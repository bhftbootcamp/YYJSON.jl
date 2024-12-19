module LazyParser

export JSONDoc,
    LazyDict,
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
struct LazyDict <: AbstractDict{AbstractString, Any}
    ptr::Ptr{YYJSONVal}
    iter::YYJSONObjIter

    function LazyDict(ptr::Ptr{YYJSONVal})
        iter = YYJSONObjIter()
        new(ptr, iter)
    end
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

struct LazyVector <: AbstractVector{Any}
    ptr::Ptr{YYJSONVal}
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

#__ JSONDoc
mutable struct JSONDoc{T <: Union{LazyDict,LazyVector}} 
    doc_ptr::Ptr{YYJSONDoc}
    alc_ptr::Ptr{YYJSONAlc}
    root::T
    is_open::Bool

    function JSONDoc(doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc}, root::T) where {T <: Union{LazyDict,LazyVector}} 
        doc = new{T}(doc_ptr, alc_ptr, root, true)
        finalizer(close, doc)
        return doc
    end
end

Base.length(doc::JSONDoc) = length(doc.root)
Base.isopen(doc::JSONDoc) = doc.is_open
Base.keys(doc::JSONDoc) = keys(doc.root)
Base.values(doc::JSONDoc) = values(doc.root)
Base.iterate(doc::JSONDoc) = iterate(doc.root)
Base.iterate(doc::JSONDoc{LazyDict}, state) = iterate(doc.root, state)
Base.iterate(doc::JSONDoc{LazyVector}, state::Tuple) = iterate(doc.root, state)

function Base.print(io::IO, ::JSONDoc{LazyDict})
    print(io, "JSONDoc{LazyDict}")
end

function Base.show(io::IO, doc::JSONDoc{LazyDict})
    len = length(doc)
    print(io, doc, " with ", len, " entr$(len < 2 ? "y" : "ies")")
end

function Base.print(io::IO, ::JSONDoc{LazyVector})
    print(io, "JSONDoc{LazyVector}")
end

function Base.show(io::IO, doc::JSONDoc{LazyVector})
    len = length(doc)
    print(io, len, "-element ", doc)
end

function Base.close(doc::JSONDoc)
    isopen(doc) || return nothing
    yyjson_doc_free(doc.doc_ptr)
    yyjson_alc_dyn_free(doc.alc_ptr)
    doc.is_open = false
    return nothing
end

function Base.getindex(doc::JSONDoc, key::Union{AbstractString,Integer})
    value = getindex(doc.root, key)
    return value
end

function Base.get(doc::JSONDoc, key::Union{AbstractString,Integer}, default)
    value = get(doc.root, key, default)
    return value
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
    root = parse_root(doc_ptr)
    return JSONDoc(doc_ptr, allocator, root)
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
    root = parse_root(doc_ptr)
    return JSONDoc(doc_ptr, allocator, root)
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