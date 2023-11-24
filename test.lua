local describe = require("test.test").describe

local doUnitTests = #arg == 0
local doBundleTests = #arg == 0
for _, val in ipairs(arg) do
    if val == "unit" then
        doUnitTests = true
    elseif val == "bundle" then
        doBundleTests = true
    end
end

describe("all tests", function()
    if doUnitTests then
        describe("unit tests", function()
            loadfile("test/unit/bundle/path.test.lua")()
            loadfile("test/unit/bundle/split.test.lua")()
        end)
    end

    if doBundleTests then
        describe("bundle tests", function()
            loadfile("test/bundle/bundle.test.lua")()
        end)
    end
end)
