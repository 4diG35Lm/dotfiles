if vim.g.vscode then
  vim.keymap.set("n", "<leader>o", "<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>")
  vim.keymap.set("n", "<leader>d", "<Cmd>call VSCodeNotify('workbench.action.files.save')<CR>")
  vim.keymap.set("n", "H", "<Cmd>call VSCodeNotify('workbench.action.previousEditor')<CR>")
  vim.keymap.set("n", "L", "<Cmd>call VSCodeNotify('workbench.action.nextEditor')<CR>")
  vim.keymap.set(
    "n",
    "<Leader>p",
    "<<Cmd>call VSCodeNotify('workbench.action.quickOpen')<CR>>",
    { noremap = true, silent = true }
  )
else
  vim.keymap.set("n", "<leader>o", function()
    require("telescope.builtin").find_files { hidden = true }
  end)
  vim.keymap.set("n", "<leader>d", "<Cmd>bd<CR>")
  vim.keymap.set("n", "H", "<Cmd>bp<CR>")
  vim.keymap.set("n", "L", "<Cmd>bn<CR>")
end
