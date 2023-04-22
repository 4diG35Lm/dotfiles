local status, spectre = pcall(require, "spectre")
if (not status) then return end

vim.cmd("command! SpectreOpen lua require('spectre').open()")
