module YYJSON

export YYJSON_TAG_BIT,
    YYJSON_TYPE_BIT,
    YYJSON_SUBTYPE_BIT,
    YYJSON_RESERVED_BIT

export YYJSON_TAG_MASK,
    YYJSON_TYPE_MASK,
    YYJSON_SUBTYPE_MASK,
    YYJSON_RESERVED_MASK

export YYJSONType,
    YYJSON_TYPE_NONE,
    YYJSON_TYPE_RAW,
    YYJSON_TYPE_NULL,
    YYJSON_TYPE_BOOL,
    YYJSON_TYPE_NUM,
    YYJSON_TYPE_STR,
    YYJSON_TYPE_ARR,
    YYJSON_TYPE_OBJ

export YYJSONSubtype,
    YYJSON_SUBTYPE_NONE,
    YYJSON_SUBTYPE_NOESC,
    YYJSON_SUBTYPE_UINT,
    YYJSON_SUBTYPE_SINT,
    YYJSON_SUBTYPE_REAL,
    YYJSON_SUBTYPE_TRUE,
    YYJSON_SUBTYPE_FALSE

export YYJSONPtrCode,
    YYJSON_PTR_ERR_NONE,
    YYJSON_PTR_ERR_PARAMETER,
    YYJSON_PTR_ERR_SYNTAX,
    YYJSON_PTR_ERR_RESOLVE,
    YYJSON_PTR_ERR_NULL_ROOT,
    YYJSON_PTR_ERR_SET_ROOT,
    YYJSON_PTR_ERR_MEMORY_ALLOCATION

export YYJSONReadFlag,
    YYJSON_READ_NOFLAG,
    YYJSON_READ_INSITU,
    YYJSON_READ_STOP_WHEN_DONE,
    YYJSON_READ_ALLOW_TRAILING_COMMAS,
    YYJSON_READ_ALLOW_COMMENTS,
    YYJSON_READ_ALLOW_INF_AND_NAN,
    YYJSON_READ_NUMBER_AS_RAW,
    YYJSON_READ_ALLOW_INVALID_UNICODE,
    YYJSON_READ_BIGNUM_AS_RAW

export YYJSONReadCode,
    YYJSON_READ_SUCCESS,
    YYJSON_READ_ERROR_INVALID_PARAMETER,
    YYJSON_READ_ERROR_MEMORY_ALLOCATION,
    YYJSON_READ_ERROR_EMPTY_CONTENT,
    YYJSON_READ_ERROR_UNEXPECTED_CONTENT,
    YYJSON_READ_ERROR_UNEXPECTED_END,
    YYJSON_READ_ERROR_UNEXPECTED_CHARACTER,
    YYJSON_READ_ERROR_JSON_STRUCTURE,
    YYJSON_READ_ERROR_INVALID_COMMENT,
    YYJSON_READ_ERROR_INVALID_NUMBER,
    YYJSON_READ_ERROR_INVALID_STRING,
    YYJSON_READ_ERROR_LITERAL,
    YYJSON_READ_ERROR_FILE_OPEN,
    YYJSON_READ_ERROR_FILE_READ

export YYJSONDoc,
    YYJSONVal,
    YYJSONAlc,
    YYJSONReadErr,
    YYJSONPtrErr,
    YYJSONArrIter,
    YYJSONObjIter

export YYJSONDoc_NULL,
    YYJSONVal_NULL,
    YYJSONAlc_NULL,
    YYJSONUInt8_NULL

export yyjson_read,
    yyjson_read_file,
    yyjson_read_opts,
    yyjson_read_max_memory_usage

export yyjson_doc_free,
    yyjson_doc_get_root,
    yyjson_doc_get_read_size,
    yyjson_doc_get_val_count,
    yyjson_doc_ptr_get,
    yyjson_doc_ptr_getn,
    yyjson_doc_ptr_getx

export yyjson_get_tag,
    yyjson_get_len,
    yyjson_locate_pos,
    yyjson_equals,
    yyjson_equals_str,
    yyjson_equals_strn

export yyjson_ptr_get,
    yyjson_ptr_getn,
    yyjson_ptr_getx

export yyjson_get_type,
    yyjson_get_subtype,
    yyjson_get_type_desc

export yyjson_is_raw,
    yyjson_get_raw

export yyjson_is_null

export yyjson_is_bool,
    yyjson_is_false,
    yyjson_is_true,
    yyjson_get_bool,
    yyjson_ptr_get_bool

export yyjson_is_num,
    yyjson_get_num,
    yyjson_ptr_get_num

export yyjson_is_int,
    yyjson_get_int

export yyjson_is_uint,
    yyjson_get_uint,
    yyjson_ptr_get_uint

export yyjson_is_sint,
    yyjson_get_sint,
    yyjson_ptr_get_sint

export yyjson_is_real,
    yyjson_get_real,
    yyjson_ptr_get_real

export yyjson_is_str,
    yyjson_get_str,
    yyjson_ptr_get_str

export yyjson_is_ctn

export yyjson_is_arr,
    yyjson_arr_size,
    yyjson_arr_get,
    yyjson_arr_get_first,
    yyjson_arr_get_last,
    yyjson_arr_iter_with,
    yyjson_arr_iter_init,
    yyjson_arr_iter_has_next,
    yyjson_arr_iter_next

export yyjson_is_obj,
    yyjson_obj_size,
    yyjson_obj_get,
    yyjson_obj_getn,
    yyjson_obj_iter_with,
    yyjson_obj_iter_init,
    yyjson_obj_iter_has_next,
    yyjson_obj_iter_next,
    yyjson_obj_iter_get,
    yyjson_obj_iter_getn,
    yyjson_obj_iter_get_val

export yyjson_alc_dyn_new,
    yyjson_alc_dyn_free,
    yyjson_alc_pool_init

export parse_json,
    open_json,
    YYJSONError

export LazyJSONDict,
    LazyJSONVector,
    LazyJSONError,
    parse_lazy_json,
    open_lazy_json

using yyjson_jll

const YYJSON_TAG_BIT = 0x08
const YYJSON_TYPE_BIT = 0x03
const YYJSON_SUBTYPE_BIT = 0x02
const YYJSON_RESERVED_BIT = 0x03

const YYJSON_TAG_MASK = 0xFF # 11111111
const YYJSON_TYPE_MASK = 0x07 # 00000111
const YYJSON_SUBTYPE_MASK = 0x18 # 00011000
const YYJSON_RESERVED_MASK = 0xE0 # 11100000

const YYJSONType = UInt8
const YYJSON_TYPE_NONE = 0
const YYJSON_TYPE_RAW = 1
const YYJSON_TYPE_NULL = 2
const YYJSON_TYPE_BOOL = 3
const YYJSON_TYPE_NUM = 4
const YYJSON_TYPE_STR = 5
const YYJSON_TYPE_ARR = 6
const YYJSON_TYPE_OBJ = 7

const YYJSONSubtype = UInt8
const YYJSON_SUBTYPE_NONE = 0 << 3
const YYJSON_SUBTYPE_NOESC = 1 << 3
const YYJSON_SUBTYPE_UINT = 0 << 3
const YYJSON_SUBTYPE_SINT = 1 << 3
const YYJSON_SUBTYPE_REAL = 2 << 3
const YYJSON_SUBTYPE_TRUE = 1 << 3
const YYJSON_SUBTYPE_FALSE = 0 << 3

const YYJSONPtrCode = UInt32
const YYJSON_PTR_ERR_NONE = 0
const YYJSON_PTR_ERR_PARAMETER = 1
const YYJSON_PTR_ERR_SYNTAX = 2
const YYJSON_PTR_ERR_RESOLVE = 3
const YYJSON_PTR_ERR_NULL_ROOT = 4
const YYJSON_PTR_ERR_SET_ROOT = 5
const YYJSON_PTR_ERR_MEMORY_ALLOCATION = 6

const YYJSONReadFlag = UInt32
const YYJSON_READ_NOFLAG = 0
const YYJSON_READ_INSITU = 1 << 0
const YYJSON_READ_STOP_WHEN_DONE = 1 << 1
const YYJSON_READ_ALLOW_TRAILING_COMMAS = 1 << 2
const YYJSON_READ_ALLOW_COMMENTS = 1 << 3
const YYJSON_READ_ALLOW_INF_AND_NAN = 1 << 4
const YYJSON_READ_NUMBER_AS_RAW = 1 << 5
const YYJSON_READ_ALLOW_INVALID_UNICODE = 1 << 6
const YYJSON_READ_BIGNUM_AS_RAW = 1 << 7

const YYJSONReadCode = UInt32
const YYJSON_READ_SUCCESS = 0
const YYJSON_READ_ERROR_INVALID_PARAMETER = 1
const YYJSON_READ_ERROR_MEMORY_ALLOCATION = 2
const YYJSON_READ_ERROR_EMPTY_CONTENT = 3
const YYJSON_READ_ERROR_UNEXPECTED_CONTENT = 4
const YYJSON_READ_ERROR_UNEXPECTED_END = 5
const YYJSON_READ_ERROR_UNEXPECTED_CHARACTER = 6
const YYJSON_READ_ERROR_JSON_STRUCTURE = 7
const YYJSON_READ_ERROR_INVALID_COMMENT = 8
const YYJSON_READ_ERROR_INVALID_NUMBER = 9
const YYJSON_READ_ERROR_INVALID_STRING = 10
const YYJSON_READ_ERROR_LITERAL = 11
const YYJSON_READ_ERROR_FILE_OPEN = 12
const YYJSON_READ_ERROR_FILE_READ = 13

struct YYJSONDoc end
struct YYJSONVal end
struct YYJSONAlc end

const YYJSONDoc_NULL   = Ptr{YYJSONDoc}(C_NULL)
const YYJSONVal_NULL   = Ptr{YYJSONVal}(C_NULL)
const YYJSONAlc_NULL   = Ptr{YYJSONAlc}(C_NULL)
const YYJSONUInt8_NULL = Ptr{UInt8}(C_NULL)

mutable struct YYJSONReadErr <: Exception
    code::YYJSONReadCode
    msg::Ptr{UInt8}
    pos::Csize_t

    function YYJSONReadErr()
        return new(0, C_NULL, 0)
    end
end

function Base.showerror(io::IO, e::YYJSONReadErr)
    return print(io, "YYJSONReadErr: $(unsafe_string(e.msg)), code: $(e.code) at byte position: $(e.pos).")
end

mutable struct YYJSONPtrErr <: Exception
    code::YYJSONPtrCode
    msg::Ptr{UInt8}
    pos::Csize_t

    function YYJSONPtrErr()
        return new(0, C_NULL, 0)
    end
end

function Base.showerror(io::IO, e::YYJSONPtrErr)
    return print(io, "YYJSONPtrErr: $(unsafe_string(e.msg)), code: $(e.code) at byte position: $(e.pos).")
end

mutable struct YYJSONArrIter
    idx::Csize_t
    max::Csize_t
    cur::Ptr{YYJSONVal}

    function YYJSONArrIter()
        return new(0, 0, C_NULL)
    end
end

mutable struct YYJSONObjIter
    idx::Csize_t
    max::Csize_t
    cur::Ptr{YYJSONVal}
    obj::Ptr{YYJSONVal}

    function YYJSONObjIter()
        return new(0, 0, C_NULL, C_NULL)
    end
end

#__ Read

function yyjson_read(dat, len, flg)
    return ccall((:yyjson_read, libyyjson), Ptr{YYJSONDoc}, (Ptr{UInt8}, Csize_t, YYJSONReadFlag), dat, len, flg)
end

function yyjson_read_file(path, flg, alc, err)
    return ccall((:yyjson_read_file, libyyjson), Ptr{YYJSONDoc}, (Ptr{UInt8}, YYJSONReadFlag, Ptr{YYJSONAlc}, Ptr{YYJSONReadErr}), path, flg, alc, err)
end

function yyjson_read_opts(dat, len, flg, alc, err)
    return ccall((:yyjson_read_opts, libyyjson), Ptr{YYJSONDoc}, (Ptr{UInt8}, Csize_t, YYJSONReadFlag, Ptr{YYJSONAlc}, Ptr{YYJSONReadErr}), dat, len, flg, alc, err)
end

function yyjson_read_max_memory_usage(len, flg)
    return ccall((:yyjson_read_max_memory_usage, libyyjson), Csize_t, (Csize_t, YYJSONReadFlag), len, flg)
end

#__ Document

function yyjson_doc_free(yyjson_doc)
    return ccall((:yyjson_doc_free, libyyjson), Cvoid, (Ptr{YYJSONDoc},), yyjson_doc)
end

function yyjson_doc_get_root(yyjson_doc)
    return ccall((:yyjson_doc_get_root, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONDoc},), yyjson_doc)
end

function yyjson_doc_get_read_size(doc)
    return ccall((:yyjson_doc_get_read_size, libyyjson), Csize_t, (Ptr{YYJSONDoc},), doc)
end

function yyjson_doc_get_val_count(doc)
    return ccall((:yyjson_doc_get_val_count, libyyjson), Csize_t, (Ptr{YYJSONDoc},), doc)
end

function yyjson_doc_ptr_get(doc, ptr)
    return ccall((:yyjson_doc_ptr_get, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONDoc}, Ptr{UInt8}), doc, ptr)
end

function yyjson_doc_ptr_getn(doc, ptr, len)
    return ccall((:yyjson_doc_ptr_getn, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONDoc}, Ptr{UInt8}, Csize_t), doc, ptr, len)
end

function yyjson_doc_ptr_getx(doc, ptr, len, err)
    return ccall((:yyjson_doc_ptr_getx, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONDoc}, Ptr{UInt8}, Csize_t, Ptr{YYJSONPtrErr}), doc, ptr, len, err)
end

#__ Utilities

function yyjson_get_tag(val)
    return ccall((:yyjson_get_tag, libyyjson), UInt8, (Ptr{YYJSONVal},), val)
end

function yyjson_get_len(val)
    return ccall((:yyjson_get_len, libyyjson), Csize_t, (Ptr{YYJSONVal},), val)
end

function yyjson_locate_pos(str, len, pos, line, col, chr)
    return ccall((:yyjson_locate_pos, libyyjson), YYJSONType, (Ptr{UInt8}, Csize_t, Csize_t, Ptr{Csize_t}, Ptr{Csize_t}, Ptr{Csize_t}), str, len, pos, line, col, chr)
end

function yyjson_equals(lhs, rhs)
    return ccall((:yyjson_equals, libyyjson), YYJSONType, (Ptr{YYJSONVal}, Ptr{YYJSONVal}), lhs, rhs)
end

function yyjson_equals_str(val, str)
    return ccall((:yyjson_equals_str, libyyjson), YYJSONType, (Ptr{YYJSONVal}, Ptr{UInt8}), val, str)
end

function yyjson_equals_strn(val, str, len)
    return ccall((:yyjson_equals_strn, libyyjson), YYJSONType, (Ptr{YYJSONVal}, Ptr{UInt8}, Csize_t), val, str, len)
end

#__ Pointer

function yyjson_ptr_get(val, ptr)
    return ccall((:yyjson_ptr_get, libyyjson), YYJSONType, (Ptr{YYJSONVal}, Ptr{UInt8}), val, ptr)
end

function yyjson_ptr_getn(val, ptr, len)
    return ccall((:yyjson_ptr_getn, libyyjson), YYJSONType, (Ptr{YYJSONVal}, Ptr{UInt8}, Csize_t), val, ptr, len)
end

function yyjson_ptr_getx(val, ptr, len, err)
    return ccall((:yyjson_ptr_getx, libyyjson), YYJSONType, (Ptr{YYJSONVal}, Ptr{UInt8}, Csize_t, Ptr{YYJSONPtrErr}), val, ptr, len, err)
end

#__ Type

function yyjson_get_type(val)
    return ccall((:yyjson_get_type, libyyjson), YYJSONType, (Ptr{YYJSONVal},), val)
end

function yyjson_get_subtype(val)
    return ccall((:yyjson_get_subtype, libyyjson), YYJSONSubtype, (Ptr{YYJSONVal},), val)
end

function yyjson_get_type_desc(val)
    return ccall((:yyjson_get_type_desc, libyyjson), Ptr{UInt8}, (Ptr{YYJSONVal},), val)
end

#__ Raw

function yyjson_is_raw(val)
    return ccall((:yyjson_is_raw, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_raw(val)
    return ccall((:yyjson_get_raw, libyyjson), Ptr{UInt8}, (Ptr{YYJSONVal},), val)
end

#__ Null

function yyjson_is_null(val)
    return ccall((:yyjson_is_null, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

#__ Bool

function yyjson_is_bool(val)
    return ccall((:yyjson_is_bool, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_is_false(val)
    return ccall((:yyjson_is_false, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_is_true(val)
    return ccall((:yyjson_is_true, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_bool(val)
    return ccall((:yyjson_get_bool, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_ptr_get_bool(root, ptr, value)
    return ccall((:yyjson_ptr_get_bool, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{UInt8}, Ptr{Bool}), root, ptr, value)
end

#__ Number

function yyjson_is_num(val)
    return ccall((:yyjson_is_num, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_num(val)
    return ccall((:yyjson_get_num, libyyjson), Float64, (Ptr{YYJSONVal},), val)
end

function yyjson_ptr_get_num(root, ptr, value)
    return ccall((:yyjson_ptr_get_num, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{UInt8}, Ptr{Float64}), root, ptr, value)
end

#__ Int

function yyjson_is_int(val)
    return ccall((:yyjson_is_int, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_int(val)
    return ccall((:yyjson_get_int, libyyjson), Int64, (Ptr{YYJSONVal},), val)
end

#__ UInt

function yyjson_is_uint(val)
    return ccall((:yyjson_is_uint, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_uint(val)
    return ccall((:yyjson_get_uint, libyyjson), UInt64, (Ptr{YYJSONVal},), val)
end

function yyjson_ptr_get_uint(root, ptr, value)
    return ccall((:yyjson_ptr_get_uint, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{UInt8}, Ptr{UInt64}), root, ptr, value)
end

#__ SInt

function yyjson_is_sint(val)
    return ccall((:yyjson_is_sint, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_sint(val)
    return ccall((:yyjson_get_sint, libyyjson), Int64, (Ptr{YYJSONVal},), val)
end

function yyjson_ptr_get_sint(root, ptr, value)
    return ccall((:yyjson_ptr_get_sint, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{UInt8}, Ptr{Int64}), root, ptr, value)
end

#__ Real

function yyjson_is_real(val)
    return ccall((:yyjson_is_real, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_real(val)
    return ccall((:yyjson_get_real, libyyjson), Float64, (Ptr{YYJSONVal},), val)
end

function yyjson_ptr_get_real(root, ptr, value)
    return ccall((:yyjson_ptr_get_real, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{UInt8}, Ptr{Float64}), root, ptr, value)
end

#__ String

function yyjson_is_str(val)
    return ccall((:yyjson_is_str, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_get_str(val)
    return ccall((:yyjson_get_str, libyyjson), Ptr{UInt8}, (Ptr{YYJSONVal},), val)
end

function yyjson_ptr_get_str(root, ptr, value)
    return ccall((:yyjson_ptr_get_str, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{UInt8}, Ptr{UInt8}), root, ptr, value)
end

#__ Container

function yyjson_is_ctn(val)
    return ccall((:yyjson_is_ctn, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

#__ Array

function yyjson_is_arr(val)
    return ccall((:yyjson_is_arr, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_arr_size(arr)
    return ccall((:yyjson_arr_size, libyyjson), Int, (Ptr{YYJSONVal},), arr)
end

function yyjson_arr_get(arr, idx)
    return ccall((:yyjson_arr_get, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONVal}, Csize_t), arr, idx)
end

function yyjson_arr_get_first(arr)
    return ccall((:yyjson_arr_get_first, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONVal},), arr)
end

function yyjson_arr_get_last(arr)
    return ccall((:yyjson_arr_get_last, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONVal},), arr)
end

function yyjson_arr_iter_with(arr)
    return ccall((:yyjson_arr_iter_with, libyyjson), Bool, (Ptr{YYJSONVal},), arr)
end

function yyjson_arr_iter_init(arr, iter)
    return ccall((:yyjson_arr_iter_init, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{YYJSONArrIter}), arr, iter)
end

function yyjson_arr_iter_has_next(iter)
    return ccall((:yyjson_arr_iter_has_next, libyyjson), Bool, (Ptr{YYJSONArrIter},), iter)
end

function yyjson_arr_iter_next(iter)
    return ccall((:yyjson_arr_iter_next, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONArrIter},), iter)
end

#__ Object

function yyjson_is_obj(val)
    return ccall((:yyjson_is_obj, libyyjson), Bool, (Ptr{YYJSONVal},), val)
end

function yyjson_obj_size(obj)
    return ccall((:yyjson_obj_size, libyyjson), Int, (Ptr{YYJSONVal},), obj)
end

function yyjson_obj_get(obj, key)
    return ccall((:yyjson_obj_get, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONVal}, Ptr{UInt8}), obj, key)
end

function yyjson_obj_getn(obj, key, key_len)
    return ccall((:yyjson_obj_getn, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONVal}, Ptr{UInt8}, Csize_t), obj, key, key_len)
end

function yyjson_obj_iter_with(arr)
    return ccall((:yyjson_obj_iter_with, libyyjson), Bool, (Ptr{YYJSONVal},), arr)
end

function yyjson_obj_iter_init(obj, iter)
    return ccall((:yyjson_obj_iter_init, libyyjson), Bool, (Ptr{YYJSONVal}, Ptr{YYJSONObjIter}), obj, iter)
end

function yyjson_obj_iter_has_next(iter)
    return ccall((:yyjson_obj_iter_has_next, libyyjson), Bool, (Ptr{YYJSONArrIter},), iter)
end

function yyjson_obj_iter_next(iter)
    return ccall((:yyjson_obj_iter_next, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONObjIter},), iter)
end

function yyjson_obj_iter_get(iter, key)
    return ccall((:yyjson_obj_iter_get, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONObjIter}, Ptr{UInt8}), iter, key)
end

function yyjson_obj_iter_getn(iter, key, key_len)
    return ccall((:yyjson_obj_iter_getn, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONObjIter}, Ptr{UInt8}, Csize_t), iter, key, key_len)
end

function yyjson_obj_iter_get_val(key)
    return ccall((:yyjson_obj_iter_get_val, libyyjson), Ptr{YYJSONVal}, (Ptr{YYJSONVal},), key)
end

#__Allocator

function yyjson_alc_dyn_new()
    return ccall((:yyjson_alc_dyn_new, libyyjson), Ptr{YYJSONAlc}, ())
end

function yyjson_alc_dyn_free(alc)
    return ccall((:yyjson_alc_dyn_free, libyyjson), Cvoid, (Ptr{YYJSONAlc},), alc)
end

function yyjson_alc_pool_init(alc, buff, size)
    return ccall((:yyjson_alc_pool_init, libyyjson), Bool, (Ptr{YYJSONAlc}, Ptr{Cvoid}, Csize_t), alc, buff, size)
end

include("Reader.jl")
using .Reader

include("ParserJSON.jl")
using .ParserJSON

include("LazyJSON.jl")
using .LazyJSON

end
