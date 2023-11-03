---@type MappingsTable
local M = {}

M.general = {
  n = {
    [";"] = { ":", "enter command mode", opts = { nowait = true } },
    ["C-h"] = { "NvimTreeToggle<cr>", "", opts = { silent = true, noremap = true } },
  },
}

-- more keybinds!

---------------------------------------------------------------------------------------------------+
-- Commands \ Modes | Normal | Insert | Command | Visual | Select | Operator | Terminal | Lang-Arg |
-- ================================================================================================+
-- map  / noremap   |    @   |   -    |    -    |   @    |   @    |    @     |    -     |    -     |
-- nmap / nnoremap  |    @   |   -    |    -    |   -    |   -    |    -     |    -     |    -     |
-- nmap / noremap  |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    -     |
-- imap / inoremap  |    -   |   @    |    -    |   -    |   -    |    -     |    -     |    -     |
-- cmap / cnoremap  |    -   |   -    |    @    |   -    |   -    |    -     |    -     |    -     |
-- vmap / vnoremap  |    -   |   -    |    -    |   @    |   @    |    -     |    -     |    -     |
-- xmap / xnoremap  |    -   |   -    |    -    |   @    |   -    |    -     |    -     |    -     |
-- smap / snoremap  |    -   |   -    |    -    |   -    |   @    |    -     |    -     |    -     |
-- omap / onoremap  |    -   |   -    |    -    |   -    |   -    |    @     |    -     |    -     |
-- tmap / tnoremap  |    -   |   -    |    -    |   -    |   -    |    -     |    @     |    -     |
-- lmap / lnoremap  |    -   |   @    |    @    |   -    |   -    |    -     |    -     |    @     |
---------------------------------------------------------------------------------------------------+
local opts = { noremap = true, silent = true }
local term_opts = { silent = true }
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================
vim.g.mapleader = " "

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
--Remap space as leader key
-- map("", "<Space>", "<Nop>", opts)

vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Split window
map("n", "ss", ":split<Return><C-w>w", opts)
map("n", "sv", ":vsplit<Return><C-w>w", opts)

-- Select all
map("n", "<C-a>", "gg<S-v>G", opts)

-- Do not yank with x
-- map("n", "x", '"_x', opts)

-- Delete a word backwards
map("n", "dw", 'vb"_d', opts)

-- 行の端に行く
map("n", "<Space>h", "^", opts)
map("n", "<Space>l", "$", opts)
-- 行末までのヤンクにする
map("n", "Y", "y$", opts)

-- <Space>q で強制終了
map("n", "<Space>q", ":<C-u>q!<Return>", opts)
-- Hide search result highlight:
vim.keymap.set("", "<Leader>f", ":nohlsearch<CR>", { remap = true, desc = "Stop highlighting search results" })

-- ESC*2 でハイライトやめる
map("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)
-- Open the tree-sitter playground. Used for debugging its queries.
vim.keymap.set("", "<Leader>t", ":TSPlaygroundToggle<CR>", { remap = true, desc = "Toggle tree-sitter playground" })

local function toggle_lsp_lines()
  local lines_shown = require("lsp_lines").toggle()
  vim.diagnostic.config { signs = not lines_shown }
end
local function toggle_spellcheck()
  vim.opt_local.spell = not (vim.opt_local.spell:get())
  print("spell: " .. tostring(vim.opt_local.spell:get()))
end
local function toggle_dark_mode()
  if vim.o.background == "light" then
    vim.o.background = "dark"
  else
    vim.o.background = "light"
  end
end

map("", "<Leader>l", toggle_lsp_lines, { desc = "Toggle lsp_lines" })
map("n", "<Leader>s", toggle_spellcheck, { desc = "Toggle spellchecker" })
map("n", "<Leader>d", toggle_dark_mode, { desc = "Toggle dark/light mode" })

-- XXX: Add git root name here?
-- use  system('git rev-parse --show-toplevel 2> /dev/null') and some awk
map("n", "<Leader>.", ":echo @%<CR>", { desc = "Echo filepath" })

-- Insert --
-- Press jk fast to exit insert mode
map("i", "jk", "<ESC>", opts)

-- コンマの後に自動的にスペースを挿入
map("i", ",", ",<Space>", opts)
-- Visual --
-- Stay in indent mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- ビジュアルモード時vで行末まで選択
map("v", "v", "$h", opts)

-- 0番レジスタを使いやすくした
map("v", "<C-p>", '"0p', opts)

-- custom leader
-- map({ "n", "x" }, "[_SubLeader]", "<Nop>", opts)
-- map("n", ",", "[_SubLeader]", {})
-- map("x", ",", "[_SubLeader]", {})

-- LSP mappings ---------------------------------------------------------------
-- These are configured even for buffers with no LSP. Otherwise, the mappings
-- are inactive when there's no LSP, and pressing them yields unexpected
-- results. Having the mapping results in an error, which is less unexpected
-- than keys not being mapped and having a different meaning.
map("n", "gd", vim.lsp.buf.definition, { remap = true })
map("n", "gD", vim.lsp.buf.declaration, { remap = true })
map("n", "<Leader>h", vim.lsp.buf.hover, { remap = true, desc = "Show hover details. Use twice to focus hover." })

-- TODO: I want this to close whenever i press enter on one
map("n", "<Leader>r", function()
  require("trouble").toggle "lsp_references"
end, { desc = "Show LSP references" })

map("n", "<Leader>e", function()
  require("trouble").toggle { "document_diagnostics", group = false }
end, { desc = "Show LSP errors/diagnostics" })

map("n", "<Leader>R", function()
  vim.lsp.buf.rename()
end, { desc = "Rename symbol under cursor" })
-- Autoformatting
map({ "n" }, "<Leader>a", function()
  vim.lsp.buf.format { async = true }
end, { remap = true, desc = "Autoformat code" })

map({ "v" }, "<Leader>a", function()
  -- XXX: This is supported by very few LSPs, but will fail silently if the
  -- current one does not support formatting ranges.
  vim.lsp.formatexpr()
end, { remap = true, desc = "Autoformat selected code" })

-- Show available code actions:
map({ "n", "v" }, "<Leader>A", function()
  require("fzf-lua").lsp_code_actions()
end, { remap = true, desc = "Apply LSP action" })

map("n", ";", "<Nop>", opts)
map("n", "[_Lsp]", "<Nop>", opts)
map("n", ";", "[_Lsp]", {})
-- [_Ts]
map("n", "[_Ts]", "<Nop>", opts)
map("n", "'", "[_Ts]", {})
map("n", "M", "<Nop>", opts)
map("n", "?", "<Nop>", opts)
map("n", "<C-s>", "<Nop>", opts)
-- sandwich & <spector>
map({ "n", "x" }, "s", "<Nop>", opts)
map({ "n", "x" }, "S", "<Nop>", opts)
-- [_Make]
map("n", "m", "<Nop>", opts)
map("n", "m", "[_Make]", {})
-- [_FuzzyFinder]
-- FZF mapping
--
-- If in a git repo, shows a file-picker for all non-ignored files. Untracked
-- failes are included too. If outside a git repo, just all files. Dotfiles are
-- always included.
--
-- TODO: It'd be great if files in pwd are weighted higher.
local function fuzzy_finder()
  -- Exclude currently focused file from the list:
  local current = vim.fn.expand "%"

  -- "hidden" includes dotfiles, but not git-ignored files and alike.
  local cmd = "fd --type f --type symlink --hidden"
  if current ~= "" then
    -- TODO: would be great to have an "extra_opts" flag in fzf
    cmd = string.format("%s --exclude %s", cmd, vim.fn.shellescape(current))
    -- FIXME: other files with the same name but different path are not included!
  end

  require("fzf-lua").files { cmd = cmd }
end
map("n", "<Leader>p", fuzzy_finder, { desc = "Open fuzzy finder" })
map({ "n", "x" }, "z", "<Nop>", opts)
map("n", "[_FuzzyFinder]", "<Nop>", opts)
map("v", "[_FuzzyFinder]", "<Nop>", opts)
map("n", "z", "[_FuzzyFinder]", {})
map("v", "z", "[_FuzzyFinder]", {})
map("n", "Z", "<Nop>", opts)
-- switch buffer
map("n", "H", "<Nop>", opts)
map("n", "L", "<Nop>", opts)
-- columnmove. use gJ
map("n", "J", "<Nop>", opts)
map("n", "K", "<Nop>", opts)
-- clever-f
map("n", "t", "<Nop>", opts)
map("n", "T", "<Nop>", opts)
-- git, use :10 or gG or GG
map("n", "G", "<Nop>", opts)
map("n", "G", "[_Git]", {})
-- not use, use RR
map("n", "R", "<Nop>", opts)
-- close
map("n", "X", "<Nop>", opts)
-- operator-replace
map("n", "U", "<Nop>", opts)
-- use 0, toggle statusline
map("n", "!", "<Nop>", opts)
-- barbar
map("n", "@", "<Nop>", opts)
map("n", "#", "<Nop>", opts)
-- g; g,
map("n", "^", "<Nop>", opts)
map("n", "&", "<Nop>", opts)
-- <C-x>
map("n", "_", "<Nop>", opts)
-- milfeulle
map("n", "<C-a>", "<Nop>", opts)
map("n", "<C-g>", "<Nop>", opts)
-- buffer close
map("n", "<C-x>", "<Nop>", opts)
-- switch window
map("n", "<C-h>", "<Nop>", opts)
map("n", "<C-j>", "<Nop>", opts)
map("n", "<C-k>", "<Nop>", opts)
map("n", "<C-l>", "<Nop>", opts)
-- floaterm
map("n", "<C-z>", "<Nop>", opts)
-- treesitter
map("n", "'", "<Nop>", opts)
-- vim-operator-convert-case
map("n", "~", "<Nop>", opts)
-- not use
map("n", "Q", "<Nop>", opts)
map("n", "C", "<Nop>", opts)
map("n", "D", "<Nop>", opts)
map("n", "Y", "<Nop>", opts)
map("n", "=", "<Nop>", opts)
map("n", "<C-q>", "<Nop>", opts)
map("n", "<C-c>", "<Nop>", { noremap = true, silent = true })

-- nnoremap <C-m> <Nop> " = <CR>
-- noremap <CR> <Nop> " use quickfix

vim.keymap.set("n", "qq", function()
  return vim.fn.reg_recording() == "" and "qq" or "q"
end, { noremap = true, expr = true })
map("n", "q", "<Nop>", opts)

map("n", "gh", "<Nop>", opts)
map("n", "gj", "<Nop>", opts)
map("n", "gk", "<Nop>", opts)
map("n", "gl", "<Nop>", opts)
map("n", "gn", "<Nop>", opts)
map("n", "gm", "<Nop>", opts)
map("n", "go", "<Nop>", opts)
map("n", "gq", "<Nop>", opts)
map("n", "gr", "<Nop>", opts)
map("n", "gs", "<Nop>", opts)
map("n", "gw", "<Nop>", opts)
map("n", "g^", "<Nop>", opts)
map("n", "g?", "<Nop>", opts)
map("n", "gQ", "<Nop>", opts)
map("n", "gR", "<Nop>", opts)
map("n", "gT", "<Nop>", opts)

-- remap
map("n", "gK", "K", opts)
-- map("n", "g~", "~", opts)
-- map("n", "G@", "@", opts)
map("n", "g=", "=", opts)
map("n", "gzz", "zz", opts)
map("n", "g?", "?", opts)
-- map("n", "gG", "G", opts)
-- map("n", "GG", "G", opts)
map({ "n", "x" }, "gJ", "J", opts)
map("n", "q", "<Cmd>close<CR>", opts)
map("n", "RR", "R", opts)
map("n", "CC", '"_C', opts)
map("n", "DD", "D", opts)
map("n", "YY", "y$", opts)
-- New tab
map("n", "te", ":tabedit", opts)
-- 新しいタブを一番右に作る
map("n", "gn", ":tabnew<Return>", opts)
-- move tab
map("n", "gh", "gT", opts)
map("n", "gl", "gt", opts)
map("n", "X", "<Cmd>tabclose<CR>", opts)
map("n", "<C-S-q>", "<Cmd>tabclose<CR>", opts)
map("n", "gj", "j", opts)
map("n", "gk", "k", opts)

-- move cursor
vim.keymap.set({ "n", "x" }, "j", function()
  return vim.v.count > 0 and "j" or "gj"
end, { noremap = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", function()
  return vim.v.count > 0 and "k" or "gk"
end, { noremap = true, expr = true })
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-s>", "<C-w>p", opts)

-- Focus floating window with <C-w><C-w>
vim.keymap.set("n", "<C-w><C-w>", function()
  if vim.api.nvim_win_get_config(vim.fn.win_getid()).relative ~= "" then
    vim.cmd [[ wincmd p ]]
    return
  end
  for _, winnr in pairs(vim.fn.range(1, vim.fn.winnr "$")) do
    local winid = vim.fn.win_getid(winnr)
    local conf = vim.api.nvim_win_get_config(winid)
    if conf.focusable and conf.relative ~= "" then
      vim.fn.win_gotoid(winid)
      return
    end
  end
end, { noremap = true, silent = false })

-- jump cursor
-- map('n', '<Tab>', function() return vim.v.count and '0<Bar>' or '10l' end,
--                {noremap = true, expr = true, silent = true})
-- map('n', '<CR>', function() return vim.o.buftype == 'quickfix' and "<CR>" or vim.v.count and '0jzz' or '10jzz' end,
--                {noremap = true, expr = true, silent = true})
-- nnoremap <silent> <expr> <CR>  &buftype ==# 'quickfix' ? "\<CR>" : v:count ? '0jzz' : '10jzz'

-- Automatically indent with i and A made by ycino
vim.keymap.set("n", "i", function()
  return vim.fn.len(vim.fn.getline ".") ~= 0 and "i" or '"_cc'
end, { noremap = true, expr = true, silent = true })
vim.keymap.set("n", "A", function()
  return vim.fn.len(vim.fn.getline ".") ~= 0 and "A" or '"_cc'
end, { noremap = true, expr = true, silent = true })

-- toggle 0, ^ made by ycino
vim.keymap.set("n", "0", function()
  return string.match(vim.fn.getline("."):sub(0, vim.fn.col "." - 1), "^%s+$") and "0" or "^"
end, { noremap = true, expr = true, silent = true })
-- map('n', '$',
--                function()
--   return string.match(vim.fn.getline('.'):sub(0, vim.fn.col('.')), '^%s+$') and '$' or 'g_'
-- end, {noremap = true, expr = true, silent = true})

-- high-functioning undo
-- nnoremap u g-
-- nnoremap <C-r> g+

-- undo behavior
map("i", "<BS>", "<C-g>u<BS>", { noremap = true, silent = false })
map("i", "<CR>", "<C-g>u<CR>", { noremap = true, silent = false })
map("i", "<DEL>", "<C-g>u<DEL>", { noremap = true, silent = false })
map("i", "<C-w>", "<C-g>u<C-w>", { noremap = true, silent = false })

-- Emacs style
-- map("c", "<C-a>", "<Home>", { noremap = true, silent = false })
--if not vim.g.vscode then
-- 	map("c", "<C-e>", "<End>", { noremap = true, silent = false })
-- end
-- map("c", "<C-f>", "<right>", { noremap = true, silent = false })
-- map("c", "<C-b>", "<left>", { noremap = true, silent = false })
-- map("c", "<C-d>", "<DEL>", { noremap = true, silent = false })
-- map('c', '<C-h>', '<BS>', {noremap = true, silent = true})
map("c", "<C-s>", "<BS>", { noremap = true, silent = false })
map("i", "<C-a>", "<Home>", { noremap = true, silent = false })
map("i", "<C-e>", "<End>", { noremap = true, silent = false })
map("i", "<C-f>", "<right>", { noremap = true, silent = false })
map("i", "<C-b>", "<left>", { noremap = true, silent = false })
map("i", "<C-h>", "<left>", { noremap = true, silent = false })
map("i", "<C-l>", "<right>", { noremap = true, silent = false })
map("i", "<C-k>", "<up>", { noremap = true, silent = false })
map("i", "<C-j>", "<down>", { noremap = true, silent = false })

-- remap H M L
map("n", "gH", "H", opts)
map("n", "gM", "M", opts)
map("n", "gL", "L", opts)

-- -- function key
-- map({ "i", "c", "t" }, "<F1>", "<Esc><F1>", opts)
-- map({ "i", "c", "t" }, "<F2>", "<Esc><F2>", opts)
-- map({ "i", "c", "t" }, "<F3>", "<Esc><F3>", opts)
-- map({ "i", "c", "t" }, "<F4>", "<Esc><F4>", opts)
-- map({ "i", "c", "t" }, "<F5>", "<Esc><F5>", opts)
-- map({ "i", "c", "t" }, "<F6>", "<Esc><F6>", opts)
-- map({ "i", "c", "t" }, "<F7>", "<Esc><F7>", opts)
-- map({ "i", "c", "t" }, "<F8>", "<Esc><F8>", opts)
-- map({ "i", "c", "t" }, "<F9>", "<Esc><F9>", opts)
-- map({ "i", "c", "t" }, "<F10>", "<Esc><F10>", opts)
-- map({ "i", "c", "t" }, "<F11>", "<Esc><F11>", opts)
-- map({ "i", "c", "t" }, "<F12>", "<Esc><F12>", opts)
--
-- map({ "n", "x" }, "<F13>", "<S-F1>", opts)
-- map({ "n", "x" }, "<F14>", "<S-F2>", opts)
-- map({ "n", "x" }, "<F15>", "<S-F3>", opts)
-- map({ "n", "x" }, "<F16>", "<S-F4>", opts)
-- map({ "n", "x" }, "<F17>", "<S-F5>", opts)
-- map({ "n", "x" }, "<F18>", "<S-F6>", opts)
-- map({ "n", "x" }, "<F19>", "<S-F7>", opts)
-- map({ "n", "x" }, "<F20>", "<S-F8>", opts)
-- map({ "n", "x" }, "<F21>", "<S-F9>", opts)
-- map({ "n", "x" }, "<F22>", "<S-F10>", opts)
-- map({ "n", "x" }, "<F23>", "<S-F11>", opts)
-- map({ "n", "x" }, "<F24>", "<S-F12>", opts)
-- map({ "n", "x" }, "<F25>", "<C-F1>", opts)
-- map({ "n", "x" }, "<F26>", "<C-F2>", opts)
-- map({ "n", "x" }, "<F27>", "<C-F3>", opts)
-- map({ "n", "x" }, "<F28>", "<C-F4>", opts)
-- map({ "n", "x" }, "<F29>", "<C-F5>", opts)
-- map({ "n", "x" }, "<F30>", "<C-F6>", opts)
-- map({ "n", "x" }, "<F31>", "<C-F7>", opts)
-- map({ "n", "x" }, "<F32>", "<C-F8>", opts)
-- map({ "n", "x" }, "<F33>", "<C-F9>", opts)
-- map({ "n", "x" }, "<F34>", "<C-F10>", opts)
-- map({ "n", "x" }, "<F35>", "<C-F11>", opts)
-- map({ "n", "x" }, "<F36>", "<C-F12>", opts)
-- map({ "n", "x" }, "<F37>", "<C-S-F1>", opts)
--
-- ハイライト消す
map("n", "<ESC><ESC>", "<Cmd>nohlsearch<CR>", opts)

-- yank
map("n", "d<Space>", "diw", opts)
map("n", "c<Space>", "ciw", opts)
map("n", "y<Space>", "yiw", opts)
map({ "n", "x" }, "gy", "y`>", opts)
map({ "n", "x" }, "<LocalLeader>y", '"+y', opts)
map({ "n", "x" }, "<LocalLeader>d", '"+d', opts)

-- lambdalisue's yank for slack
--vim.keymap.set("x", "[_SubLeader]y", function()
--	vim.cmd([[ normal! y ]])
--	local content = vim.fn.getreg(vim.v.register, 1, true)
--	local spaces = {}
--	for _, v in ipairs(content) do
--		table.insert(spaces, string.match(v, "%s*"):len())
--	end
--	table.sort(spaces)
--	local leading = spaces[1]
--	local content_new = {}
--	for _, v in ipairs(content) do
--		table.insert(content_new, string.sub(v, leading + 1))
--	end
--	vim.fn.setreg(vim.v.register, content_new, vim.fn.getregtype(vim.v.register))
-- end, opts)

-- paste
map({ "n", "x" }, "p", "]p", opts)
map({ "n", "x" }, "gp", "p", opts)
map({ "n", "x" }, "gP", "P", opts)
map({ "n", "x" }, "<LocalLeader>p", '"+p', opts)
map({ "n", "x" }, "<LocalLeader>P", '"+P', opts)

-- x,dはレジスタに登録しない
map({ "n", "x" }, "x", '"_x', opts)
map("n", "[_SubLeader]d", '"_d', opts)
map("n", "[_SubLeader]D", '"_D', opts)

-- インクリメント設定
map({ "n", "x" }, "+", "<C-a>", opts)
map({ "n", "x" }, "_", "<C-x>", opts)

-- move changes
-- map("n", "<C-F2>", "g;zz", opts)
-- map("n", "<C-F3>", "g,zz", opts)
map("n", "^", "g;zz", opts)
map("n", "&", "g,zz", opts)

-- refresh Use <F5> to clear the highlighting of :set hlsearch.
-- if vim.fn.maparg("<F5>", "n") == "" then
-- 	map(
--		"n",
--		"<F5>",
--		":<C-u>nohlsearch<C-r>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-l>",
--		opts
--	)
-- end
-- map("n", "<Esc>", "<Cmd>nohlsearch<CR><C-L><Esc>", opts)

local function is_normal_buffer()
  if
    vim.o.ft == "qf"
    or vim.o.ft == "Vista"
    or vim.o.ft == "NvimTree"
    or vim.o.ft == "coc-explorer"
    or vim.o.ft == "diff"
  then
    return false
  end
  if vim.fn.empty(vim.o.buftype) or vim.o.buftype == "terminal" then
    return true
  end
  return true
end

-- move buffer
-- vim.keymap.set("n", "<F2>", function()
-- 	if is_normal_buffer() then
-- 		vim.cmd([[execute "bprev"]])
-- 	end
-- end, opts)
-- vim.keymap.set("n", "<F3>", function()
-- 	if is_normal_buffer() then
-- 		vim.cmd([[execute "bnext"]])
-- 	end
--end, opts)
vim.keymap.set("n", "H", function()
  if is_normal_buffer() then
    vim.cmd [[execute "bprev"]]
  end
end, opts)
vim.keymap.set("n", "L", function()
  if is_normal_buffer() then
    vim.cmd [[execute "bnext"]]
  end
end, opts)
vim.keymap.set("n", "<C-S-Left>", function()
  if is_normal_buffer() then
    vim.cmd [[execute "bprev"]]
  end
end, opts)
vim.keymap.set("n", "<C-S-Right>", function()
  if is_normal_buffer() then
    vim.cmd [[execute "bnext"]]
  end
end, opts)

map("n", "[q", ":cprevious<CR>", opts)
map("n", "]q", ":cnext<CR>", opts)
map("n", "[Q", ":cfirst<CR>", opts)
map("n", "]Q", ":clast<CR>", opts)
map("n", "[l", ":lprevious<CR>", opts)
map("n", "]l", ":lnext<CR>", opts)
map("n", "[L", ":lfirst<CR>", opts)
map("n", "]L", ":llast<CR>", opts)
map("n", "[b", ":bprevious<CR>", opts)
map("n", "]b", ":bnext<CR>", opts)
map("n", "[B", ":bfirst<CR>", opts)
map("n", "]B", ":blast<CR>", opts)
map("n", "[t", ":tabprevious<CR>", opts)
map("n", "]t", ":tabnext<CR>", opts)
map("n", "[T", ":tabfirst<CR>", opts)
map("n", "]T", ":tablast<CR>", opts)
map("n", "[;", "g;zz", opts)
map("n", "];", "g,zz", opts)

-- switch quickfix/location list
-- map("n", "[_SubLeader]q", "<Cmd>copen<CR>", opts)
-- map("n", "[_SubLeader]l", "<Cmd>lopen<CR>", opts)

-- Go to tab by number
-- nnoremap <Leader>1 1gt
-- nnoremap <Leader>2 2gt
-- nnoremap <Leader>3 3gt
-- nnoremap <Leader>4 4gt
-- nnoremap <Leader>5 5gt
-- nnoremap <Leader>6 6gt
-- nnoremap <Leader>7 7gt
-- nnoremap <Leader>8 8gt
-- nnoremap <Leader>9 9gt
-- nnoremap <Leader>0 :tablast<CR>

-- Tab move(alt-left/right)
-- nnoremap <S-PageUp> <Cmd>execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
-- nnoremap <S-PageDown> <Cmd>execute 'silent! tabmove ' . (tabpagenr()+1)<CR>

-- move tab
-- nnoremap <S-F2> gT
-- nnoremap <S-F3> gt

-- change paragraph
-- nnoremap (  {zz
-- nnoremap )  }zz
-- nnoremap ]] ]]zz
-- nnoremap [[ [[zz
-- nnoremap [] []zz
-- nnoremap ][ ][zz

-- For search
-- map("n", "g/", "/\\v", { noremap = true, silent = false })
map("n", "*", "g*N", opts)
map("x", "*", 'y/<C-R>"<CR>N', opts)
-- noremap # g#n
map({ "n", "x" }, "g*", "*N", opts)
map({ "n", "x" }, "g#", "#n", opts)
map("x", "/", "<ESC>/\\%V", { noremap = true, silent = false })
map("x", "?", "<ESC>?\\%V", { noremap = true, silent = false })

-- For replace
map("n", "gr", "gd[{V%::s/<C-R>///gc<left><left><left>", { noremap = true, silent = false })
map("n", "gR", "gD:%s/<C-R>///gc<left><left><left>", { noremap = true, silent = false })
-- map("n", "[_SubLeader]s", ":%s/\\<<C-r><C-w>\\>/", { noremap = true, silent = false })
-- map("x", "[_SubLeader]s", ":s/\\%V", { noremap = true, silent = false })

-- Undoable<C-w> <C-u>
map("i", "<C-w>", "<C-g>u<C-w>", opts)
map("i", "<C-u>", "<C-g>u<C-u>", opts)
map("i", "<Space>", "<C-g>u<Space>", opts)

-- Change current directory
map("n", "[_SubLeader]cd", "<Cmd>lcd %:p:h<CR>:pwd<CR>", opts)

-- Delete buffer
map("n", "[_SubLeader]bd", "<Cmd>bdelete<CR>", opts)
map("n", "<C-x>", "<Cmd>bdelete<CR>", opts)
-- map("n", "<S-F4>", "<Cmd>edit #<CR>", opts)

-- Delete all marks
map("n", "[_SubLeader]md", "<Cmd>delmarks!<CR>", opts)

-- Change encoding
map("n", "[_SubLeader]eu", "<Cmd>e ++enc=utf-8<CR>", opts)
map("n", "[_SubLeader]es", "<Cmd>e ++enc=cp932<CR>", opts)
map("n", "[_SubLeader]ee", "<Cmd>e ++enc=euc-jp<CR>", opts)
map("n", "[_SubLeader]ej", "<Cmd>e ++enc=iso-2022-jp<CR>", opts)

-- tags jump
map("n", "<C-]>", "g<C-]>", opts)

-- goto
map("n", "gf", "gF", opts)
map("n", "<C-w>f", "<C-w>F", opts)
map("n", "<C-w>gf", "<C-w>F", opts)
map("n", "<C-w><C-f>", "<C-w>F", opts)
map("n", "<C-w>g<C-f>", "<C-w>F", opts)

-- split goto
map("n", "-gf", "<Cmd>split<CR>gF", opts)
map("n", "<Bar>gf", "<Cmd>vsplit<CR>gF", opts)
map("n", "-<C-]>", "<Cmd>split<CR>g<C-]>", opts)
map("n", "<Bar><C-]>", "<Cmd>vsplit<CR>g<C-]>", opts)

-- split
map("n", "-", "<Cmd>split<CR>", opts)
map("n", "<Bar>", "<Cmd>vsplit<CR>", opts)
map("n", "--", "<Cmd>split<CR>", opts)
map("n", "<Bar><Bar>", "<Cmd>vsplit<CR>", opts)

-- useful search
map("n", "n", "'Nn'[v:searchforward]", { noremap = true, silent = true, expr = true })
map("n", "N", "'nN'[v:searchforward]", { noremap = true, silent = true, expr = true })
-- map("c", "<C-s>", "<HOME><Bslash><lt><END><Bslash>>", { noremap = true, silent = false })
-- map("c", "<C-d>", "<HOME><Del><Del><END><BS><BS>", { noremap = true, silent = false })

-- Edit macro
map("n", "[_SubLeader]me", ":<C-r><C-r>='let @'. v:register .' = '. string(getreg(v:register))<CR><C-f><left>", opts)

-- indent
map("x", "<", "<gv", opts)
map("x", ">", ">gv", opts)
map("n", "(", "{", opts)
map("n", ")", "}", opts)
map("n", "[[", "[m", opts)
map("n", "]]", "]m", opts)

-- command mode
map("c", "<C-x>", "<C-r>=expand('%:p:h')<CR>/", { noremap = true, silent = false }) -- expand path
map("c", "<C-z>", "<C-r>=expand('%:p:r')<CR>", { noremap = true, silent = false }) -- expand file (not ext)
map("c", "<C-p>", "<Up>", { noremap = true, silent = false })
map("c", "<C-n>", "<Down>", { noremap = true, silent = false })
map("c", "<Up>", "<C-p>", { noremap = true, silent = false })
map("c", "<Down>", "<C-n>", { noremap = true, silent = false })
vim.o.cedit = "<C-c>" -- command window

-- terminal mode
map("t", "<Esc>", "<C-\\><C-n>", { noremap = true, silent = false })

-- completion
-- nvim-cmp
map("i", "<CR>", function()
  return vim.fn.pumvisible() and "<C-y>" or "<CR>"
end, { noremap = true, silent = true, expr = true })
map("i", "<Down>", function()
  return vim.fn.pumvisible() and "<C-n>" or "<Down>"
end, { noremap = true, silent = true, expr = true })
map("i", "<Up>", function()
  return vim.fn.pumvisible() and "<C-p>" or "<Up>"
end, { noremap = true, silent = true, expr = true })
map("i", "<PageDown>", function()
  return vim.fn.pumvisible() and "<PageDown><C-p><C-n>" or "<PageDown>"
end, { noremap = true, silent = true, expr = true })
map("i", "<PageUp>", function()
  return vim.fn.pumvisible() and "<PageUp><C-p><C-n>" or "<PageUp>"
end, { noremap = true, silent = true, expr = true })
-- map('i', '<Tab>', function() return vim.fn.pumvisible() and "<C-n>" or "<Tab>" end,
--               {noremap = true, silent = true, expr = true})
-- map('i', '<S-Tab>', function() return vim.fn.pumvisible() and "<C-p>" or "<S-Tab>" end,
--                {noremap = true, silent = true, expr = true})

-- fold
-- nnoremap Zo zo " -> use l
map("n", "gzO", "zO", opts)
map("n", "gzc", "zc", opts)
map("n", "gzC", "zC", opts)
map("n", "gzR", "zR", opts)
map("n", "gzM", "zM", opts)
map("n", "gza", "za", opts)
map("n", "gzA", "zA", opts)
map("n", "gz<Space>", "zMzvzz", opts)

-- quit
map("n", "ZZ", "<Nop>", opts)
map("n", "ZQ", "<Nop>", opts)

-- operator
-- map("o", "<Space>", "iw", opts)
map("o", 'a"', '2i"', opts)
map("o", "a'", "2i'", opts)
map("o", "a`", "2i`", opts)
-- -> In double-quote, you can't delete with ]} and ])
map("o", "{", "i{", opts)
map("o", "(", "i(", opts)
map("o", "[", "i[", opts)
-- map("o", "<", "i<", opts)
-- map("n", "<<", "<<", opts)
map("o", "}", "i}", opts)
map("o", ")", "i)", opts)
map("o", "]", "i]", opts)
-- map("o", ">", "i>", opts)
-- map("n", ">>", ">>", opts)
map("o", '"', 'i"', opts)
map("o", "'", "i'", opts)
map("o", "`", "i`", opts)
map("o", "_", "i_", opts)
map("o", "-", "i-", opts)

-- from monaqa's vimrc
-- map("n", "[_SubLeader])", "])", opts)
-- map("n", "[_SubLeader]}", "]}", opts)
-- map("x", "[_SubLeader]]", "i]o``", opts)
-- map("x", "[_SubLeader](", "i)``", opts)
-- map("x", "[_SubLeader]{", "i}``", opts)
-- map("x", "[_SubLeader][", "i]``", opts)
-- map("n", "d[_SubLeader]]", "vi]o``d", opts)
-- map("n", "d[_SubLeader](", "vi)o``d", opts)
-- map("n", "d[_SubLeader]{", "vi}o``d", opts)
-- map("n", "d[_SubLeader][", "vi]o``d", opts)
-- map("n", "d[_SubLeader]]", "vi]o``d", opts)
-- map("n", "c[_SubLeader]]", "vi]o``c", opts)
-- map("n", "c[_SubLeader](", "vi)o``c", opts)
-- map("n", "c[_SubLeader]{", "vi}o``c", opts)
-- map("n", "c[_SubLeader][", "vi]o``c", opts)
-- map("n", "c[_SubLeader]]", "vi]o``c", opts)

-- control code
map("i", "<C-q>", "<C-r>=nr2char(0x)<Left>", opts)
map("x", ".", ":normal! .<CR>", opts)
map("x", "@", ":<C-u>execute \":'<,'>normal! @\" . nr2char(getchar())<CR>", opts)
map("n", "<Space>db", "<cmd> DapToggleBreakpoint <CR>", opts)
map("n", "<Space>dpr", function()
  return require("dap-python").test_method()
end, opts)
map("n", "<Space>df", function()
  return require("dap-python").test_class()
end, opts)
return M
