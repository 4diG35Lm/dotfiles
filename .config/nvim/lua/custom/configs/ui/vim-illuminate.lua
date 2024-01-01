local status, nvim_illuminate = pcall(require, "nvim-illuminate")
if (not status) then return end
vim.g.Illuminate_delay = 300
