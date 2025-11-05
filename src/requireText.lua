local file = require("src.lib.file")
local resolver = require("src.resolver")

---require file as a string
---@param moduleName string
---@return string
local function requireText (moduleName)
    if package.loaded[moduleName] ~= nil then
        return package.loaded[moduleName]
    end

    local resolved = assert(resolver.resolvePath(moduleName, ".", {}, {}))
    local content = assert(file.getContent(resolved.path))

    package.loaded[moduleName] = content

    return package.loaded[moduleName]
end

return requireText
