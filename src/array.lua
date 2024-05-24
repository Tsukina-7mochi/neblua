---@generic T
---@param array T[]
---@param value T
---@return boolean
local function includes(array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

---@generic T
---@param array T[]
---@param predicate fun(value: T): boolean
---@return T[]
local function filter(array, predicate)
    local result = {}
    for _, v in ipairs(array) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

return {
    includes = includes,
    filter = filter
}
