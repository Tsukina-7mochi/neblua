local function render (filename, text)
    local result = ([[package.loaded["%s"] = %q]])
        :format(filename, text)
        :gsub("\\\n", "\\n")
    return result
end

return {
    render = render,
}
