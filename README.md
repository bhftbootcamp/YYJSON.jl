# YYJSON.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://bhftbootcamp.github.io/YYJSON.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://bhftbootcamp.github.io/YYJSON.jl/dev/)
[![Build Status](https://github.com/bhftbootcamp/YYJSON.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/bhftbootcamp/YYJSON.jl/actions/workflows/CI.yml?query=branch%3Amaster)
[![Coverage](https://codecov.io/gh/bhftbootcamp/YYJSON.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/bhftbootcamp/YYJSON.jl)
[![Registry](https://img.shields.io/badge/registry-General-4063d8)](https://github.com/JuliaRegistries/General)

YYJSON is a convenient wrapper around [yyjson](https://github.com/ibireme/yyjson) library for reading and parsing JSON documents and provides its own parser implementation.

<html>
  <body>
    <table>
      <tr><th>Feature&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp&nbsp</th><th><div>Description</div></th></tr>
      <tr>
        <td>Performance</td>
        <td><div>Able to <code>read</code> gigabytes of JSON document per second.</div></td>
      </tr>
      <tr>
        <td>Flexibility</td>
        <td><div>The library wraps a lot of methods of the original library, which allows you to make your own implementation of JSON <code>reader</code>/<code>parser</code>/<code>(de)serializer</code>.</div></td>
      </tr>
      <tr>
        <td>Parser</td>
        <td><div>Provides its own <code>parser</code> implementation using <a href="https://github.com/ibireme/yyjson">yyjson</a> tools.</div></td>
      </tr>
    </table>
  </body>
</html>

## Installation

To install YYJSON, simply use the Julia package manager:

```julia
] add YYJSON
```

## Usage

A small example of parsing the returned result from a ticker request:

```julia
using YYJSON

json = """
{
  "retCode":0,
  "retMsg":"OK",
  "result":{
    "ap":0.6636,
    "bp":0.6634,
    "h":0.6687,
    "l":0.6315,
    "lp":0.6633,
    "o":0.6337,
    "qv":1.1594252877069e7,
    "s":"ADAUSDT",
    "t":"2024-03-25T19:05:35.491000064",
    "v":1.780835204e7
  },
  "retExtInfo":{},
  "time":"2024-03-25T19:05:38.912999936"
}
"""

julia> parse_json(json)
Dict{String, Any} with 5 entries:
  "retExtInfo" => Dict{String, Any}()
  "time"       => "2024-03-25T19:05:38.912999936"
  "retCode"    => 0
  "retMsg"     => "OK"
  "result"     => Dict{String, Any}("v"=>1.78084e7, "ap"=>0.6636, "o"=>0.6337, ...)
```

Lazy parsing enables more efficient value retrieval compared to regular parsing:

```julia
using YYJSON

json = read("assets/binance_exchange_info.json", String);

function test_yyjson(json)
    d = parse_json(json)
    return d["symbols"][1]["filters"][1]["filterType"]
end

function test_lazy_yyjson(json)
    parse_lazy_json(json) do ld
        ld["symbols"][1]["filters"][1]["filterType"]
    end
end

julia> @time test_yyjson(json)
  0.000245 seconds (2.89 k allocations: 203.727 KiB)
"PRICE_FILTER"

julia> @time test_lazy_yyjson(json)
  0.000054 seconds (10 allocations: 448 bytes)
"PRICE_FILTER"
```

## Contributing

Contributions to YYJSON are welcome! If you encounter a bug, have a feature request, or would like to contribute code, please open an issue or a pull request on GitHub.
