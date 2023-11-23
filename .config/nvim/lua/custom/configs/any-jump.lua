vim.g.any_jump_grouping_enabled = 1
vim.g.any_jump_disable_default_keybindings = 1
local opts = { noremap = true, silent = true }

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
map("n", "<Leader>j", "<Cmd>AnyJump<CR>", opts)
map("n", "<Leader>j", "<Cmd>AnyJumpVisual<CR>", opts)
map("n", "<Leader>l", "<Cmd>AnyJumpLastResults<CR>", opts)
