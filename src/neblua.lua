local appInfo = require("app")
local getFileContent = require("src.getFileContent")
local moduleLoader = require("src.moduleLoader")
local path = require("src.path")
local requireText = require("src.requireModule").requireText
local split = require("src.string").split

local template = requireText("./src/templates/template.lua")
local substitutionPoints = {
    entry = "__NEBLUA_ENTRY__",
    slot = "%-%-%[%[__NEBLUA_SLOT__%]%]",
}

---@class BundleOptions
---@field rootDir? string
---@field entry string
---@field files (string | { path: string, type: string })[]
---@field output string
---@field verbose? boolean

---@param options BundleOptions
local function bundle(options)
    local verbosePrint = function(...)
        if options.verbose == true then
            print("[neblua]", ...)
        end
    end

    if type(options) ~= "table" then
        error("[neblua] Expected options to be a table")
    end
    if type(options.entry) ~= "string" then
        error("[neblua] Expected options.entry to be a string")
    end
    if type(options.files) ~= "table" then
        error("[neblua] Expected options.files to be a table")
    end
    if type(options.output) ~= "string" then
        error("[neblua] Expected options.output to be a string")
    end

    options.output = path.relative(options.output, ".")
    if options.rootDir == nil then
        options.rootDir = "./"
    else
        if type(options.rootDir) ~= "string" then
            error("[neblua] Expected options.rootDir to be a string")
        end

        if options.rootDir:sub(-1) ~= path.separator then
            options.rootDir = options.rootDir .. path.separator
        end
        options.rootDir = path.relative(options.rootDir, ".")
    end

    for i, file in ipairs(options.files) do
        if type(file) == "string" then
            options.files[i] = {
                path = file,
                type = "lua",
            }
        elseif type(file) == "table" then
            if type(file.path) ~= "string" then
                error("[neblua] Expected options.files[" .. i .. "].path to be a string")
            elseif type(file.type) ~= "string" then
                error("[neblua] Expected options.files[" .. i .. "].type to be a string")
            end
        else
            error("[neblua] Expected options.files[" .. i .. "] to be a string or a table")
        end

        options.files[i].path = path.relative(options.files[i].path, ".")
        local extName = path.extName(options.files[i].path)
        if options.files[i].type == "lua" then
            if extName ~= ".lua" then
                error("[neblua] File " .. options.files[i] .. " is not a Lua file")
            end
        elseif options.files[i].type == "text" then
            --do nothing
        else
            error("[neblua] Unknown file type: " .. options.files[i].type)
        end
    end

    verbosePrint("Entry : " .. options.entry)
    verbosePrint("Output: " .. options.output)
    if options.verbose == true then
        local files = {}
        for _, file in ipairs(options.files) do
            table.insert(files, string.format("[%s]%s", file.type, file.path))
        end
        verbosePrint("Files : " .. table.concat(files, ", "))
    end

    ---@type table<string, { type: string, content: string }>
    local files = {}
    for _, file in ipairs(options.files) do
        files[file.path] = {
            type = file.type,
            content = getFileContent(path.relative(file.path, options.rootDir)),
        }
        verbosePrint("Loaded " .. file.path)
    end

    local slotContents = {}
    for fileName, file in pairs(files) do
        fileName = fileName:gsub("%%", "%%%%")

        if file.type == "lua" then
            table.insert(slotContents, moduleLoader.luaModule(fileName, file.content))
        elseif file.type == "text" then
            table.insert(slotContents, moduleLoader.textModule(fileName, file.content))
        end
    end

    local entryName = "\"" .. options.entry:gsub("%%", "%%%%") .. "\""
    local slotContentsString = table.concat(slotContents, "\n"):gsub("%%", "%%%%")
    local result = template
        :gsub(substitutionPoints.entry, entryName)
        :gsub(substitutionPoints.slot, slotContentsString)

    local outputFile = io.open(options.output, "w")
    if outputFile == nil then
        error("[neblua] Could not open output file: " .. options.output)
    end
    outputFile:write(result)
    outputFile:close()

    verbosePrint("Wrote " .. options.output)
end

return {
    bundle = bundle,
    requireText = requireText,
    appInfo = appInfo,
}
