local getFileContent = require("src.getFileContent")
local moduleLoader = require("src.moduleLoader")
local path = require("src.path")
local requireText = require("src.requireModule").requireText
local split = require("src.string").split

local appInfo = {
    name = "neblua",
    version = requireText("./version.txt"):gsub("\n", ""),
}

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

---@class NormalizedBundleOptions
---@field rootDir string
---@field entry string
---@field files { path: string, type: "lua" | "text" }[]
---@field output string
---@field verbose boolean

---@param options BundleOptions
---@return NormalizedBundleOptions
local function normalizeBundleOptions(options)
    if type(options) ~= "table" then
        error("[neblua] Expected options to be a table")
    end

    local rootDir = options.rootDir
    local entry = options.entry
    local files = options.files
    local output = options.output
    local verbose = options.verbose

    if rootDir == nil then
        rootDir = "./"
    else
        if type(rootDir) ~= "string" then
            error("[neblua] Expected options.rootDir to be a string or nil")
        end

        -- make rootDir to start with './' and end with '/'
        if rootDir:sub(-1) ~= path.separator then
            rootDir = rootDir .. path.separator
        end
        rootDir = path.relative(rootDir, ".")
    end

    if type(entry) ~= "string" then
        error("[neblua] Expected options.entry to be a string")
    end

    if type(files) ~= "table" then
        error("[neblua] Expected options.files to be a table")
    end
    for i, file in ipairs(files) do
        if type(file) == "string" then
            files[i] = { path = file, type = "lua" }
        elseif type(file) == "table" then
            if type(file.path) ~= "string" then
                error("[neblua] Expected options.files[" .. i .. "].path to be a string")
            elseif type(file.type) ~= "string" then
                error("[neblua] Expected options.files[" .. i .. "].type to be one of {\"lua\", \"text\"}")
            end
        else
            error("[neblua] Expected options.files[" .. i .. "] to be a string or a table")
        end

        files[i].path = path.relative(files[i].path, ".")
        if files[i].type == "lua" then
        elseif files[i].type == "text" then
            --do nothing
        else
            error("[neblua] Expected options.files[" .. i .. "].type to be one of {\"lua\", \"text\"}")
        end
    end

    if type(output) ~= "string" then
        error("[neblua] Expected options.output to be a string")
    end
    options.output = path.relative(options.output, ".")

    if verbose ~= nil and type(verbose) ~= "boolean" then
        error("[neblua] Expected options.verbose to be a string or nil")
    end

    return {
        rootDir = rootDir,
        entry = entry,
        files = files,
        output = output,
        verbose = verbose,
    }
end

---@param options BundleOptions
local function bundle(options)
    local verbosePrint = function(...)
        if options.verbose == true then
            print("[neblua]", ...)
        end
    end

    local options = normalizeBundleOptions(options)

    verbosePrint("Root  : " .. options.rootDir)
    verbosePrint("Entry : " .. options.entry)
    verbosePrint("Output: " .. options.output)

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
