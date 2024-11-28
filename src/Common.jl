function bitwise_read_flag(;
    in_situ::Bool = false,
    number_as_raw::Bool = false,
    bignum_as_raw::Bool = false,
    stop_when_done::Bool = false,
    allow_comments::Bool = false,
    allow_inf_and_nan::Bool = false,
    allow_invalid_unicode::Bool = false,
    allow_trailing_commas::Bool = false,
)
    flag = YYJSON_READ_NOFLAG
    flag |= in_situ               ? YYJSON_READ_INSITU                : flag
    flag |= number_as_raw         ? YYJSON_READ_NUMBER_AS_RAW         : flag
    flag |= bignum_as_raw         ? YYJSON_READ_BIGNUM_AS_RAW         : flag
    flag |= stop_when_done        ? YYJSON_READ_STOP_WHEN_DONE        : flag
    flag |= allow_comments        ? YYJSON_READ_ALLOW_COMMENTS        : flag
    flag |= allow_inf_and_nan     ? YYJSON_READ_ALLOW_INF_AND_NAN     : flag
    flag |= allow_invalid_unicode ? YYJSON_READ_ALLOW_INVALID_UNICODE : flag
    flag |= allow_trailing_commas ? YYJSON_READ_ALLOW_TRAILING_COMMAS : flag
    return flag
end

function read_json_doc(json; alc = C_NULL, kw...)#::AbstractString
    err = YYJSONReadErr() #Выделение памяти при создании
    doc_ptr = yyjson_read_opts(
        json,
        length(json),
        bitwise_read_flag(; kw...),
        alc,
        pointer_from_objref(err),
    )
    if doc_ptr == C_NULL
        yyjson_doc_free(doc_ptr)
        throw(err)
    end
    return doc_ptr
end