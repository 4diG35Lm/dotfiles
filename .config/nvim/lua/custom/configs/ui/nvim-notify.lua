local status, notify = pcall(require, "notify")
if (not status) then return end

vim.opt.termguicolors = true
notify.setup({
  timeout = 3000,
  background_colour = "#000000",
  max_height = function()
    return math.floor(vim.o.lines * 0.75)
  end,
  max_width = function()
    return math.floor(vim.o.columns * 0.75)
  end,
})
