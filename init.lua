-- Systems Programming Neovim Configuration
-- Optimized for C++ and Go development

-- Version check (0.11+)
local ver = vim.version()
if ver.major == 0 and ver.minor < 11 then
  vim.api.nvim_echo({{"This configuration requires Neovim 0.11 or newer", "ErrorMsg"}}, true, {})
  return
end

-- Leader keys
vim.keymap.set("n", "<Space>", "<Nop>", { silent = true })
vim.g.mapleader = " "
vim.g.maplocalleader = ","

-------------------------------------------------------------------------------
-- Core Settings
-------------------------------------------------------------------------------
-- Folding
vim.opt.foldenable = false
vim.opt.foldmethod = 'manual'
vim.opt.foldlevelstart = 99

-- UI
vim.opt.scrolloff = 8              -- More context when scrolling
vim.opt.wrap = false               -- No line wrapping
vim.opt.signcolumn = 'yes'         -- Always show sign column
vim.opt.relativenumber = true      -- Relative line numbers
vim.opt.number = true              -- Current line number
vim.opt.splitright = true          -- Vertical splits to the right
vim.opt.splitbelow = true          -- Horizontal splits below
vim.opt.undofile = true            -- Persistent undo
vim.opt.wildmode = 'list:longest'  -- Better tab completion
vim.opt.ignorecase = true          -- Case-insensitive search
vim.opt.smartcase = true           -- Case-sensitive when uppercase present
vim.opt.visualbell = true          -- Disable beeping
vim.opt.colorcolumn = '120'        -- Line length guide (C++ modern standard)
vim.opt.listchars = 'tab:▸ ,nbsp:¬,extends:»,precedes:«,trail:•'
vim.opt.clipboard = 'unnamedplus'  -- System clipboard
vim.opt.updatetime = 250           -- Faster completion
vim.opt.timeoutlen = 300           -- Faster key sequences
vim.opt.cursorline = true          -- Highlight current line
vim.opt.termguicolors = true       -- True color support

-- Swap/Backup
vim.opt.swapfile = true
vim.opt.directory = vim.fn.stdpath('state') .. '/swap//'
vim.opt.backupdir = vim.fn.stdpath('state') .. '/backup//'

-- Create directories
local function ensure_dir(path)
  if vim.fn.isdirectory(path) == 0 then
    vim.fn.mkdir(path, 'p')
  end
end

ensure_dir(vim.fn.stdpath('state') .. '/swap')
ensure_dir(vim.fn.stdpath('state') .. '/backup')

-- Tab defaults (2 spaces for C++, tabs for Go)
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.expandtab = true

-------------------------------------------------------------------------------
-- Language-specific Settings
-------------------------------------------------------------------------------
local lang_group = vim.api.nvim_create_augroup('LangSettings', { clear = true })

-- C++ standard detection
local function detect_cpp_standard()
  -- Check compile_commands.json
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
    
    for _, pattern in ipairs({"c%+%+_std_(%d+)", "cxx_std_(%d+)"}) do
      std = content:match(pattern)
      if std then return "c++" .. std end
    end
  end
  
  return "c++20" -- Modern default
end

-- C/C++ settings
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = {'cpp', 'c', 'h', 'hpp', 'cc', 'hh'},
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.colorcolumn = '120'
    vim.opt_local.commentstring = '// %s'
    
    -- Set C++ standard
    local cpp_std = detect_cpp_standard()
    vim.b.cpp_std = cpp_std
    
    -- C++ keymaps
    local opts = { noremap = true, silent = true, buffer = true }
    vim.keymap.set('n', '<leader>ch', '<cmd>ClangdSwitchSourceHeader<cr>', 
      vim.tbl_extend('force', opts, { desc = "Switch Header/Source" }))
    vim.keymap.set('n', '<leader>ct', '<cmd>ClangdTypeHierarchy<cr>', 
      vim.tbl_extend('force', opts, { desc = "Type Hierarchy" }))
    vim.keymap.set('n', '<leader>cs', '<cmd>ClangdSymbolInfo<cr>', 
      vim.tbl_extend('force', opts, { desc = "Symbol Info" }))
    vim.keymap.set('n', '<leader>cm', '<cmd>ClangdMemoryUsage<cr>', 
      vim.tbl_extend('force', opts, { desc = "Memory Usage" }))
  end
})

-- Go settings (tabs, not spaces)
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = 'go',
  callback = function()
    vim.opt_local.expandtab = false   -- Go uses tabs
    vim.opt_local.shiftwidth = 8
    vim.opt_local.tabstop = 8
    vim.opt_local.colorcolumn = '120'
    
    -- Go keymaps
    local opts = { noremap = true, silent = true, buffer = true }
    vim.keymap.set('n', '<leader>gi', '<cmd>GoImport<cr>', 
      vim.tbl_extend('force', opts, { desc = "Go imports" }))
    vim.keymap.set('n', '<leader>gt', '<cmd>GoTest<cr>', 
      vim.tbl_extend('force', opts, { desc = "Go test" }))
    vim.keymap.set('n', '<leader>gb', '<cmd>GoBuild<cr>', 
      vim.tbl_extend('force', opts, { desc = "Go build" }))
  end
})

-- Makefile/CMake (tabs required)
vim.api.nvim_create_autocmd('FileType', {
  group = lang_group,
  pattern = {'make', 'cmake'},
  callback = function()
    vim.opt_local.expandtab = false
    vim.opt_local.shiftwidth = 8
    vim.opt_local.tabstop = 8
  end
})

-------------------------------------------------------------------------------
-- Key Mappings
-------------------------------------------------------------------------------
-- File operations with fzf
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
            vim.fn.mkdir(dir, 'p')
          end
          vim.cmd('edit ' .. vim.fn.fnameescape(selection))
          vim.cmd('write')
        else
          vim.ui.input({ prompt = 'New file: ' }, function(filename)
            if filename and filename ~= '' then
              local dir = vim.fn.fnamemodify(filename, ':h')
              if dir ~= '.' and dir ~= '' and vim.fn.isdirectory(dir) == 0 then
                vim.fn.mkdir(dir, 'p')
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
    options = '--expect=ctrl-e --prompt="Files (Ctrl-E: create)> " --print-query --preview="bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null"'
  }))
end, { desc = "Find files" })

vim.keymap.set('n', '<leader>;', '<cmd>Buffers<cr>', { desc = "List buffers" })
vim.keymap.set('n', '<leader>rg', '<cmd>Rg<cr>', { desc = "Ripgrep search" })

-- Essential operations
vim.keymap.set('n', '<leader>w', '<cmd>w<cr>', { desc = "Save file" })
vim.keymap.set('n', '<leader>q', '<cmd>q<cr>', { desc = "Quit" })
vim.keymap.set('n', ';', ':', { desc = "Command mode" })

-- Clipboard
vim.keymap.set('n', '<leader>p', '"+p', { desc = "Paste from clipboard" })
vim.keymap.set('n', '<leader>y', '"+y', { desc = "Yank to clipboard" })
vim.keymap.set('v', '<leader>y', '"+y', { desc = "Yank to clipboard" })

-- Navigation
vim.keymap.set('', 'H', '^', { desc = "Start of line" })
vim.keymap.set('', 'L', '$', { desc = "End of line" })
vim.keymap.set('n', '<leader><leader>', '<c-^>', { desc = "Toggle buffers" })

-- Search improvements
vim.keymap.set('n', '<C-h>', '<cmd>nohlsearch<cr>', { desc = "Clear highlights" })
vim.keymap.set('n', 'n', 'nzz', { silent = true, desc = "Next result (centered)" })
vim.keymap.set('n', 'N', 'Nzz', { silent = true, desc = "Previous result (centered)" })

-- Quick escape
vim.keymap.set('i', 'jk', '<Esc>', { desc = "Exit insert mode" })
vim.keymap.set('v', 'jk', '<Esc>', { desc = "Exit visual mode" })
vim.keymap.set('t', 'jk', '<C-\\><C-n>', { desc = "Exit terminal mode" })

-- Window navigation - Using leader-based to avoid conflicts
vim.keymap.set('n', '<leader>j', '<C-w>j', { desc = "Move to window below" })
vim.keymap.set('n', '<leader>k', '<C-w>k', { desc = "Move to window above" })
vim.keymap.set('n', '<leader>l', '<C-w>l', { desc = "Move to window right" })
vim.keymap.set('n', '<leader>h', '<C-w>h', { desc = "Move to window left" })

-- Window management
vim.keymap.set('n', '<leader>sv', '<cmd>vsplit<cr>', { desc = "Vertical split" })
vim.keymap.set('n', '<leader>sh', '<cmd>split<cr>', { desc = "Horizontal split" })
vim.keymap.set('n', '<leader>sx', '<cmd>close<cr>', { desc = "Close split" })
vim.keymap.set('n', '<leader>s=', '<C-w>=', { desc = "Equal splits" })

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
-- Plugin Manager (lazy.nvim)
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
  -- Theme
  { 
    "ellisonleao/gruvbox.nvim", 
    priority = 1000, 
    config = function()
      require("gruvbox").setup({
        contrast = "hard",
        italic = {
          strings = false,
          comments = false,
        },
      })
      vim.cmd.colorscheme("gruvbox")
      vim.o.background = "dark"
      
      -- Configure lightline after colorscheme is loaded
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
    end
  },
  
  -- UI
  {
  "nvim-lualine/lualine.nvim",  -- Modern alternative to lightline
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("lualine").setup({
      options = {
        theme = "gruvbox",
        icons_enabled = true,
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        disabled_filetypes = {},
      },
      sections = {
        lualine_a = { 'mode' },
        lualine_b = { 'branch', 'diff', 'diagnostics' },
        lualine_c = { {
          'filename',
          file_status = true,
          path = 1,
        } },
        lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = { 'progress' },
        lualine_z = { 'location' }
      },
      extensions = { 'fzf', 'fugitive', 'oil' },
    })
  end
},
  { "nvim-tree/nvim-web-devicons", opts = {} },
  
  -- Keymap discovery
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      icons = { mappings = true },
      spec = {
        { "<leader>c", group = "code/cpp" },
        { "<leader>g", group = "git/go" },
        { "<leader>d", group = "diagnostics" },
        { "<leader>s", group = "splits" },
      },
    },
  },

  -- Navigation
  { 
    "ggandor/leap.nvim", 
    keys = {"s", "S", "gs"},
    config = function() 
      require('leap').add_default_mappings() 
    end 
  },
  
  -- Fuzzy finder
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim", cmd = {"Files", "Buffers", "Rg", "GFiles"} },
  { "airblade/vim-rooter" },
  
  -- File explorer
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = { show_hidden = true },
      keymaps = {
        ["<C-h>"] = false,  -- Disable oil's C-h to avoid conflicts
        ["<C-l>"] = false,  -- Disable oil's C-l to avoid conflicts
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
  
  -- Comments
  {
    "numToStr/Comment.nvim",
    keys = {
      { "gc", mode = { "n", "v" }, desc = "Comment toggle linewise" },
      { "gb", mode = { "n", "v" }, desc = "Comment toggle blockwise" },
    },
    opts = {},
  },
  
  -- Terminal
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
          "lua", "c", "cpp", "go", "make", "cmake", "bash", "json", "yaml", "toml"
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

  -- Auto-pairs
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true
  },

  -- LSP & Completion
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "clangd", "gopls" },
      automatic_installation = false,
    },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  
  -- LSP progress
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
  
  -- Snippets
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
    end,
  },
  
  -- Completion
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
      
      -- Autopairs integration
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  },

  -- Language-specific
  { "octol/vim-cpp-enhanced-highlight", ft = { "cpp", "c" } },
  { "fatih/vim-go", ft = "go", build = ":GoUpdateBinaries" },
}, {
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen", "netrwPlugin",
        "tarPlugin", "tohtml", "tutor", "zipPlugin",
      },
    },
  },
})

-------------------------------------------------------------------------------
-- LSP Configuration
-------------------------------------------------------------------------------

-- Diagnostics
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

-- LSP on_attach
local on_attach = function(client, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
  
  -- Navigation
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, 
    vim.tbl_extend('force', opts, { desc = "Go to definition" }))
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, 
    vim.tbl_extend('force', opts, { desc = "Go to declaration" }))
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, 
    vim.tbl_extend('force', opts, { desc = "Go to implementation" }))
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, 
    vim.tbl_extend('force', opts, { desc = "Show references" }))
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, 
    vim.tbl_extend('force', opts, { desc = "Hover documentation" }))
  
  -- Code actions
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, 
    vim.tbl_extend('force', opts, { desc = "Rename symbol" }))
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, 
    vim.tbl_extend('force', opts, { desc = "Code action" }))
  
  -- Diagnostics
  vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, 
    vim.tbl_extend('force', opts, { desc = 'Previous diagnostic' }))
  vim.keymap.set('n', ']d', vim.diagnostic.goto_next, 
    vim.tbl_extend('force', opts, { desc = 'Next diagnostic' }))
  vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, 
    vim.tbl_extend('force', opts, { desc = 'Show diagnostic' }))
  vim.keymap.set('n', '<leader>dl', vim.diagnostic.setloclist, 
    vim.tbl_extend('force', opts, { desc = 'Diagnostic list' }))
  
  -- Formatting
  if client.server_capabilities.documentFormattingProvider then
    vim.keymap.set("n", "<leader>cf", function() 
      vim.lsp.buf.format { async = true } 
    end, vim.tbl_extend('force', opts, { desc = "Format buffer" }))
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

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- Clangd (C/C++)
vim.lsp.config('clangd', {
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

-- Gopls (Go)
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

-- Enable LSP servers
vim.lsp.enable('clangd')
vim.lsp.enable('gopls')

-------------------------------------------------------------------------------
-- Autocommands
-------------------------------------------------------------------------------

-- Format on save
local format_group = vim.api.nvim_create_augroup('AutoFormat', { clear = true })
vim.api.nvim_create_autocmd('BufWritePre', {
  group = format_group,
  pattern = { '*.c', '*.h', '*.cpp', '*.hpp', '*.cc', '*.hh', '*.go' },
  callback = function()
    local timeout_ms = 2000
    local bufnr = vim.api.nvim_get_current_buf()
    
    local clients = vim.lsp.get_clients({ bufnr = bufnr })
    if #clients == 0 then return end
    
    pcall(function()
      vim.lsp.buf.format({ 
        async = false,
        timeout_ms = timeout_ms,
        bufnr = bufnr,
      })
    end)
  end
})

-- Highlight on yank
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = highlight_group,
  pattern = '*',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 200 })
  end,
})

-- Auto-create parent directories
vim.api.nvim_create_autocmd('BufWritePre', {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+://') then return end
    local file = vim.loop.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Terminal settings
vim.api.nvim_create_autocmd('TermOpen', {
  group = vim.api.nvim_create_augroup('terminal_settings', { clear = true }),
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    vim.opt_local.signcolumn = 'no'
  end,
})

-- Return to last position
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

-------------------------------------------------------------------------------
-- Utility Commands
-------------------------------------------------------------------------------

-- Create .clangd config for C++ projects
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
  vim.notify("Created .clangd configuration with " .. cpp_std, vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('CreateClangdConfig', create_clangd_config, {
  desc = "Create .clangd configuration file"
})

-- Show active LSP clients
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

-- Lightline filename function
vim.cmd([[
function! LightlineFilename()
  let filename = expand('%:t') !=# '' ? expand('%:t') : '[No Name]'
  let modified = &modified ? ' +' : ''
  return filename . modified
endfunction
]])
