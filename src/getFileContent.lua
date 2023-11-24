---Gets the content of a file as a string
---@param filename string
---@return string
local function getFileContent(filename)
    local file, err = io.open(filename, "r")
    if file == nil then
        error("[neblua] Could not open file " .. filename .. ": " .. err)
    end

    local content = file:read("a")
    file:close()

    return content
end

return getFileContent
