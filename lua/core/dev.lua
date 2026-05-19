local M = {}

local uv = vim.uv or vim.loop

local function notify(message, level)
  vim.notify(message, level or vim.log.levels.INFO, { title = "workstation" })
end

local function shellescape(value)
  return vim.fn.shellescape(value)
end

local function command_exists(command)
  return vim.fn.executable(command) == 1
end

local function project_root()
  local ok, root = pcall(vim.fn.systemlist, { "git", "rev-parse", "--show-toplevel" })
  if ok and vim.v.shell_error == 0 and root[1] and root[1] ~= "" then
    return root[1]
  end
  return vim.fn.getcwd()
end

local function run_terminal(command, opts)
  opts = opts or {}
  local cwd = opts.cwd or project_root()

  local ok, terminal = pcall(require, "toggleterm.terminal")
  if ok then
    terminal.Terminal:new({
      cmd = command,
      dir = cwd,
      direction = "float",
      close_on_exit = false,
      hidden = true,
    }):toggle()
    return
  end

  vim.cmd("botright split")
  vim.cmd("terminal cd " .. shellescape(cwd) .. " && " .. command)
  vim.cmd("startinsert")
end

local function collect_projects()
  local roots = {
    vim.fn.expand("~/dev"),
    vim.fn.expand("~/projects"),
    vim.fn.expand("~/.dotfiles"),
  }

  local seen = {}
  local projects = {}

  local function add_dir(path)
    if path == "" then
      return
    end
    path = vim.fn.fnamemodify(path, ":p")
    path = path:gsub("/$", "")
    if seen[path] or vim.fn.isdirectory(path) == 0 then
      return
    end
    seen[path] = true
    table.insert(projects, path)
  end

  for _, root in ipairs(roots) do
    if vim.fn.isdirectory(root) == 1 then
      add_dir(root)
      local markers = { ".git", "go.mod", "Cargo.toml", "package.json", "pyproject.toml", "Makefile", "justfile" }
      for _, marker in ipairs(markers) do
        local found = vim.fn.systemlist({
          "find",
          root,
          "-maxdepth",
          "4",
          "-name",
          marker,
          "-print",
        })
        for _, item in ipairs(found) do
          add_dir(vim.fn.fnamemodify(item, ":p:h"))
        end
      end
    end
  end

  table.sort(projects)
  return projects
end

local function open_project(path)
  if not path or path == "" then
    return
  end
  vim.cmd("cd " .. vim.fn.fnameescape(path))
  vim.cmd("edit .")
  notify("Project: " .. path)
end

function M.project_picker()
  local projects = collect_projects()
  if #projects == 0 then
    notify("No projects found", vim.log.levels.WARN)
    return
  end

  if vim.fn.exists("*fzf#run") == 1 then
    vim.fn["fzf#run"](vim.fn["fzf#wrap"]({
      source = projects,
      sink = open_project,
      options = "--prompt='Projects> ' --height=40% --layout=reverse",
    }))
    return
  end

  vim.ui.select(projects, { prompt = "Project" }, open_project)
end

function M.dev_doctor()
  run_terminal("dev-repo-doctor")
end

function M.dev_pr()
  run_terminal("dev-pr")
end

function M.dev_checks()
  run_terminal("dev-gh checks")
end

function M.dev_reviews()
  run_terminal("dev-gh reviews")
end

function M.dev_open_pr()
  run_terminal("dev-gh open")
end

function M.dev_update()
  run_terminal("dev-update --check", { cwd = vim.fn.expand("~/.dotfiles") })
end

function M.dev_backup()
  run_terminal("dev-backup --run", { cwd = vim.fn.expand("~/.dotfiles") })
end

function M.dev_signing()
  run_terminal("dev-signing-doctor --check", { cwd = vim.fn.expand("~/.dotfiles") })
end

function M.dev_fonts()
  run_terminal("dev-fonts --check", { cwd = vim.fn.expand("~/.dotfiles") })
end

function M.dev_perf()
  run_terminal("dev-perf --run", { cwd = vim.fn.expand("~/.dotfiles") })
end

function M.db_psql(opts)
  opts = opts or {}
  local args = opts.args or ""
  if args == "" then
    run_terminal("psql ${DATABASE_URL:-}")
  else
    run_terminal("psql " .. shellescape(args))
  end
end

function M.db_redis(opts)
  opts = opts or {}
  local args = opts.args or ""
  if args == "" then
    run_terminal("redis-cli")
  else
    run_terminal("redis-cli " .. args)
  end
end

function M.db_sqlite(opts)
  opts = opts or {}
  local args = opts.args or ""
  if args == "" then
    vim.ui.input({ prompt = "SQLite database: ", default = "dev.db" }, function(path)
      if path and path ~= "" then
        run_terminal("sqlite3 " .. shellescape(path))
      end
    end)
  else
    run_terminal("sqlite3 " .. shellescape(args))
  end
end

function M.trim_lsp_log(max_mb)
  max_mb = tonumber(max_mb) or 256
  local path = vim.lsp.log.get_filename()
  local stat = uv.fs_stat(path)
  if not stat or stat.size < max_mb * 1024 * 1024 then
    return false
  end

  local backup = path .. ".old"
  os.remove(backup)
  local ok, err = os.rename(path, backup)
  if not ok then
    notify("Could not rotate LSP log: " .. tostring(err), vim.log.levels.WARN)
    return false
  end

  vim.fn.writefile({}, path)
  notify(string.format("Rotated LSP log over %d MB to %s", max_mb, backup))
  return true
end

function M.setup_commands()
  vim.api.nvim_create_user_command("DevProject", M.project_picker, { desc = "Pick a project" })
  vim.api.nvim_create_user_command("DevDoctor", M.dev_doctor, { desc = "Run repo doctor" })
  vim.api.nvim_create_user_command("DevPr", M.dev_pr, { desc = "Show PR status" })
  vim.api.nvim_create_user_command("DevChecks", M.dev_checks, { desc = "Show PR checks or recent runs" })
  vim.api.nvim_create_user_command("DevReviews", M.dev_reviews, { desc = "Show formal and inline PR review context" })
  vim.api.nvim_create_user_command("DevOpenPr", M.dev_open_pr, { desc = "Open PR create/view flow" })
  vim.api.nvim_create_user_command("DevUpdate", M.dev_update, { desc = "Preview workstation update commands" })
  vim.api.nvim_create_user_command("DevBackup", M.dev_backup, { desc = "Create workstation config backup" })
  vim.api.nvim_create_user_command("DevSigning", M.dev_signing, { desc = "Check Git signing setup" })
  vim.api.nvim_create_user_command("DevFonts", M.dev_fonts, { desc = "Check terminal font and theme setup" })
  vim.api.nvim_create_user_command("DevPerf", M.dev_perf, { desc = "Run workstation performance audit" })
  vim.api.nvim_create_user_command("DbPsql", M.db_psql, { nargs = "?", desc = "Open psql console" })
  vim.api.nvim_create_user_command("DbRedis", M.db_redis, { nargs = "*", desc = "Open redis-cli console" })
  vim.api.nvim_create_user_command("DbSqlite", M.db_sqlite, { nargs = "?", complete = "file", desc = "Open sqlite3 console" })
  vim.api.nvim_create_user_command("NvimTrimLspLog", function(opts)
    M.trim_lsp_log(opts.args)
  end, { nargs = "?", desc = "Rotate oversized Neovim LSP log" })
end

function M.setup_keymaps()
  vim.keymap.set("n", "<leader>fp", M.project_picker, { desc = "Find projects" })
  vim.keymap.set("n", "<leader>od", M.dev_doctor, { desc = "Repo doctor" })
  vim.keymap.set("n", "<leader>op", M.dev_pr, { desc = "PR status" })
  vim.keymap.set("n", "<leader>oc", M.dev_checks, { desc = "PR checks" })
  vim.keymap.set("n", "<leader>or", M.dev_reviews, { desc = "PR reviews" })
  vim.keymap.set("n", "<leader>oP", M.dev_open_pr, { desc = "Open/create PR" })
  vim.keymap.set("n", "<leader>ou", M.dev_update, { desc = "Update preview" })
  vim.keymap.set("n", "<leader>ob", M.dev_backup, { desc = "Backup config" })
  vim.keymap.set("n", "<leader>os", M.dev_signing, { desc = "Signing doctor" })
  vim.keymap.set("n", "<leader>of", M.dev_fonts, { desc = "Font/theme doctor" })
  vim.keymap.set("n", "<leader>oT", M.dev_perf, { desc = "Performance audit" })
  vim.keymap.set("n", "<leader>ol", function()
    M.trim_lsp_log(64)
  end, { desc = "Trim LSP log" })
end

function M.setup()
  pcall(vim.lsp.log.set_level, vim.lsp.log.levels.WARN)
  M.setup_commands()
  M.setup_keymaps()
  M.trim_lsp_log(256)
end

M.setup()

return M
