local status, statusline = pcall(require, "statusline")
if (not status) then return end

require("statusline").lsp_diagnostics = true
require("statusline").tabline =  true
vim.o.laststatus=3
