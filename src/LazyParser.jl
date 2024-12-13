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

"""
```julia
using YYJSON

json = \"\"\" {"body":{"count":1726219849072.1, "count2": 1},"name":"json","id":100,"bool":false,"arr":[1,2,["a","b"],false]} \"\"\";

doc = lazy_parse(json)

julia> doc["body"]
LazyDict{Ptr{YYJSONVal}} with 2 entries:
  "count"  => 1.72622e12
  "count2" => 1.0

julia> doc["name"]
"json"

julia> doc["id"]
100.0

julia> doc["arr"]
4-element LazyVector{Ptr{YYJSONVal}}:
     1.0
     2.0
      Ptr{YYJSONVal}["a", "b"]
 false

julia> body = doc["body"]
LazyDict{Ptr{YYJSONVal}} with 2 entries:
  "count"  => 1.72622e12
  "count2" => 1.0

julia> GC.@preserve body for (k,v) in body
           println("\$k => \$v")
       end
count => 1.7262198490721e12
count2 => 1.0
```
"""
struct LazyDict{T<:Ptr{YYJSONVal}} <: AbstractDict{AbstractString, Ptr{YYJSONVal}}
    obj_ptr::T
    #iter::YYJSONObjIter
    iter_ptr::Ptr{YYJSONObjIter}
    #iter_ref::Ref{YYJSONObjIter}

    function LazyDict(obj_ptr::Ptr{YYJSONVal})
        iter = YYJSONObjIter()
        iter_ref = Ref(iter)
        iter_ptr = Base.unsafe_convert(Ptr{YYJSONObjIter}, iter_ref)

        new{Ptr{YYJSONVal}}(obj_ptr, iter_ptr)#iter, iter_ptr, iter_ref)
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
    value_ptr = yyjson_obj_get(obj.obj_ptr, key)
    return if value_ptr != C_NULL
        parse_value(value_ptr)
    else
        default
    end    
end

# function Base.iterate(obj::LazyDict)
#     iter = obj.iter
#     iter_ptr = pointer_from_objref(iter)
#     GC.@preserve iter begin
#         yyjson_obj_iter_init(obj.obj_ptr, iter_ptr) || throw(LazyYYJSONError("Failed to initialize object iterator"))

#         yyjson_obj_iter_has_next(iter_ptr) || return nothing
        
#         key_ptr = yyjson_obj_iter_next(iter_ptr)
#         key = parse_string(key_ptr)
#         val_ptr = yyjson_obj_iter_get_val(key_ptr)
#         val = parse_value(val_ptr)
#         new_state = yyjson_obj_iter_has_next(iter_ptr)
#         return (key => val), new_state
#     end
# end

# function Base.iterate(obj::LazyDict, state)
#     state || return nothing
#     iter = obj.iter
#     iter_ptr = pointer_from_objref(iter)
#     GC.@preserve iter begin
#         key_ptr = yyjson_obj_iter_next(iter_ptr)
#         key = parse_string(key_ptr)
#         val_ptr = yyjson_obj_iter_get_val(key_ptr)
#         val = parse_value(val_ptr)
#         new_state = yyjson_obj_iter_has_next(iter_ptr)
#         return (key => val), new_state
#     end
# end

# function Base.iterate(obj::LazyDict)
#     GC.@preserve obj begin
#         yyjson_obj_iter_init(obj.obj_ptr, obj.iter_ptr) || throw(LazyYYJSONError("Failed to initialize object iterator"))

#         yyjson_obj_iter_has_next(obj.iter_ptr) || return nothing
        
#         key_ptr = yyjson_obj_iter_next(obj.iter_ptr)
#         key = parse_string(key_ptr)
#         val_ptr = yyjson_obj_iter_get_val(key_ptr)
#         val = parse_value(val_ptr)
#         new_state = yyjson_obj_iter_has_next(obj.iter_ptr)
#         kv = (key => val)
#         return kv, new_state
#     end
# end

# function Base.iterate(obj::LazyDict, state)
#     state || return nothing
#     GC.@preserve obj begin
#         key_ptr = yyjson_obj_iter_next(obj.iter_ptr)
#         key = parse_string(key_ptr)
#         val_ptr = yyjson_obj_iter_get_val(key_ptr)
#         val = parse_value(val_ptr)
#         new_state = yyjson_obj_iter_has_next(obj.iter_ptr)
#         kv = (key => val)
#         return kv, new_state
#     end
# end

# function Base.iterate(obj::LazyDict)
#     iter_ptr = Base.unsafe_convert(Ptr{YYJSONObjIter}, obj.iter_ref)
#     GC.@preserve obj begin
#         yyjson_obj_iter_init(obj.obj_ptr, iter_ptr) || throw(LazyYYJSONError("Failed to initialize object iterator"))

#         yyjson_obj_iter_has_next(iter_ptr) || return nothing
        
#         key_ptr = yyjson_obj_iter_next(iter_ptr)
#         key = parse_string(key_ptr)
#         val_ptr = yyjson_obj_iter_get_val(key_ptr)
#         val = parse_value(val_ptr)
#         new_state = yyjson_obj_iter_has_next(iter_ptr)
#         return (key => val), new_state
#     end
# end

# function Base.iterate(obj::LazyDict, state)
#     state || return nothing
#     iter_ptr = Base.unsafe_convert(Ptr{YYJSONObjIter}, obj.iter_ref)
#     GC.@preserve obj begin
#         key_ptr = yyjson_obj_iter_next(iter_ptr)
#         key = parse_string(key_ptr)
#         val_ptr = yyjson_obj_iter_get_val(key_ptr)
#         val = parse_value(val_ptr)
#         new_state = yyjson_obj_iter_has_next(iter_ptr)
#         return (key => val), new_state
#     end
# end

function Base.iterate(obj::LazyDict)
    GC.@preserve obj begin
        yyjson_obj_iter_init(obj.obj_ptr, obj.iter_ptr) || throw(LazyYYJSONError("Failed to initialize object iterator"))

        yyjson_obj_iter_has_next(obj.iter_ptr) || return nothing
        
        key_ptr = yyjson_obj_iter_next(obj.iter_ptr)
        key = parse_string(key_ptr)
        val_ptr = yyjson_obj_iter_get_val(key_ptr)
        val = parse_value(val_ptr)
        new_state = yyjson_obj_iter_has_next(obj.iter_ptr)
        kv = (key => val)
        return kv, new_state
    end
end

function Base.iterate(obj::LazyDict, state::Bool)
    GC.@preserve obj begin
        state || return nothing
        key_ptr = yyjson_obj_iter_next(obj.iter_ptr)
        key = parse_string(key_ptr)
        val_ptr = yyjson_obj_iter_get_val(key_ptr)
        val = parse_value(val_ptr)
        new_state = yyjson_obj_iter_has_next(obj.iter_ptr)
        kv = (key => val)
        return kv, new_state
    end
end

Base.length(x::LazyDict) = yyjson_obj_size(x.obj_ptr)

struct LazyVector{T<:Ptr{YYJSONVal}} <: AbstractVector{Ptr{YYJSONVal}}
    arr_ptr::T
end

Base.length(x::LazyVector) = yyjson_arr_size(x.arr_ptr)

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
    value_ptr = yyjson_arr_get(arr.arr_ptr, index-1)
    return if value_ptr != C_NULL
        parse_value(value_ptr)
    else
        default
    end 
end

mutable struct JSONDoc 
    doc_ptr::Ptr{YYJSONDoc}
    alc_ptr::Ptr{YYJSONAlc}
    root::LazyDict
    is_open::Bool

    function JSONDoc(doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc}, root::LazyDict)
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

function parse_value(ptr::Ptr{YYJSONVal})
    return if yyjson_is_str(ptr)
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
    return yyjson_get_num(ptr)
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