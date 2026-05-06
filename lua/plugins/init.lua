local specs = {}

local function extend(module)
  for _, spec in ipairs(require(module)) do
    table.insert(specs, spec)
  end
end

extend("plugins.ui")
extend("plugins.navigation")
extend("plugins.editing")
extend("plugins.lsp")
extend("plugins.dap")

return specs
