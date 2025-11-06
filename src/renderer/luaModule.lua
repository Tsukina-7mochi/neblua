local function render (registry, filename, functionBody)
    return ([[
%s["%s"] = {
    line = debug.getinfo(1).currentline,
    loader = function(...)
%s
    end
}
]]):format(registry, filename, functionBody)
end

return {
    render = render,
}
