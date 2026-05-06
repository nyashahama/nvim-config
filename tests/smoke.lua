vim.opt.runtimepath:prepend(vim.fn.getcwd())
dofile("init.lua")

local expected_modules = {
  "core.options",
  "core.keymaps",
  "core.autocmds",
  "core.commands",
  "lang.cpp",
  "lang.go",
  "lang.rust",
  "plugins",
  "plugins.ui",
  "plugins.navigation",
  "plugins.editing",
  "plugins.lsp",
  "plugins.dap",
}

for _, module in ipairs(expected_modules) do
  assert(package.loaded[module] ~= nil, string.format("expected module %q to load", module))
end

assert(vim.g.mapleader == " ", "leader should be <Space>")
assert(vim.g.maplocalleader == ",", "localleader should be comma")

local function has_normal_map(lhs)
  return vim.fn.maparg(lhs, "n") ~= ""
end

assert(has_normal_map("<C-p>"), "expected <C-p> file finder mapping")
assert(has_normal_map("<leader>ff"), "expected <leader>ff file finder mapping")
assert(has_normal_map("<leader>sg"), "expected <leader>sg live grep mapping")
assert(has_normal_map("<leader>xq"), "expected <leader>xq quickfix mapping")

vim.cmd("enew")
vim.cmd("setfiletype go")
assert(vim.bo.expandtab == false, "go buffers should use tabs")
assert(vim.fn.maparg(",t", "n") ~= "", "expected Go test localleader mapping")

vim.cmd("enew")
vim.cmd("setfiletype cpp")
assert(vim.bo.expandtab == true, "C++ buffers should use spaces")
assert(vim.b.cpp_std ~= nil, "expected detected C++ standard")
assert(vim.fn.maparg(",h", "n") ~= "", "expected C++ header/source localleader mapping")

vim.cmd("enew")
vim.cmd("setfiletype rust")
assert(vim.bo.shiftwidth == 4, "Rust buffers should use four spaces")
assert(vim.fn.maparg(",r", "n") ~= "", "expected Rust runnables localleader mapping")
