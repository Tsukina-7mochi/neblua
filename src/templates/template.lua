-- This file is generated by the neblua bundler
-- https://github.com/Tsukina-7mochi/neblua

package.bundleLoader = {}

--[[__NEBLUA_SLOT__]]

-- sentinel value for error message replacement
package.bundleLoader[debug.getinfo(1).short_src] = {
    line = 0,
    loader = nil,
}

---Splits a string by a search string
---@param str string
---@param searchStr string
---@return string[]
local function split(str, searchStr)
    if #str == 0 then
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
    else
        table.insert(result, "")
    end

    return result
end

local config = split(package.config, "\n")
local pathSeparator = config[1]
local templateSeparator = config[2]
local substitutionPoint = config[3]

--- Resolves a given path using the specified path separator
---@param path string The path to resolve
---@return string
local function resolvePath(path)
    local segments = split(path, pathSeparator)
    local resultSegments = {}

    if segments[1] == "." then
        table.insert(resultSegments, ".")
    end
    if segments[1] == "" then
        table.insert(resultSegments, "")
    end
    if segments[1] == ".." then
        error("Cannot go above root directory")
    end

    for _, seg in ipairs(segments) do
        if seg == "." or seg == "" then
            -- Do nothing
        elseif seg == ".." then
            table.remove(resultSegments)
        else
            table.insert(resultSegments, seg)
        end
    end

    if segments[#segments] == "" then
        table.insert(resultSegments, "")
    end

    return table.concat(resultSegments, pathSeparator)
end

--- Searches for a module in the `package.bundleLoader`
---@param moduleName string
---@return function
---@return string
---@overload fun(moduleName: string): nil
local function bundlerSearcher(moduleName)
    moduleName = moduleName:gsub("%.", pathSeparator)

    local templates = split(package.path, templateSeparator)
    for _, template in ipairs(templates) do
        local path = template:gsub(substitutionPoint, moduleName)
        local resolvedPath = resolvePath(path)
        local loader = package.bundleLoader[resolvedPath]
        if loader ~= nil and loader.loader ~= nil then
            return loader.loader, path
        end
    end

    return nil
end

--- Register the bundler searcher at the highest priority
table.insert(package.searchers, 1, bundlerSearcher)

-- Replace dofile
local originalDoFile = dofile
---@diagnostic disable-next-line: duplicate-set-field
_ENV.dofile = function(path)
    local loader = package.bundleLoader[path]
    if loader ~= nil and loader.loader ~= nil then
        return loader.loader()
    else
        return originalDoFile(path)
    end
end

-- Replace loadfile
local originalLoadFile = loadfile
---@diagnostic disable-next-line: duplicate-set-field
_ENV.loadfile = function(path, ...)
    local loader = package.bundleLoader[path]
    if loader ~= nil and loader.loader ~= nil then
        return loader.loader
    else
        return originalLoadFile(path, ...)
    end
end

local loaderLineOffset = -2
---Error handler for xpcall
---@param err any
---@return any
local errorHandler = function(err)
    local srcName = debug.getinfo(1).short_src:gsub("[^%w]", "%%%0")
    local pattern = srcName .. ":(%d+):"

    local message = debug.traceback(err, 2):gsub(pattern, function(line)
        local lineNumber = tonumber(line)

        local loaderLine = -1
        local loaderName = nil
        for name, loader in pairs(package.bundleLoader) do
            if loader.line ~= nil and loaderLine < loader.line and loader.line < lineNumber then
                loaderLine = loader.line
                loaderName = name
            end
        end

        return loaderName .. ":" .. (lineNumber - loaderLine + loaderLineOffset) .. ":"
    end)

    return message
end

local fallbackStderr = __NEBLUA_FALLBACK_STDERR__

local result = table.pack(xpcall(require, errorHandler, __NEBLUA_ENTRY__, ...))
local success = result[1]
-- print error to stdout and re-throw
if not success then
    if fallbackStderr then
        print(result[2])
    else
        io.stderr:write(result[2])
    end
    error("Error occurred in bundled file.")
end

return table.unpack(result, 2)
