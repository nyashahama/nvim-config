local M = {}

local function map_lsp(bufnr, lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, {
    noremap = true,
    silent = true,
    buffer = bufnr,
    desc = desc,
  })
end

local function on_attach(client, bufnr)
  map_lsp(bufnr, "gd", vim.lsp.buf.definition, "Go to definition")
  map_lsp(bufnr, "gD", vim.lsp.buf.declaration, "Go to declaration")
  map_lsp(bufnr, "gi", vim.lsp.buf.implementation, "Go to implementation")
  map_lsp(bufnr, "gr", vim.lsp.buf.references, "Show references")
  map_lsp(bufnr, "K", vim.lsp.buf.hover, "Hover documentation")

  map_lsp(bufnr, "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
  map_lsp(bufnr, "<leader>ca", vim.lsp.buf.code_action, "Code action")

  map_lsp(bufnr, "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
  map_lsp(bufnr, "]d", vim.diagnostic.goto_next, "Next diagnostic")
  map_lsp(bufnr, "<leader>xd", vim.diagnostic.open_float, "Show diagnostic")
  map_lsp(bufnr, "<leader>xl", vim.diagnostic.setloclist, "Diagnostics to location list")

  if client.server_capabilities.documentFormattingProvider then
    map_lsp(bufnr, "<leader>cf", function()
      vim.lsp.buf.format({ async = true })
    end, "Format buffer")
  end

  if client.server_capabilities.documentHighlightProvider then
    local group = vim.api.nvim_create_augroup("LspDocumentHighlight", { clear = false })
    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = group })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = group,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

function M.setup_diagnostics()
  vim.diagnostic.config({
    virtual_text = {
      prefix = "E",
      spacing = 4,
    },
    signs = true,
    underline = true,
    update_in_insert = false,
    severity_sort = true,
    float = {
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  })

  local signs = {
    Error = "E",
    Warn = "W",
    Hint = "H",
    Info = "I",
  }

  for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
  end
end

function M.setup_lsp()
  M.setup_diagnostics()

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
  if ok then
    capabilities = cmp_lsp.default_capabilities(capabilities)
  end

  require("lang.cpp").setup_lsp(capabilities, on_attach)
  require("lang.go").setup_lsp(capabilities, on_attach)
  require("lang.rust").setup_lsp(capabilities, on_attach)
end

function M.setup_cmp()
  local cmp = require("cmp")
  local luasnip = require("luasnip")

  cmp.setup({
    snippet = {
      expand = function(args)
        luasnip.lsp_expand(args.body)
      end,
    },
    sources = {
      { name = "nvim_lsp", priority = 1000 },
      { name = "luasnip", priority = 750 },
      { name = "path", priority = 500 },
      { name = "buffer", keyword_length = 3, priority = 250 },
    },
    mapping = cmp.mapping.preset.insert({
      ["<C-b>"] = cmp.mapping.scroll_docs(-4),
      ["<C-f>"] = cmp.mapping.scroll_docs(4),
      ["<C-Space>"] = cmp.mapping.complete(),
      ["<C-e>"] = cmp.mapping.abort(),
      ["<CR>"] = cmp.mapping.confirm({ select = true }),
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_next_item()
        elseif luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        else
          fallback()
        end
      end, { "i", "s" }),
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),
    }),
    formatting = {
      format = function(entry, item)
        item.menu = ({
          nvim_lsp = "[LSP]",
          luasnip = "[Snip]",
          buffer = "[Buf]",
          path = "[Path]",
        })[entry.source.name]
        return item
      end,
    },
    experimental = { ghost_text = true },
  })

  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
      { name = "path" },
      { name = "cmdline" },
    },
  })

  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
end

return {
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = M.setup_lsp,
  },
  { "williamboman/mason.nvim", cmd = "Mason", opts = {} },
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      ensure_installed = { "clangd", "gopls", "rust_analyzer" },
      automatic_installation = false,
    },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
  },
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {},
  },
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
    config = function()
      require("luasnip.loaders.from_vscode").lazy_load()
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
      "windwp/nvim-autopairs",
    },
    config = M.setup_cmp,
  },
  { "mrcjkb/rustaceanvim", version = "^9", ft = "rust" },
}
