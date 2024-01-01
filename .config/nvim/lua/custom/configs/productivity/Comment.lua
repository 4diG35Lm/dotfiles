local status, comment = pcall(require, "Comment")
if not status then
  return
end
local api = vim.api

comment.setup({
})

 api.nvim_set_keymap("n", "<C-_>", "<Cmd>lua require('Comment.api').toggle.linewise.current()<CR>", {})
 api.nvim_set_keymap("i", "<C-_>", "<Esc>:<C-u>lua require('Comment.api').toggle.linewise.current()<CR>\"_cc", {})
 api.nvim_set_keymap("v", "<C-_>", "gc", {})
 api.nvim_set_keymap("n", "<C-/>", "<Cmd>lua require('Comment.api').toggle.linewise.current()<CR>", {})
 api.nvim_set_keymap("i", "<C-/>", "<Esc>:<C-u>lua require('Comment.api').toggle.linewise.current()<CR>\"_cc", {})
api.nvim_set_keymap("v", "<C-/>", "gc", {})
