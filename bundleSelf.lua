local bundle = require("src.neblua").bundle

bundle {
    entry = "src.neblua",
    output = "./dist/neblua.lua",
    files = {
        "./src/neblua.lua",
    },
    verbose = true,
}

bundle {
    entry = "src.cli",
    output = "./dist/neblua-cli.lua",
    files = {
        "./src/cli.lua",
    },
    verbose = true,
}
