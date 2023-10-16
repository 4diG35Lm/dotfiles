-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*

local g = vim.g -- Global variables
local opt = vim.opt -- Set options (global/buffer/windows-scoped)
----------------------------------------------------------
-- General
-----------------------------------------------------------
opt.mouse = "a" -- Enable mouse support
opt.clipboard = "unnamedplus" -- Copy/paste to system clipboard
opt.swapfile = false -- Don't use swapfile
opt.completeopt = "menuone,noinsert,noselect" -- Autocomplete options
opt.shortmess = vim.o.shortmess .. "c"
-- Buffers/Tabs/Windows
vim.o.hidden = true
-- Tab control
opt.smarttab = true -- tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
opt.tabstop = 2 -- the visible width of tabs
opt.softtabstop = 2 -- edit as if the tabs are 4 characters wide
opt.shiftwidth = 2 -- number of spaces to use for indent and unindent
opt.shiftround = true -- round indent to a multiple of 'shiftwidth'

-- Set spelling
vim.o.spell = false

-- For git
vim.wo.signcolumn = "yes"

-- Status line
vim.o.showmode = false

-- Better display
vim.o.cmdheight = 2

g.mapleader = ","
g.maplocalleader = "\\"

opt.shada = "'50,<1000,s100,\"1000,!" -- YankRing用に!を追加
opt.shadafile = vim.fn.stdpath "state" .. "/shada/main.shada"
vim.fn.mkdir(vim.fn.fnamemodify(vim.fn.expand(vim.g.viminfofile), ":h"), "p")
opt.shellslash = true -- Windowsでディレクトリパスの区切り文字に / を使えるようにする
-- vim.o.lazyredraw   vim-anzuの検索結果が見えなくなることがあるためOFF
opt.complete = vim.o.complete .. ",k" -- 補完に辞書ファイル追加
opt.completeopt = "menuone,noselect,noinsert"
opt.history = 10000
opt.timeout = true
opt.timeoutlen = 500
opt.ttimeoutlen = 10
opt.updatetime = 2000
opt.jumpoptions = "stack"
opt.mousescroll = "ver:0,hor:0"

-- Tab
-- tabstopはTab文字を画面上で何文字分に展開するか
-- shiftwidthはcindentやautoindent時に挿入されるインデントの幅
-- softtabstopはTabキー押し下げ時の挿入される空白の量，0の場合はtabstopと同じ，BSにも影響する
-----------------------------------------------------------
-- Tabs, indent
-----------------------------------------------------------
opt.expandtab = true -- Use spaces instead of tabs タブを空白文字に展開
opt.shiftwidth = 2 -- Shift 2 spaces when tab
opt.tabstop = 2 -- 1 tab == 2 spaces
opt.smartindent = true -- Autoindent new lines
opt.autoindent = true -- 自動インデント，スマートインデント
opt.list = true
opt.listchars = "tab:» "
-----------------------------------------------------------
-- Memory, CPU
-----------------------------------------------------------
opt.hidden = true -- Enable background buffers
opt.lazyredraw = true -- Faster scrolling
opt.synmaxcol = 240 -- Max column for syntax highlight

-----------------------------------------------------------
-- Startup
-----------------------------------------------------------
-- Disable nvim intro
opt.shortmess:append "sI"

-- Insert
opt.backspace = "indent,eol,start" -- バックスペースでなんでも消せるように
opt.formatoptions = vim.o.formatoptions .. "m" -- 整形オプション，マルチバイト系を追加
-- https://github.com/vim-jp/issues/issues/152 use nofixeol
-- vim.o.binary noeol=true
opt.fixendofline = false
-- vim.o.formatoptions=vim.o.formatoptions .. "j" -- Delete comment character when joining commented lines

-- 単語区切り設定 setting by vim-polyglot
-- vim.o.iskeyword="48-57,192-255"

-- Command
opt.wildmenu = true -- コマンド補完を強化
opt.wildmode = "longest,list,full" -- リスト表示，最長マッチ

-- Search
opt.wrapscan = true -- 最後まで検索したら先頭へ戻る

-- vim.o.nowrapscan -- 最後まで検索しても先頭に戻らない
opt.ignorecase = true -- 大文字小文字無視
opt.smartcase = true -- 大文字ではじめたら大文字小文字無視しない
opt.incsearch = true -- インクリメンタルサーチ
opt.hlsearch = true -- 検索文字をハイライト

-- Window
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "cursor"
opt.equalalways = false

-- カーソルと表示
-- vim.opt.cursorline = true -- カーソルがある行を強調
-- vim.opt.cursorcolumn = true -- カーソルがある列を強調

-- クリップボード共有
vim.opt.clipboard:append { "unnamedplus" } -- レジスタとクリップボードを共有

-- File
-- vim.o.backup=false   -- バックアップ取らない
opt.fileencoding = "utf-8" -- エンコーディングをUTF-8に設定
opt.swapfile = false -- スワップファイルを作成しない
opt.helplang = "ja" -- ヘルプファイルの言語は日本語
opt.hidden = true -- バッファを切り替えるときに
--ファイルを保存しなくてもOKに
opt.autoread = true -- 他で書き換えられたら自動で読み直す
opt.backup = true
opt.backupdir = vim.fn.stdpath "state" .. "/backup/"
vim.fn.mkdir(vim.o.backupdir, "p")
-- vim.o.backupext = string.gsub(vim.o.backupext, "[vimbackup]", "")
vim.o.backupskip = ""
vim.o.directory = vim.fn.stdpath "state" .. "/swap/"
vim.fn.mkdir(vim.o.directory, "p")
vim.o.updatecount = 100
vim.o.undofile = true
vim.o.undodir = vim.fn.stdpath "state" .. "/undo/"
vim.fn.mkdir(vim.o.undodir, "p")
vim.o.modeline = false
-- vim.o.autochdir = true

-- clipboard
-- + reg: Ctrl-v nnamedplus
-- * reg: middle click unnamed
if vim.fn.has "clipboard" == 1 then
  vim.o.clipboard = "unnamedplus,unnamed"
end

-- beep sound
opt.errorbells = false
opt.visualbell = true
opt.timeoutlen = 500

-- Appearance
---------------------------------------------------------
vim.o.termguicolors = true
opt.wrap = true -- turn on line wrapping
opt.wrapmargin = 8 -- wrap lines when coming within n characters from side
opt.linebreak = true -- set soft wrapping
opt.showbreak = "↪"
opt.ttyfast = true -- faster redrawing
table.insert(opt.diffopt, "vertical")
table.insert(opt.diffopt, "iwhite")
table.insert(opt.diffopt, "internal")
table.insert(opt.diffopt, "algorithm:patience")
table.insert(opt.diffopt, "hiddenoff")
opt.laststatus = 3 -- show the global statusline all the time

-- tags
opt.tags:remove { "./tags" }
opt.tags:remove { "./tags;" }
opt.tags = "./tags," .. vim.go.tags

-- session
opt.sessionoptions = "buffers,curdir,tabpages,winsize,globals"

-- quickfix
opt.switchbuf = "useopen,uselast"

-- smart indent for long line
-- vim.o.breakindent=true

opt.pumblend = 0
opt.wildoptions = vim.o.wildoptions .. ",pum"
opt.spelllang = "en,cjk"
vim.opt_local.spelloptions:append "noplainbuffer"
opt.inccommand = "split"
g.vimsyn_embed = "l"

-- diff
opt.diffopt = vim.o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic"

-- code folding settings
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99
opt.foldnestmax = 10 -- deepest fold is 10 levels
opt.foldenable = false -- don't fold by default
opt.foldlevel = 1
-- fix code folding. Without this autocmd, the message "E490: No fold found" is displayed
-- anytime a fold is triggered, until the file is reloaded (for example, with `:e<cr>`)
-- https://github.com/nvim-telescope/telescope.nvim/issues/699#issuecomment-1159637962
vim.api.nvim_create_autocmd({ "BufEnter" }, { pattern = { "*" }, command = "normal zx" })

-- increment
opt.nrformats:append "unsigned"
opt.shortmess:append "c"
opt.matchpairs:append {
  "（:）",
  "「:」",
  "『:』",
  "【:】",
}
opt.sessionoptions = {
  "buffers",
  "folds",
  "tabpages",
  "winsize",
}

if vim.fn.executable "rg" then
  opt.grepprg = "rg --vimgrep --hidden --glob " .. "'!tags*'"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

--
g.python3_host_prog = (vim.fn.getenv "HOME") .. "/.local/share/nvim/venv/neovim/bin/python"
-- 最後の4文字が "fish" だったら "sh" にする
if opt.shell:get():sub(#vim.opt.shell - 3) == "fish" then
  opt.shell.set "sh"
end

if vim.fn.has "persistent_undo" then
  opt.undofile = true
end

vim.cmd "set whichwrap+=<,>,[,],h,l"
vim.cmd [[set iskeyword+=-]]
vim.cmd [[set formatoptions-=cro]] -- TODO: this doesn't seem to work

-- =============================================================================
-- = Theming and Looks =
-- =============================================================================
vim.wo.number = true
vim.wo.relativenumber = true
vim.o.termguicolors = true

-- =============================================================================
-- =  nvim-tree
-- =============================================================================
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
