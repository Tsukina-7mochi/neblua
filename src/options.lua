local path = require("src.lib.path")

---@class PartialBundleOptions
---@field rootDir? string
---@field entry string
---@field include? (string | { path: string, type: string })[]
---@field output string
---@field verbose? boolean
---@field exclude? string[]
---@field external? string[]
---@field fallbackStderr? boolean
---@field header? string
---@field preInitCode? string
---@field postInitCode? string
---@field preRunCode? string
---@field postRunCode? string

---@class BundleOptions
---@field rootDir string
---@field entry string
---@field include { path: string, type: "lua" | "text" }[]
---@field output string
---@field verbose boolean
---@field exclude string[]
---@field external string[]
---@field fallbackStderr boolean
---@field header string
---@field preInitCode string
---@field postInitCode string
---@field preRunCode string
---@field postRunCode string

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
    local header = options.header
    local preInitCode = options.preInitCode
    local postInitCode = options.postInitCode
    local preRunCode = options.preRunCode
    local postRunCode = options.postRunCode

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

    if include == nil then
        include = {}
    elseif type(include) == "table" then
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
    else
        return nil, "Expected options.include to be a table"
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

    if header == nil then
        header = ""
    elseif type(header) ~= "string" then
        return nil, "Expected options.header to be a string or nil"
    end

    if preInitCode == nil then
        preInitCode = ""
    elseif type(preInitCode) ~= "string" then
        return nil, "Expected options.preInitCode to be a string or nil"
    end

    if postInitCode == nil then
        postInitCode = ""
    elseif type(postInitCode) ~= "string" then
        return nil, "Expected options.postInitCode to be a string or nil"
    end

    if preRunCode == nil then
        preRunCode = ""
    elseif type(preRunCode) ~= "string" then
        return nil, "Expected options.preRunCode to be a string or nil"
    end

    if postRunCode == nil then
        postRunCode = ""
    elseif type(postRunCode) ~= "string" then
        return nil, "Expected options.postRunCode to be a string or nil"
    end

    return {
        rootDir = rootDir,
        entry = entry,
        include = include,
        output = output,
        verbose = verbose,
        exclude = exclude,
        external = external,
        fallbackStderr = fallbackStderr,
        header = header,
        preInitCode = preInitCode,
        postInitCode = postInitCode,
        preRunCode = preRunCode,
        postRunCode = postRunCode,
    }
end

return {
    normalize = normalize,
}
