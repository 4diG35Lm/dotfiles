local status, contextprint = pcall(require, "contexprint")
if (not status) then return end
contextprint.setup({
	separator_char = ":",
})
