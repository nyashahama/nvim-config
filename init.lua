-- Check for minimum Neovim version (0.12+ compatible)
local ver = vim.version()
if ver.major == 0 and ver.minor < 12 then
  vim.api.nvim_echo({{"This configuration requires Neovim 0.12 or newer", "ErrorMsg"}}, true, {})
  return
end

-- always set leader first!
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "

-------------------------------------------------------------------------------
-- Preferences
-------------------------------------------------------------------------------
-- Never automatic folding
vim.opt.foldenable = false
vim.opt.foldmethod = 'manual'
vim.opt.foldlevelstart = 99

-- UI improvements
vim.opt.scrolloff = 5              -- More context when scrolling
vim.opt.wrap = false               -- No line wrapping
vim.opt.signcolumn = 'yes'         -- Always show sign column
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.number = true              -- Show current line number
vim.opt.splitright = true          -- Vertical splits to the right
vim.opt.splitbelow = true          -- Horizontal splits below
vim.opt.undofile = true            -- Persistent undo history
vim.opt.wildmode = 'list:longest'  -- Better tab completion
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- Case-sensitive when uppercase present
vim.opt.visualbell = true          -- Disable beeping (use visualbell)
vim.opt.colorcolumn = '80'         -- Line length guide
vim.opt.listchars = 'tab:▸ ,nbsp:¬,extends:»,precedes:«,trail:•'
vim.opt.clipboard = 'unnamedplus'  -- Use system clipboard

-- Tab settings (customize per language later)
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true           -- Use spaces by default

-- Language-specific configurations
local lang_group = vim.api.nvim_create_augroup('LangSettings', { clear = true })

-- Rust settings
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = 'rust',
  callback = function()
    vim.opt_local.colorcolumn = '100'  -- Rust's 100-char limit
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
  end
})

-- C/C++ settings (updated for modern C++: wider column, ensure spaces)
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = {'cpp', 'hpp', 'c', 'h'},
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = '120'  -- Wider guide for modern codebases
    
    -- Set C++ standard based on project detection
    local cpp_std = "c++17" -- Default fallback
    
    -- Check for CMakeLists.txt to determine C++ standard
    local cmake_file = vim.fn.findfile("CMakeLists.txt", ".;")
    if cmake_file ~= "" then
      local content = vim.fn.readfile(cmake_file)
      for _, line in ipairs(content) do
        if line:match("CMAKE_CXX_STANDARD") then
          if line:match("20") or line:match("23") then
            cpp_std = "c++20"
          elseif line:match("17") then
            cpp_std = "c++17"
          elseif line:match("14") then
            cpp_std = "c++14"
          end
          break
        end
      end
    end
    
    -- Set buffer-local variable for the standard
    vim.b.cpp_std = cpp_std
    
    -- Add C++-specific keymaps
    local bufopts = { noremap = true, silent = true, buffer = true }
    vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', 
      vim.tbl_extend('force', bufopts, { desc = "Switch Header/Source" }))
    vim.keymap.set('n', '<leader>ct', '<cmd>ClangdTypeHierarchy<cr>', 
      vim.tbl_extend('force', bufopts, { desc = "Type Hierarchy" }))
    vim.keymap.set('n', '<leader>cs', '<cmd>ClangdSymbolInfo<cr>', 
      vim.tbl_extend('force', bufopts, { desc = "Symbol Info" }))
  end
})

-- Go settings
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false   -- Go uses tabs by default
    vim.opt_local.shiftwidth = 8
    vim.opt_local.tabstop = 8
  end
})

-- Dart/Flutter settings
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = 'dart',
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    
    -- Flutter commands
    vim.keymap.set('n', '<leader>fa', '<cmd>FlutterRun<cr>', { buffer = true, desc = "Run Flutter" })
    vim.keymap.set('n', '<leader>fq', '<cmd>FlutterQuit<cr>', { buffer = true, desc = "Quit Flutter" })
    vim.keymap.set('n', '<leader>fr', '<cmd>FlutterHotReload<cr>', { buffer = true, desc = "Hot Reload" })
    vim.keymap.set('n', '<leader>fR', '<cmd>FlutterRestart<cr>', { buffer = true, desc = "Hot Restart" })
    vim.keymap.set('n', '<leader>fe', '<cmd>FlutterEmulators<cr>', { buffer = true, desc = "Show Emulators" })
    vim.keymap.set('n', '<leader>fd', '<cmd>FlutterDevices<cr>', { buffer = true, desc = "Show Devices" })
    vim.keymap.set('n', '<leader>fo', '<cmd>FlutterOutlineToggle<cr>', { buffer = true, desc = "Toggle Outline" })
    vim.keymap.set('n', '<leader>fp', '<cmd>FlutterPubGet<cr>', { buffer = true, desc = "Pub Get" })
    vim.keymap.set('n', '<leader>fc', '<cmd>FlutterCopyProfilerUrl<cr>', { buffer = true, desc = "Copy Profiler URL" })
    vim.keymap.set('n', '<leader>ft', '<cmd>FlutterDevTools<cr>', { buffer = true, desc = "Launch DevTools" })
  end
})

-------------------------------------------------------------------------------
-- Key mappings
-------------------------------------------------------------------------------
-- Enhanced fzf file finder with creation capability
vim.keymap.set('n', '<C-p>', function()
  vim.fn['fzf#run'](vim.fn['fzf#wrap']({
    source = 'find . -type f 2>/dev/null',
    sink = function(selected)
      vim.cmd('edit ' .. vim.fn.fnameescape(selected))
    end,
    ['sink*'] = function(lines)
      local key = lines[1]  -- The key that was pressed
      local selection = lines[2] or ''  -- The current input/selection
      
      if key == 'ctrl-e' then
        -- Ctrl-E was pressed, create new file
        if selection ~= '' then
          local dir = vim.fn.fnamemodify(selection, ':h')
          if dir ~= '.' and dir ~= '' and vim.fn.isdirectory(dir) == 0 then
            local success = vim.fn.mkdir(dir, 'p')
            if success == 0 then
              vim.api.nvim_echo({{"Failed to create directory: " .. dir, "ErrorMsg"}}, true, {})
              return
            end
          end
          vim.cmd('edit ' .. vim.fn.fnameescape(selection))
          -- Force create the file immediately
          vim.cmd('write')
        else
          -- If no input, prompt for filename
          vim.ui.input({ prompt = 'New file: ' }, function(filename)
            if filename and filename ~= '' then
              local dir = vim.fn.fnamemodify(filename, ':h')
              if dir ~= '.' and dir ~= '' and vim.fn.isdirectory(dir) == 0 then
                local success = vim.fn.mkdir(dir, 'p')
                if success == 0 then
                  vim.api.nvim_echo({{"Failed to create directory: " .. dir, "ErrorMsg"}}, true, {})
                  return
                end
              end
              vim.cmd('edit ' .. vim.fn.fnameescape(filename))
              -- Force create the file immediately
              vim.cmd('write')
            end
          end)
        end
      else
        -- Regular selection, open existing file
        if selection ~= '' then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection))
        end
      end
    end,
    options = '--expect=ctrl-e --prompt="Files (Ctrl-E: create)> " --print-query --preview="if [ -f {} ]; then bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null; else echo \'[New file - Press Ctrl-E to create]\'; fi"'
  }))
end, { desc = "Find files with creation option" })

vim.keymap.set('n', '<leader>;', '<cmd>Buffers<cr>')

-- Essential operations
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>')   -- Save
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>')   -- Quit
vim.keymap.set('n', ';', ':')                    -- Faster command mode

-- Clipboard integration (Linux/Mac)
vim.keymap.set('n', '<leader>p', '"+p')          -- Paste from clipboard
vim.keymap.set('n', '<leader>y', '"+y')          -- Yank to clipboard
vim.keymap.set('v', '<leader>y', '"+y')          -- Visual mode yank to clipboard

-- Navigation enhancements
vim.keymap.set('', 'H', '^')                     -- Start of line
vim.keymap.set('', 'L', '$')                     -- End of line
vim.keymap.set('n', '<leader><leader>', '<c-^>') -- Toggle buffers

-- Improved search
vim.keymap.set('n', '<C-h>', '<cmd>nohlsearch<cr>')
vim.keymap.set('n', 'n', 'nzz', { silent = true })
vim.keymap.set('n', 'N', 'Nzz', { silent = true })

-- Escape remaps
vim.keymap.set('i', 'jk', '<Esc>')
vim.keymap.set('v', 'jk', '<Esc>')
vim.keymap.set('t', 'jk', '<C-\\><C-n>')

-------------------------------------------------------------------------------
-- Plugin configuration (using lazy.nvim)
-------------------------------------------------------------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- UI Enhancements
  { "ellisonleao/gruvbox.nvim", priority = 1000, config = true },
  { "itchyny/lightline.vim" },
  { "nvim-tree/nvim-web-devicons", opts = {} },

  -- Navigation & Productivity
  { "ggandor/leap.nvim", config = function() require('leap').add_default_mappings() end },
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim" },
  { "airblade/vim-rooter" },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "lua", "rust", "go", "c", "cpp", "dart" },
        highlight = { enable = true },
      })
    end
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- LSP & Autocompletion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = { "rust_analyzer", "clangd", "gopls" }
    },
    dependencies = {
      { "williamboman/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
    },
    config = function()
      local cmp = require 'cmp'
      cmp.setup({
        sources = {
          { name = 'nvim_lsp' },
          { name = 'path' },
          { name = 'buffer' },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
        }),
        experimental = { ghost_text = true },
      })
    end
  },

  -- Language Support
  { "rust-lang/rust.vim", ft = "rust" },
  { "fatih/vim-go", ft = "go" },
  
  -- Flutter/Dart Support
  {
    "dart-lang/dart-vim-plugin",
    ft = "dart",
    init = function()
      vim.g.dart_style_guide = 2
      vim.g.dart_format_on_save = 1
    end
  },
  {
    "akinsho/flutter-tools.nvim",
    lazy = false,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "stevearc/dressing.nvim", -- Optional for better UI
    },
    config = function()
      -- Will be configured after LSP setup
    end,
  },

  -- Enhanced C++ support
  { "octol/vim-cpp-enhanced-highlight", ft = { "cpp", "c" } },
}, {
  ui = {
    border = "rounded",
  },
})

-- Common LSP on_attach function
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  
  -- Add LSP-based formatting capability
  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, bufopts)
  end
end

-- LSP server configurations
local lspconfig = require 'lspconfig'
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure Flutter Tools first
require("flutter-tools").setup({
  lsp = {
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
      dart = {
        completeFunctionCalls = true,
        showTodos = true,
        analysisExcludedFolders = { vim.fn.expand("$HOME/.pub-cache") },
      }
    }
  },
  dev_log = {
    enabled = true,
    open_cmd = "tabedit",
  },
  widget_guides = {
    enabled = true,
  },
  dev_tools = {
    autostart = false, -- Changed to false to prevent auto-opening
    auto_open_browser = false, -- Changed to false
  },
  debugger = {
    enabled = true,
    run_via_dap = false, -- Changed to false unless you have nvim-dap configured
  },
})

lspconfig.rust_analyzer.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = true,
      check = { command = "clippy" },
    },
  },
})

-- Fixed clangd configuration for modern C++ (conservative approach)
lspconfig.clangd.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  root_dir = require('lspconfig.util').root_pattern(
    'compile_commands.json',
    'compile_flags.txt',
    '.clangd',
    '.git',
    'CMakeLists.txt',
    'Makefile'
  ),
})

lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    gopls = { 
      analyses = { unusedparams = true }, 
      staticcheck = true,
      gofumpt = true,
    },
  },
})

-- Don't configure dartls separately if using flutter-tools
-- flutter-tools handles Dart LSP configuration

-- Autopairs configuration
require("nvim-autopairs").setup({
  check_ts = true,
  disable_filetype = { "TelescopePrompt", "flutterToolsOutline" },
})

-- Integration with nvim-cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- Format on save (for supported filetypes)
vim.api.nvim_create_autocmd('BufWritePre', {
  pattern = { '*.rs', '*.go', '*.cpp', '*.hpp', '*.c', '*.h', '*.dart' },
  callback = function()
    vim.lsp.buf.format({ 
      async = false,
    })
  end
})

-- Create .clangd file automatically for new C++ projects
local function create_clangd_config()
  local clangd_config = [[
CompileFlags:
  Add:
    - "-std=c++17"
    - "-Wall"
    - "-Wextra"
  CompilationDatabase: .
]]
  
  vim.fn.writefile(vim.split(clangd_config, '\n'), '.clangd')
  print("Created .clangd configuration file")
end

-- Command to create clangd config
vim.api.nvim_create_user_command('CreateClangdConfig', create_clangd_config, {
  desc = "Create .clangd configuration file for modern C++"
})

-- Theme
vim.cmd.colorscheme("gruvbox")
vim.o.background = "dark"
