local describe = require("lib.test").describe

local doUnitTests = #arg == 0
local doBundleTests = #arg == 0
for _, val in ipairs(arg) do
    if val == "unit" then
        doUnitTests = true
    elseif val == "bundle" then
        doBundleTests = true
    end
end

describe("all tests", function ()
    if doUnitTests then
        describe("unit tests", function ()
            require("test.unit.bundle.path")
            require("test.unit.bundle.split")
        end)
    end

    if doBundleTests then
        describe("bundle tests", function ()
            require("test.bundle.bundle")
        end)
    end
end)
