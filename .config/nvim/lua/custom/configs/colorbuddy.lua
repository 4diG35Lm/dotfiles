local status, colorbuddy = pcall(require, "colorbuddy")
if (not status) then return end

colorbuddy.colorscheme("gruvbox")
vim.g['gruvbox_contrast_dark'] = "medium"
vim.o.bg = 'dark'
