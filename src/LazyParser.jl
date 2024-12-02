module LazyParser

export JSONObject,
    JSONDoc,
    LazyYYJSONError

export lazy_parse

using ..YYJSON
using UnsafeArrays
using StringViews

include("Common.jl")

struct LazyYYJSONError <: Exception
    message::String
end

Base.show(io::IO, e::LazyYYJSONError) = print(io, e.message)

mutable struct JSONObject{T}
    ptr::Ptr{YYJSONVal}
    data
    size::Int64
    is_evaluated::Bool

    function JSONObject{T}(ptr::Ptr{YYJSONVal}) where T
        new{T}(ptr, nothing, -1, false)
    end
end

function Base.show(io::IO, obj::JSONObject{YYJSON_TYPE_OBJ})
    _evaluate(obj)
    for (key, value) in obj.data
        println(io, key, " => ", value)
    end
end

function Base.show(io::IO, obj::JSONObject{YYJSON_TYPE_ARR})
    _evaluate(obj)
    print(io, obj.data)
end

function Base.show(io::IO, obj::JSONObject)
    _evaluate(obj)
    print(io, obj.is_evaluated ? obj.data : "<not-evaluated>")
end

struct NotSet end
NOT_SET = NotSet()

function Base.getindex(obj::JSONObject, key::String)
    value = get(obj, key, NOT_SET)
    if value === NOT_SET
        throw(KeyError(key))
    else
        return value
    end
end

function Base.get(obj::JSONObject, key::String, default)
    _evaluate(obj)
    if haskey(obj.data, key)
        value = obj.data[key]
        _evaluate(value)
        return value
    else
        return default
    end    
end

function Base.getindex(obj::JSONObject, index::Int)
    _evaluate(obj)
    len = length(obj)
    (1 <= index <= len) || throw(BoundsError(obj, index))
    value = obj.data[index]
    _evaluate(value)
    return value
end

function Base.get(obj::JSONObject, index::Int, default)
    _evaluate(obj)
    try
        value = obj.data[index]
        _evaluate(value)
        return value
    catch e
        if isa(e, BoundsError)
            return default
        end
        throw(e)
    end
end

Base.length(obj::JSONObject) = obj.size

mutable struct JSONDoc 
    doc_ptr::Ptr{YYJSONDoc}
    alc_ptr::Ptr{YYJSONAlc}
    root::JSONObject
    is_open::Bool

    function JSONDoc(doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc}, root::JSONObject)
        doc = new(doc_ptr, alc_ptr, root, true)
        finalizer(close, doc)
        return doc
    end
end

function Base.show(io::IO, doc::JSONDoc)
    print(io, "JSON Document")
end

function Base.close(doc::JSONDoc)
    doc.is_open || return nothing
    yyjson_doc_free(doc.doc_ptr)
    yyjson_alc_dyn_free(doc.alc_ptr)
    doc.is_open = false
    return nothing
end

function Base.getindex(doc::JSONDoc, key::String)
    value = getindex(doc.root, key)
    return value
end

function _evaluate(obj::JSONObject{YYJSON_TYPE_OBJ})
    obj.is_evaluated && return nothing
    iter = YYJSONObjIter()
    iter_ref = Ref(iter)
    iter_ptr = Base.unsafe_convert(Ptr{YYJSONObjIter}, iter_ref)
    GC.@preserve iter begin
        yyjson_obj_iter_init(obj.ptr, iter_ptr) || throw(LazyYYJSONError("Failed to initialize object iterator"))
        data = Dict{StringView, JSONObject}()
        for _ in 1:iter.max
            key_ptr = yyjson_obj_iter_next(iter_ptr)
            val_ptr = yyjson_obj_iter_get_val(key_ptr)
            data[parse_string(key_ptr)] = parse_value(val_ptr)
        end
    end
    obj.data = data
    obj.size = iter.max
    obj.is_evaluated = true
    return nothing
end

function _evaluate(obj::JSONObject{YYJSON_TYPE_ARR})
    obj.is_evaluated && return nothing
    iter = YYJSONArrIter()
    iter_ref = Ref(iter)
    iter_ptr = Base.unsafe_convert(Ptr{YYJSONArrIter}, iter_ref)
    GC.@preserve iter begin
        yyjson_arr_iter_init(obj.ptr, iter_ptr) || throw(LazyYYJSONError("Failed to initialize array iterator"))
        data = Vector{JSONObject}(undef, iter.max)
        for i in 1:iter.max
            val_ptr = yyjson_arr_iter_next(iter_ptr)
            data[i] = parse_value(val_ptr)
        end
    end
    obj.data = data
    obj.size = iter.max
    obj.is_evaluated = true
    return nothing
end

function _evaluate(obj::JSONObject{YYJSON_TYPE_STR})
    obj.is_evaluated && return nothing
    obj.data = parse_string(obj.ptr)
    obj.size = length(obj.data)
    obj.is_evaluated = true
    return nothing
end

function _evaluate(obj::JSONObject{YYJSON_TYPE_NUM})
    obj.is_evaluated && return nothing
    obj.data = parse_number(obj.ptr)
    obj.is_evaluated = true
    return nothing
end

function _evaluate(obj::JSONObject{YYJSON_TYPE_BOOL})
    obj.is_evaluated && return nothing
    obj.data = yyjson_get_bool(obj.ptr)
    obj.is_evaluated = true
    return nothing
end

function parse_value(ptr::Ptr{YYJSONVal})
    type = yyjson_get_type(ptr)
    return JSONObject{type}(ptr)
end

function parse_string(ptr::Ptr{YYJSONVal})
    ptr_char = yyjson_get_str(ptr)
    ptr_char == C_NULL && throw(LazyYYJSONError("Error while parsing string: $ptr_char"))
    size = yyjson_get_len(ptr)
    arr = UnsafeArray(ptr_char, (Int(size),))
    view = StringView(arr)
    return view
end

function parse_number(ptr::Ptr{YYJSONVal})
    num_subtype = yyjson_get_subtype(ptr)
    return if num_subtype == YYJSON_SUBTYPE_UINT
        yyjson_get_uint(ptr)
    elseif num_subtype == YYJSON_SUBTYPE_SINT
        yyjson_get_sint(ptr)
    else
        yyjson_get_real(ptr)
    end
end

function lazy_parse(json::Union{AbstractString,AbstractVector{UInt8}}; kw...)
    allocator = yyjson_alc_dyn_new()
    doc_ptr = read_json_doc(json; alc = allocator, kw...)
    root_ptr = yyjson_doc_get_root(doc_ptr)
    root_ptr == C_NULL && throw(LazyYYJSONError("Error while parsing root: $root"))
    root = parse_value(root_ptr)
    doc = JSONDoc(doc_ptr, allocator, root)
    return doc
end

end