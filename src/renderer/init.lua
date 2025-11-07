local luaRenderer = require("src.renderer.luaModule")
local requireText = require("src.requireText")
local textRenderer = require("src.renderer.textModule")

---@class RendererOptions
---@field entry string
---@field fallbackStderr boolean
---@field header? string
---@field preInitCode? string
---@field postInitCode? string
---@field preRunCode? string
---@field postRunCode? string

---@param repl string
---@return string
local function rawGsubRepl (repl)
    local result = repl:gsub("%%", "%%%%")
    return result
end

local initTemplate = requireText("src/renderer/templates/initialization.lua")
local bootstrapTemplate = requireText("src/renderer/templates/bootstrap.lua")
local templatePatterns = {
    registry = "__NEBLUA_REGISTRY__",
    entry = "__NEBLUA_ENTRY__",
    fallbackStderr = "__NEBLUA_FALLBACK_STDERR__",
    header = "%-%-%[%[ slot: header %]%]",
    preInit = "%-%-%[%[ slot: pre%-init %]%]",
    postInit = "%-%-%[%[ slot: post%-init %]%]",
    preRun = "%-%-%[%[ slot: pre%-run %]%]",
    postRun = "%-%-%[%[ slot: post%-run %]%]",
}
local registryName = "package.nebluaModule"

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
        :gsub(templatePatterns.header, tostring(options.header))
        :gsub(templatePatterns.preInit, tostring(options.preInitCode))
        :gsub(templatePatterns.postInit, tostring(options.postInitCode))

    local bootstrap = bootstrapTemplate
        :gsub(templatePatterns.registry, rawGsubRepl(registryName))
        :gsub(templatePatterns.entry, '"' .. rawGsubRepl(options.entry) .. '"')
        :gsub(templatePatterns.fallbackStderr, tostring(options.fallbackStderr))
        :gsub(templatePatterns.preRun, tostring(options.preRunCode))
        :gsub(templatePatterns.postRun, tostring(options.postRunCode))

    return table.concat({
        preload,
        table.concat(renderedModules, "\n"),
        bootstrap,
    }, "\n")
end

return {
    render = render,
}
