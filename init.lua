-- Check for minimum Neovim version (0.11+ compatible)
local ver = vim.version()
if ver.major == 0 and ver.minor < 11 then
  vim.api.nvim_echo({{"This configuration requires Neovim 0.11 or newer", "ErrorMsg"}}, true, {})
  return
end

-- always set leader first!
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = ","

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
vim.opt.updatetime = 250           -- Faster completion
vim.opt.timeoutlen = 300           -- Faster key sequence completion
vim.opt.cursorline = true          -- Highlight current line
vim.opt.termguicolors = true       -- True color support

-- Swap file configuration 
vim.opt.swapfile = true
vim.opt.directory = vim.fn.stdpath('state') .. '/swap//'
vim.opt.backupdir = vim.fn.stdpath('state') .. '/backup//'

-- Create directories if they don't exist
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, 'p')
  end
end

ensure_dir(vim.fn.stdpath('state') .. '/swap')
ensure_dir(vim.fn.stdpath('state') .. '/backup')-- Tab settings (customize per language later)
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true           -- Use spaces by default

-- Language-specific configurations
local lang_group = vim.api.nvim_create_augroup('LangSettings', { clear = true })

-- Robust C++ standard detection
local function detect_cpp_standard()
  -- Check compile_commands.json first (most reliable)
  local compile_cmds = vim.fn.findfile("compile_commands.json", ".;")
  if compile_cmds ~= "" then
    local ok, data = pcall(vim.fn.json_decode, vim.fn.readfile(compile_cmds))
    if ok and data[1] and data[1].command then
      local std = data[1].command:match("-std=c%+%+(%d+)")
      if std then return "c++" .. std end
    end
  end
  
  -- Check CMakeLists.txt
  local cmake_file = vim.fn.findfile("CMakeLists.txt", ".;")
  if cmake_file ~= "" then
    local content = table.concat(vim.fn.readfile(cmake_file), "\n")
    local std = content:match("CMAKE_CXX_STANDARD%s+(%d+)")
    if std then return "c++" .. std end
    
    -- Check for set_property or target_compile_features
    for _, pattern in ipairs({"c%+%+_std_(%d+)", "cxx_std_(%d+)"}) do
      std = content:match(pattern)
      if std then return "c++" .. std end
    end
  end
  
  return "c++17" -- fallback
end

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
    local cpp_std = detect_cpp_standard()
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

-- TypeScript/JavaScript/React settings
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = {'typescript', 'typescriptreact', 'javascript', 'javascriptreact'},
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = '100'
    
    -- React-specific keymaps
    local bufopts = { noremap = true, silent = true, buffer = true }
    vim.keymap.set('n', '<leader>rf', '<cmd>EslintFixAll<cr>', 
      vim.tbl_extend('force', bufopts, { desc = "ESLint fix all" }))
    vim.keymap.set('n', '<leader>ro', '<cmd>OrganizeImports<cr>', 
      vim.tbl_extend('force', bufopts, { desc = "Organize imports" }))
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

-- Python settings
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = 'python',
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = '88'  -- Black's default
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
      local key = lines[1]
      local selection = lines[2] or ''
      
      if key == 'ctrl-e' then
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
          vim.cmd('write')
        else
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
              vim.cmd('write')
            end
          end)
        end
      else
        if selection ~= '' then
          vim.cmd('edit ' .. vim.fn.fnameescape(selection))
        end
      end
    end,
    options = '--expect=ctrl-e --prompt="Files (Ctrl-E: create)> " --print-query --preview="if [ -f {} ]; then bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null; else echo \'[New file - Press Ctrl-E to create]\'; fi"'
  }))
end, { desc = "Find files with creation option" })

vim.keymap.set('n', '<leader>;', '<cmd>Buffers<cr>', { desc = "List buffers" })

-- Essential operations
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = "Save file" })
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { desc = "Quit" })
vim.keymap.set('n', ';', ':', { desc = "Command mode" })

-- Clipboard integration
vim.keymap.set('n', '<leader>p', '"+p', { desc = "Paste from clipboard" })
vim.keymap.set('n', '<leader>y', '"+y', { desc = "Yank to clipboard" })
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Yank to clipboard" })

-- Navigation enhancements
vim.keymap.set('', 'H', '^', { desc = "Start of line" })
vim.keymap.set('', 'L', '$', { desc = "End of line" })
vim.keymap.set('n', '<leader><leader>', '<c-^>', { desc = "Toggle buffers" })

-- Improved search
vim.keymap.set('n', '<C-h>', '<cmd>nohlsearch<cr>', { desc = "Clear highlights" })
vim.keymap.set('n', 'n', 'nzz', { silent = true, desc = "Next result (centered)" })
vim.keymap.set('n', 'N', 'Nzz', { silent = true, desc = "Previous result (centered)" })

-- Escape remaps
vim.keymap.set('i', 'jk', '<Esc>', { desc = "Exit insert mode" })
vim.keymap.set('v', 'jk', '<Esc>', { desc = "Exit visual mode" })
vim.keymap.set('t', 'jk', '<C-\\><C-n>', { desc = "Exit terminal mode" })

-- Window navigation
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Move to window below" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Move to window above" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Move to window right" })

-- Quickfix navigation
vim.keymap.set('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open quickfix' })
vim.keymap.set('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close quickfix' })
vim.keymap.set('n', '[q', '<cmd>cprev<cr>', { desc = 'Previous quickfix' })
vim.keymap.set('n', ']q', '<cmd>cnext<cr>', { desc = 'Next quickfix' })

-- Better indenting
vim.keymap.set('v', '<', '<gv', { desc = "Indent left" })
vim.keymap.set('v', '>', '>gv', { desc = "Indent right" })

-- Move lines
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==', { desc = "Move line down" })
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==', { desc = "Move line up" })
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

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
  
  -- Which-key for keymap discovery
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = true },
      spec = {
        { "<leader>c", group = "code/cpp" },
        { "<leader>f", group = "flutter" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>g", group = "git" },
        { "<leader>r", group = "react" },
      },
    },
  },

  -- Navigation & Productivity
  { 
    "ggandor/leap.nvim", 
    keys = {"s", "S", "gs"},
    config = function() 
      require('leap').add_default_mappings() 
    end 
  },
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim", cmd = {"Files", "Buffers", "Rg", "GFiles"} },
  { "airblade/vim-rooter" },
  
  -- File explorer
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = {
        show_hidden = true,
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },
  
  -- Git integration
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    opts = {
      signs = {
        add = { text = '│' },
        change = { text = '│' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local opts = { buffer = bufnr }
        
        vim.keymap.set('n', '<leader>gb', function() gs.blame_line{full=true} end, 
          vim.tbl_extend('force', opts, { desc = "Blame line" }))
        vim.keymap.set('n', '<leader>gd', gs.diffthis, 
          vim.tbl_extend('force', opts, { desc = "Diff this" }))
        vim.keymap.set('n', '<leader>gp', gs.preview_hunk, 
          vim.tbl_extend('force', opts, { desc = "Preview hunk" }))
        vim.keymap.set('n', '<leader>gr', gs.reset_hunk, 
          vim.tbl_extend('force', opts, { desc = "Reset hunk" }))
        vim.keymap.set('n', '[h', gs.prev_hunk, 
          vim.tbl_extend('force', opts, { desc = "Previous hunk" }))
        vim.keymap.set('n', ']h', gs.next_hunk, 
          vim.tbl_extend('force', opts, { desc = "Next hunk" }))
      end
    }
  },
  
  -- Comment plugin
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = {},
  },
  
  -- Better terminal
  {
    "akinsho/toggleterm.nvim",
    cmd = "ToggleTerm",
    keys = {
      { [[<c-\>]], '<cmd>ToggleTerm<cr>', desc = "Toggle terminal" },
    },
    opts = {
      open_mapping = [[<c-\>]],
      direction = 'float',
      float_opts = { 
        border = 'curved',
        width = function() return math.floor(vim.o.columns * 0.9) end,
        height = function() return math.floor(vim.o.lines * 0.8) end,
      },
    },
  },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { 
          "lua", "rust", "go", "c", "cpp", "dart", "python", 
          "javascript", "typescript", "tsx", "json", "html", "css"
        },
        highlight = { 
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<CR>",
            node_incremental = "<CR>",
            scope_incremental = "<S-CR>",
            node_decremental = "<BS>",
          },
        },
      })
    end
  },
  
  -- Auto-close and auto-rename JSX/HTML tags - FIXED: Use standalone setup
  {
    "windwp/nvim-ts-autotag",
    ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "xml" },
    config = function()
      require('nvim-ts-autotag').setup({
        opts = {
          enable_close = true,
          enable_rename = true,
          enable_close_on_slash = false,
        },
      })
    end,
  },
  
  -- Indentation guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      indent = { char = "│" },
      scope = { enabled = false },
    },
  },

  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- LSP & Autocompletion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { 
        "rust_analyzer", 
        "clangd", 
        "gopls", 
        "pyright",
        "ts_ls",  -- TypeScript/JavaScript LSP
        "eslint"  -- ESLint integration
      },
      -- Disable automatic server setup (we use vim.lsp.config)
      automatic_installation = false,
    },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  
  -- LSP progress indicator
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
  
  -- Snippet engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
      
      -- Add custom React snippets
      local ls = require("luasnip")
      local s = ls.snippet
      local t = ls.text_node
      local i = ls.insert_node
      
      ls.add_snippets("typescriptreact", {
        s("rfc", {
          t({"import React from 'react';", "", "interface "}),
          i(1, "Component"),
          t({"Props {", "  "}),
          i(2, "// props"),
          t({"", "}", "", "const "}),
          i(3, "Component"),
          t({": React.FC<"}),
          i(4, "Component"),
          t({"Props> = (props) => {", "  return (", "    <div>"}),
          i(5, "Component"),
          t({"</div>", "  );", "};", "", "export default "}),
          i(6, "Component"),
          t(";"),
        }),
        s("useh", {
          t("const ["),
          i(1, "state"),
          t(", set"),
          i(2, "State"),
          t("] = useState"),
          i(3, "<"),
          i(4, "Type"),
          t(">("),
          i(5, "initialValue"),
          t(");"),
        }),
        s("usee", {
          t({"useEffect(() => {", "  "}),
          i(1, "// effect"),
          t({"", "}, ["}),
          i(2, "deps"),
          t("]);"),
        }),
      })
      
      ls.add_snippets("javascriptreact", {
        s("rfc", {
          t({"import React from 'react';", "", "const "}),
          i(1, "Component"),
          t({" = (props) => {", "  return (", "    <div>"}),
          i(2, "Component"),
          t({"</div>", "  );", "};", "", "export default "}),
          i(3, "Component"),
          t(";"),
        }),
        s("useh", {
          t("const ["),
          i(1, "state"),
          t(", set"),
          i(2, "State"),
          t("] = useState("),
          i(3, "initialValue"),
          t(");"),
        }),
      })
    end,
  },
  
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require 'cmp'
      local luasnip = require 'luasnip'
      
      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        sources = {
          { name = 'nvim_lsp', priority = 1000 },
          { name = 'luasnip', priority = 750 },
          { name = 'path', priority = 500 },
          { name = 'buffer', keyword_length = 3, priority = 250 },
        },
        mapping = cmp.mapping.preset.insert({
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ select = true }),
          ['<Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { 'i', 's' }),
          ['<S-Tab>'] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { 'i', 's' }),
        }),
        formatting = {
          format = function(entry, item)
            item.menu = ({
              nvim_lsp = '[LSP]',
              luasnip = '[Snip]',
              buffer = '[Buf]',
              path = '[Path]',
            })[entry.source.name]
            return item
          end
        },
        experimental = { ghost_text = true },
      })
      
      -- Command line completion
      cmp.setup.cmdline(':', {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = 'path' },
          { name = 'cmdline' }
        }
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
      "stevearc/dressing.nvim",
    },
    config = function()
      -- Configured after LSP setup
    end,
  },

  -- Enhanced C++ support
  { "octol/vim-cpp-enhanced-highlight", ft = { "cpp", "c" } },
}, {
  ui = {
    border = "rounded",
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-------------------------------------------------------------------------------
-- LSP Configuration
-------------------------------------------------------------------------------

-- CRITICAL: Prevent angularls from ever starting
-- This must come before any other LSP configuration
vim.g.lsp_angularls_enable = false

-- Block angularls configuration completely
vim.lsp.config('angularls', {
  enabled = false,
  autostart = false,
  filetypes = {},  -- Remove all filetypes
})

-- Additional safety: Stop angularls if it somehow gets attached
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client.name == "angularls" then
      vim.schedule(function()
        vim.lsp.stop_client(client.id)
        vim.notify("Stopped unwanted angularls client", vim.log.levels.WARN)
      end)
    end
  end,
})

-- Block FileType autocmd that might trigger angularls
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "typescript", "typescriptreact", "typescript.tsx", "html" },
  callback = function()
    -- Ensure angularls doesn't start for these filetypes
    vim.b.lsp_angularls_enable = false
  end,
})-- Diagnostic configuration
vim.diagnostic.config({
  virtual_text = { 
    prefix = '●',
    spacing = 4,
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

-- Diagnostic signs
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

-- Common LSP on_attach function
local on_attach = function(client, bufnr)
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  
  -- Navigation
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, 
    vim.tbl_extend('force', bufopts, { desc = "Go to definition" }))
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, 
    vim.tbl_extend('force', bufopts, { desc = "Go to declaration" }))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, 
    vim.tbl_extend('force', bufopts, { desc = "Go to implementation" }))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, 
    vim.tbl_extend('force', bufopts, { desc = "Show references" }))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, 
    vim.tbl_extend('force', bufopts, { desc = "Hover documentation" }))
  
  -- Code actions
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, 
    vim.tbl_extend('force', bufopts, { desc = "Rename symbol" }))
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, 
    vim.tbl_extend('force', bufopts, { desc = "Code action" }))
  
  -- Diagnostics
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, 
    vim.tbl_extend('force', bufopts, { desc = 'Previous diagnostic' }))
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, 
    vim.tbl_extend('force', bufopts, { desc = 'Next diagnostic' }))
  vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, 
    vim.tbl_extend('force', bufopts, { desc = 'Show diagnostic' }))
  vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, 
    vim.tbl_extend('force', bufopts, { desc = 'Diagnostic list' }))
  
  -- Formatting
  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<leader>cf", function() 
      vim.lsp.buf.format { async = true } 
    end, vim.tbl_extend('force', bufopts, { desc = "Format buffer" }))
  end
  
  -- Highlight symbol under cursor
  if client.server_capabilities.documentHighlightProvider then
    local highlight_augroup = vim.api.nvim_create_augroup('lsp_document_highlight', { clear = false })
    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = highlight_augroup })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = highlight_augroup,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      group = highlight_augroup,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

-- LSP server configurations
local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Configure Flutter Tools (uses its own LSP setup)
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
    autostart = false,
    auto_open_browser = false,
  },
  debugger = {
    enabled = true,
    run_via_dap = false,
  },
})

-- Rust Analyzer with new API
vim.lsp.config('rust_analyzer', {
  cmd = { 'rust-analyzer' },
  filetypes = { 'rust' },
  root_markers = { 'Cargo.toml', 'rust-project.json' },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    ["rust-analyzer"] = {
      cargo = { allFeatures = true },
      checkOnSave = true,
      check = { command = "clippy" },
      inlayHints = {
        bindingModeHints = { enable = true },
        closureReturnTypeHints = { enable = "always" },
        lifetimeElisionHints = { enable = "always" },
      },
    },
  },
})

-- Clangd for C/C++ with new API
vim.lsp.config('clangd', {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=iwyu",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = {
    'compile_commands.json',
    'compile_flags.txt',
    '.clangd',
    '.git',
    'CMakeLists.txt',
    'Makefile'
  },
  capabilities = capabilities,
  on_attach = on_attach,
})

-- Go LSP with new API
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
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
    },
  },
})

-- Python LSP with new API
vim.lsp.config('pyright', {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', '.git' },
  capabilities = capabilities,
  on_attach = on_attach,
  settings = {
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
        typeCheckingMode = "basic",
      }
    }
  }
})

-- TypeScript/JavaScript LSP with React support - FIXED FORMATTING
vim.lsp.config('ts_ls', {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = { 
    'javascript', 
    'javascriptreact', 
    'javascript.jsx', 
    'typescript', 
    'typescriptreact', 
    'typescript.tsx' 
  },
  root_markers = { 'package.json', 'tsconfig.json', 'jsconfig.json', '.git' },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- Call default on_attach
    on_attach(client, bufnr)
    
    -- IMPORTANT: Enable formatting for TypeScript LSP
    client.server_capabilities.documentFormattingProvider = true
    client.server_capabilities.documentRangeFormattingProvider = true
  end,
  settings = {
    typescript = {
      format = {
        indentSize = 2,
        convertTabsToSpaces = true,
        tabSize = 2,
      },
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      suggest = {
        includeCompletionsForModuleExports = true,
      },
    },
    javascript = {
      format = {
        indentSize = 2,
        convertTabsToSpaces = true,
        tabSize = 2,
      },
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      },
      suggest = {
        includeCompletionsForModuleExports = true,
      },
    },
  },
})

-- ESLint LSP for linting and formatting
vim.lsp.config('eslint', {
  cmd = { 'vscode-eslint-language-server', '--stdio' },
  filetypes = { 
    'javascript', 
    'javascriptreact', 
    'javascript.jsx', 
    'typescript', 
    'typescriptreact', 
    'typescript.tsx',
  },
  root_markers = { 
    'eslint.config.js',
    '.eslintrc', 
    '.eslintrc.js', 
    '.eslintrc.cjs',
    '.eslintrc.yaml',
    '.eslintrc.yml',
    '.eslintrc.json', 
    'package.json' 
  },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    on_attach(client, bufnr)
    
    -- Create buffer-local command for ESLint fix
    vim.api.nvim_buf_create_user_command(bufnr, 'EslintFixAll', function()
      vim.lsp.buf.code_action({
        context = {
          only = { 'source.fixAll.eslint' },
          diagnostics = {},
        },
        apply = true,
      })
    end, {
      desc = 'Fix all ESLint issues'
    })
    
    -- Format on save (more robust)
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        -- Only try to fix if ESLint is ready
        if client.is_stopped() then
          return
        end
        
        local params = {
          textDocument = vim.lsp.util.make_text_document_params(),
          context = { only = { 'source.fixAll.eslint' } },
        }
        
        local result = vim.lsp.buf_request_sync(bufnr, 'textDocument/codeAction', params, 1000)
        if not result then return end
        
        for _, res in pairs(result) do
          for _, action in pairs(res.result or {}) do
            if action.edit then
              vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
            end
          end
        end
      end,
    })
  end,
  settings = {
    validate = 'on',
    packageManager = 'npm',
    useESLintClass = false,
    experimental = {
      useFlatConfig = true,
    },
    codeAction = {
      disableRuleComment = {
        enable = true,
        location = "separateLine"
      },
      showDocumentation = {
        enable = true
      }
    },
    codeActionOnSave = {
      enable = false, -- We handle this manually
      mode = "all"
    },
    format = true,
    quiet = false,
    onIgnoredFiles = "off",
    rulesCustomizations = {},
    run = "onType",
    workingDirectory = {
      mode = "auto"
    }
  }
})
-- Enable LSP servers
vim.lsp.enable('rust_analyzer')
vim.lsp.enable('clangd')
vim.lsp.enable('gopls')
vim.lsp.enable('pyright')
vim.lsp.enable('ts_ls')
vim.lsp.enable('eslint')

-- Command for organizing imports (TypeScript/JavaScript)
vim.api.nvim_create_user_command('OrganizeImports', function()
  local params = {
    command = "_typescript.organizeImports",
    arguments = {vim.api.nvim_buf_get_name(0)},
  }
  vim.lsp.buf.execute_command(params)
end, {
  desc = "Organize imports (TypeScript)"
})

-- Autopairs configuration
require("nvim-autopairs").setup({
  check_ts = true,
  disable_filetype = { "TelescopePrompt", "flutterToolsOutline" },
  fast_wrap = {
    map = '<M-e>',
    chars = { '{', '[', '(', '"', "'" },
    pattern = [=[[%'%"%)%>%]%)%}%,]]=],
    end_key = ',',
    keys = 'qwertyuiopzxcvbnmasdfghjkl',
    check_comma = true,
    highlight = 'Search',
    highlight_grey='Comment'
  },
})

-- Integration with nvim-cmp
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local cmp = require("cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

-- Format on save with error handling
local format_group = vim.api.nvim_create_augroup('AutoFormat', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_group,
  pattern = { 
    '*.rs', '*.go', '*.cpp', '*.hpp', '*.c', '*.h', '*.dart', '*.py',
    '*.js', '*.jsx', '*.ts', '*.tsx', '*.json', '*.css', '*.html'  -- Add these!
  },
  callback = function()
    local timeout_ms = 2000
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Check if LSP client is attached
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then
      return
    end
    
    -- Format with timeout
    local success = pcall(function()
      vim.lsp.buf.format({ 
        async = false,
        timeout_ms = timeout_ms,
        bufnr = bufnr,
        filter = function(client)
          -- For JS/TS files, prefer eslint for formatting if available
          if client.name == "eslint" then
            return true
          end
          -- For other files, use any LSP that supports formatting
          return client.supports_method("textDocument/formatting")
        end
      })
    end)
    
    if not success then
      vim.notify("Format timeout or error", vim.log.levels.WARN)
    end
  end
})-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Auto-create parent directories on save
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+://') then
      return
    end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})



-- Create .clangd file automatically for new C++ projects
local function create_clangd_config()
  local cpp_std = detect_cpp_standard()
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
]], cpp_std)
  
  vim.fn.writefile(vim.split(clangd_config, '\n'), '.clangd')
  vim.notify("Created .clangd configuration file with " .. cpp_std, vim.log.levels.INFO)
end

-- Command to create clangd config
vim.api.nvim_create_user_command('CreateClangdConfig', create_clangd_config, {
  desc = "Create .clangd configuration file for modern C++"
})

-- Command to show LSP info
vim.api.nvim_create_user_command('LspInfo', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  
  if #clients == 0 then
    vim.notify("No LSP clients attached", vim.log.levels.INFO)
    return
  end
  
  local info = {}
  for _, client in ipairs(clients) do
    table.insert(info, string.format("• %s (id: %d)", client.name, client.id))
  end
  
  vim.notify("Active LSP clients:\n" .. table.concat(info, "\n"), vim.log.levels.INFO)
end, {
  desc = "Show active LSP clients"
})

-- Better defaults for terminal mode
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('terminal_settings', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('last_loc', { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Theme
vim.cmd.colorscheme("gruvbox")
vim.o.background = "dark"

-- Lightline configuration
vim.g.lightline = {
  colorscheme = 'gruvbox',
  active = {
    left = {
      { 'mode', 'paste' },
      { 'readonly', 'filename', 'modified' }
    },
    right = {
      { 'lineinfo' },
      { 'percent' },
      { 'fileformat', 'fileencoding', 'filetype' }
    }
  },
  component_function = {
    filename = 'LightlineFilename'
  }
}

-- Custom filename function for lightline
vim.cmd([[
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
]])
