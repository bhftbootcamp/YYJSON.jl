module LazyParser

export LazyDict,
    LazyVector,
    LazyYYJSONError

export lazy_parse, lazy_open

using ..YYJSON
import ..YYJSON: read_json_doc, open_json_doc

struct LazyYYJSONError <: Exception
    message::String
end

Base.show(io::IO, e::LazyYYJSONError) = print(io, e.message)

#__ LazyDict

mutable struct LazyDict <: AbstractDict{AbstractString, Any}
    ptr::Ptr{YYJSONVal}
    iter::YYJSONObjIter
    doc_ptr::Ptr
    alc_ptr::Ptr
    is_open::Bool

    function LazyDict(ptr::Ptr{YYJSONVal})
        iter = YYJSONObjIter()
        new(ptr, iter, C_NULL, C_NULL, true)
    end

    function LazyDict(ptr::Ptr{YYJSONVal}, doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc})
        iter = YYJSONObjIter()
        new(ptr, iter, doc_ptr, alc_ptr, true)
    end
end

function Base.close(root::LazyDict)
    (root.is_open && root.alc_ptr != C_NULL && root.doc_ptr != C_NULL) || return nothing
    yyjson_doc_free(root.doc_ptr)
    yyjson_alc_dyn_free(root.alc_ptr)
    root.is_open = false
    return nothing
end

function Base.getindex(obj::LazyDict, key::AbstractString)
    value = get(obj, key, C_NULL)
    value === C_NULL && throw(KeyError(key))
    return value
end

function Base.get(obj::LazyDict, key::AbstractString, default)
    value_ptr = yyjson_obj_get(obj.ptr, key)
    return value_ptr != C_NULL ? parse_value(value_ptr) : default
end

function _lazy_dict_next(iter_ptr::Ptr{YYJSONObjIter})
    key_ptr = yyjson_obj_iter_next(iter_ptr)
    val_ptr = yyjson_obj_iter_get_val(key_ptr)
    return (parse_string(key_ptr) => parse_value(val_ptr)), yyjson_obj_iter_has_next(iter_ptr)
end

function Base.iterate(obj::LazyDict, state = nothing)
    iter = obj.iter
    iter_ptr = Ptr{YYJSONObjIter}(pointer_from_objref(iter))
    GC.@preserve iter begin
        if state === nothing
            yyjson_obj_iter_init(obj.ptr, iter_ptr) ||
                throw(LazyYYJSONError("Failed to initialize iterator"))
        end
        return yyjson_obj_iter_has_next(iter_ptr) ? _lazy_dict_next(iter_ptr) : nothing
    end
end

Base.length(x::LazyDict) = yyjson_obj_size(x.ptr)

#__ LazyVector

mutable struct LazyVector <: AbstractVector{Any}
    ptr::Ptr{YYJSONVal}
    doc_ptr::Ptr
    alc_ptr::Ptr
    is_open::Bool

    function LazyVector(ptr::Ptr{YYJSONVal})
        new(ptr, C_NULL, C_NULL, true)
    end

    function LazyVector(ptr::Ptr{YYJSONVal}, doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc})
        new(ptr, doc_ptr, alc_ptr, true)
    end
end

function Base.close(root::LazyVector)
    (root.is_open && root.alc_ptr != C_NULL && root.doc_ptr != C_NULL) || return nothing
    yyjson_doc_free(root.doc_ptr)
    yyjson_alc_dyn_free(root.alc_ptr)
    root.is_open = false
    return nothing
end

Base.length(x::LazyVector) = yyjson_arr_size(x.ptr)

Base.size(x::LazyVector) = (yyjson_arr_size(x.ptr),)

function Base.getindex(arr::LazyVector, index::Integer)
    value = get(arr, index, C_NULL)
    value === C_NULL && throw(BoundsError(arr, index))
    return value
end

function Base.get(arr::LazyVector, index::Integer, default)
    (1 <= index <= length(arr)) || return default
    value_ptr = yyjson_arr_get(arr.ptr, index-1)
    return value_ptr != C_NULL ? parse_value(value_ptr) : default
end

#__ Parser

function parse_value(ptr::Ptr{YYJSONVal})
    return if yyjson_is_str(ptr)
        parse_string(ptr)
    elseif yyjson_is_raw(ptr)
        parse_string(ptr)
    elseif yyjson_is_num(ptr)
        parse_number(ptr)
    elseif yyjson_is_bool(ptr)
        yyjson_get_bool(ptr)
    elseif yyjson_is_obj(ptr)
        LazyDict(ptr)
    elseif yyjson_is_arr(ptr)
        LazyVector(ptr)
    else
        nothing
    end
end

function parse_string(ptr::Ptr{YYJSONVal})
    ptr_char = yyjson_get_str(ptr)
    ptr_char == C_NULL && throw(LazyYYJSONError("Error parsing string"))
    return unsafe_string(ptr_char)
end

function parse_number(ptr::Ptr{YYJSONVal})
    return yyjson_is_real(ptr) ? yyjson_get_real(ptr) : yyjson_get_int(ptr)
end

function parse_root(doc_ptr::Ptr{YYJSONDoc})
    root_ptr = yyjson_doc_get_root(doc_ptr)
    root_ptr == C_NULL && throw(LazyYYJSONError("Error parsing root"))
    return parse_value(root_ptr)
end

function lazy_parse(json::AbstractString; kw...)
    allocator = yyjson_alc_dyn_new()
    doc_ptr = read_json_doc(json; alc = allocator, kw...)
    root_ptr = yyjson_doc_get_root(doc_ptr)
    root_ptr == C_NULL && throw(LazyYYJSONError("Error parsing root"))
    return yyjson_is_obj(root_ptr) ? LazyDict(root_ptr, doc_ptr, allocator) : LazyVector(root_ptr, doc_ptr, allocator)
end

function lazy_parse(json::AbstractVector{UInt8}; kw...)
    return lazy_parse(unsafe_string(pointer(json), length(json)); kw...)
end

function lazy_parse(f::Function, x...; kw...)
    doc = lazy_parse(x...; kw...)
    try
        f(doc)
    finally
        close(doc)
    end
end

function lazy_open(path::AbstractString; kw...)
    allocator = yyjson_alc_dyn_new()
    doc_ptr = open_json_doc(path; alc = allocator, kw...)
    root_ptr = yyjson_doc_get_root(doc_ptr)
    root_ptr == C_NULL && throw(LazyYYJSONError("Error parsing root"))
    return yyjson_is_obj(root_ptr) ? LazyDict(root_ptr, doc_ptr, allocator) : LazyVector(root_ptr, doc_ptr, allocator)
end

function lazy_open(io::IO; kw...)
    return lazy_parse(read(io))
end

function lazy_open(f::Function, x...; kw...)
    doc = lazy_open(x...; kw...)
    try
        f(doc)
    finally
        close(doc)
    end
end

end
