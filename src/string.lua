---Splits a string by a search string
---@param str string
---@param searchStr string
---@return string[]
local function split(str, searchStr)
    if #str == 0 then
        return { str }
    end

    local result = {}
    local pos = 1

    while true do
        local startPos, endPos = str:find(searchStr, pos)

        if startPos == nil then
            break
        end

        table.insert(result, str:sub(pos, startPos - 1))
        pos = endPos + 1
    end

    if pos <= #str then
        table.insert(result, str:sub(pos))
    else
        table.insert(result, "")
    end

    return result
end

return { split = split }
