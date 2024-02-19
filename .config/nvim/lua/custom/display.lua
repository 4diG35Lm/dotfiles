-- alias to vim's objects
local api = vim.api
local cmd = vim.cmd
local env = vim.env
local fn = vim.fn
local g = vim.g
local o = vim.o
local opt = vim.opt
-- nvim color
env.NVIM_TUI_ENABLE_TRUE_COLOR = 1
o.synmaxcol = 200
-- ColorScheme
cmd [[ syntax enable ]] -- シンタックスカラーリングオン
cmd [[
try
  colorscheme kanagawa-dragon
catch /^Vim\%((\a\+)\)\=:E185/
  colorscheme default
  set background=dark
endtry
]]
o.background = ""
-- true color support
g.colorterm = os.getenv "COLORTERM"
if fn.exists "+termguicolors" == 1 then
  -- vim.o.t_8f = "<Esc>[38;2;%lu;%lu;%lum"
  -- vim.o.t_8b = "<Esc>[48;2;%lu;%lu;%lum"
  o.termguicolors = true
end

o.cmdheight = 0
-- colorscheme pluginconfig -> colorscheme
o.cursorline = true

o.display = "lastline" -- 長い行も一行で収まるように
o.showmode = false
o.showmatch = true -- 括弧の対応をハイライト
o.matchtime = 1 -- 括弧の対を見つけるミリ秒数
o.showcmd = true -- 入力中のコマンドを表示
o.number = true -- 行番号表示
o.relativenumber = true
o.wrap = true -- 画面幅で折り返す
o.title = false -- タイトル書き換えない
o.scrolloff = 5
o.sidescrolloff = 5
o.pumheight = 10 -- 補完候補の表示数
-- 折りたたみ設定
o.foldmethod = "marker"
-- vim.o.foldmethod = "manual"
o.foldlevel = 1
o.foldlevelstart = 99
vim.w.foldcolumn = "0:"

-- Cursor style
o.guicursor = "n-v-c-sm:block-Cursor/lCursor-blinkon0,i-ci-ve:ver25-Cursor/lCursor,r-cr-o:hor20-Cursor/lCursor"
o.cursorlineopt = "number"

-- ステータスライン関連
-- vim.o.laststatus = 2
o.laststatus = 3
o.shortmess = "aItToOF"
opt.fillchars = {
  horiz = "━",
  horizup = "┻",
  horizdown = "┳",
  vert = "┃",
  vertleft = "┫",
  vertright = "┣",
  verthoriz = "╋",
}
opt.ambiwidth = "single"
opt.winblend = 20
opt.pumblend = 20
opt.termguicolors=true -- 24 ビットカラーを使用
opt.background = "dark" -- ダークカラーを使用する
opt.number = true
-- 表示
opt.number = true -- 行番号を表示
opt.relativenumber = true -- 相対行番号を表示
opt.wrap = true -- テキストの自動折り返しを無効に
opt.showtabline = 2 -- タブラインを表示
                    -- （1:常に表示、2:タブが開かれたときに表示）
opt.visualbell = true -- ビープ音を表示する代わりに画面をフラッシュ
opt.showmatch = true -- 対応する括弧をハイライト表示
-- インタフェース
opt.winblend = 0 -- ウィンドウの不透明度
opt.pumblend = 0 -- ポップアップメニューの不透明度
opt.showtabline = 2 -- タブラインを表示する設定
opt.signcolumn = "yes" -- サインカラムを表示
opt.background = 'light'
opt.wildignore = { '*.o', '*.a', '__pycache__' }
-- メニューとコマンド
opt.wildmenu = true -- コマンドラインで補完
opt.cmdheight = 1 -- コマンドラインの表示行数
opt.laststatus = 2 -- 下部にステータスラインを表示
opt.showcmd = true -- コマンドラインに入力されたコマンドを表示
