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
---@param stdin string
---@return string stdout
---@return string stderr
local function execute(filename, stdin)
    local stdoutFilename = os.tmpname()
    local stderrFilename = os.tmpname()

    local command = "lua " .. filename .. " 1>" .. stdoutFilename .. " 2>" .. stderrFilename

    local file = assert(io.popen(command, "w"))
    if file == nil then
        error("Failed to execute command: " .. command)
    end

    assert(file:write(stdin))
    file:close()

    local stdoutFile = assert(io.open(stdoutFilename, "r"))
    local stdout = stdoutFile:read("*a")
    stdoutFile:close()

    local stderrFile = assert(io.open(stderrFilename, "r"))
    local stderr = stderrFile:read("*a")
    stderrFile:close()

    return stdout, stderr
end

return {
    fileReadable = fileReadable,
    changeDir = changeDir,
    execute = execute
}
