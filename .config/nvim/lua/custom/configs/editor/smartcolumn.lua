local status, smartcolumn = pcall(require, "smartcolumn")
if not status then
  return
end

smartcolumn.setup({
  colorcolumn = "120",
  disabled_filetypes = {
    "help",
    "alpha",
    "dashboard",
    "neo-tree",
    "Trouble",
    "lazy",
    "mason",
    "notify",
    "toggleterm",
    "lazyterm",
  },
})
