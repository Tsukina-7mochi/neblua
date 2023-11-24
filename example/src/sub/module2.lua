require("./module1")

print("sub/module2 loaded")
print("args: " .. table.concat({ ... }, ", "))

return "module2"
