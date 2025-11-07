__NEBLUA_REGISTRY__[debug.getinfo(1).short_src] = {
    line = 0,
    loader = nil,
}

local internalPathSeparator = "/"
local pathSeparator = package.config:sub(1, 1)
local templateSeparator = package.config:sub(3, 3)
local substitutionPoint = package.config:sub(5, 5)

local function split (str, sep)
    return str:gmatch("([^" .. sep .. "]*)")
end

local function collect (func)
    local result = {}
    for v in func do
        table.insert(result, v)
    end
    return result
end

local function normalizePath (path)
    local segments = collect(split(path, internalPathSeparator))
    local resultSegments = {}

    if segments[1] == "." then
        table.insert(resultSegments, ".")
    elseif segments[1] == "" then
        table.insert(resultSegments, "")
    elseif segments[1] == ".." then
        error("Cannot go above root directory")
    end

    for _, seg in ipairs(segments) do
        if seg == ".." then
            table.remove(resultSegments)
        elseif seg ~= "." and seg ~= "" then
            table.insert(resultSegments, seg)
        end
    end

    if segments[#segments] == "" then
        table.insert(resultSegments, "")
    end

    return table.concat(resultSegments, internalPathSeparator)
end

-- searches for modules in package.nebluaModule table
local function bundlerSearcher (moduleName)
    moduleName = moduleName:gsub("%.", internalPathSeparator)

    for template in split(package.path, templateSeparator) do
        local path = template
            :gsub(pathSeparator, internalPathSeparator)
            :gsub(substitutionPoint, moduleName)

        local module = package.nebluaModule[normalizePath(path)]
        if module ~= nil and module.loader ~= nil then
            return module.loader, path
        end
    end

    return nil
end

if not _ENV.__NEBLUA_INSTALLED then
    -- Register the bundler searcher at the highest priority
    table.insert(package.searchers, 1, bundlerSearcher)

    -- Replace dofile
    local originalDoFile = dofile
    _ENV.dofile = function (path)
        local loader = package.nebluaModule[path]
        if loader ~= nil and loader.loader ~= nil then
            return loader.loader()
        else
            return originalDoFile(path)
        end
    end

    -- Replace loadfile
    local originalLoadFile = loadfile
    _ENV.loadfile = function (path, ...)
        local loader = package.nebluaModule[path]
        if loader ~= nil and loader.loader ~= nil then
            return loader.loader
        else
            return originalLoadFile(path, ...)
        end
    end
end

_ENV.__NEBLUA_INSTALLED = true

-- Error handler for xpcall
local errorHandler = function (err)
    local srcName = debug.getinfo(1).short_src:gsub("[^%w]", "%%%0")
    local pattern = srcName .. ":(%d+):"
    local loaderLineOffset = -1

    local message = debug.traceback(err, 2):gsub(pattern, function (line)
        local lineNumber = tonumber(line)

        local loaderLine = -1
        local loaderName = nil
        for name, loader in pairs(package.nebluaModule) do
            if
                loader.line ~= nil
                and loaderLine < loader.line
                and loader.line < lineNumber
            then
                loaderLine = loader.line
                loaderName = name
            end
        end

        return loaderName
            .. ":"
            .. (lineNumber - loaderLine + loaderLineOffset)
            .. ":"
    end)

    return message
end

--[[ slot: pre-run ]]

local loader = bundlerSearcher(__NEBLUA_ENTRY__)
if loader == nil then
    error("Cannot find entry point: " .. __NEBLUA_ENTRY__)
end

local result = table.pack(xpcall(loader, errorHandler, __NEBLUA_ENTRY__, ...))
local success = result[1]

--[[ slot: post-run ]]

-- print error to stdout and re-throw
if not success then
    if __NEBLUA_FALLBACK_STDERR__ then
        print(result[2])
    else
        io.stderr:write(result[2])
    end
    error("Error occurred in bundled file.")
end

return table.unpack(result, 2)
