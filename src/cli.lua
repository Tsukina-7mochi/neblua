local neblua = require("src.neblua")

---Splits a string by a search string
---@param str string
---@param searchStr string
---@return string[]
local function split(str, searchStr)
    if str == "" then
        return { str }
    end

    local result = {}
    local pos = 1
    while true do
        local startPos, endPos = str:find(searchStr, pos)

        if startPos == nil then
            break
        end

        table.insert(result, str:sub(pos, startPos - 1))
        pos = endPos + 1
    end

    if pos <= #str then
        table.insert(result, str:sub(pos))
    end

    return result
end

local config = split(package.config, "\n")
local pathSeparator = config[1]
local templateSeparator = config[2]
local substitutionPoint = config[3]

local srcName = "./" .. debug.getinfo(1).short_src
local bundleFileName = srcName:gsub(
    "%" .. pathSeparator .. "[^/]*$",
    ("/src/bundle.lua"):gsub("%/", pathSeparator)
)
local options = {
    entry = nil,
    files = {},
    output = nil,
    verbose = false,
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
            options.output = options.entry:sub(1, options.entry:find("%.[^%.]*$") - 1) .. ".bundle.lua"
        end
    elseif command == "-o" or command == "--output" then
        command = nil

        options.output = val
    else
        error("Unknown command " .. command)
    end
end

if options.entry == nil then
    error("No entry file specified")
end
if options.output == nil then
    error("No output file specified")
end

return require("src.neblua").bundle(options)
