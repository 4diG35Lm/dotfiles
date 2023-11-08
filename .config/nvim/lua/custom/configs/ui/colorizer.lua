local status, colorizer = pcall(require, "colorizer")
if (not status) then return end

colorizer.setup ({
  'javascript';
  html = {
    mode = 'foreground';
  }
}, { mode = 'foreground' })
vim.cmd(
  [[autocmd ColorScheme * lua package.loaded['colorizer'] = nil; require('colorizer').setup(); require('colorizer').attach_to_buffer(0)]]
)
