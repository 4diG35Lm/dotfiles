local status, spellsitter = pcall(require, "spellsitter")
if (not status) then return end

spellsitter.setup({
  -- Whether enabled, can be a list of filetypes, e.g. {'python', 'lua'}
  enable = true,
  debug = false
})
local my_augroup = vim.api.nvim_create_augroup("my_augroup", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "lua" }, -- disable spellchecking for these filetypes
  command = "setlocal nospell",
  group = my_augroup,
})
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*", -- disable spellchecking in the embeded terminal
  command = "setlocal nospell",
  group = my_augroup,
})
