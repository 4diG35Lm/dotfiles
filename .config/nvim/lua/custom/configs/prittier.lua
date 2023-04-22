local status, prettier = pcall(require, "prettier")
if (not status) then return end

prettier.setup {
  bin = 'prettierd',
  filetypes = {
    "css",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "scss",
    "less"
  }
}

vim.g[prettier#autoformat] = 1
vim.g[prettier#autoformat_require_pragma] = 0
vim.g[prettier#quickfix_enabled] = 0
vim.g[prettier#partial_forma] = 1
vim.g[prettier#quickfix_auto_focus] = 0
