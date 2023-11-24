require("module1")
require("/module2")
require("./sub.module1")
require("sub.module2")

local loaded = {}
for k, _ in pairs(package.loaded) do
    loaded[#loaded + 1] = k
end

print(table.concat(loaded, ","))
