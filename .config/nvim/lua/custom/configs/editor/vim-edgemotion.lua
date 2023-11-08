local status, vim_edgemotion = pcall(require, "vim-edgemotion")
if (not status) then return end

vim.api.nvim_set_keymap("n", "<C-j>", "<Plug>(edgemotion-j)", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<Plug>(edgemotion-k)", { noremap = true, silent = true })

