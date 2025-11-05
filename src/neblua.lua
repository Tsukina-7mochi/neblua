local bundler = require("src.bundler")
local normalizeBundleOptions = require("src.options").normalize
local requireText = require("src.requireText")

local appInfo = {
    name = "neblua",
    version = requireText("version.txt"),
}

---@param options PartialBundleOptions
local function bundle (options)
    local normalizedOptions, err = normalizeBundleOptions(options)
    if err or normalizedOptions == nil then
        error("Invalid options: " .. err)
    end

    bundler.bundle(normalizedOptions)
end

return {
    bundle = bundle,
    requireText = requireText,
    appInfo = appInfo,
}
