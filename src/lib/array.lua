---collects all values yielded by an iterator function into a table.
---@generic T
---@param func fun(): T
---@return T[]
local function collect (func)
    local result = {}

    for v in func do
        table.insert(result, v)
    end

    return result
end

---@generic T
---@param array T[]
---@param predicate fun(value: T): boolean
---@return T[]
local function filter (array, predicate)
    local result = {}
    for _, v in ipairs(array) do
        if predicate(v) then
            table.insert(result, v)
        end
    end
    return result
end

---@generic T
---@param array T[]
---@param value T
---@return boolean
local function includes (array, value)
    for _, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

return {
    collect = collect,
    filter = filter,
    includes = includes,
}
