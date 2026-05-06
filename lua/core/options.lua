local M = {}

local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, "p")
  end
end

function M.setup()
  vim.opt.foldenable = false
  vim.opt.foldmethod = "manual"
  vim.opt.foldlevelstart = 99

  vim.opt.scrolloff = 8
  vim.opt.wrap = false
  vim.opt.signcolumn = "yes"
  vim.opt.relativenumber = true
  vim.opt.number = true
  vim.opt.splitright = true
  vim.opt.splitbelow = true
  vim.opt.undofile = true
  vim.opt.wildmode = "list:longest"
  vim.opt.ignorecase = true
  vim.opt.smartcase = true
  vim.opt.visualbell = true
  vim.opt.colorcolumn = "120"
  vim.opt.listchars = "tab:▸ ,nbsp:¬,extends:»,precedes:«,trail:•"
  vim.opt.clipboard = "unnamedplus"
  vim.opt.updatetime = 250
  vim.opt.timeoutlen = 300
  vim.opt.cursorline = true
  vim.opt.termguicolors = true

  vim.opt.swapfile = true
  vim.opt.directory = vim.fn.stdpath("state") .. "/swap//"
  vim.opt.backupdir = vim.fn.stdpath("state") .. "/backup//"

  ensure_dir(vim.fn.stdpath("state") .. "/swap")
  ensure_dir(vim.fn.stdpath("state") .. "/backup")

  vim.opt.shiftwidth = 2
  vim.opt.softtabstop = 2
  vim.opt.tabstop = 2
  vim.opt.expandtab = true
end

M.setup()

return M
