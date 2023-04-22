local status, nvim_cursorword = pcall(require, "nvim-cursorword")
if (not status) then return end
vim.g.cursorword_min_width = 3
vim.g.cursorword_max_width = 20
vim.g.cursorword_disable_filetypes = { "TelescopePrompt" }
vim.cmd("hi! def link CursorWord CursorLine")
