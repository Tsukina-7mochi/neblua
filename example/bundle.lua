local bundle = require("src.neblua").bundle

bundle({
    rootDir = "./example/src/",
    include = { "main.lua" },
    entry = "main",
    output = "./example/main.bundle.lua",
    verbose = true,
})
