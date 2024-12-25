# YYJSON.jl

YYJSON is a convenient wrapper around [yyjson](https://github.com/ibireme/yyjson) library for reading and parsing JSON documents and provides its own parser implementation.

```@raw html
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
```

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

json = read("assets/binance_exchange_info.json", String)

function test_full_parse(json)
    parsed = parse_json(json)
    return parsed["symbols"][1]["filters"][1]["filterType"]
end

function test_lazy_parse(json)
    parse_lazy_json(json) do lazy_parsed
        return lazy_parsed["symbols"][1]["filters"][1]["filterType"]
    end
end

julia> @time test_full_parse(json)
  0.000245 seconds (2.89 k allocations: 203.727 KiB)
"PRICE_FILTER"

julia> @time test_lazy_parse(json)
  0.000041 seconds (10 allocations: 448 bytes)
"PRICE_FILTER"
```
