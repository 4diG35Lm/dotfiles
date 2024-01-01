local status, dap = pcall(require, "dap")
if (not status) then return end

require("nvim-dap-virtual-text").setup {}
local dap_python = require("dap-python")
-- キーマッピングの設定
vim.api.nvim_set_keymap('n', '<F5>', '<cmd>lua require"dap".continue()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F10>', '<cmd>lua require"dap".step_over()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F11>', '<cmd>lua require"dap".step_into()<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F12>', '<cmd>lua require"dap".step_out()<CR>', { noremap = true, silent = true })

vim.schedule(function()
  require("dapui").setup()
  require("mason-nvim-dap").setup {
    handlers = {},
  }
  require("dap.ext.vscode").load_launchjs(nil, {
    coreclr = { "cs" },
  })
end)
dap.configurations.lua = {
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  },
}

dap.adapters.rust = {
  type = "executable",
  attach = { pidProperty = "pid", pidSelect = "ask" },
  command = "lldb-vscode", -- my binary was called 'lldb-vscode-11'
  env = { LLDB_LAUNCH_FLAG_LAUNCH_IN_TTY = "YES" },
  name = "lldb",
}
dap.adapters.python = {
  type = 'executable',
  command = 'python',
  args = { '-m', 'debugpy.adapter' },
}

dap.configurations.python = {
  {
    type = 'python',
    request = 'launch',
    name = 'Launch file',
    program = "${file}",
    pythonPath = function()
      return '/usr/local/bin/python'
    end,
  },
}
-- keymap
dap.adapters.nlua = function(callback, config)
  callback({ type = "server", host = config.host or "127.0.0.1", port = config.port or 8086 })
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
