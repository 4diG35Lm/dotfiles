local status,  CamelCaseMotion = pcall(require,  "CamelCaseMotion")
if (not status) then return end


vim.keymap.set("", "<leader>w", "<Plug>CamelCaseMotion_w", {})
vim.keymap.set("", "<leader>b", "<Plug>CamelCaseMotion_b", { noremap = true, silent = true })
vim.keymap.set("", "<leader>e", "<Plug>CamelCaseMotion_e", { noremap = true, silent = true })
vim.keymap.set("", "<leader>ge", "<Plug>CamelCaseMotion_ge", { noremap = true, silent = true })
