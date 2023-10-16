vim.keymap.set({ "n", "x" }, "p", require("pasta.mappings").p)
vim.keymap.set({ "n", "x" }, "P", require("pasta.mappings").P)
vim.keymap.set({ "n" }, "<C-p>", require("pasta.mappings").toggle_pin)

-- This is the default. You can omit `setup` call if you don't want to change this.
require("pasta").setup {
  paste_mode = true,
  fix_cursor = true,
  fix_indent = true,
  prevent_diagnostics = false,
  next_key = vim.api.nvim_replace_termcodes("<C-p>", true, true, true),
  prev_key = vim.api.nvim_replace_termcodes("<C-n>", true, true, true),
}
