local loader = require("src.loader")
local renderer = require("src.renderer.init")
local resolver = require("src.resolver")

---@param type "lua" | "text"
---@param specifier string
---@param pathTemplates string
---@param rootDir string
---@param ignorePatterns string[]
---@return ResolverResult?
---@return string? errmsg
local function resolveBasedOnType (
    type,
    specifier,
    pathTemplates,
    rootDir,
    ignorePatterns
)
    if type == "lua" then
        return resolver.resolveModule(
            specifier,
            pathTemplates,
            rootDir,
            ignorePatterns
        )
    elseif type == "text" then
        return resolver.resolvePath(specifier, rootDir, ignorePatterns)
    end

    return nil, "internal error: unknown module type: " .. tostring(type)
end

---@param options BundleOptions
local function bundle (options)
    local verbosePrint = function (...)
        if options.verbose == true then
            print(...)
        end
    end

    verbosePrint("Root  : " .. options.rootDir)
    verbosePrint("Entry : " .. options.entry)
    verbosePrint("Output: " .. options.output)

    ---@type ModuleSpec[]
    local modulesToLoad = {}
    ---@type Module[]
    local loadedModules = {}

    -- load entry module
    local resolvedEntry, err = resolver.resolveModule(
        options.entry,
        package.path,
        options.rootDir,
        options.exclude
    )

    if err then
        error("Failed to resolve entry module: " .. err)
    elseif resolvedEntry ~= nil then
        table.insert(modulesToLoad, {
            type = "lua",
            path = resolvedEntry.path,
            filepath = resolvedEntry.filepath,
        })
    end

    -- Add included modules to queue
    for _, spec in pairs(options.include) do
        local resolved, err =
            resolver.resolvePath(spec.path, options.rootDir, options.exclude)

        if err or resolved == nil then
            -- stylua: ignore
            error("Failed to resolve included module '" .. spec.path .. "': " .. err)
        end

        table.insert(modulesToLoad, {
            type = spec.type,
            path = resolved.path,
            filepath = resolved.filepath,
        })
    end

    while #modulesToLoad > 0 do
        ---@type ModuleSpec
        local spec = table.remove(modulesToLoad, 1)

        -- skip if already loaded
        for _, loaded in pairs(loadedModules) do
            if loaded.path == spec.path then
                goto continue
            end
        end

        local result, err = loader.loadAsIs(spec.filepath, spec.type)
        if err or result == nil then
            error("Failed to load module '" .. spec.path .. "': " .. err)
        end

        table.insert(loadedModules, {
            type = spec.type,
            path = spec.path,
            filepath = spec.filepath,
            content = result.content,
        })

        verbosePrint("Loaded " .. spec.path)

        -- resolve and queue imports
        for _, import in pairs(result.imports) do
            local resolved, err = resolveBasedOnType(
                import.type,
                import.name,
                package.path,
                options.rootDir,
                options.exclude
            )
            if err then
                -- stylua: ignore
                error("In " .. spec.path .. ", Failed to resolve module '" .. import.name .. "': " .. err)
            elseif resolved ~= nil then
                table.insert(modulesToLoad, {
                    type = import.type,
                    path = resolved.path,
                    filepath = resolved.filepath,
                })
            end
        end

        ::continue::
    end

    local result = renderer.render(loadedModules, {
        entry = options.entry,
        fallbackStderr = options.fallbackStderr,
    })

    local outputFile = io.open(options.output, "w")
    if outputFile == nil then
        error("Could not open output file: " .. options.output)
    end
    outputFile:write(result)
    outputFile:close()

    verbosePrint("Wrote to " .. options.output)
end

return {
    bundle = bundle,
}
