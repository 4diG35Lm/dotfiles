local status, iron = pcall(require, "iron")
if (not status) then return end

iron.core.setup({
	config = {
		repl_open_cmd = "rightbelow 10 split",
	},
})
