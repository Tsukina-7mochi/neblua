local function luaModule(filename, functionBody)
    return ([[
package.bundleLoader["%s"] = {
    line = debug.getinfo(1).currentline,
    loader = function(...)

%s

    end
    }
]]):format(filename, functionBody)
end

local function textModule(filename, text)
    local result = ([[package.loaded["%s"] = %q]])
        :format(filename, text)
        :gsub("\\\n", "\\n")
    return result
end

return {
    luaModule = luaModule,
    textModule = textModule,
}
