local function render (filename, functionBody)
    return ([[
package.bundleLoader["%s"] = {
    line = debug.getinfo(1).currentline,
    loader = function(...)

%s

    end
}
]]):format(filename, functionBody)
end

return {
    render = render,
}
