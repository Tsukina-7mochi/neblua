local bundle = require("src.neblua").bundle

bundle {
    entry = "src.neblua",
    output = "./dist/neblua.lua",
    files = {
        "./src/getFileContent.lua",
        "./src/moduleLoader.lua",
        "./src/neblua.lua",
        "./src/path.lua",
        "./src/requireModule.lua",
        "./src/string.lua",
        { path = "./version.txt",                type = "text" },
        { path = "./src/templates/template.lua", type = "text" },
    },
    verbose = true,
}

bundle {
    entry = "src.cli",
    output = "./dist/neblua-cli.lua",
    files = {
        "./src/cli.lua",
        "./src/getFileContent.lua",
        "./src/moduleLoader.lua",
        "./src/neblua.lua",
        "./src/path.lua",
        "./src/requireModule.lua",
        "./src/string.lua",
        { path = "./version.txt",                type = "text" },
        { path = "./src/templates/template.lua", type = "text" }
    },
    verbose = true,
}
