local status, statusline = pcall(require, "statusline")
if (not status) then return end

statusline.lsp_diagnostics = false
statusline.tabline =  true
vim.o.laststatus=3
