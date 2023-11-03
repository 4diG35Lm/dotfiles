-- "custom.Treesitter.config"
local status, nvim_treesitter = pcall(require, "nvim-treesitter")
if not status then
	return
end

nvim_treesitter.setup({
	highlight = {
		enable = true,
	},
	-- enable indentation
	indent = { enable = true },
	-- enable autotagging (w/ nvim-ts-autotag plugin)
	autotag = {
		enable = true,
	},
	-- ensure these language parsers are installed
	ensure_installed = {
		"json",
		"javascript",
		"typescript",
		"tsx",
		"yaml",
		"html",
		"css",
		"prisma",
		"markdown",
		"markdown_inline",
		"svelte",
		"graphql",
		"bash",
		"lua",
		"vim",
		"dockerfile",
		"gitignore",
		"query",
	},
	incremental_selection = {
		enable = true,
		keymaps = {
			init_selection = "<C-space>",
			node_incremental = "<C-space>",
			scope_incremental = false,
			node_decremental = "<bs>",
		},
	},
	-- enable nvim-ts-context-commentstring plugin for commenting tsx and jsx
	context_commentstring = {
		enable = true,
		enable_autocmd = false,
	},
})
