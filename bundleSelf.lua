local bundle = require("src.neblua").bundle

bundle {
    entry = "src.neblua",
    output = "./dist/neblua.lua",
    files = {
        "./src/neblua.lua",
        "./src/path.lua",
        "./src/string.lua",
        { path = "./src/templates/template.lua", type = "text" }
    },
    verbose = true,
}

bundle {
    entry = "src.cli",
    output = "./dist/neblua-cli.lua",
    files = {
        "./src/cli.lua",
        "./src/neblua.lua",
        "./src/path.lua",
        "./src/string.lua",
        { path = "./src/templates/template.lua", type = "text" }
    },
    verbose = true,
}
