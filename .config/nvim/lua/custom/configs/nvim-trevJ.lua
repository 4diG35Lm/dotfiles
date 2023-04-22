local status, trevJ = pcall(require, "trevJ")
if (not status) then return end

vim.keymap.set("n", "<Leader>=", function()
	trevj.format_at_cursor()
end, { noremap = true, silent = true })
