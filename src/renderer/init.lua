local luaRenderer = require("src.renderer.luaModule")
local requireText = require("src.requireText")
local textRenderer = require("src.renderer.textModule")

local initTemplate = requireText("src/renderer/templates/initialization.lua")
local bootstrapTemplate = requireText("src/renderer/templates/bootstrap.lua")
local templatePatterns = {
    registry = "__NEBLUA_REGISTRY__",
    entry = "__NEBLUA_ENTRY__",
    fallbackStderr = "__NEBLUA_FALLBACK_STDERR__",
}
local registryName = "package.nebluaModule"

---@class RendererOptions
---@field entry string
---@field fallbackStderr boolean

---@param repl string
---@return string
local function rawGsubRepl (repl)
    local result = repl:gsub("%%", "%%%%")
    return result
end

---@param module Module
---@return string
local function renderModule (module)
    if module.type == "lua" then
        return luaRenderer.render(registryName, module.path, module.content)
    elseif module.type == "text" then
        return textRenderer.render(module.path, module.content)
    end

    error("internal error: unknown module type: " .. tostring(module.type))
end

---@param modules Module[]
---@param options RendererOptions
---@return string
local function render (modules, options)
    local renderedModules = {}
    for _, module in ipairs(modules) do
        table.insert(renderedModules, renderModule(module))
    end

    local preload = initTemplate
        :gsub(templatePatterns.registry, rawGsubRepl(registryName))
        :gsub(templatePatterns.entry, '"' .. rawGsubRepl(options.entry) .. '"')
        :gsub(templatePatterns.fallbackStderr, tostring(options.fallbackStderr))

    local bootstrap = bootstrapTemplate
        :gsub(templatePatterns.registry, rawGsubRepl(registryName))
        :gsub(templatePatterns.entry, '"' .. rawGsubRepl(options.entry) .. '"')
        :gsub(templatePatterns.fallbackStderr, tostring(options.fallbackStderr))

    return preload
        .. "\n"
        .. table.concat(renderedModules, "\n")
        .. "\n"
        .. bootstrap
end

return {
    render = render,
}
