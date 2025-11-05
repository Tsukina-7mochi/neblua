local path = require("src.lib.path")

---@class PartialBundleOptions
---@field rootDir? string
---@field entry string
---@field include (string | { path: string, type: string })[]
---@field output string
---@field verbose? boolean
---@field exclude? string[]
---@field external? string[]
---@field fallbackStderr? boolean

---@class BundleOptions
---@field rootDir string
---@field entry string
---@field include { path: string, type: "lua" | "text" }[]
---@field output string
---@field verbose boolean
---@field exclude string[]
---@field external string[]
---@field fallbackStderr boolean

---@param options PartialBundleOptions
---@return BundleOptions?
---@return string? errmsg
local function normalize (options)
    if type(options) ~= "table" then
        return nil, "Expected options to be a table"
    end

    local rootDir = options.rootDir
    local entry = options.entry
    local include = options.include
    local output = options.output
    local verbose = options.verbose
    local exclude = options.exclude
    local external = options.external
    local fallbackStderr = options.fallbackStderr

    if rootDir == nil then
        rootDir = "./"
    else
        if type(rootDir) ~= "string" then
            return nil, "Expected options.rootDir to be a string or nil"
        end

        rootDir = path.normalize(rootDir)
    end

    if type(entry) ~= "string" then
        return nil, "Expected options.entry to be a string"
    end
    entry = path.normalize(entry)

    if type(include) ~= "table" then
        return nil, "Expected options.include to be a table"
    end
    for i, file in ipairs(include) do
        if type(file) == "string" then
            include[i] = { path = file, type = "lua" }
        elseif type(file) == "table" then
            if type(file.path) ~= "string" then
                -- stylua: ignore
                return nil, "Expected options.include[" .. i .. "].path to be a string"
            elseif type(file.type) ~= "string" then
                -- stylua: ignore
                return nil,
                    "Expected options.include[" .. i .. '].type to be one of {"lua", "text"}'
            end
        else
            -- stylua: ignore
            return nil, "Expected options.include[" .. i .. "] to be a string or a table"
        end

        include[i].path = path.normalize(include[i].path)
        if include[i].type ~= "lua" and include[i].type ~= "text" then
            -- stylua: ignore
            return nil, "Expected options.include[" .. i .. '].type to be one of {"lua", "text"}'
        end
    end

    if type(output) ~= "string" then
        return nil, "Expected options.output to be a string"
    end
    output = path.normalize(output)

    if verbose ~= nil and type(verbose) ~= "boolean" then
        return nil, "Expected options.verbose to be a string or nil"
    end
    verbose = verbose == true

    if exclude == nil then
        exclude = {}
    elseif type(exclude) == "table" then
        for i, pattern in ipairs(exclude) do
            if type(pattern) ~= "string" then
                -- stylua: ignore
                return nil, "Expected options.include[" .. i .. "].path to be a string"
            end
        end
    else
        return nil, "Expected options.exclude to be a string[]"
    end

    if external == nil then
        external = {}
    elseif type(external) == "table" then
        for i, pattern in ipairs(external) do
            if type(pattern) ~= "string" then
                -- stylua: ignore
                return nil, "Expected options.external[" .. i .. "] to be a string"
            end
        end
    else
        return nil, "Expected options.external to be a string[]"
    end

    if fallbackStderr ~= nil and type(fallbackStderr) ~= "boolean" then
        return nil, "Expected options.fallbackStderr to be a boolean or nil"
    end
    fallbackStderr = fallbackStderr == true

    return {
        rootDir = rootDir,
        entry = entry,
        include = include,
        output = output,
        verbose = verbose,
        exclude = exclude,
        external = external,
        fallbackStderr = fallbackStderr,
    }
end

return {
    normalize = normalize,
}
