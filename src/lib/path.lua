local array = require("src.lib.array")

---@param str string
---@param sep string
---@return string[]
local function split (str, sep)
    return array.collect(str:gmatch("([^" .. sep .. "]*)"))
end

local config = split(package.config, "\n")
local separator = config[1]

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
---@param basePath string
---@return string
local function relative (path, basePath)
    local segments = {} --[[ @as string[] ]]
    local resultSegments = {} --[[ @as string[] ]]
    if path:sub(1, 1) == separator then
        segments = split(path, separator)
    else
        local pathSegments = split(path, separator)
        local basePathSegments = split(basePath, separator)
        if
            basePathSegments[#basePathSegments] ~= "."
            and basePathSegments[#basePathSegments] ~= ".."
        then
            table.remove(basePathSegments)
        end

        segments = basePathSegments
        for _, seg in ipairs(pathSegments) do
            table.insert(segments, seg)
        end
    end

    if segments[1] == "." then
        table.insert(resultSegments, ".")
    end
    if segments[1] == "" then
        table.insert(resultSegments, "")
    end

    for _, seg in ipairs(segments) do
        if seg == "." or seg == "" then
            -- Do nothing
        elseif seg == ".." then
            if #resultSegments == 0 then
                table.insert(resultSegments, seg)
            elseif #resultSegments == 1 then
                if resultSegments[1] == "" then
                    error("invalid paths (cannot go above root directory)")
                elseif resultSegments[1] == "." then
                    table.remove(resultSegments)
                    table.insert(resultSegments, seg)
                elseif resultSegments[1] == ".." then
                    table.insert(resultSegments, seg)
                end
            else
                table.remove(resultSegments)
            end
        else
            table.insert(resultSegments, seg)
        end
    end

    if segments[#segments] == "" then
        table.insert(resultSegments, "")
    end

    return table.concat(resultSegments, separator)
end

return {
    separator = separator,
    baseName = baseName,
    extName = extName,
    noExtName = noExtName,
    relative = relative,
}
