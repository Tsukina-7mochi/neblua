local neblua = require("src.neblua")

local options = {
    entry = nil,
    files = {},
    output = nil,
    verbose = false,
    excludes = {},
}

local command = nil
for _, val in ipairs(arg) do
    if val:sub(1, 1) == "-" then
        if command ~= nil then
            error("Expected value for " .. command)
        end

        if val == "--verbose" then
            options.verbose = true
        elseif val == "-v" or val == "--version" then
            print(neblua.appInfo.name .. " " .. neblua.appInfo.version)
            os.exit(0)
        elseif val == "--help" then
            print(neblua.appInfo.name .. " " .. neblua.appInfo.version)
            print([[Usage: lua neblua-cli [options] <files...>
Options:
    -e, --entry <file>      Entry module name
    -o, --output <file>     Output file name
    -v, --version           Print version
    --root-dir <dir>        Root directory
    --verbose               Enable verbose output
    --help                  Print this help message
            ]])
            os.exit(0)
        else
            command = val
        end
    elseif command == nil then
        table.insert(options.files, val)
    elseif command == "-e" or command == "--entry" then
        command = nil

        options.entry = val

        if options.output == nil then
            options.output = options.entry .. ".bundle.lua"
        end
    elseif command == "-o" or command == "--output" then
        command = nil

        options.output = val
    elseif command == "--root-dir" then
        command = nil

        options.rootDir = val
    elseif command == "--excludes" then
        command = nil

        table.insert(options.excludes, val)
    else
        error("Unknown command " .. command)
    end
end

if options.entry == nil then
    error("No entry module specified")
end
if options.output == nil then
    error("No output file specified")
end

return neblua.bundle(options)
