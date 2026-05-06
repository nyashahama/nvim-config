-- Systems Programming Neovim Configuration
-- Optimized for C++, Go, and Rust development.

local ver = vim.version()
if ver.major == 0 and ver.minor < 11 then
  vim.api.nvim_echo({ { "This configuration requires Neovim 0.11 or newer", "ErrorMsg" } }, true, {})
  return
end

vim.g.mapleader = " "
vim.g.maplocalleader = ","
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })

require("core.options")
require("core.keymaps")
require("lang.cpp").setup()
require("lang.go").setup()
require("lang.rust").setup()
require("core.lazy")
require("core.autocmds")
require("core.commands")
