local M = {}

local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, {
    noremap = true,
    silent = true,
    buffer = true,
    desc = desc,
  })
end

function M.detect_standard()
  local compile_commands = vim.fn.findfile("compile_commands.json", ".;")
  if compile_commands ~= "" then
    local ok, data = pcall(vim.fn.json_decode, vim.fn.readfile(compile_commands))
    if ok and data[1] and data[1].command then
      local std = data[1].command:match("-std=c%+%+(%d+)")
      if std then
        return "c++" .. std
      end
    end
  end

  local cmake_file = vim.fn.findfile("CMakeLists.txt", ".;")
  if cmake_file ~= "" then
    local content = table.concat(vim.fn.readfile(cmake_file), "\n")
    local std = content:match("CMAKE_CXX_STANDARD%s+(%d+)")
    if std then
      return "c++" .. std
    end

    for _, pattern in ipairs({ "c%+%+_std_(%d+)", "cxx_std_(%d+)" }) do
      std = content:match(pattern)
      if std then
        return "c++" .. std
      end
    end
  end

  return "c++20"
end

function M.setup()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("CppSettings", { clear = true }),
    pattern = { "cpp", "c", "h", "hpp", "cc", "hh" },
    callback = function()
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
      vim.opt_local.colorcolumn = "120"
      vim.opt_local.commentstring = "// %s"
      vim.b.cpp_std = M.detect_standard()

      map("<localleader>h", "<cmd>ClangdSwitchSourceHeader<cr>", "Switch header/source")
      map("<localleader>t", "<cmd>ClangdTypeHierarchy<cr>", "Type hierarchy")
      map("<localleader>s", "<cmd>ClangdSymbolInfo<cr>", "Symbol info")
      map("<localleader>m", "<cmd>ClangdMemoryUsage<cr>", "Clangd memory usage")
    end,
  })
end

function M.setup_lsp(capabilities, on_attach)
  vim.lsp.config("clangd", {
    cmd = {
      "clangd",
      "--background-index",
      "--clang-tidy",
      "--header-insertion=iwyu",
      "--completion-style=detailed",
      "--function-arg-placeholders",
      "--fallback-style=llvm",
      "--enable-config",
    },
    filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
    root_markers = {
      "compile_commands.json",
      "compile_flags.txt",
      ".clangd",
      ".git",
      "CMakeLists.txt",
      "Makefile",
    },
    capabilities = capabilities,
    on_attach = on_attach,
  })

  vim.lsp.enable("clangd")
end

function M.create_clangd_config()
  local clangd_config = string.format([[
CompileFlags:
  Add:
    - "-std=%s"
    - "-Wall"
    - "-Wextra"
    - "-Wpedantic"
  CompilationDatabase: .

Diagnostics:
  UnusedIncludes: Strict
  MissingIncludes: Strict
]], M.detect_standard())

  vim.fn.writefile(vim.split(clangd_config, "\n"), ".clangd")
  vim.notify("Created .clangd configuration with " .. M.detect_standard(), vim.log.levels.INFO)
end

return M
