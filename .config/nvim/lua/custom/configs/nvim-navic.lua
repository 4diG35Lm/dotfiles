local status, nvim_navic = pcall(require, "nvim-navic")
if (not status) then return end

vim.g.navic_silence = true
