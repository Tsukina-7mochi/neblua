local bundle = require("src.neblua").bundle
local util = require("test.util")
local test = require("test.test").test
local describe = require("test.test").describe
local expect = require("test.test").expect

describe(debug.getinfo(1).short_src, function()
    test("single file: module form entry", function()
        local options = {
            entry = "test.bundle.singleFile.main",
            files = { "./test/bundle/singleFile/main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }

        bundle(options)

        local result = util.execute(options.output)
        expect(result):toBe("main")
    end)

    test("single file: path form entry", function()
        local options = {
            entry = "./test/bundle/singleFile/main",
            files = { "./test/bundle/singleFile/main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }

        bundle(options)

        local result = util.execute(options.output)
        expect(result):toBe("main")
    end)

    test("single file: rootDir", function()
        local options = {
            rootDir = "./test/bundle/singleFile/",
            entry = "main",
            files = { "./main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }
        bundle(options)

        local result = util.execute(options.output)
        expect(result):toBe("main")
    end)

    test("multi file: module form", function()
        local options = {
            rootDir = "./test/bundle/multiFileModuleRequire/",
            entry = "main",
            files = { "./main.lua", "./module1.lua", "./subpath/module2.lua" },
            output = "./test/bundle/multiFileModuleRequire/main.bundle.lua",
        }
        bundle(options)

        local result = util.execute(options.output)
        expect(result):toBe("main\nmodule1\nmodule2")
    end)

    test("multi file: path form", function()
        local options = {
            rootDir = "./test/bundle/multiFilePathRequire/",
            entry = "main",
            files = { "./main.lua", "./module1.lua", "./subpath/module2.lua" },
            output = "./test/bundle/multiFilePathRequire/main.bundle.lua",
        }
        bundle(options)

        local result = util.execute(options.output)
        expect(result):toBe("main\nmodule1\nmodule2")
    end)

    test("error line", function()
        local options = {
            rootDir = "./test/bundle/error/",
            entry = "main",
            files = { "./main.lua", "./module1.lua" },
            output = "./test/bundle/error/main.bundle.lua",
        }
        bundle(options)

        local result = util.execute(options.output, true)
        expect(result):to(function(value)
            return value:find("in function 'error'") ~= nil and value:find("module1.lua:3:") ~= nil
        end)
    end)

    test("loadfile", function()
        local options = {
            rootDir = "./test/bundle/loadfile/",
            entry = "main",
            files = { "./main.lua", "./module1.lua" },
            output = "./test/bundle/loadfile/main.bundle.lua",
        }
        bundle(options)

        local result = util.execute(options.output, true)
        expect(result):toBe("main\nmodule1")
    end)

    test("dofile", function()
        local options = {
            rootDir = "./test/bundle/dofile/",
            entry = "main",
            files = { "./main.lua", "./module1.lua" },
            output = "./test/bundle/dofile/main.bundle.lua",
        }
        bundle(options)

        local result = util.execute(options.output, true)
        expect(result):toBe("main\nmodule1")
    end)
end)
