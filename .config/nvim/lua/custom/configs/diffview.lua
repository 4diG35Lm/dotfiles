local status, diffview = pcall(require, "diffview")
if (not status) then return end

vim.api.nvim_set_keymap("n", "[_Git]d", "<Cmd>DiffviewOpen<CR>", { noremap = true, silent = true })
