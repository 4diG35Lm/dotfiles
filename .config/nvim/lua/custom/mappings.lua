local M = {}
---@type MappingsTable
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
local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd
local g = vim.g
local o = vim.o
local opt = vim.opt
local opts = { noremap = true, silent = true }
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
--Remap space as leader key
-- map("", "<Space>", "<Nop>", opts)

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
map("", "<Leader>f", ":nohlsearch<CR>", { remap = true, desc = "Stop highlighting search results" })

-- ESC*2 でハイライトやめる
map("n", "<Esc><Esc>", ":<C-u>set nohlsearch<Return>", opts)
-- Open the tree-sitter playground. Used for debugging its queries.
map("", "<Leader>t", ":TSPlaygroundToggle<CR>", { remap = true, desc = "Toggle tree-sitter playground" })

-- XXX: Add git root name here?
-- use  system('git rev-parse --show-toplevel 2> /dev/null') and some awk
map("n", "<Leader>.", ":echo @%<CR>", { desc = "Echo filepath" })

-- Insert --
-- Press jk fast to exit insert mode
map("i", "jk", "<ESC>", opts)

-- 自動的にスペースを挿入
map("i", ",", ",<Space>", opts)
map("i", "{", ",<Space>", opts)
map("i", "}", ",<Space>", opts)
-- Visual --
-- Stay in indent mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- ビジュアルモード時vで行末まで選択
map("v", "v", "$h", opts)

-- 0番レジスタを使いやすくした
map("v", "<C-p>", '"0p', opts)

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
-- switch buffer
map("n", "H", "<Nop>", opts)
map("n", "L", "<Nop>", opts)
-- columnmove. use gJ
map("n", "J", "<Nop>", opts)
map("n", "K", "<Nop>", opts)
-- clever-f
map("n", "t", "<Nop>", opts)
map("n", "T", "<Nop>", opts)
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
-- vim-operator-convert-case
map("n", "~", "<Nop>", opts)

map("n", "qq", function()
  return vim.fn.reg_recording() == "" and "qq" or "q"
end, { noremap = true, expr = true })
map("n", "q", "<Nop>", opts)

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
map({ "n", "x" }, "j", function()
  return vim.v.count > 0 and "j" or "gj"
end, { noremap = true, expr = true })
map({ "n", "x" }, "k", function()
  return vim.v.count > 0 and "k" or "gk"
end, { noremap = true, expr = true })
-- Focus floating window with <C-w><C-w>
map("n", "<C-w><C-w>", function()
  if vim.api.nvim_win_get_config(vim.fn.win_getid()).relative ~= "" then
    vim.cmd [[ wincmd p ]]
    return
  end
  for _, winnr in pairs(fn.range(1, fn.winnr "$")) do
    local winid = fn.win_getid(winnr)
    local conf = api.nvim_win_get_config(winid)
    if conf.focusable and conf.relative ~= "" then
      fn.win_gotoid(winid)
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
map("n", "i", function()
  return fn.len(vim.fn.getline ".") ~= 0 and "i" or '"_cc'
end, { noremap = true, expr = true, silent = true })
map("n", "A", function()
  return fn.len(vim.fn.getline ".") ~= 0 and "A" or '"_cc'
end, { noremap = true, expr = true, silent = true })

-- toggle 0, ^ made by ycino
map("n", "0", function()
  return string.match(fn.getline("."):sub(0, vim.fn.col "." - 1), "^%s+$") and "0" or "^"
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

-- remap H M L
map("n", "gH", "H", opts)
map("n", "gM", "M", opts)
map("n", "gL", "L", opts)

-- ハイライト消す
map("n", "<ESC><ESC>", "<Cmd>nohlsearch<CR>", opts)

-- yank
map("n", "d<Space>", "diw", opts)
map("n", "c<Space>", "ciw", opts)
map("n", "y<Space>", "yiw", opts)
map({ "n", "x" }, "gy", "y`>", opts)
map({ "n", "x" }, "<LocalLeader>y", '"+y', opts)
map({ "n", "x" }, "<LocalLeader>d", '"+d', opts)

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

-- move changes
map("n", "^", "g;zz", opts)
map("n", "&", "g,zz", opts)

local function is_normal_buffer()
  if
    o.ft == "qf"
    or o.ft == "Vista"
    or o.ft == "diff"
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
map("n", "H", function()
  if is_normal_buffer() then
    cmd [[execute "bprev"]]
  end
end, opts)
map("n", "L", function()
  if is_normal_buffer() then
    cmd [[execute "bnext"]]
  end
end, opts)
map("n", "<C-S-Left>", function()
  if is_normal_buffer() then
    cmd [[execute "bprev"]]
  end
end, opts)
map("n", "<C-S-Right>", function()
  if is_normal_buffer() then
    cmd [[execute "bnext"]]
  end
end, opts)

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

return M