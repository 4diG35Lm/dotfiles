-- "custom.configs.nvim-format-buffer"
local status, nvim_format_buffer = pcall(require, "nvim-format-buffer")
if not status then
  return
end

nvim_format_buffer.setup({
  verbose = true,
  format_rules = {
    { pattern = { "*.lua" }, command = "stylua -" },
    { pattern = { "*.py" }, command = "black -q - | isort -" },
    { pattern = { "*.js", "*.jsx", "*.ts", "*.tsx" }, command = "prettier --parser typescript 2>/dev/null" },
    { pattern = { "*.md" }, command = "prettier --parser markdown 2>/dev/null" },
    { pattern = { "*.css" }, command = "prettier --parser css" },
    { pattern = { "*.rs" }, command = "rustfmt --edition 2021" },
    { pattern = { "*.sql" }, command = "sql-formatter --config ~/sql-formatter.json" }, -- requires `npm -g i sql-formatter`
  },
})
local run_stylua = require("nvim-format-buffer").create_format_fn("stylua -")
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*.lua" },
  callback = function()
    run_stylua()
    print("Formatted!")
  end,
})
