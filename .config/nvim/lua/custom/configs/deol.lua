local status, deol = pcall(require, "deol")
if (not status) then return end
local util = require('util')
vim.g['deol#shell_history_path'] = '~/.zsh_history'
util.map('n', '<leader>df', ':<C-u>Deol -split=floating<CR>')
util.map('n', '<leader>dv', ':<C-u>Deol -split=vertical<CR>')
util.map('n', '<leader>ds', ':<C-u>Deol -split=horizontal<CR>')
