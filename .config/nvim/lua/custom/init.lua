local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
autocmd("VimResized", {
  pattern = "*",
  command = "tabdo wincmd =",
})
require "custom.core.utils"
require "custom.profile"
-- require "custom.mappings"
require "custom.base"
require "custom.display"
require "custom.autocmd"
require "custom.option"
require "custom.filetype"
if vim.g.vscode then
  require "custom.vscode-neovim.mappings"
  require "custom.vscode-neovim.options"
end
vim.defer_fn(function()
  require "custom.command"
end, 50)
-- Configure lazy
require "custom.Telescope.init"
require "custom.Treesitter.init"
require "custom.cmp.init"
require "custom.lsp.init"
