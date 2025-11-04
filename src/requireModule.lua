local getFileContent = require("src.getFileContent")

---require file as a string
---@param path string
local function requireText (path)
    if package.loaded[path] ~= nil then
        return package.loaded[path]
    end

    package.loaded[path] = getFileContent(path)

    return package.loaded[path]
end

return {
    requireText = requireText,
}
