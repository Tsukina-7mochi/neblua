---Opens a file and returns its content as a string.
---@param filename string
---@return string? content
---@return string? errmsg
local function getContent (filename)
    local file, err = io.open(filename, "r")
    if file == nil then
        return nil, err
    end

    local content = file:read("a")
    file:close()

    return content
end

return {
    getContent = getContent,
}
