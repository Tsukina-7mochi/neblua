local file = require("src.lib.file")

---require file as a string
---@param path string
local function requireText (path)
    if package.loaded[path] ~= nil then
        return package.loaded[path]
    end

    local content, err = file.getContent(path)
    if err then
        error("[neblua] Error loading text file '" .. path .. "': " .. err)
    end

    package.loaded[path] = content

    return package.loaded[path]
end

return requireText
