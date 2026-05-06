local M = {}

function M.setup()
  vim.api.nvim_create_user_command("CreateClangdConfig", function()
    require("lang.cpp").create_clangd_config()
  end, {
    desc = "Create .clangd configuration file",
  })

  vim.api.nvim_create_user_command("LspInfo", function()
    local bufnr = vim.api.nvim_get_current_buf()
    local clients = vim.lsp.get_clients({ bufnr = bufnr })

    if #clients == 0 then
      vim.notify("No LSP clients attached", vim.log.levels.INFO)
      return
    end

    local info = {}
    for _, client in ipairs(clients) do
      table.insert(info, string.format("- %s (id: %d)", client.name, client.id))
    end

    vim.notify("Active LSP clients:\n" .. table.concat(info, "\n"), vim.log.levels.INFO)
  end, {
    desc = "Show active LSP clients",
  })
end

M.setup()

return M
