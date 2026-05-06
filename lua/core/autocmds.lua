local M = {}

function M.setup()
  local format_group = vim.api.nvim_create_augroup("AutoFormat", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = format_group,
    pattern = { "*.c", "*.h", "*.cpp", "*.hpp", "*.cc", "*.hh", "*.go", "*.rs" },
    callback = function()
      local bufnr = vim.api.nvim_get_current_buf()
      if #vim.lsp.get_clients({ bufnr = bufnr }) == 0 then
        return
      end

      pcall(function()
        vim.lsp.buf.format({
          async = false,
          timeout_ms = 2000,
          bufnr = bufnr,
        })
      end)
    end,
  })

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("YankHighlight", { clear = true }),
    pattern = "*",
    callback = function()
      vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
  })

  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("AutoCreateDir", { clear = true }),
    callback = function(event)
      if event.match:match("^%w%w+://") then
        return
      end

      local file = vim.uv.fs_realpath(event.match) or event.match
      vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
  })

  vim.api.nvim_create_autocmd("TermOpen", {
    group = vim.api.nvim_create_augroup("TerminalSettings", { clear = true }),
    callback = function()
      vim.opt_local.number = false
      vim.opt_local.relativenumber = false
      vim.opt_local.signcolumn = "no"
    end,
  })

  vim.api.nvim_create_autocmd("BufReadPost", {
    group = vim.api.nvim_create_augroup("LastLocation", { clear = true }),
    callback = function()
      local mark = vim.api.nvim_buf_get_mark(0, '"')
      local line_count = vim.api.nvim_buf_line_count(0)
      if mark[1] > 0 and mark[1] <= line_count then
        pcall(vim.api.nvim_win_set_cursor, 0, mark)
      end
    end,
  })
end

M.setup()

return M
