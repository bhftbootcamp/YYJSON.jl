module LazyJSON

export LazyJSONDict,
    LazyJSONVector,
    LazyJSONError

export parse_lazy_json, open_lazy_json

using ..YYJSON
import ..YYJSON: read_json_doc, open_json_doc

#__ Errors

struct LazyJSONError <: Exception
    message::String
end

Base.show(io::IO, e::LazyJSONError) = print(io, e.message)

#__ LazyJSONDict

"""
    LazyJSONDict <: AbstractDict{AbstractString,Any}

Represents a dictionary for a JSON object.

## Fields
- `ptr::Ptr{YYJSONVal}`: The object value pointer.
- `iter::YYJSONObjIter`: The object iterator structure.
- `doc_ptr::Ptr{YYJSONDoc}`: The JSON document pointer (non-null only for the root).
- `alc_ptr::Ptr{YYJSONAlc}`: The dynamic allocator pointer (non-null only for the root).
- `freed::Bool`: Flag indicating whether the document is freed.
"""
mutable struct LazyJSONDict <: AbstractDict{AbstractString,Any}
    ptr::Ptr{YYJSONVal}
    iter::YYJSONObjIter
    doc_ptr::Ptr{YYJSONDoc}
    alc_ptr::Ptr{YYJSONAlc}
    freed::Bool

    function LazyJSONDict(ptr::Ptr{YYJSONVal})
        iter = YYJSONObjIter()
        new(ptr, iter, YYJSONDoc_NULL, YYJSONAlc_NULL, false)
    end

    function LazyJSONDict(ptr::Ptr{YYJSONVal}, doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc})
        iter = YYJSONObjIter()
        new(ptr, iter, doc_ptr, alc_ptr, false)
    end
end

function Base.close(obj::LazyJSONDict)
    obj.freed && return nothing
    yyjson_doc_free(obj.doc_ptr)
    yyjson_alc_dyn_free(obj.alc_ptr)
    obj.freed = true
    return nothing
end

function Base.getindex(obj::LazyJSONDict, key::AbstractString)
    value = get(obj, key, YYJSONVal_NULL)
    value === YYJSONVal_NULL && throw(KeyError(key))
    return value
end

function Base.get(obj::LazyJSONDict, key::AbstractString, default)
    value_ptr = yyjson_obj_get(obj.ptr, key)
    return value_ptr !== YYJSONVal_NULL ? parse_json_value(value_ptr) : default
end

function Base.iterate(obj::LazyJSONDict, state = nothing)
    iter = obj.iter
    iter_ptr = pointer_from_objref(iter)
    GC.@preserve iter begin
        if state === nothing
            yyjson_obj_iter_init(obj.ptr, iter_ptr) ||
                throw(LazyJSONError("Failed to initialize iterator."))
        end
        if yyjson_obj_iter_has_next(iter_ptr)
            key_ptr = yyjson_obj_iter_next(iter_ptr)
            val_ptr = yyjson_obj_iter_get_val(key_ptr)
            return (parse_json_string(key_ptr) => parse_json_value(val_ptr)), true
        else
            return nothing
        end
    end
end

Base.length(x::LazyJSONDict) = yyjson_obj_size(x.ptr)

#__ LazyJSONVector

"""
    LazyJSONVector <: AbstractVector{Any}

Represents a vector for a JSON array.

## Fields
- `ptr::Ptr{YYJSONVal}`: The array value pointer.
- `doc_ptr::Ptr{YYJSONDoc}`: The JSON document pointer (non-null only for the root).
- `alc_ptr::Ptr{YYJSONAlc}`: The dynamic allocator pointer (non-null only for the root).
- `freed::Bool`: Flag indicating whether the document is freed.
"""
mutable struct LazyJSONVector <: AbstractVector{Any}
    ptr::Ptr{YYJSONVal}
    doc_ptr::Ptr{YYJSONDoc}
    alc_ptr::Ptr{YYJSONAlc}
    freed::Bool

    function LazyJSONVector(ptr::Ptr{YYJSONVal})
        new(ptr, YYJSONDoc_NULL, YYJSONAlc_NULL, false)
    end

    function LazyJSONVector(ptr::Ptr{YYJSONVal}, doc_ptr::Ptr{YYJSONDoc}, alc_ptr::Ptr{YYJSONAlc})
        new(ptr, doc_ptr, alc_ptr, false)
    end
end

function Base.close(arr::LazyJSONVector)
    arr.freed && return nothing
    yyjson_doc_free(arr.doc_ptr)
    yyjson_alc_dyn_free(arr.alc_ptr)
    arr.freed = true
    return nothing
end

Base.length(x::LazyJSONVector) = yyjson_arr_size(x.ptr)

Base.size(x::LazyJSONVector) = (yyjson_arr_size(x.ptr),)

function Base.getindex(arr::LazyJSONVector, index::Integer)
    value = get(arr, index, YYJSONVal_NULL)
    value === YYJSONVal_NULL && throw(BoundsError(arr, index))
    return value
end

function Base.get(arr::LazyJSONVector, index::Integer, default)
    (1 <= index <= length(arr)) || return default
    value_ptr = yyjson_arr_get(arr.ptr, index-1)
    return value_ptr !== YYJSONVal_NULL ? parse_json_value(value_ptr) : default
end

#__ API

function parse_json_value(ptr::Ptr{YYJSONVal})
    return if yyjson_is_str(ptr) || yyjson_is_raw(ptr)
        parse_json_string(ptr)
    elseif yyjson_is_num(ptr)
        parse_json_number(ptr)
    elseif yyjson_is_bool(ptr)
        yyjson_get_bool(ptr)
    elseif yyjson_is_obj(ptr)
        LazyJSONDict(ptr)
    elseif yyjson_is_arr(ptr)
        LazyJSONVector(ptr)
    else
        nothing
    end
end

function parse_json_string(ptr::Ptr{YYJSONVal})
    char_ptr = yyjson_get_str(ptr)
    char_ptr === YYJSONUInt8_NULL && throw(LazyJSONError("Error parsing string."))
    return unsafe_string(char_ptr)
end

function parse_json_number(ptr::Ptr{YYJSONVal})
    return yyjson_is_real(ptr) ? yyjson_get_real(ptr) : yyjson_get_int(ptr)
end

function parse_json_root(doc_ptr::Ptr{YYJSONDoc})
    root_ptr = yyjson_doc_get_root(doc_ptr)
    root_ptr === YYJSONVal_NULL && throw(LazyJSONError("Error parsing root."))
    return root_ptr
end

"""
    parse_lazy_json([f::Function], json::String; kw...)
    parse_lazy_json([f::Function], json::Vector{UInt8}; kw...)

Parse a JSON string `json` (or vector of `UInt8`) into a [`LazyJSONDict`](@ref) or [`LazyJSONVector`](@ref).

!!! note
    When it's no longer needed, it should be closed with `close` or use `do` block syntax.

## Keyword arguments
Similar to [`parse_json`](@ref).

## Examples
```julia-repl
julia> json = \"\"\"{
           "str": "John Doe",
           "num": "30",
           "array": [1,2,{"a": 3, "b": null}],
           "bool": false,
           "obj" : {"a": 1, "b": null},
           "another": "key"
       }
       \"\"\";

julia> parse_lazy_json(json)
LazyJSONDict with 6 entries:
  "str"     => "John Doe"
  "num"     => "30"
  "array"   => Any[1, 2, LazyJSONDict("a"=>3, "b"=>nothing)]
  "bool"    => false
  "obj"     => LazyJSONDict("a"=>1, "b"=>nothing)
  "another" => "key"
```

```julia-repl
julia> json = \"\"\"{
           "array": [1,2,3]
       }
       \"\"\";

array = []
parse_lazy_json(json) do data
    for value in data["array"]
        push!(array, value)
    end
end

julia> array
3-element Vector{Any}:
 1
 2
 3
```
"""
function parse_lazy_json end

function parse_lazy_json(json::AbstractString; kw...)
    allocator = yyjson_alc_dyn_new()
    allocator === YYJSONAlc_NULL && throw(LazyJSONError("Failed to allocate memory for JSON parsing."))
    doc_ptr = read_json_doc(json; alc = allocator, kw...)
    root_ptr = parse_json_root(doc_ptr)
    root = yyjson_is_obj(root_ptr) ? LazyJSONDict(root_ptr, doc_ptr, allocator) : LazyJSONVector(root_ptr, doc_ptr, allocator)
    finalizer(close, root)
    return root
end

function parse_lazy_json(json::AbstractVector{UInt8}; kw...)
    return parse_lazy_json(unsafe_string(pointer(json), length(json)); kw...)
end

function parse_lazy_json(f::Function, x...; kw...)
    root = parse_lazy_json(x...; kw...)
    try
        f(root)
    finally
        close(root)
    end
end

"""
    open_lazy_json([f::Function], path::String; kw...)
    open_lazy_json([f::Function], io::IO; kw...)

Reads a JSON file from a given `path` or `io` and parse it into a [`LazyJSONDict`](@ref) or [`LazyJSONVector`](@ref).

!!! note
    When it's no longer needed, it should be closed with `close` or use `do` block syntax.

## Keyword arguments
Similar to [`parse_json`](@ref).
"""
function open_lazy_json end

function open_lazy_json(path::AbstractString; kw...)
    allocator = yyjson_alc_dyn_new()
    allocator === YYJSONAlc_NULL && throw(LazyJSONError("Failed to allocate memory for JSON parsing."))
    doc_ptr = open_json_doc(path; alc = allocator, kw...)
    root_ptr = parse_json_root(doc_ptr)
    root = yyjson_is_obj(root_ptr) ? LazyJSONDict(root_ptr, doc_ptr, allocator) : LazyJSONVector(root_ptr, doc_ptr, allocator)
    finalizer(close, root)
    return root
end

function open_lazy_json(io::IO; kw...)
    return parse_lazy_json(read(io))
end

function open_lazy_json(f::Function, x...; kw...)
    root = open_lazy_json(x...; kw...)
    try
        f(root)
    finally
        close(root)
    end
end

end
