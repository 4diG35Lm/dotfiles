local status, colorizer = pcall(require, "colorizer")
if not status then
  return
end

colorizer.setup {
  filetypes = {
    "css",
    "javascript",
    html = { mode = "foreground" },
  },
  user_default_options = {
    trailwind = true,
  },
}
