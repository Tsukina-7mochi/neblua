local path = require("src.lib.path")
local test = require("lib.test").test
local describe = require("lib.test").describe
local expect = require("lib.test").expect

describe(debug.getinfo(1).short_src, function ()
    describe("baseName", function ()
        test("file.lua", function ()
            expect(path.baseName("file.lua")):toBe("file.lua")
        end)

        test("path/to/file.lua", function ()
            expect(path.baseName("path/to/file.lua")):toBe("file.lua")
        end)

        test("path/to/", function ()
            expect(path.baseName("path/to/")):toBe("")
        end)

        test("/", function ()
            expect(path.baseName("/")):toBe("")
        end)

        test(".", function ()
            expect(path.baseName(".")):toBe(".")
        end)

        test("./", function ()
            expect(path.baseName("./")):toBe("")
        end)

        test("..", function ()
            expect(path.baseName("..")):toBe("..")
        end)

        test("../", function ()
            expect(path.baseName("../")):toBe("")
        end)

        test("empty", function ()
            expect(path.baseName("")):toBe("")
        end)
    end)

    describe("extName", function ()
        test("file.lua", function ()
            expect(path.extName("file.lua")):toBe(".lua")
        end)

        test("file", function ()
            expect(path.extName("file")):toBe("")
        end)

        test("path/to/file.lua", function ()
            expect(path.extName("path/to/file.lua")):toBe(".lua")
        end)

        test("path/", function ()
            expect(path.extName("path/")):toBe("")
        end)

        test("empty", function ()
            expect(path.extName("")):toBe("")
        end)
    end)

    describe("noExtName", function ()
        test("file.lua", function ()
            expect(path.noExtName("file.lua")):toBe("file")
        end)

        test("file", function ()
            expect(path.noExtName("file")):toBe("file")
        end)

        test("path/to/file.lua", function ()
            expect(path.noExtName("path/to/file.lua")):toBe("file")
        end)

        test("path/", function ()
            expect(path.noExtName("path/")):toBe("")
        end)

        test("empty", function ()
            expect(path.noExtName("")):toBe("")
        end)
    end)

    describe("normalize", function ()
        test("path/to/file.lua", function ()
            expect(path.normalize("path/to/file.lua")):toBe(
                "./path/to/file.lua"
            )
        end)

        test("path//to///file.lua", function ()
            expect(path.normalize("path//to///file.lua")):toBe(
                "./path/to/file.lua"
            )
        end)

        test("/file.lua", function ()
            expect(path.normalize("/file.lua")):toBe("/file.lua")
        end)

        test("///path/to/file.lua", function ()
            expect(path.normalize("///path/to/file.lua")):toBe(
                "/path/to/file.lua"
            )
        end)

        test("./file.lua", function ()
            expect(path.normalize("./file.lua")):toBe("./file.lua")
        end)

        test("path/./to/././file.lua", function ()
            expect(path.normalize("path/./to/././file.lua")):toBe(
                "./path/to/file.lua"
            )
        end)

        test("./././path/to/file.lua", function ()
            expect(path.normalize("./././path/to/file.lua")):toBe(
                "./path/to/file.lua"
            )
        end)

        test("path/to/../file.lua", function ()
            expect(path.normalize("path/to/../file.lua")):toBe(
                "./path/file.lua"
            )
        end)

        test("../file.lua", function ()
            expect(path.normalize("../file.lua")):toBe("../file.lua")
        end)

        test("../../file.lua", function ()
            expect(path.normalize("../../file.lua")):toBe("../../file.lua")
        end)

        test("path/to/../../../file.lua", function ()
            expect(path.normalize("path/to/../../../file.lua")):toBe(
                "../file.lua"
            )
        end)

        test("/", function ()
            expect(path.normalize("/")):toBe("/")
        end)

        test(".", function ()
            expect(path.normalize(".")):toBe(".")
        end)

        test("./", function ()
            expect(path.normalize("./")):toBe(".")
        end)

        test("../", function ()
            expect(path.normalize("../")):toBe("..")
        end)

        test("/../", function ()
            expect(path.normalize("/../")):toBe("/..")
        end)
    end)

    describe("join", function ()
        test("/, file.lua", function ()
            expect(path.join("/", "file.lua")):toBe("/file.lua")
        end)

        test("., file.lua", function ()
            expect(path.join(".", "file.lua")):toBe("./file.lua")
        end)

        test("./, file.lua", function ()
            expect(path.join("./", "file.lua")):toBe("./file.lua")
        end)

        test(".., file.lua", function ()
            expect(path.join("..", "file.lua")):toBe("../file.lua")
        end)

        test("../, file.lua", function ()
            expect(path.join("../", "file.lua")):toBe("../file.lua")
        end)

        test("path/to, file.lua", function ()
            expect(path.join("path/to", "file.lua")):toBe("./path/to/file.lua")
        end)

        test("path/to/, file.lua", function ()
            expect(path.join("path/to/", "file.lua")):toBe("./path/to/file.lua")
        end)

        test("path/to, subpath/file.lua", function ()
            expect(path.join("path/to", "subpath/file.lua")):toBe(
                "./path/to/subpath/file.lua"
            )
        end)

        test("path/to, ../file.lua", function ()
            expect(path.join("path/to", "../file.lua")):toBe("./path/file.lua")
        end)

        test("path/to/../, file.lua", function ()
            expect(path.join("path/to/../", "file.lua")):toBe("./path/file.lua")
        end)

        test("path/to/./, file.lua", function ()
            expect(path.join("path/to/./", "file.lua")):toBe(
                "./path/to/file.lua"
            )
        end)

        test("path/to, /path/to/file.lua", function ()
            expect(path.join("path/to", "/path/to/file.lua")):toBe(
                "./path/to/path/to/file.lua"
            )
        end)
    end)
end)
