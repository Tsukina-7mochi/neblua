local bundle = require("src.neblua").bundle

bundle {
    rootDir = "./example/src/",
    entry = "main",
    files = {
        "./main.lua",
    },
    output = "./example/main.bundle.lua",
}
