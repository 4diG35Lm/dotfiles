local status, stf = pcall(require, "syntax-tree-surfer")
if (not status) then return end

stf.setup()
vim.keymap.set("n", ",j", function()
	stf.filtered_jump("default", true)
end, { noremap = true, silent = true })
vim.keymap.set("n", ",k", function()
	stf.filtered_jump("default", false)
end, { noremap = true, silent = true })
