return {
  {
    "ggandor/leap.nvim",
    keys = { "s", "S", "gs" },
    config = function()
      require("leap").add_default_mappings()
    end,
  },
  { "junegunn/fzf", build = "./install --all" },
  { "junegunn/fzf.vim", cmd = { "Files", "Buffers", "Rg", "GFiles" } },
  { "airblade/vim-rooter" },
  {
    "stevearc/oil.nvim",
    opts = {
      view_options = { show_hidden = true },
      keymaps = {
        ["<C-h>"] = false,
        ["<C-l>"] = false,
      },
    },
    keys = {
      { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
    },
  },
}
