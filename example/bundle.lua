local bundle = require("src.neblua").bundle

bundle {
    rootDir = "./example/src/",
    entry = "main",
    files = {
        "./main.lua",
        "./module1.lua",
        "./module2.lua",
        "./sub/module1.lua",
        "./sub/module2.lua",
    },
    output = "./example/main.bundle.lua",
}
