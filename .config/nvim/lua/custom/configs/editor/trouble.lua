local status, trouble = pcall(require, "trouble")
if not status then
  return
end

local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd
local opts = { noremap = true, silent = true }
local g = vim.g

-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================
g.mapleader = " "
g.maplocalleader = " "

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
trouble.setup ({})

map("n", "[_Lsp]xx", "<cmd>Trouble<cr>", opts)
map("n", "[_Lsp]xw", "<cmd>Trouble workspace_diagnostics<cr>", opts)
map("n", "[_Lsp]xd", "<cmd>Trouble document_diagnostics<cr>", opts)
map("n", "[_Lsp]xl", "<cmd>Trouble loclist<cr>", opts)
map("n", "[_Lsp]xq", "<cmd>Trouble quickfix<cr>", opts)
map("n", "gR", "<cmd>Trouble lsp_references<cr>", opts)
map("n", "[q",
  function()
    if trouble.is_open() then
      trouble.previous({ skip_groups = true, jump = true })
    else
      local ok, err = pcall(vim.cmd.cprev)
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end
  end, opts
)
map("n", "]q",
  function()
    if trouble.is_open() then
      trouble.next({ skip_groups = true, jump = true })
    else
      local ok, err = pcall(vim.cmd.cnext)
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
      end
    end
  end, opts
)
