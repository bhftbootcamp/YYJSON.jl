using Test
using YYJSON

@testset "Parsing from string" begin
    @testset "Case №1: Strings" begin
        str_json = """
            {
                "a": "1",
                "b": "2",
                "c": "3"
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => "2", "a" => "1", "c" => "3")

        str_json = """
            {
                "b": "2",
                "c": "3",
                "a": "1"
            }
        """
        @test parse_json(str_json, dict_type = IdDict) == IdDict{String,Any}("b" => "2", "a" => "1", "c" => "3")

        str_json = """
            {"你好": "世界！"}
        """
        @test parse_json(str_json) == Dict{String,Any}("你好" => "世界！")

        str_json = """
            {
                "a": "1",
                "b": "2",
                "c": "3",
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
            {
                "a": "1",
                "b":    ,
                "c": "3"
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №2: Integers" begin
        str_json = """
            {
                "a": 1,
                "b": 2,
                "c": 3
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => 2, "a" => 1, "c" => 3)

        str_json = """
            {
                "b": 2,
                "c": 3,
                "a": 1
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => 2, "a" => 1, "c" => 3)

        str_json = """
            {
                "b": 2,
                "c": 3,
                "a": 1,
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
            {
                "b": 2,
                "c":  ,
                "a": 1,
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №3: Floats" begin
        str_json = """
            {
                "a": 1.0,
                "b": 2.0,
                "c": 3.0
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => 2.0, "a" => 1.0, "c" => 3.0)

        str_json = """
            {
                "b": 2.0,
                "c": 3.0,
                "a": 1.0
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => 2.0, "a" => 1.0, "c" => 3.0)

        str_json = """
            {
                "b": 2.0,
                "c": 3.0,
                "a": 1.0,
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
            {
                "b": 2.0,
                "c":    ,
                "a": 1.0,
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №4: Null" begin
        str_json = """
            {
                "a": 1,
                "b": null,
                "c": 3
            }
        """
        @test isequal(parse_json(str_json), Dict{String,Any}("b" => nothing, "a" => 1, "c" => 3))

        str_json = """
            {
                "b": null,
                "c": 3,
                "a": 1
            }
        """
        @test isequal(parse_json(str_json, null = missing), Dict{String,Any}("b" => missing, "a" => 1, "c" => 3))

        str_json = """
            {
                "b": null,
                "c": 3,
                "a": 1,
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
            {
                "b": _null,
                "c": 3,
                "a": 1
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №5: Bool" begin
        str_json = """
            {
                "a": 1,
                "b": true,
                "c": false
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => true, "a" => 1, "c" => false)

        str_json = """
            {
                "b": true,
                "c": false,
                "a": 1
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("b" => true, "a" => 1, "c" => false)

        str_json = """
            {
                "b": true,
                "c": false,
                "a": 1,
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
            {
                "b": true,
                "c": _false,
                "a": 1
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №6: Arrays" begin
        str_json = """
            {
                "a": ["1", "2", "3"]
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("a" => Any["1", "2", "3"])

        str_json = """
            {
                "a": ["1", "2", "3"],
                "b": [1, 2, 3]
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("a" => Any["1", "2", "3"], "b" => Any[1, 2, 3])

        str_json = """
            {
                "a": ["1", "2", "3"],
                "b": [1, 2, 3],
                "c": [1.0, 2.0, 3.0]
            }
        """
        @test parse_json(str_json) ==
              Dict{String,Any}("a" => Any["1", "2", "3"], "b" => Any[1, 2, 3], "c" => Any[1.0, 2.0, 3.0])

        str_json = """
           {
                "a": ["1", "2", "3", ]
            }
       """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
           {
                "a": ["1", "2", "3"
            }
       """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №7: Objects" begin
        str_json = """
            {
                "a": {
                    "b": "1"
                }
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("a" => Dict{String,Any}("b" => "1"))

        str_json = """
            {
                "a": {
                    "b": {
                        "c": "1"
                    }
                }
            }
        """
        @test parse_json(str_json) == Dict{String,Any}("a" => Dict{String,Any}("b" => Dict{String,Any}("c" => "1")))

        str_json = """
            {
                "a": {
                    "b": "1"
                },
                "c": {
                    "d": "2"
                }
            }
        """
        @test parse_json(str_json) ==
              Dict{String,Any}("c" => Dict{String,Any}("d" => "2"), "a" => Dict{String,Any}("b" => "1"))

        str_json = """
            {
                "a": {
                    "b": "1"
                },
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)

        str_json = """
            {
                "a": {
                    "b": "1"
            }
        """
        @test_throws YYJSONReadErr parse_json(str_json)
    end

    @testset "Case №8: Different types" begin
        str_json = """
            {
                "str": "John Doe",
                "num": "30",
                "array": [1, 2, 3],
                "bool": false,
                "obj" : {"a": 1, "b": 2}
            }
        """
        @test parse_json(str_json) == Dict{String,Any}(
            "str" => "John Doe",
            "obj" => Dict{String,Any}("b" => 2, "a" => 1),
            "array" => Any[1, 2, 3],
            "num" => "30",
            "bool" => false,
        )

        str_json = """
            {
                "str": "John Doe",
                "num": "30",
                "array": [1, 2, {"a": 3, "b": 4}],
                "bool": false,
                "obj" : {"a": 1, "b": 2},
                "another": "key"
            }
        """
        @test parse_json(str_json) == Dict{String,Any}(
            "another" => "key",
            "str" => "John Doe",
            "obj" => Dict{String,Any}("b" => 2, "a" => 1),
            "array" => Any[1, 2, Dict{String,Any}("b" => 4, "a" => 3)],
            "num" => "30",
            "bool" => false,
        )

        str_json = """
            {
                "str": "John Doe",
                "num": "30",
                "array": [1, 2, {"a": 3, "b": null}],
                "bool": false,
                "obj" : {"a": 1, "b": null},
                "another": "key"
            }
        """
        @test parse_json(str_json) == Dict{String,Any}(
            "another" => "key",
            "str" => "John Doe",
            "obj" => Dict{String,Any}("b" => nothing, "a" => 1),
            "array" => Any[1, 2, Dict{String,Any}("b" => nothing, "a" => 3)],
            "num" => "30",
            "bool" => false,
        )
    end

    @testset "Case №9: Custom parser types" begin
        str_json = """
            {
                "a": 1,
                "b": 2,
                "c": 3
            }
        """
        @test parse_json(str_json; dict_type = Dict{String,Int}) == Dict("c" => 3, "b" => 2, "a" => 1)

        str_json = """
            {
                "a": null,
                "b": null,
                "c": null
            }
        """
        @test parse_json(str_json; dict_type = Dict{String,Nothing}) ==
              Dict("c" => nothing, "b" => nothing, "a" => nothing)

        str_json = """
            {
                "a": ["1", "2", "3"]
            }
        """
        @test parse_json(str_json; dict_type = Dict{String,Vector}) == Dict("a" => Any["1", "2", "3"])

        str_json = """
            {
                "a": [null, null, null]
            }
        """
        @test isequal(
            parse_json(str_json; dict_type = Dict{String,Vector{Missing}}, null = missing),
            Dict("a" => Any[missing, missing, missing]),
        )
    end

    @testset "Case №10: Options" begin
        str_json = """
            {
                "a": "1",
                "b": "2",
                "c": "3"
            }
        """
        @test parse_json(str_json, in_situ = true) == Dict{String,Any}("c" => "3", "b" => "2", "a" => "1")

        str_json = """
            {
                "a": "1",
                "b": "2",
                "c": "3"
            }
            {
                "something": "else"
            }
        """
        @test parse_json(str_json, stop_when_done = true) == Dict{String,Any}("c" => "3", "b" => "2", "a" => "1")

        str_json = """
            {
                "a": "1",
                "b": "2",
                "c": "3",
            }
        """
        @test parse_json(str_json, allow_trailing_commas = true) == Dict{String,Any}("c" => "3", "b" => "2", "a" => "1")

        str_json = """
            { // It's a single comment at the begin
                "a": "1",
                "b": /* WoW */ "2",
                "c": "3"
            } // It's a single comment at the end
        """
        @test parse_json(str_json, allow_comments = true) == Dict{String,Any}("c" => "3", "b" => "2", "a" => "1")

        str_json = """
            {
                "a": NaN,
                "b": nan,
                "c": Inf,
                "d": -Infinity
            }
        """
        @test isequal(
            parse_json(str_json, allow_inf_and_nan = true),
            Dict{String,Any}("c" => Inf, "b" => NaN, "a" => NaN, "d" => -Inf),
        )

        str_json = """
            {
                "a": 42,
                "b": 3.1415,
                "c": 1e3
            }
        """
        @test parse_json(str_json, number_as_raw = true) == Dict{String,Any}("c" => "1e3", "b" => "3.1415", "a" => "42")

        str_json = """
            {
                "a": "\x80xyz",
                "b": "\xF0",
                "c": "\x81"
            }
        """
        @test parse_json(str_json, allow_invalid_unicode = true) == Dict{String,Any}("c" => "\x81", "b" => "\xf0", "a" => "\x80xyz")
    end
end

@testset "Lazy Parser" begin
    @testset "Case №1: Parse from string, byte vector" begin
        str_json = """
        {
            "a": "1",
            "b": "2",
            "c": "3"
        }
        """
        @test parse_lazy_json(str_json) isa LazyJSONDict

        byte_json = b"""
        [
            "1",
            "2",
            "3"
        ]
        """
        @test parse_lazy_json(byte_json) isa LazyJSONVector

        parse_lazy_json(byte_json) do doc
            @test doc isa LazyJSONVector
        end
    end

    @testset "Case №2: LazyJSONDict interfaces" begin
        str_json = """
        {
            "a": "string",
            "b": 1.0,
            "c": 3,
            "d": true,
            "e": [1, "2", false],
            "f": {"1": 1, "2": 2},
            "g": null
        }
        """
        doc = parse_lazy_json(str_json)

        @test doc["a"] == "string"
        @test doc["b"] == 1.0 && doc["b"] isa Float64
        @test doc["c"] == 3 && doc["c"] isa Int64
        @test doc["d"]
        @test doc["e"] isa LazyJSONVector
        @test doc["f"] isa LazyJSONDict
        @test doc["g"] === nothing

        @test_throws KeyError doc["h"]
        @test ismissing(get(doc, "h", missing))

        @test collect(keys(doc)) == ["a", "b", "c", "d", "e", "f", "g"]
        @test length(doc) == 7
    end
    @testset "Case №3: LazyJSONVector interfaces" begin
        str_json = """
        [
            "string",
            1.0,
            3,
            true,
            [1, "2", false],
            {"1": 1, "2": 2},
            null
        ]
        """ 
        doc = parse_lazy_json(str_json)

        @test doc[1] == "string"
        @test doc[2] == 1.0 && doc[2] isa Float64
        @test doc[3] == 3 && doc[3] isa Int64
        @test doc[4]
        @test doc[5] isa LazyJSONVector
        @test doc[6] isa LazyJSONDict
        @test doc[7] === nothing

        @test_throws BoundsError doc[8]
        @test ismissing(get(doc, 8, missing))

        @test collect(keys(doc)) == Int64[1,2,3,4,5,6,7]
        @test length(doc) == 7
    end
end
