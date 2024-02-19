local status, wk = pcall(require, "which-key")
if (not status) then return end

local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd
local keymap = vim.keymap
local g = vim.g
local o = vim.o
local opt = vim.opt
local tbl = vim.tbl_deep_extend
o.timeout = true
o.timeoutlen = 300
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = tbl("force", options, opts)
  end
  keymap.set(mode, lhs, rhs, options)
end
wk.register({
  ["<C-l>"] = 'Whole lines',
  ["<C-n>"] = 'keywords in the current file',
  ["<C-k>"] = 'keywords in dictionary',
  ["<C-t>"] = 'keywords in thesaurus',
  ["<C-i>"] = 'keywords in the current and included files',
  ["<C-]>"] = 'tags',
  ["<C-f>"] = 'file names',
  ["<C-d>"] = 'definitions or macros',
  ["<C-v>"] = 'Vim command-line',
  ["<C-u>"] = 'User defined completion',
  ["<C-o>"] = 'omni completion',
  ["<C-s>"] = 'Spelling suggestions',
  ["<C-z>"] = 'stop completion',
},{
  mode = {"n", "v"},
  prefix = "<C-x>"
})
-- set keymaps with `nowait`
-- see `:h :map-nowait`

-- a timer to call a callback after a specified number of milliseconds.
local function timeout(ms, callback)
  local uv = vim.uv
  local timer = uv.new_timer()
  local _callback = vim.schedule_wrap(function()
    uv.timer_stop(timer)
    uv.close(timer)
    callback()
  end)
  uv.timer_start(timer, ms, 0, _callback)
end
timeout(100, function()
  map(
    "n",
    "<Leader>",
    wk({ text_insert_in_advance = "<Leader>" }),
    { noremap = true, silent = true, desc = "[wf.nvim] which-key /", }
  )
end)
api.nvim_create_autocmd({"BufEnter", "BufAdd"}, {
  group = api.nvim_create_augroup("my_wf", { clear = true }),
  callback = function()
    timeout(100, function()
      map(
        "n",
        "<Leader>",
        wk{ text_insert_in_advance = "<Leader>" }),
        { noremap = true, silent = true, desc = "[wf.nvim] which-key /", buffer = true })
    end)
  end
})
local which_key = wk.builtin.which_key
local register = wk.builtin.register
local bookmark = wk.builtin.bookmark
local buffer = wk.builtin.buffer
local mark = wk.builtin.mark

-- Register
map(
  "n",
  "<Space>wr",
  -- register(opts?: table) -> function
  -- opts?: option
  register(),
  { noremap = true, silent = true, desc = "[wf.nvim] register" }
)

-- Bookmark
map(
  "n",
  "<Space>wbo",
  -- bookmark(bookmark_dirs: table, opts?: table) -> function
  -- bookmark_dirs: directory or file paths
  -- opts?: option
  bookmark({
    nvim = "~/.config/nvim",
    zsh = "~/.zshrc",
  }),
  { noremap = true, silent = true, desc = "[wf.nvim] bookmark" }
)

-- Buffer
map(
  "n",
  "<Space>wbu",
  -- buffer(opts?: table) -> function
  -- opts?: option
  buffer(),
  {noremap = true, silent = true, desc = "[wf.nvim] buffer"}
)

-- Mark
map(
  "n",
  "'",
  -- mark(opts?: table) -> function
  -- opts?: option
  mark(),
  { nowait = true, noremap = true, silent = true, desc = "[wf.nvim] mark"}
)

-- Which Key
map(
  "n",
  "<Leader>",
   -- mark(opts?: table) -> function
   -- opts?: option
  which_key({ text_insert_in_advance = "<Leader>" }),
  { noremap = true, silent = true, desc = "[wf.nvim] which-key /", }
)
wk.setup({
  plugins = {
    marks = false, -- shows a list of your marks on ' and `
    registers = false, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
    presets = {
      operators = false,
      motions = false, -- adds help for motions
      text_objects = false, -- help for text objects triggered after entering an operator
      windows = false, -- default bindings on <c-w>
      nav = false, -- misc bindings to work with windows
      z = false, -- bindings for folds, spelling and others prefixed with z
      g = false, -- bindings for prefixed with g
    },
  },
  icons = {
    breadcrumb = "»", -- symbol used in the command line area that shows your active key combo
    separator = "➜", -- symbol used between a key and it's label
    group = "+", -- symbol prepended to a group
  },
  window = {
    border = "none", -- none, single, double, shadow
    position = "bottom", -- bottom, top
    margin = { 1, 0, 1, 0 }, -- extra window margin [top, right, bottom, left]
    padding = { 2, 2, 2, 2 }, -- extra window padding [top, right, bottom, left]
  },
  layout = {
    height = { min = 4, max = 25 }, -- min and max height of the columns
    width = { min = 20, max = 50 }, -- min and max width of the columns
    spacing = 3, -- spacing between columns
  },
  hidden = { "<silent>", "<cmd>", "<Cmd>", "<CR>", "call", "lua", "^:", "^ " }, -- hide mapping boilerplate
  show_help = true,
  triggers = { "<Leader>" }, -- or specify a list manually
  buffer = nil,
})
