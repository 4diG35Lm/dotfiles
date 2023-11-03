-- custom.configs.nvim-dap
local status, dap = pcall(require, "dap")
if not status then
  return
end

require("core.utils").load_mappings "dap"
dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  },
}

require("dap-vscode-js").setup {
  debugger_path = vim.fn.stdpath "data" .. "/lazy/vscode-js-debug",
  adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" }, -- which adapters to register in nvim-dap
}

for _, language in ipairs { "typescript", "javascript", "typescriptreact" } do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Attach",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
    },
    {
      type = "pwa-node",
      request = "launch",
      name = "Debug Jest Tests",
      -- trace = true, -- include debugger info
      runtimeExecutable = "node",
      runtimeArgs = {
        "./node_modules/jest/bin/jest.js",
        "--runInBand",
      },
      rootPath = "${workspaceFolder}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      internalConsoleOptions = "neverOpen",
    },
  }
end

dap.adapters.rust = {
  type = "executable",
  attach = { pidProperty = "pid", pidSelect = "ask" },
  command = "lldb-vscode", -- my binary was called 'lldb-vscode-11'
  env = { LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES" },
  name = "lldb",
}

dap.adapters.nlua = function(callback, config)
  callback { type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 }
end

for _, language in ipairs { "typescript", "javascript" } do
  dap.configurations[language] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Launch file",
      program = "${file}",
      cwd = "${workspaceFolder}",
      runtimeExecutable = "node",
    },
  }
end
vim.fn.sign_define("DapBreakpoint", { text = "🛑", texthl = "", linehl = "", numhl = "" })

-- do not use a/d/r(sandwich)
vim.api.nvim_set_keymap("n", "[_Debugger]", "<Nop>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "s", "[_Debugger]", {})
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]b",
  "<Cmd>lua require'dap'.toggle_breakpoint()<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "[_Debugger]c", "<Cmd>lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_Debugger]n", "<Cmd>lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_Debugger]i", "<Cmd>lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_Debugger]o", "<Cmd>lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_Debugger]R", "<Cmd>lua require'dap'.repl.open()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]B",
  "<Cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]l",
  "<Cmd>lua require'dap'.load_launchjs()<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "[_Debugger]g", "<Cmd>lua require'dap'.run_last()<CR>", { noremap = true, silent = true })
-- telescope
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]H",
  "<Cmd>lua require'telescope'.extensions.dap.commands{}<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]C",
  "<Cmd>lua require'telescope'.extensions.dap.configurations{}<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]P",
  "<Cmd>lua require'telescope'.extensions.dap.list_breakpoints{}<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]V",
  "<Cmd>lua require'telescope'.extensions.dap.variables{}<CR>",
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]q",
  "<Cmd>lua require'dap'.disconnect({})<CR>",
  { noremap = true, silent = true }
)
