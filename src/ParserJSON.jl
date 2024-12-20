module ParserJSON

export parse_json,
    open_json,
    YYJSONError

using ..YYJSON
import ..YYJSON: read_json_doc, open_json_doc

struct YYJSONError <: Exception
    message::String
end

Base.show(io::IO, e::YYJSONError) = print(io, e.message)

const NullType = Union{Missing,Nothing}

@inline function parse_none(none_ptr::Ptr{YYJSONVal})
    return throw(YYJSONError("Invalid JSON value type."))
end

@inline function parse_raw(raw_ptr::Ptr{YYJSONVal})
    return unsafe_string(yyjson_get_raw(raw_ptr))
end

@inline function parse_bool(bool_ptr::Ptr{YYJSONVal})
    return yyjson_get_bool(bool_ptr)
end

@inline function parse_int(int_ptr::Ptr{YYJSONVal})
    return Int64(yyjson_get_num(int_ptr))
end

@inline function parse_real(real_ptr::Ptr{YYJSONVal})
    return yyjson_get_real(real_ptr)
end

@inline function parse_str(str_ptr::Ptr{YYJSONVal})
    return unsafe_string(yyjson_get_str(str_ptr))
end

function parse_arr(arr_ptr::Ptr{YYJSONVal}, dict_type::Type{<:AbstractDict}, null::NullType)
    iter = YYJSONArrIter()
    iter_ptr = pointer_from_objref(iter)
    yyjson_arr_iter_init(arr_ptr, iter_ptr) || throw(YYJSONError("Failed to initialize array iterator."))
    array_elements = Vector{Any}(undef, yyjson_arr_size(arr_ptr))
    @inbounds for i in eachindex(array_elements)
        val_ptr = yyjson_arr_iter_next(iter_ptr)
        array_elements[i] = parse_value(val_ptr, dict_type, null)
    end
    return array_elements
end

function parse_obj(obj_ptr::Ptr{YYJSONVal}, dict_type::Type{<:AbstractDict}, null::NullType)
    iter = YYJSONObjIter()
    iter_ptr = pointer_from_objref(iter)
    yyjson_obj_iter_init(obj_ptr, iter_ptr) || throw(YYJSONError("Failed to initialize object iterator."))
    object_elements = dict_type()
    for i in 1:yyjson_obj_size(obj_ptr)
        key_ptr = yyjson_obj_iter_next(iter_ptr)
        val_ptr = yyjson_obj_iter_get_val(key_ptr)
        object_elements[parse_str(key_ptr)] = parse_value(val_ptr, dict_type, null)
    end
    return object_elements
end

function parse_value(val_ptr::Ptr{YYJSONVal}, dict_type::Type{<:AbstractDict}, null::NullType)
    return if yyjson_is_str(val_ptr)
        parse_str(val_ptr)
    elseif yyjson_is_raw(val_ptr)
        parse_raw(val_ptr)
    elseif yyjson_is_real(val_ptr)
        parse_real(val_ptr)
    elseif yyjson_is_int(val_ptr)
        parse_int(val_ptr)
    elseif yyjson_is_bool(val_ptr)
        parse_bool(val_ptr)
    elseif yyjson_is_obj(val_ptr)
        parse_obj(val_ptr, dict_type, null)
    elseif yyjson_is_arr(val_ptr)
        parse_arr(val_ptr, dict_type, null)
    elseif yyjson_is_null(val_ptr)
        null
    else
        parse_none(val_ptr)
    end
end

"""
    parse_json(x::AbstractString; kw...)
    parse_json(x::Vector{UInt8}; kw...)

Parse a JSON string `x` (or vector of `UInt8`) into a dictionary.

## Keyword arguments
- `dict_type::Type{D} = Dict{String,Any}`: Defines the type of `dictionary` into which `objects` will be parsed.
- `null::Union{Nothing,Missing} = nothing`: Null value.
- `in_situ::Bool`: This option allows the reader to modify and use the input data to store string values, which can slightly improve reading speed.
- `number_as_raw::Bool`: Read all numbers as raw strings without parsing.
- `bignum_as_raw::Bool`: Read big numbers as raw strings.
- `stop_when_done::Bool`: Stop parsing when reaching the end of a JSON document instead of issues an error if there's additional content after it.
- `allow_comments::Bool`: Allow C-style single line and multiple line comments.
- `allow_inf_and_nan::Bool`: Allow `nan`/`inf`` number or case-insensitive literal.
- `allow_invalid_unicode::Bool`: Allow reading invalid unicode when parsing string values.
- `allow_trailing_commas::Bool`: Allow a single trailing comma at the end of an object or array.

## Examples
```julia
julia> json = \"\"\"{
           "str": "John Doe",
           "num": "30",
           "array": [1,2,{"a": 3, "b": null}],
           "bool": false,
           "obj" : {"a": 1, "b": null},
           "another": "key"
       }
       \"\"\";

julia> parse_json(json)
Dict{String, Any} with 6 entries:
  "another" => "key"
  "str"     => "John Doe"
  "obj"     => Dict{String, Any}("b"=>nothing, "a"=>1)
  "array"   => Any[1, 2, Dict{String, Any}("b"=>nothing, "a"=>3)]
  "num"     => "30"
  "bool"    => false
```
"""
function parse_json(
    json::AbstractString;
    dict_type::Type{<:AbstractDict} = Dict{String,Any},
    null::NullType = nothing,
    kw...
)
    doc_ptr = read_json_doc(json; kw...)
    try
        return parse_value(
            yyjson_doc_get_root(doc_ptr),
            dict_type,
            null,
        )
    finally
        yyjson_doc_free(doc_ptr)
    end
end

function parse_json(json::AbstractVector{UInt8}; kw...)
    return parse_json(unsafe_string(pointer(json), length(json)); kw...)
end

"""
    open_json(path::AbstractString; kw...)

Reads a JSON file from a given `path` and parse it into dictionary.

## Keyword arguments
Similar to [`parse_json`](@ref).
"""
function open_json(
    path::AbstractString;
    dict_type::Type{<:AbstractDict} = Dict{String,Any},
    null::NullType = nothing,
    kw...
)
    doc_ptr = open_json_doc(path; kw...)
    try
        return parse_value(
            yyjson_doc_get_root(doc_ptr),
            dict_type,
            null,
        )
    finally
        yyjson_doc_free(doc_ptr)
    end
end

"""
    open_json(io::IO; kw...)

Reads a JSON file from a given `io` and parse it into dictionary.

## Keyword arguments
Similar to [`parse_json`](@ref).
"""
function open_json(io::IO; kw...)
    return parse_json(read(io))
end

end
