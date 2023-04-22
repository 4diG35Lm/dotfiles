local status, teskrun = pcall(require, "teskrun")
if (not status) then return end

taskrun.setup()
vim.api.nvim_set_keymap("n", "[_Make]m", "<Cmd>TaskRunToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_Make]q", "<Cmd>TaskRunToggle<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_Make]r", "<Cmd>TaskRunLast<CR>", { noremap = true, silent = true })
