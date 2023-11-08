local status, catppuccin = pcall(require, "catppuccin")
if not status then
  return
end

local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd

catppuccin.setup({
  transparent_background = true,
  integrations = {
    aerial = true,
    dap = { enabled = true, enable_ui = true },
    dashboard = true,
    cmp = true,
    flash = true,
    gitsigns = true,
    harpoon = true,
    illuminate = { enabled = true, lsp = true },
    indent_blankline = { enabled = true },
    lsp_trouble = true,
    markdown = true,
    mason = true,
    mini = true,
    native_lsp = {
      enabled = true,
      virtual_text = {
        errors = { "italic" },
        hints = { "italic" },
        warnings = { "italic" },
        information = { "italic" },
      },
      underlines = {
        errors = { "undercurl" },
        hints = { "undercurl" },
        warnings = { "undercurl" },
        information = { "undercurl" },
      },
      inlay_hints = {
        background = true,
      },
    },
    neotest = true,
    neotree = true,
    noice = true,
    notify = true,
    semantic_tokens = true,
    telescope = { enabled = true },
    treesitter = true,
    treesitter_context = true,
    which_key = true,
  },
})
