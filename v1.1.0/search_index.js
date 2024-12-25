var documenterSearchIndex = {"docs":
[{"location":"#YYJSON.jl","page":"Home","title":"YYJSON.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"YYJSON is a convenient wrapper around yyjson library for reading and parsing JSON documents and provides its own parser implementation.","category":"page"},{"location":"","page":"Home","title":"Home","text":"<html>\n  <body>\n    <table>\n      <tr><th>Feature&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</th><th><div>Description</div></th></tr>\n      <tr>\n        <td>Performance</td>\n        <td><div>Able to <code>read</code> gigabytes of JSON document per second.</div></td>\n      </tr>\n      <tr>\n        <td>Flexibility</td>\n        <td><div>The library wraps a lot of methods of the original library, which allows you to make your own implementation of JSON <code>reader</code>/<code>parser</code>/<code>(de)serializer</code>.</div></td>\n      </tr>\n      <tr>\n        <td>Parser</td>\n        <td><div>Provides its own <code>parser</code> implementation using <a href=\"https://github.com/ibireme/yyjson\">yyjson</a> tools.</div></td>\n      </tr>\n    </table>\n  </body>\n</html>","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To install YYJSON, simply use the Julia package manager:","category":"page"},{"location":"","page":"Home","title":"Home","text":"] add YYJSON","category":"page"},{"location":"#Usage","page":"Home","title":"Usage","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"A small example of parsing the returned result from a ticker request:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using YYJSON\n\njson = \"\"\"\n{\n  \"retCode\":0,\n  \"retMsg\":\"OK\",\n  \"result\":{\n    \"ap\":0.6636,\n    \"bp\":0.6634,\n    \"h\":0.6687,\n    \"l\":0.6315,\n    \"lp\":0.6633,\n    \"o\":0.6337,\n    \"qv\":1.1594252877069e7,\n    \"s\":\"ADAUSDT\",\n    \"t\":\"2024-03-25T19:05:35.491000064\",\n    \"v\":1.780835204e7\n  },\n  \"retExtInfo\":{},\n  \"time\":\"2024-03-25T19:05:38.912999936\"\n}\n\"\"\"\n\njulia> parse_json(json)\nDict{String, Any} with 5 entries:\n  \"retExtInfo\" => Dict{String, Any}()\n  \"time\"       => \"2024-03-25T19:05:38.912999936\"\n  \"retCode\"    => 0\n  \"retMsg\"     => \"OK\"\n  \"result\"     => Dict{String, Any}(\"v\"=>1.78084e7, \"ap\"=>0.6636, \"o\"=>0.6337, ...)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Lazy parsing enables more efficient value retrieval compared to regular parsing:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using YYJSON\n\njson_str = read(\"assets/binance_exchange_info.json\", String);\n\nfunction test_yyjson(json_str)\n    d = parse_json(json_str)\n    return d[\"symbols\"][1][\"filters\"][1][\"filterType\"]\nend\n\ntest_yyjson(json_str)\n\njulia> @time test_yyjson(json_str)\n  0.000245 seconds (2.89 k allocations: 203.727 KiB)\n\"PRICE_FILTER\"\n\nfunction test_lazy_yyjson(json_str)\n    parse_lazy_json(json_str) do ld\n      ld[\"symbols\"][1][\"filters\"][1][\"filterType\"]\n    end\nend\n\ntest_lazy_yyjson(json_str)\n\njulia> @time test_lazy_yyjson(json_str)\n  0.000054 seconds (10 allocations: 448 bytes)\n\"PRICE_FILTER\"","category":"page"},{"location":"pages/api_reference/#API-Reference","page":"API Reference","title":"API Reference","text":"","category":"section"},{"location":"pages/api_reference/#JSON-parser","page":"API Reference","title":"JSON parser","text":"","category":"section"},{"location":"pages/api_reference/","page":"API Reference","title":"API Reference","text":"parse_json\nopen_json","category":"page"},{"location":"pages/api_reference/#YYJSON.ParserJSON.parse_json","page":"API Reference","title":"YYJSON.ParserJSON.parse_json","text":"parse_json(x::String; kw...)\nparse_json(x::Vector{UInt8}; kw...)\n\nParse a JSON string x (or vector of UInt8) into a dictionary.\n\nKeyword arguments\n\ndict_type::Type{D} = Dict{String,Any}: Defines the type of dictionary into which objects will be parsed.\nnull::Union{Nothing,Missing} = nothing: Null value.\nin_situ::Bool: This option allows the reader to modify and use the input data to store string values, which can slightly improve reading speed.\nnumber_as_raw::Bool: Read all numbers as raw strings without parsing.\nbignum_as_raw::Bool: Read big numbers as raw strings.\nstop_when_done::Bool: Stop parsing when reaching the end of a JSON document instead of issues an error if there's additional content after it.\nallow_comments::Bool: Allow C-style single line and multiple line comments.\nallow_inf_and_nan::Bool: Allow nan/inf` number or case-insensitive literal.\nallow_invalid_unicode::Bool: Allow reading invalid unicode when parsing string values.\nallow_trailing_commas::Bool: Allow a single trailing comma at the end of an object or array.\n\nExamples\n\njulia> json = \"\"\"{\n           \"str\": \"John Doe\",\n           \"num\": \"30\",\n           \"array\": [1,2,{\"a\": 3, \"b\": null}],\n           \"bool\": false,\n           \"obj\" : {\"a\": 1, \"b\": null},\n           \"another\": \"key\"\n       }\n       \"\"\";\n\njulia> parse_json(json)\nDict{String, Any} with 6 entries:\n  \"another\" => \"key\"\n  \"str\"     => \"John Doe\"\n  \"obj\"     => Dict{String, Any}(\"b\"=>nothing, \"a\"=>1)\n  \"array\"   => Any[1, 2, Dict{String, Any}(\"b\"=>nothing, \"a\"=>3)]\n  \"num\"     => \"30\"\n  \"bool\"    => false\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#YYJSON.ParserJSON.open_json","page":"API Reference","title":"YYJSON.ParserJSON.open_json","text":"open_json(path::String; kw...)\n\nReads a JSON file from a given path and parse it into dictionary.\n\nKeyword arguments\n\nSimilar to parse_json.\n\n\n\n\n\nopen_json(io::IO; kw...)\n\nReads a JSON file from a given io and parse it into dictionary.\n\nKeyword arguments\n\nSimilar to parse_json.\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#JSON-lazy-parser","page":"API Reference","title":"JSON lazy parser","text":"","category":"section"},{"location":"pages/api_reference/","page":"API Reference","title":"API Reference","text":"LazyJSONDict\nLazyJSONVector\nparse_lazy_json\nopen_lazy_json","category":"page"},{"location":"pages/api_reference/#YYJSON.LazyJSON.LazyJSONDict","page":"API Reference","title":"YYJSON.LazyJSON.LazyJSONDict","text":"LazyJSONDict <: AbstractDict{AbstractString,Any}\n\nRepresents a dictionary for a JSON object.\n\nFields\n\nptr::Ptr{YYJSONVal}: The object value pointer.\niter::YYJSONObjIter: The object iterator structure.\ndoc_ptr::Ptr{YYJSONDoc}: The JSON document pointer (non-null only for the root).\nalc_ptr::Ptr{YYJSONAlc}: The dynamic allocator pointer (non-null only for the root).\nfreed::Bool: Flag indicating whether the document is freed.\n\n\n\n\n\n","category":"type"},{"location":"pages/api_reference/#YYJSON.LazyJSON.LazyJSONVector","page":"API Reference","title":"YYJSON.LazyJSON.LazyJSONVector","text":"LazyJSONVector <: AbstractVector{Any}\n\nRepresents a vector for a JSON array.\n\nFields\n\nptr::Ptr{YYJSONVal}: The array value pointer.\ndoc_ptr::Ptr{YYJSONDoc}: The JSON document pointer (non-null only for the root).\nalc_ptr::Ptr{YYJSONAlc}: The dynamic allocator pointer (non-null only for the root).\nfreed::Bool: Flag indicating whether the document is freed.\n\n\n\n\n\n","category":"type"},{"location":"pages/api_reference/#YYJSON.LazyJSON.parse_lazy_json","page":"API Reference","title":"YYJSON.LazyJSON.parse_lazy_json","text":"parse_lazy_json([f::Function], json::String; kw...)\nparse_lazy_json([f::Function], json::Vector{UInt8}; kw...)\n\nParse a JSON string json (or vector of UInt8) into a LazyJSONDict or LazyJSONVector.\n\nnote: Note\nWhen it's no longer needed, it should be closed with close or use do block syntax.\n\nKeyword arguments\n\nSimilar to parse_json.\n\nExamples\n\njulia> json = \"\"\"{\n           \"str\": \"John Doe\",\n           \"num\": \"30\",\n           \"array\": [1,2,{\"a\": 3, \"b\": null}],\n           \"bool\": false,\n           \"obj\" : {\"a\": 1, \"b\": null},\n           \"another\": \"key\"\n       }\n       \"\"\";\n\njulia> parse_lazy_json(json)\nLazyJSONDict with 6 entries:\n  \"str\"     => \"John Doe\"\n  \"num\"     => \"30\"\n  \"array\"   => Any[1, 2, LazyJSONDict(\"a\"=>3, \"b\"=>nothing)]\n  \"bool\"    => false\n  \"obj\"     => LazyJSONDict(\"a\"=>1, \"b\"=>nothing)\n  \"another\" => \"key\"\n\njulia> json = \"\"\"{\n           \"array\": [1,2,3]\n       }\n       \"\"\";\n\narray = []\nparse_lazy_json(json) do data\n    for value in data[\"array\"]\n        push!(array, value)\n    end\nend\n\njulia> array\n3-element Vector{Any}:\n 1\n 2\n 3\n\n\n\n\n\n","category":"function"},{"location":"pages/api_reference/#YYJSON.LazyJSON.open_lazy_json","page":"API Reference","title":"YYJSON.LazyJSON.open_lazy_json","text":"open_lazy_json([f::Function], path::String; kw...)\nopen_lazy_json([f::Function], io::IO; kw...)\n\nReads a JSON file from a given path or io and parse it into a LazyJSONDict or LazyJSONVector.\n\nnote: Note\nWhen it's no longer needed, it should be closed with close or use do block syntax.\n\nKeyword arguments\n\nSimilar to parse_json.\n\n\n\n\n\n","category":"function"}]
}
