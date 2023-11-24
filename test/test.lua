---@alias test { name: string, func: function }
---@alias testContext { context: true, name: string, fullName: string, depth: number, tests: (test | testContext)[] }
---@type testContext[]
_ENV.tests = {}

---@type testContext | nil
_ENV.testContext = nil

---Make text green in console
---@param text string
local textGreen = function(text)
    return "\x1b[32m" .. text .. "\x1b[0m"
end

---Make text red in console
---@param text string
local textRed = function(text)
    return "\x1b[31m" .. text .. "\x1b[0m"
end

---@param name string
---@param func function
---@param ctx testContext | nil
local runTest = function(name, func, ctx)
    local logLevel = 0
    local fullName = name
    if ctx ~= nil then
        logLevel = ctx.depth + 1
        fullName = ctx.fullName .. " > " .. name
    end
    local indents = ("  "):rep(logLevel)

    local success, message = pcall(func)

    if ctx == nil then
        if success then
            io.stdout:write(indents .. textGreen("✓ ") .. name .. "\n")
        else
            io.stdout:write(indents .. textRed("✗ ") .. name .. "\n")
            io.stderr:write(textRed(message) .. "\n")
        end
    end

    return success, message
end

---@param ctx testContext
---@param parentCtx testContext | nil
local function runTestContext(ctx, parentCtx)
    local indents = ("  "):rep(ctx.depth)

    local numSuccess = 0
    ---@type ({ fullName: string, message: string })[]
    local failures = {}
    local outputs = { "" }
    for _, test in ipairs(ctx.tests) do
        if test.context then
            local success, childFailures, childOutputs = runTestContext(test --[[@as testContext]], ctx)
            if success then
                numSuccess = numSuccess + 1
            else
                for _, f in ipairs(childFailures) do
                    failures[#failures + 1] = f
                end
            end
            for _, o in ipairs(childOutputs) do
                outputs[#outputs + 1] = o
            end
        else
            local success, message = runTest(test.name, test.func, ctx)
            if success then
                numSuccess = numSuccess + 1
                outputs[#outputs + 1] = indents .. "  " .. textGreen("✓ ") .. test.name
            else
                failures[#failures + 1] = {
                    fullName = ctx.name .. " > " .. test.name,
                    message = message
                }
                outputs[#outputs + 1] = indents .. "  " .. textRed("✗ ") .. test.name
            end
        end
    end

    if numSuccess == #ctx.tests then
        outputs[1] = indents .. textGreen("✓ ")
    else
        outputs[1] = indents .. textRed("✗ ")
    end
    outputs[1] = outputs[1] .. ctx.name .. " (" .. numSuccess .. "/" .. #ctx.tests .. ")"

    if parentCtx == nil then
        for _, o in ipairs(outputs) do
            print(o)
        end

        for _, f in ipairs(failures) do
            print()
            print(textRed("in " .. f.fullName))
            print(textRed(f.message))
        end
    end

    return numSuccess == #ctx.tests, failures, outputs
end

---@param name string
---@param func function
local test = function(name, func)
    local ctx = _ENV.testContext
    -- top-level test
    if ctx == nil then
        runTest(name, func, nil)
        return
    end

    ctx.tests[#ctx.tests + 1] = { name = name, func = func }
end

---@param name string
---@param func function
local describe = function(name, func)
    local parentCtx = _ENV.testContext

    ---@type testContext
    local ctx = {
        context = true,
        name = name,
        fullName = name,
        depth = 0,
        tests = {},
    }
    if parentCtx ~= nil then
        ctx.fullName = parentCtx.name .. " > " .. name
        ctx.depth = parentCtx.depth + 1
        parentCtx.tests[#parentCtx.tests + 1] = ctx
    end

    _ENV.testContext = ctx
    func()
    _ENV.testContext = parentCtx

    if parentCtx == nil then
        runTestContext(ctx, nil)
    end
end

---@param val any
local toDebugString = function(val)
    if type(val) == "string" then
        return "\"" .. val .. "\""
    else
        return tostring(val)
    end
end

---@param expectation any
---@param expected any
local expectToBe = function(expectation, expected)
    if expectation.value ~= expected then
        error(table.concat({
            "expected ",
            toDebugString(expectation.value),
            " to be ",
            toDebugString(expected)
        }), 2)
    end
end

---@param expectation any
---@param lambda fun(value: any): boolean
local expectTo = function(expectation, lambda)
    if not lambda(expectation.value) then
        error(table.concat({
            "expected ",
            toDebugString(expectation.value),
            " to pass given condition"
        }), 2)
    end
end

---@class Expectation
---@field value any
---@field toBe fun(expectation: Expectation, expected: any) expect expectation value to be expected value
---@field to fun(expectation: Expectation, lambda: function) expect expectation value to pass given condition
local expectationMeta = {
    __index = {
        toBe = expectToBe,
        to = expectTo,
    }
}

---@param actual any
---@return Expectation
local expect = function(actual)
    local expectation = {
        value = actual
    }
    setmetatable(expectation, expectationMeta)

    return expectation
end

return {
    test = test,
    describe = describe,
    expect = expect,
}
