local M = {}

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, {
    noremap = true,
    silent = true,
    buffer = true,
    desc = desc,
  })
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("RustSettings", { clear = true }),
    pattern = "rust",
    callback = function()
      vim.opt_local.shiftwidth = 4
      vim.opt_local.tabstop = 4
      vim.opt_local.softtabstop = 4
      vim.opt_local.expandtab = true
      vim.opt_local.colorcolumn = "100"

      map("<localleader>r", "<cmd>RustLsp runnables<cr>", "Rust runnables")
      map("<localleader>d", "<cmd>RustLsp debuggables<cr>", "Rust debuggables")
      map("<localleader>e", "<cmd>RustLsp expandMacro<cr>", "Expand macro")
      map("<localleader>c", "<cmd>RustLsp openCargo<cr>", "Open Cargo.toml")
      map("<localleader>p", "<cmd>RustLsp parentModule<cr>", "Go to parent module")
    end,
  })
end

function M.setup_lsp(capabilities, on_attach)
  vim.g.rustaceanvim = {
    server = {
      on_attach = on_attach,
      capabilities = capabilities,
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = true,
          check = { command = "clippy" },
          cargo = { allFeatures = true },
          inlayHints = {
            bindingModeHints = { enable = true },
            closureReturnTypeHints = { enable = "always" },
            lifetimeElisionHints = { enable = "skip_trivial" },
          },
        },
      },
    },
  }

  pcall(vim.lsp.enable, "rust_analyzer", false)
end

return M
