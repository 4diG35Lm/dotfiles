-- custom.init
local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
	pattern = "*",
	command = "tabdo wincmd =",
})
require("custom.base")
require("custom.display")
require("custom.autocmd")
require("custom.option")
require("custom.lsp.config")
if vim.g.vscode then
	require("custom.vscode-neovim.mappings")
	require("custom.vscode-neovim.options")
end
vim.defer_fn(function()
	require("custom.command")
end, 50)
