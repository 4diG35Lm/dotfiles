local status, dapui = pcall(require, "dapui")
if not status then
  return
end

local dap = require "dap"

dapui.setup {}

dap.listeners.after.event_initialized["dapui_config"] = function()
  dapui.open {}
end
dap.listeners.before.event_terminated["dapui_config"] = function()
  dapui.close {}
end
dap.listeners.before.event_exited["dapui_config"] = function()
  dapui.close {}
end

vim.api.nvim_set_keymap(
  "n",
  "[_Debugger]x",
  '<Cmd>lua require("dapui").toggle()<CR>',
  { noremap = true, silent = true }
)
vim.api.nvim_set_keymap("v", "[_Debugger]e", '<Cmd>lua require("dapui").eval()<CR>', { noremap = true, silent = true })
