--local utils = require("utils")
-- Neovim-specific configuration
--
-- require("globals")
-- alias to vim's objects
local api = vim.api
local cmd = vim.cmd
local env = vim.env
local fn = vim.fn
local g = vim.g
--local imap = utils.imap
local indent = 2
--local inoremap = utils.inoremap
--local nmap = utils.nmap
--local nnoremap = utils.nnoremap
local o = vim.o
--local omap = utils.omap
local opt = vim.opt
--local termcodes = utils.termcodes
-- local vmap = utils.vmap
--local vnoremap = utils.vnoremap
local wo = vim.wo
-- local xmap = utils.xmap

cmd "autocmd!"

vim.scriptencoding = "utf-8"

vim.wo.number = true

-- LANG

if fn.has "unix" == 1 then
  env.LANG = "en_US.UTF-8"
else
  env.LANG = "en"
end
cmd [[ "language " .. os.getenv("LANG") ]]
o.langmenu = os.getenv "LANG"

o.encoding = "utf-8"
o.fileencodings = "ucs-bom,utf-8,euc-jp,iso-2022-jp,cp932,sjis,latin1"
o.fileformats = "unix,dos,mac"
--cmd [[ scriptencoding utf-8 ]]

-- debug level
-- vim.lsp.set_log_level('debug')
---@type integer
local augroup = api.nvim_create_augroup("vimrc", { clear = true })
---vimrc 専用の属性を格納するテーブル
_G.vimrc = {
  -- operator
  op = {},
  motion = {},
  omnifunc = {},
  state = {},
}

cmd [[
  filetype off
  filetype plugin indent off
]]

-- General
----------------------------------------------------------------

g.airline_powerline_fonts = 1
g.mapleader = " "
g.neovide_iso_layout = true
g.ale_linters = {
  ["*"] = { "ale_linters" },
  ["python"] = { "flake8" },
  ["sh"] = { "shellcheck" },
  ["zsh"] = { "shellcheck" },
  ["vim"] = { "vint" },
  ["lua"] = { "luacheck" },
  ["go"] = { "golangci-lint" },
  ["dockerfile"] = { "dockerfile_lint" },
}
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1

-- set termguicolors to enable highlight groups
opt.termguicolors = true

-- disable default plugins
local disable_plugins = {
  "loaded_gzip",
  "loaded_shada_plugin",
  "loadedzip",
  "loaded_spellfile_plugin",
  "loaded_tutor_mode_plugin",
  "loaded_gzip",
  "loaded_tar",
  "loaded_tarPlugin",
  "loaded_zip",
  "loaded_zipPlugin",
  "loaded_rrhelper",
  "loaded_2html_plugin",
  "loaded_vimball",
  "loaded_vimballPlugin",
  "loaded_getscript",
  "loaded_getscriptPlugin",
  "loaded_logipat",
  "loaded_matchparen",
  "loaded_man",
  "loaded_netrw",
  "loaded_netrwPlugin",
  "loaded_netrwSettings",
  "loaded_netrwFileHandlers",
  "loaded_logiPat",
  "did_install_default_menus",
  "did_install_syntax_menu",
  "skip_loading_mswin",
}

for _, name in pairs(disable_plugins) do
  g[name] = true
end

cmd "filetype off"
cmd "syntax off"
-- eqaul to below setting
cmd "autocmd TermOpen * startinsert"

cmd [[
if executable('fcitx')
  let g:fcitx_state = 1
  augroup fcitx_savestate
    autocmd!
    autocmd InsertLeave * let g:fcitx_state = str2nr(system('fcitx-remote'))
    autocmd InsertLeave * call system('fcitx-remote -c')
    autocmd InsertEnter * call system(g:fcitx_state == 1 ? 'fcitx-remote -c': 'fcitx-remote -o')
  augroup END
endif
]]

local vars = {
  python_host_prog = "/usr/bin/python2",
  python3_host_prog = "$HOME/.anyenv/envs/pyenv/shims/python",
  python3_dir = "$HOME/.nvim/python3", 
  loaded_matchparen = 1,
}

for var, val in ipairs(vars) do
  api.nvim_set_var(var, val)
end

cmd [[
 filetype plugin indent on
 syntax enable
]]
-- make comments and HTML attributes italic
cmd [[highlight Comment cterm=italic term=italic gui=italic]]
cmd [[highlight htmlArg cterm=italic term=italic gui=italic]]
cmd [[highlight xmlAttrib cterm=italic term=italic gui=italic]]
cmd [[highlight Normal ctermbg=none]]

-- https://github.com/neovim/neovim/issues/14090#issuecomment-1177933661
-- vim.g.do_filetype_lua = 1
-- vim.g.did_load_filetypes = 0

opt.runtimepath:remove "/etc/xdg/nvim"
opt.runtimepath:remove "/etc/xdg/nvim/after"
opt.runtimepath:remove "/usr/share/vim/vimfiles"
