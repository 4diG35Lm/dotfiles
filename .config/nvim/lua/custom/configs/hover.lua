local status, hover = pcall(require, "hover")
if (not status) then return end

hover.setup({
	init = function()
		-- Require providers
		require("hover.providers.lsp")
		-- require('hover.providers.gh')
		-- require('hover.providers.man')
		-- require('hover.providers.dictionary')
	end,
	preview_opts = {
		border = nil,
	},
	title = true,
})

-- Setup keymaps
vim.keymap.set("n", "Q", hover.hover, { desc = "hover.nvim" })
vim.keymap.set("n", "gQ", hover.hover_select, { desc = "hover.nvim (select)" })
