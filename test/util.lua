---Checks if given file is readable
---@param filename string
---@return boolean
local function fileReadable(filename)
    local file = io.open(filename, "r")
    if file == nil then
        return false
    end
    file:close()
    return true
end

---Changes directory
---@param path string
local function changeDir(path)
    local success = os.execute("cd " .. path)
    if not success then
        error("Could not change directory to " .. path)
    end
end

---Execute given lua file
---@param filename string
---@param redirectStderr boolean?
---@return string stdout
local function execute(filename, redirectStderr)
    local command = "lua " .. filename
    if redirectStderr == true then
        command = command .. " 2>&1"
    end

    local file = assert(io.popen(command, "r"))
    if file == nil then
        return ""
    end

    local output = file:read("*a")
    file:close()

    output = output:gsub("^%s*(.-)%s*$", "%1")

    return output
end

return {
    fileReadable = fileReadable,
    changeDir = changeDir,
    execute = execute
}
