require("./module1")

print("module2 loaded")
print("args: " .. table.concat({ ... }, ", "))

return "module2"
