local M = {}

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts or {})
end

local function load_fzf()
  local ok, lazy = pcall(require, "lazy")
  if ok then
    pcall(lazy.load, { plugins = { "fzf.vim" } })
  end
end

function M.find_files()
  load_fzf()

  if vim.fn.exists("*fzf#run") == 0 then
    vim.notify("fzf.vim is not available", vim.log.levels.ERROR)
    return
  end

  local finder = "find . -type f 2>/dev/null"
  if vim.fn.executable("fd") == 1 then
    finder = "fd --type f --hidden --follow --exclude .git"
  elseif vim.fn.executable("fdfind") == 1 then
    finder = "fdfind --type f --hidden --follow --exclude .git"
  elseif vim.fn.executable("rg") == 1 then
    finder = "rg --files --hidden --glob '!.git'"
  end

  local preview = "cat {} 2>/dev/null"
  if vim.fn.executable("bat") == 1 then
    preview = "bat --style=numbers --color=always {} 2>/dev/null"
  elseif vim.fn.executable("batcat") == 1 then
    preview = "batcat --style=numbers --color=always {} 2>/dev/null"
  end

  vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
    source = finder,
    sink = function(selected)
      vim.cmd("edit " .. vim.fn.fnameescape(selected))
    end,
    ["sink*"] = function(lines)
      local key = lines[1] or ""
      local query = lines[2] or ""
      local selection = lines[3] or query

      if key == "ctrl-e" then
        local filename = query ~= "" and query or selection
        if filename ~= "" then
          local dir = vim.fn.fnamemodify(filename, ":h")
          if dir ~= "." and dir ~= "" and vim.fn.isdirectory(dir) == 0 then
            vim.fn.mkdir(dir, "p")
          end
          vim.cmd("edit " .. vim.fn.fnameescape(filename))
          vim.cmd("write")
          return
        end

        vim.ui.input({ prompt = "New file: " }, function(filename)
          if filename and filename ~= "" then
            local dir = vim.fn.fnamemodify(filename, ":h")
            if dir ~= "." and dir ~= "" and vim.fn.isdirectory(dir) == 0 then
              vim.fn.mkdir(dir, "p")
            end
            vim.cmd("edit " .. vim.fn.fnameescape(filename))
            vim.cmd("write")
          end
        end)
      elseif selection ~= "" then
        vim.cmd("edit " .. vim.fn.fnameescape(selection))
      end
    end,
    options = table.concat({
      "--expect=ctrl-e",
      "--prompt='Files (Ctrl-E: create)> '",
      "--print-query",
      "--preview='" .. preview .. "'",
    }, " "),
  }))
end

function M.setup()
  map("n", "<C-p>", M.find_files, { desc = "Find files" })
  map("n", "<leader>ff", M.find_files, { desc = "Find files" })
  map("n", "<leader>fb", "<cmd>Buffers<cr>", { desc = "Find buffers" })
  map("n", "<leader>;", "<cmd>Buffers<cr>", { desc = "Find buffers" })
  map("n", "<leader>sg", "<cmd>Rg<cr>", { desc = "Search by grep" })
  map("n", "<leader>rg", "<cmd>Rg<cr>", { desc = "Search by grep" })
  map("n", "<leader>ss", function()
    vim.lsp.buf.workspace_symbol("")
  end, { desc = "Search workspace symbols" })

  map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })
  map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
  map("n", ";", ":", { desc = "Command mode" })

  map("n", "<leader>p", '"+p', { desc = "Paste from clipboard" })
  map("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
  map("v", "<leader>y", '"+y', { desc = "Yank to clipboard" })

  map("", "H", "^", { desc = "Start of line" })
  map("", "L", "$", { desc = "End of line" })
  map("n", "<leader><leader>", "<c-^>", { desc = "Toggle buffers" })

  map("n", "<C-h>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })
  map("n", "n", "nzz", { silent = true, desc = "Next result centered" })
  map("n", "N", "Nzz", { silent = true, desc = "Previous result centered" })

  map("i", "jk", "<Esc>", { desc = "Exit insert mode" })
  map("v", "jk", "<Esc>", { desc = "Exit visual mode" })
  map("t", "jk", "<C-\\><C-n>", { desc = "Exit terminal mode" })

  map("n", "<leader>j", "<C-w>j", { desc = "Move to window below" })
  map("n", "<leader>k", "<C-w>k", { desc = "Move to window above" })
  map("n", "<leader>l", "<C-w>l", { desc = "Move to window right" })
  map("n", "<leader>h", "<C-w>h", { desc = "Move to window left" })

  map("n", "<leader>sv", "<cmd>vsplit<cr>", { desc = "Vertical split" })
  map("n", "<leader>sh", "<cmd>split<cr>", { desc = "Horizontal split" })
  map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })
  map("n", "<leader>s=", "<C-w>=", { desc = "Equal splits" })

  map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Open quickfix" })
  map("n", "<leader>xQ", "<cmd>cclose<cr>", { desc = "Close quickfix" })
  map("n", "[q", "<cmd>cprev<cr>", { desc = "Previous quickfix" })
  map("n", "]q", "<cmd>cnext<cr>", { desc = "Next quickfix" })

  map("v", "<", "<gv", { desc = "Indent left" })
  map("v", ">", ">gv", { desc = "Indent right" })

  map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down" })
  map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up" })
  map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
  map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })
end

M.setup()

return M
