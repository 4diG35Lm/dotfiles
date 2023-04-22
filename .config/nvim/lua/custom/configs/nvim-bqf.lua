local status, bqf = pcall(require, "bqf")
if (not status) then return end
bqf.setup({
  func_map = {
    pscrollup = "<C-u>", pscrolldown = "<C-d>"
  }
})
