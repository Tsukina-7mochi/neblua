local array = require("src.lib.array")
local file = require("src.lib.file")
local moduleLoader = require("src.moduleLoader")
local path = require("src.lib.path")
local requireText = require("src.requireModule").requireText

---@param str string
---@param sep string
---@return string[]
local function split (str, sep)
    return array.collect(str:gmatch("([^" .. sep .. "]+)"))
end

local appInfo = {
    name = "neblua",
    version = requireText("./version.txt"):gsub("\n", ""),
}

local template = requireText("./src/templates/template.lua")
local substitutionPoints = {
    entry = "__NEBLUA_ENTRY__",
    fallbackStderr = "__NEBLUA_FALLBACK_STDERR__",
    slot = "%-%-%[%[__NEBLUA_SLOT__%]%]",
}

-- TODO: support long string literals
local requirePatterns = {
    'require%s*"([^"]*)"',
    "require%s*'([^\"]*)'",
    'require%s*%(%s*"([^"]*)"%s*%)',
    "require%s*%(%s*'([^\"]*)'%s*%)",
}
local requireTextPatterns = {
    'requireText%s*"([^"]*)"',
    "requireText%s*'([^\"]*)'",
    'requireText%s*%(%s*"([^"]*)"%s*%)',
    "requireText%s*%(%s*'([^\"]*)'%s*%)",
}

local config = split(package.config, "\n")
local pathSeparator = "/"
local templateSeparator = config[2]
local substitutionPoint = config[3]
local pathTemplates = split(package.path, templateSeparator)
pathTemplates = array.filter(pathTemplates, function (v)
    return v:sub(1, 1) == "."
end)

---@param str string
---@param patterns string[]
---@return boolean
local function anyPatternMatch (str, patterns)
    for _, pattern in ipairs(patterns) do
        if str:match(pattern) then
            return true
        end
    end
    return false
end

---@param filename string
---@param moduleType "lua" | "text"
---@param rootDir string
---@param excludePatterns string[]
---@return { path: string, slotContent: string }[]
local function loadFileAsSlot (filename, moduleType, rootDir, excludePatterns)
    ---@type { path: string, slotContent: string }[]
    local results = {}
    local escapedFileName = filename:gsub("%%", "%%%%")

    local content, err = file.getContent(path.relative(filename, rootDir))
    if err then
        return {}
    end

    if moduleType == "lua" then
        local loaded = moduleLoader.luaModule(escapedFileName, content)
        table.insert(results, { path = filename, slotContent = loaded })
    elseif moduleType == "text" then
        local loaded = moduleLoader.textModule(escapedFileName, content)
        table.insert(results, { path = filename, slotContent = loaded })
    end

    if moduleType == "text" then
        return results
    end

    -- search `require`s recursively
    for _, pattern in ipairs(requirePatterns) do
        for moduleName in content:gmatch(pattern) do
            moduleName = moduleName:gsub("%.", pathSeparator)
            if not anyPatternMatch(moduleName, excludePatterns) then
                for _, template in ipairs(pathTemplates) do
                    local modulePath =
                        template:gsub(substitutionPoint, moduleName)
                    local filename = path.relative(modulePath, ".")
                    local loaded = loadFileAsSlot(
                        filename,
                        "lua",
                        rootDir,
                        excludePatterns
                    )
                    for _, l in ipairs(loaded) do
                        table.insert(results, l)
                    end
                end
            end
        end
    end

    -- search `requireText`s
    for _, pattern in ipairs(requireTextPatterns) do
        for filename in content:gmatch(pattern) do
            if not anyPatternMatch(filename, excludePatterns) then
                local loaded =
                    loadFileAsSlot(filename, "text", rootDir, excludePatterns)
                for _, l in ipairs(loaded) do
                    table.insert(results, l)
                end
            end
        end
    end

    return results
end

---@class BundleOptions
---@field rootDir? string
---@field entry string
---@field include (string | { path: string, type: string })[]
---@field output string
---@field verbose? boolean
---@field exclude? string[]
---@field fallbackStderr? boolean

---@class NormalizedBundleOptions
---@field rootDir string
---@field entry string
---@field include { path: string, type: "lua" | "text" }[]
---@field output string
---@field verbose boolean
---@field exclude string[]
---@field fallbackStderr boolean

---@param options BundleOptions
---@return NormalizedBundleOptions
local function normalizeBundleOptions (options)
    if type(options) ~= "table" then
        error("[neblua] Expected options to be a table")
    end

    local rootDir = options.rootDir
    local entry = options.entry
    local include = options.include
    local output = options.output
    local verbose = options.verbose
    local exclude = options.exclude
    local fallbackStderr = options.fallbackStderr

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

    if type(include) ~= "table" then
        error("[neblua] Expected options.include to be a table")
    end
    for i, file in ipairs(include) do
        if type(file) == "string" then
            include[i] = { path = file, type = "lua" }
        elseif type(file) == "table" then
            if type(file.path) ~= "string" then
                error(
                    "[neblua] Expected options.include["
                        .. i
                        .. "].path to be a string"
                )
            elseif type(file.type) ~= "string" then
                error(
                    "[neblua] Expected options.include["
                        .. i
                        .. '].type to be one of {"lua", "text"}'
                )
            end
        else
            error(
                "[neblua] Expected options.include["
                    .. i
                    .. "] to be a string or a table"
            )
        end

        include[i].path = path.relative(include[i].path, ".")
        if include[i].type == "lua" then
        elseif include[i].type == "text" then
            --do nothing
        else
            error(
                "[neblua] Expected options.include["
                    .. i
                    .. '].type to be one of {"lua", "text"}'
            )
        end
    end

    if type(output) ~= "string" then
        error("[neblua] Expected options.output to be a string")
    end
    output = path.relative(output, ".")

    if verbose ~= nil and type(verbose) ~= "boolean" then
        error("[neblua] Expected options.verbose to be a string or nil")
    end
    verbose = verbose == true

    if exclude == nil then
        exclude = {}
    elseif type(exclude) == "table" then
        for i, pattern in ipairs(exclude) do
            if type(pattern) ~= "string" then
                error(
                    "[neblua] Expected options.include["
                        .. i
                        .. "].path to be a string"
                )
            end
        end
    else
        error("[neblua] Expected options.exclude to be a string[]")
    end

    if fallbackStderr ~= nil and type(fallbackStderr) ~= "boolean" then
        error("[neblua] Expected options.fallbackStderr to be a boolean or nil")
    end
    fallbackStderr = fallbackStderr == true

    return {
        rootDir = rootDir,
        entry = entry,
        include = include,
        output = output,
        verbose = verbose,
        exclude = exclude,
        fallbackStderr = fallbackStderr,
    }
end

---@param options BundleOptions
local function bundle (options)
    local verbosePrint = function (...)
        if options.verbose == true then
            print("[neblua]", ...)
        end
    end

    local options = normalizeBundleOptions(options)

    verbosePrint("Root  : " .. options.rootDir)
    verbosePrint("Entry : " .. options.entry)
    verbosePrint("Output: " .. options.output)

    ---@type string[]
    local loadedFiles = {}
    local slotContents = {}
    for _, file in ipairs(options.include) do
        local loaded = loadFileAsSlot(
            file.path,
            file.type,
            options.rootDir,
            options.exclude
        )
        for _, l in ipairs(loaded) do
            if not array.includes(loadedFiles, l.path) then
                verbosePrint("Loaded " .. l.path)
                table.insert(loadedFiles, l.path)
                table.insert(slotContents, l.slotContent)
            end
        end
    end

    local entryName = '"' .. options.entry:gsub("%%", "%%%%") .. '"'
    local slotContentsString =
        table.concat(slotContents, "\n"):gsub("%%", "%%%%")
    local fallbackStderr = "false"
    if options.fallbackStderr == true then
        fallbackStderr = "true"
    end

    local result = template
        :gsub(substitutionPoints.entry, entryName)
        :gsub(substitutionPoints.fallbackStderr, fallbackStderr)
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
