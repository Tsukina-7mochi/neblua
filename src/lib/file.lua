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

---Returns whether a file is readable.
---@param filename string
---@return boolean
---@return string?
local function isReadable (filename)
    local file, err = io.open(filename, "r")
    if file == nil then
        return false, err
    end

    file:close()

    return true, nil
end

return {
    getContent = getContent,
    isReadable = isReadable,
}
