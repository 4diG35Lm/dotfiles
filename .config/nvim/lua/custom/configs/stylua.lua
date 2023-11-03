-- "custom.configs.stylua"
local status, stylua = pcall(require, "stylua")
if not status then
  return
end

stylua.setup({
  indent_width = 2,
  indent_type = 'Spaces',
  column_width = 80,
  line_ending = 'Unix',
  quote_style = 'Auto',
})
vim.cmd([[autocmd BufWritePre *.lua lua require('stylua').format_file()]])
