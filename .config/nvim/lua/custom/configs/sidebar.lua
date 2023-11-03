local status, sidebar_nvim = pcall(require, "sidebar-nvim")
if (not status) then return end
sidebar_nvim.setup({
	disable_default_keybindings = 0,
	bindings = {
		["q"] = function()
			sidebar_nvim.close()
		end,
	},
	open = false,
	side = "right",
	initial_width = 35,
	update_interval = 1000,
	section_separator = "-----",
})

vim.api.nvim_set_keymap("n", "gs", "<Cmd>SidebarNvimToggle<CR>", { noremap = true, silent = true })
