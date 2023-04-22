local status,  betterdigraphs = pcall(require,  "betterdigraphs")
if (not status) then return end

vim.keymap.set("i", "<C-d>", "<Cmd>lua require'betterdigraphs'.digraphs('i')<CR>", { noremap = true, silent = false })
