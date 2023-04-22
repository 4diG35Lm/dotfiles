-- local autocmd = vim.api.nvim_create_autocmd

-- Auto resize panes when resizing nvim window
-- autocmd("VimResized", {
--   pattern = "*",
--   command = "tabdo wincmd =",
-- })
require "custom.core.utils"
require "custom.base"
require "custom.display"
require "custom.autocmd"
require "custom.option"
if vim.g.vscode then
  require "custom.vscode-neovim.mappings"
end
vim.defer_fn(function()
  require "custom.command"
end, 50)
