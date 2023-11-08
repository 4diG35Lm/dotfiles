-- "custom.func"
local g = vim.g -- Global variables
local opt = vim.opt -- Set options (global/buffer/windows-scoped)
local cmd = vim.cmd
local fn = vim.fn
local api = vim.api

-- opt.wildcharm = ('<Tab>'):byte()
opt.clipboard:append { fn.has "mac" == 1 and "unnamed" or "unnamedplus" }
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"
opt.mouse = {}
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"

-- file indent
local filetype_indent_group = api.nvim_create_augroup("fileTypeIndent", { clear = true })
local file_indents = {
  {
    pattern = "go",
    command = "setlocal tabstop=2 shiftwidth=2",
  },
  {
    pattern = "rust",
    command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab",
  },
  {
    pattern = {
      "javascript",
      "typescriptreact",
      "typescript",
      "vim",
      "lua",
      "yaml",
      "json",
      "sh",
      "zsh",
      "markdown",
      "wast",
    },
    command = "setlocal tabstop=2 softtabstop=2 shiftwidth=2 expandtab smartindent autoindent",
  },
}

for _, indent in pairs(file_indents) do
  api.nvim_create_autocmd("FileType", {
    pattern = indent.pattern,
    command = indent.command,
    group = filetype_indent_group,
  })
end

-- grep window
api.nvim_create_autocmd("QuickFixCmdPost", {
  pattern = "*grep*",
  command = "cwindow",
  group = api.nvim_create_augroup("grepWindow", { clear = true }),
})

-- restore cursorline
api.nvim_create_autocmd("BufReadPost", {
  pattern = "*",
  callback = function()
    cmd [[
    if line("'\"") > 0 && line("'\"") <= line("$")
      exe "normal! g'\""
    endif
    ]]
  end,
  group = api.nvim_create_augroup("restoreCursorline", { clear = true }),
})

-- persistent undo
local ensure_undo_dir = function()
  local undo_path = fn.expand "~/.config/nvim/undo"
  if fn.isdirectory(undo_path) == 0 then
    fn.mkdir(undo_path, "p")
  end
  opt.undodir = undo_path
  opt.undofile = true
end
ensure_undo_dir()

-- start insert mode when termopen
api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  callback = function()
    cmd "startinsert"
    cmd "setlocal scrolloff=0"
  end,
  group = api.nvim_create_augroup("neovimTerminal", { clear = true }),
})

-- auto mkdir
local auto_mkdir = function(dir)
  if fn.isdirectory(dir) == 0 then
    fn.mkdir(dir, "p")
  end
end
api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
    auto_mkdir(fn.expand "<afile>:p:h")
  end,
  group = api.nvim_create_augroup("autoMkdir", { clear = true }),
})
