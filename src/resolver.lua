local array = require("src.lib.array")
local file = require("src.lib.file")
local pathUtil = require("src.lib.path")

local templateSeparator = package.config:sub(3, 3)
local substitutionPoint = package.config:sub(5, 5)
local substitutionPattern = "%" .. substitutionPoint

---@param str string
---@param sep string
---@return string[]
local function split (str, sep)
    return array.collect(str:gmatch("([^" .. sep .. "]*)"))
end

---@param templatesStr string
---@param value string
---@return string[]
local function applyTemplates (templatesStr, value)
    local templates = split(templatesStr, templateSeparator)

    local result = {}
    for _, template in ipairs(templates) do
        local applied = template:gsub(substitutionPattern, value)
        table.insert(result, applied)
    end

    return result
end

---@class ResolverResult
---@field path string
---@field filepath string

---@param path string
---@param rootDir string
---@param ignorePatterns string[]
---@param externalPatterns string[]
---@return ResolverResult?
---@return string? errmsg
local function resolvePath (path, rootDir, ignorePatterns, externalPatterns)
    local normalizedPath = pathUtil.normalize(path)
    for _, pattern in ipairs(externalPatterns) do
        if normalizedPath:match(pattern) then
            return nil, nil
        end
    end

    local resolvedPath, err = pathUtil.join(rootDir, normalizedPath)
    if err or resolvedPath == nil then
        return nil, "Cannot resolve path: " .. path
    end

    for _, pattern in ipairs(ignorePatterns) do
        if resolvedPath:match(pattern) then
            return nil, "Cannot resolve path: " .. path
        end
    end

    local isReadable = file.isReadable(resolvedPath)
    if not isReadable then
        return nil, "Cannot resolve path: " .. path
    end

    return { path = pathUtil.normalize(path), filepath = resolvedPath }, nil
end

---@param moduleName string
---@param pathTemplates string
---@param rootDir string
---@param ignorePatterns string[]
---@param externalPatterns string[]
---@return ResolverResult?
---@return string? errmsg
local function resolveModule (
    moduleName,
    pathTemplates,
    rootDir,
    ignorePatterns,
    externalPatterns
)
    for _, pattern in ipairs(externalPatterns) do
        if moduleName:match(pattern) then
            return nil, nil
        end
    end

    local path = moduleName:gsub("%.", pathUtil.separator)
    local possiblePaths = applyTemplates(pathTemplates, path)

    for _, possiblePath in ipairs(possiblePaths) do
        local result, err =
            resolvePath(possiblePath, rootDir, ignorePatterns, {})
        if err == nil and result ~= nil then
            return result, nil
        end
    end

    error("Cannot resolve module: " .. moduleName)
end

return {
    resolvePath = resolvePath,
    resolveModule = resolveModule,
}
