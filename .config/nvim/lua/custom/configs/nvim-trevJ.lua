-- custom.configs.trevj
local status, trevj = pcall(require, "trevj")
if not status then
	return
end

trevj.setup({
	containers = {
		lua = {
			table_constructor = { final_separator = ",", final_end_line = true },
			arguments = { final_separator = false, final_end_line = true },
			parameters = { final_separator = false, final_end_line = true },
		},
	},
})
vim.keymap.set("n", "<Leader>=", function()
	trevj.format_at_cursor()
end, { noremap = true, silent = true })
