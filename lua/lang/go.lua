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
    group = vim.api.nvim_create_augroup("GoSettings", { clear = true }),
    pattern = "go",
    callback = function()
      vim.opt_local.expandtab = false
      vim.opt_local.shiftwidth = 8
      vim.opt_local.tabstop = 8
      vim.opt_local.colorcolumn = "120"

      map("<localleader>i", function()
        vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
      end, "Organize imports")
      map("<localleader>t", '<cmd>TermExec cmd="go test ./..."<cr>', "Go test")
      map("<localleader>b", '<cmd>TermExec cmd="go build ./..."<cr>', "Go build")
      map("<localleader>r", '<cmd>TermExec cmd="go run ."<cr>', "Go run")
    end,
  })
end

function M.setup_lsp(capabilities, on_attach)
  vim.lsp.config("gopls", {
    cmd = { "gopls" },
    filetypes = { "go", "gomod", "gowork", "gotmpl" },
    root_markers = { "go.work", "go.mod", ".git" },
    capabilities = capabilities,
    on_attach = on_attach,
    settings = {
      gopls = {
        analyses = {
          unusedparams = true,
          shadow = true,
        },
        staticcheck = true,
        gofumpt = true,
        usePlaceholders = true,
        completeUnimported = true,
        hints = {
          assignVariableTypes = true,
          compositeLiteralFields = true,
          compositeLiteralTypes = true,
          constantValues = true,
          functionTypeParameters = true,
          parameterNames = true,
          rangeVariableTypes = true,
        },
      },
    },
  })

  vim.lsp.enable("gopls")
end

return M
