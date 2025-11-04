local split = require("src.string").split
local test = require("lib.test").test
local describe = require("lib.test").describe
local expect = require("lib.test").expect

describe(debug.getinfo(1).short_src, function ()
    test("1 value", function ()
        local result = split("aaa", ",")
        expect(#result):toBe(1)
        expect(result[1]):toBe("aaa")
    end)

    test("2 values", function ()
        local result = split("aaa,bbb", ",")
        expect(#result):toBe(2)
        expect(result[1]):toBe("aaa")
        expect(result[2]):toBe("bbb")
    end)

    test("3 values", function ()
        local result = split("aaa,bbb,ccc", ",")
        expect(#result):toBe(3)
        expect(result[1]):toBe("aaa")
        expect(result[2]):toBe("bbb")
        expect(result[3]):toBe("ccc")
    end)

    test("empty string", function ()
        local result = split("", ",")
        expect(#result):toBe(1)
        expect(result[1]):toBe("")
    end)

    test("starts with separator", function ()
        local result = split(",aaa", ",")
        expect(#result):toBe(2)
        expect(result[1]):toBe("")
        expect(result[2]):toBe("aaa")
    end)

    test("ends with separator", function ()
        local result = split("aaa,", ",")
        expect(#result):toBe(2)
        expect(result[1]):toBe("aaa")
        expect(result[2]):toBe("")
    end)
end)
