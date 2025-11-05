local bundle = require("src.neblua").bundle
local util = require("test.util")
local test = require("lib.test").test
local describe = require("lib.test").describe
local expect = require("lib.test").expect

describe(debug.getinfo(1).short_src, function ()
    test("single file: module form entry", function ()
        local options = {
            entry = "test.bundle.singleFile.main",
            include = { "./test/bundle/singleFile/main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }

        bundle(options)

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\n")
        expect(stderr):toBe("")
    end)

    test("single file: path form entry", function ()
        local options = {
            entry = "./test/bundle/singleFile/main",
            include = { "./test/bundle/singleFile/main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }

        bundle(options)

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\n")
        expect(stderr):toBe("")
    end)

    test("single file: rootDir", function ()
        local options = {
            rootDir = "./test/bundle/singleFile/",
            entry = "main",
            include = { "./main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }
        bundle(options)

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\n")
        expect(stderr):toBe("")
    end)

    test("single file: call multi time", function ()
        local options = {
            rootDir = "./test/bundle/singleFile/",
            entry = "main",
            include = { "./main.lua" },
            output = "./test/bundle/singleFile/main.bundle.lua",
        }
        bundle(options)

        local entryFilename = os.tmpname()
        local entryFile = assert(io.open(entryFilename, "w"))
        entryFile:write(
            [[local chunk = loadfile("]]
                .. options.output
                .. [[") chunk() chunk()]]
        )
        entryFile:close()

        local stdout, stderr = util.execute(entryFilename)

        expect(stdout):toBe("main\nmain\n")
        expect(stderr):toBe("")
    end)

    test("multi file: module form", function ()
        local options = {
            rootDir = "./test/bundle/multiFileModuleRequire/",
            entry = "main",
            include = { "./main.lua" },
            output = "./test/bundle/multiFileModuleRequire/main.bundle.lua",
        }
        bundle(options)

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\nmodule1\nmodule2\n")
        expect(stderr):toBe("")
    end)

    test("multi file: path form", function ()
        local options = {
            rootDir = "./test/bundle/multiFilePathRequire/",
            entry = "main",
            include = { "./main.lua" },
            output = "./test/bundle/multiFilePathRequire/main.bundle.lua",
        }
        bundle(options)

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\nmodule1\nmodule2\n")
        expect(stderr):toBe("")
    end)

    test(
        "multi file: backslash path separator at execution environment",
        function ()
            local options = {
                rootDir = "./test/bundle/pathSeparator/",
                entry = "main",
                include = { "./main.lua" },
                output = "./test/bundle/pathSeparator/main.bundle.lua",
            }
            bundle(options)

            local outFile = assert(io.open(options.output, "r"))
            local content = outFile:read("*a")
            outFile:close()

            outFile = assert(io.open(options.output, "w"))
            outFile:write(
                [[package.path = package.path:gsub(package.config:sub(1, 1), "\\")]]
            )
            outFile:write([[package.config = "\\" .. package.config:sub(2)]])
            outFile:write(content)
            outFile:close()

            local stdout, stderr = util.execute(options.output)

            expect(stdout):toBe("main\nmodule1\nmodule2\n")
            expect(stderr):toBe("")
        end
    )

    test("error line", function ()
        local options = {
            rootDir = "./test/bundle/error/",
            entry = "main",
            include = { "./main.lua" },
            output = "./test/bundle/error/main.bundle.lua",
        }
        bundle(options)

        local _, stderr = util.execute(options.output)

        assert(stderr:find("Oops!") ~= nil, "error message not found")
        assert(stderr:find("module1.lua:3:") ~= nil, "error line not found")
    end)

    test("redirect stderr", function ()
        local options = {
            rootDir = "./test/bundle/error/",
            entry = "main",
            include = { "./main.lua" },
            output = "./test/bundle/error/main.bundle.lua",
            fallbackStderr = true,
        }
        bundle(options)

        local stdout, stderr = util.execute(options.output)

        assert(stdout:find("Oops!") ~= nil, "error message not found in stdout")
        assert(stderr:find("Oops!") == nil, "error message found in stderr")
    end)

    test("external: build success", function ()
        local options = {
            rootDir = "./test/bundle/external/",
            include = {},
            external = {
                "^module1$", -- module does not exist in the project
                "^./resource.txt$",
            },
            entry = "main",
            output = "./test/bundle/external/main.bundle.lua",
        }
        bundle(options)

        -- inject module1 implementation and dummy requireText
        local outFile = assert(io.open(options.output, "r"))
        local content = outFile:read("*a")
        outFile:close()

        outFile = assert(io.open(options.output, "w"))
        outFile:write(
            'package.preload["module1"] = function () print("module1") end\n'
        )
        outFile:write("requireText = function() end\n")
        outFile:write(content)
        outFile:close()

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\nmodule1\n")
        expect(stderr):toBe("")
    end)

    test("external: build failure", function ()
        local options = {
            rootDir = "./test/bundle/external/",
            include = {},
            entry = "main",
            output = "./test/bundle/external/main.bundle.lua",
        }
        local success, err = pcall(bundle, options)

        expect(success):toBe(false)
        assert(
            string.find(err, "Cannot resolve module: module1") ~= nil,
            "error message not found"
        )
    end)

    test("loadfile", function ()
        local options = {
            rootDir = "./test/bundle/loadfile/",
            entry = "main",
            include = { "./main.lua", "./module1.lua" },
            output = "./test/bundle/loadfile/main.bundle.lua",
        }
        bundle(options)

        local stdout, stderr = util.execute(options.output)

        expect(stdout):toBe("main\nmodule1\n")
        expect(stderr):toBe("")
    end)

    test("dofile", function ()
        local options = {
            rootDir = "./test/bundle/dofile/",
            entry = "main",
            include = { "./main.lua", "./module1.lua" },
            output = "./test/bundle/dofile/main.bundle.lua",
        }
        bundle(options)

        local stdout, stderr = util.execute(options.output)
        expect(stdout):toBe("main\nmodule1\n")
        expect(stderr):toBe("")
    end)
end)
