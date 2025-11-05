local file = require("src.lib.file")

-- TODO: support long string literals
-- TODO?: support line breaks and \z
local requirePatterns = {
    'require%s*"([^"\r\n]*)"',
    "require%s*'([^\"\r\n]*)'",
    'require%s*%(%s*"([^"\r\n]*)"%s*%)',
    "require%s*%(%s*'([^\"\r\n]*)'%s*%)",
}
local requireTextPatterns = {
    'requireText%s*"([^"\r\n]*)"',
    "requireText%s*'([^\"\r\n]*)'",
    'requireText%s*%(%s*"([^"\r\n]*)"%s*%)',
    "requireText%s*%(%s*'([^\"\r\n]*)'%s*%)",
}

---@class LoaderResult
---@field content string
---@field imports { name: string, type: "lua"|"text" }[]

---@param filepath string
---@param type "lua" | "text"
---@return LoaderResult?
---@return string? errmsg
local function loadAsIs (filepath, type)
    local content, err = file.getContent(filepath)
    if err or content == nil then
        return nil, "Failed to read file: " .. err
    end

    if type == "text" then
        return { content = content, imports = {} }, nil
    end

    local imports = {}

    for _, pattern in ipairs(requirePatterns) do
        for moduleName in content:gmatch(pattern) do
            table.insert(imports, { name = moduleName, type = "lua" })
        end
    end

    for _, pattern in ipairs(requireTextPatterns) do
        for moduleName in content:gmatch(pattern) do
            table.insert(imports, { name = moduleName, type = "text" })
        end
    end

    return { content = content, imports = imports }, nil
end

return {
    loadAsIs = loadAsIs,
}
