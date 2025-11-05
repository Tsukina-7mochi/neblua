local array = require("src.lib.array")

---@param str string
---@param sep string
---@return string[]
local function split (str, sep)
    return array.collect(str:gmatch("([^" .. sep .. "]*)"))
end

local separator = package.config:sub(1, 1)

---@param path string
---@return string
local function baseName (path)
    local segments = split(path, separator)
    return segments[#segments]
end

---@param path string
---@return string
local function extName (path)
    ---@type string
    local baseName = baseName(path)
    local extStart, extEnd = baseName:find("%.[^%.]*$")
    if extStart == nil then
        return ""
    else
        return baseName:sub(extStart, extEnd)
    end
end

---@param path string
---@return string
local function noExtName (path)
    ---@type string
    local baseName = baseName(path)
    local extStart = baseName:find("%.")
    if extStart == nil then
        return baseName
    else
        return baseName:sub(1, extStart - 1)
    end
end

---@param path string
---@return string
local function normalize (path)
    local segments = split(path, separator)

    local idx = 2
    while idx <= #segments do
        if segments[idx] == "" or segments[idx] == "." then
            table.remove(segments, idx)
        else
            idx = idx + 1
        end
    end

    idx = 1
    while idx <= #segments do
        if
            segments[idx] == ".."
            and idx > 1
            and (segments[idx - 1] ~= ".." and segments[idx - 1] ~= "")
        then
            table.remove(segments, idx)
            table.remove(segments, idx - 1)
            idx = idx - 1
        else
            idx = idx + 1
        end
    end

    if #segments == 0 then
        return "."
    elseif #segments == 1 and segments[1] == "" then
        return separator
    end

    if segments[1] ~= "" and segments[1] ~= "." and segments[1] ~= ".." then
        table.insert(segments, 1, ".")
    end

    return table.concat(segments, separator)
end

---@param ... string
---@return string
local function join (...)
    return normalize(table.concat({ ... }, separator))
end

return {
    separator = separator,

    baseName = baseName,
    extName = extName,
    noExtName = noExtName,

    normalize = normalize,
    join = join,
}
