local M = {}

local function split_args(input)
  if input == nil or input == "" then
    return {}
  end

  return vim.split(input, " ", { trimempty = true })
end

function M.setup_adapters(dap)
  local codelldb = vim.fn.exepath("codelldb")
  if codelldb ~= "" then
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb,
        args = { "--port", "${port}" },
      },
    }

    local native_config = {
      {
        name = "Launch executable",
        type = "codelldb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        args = function()
          return split_args(vim.fn.input("Args: "))
        end,
      },
    }

    dap.configurations.c = native_config
    dap.configurations.cpp = native_config
    dap.configurations.rust = native_config
  end

  local delve = vim.fn.exepath("dlv")
  if delve ~= "" then
    dap.adapters.go = {
      type = "server",
      port = "${port}",
      executable = {
        command = delve,
        args = { "dap", "-l", "127.0.0.1:${port}" },
      },
    }

    dap.configurations.go = {
      {
        type = "go",
        name = "Debug package",
        request = "launch",
        program = "${fileDirname}",
      },
      {
        type = "go",
        name = "Debug test",
        request = "launch",
        mode = "test",
        program = "${fileDirname}",
      },
    }
  end
end

function M.setup()
  local dap = require("dap")
  local dapui = require("dapui")

  require("mason-nvim-dap").setup({
    ensure_installed = { "codelldb", "delve" },
    automatic_installation = true,
    handlers = {},
  })

  dapui.setup()
  M.setup_adapters(dap)

  dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
  end
  dap.listeners.before.event_terminated["dapui_config"] = function()
    dapui.close()
  end
  dap.listeners.before.event_exited["dapui_config"] = function()
    dapui.close()
  end

  vim.fn.sign_define("DapBreakpoint", { text = "B", texthl = "DiagnosticError" })
  vim.fn.sign_define("DapBreakpointCondition", { text = "C", texthl = "DiagnosticWarn" })
  vim.fn.sign_define("DapStopped", { text = ">", texthl = "DiagnosticInfo", linehl = "Visual" })
end

return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "nvim-neotest/nvim-nio",
      "jay-babu/mason-nvim-dap.nvim",
    },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Condition: "))
        end,
        desc = "Conditional breakpoint",
      },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>dO", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      { "<leader>dx", function() require("dap").terminate() end, desc = "Terminate" },
    },
    config = M.setup,
  },
}
