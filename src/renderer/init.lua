local luaRenderer = require("src.renderer.luaModule")
local requireText = require("src.requireText")
local textRenderer = require("src.renderer.textModule")

local template = requireText("src.renderer.templates.template")
local templatePatterns = {
    entry = "__NEBLUA_ENTRY__",
    fallbackStderr = "__NEBLUA_FALLBACK_STDERR__",
    modulesDefinition = "--%[%[__NEBLUA_SLOT__%]%]",
}

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
        return luaRenderer.render(module.path, module.content)
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

    local result = template
        :gsub(templatePatterns.entry, '"' .. rawGsubRepl(options.entry) .. '"')
        :gsub(templatePatterns.fallbackStderr, tostring(options.fallbackStderr))
        :gsub(
            templatePatterns.modulesDefinition,
            rawGsubRepl(table.concat(renderedModules, "\n"))
        )

    return result
end

return {
    render = render,
}
