local status, vim_quickhl = pcall(require, "vim-quickhl")
if (not status) then return end

vim_quickhl.setup()

