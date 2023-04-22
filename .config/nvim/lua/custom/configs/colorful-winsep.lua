local status,  colorful_winsep = pcall(require,  "colorful-winsep")
if (not status) then return end

colorful_winsep.setup({
	highlight = { fg = vim.api.nvim_get_hl_by_name("FloatBorder", true)["foreground"], bg = "bg" },
})
