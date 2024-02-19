-----------------------------------------------------------
-- General Neovim settings and configuration
-----------------------------------------------------------

-- Default options are not included
-- See: https://neovim.io/doc/user/vim_diff.html
-- [2] Defaults - *nvim-defaults*
local api = vim.api
local cmd = vim.cmd
local g = vim.g -- Global variables
local fn = vim.fn
local o = vim.o
local opt = vim.opt -- Set options (global/buffer/windows-scoped)
local wo = vim.wo
----------------------------------------------------------
-- General
-----------------------------------------------------------
-- Behavior
opt.shortmess = opt.shortmess + "I"

opt.mouse = "a" -- Enable mouse support
opt.mousemodel = "popup"
cmd.aunmenu { "PopUp.How-to\\ disable\\ mouse" }
cmd.aunmenu { "PopUp.-1-" }
opt.clipboard = "unnamedplus" -- Copy/paste to system clipboard
opt.swapfile = false -- Don't use swapfile
opt.completeopt = "menuone,noinsert,noselect" -- Autocomplete options
opt.shortmess = o.shortmess .. "c"
-- Buffers/Tabs/Windows
o.hidden = true
-- Tab control
opt.smarttab = true -- tab respects 'tabstop', 'shiftwidth', and 'softtabstop'
opt.tabstop = 2 -- the visible width of tabs
opt.softtabstop = 2 -- edit as if the tabs are 4 characters wide
opt.shiftwidth = 2 -- number of spaces to use for indent and unindent
opt.shiftround = true -- round indent to a multiple of 'shiftwidth'
opt.termguicolors = true
opt.winblend = 0 -- ウィンドウの不透明度
opt.pumblend = 0 -- ポップアップメニューの不透明度
opt.undofile = true

opt.confirm = true
opt.autoread = true
opt.fileformat = "unix"
opt.fileformats = "unix,dos"
-- Set spelling
o.spell = false

-- For git
wo.signcolumn = "yes"

-- Status line
o.showmode = false

-- Better display
o.cmdheight = 2

g.mapleader = " "
g.maplocalleader = "\\"

opt.shada = "'50,<1000,s100,\"1000,!" -- YankRing用に!を追加
opt.shadafile = fn.stdpath "state" .. "/shada/main.shada"
fn.mkdir(fn.fnamemodify(fn.expand(g.viminfofile), ":h"), "p")
--opt.shellslash = true -- Windowsでディレクトリパスの区切り文字に / を使えるようにする
-- vim.o.lazyredraw   vim-anzuの検索結果が見えなくなることがあるためOFF
opt.complete = o.complete .. ",k" -- 補完に辞書ファイル追加
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
opt.shortmess = opt.shortmess + "sI"

-- Insert
opt.backspace = "indent,eol,start" -- バックスペースでなんでも消せるように
opt.formatoptions = o.formatoptions .. "m" -- 整形オプション，マルチバイト系を追加
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
opt.matchtime = 1 -- 入力された文字列がマッチするまでにかかる時間

-- Window
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "cursor"
opt.equalalways = false

-- File
-- vim.o.backup=false   -- バックアップ取らない
opt.autoread = true -- 他で書き換えられたら自動で読み直す
opt.swapfile = false -- スワップファイル作らない
opt.hidden = true -- 編集中でも他のファイルを開けるようにする
opt.backup = true
opt.backupdir = fn.stdpath "state" .. "/backup/"
fn.mkdir(o.backupdir, "p")
-- vim.o.backupext = string.gsub(vim.o.backupext, "[vimbackup]", "")
o.backupskip = ""
o.directory = fn.stdpath "state" .. "/swap/"
fn.mkdir(o.directory, "p")
o.updatecount = 100
o.undofile = true
o.undodir = fn.stdpath "state" .. "/undo/"
fn.mkdir(o.undodir, "p")
o.modeline = false
-- vim.o.autochdir = true

-- clipboard
-- + reg: Ctrl-v nnamedplus
-- * reg: middle click unnamed
if fn.has "clipboard" == 1 then
  o.clipboard = "unnamedplus,unnamed"
  opt.clipboard = opt.clipboard + { "unnamedplus" } -- レジスタとクリップボードを共有
end

-- beep sound
opt.errorbells = false
opt.visualbell = true
opt.timeoutlen = 500

-- Appearance
---------------------------------------------------------
o.termguicolors = true
opt.wrap = true -- turn on line wrapping
opt.wrapmargin = 8 -- wrap lines when coming within n characters from side
opt.linebreak = true -- set soft wrapping
opt.showbreak = "↪"
opt.ttyfast = true -- faster redrawing
table.insert(opt.dip, "vertical")
table.insert(opt.dip, "iwhite")
table.insert(opt.dip, "internal")
table.insert(opt.dip, "algorithm:patience")
table.insert(opt.dip, "hiddenoff")
opt.laststatus = 3 -- show the global statusline all the time

-- tags
opt.tags:remove { "./tags" }
opt.tags:remove { "./tags;" }
opt.tags = "./tags," .. vim.go.tags

-- session
opt.sessionoptions = "buffers,curdir,tabpages,winsize,globals"

-- quickfix
opt.switchbuf = "useopen,uselast"

opt.pumblend = 0
opt.wildoptions = o.wildoptions .. ",pum"
opt.spelllang = "en,cjk"
opt.inccommand = "split"
g.vimsyn_embed = "l"

-- diff
opt.diffopt = o.diffopt .. ",vertical,internal,algorithm:patience,iwhite,indent-heuristic"

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
api.nvim_create_autocmd({ "BufEnter" }, { pattern = { "*" }, command = "normal zx" })

-- increment
opt.nrformats:append "unsigned"
opt.shortmess = opt.shortmess + "c"
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

if fn.executable "rg" then
  opt.grepprg = "rg --vimgrep --hidden --glob " .. "'!tags*'"
  opt.grepformat = "%f:%l:%c:%m,%f:%l:%m"
end

--
g.python3_host_prog = (fn.getenv "HOME") .. "/.local/share/nvim/venv/neovim/bin/python"
-- 最後の4文字が "fish" だったら "sh" にする
if opt.shell:get():sub(#opt.shell - 3) == "fish" then
  opt.shell.set "sh"
end

if fn.has "persistent_undo" then
  opt.undofile = true
end

cmd "set whichwrap+=<,>,[,],h,l"
cmd [[set iskeyword+=-]]
cmd [[set formatoptions-=cro]] -- TODO: this doesn't seem to work
opt.foldcolumn = "1"
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.fillchars = {
  eob = " ",
  fold = " ",
  foldopen = "",
  foldsep = " ",
  foldclose = ">",
}

opt.updatetime = 300

cmd [[autocmd FileType help wincmd L]]

-- Key
opt.timeoutlen = 400

-- Editing
opt.tabstop = 2
opt.shiftwidth = 2
opt.expandtab = true

-- Appearance
if fn.has "termguicolors" == 1 then
  opt.termguicolors = true
end

opt.title = true

opt.number = true
opt.signcolumn = "yes"
opt.cursorline = true
opt.sidescrolloff = 16
opt.list = true

opt.winblend = 15
opt.pumblend = 15

vim.diagnostic.config {
  virtual_lines = false,
}

fn.sign_define("DiagnosticSignError", { text = " ", texthl = "DiagnosticSignError" })
fn.sign_define("DiagnosticSignWarn", { text = " ", texthl = "DiagnosticSignWarn" })
fn.sign_define("DiagnosticSignInfo", { text = " ", texthl = "DiagnosticSignInfo" })
fn.sign_define("DiagnosticSignHint", { text = " ", texthl = "DiagnosticSignHint" })

-- Prevent closing terminal in insert mode if exited
api.nvim_create_autocmd("TermClose", {
  callback = function(ctx)
    cmd "stopinsert"
    api.nvim_create_autocmd("TermEnter", {
      callback = function()
        cmd "stopinsert"
      end,
      buffer = ctx.buf,
    })
  end,
  nested = true,
})

g.markdown_fenced_languages = {
  "ts=typescript",
}
-- =============================================================================
-- = Theming and Looks =
-- =============================================================================
wo.number = true
wo.relativenumber = true
o.termguicolors = true

-- =============================================================================
-- =  nvim-tree
-- =============================================================================
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
