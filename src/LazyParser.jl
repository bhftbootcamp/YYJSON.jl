module LazyParser

export JSONDoc,
    LazyDict,
    LazyVector,
    LazyYYJSONError

export lazy_parse

using ..YYJSON
import ..YYJSON: read_json_doc, open_json_doc

struct LazyYYJSONError <: Exception
    message::String
end

Base.show(io::IO, e::LazyYYJSONError) = print(io, e.message)

#__ LazyDict
struct LazyDict{T<:Ptr{YYJSONVal}} <: AbstractDict{AbstractString, Any}
    ptr::T
    iter::YYJSONObjIter

    function LazyDict(ptr::Ptr{YYJSONVal})
        iter = YYJSONObjIter()
        new{Ptr{YYJSONVal}}(ptr, iter)
    end
end

function Base.getindex(obj::LazyDict, key::String)
    value = get(obj, key, :NOT_SET)
    if value === :NOT_SET
        throw(KeyError(key))
    else
        return value
    end
end

function Base.get(obj::LazyDict, key::String, default)
    value_ptr = yyjson_obj_get(obj.ptr, key)
    return if value_ptr != C_NULL
        parse_value(value_ptr)
    else
        default
    end    
end

function Base.iterate(obj::LazyDict)
    iter = obj.iter
    iter_ptr = pointer_from_objref(iter)
    GC.@preserve iter begin
        yyjson_obj_iter_init(obj.ptr, iter_ptr) || throw(LazyYYJSONError("Failed to initialize object iterator"))

        yyjson_obj_iter_has_next(iter_ptr) || return nothing
        
        key_ptr = yyjson_obj_iter_next(iter_ptr)
        key = parse_string(key_ptr)
        val_ptr = yyjson_obj_iter_get_val(key_ptr)
        val = parse_value(val_ptr)
        new_state = yyjson_obj_iter_has_next(iter_ptr)
        return (key => val), new_state
    end
end

function Base.iterate(obj::LazyDict, state)
    state || return nothing
    iter = obj.iter
    iter_ptr = pointer_from_objref(iter)
    GC.@preserve iter begin
        key_ptr = yyjson_obj_iter_next(iter_ptr)
        key = parse_string(key_ptr)
        val_ptr = yyjson_obj_iter_get_val(key_ptr)
        val = parse_value(val_ptr)
        new_state = yyjson_obj_iter_has_next(iter_ptr)
        return (key => val), new_state
    end
end

Base.length(x::LazyDict) = yyjson_obj_size(x.ptr)

#__ LazyVector

struct LazyVector{T<:Ptr{YYJSONVal}} <: AbstractVector{Any}
    ptr::T
end

Base.length(x::LazyVector) = yyjson_arr_size(x.ptr)

Base.size(x::LazyVector) = (length(x),)

function Base.getindex(arr::LazyVector, index::Int)
    value = get(arr, index, :NOT_SET)
    if value === :NOT_SET
        throw(BoundsError(arr, index))
    else
        return value
    end
end

function Base.get(arr::LazyVector, index::Int, default)
    (1 <= index <= length(arr)) || return default
    value_ptr = yyjson_arr_get(arr.ptr, index-1)
    return if value_ptr != C_NULL
        parse_value(value_ptr)
    else
        default
    end 
end

#__ JSONDoc
mutable struct JSONDoc{LT <: Union{LazyDict, LazyVector}} 
    doc_ptr::Ptr{YYJSONDoc}
    alc_ptr::Ptr{YYJSONAlc}
    root::LT
    is_open::Bool

    function JSONDoc(doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc}, root::LT) where {LT <: Union{LazyDict, LazyVector}} 
        doc = new{LT}(doc_ptr, alc_ptr, root, true)
        finalizer(close, doc)
        return doc
    end
end

function Base.show(io::IO, ::JSONDoc{LT}) where LT
    print(io, "JSON Document $LT")
end

function Base.close(doc::JSONDoc)
    doc.is_open || return nothing
    yyjson_doc_free(doc.doc_ptr)
    yyjson_alc_dyn_free(doc.alc_ptr)
    doc.is_open = false
    return nothing
end

function Base.getindex(doc::JSONDoc, key::Union{AbstractString, Int64})
    value = getindex(doc.root, key)
    return value
end

function Base.get(doc::JSONDoc, key::Union{AbstractString, Int64}, default)
    value = get(doc.root, key, default)
    return value
end

function Base.keys(doc::JSONDoc{LT}) where LT
    return if LT <: LazyDict
        keys(doc.root)
    else
        LinearIndices(1:length(doc))
    end
end

function Base.values(doc::JSONDoc{LT}) where LT
    return if LT <: LazyDict
        values(doc.root)
    else
        [v for v in doc.root]
    end
end

Base.collect(doc::JSONDoc) = collect(doc.root)

Base.length(doc::JSONDoc) = length(doc.root)

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
    ptr_char == C_NULL && throw(LazyYYJSONError("Error while parsing string: $ptr_char"))
    return unsafe_string(ptr_char)
end

function parse_number(ptr::Ptr{YYJSONVal})
    return if yyjson_is_real(ptr)
        yyjson_get_real(ptr)
    else
        Int64(yyjson_get_num(ptr))
    end
end

function lazy_parse(json::AbstractString; kw...)
    allocator = yyjson_alc_dyn_new()
    doc_ptr = read_json_doc(json; alc = allocator, kw...)
    root_ptr = yyjson_doc_get_root(doc_ptr)
    root_ptr == C_NULL && throw(LazyYYJSONError("Error while parsing root: $root"))
    root = parse_value(root_ptr)
    doc = JSONDoc(doc_ptr, allocator, root)
    return doc
end

function lazy_parse(json::AbstractVector{UInt8}; kw...)
    return lazy_parse(unsafe_string(pointer(json), length(json)); kw...)
end

end