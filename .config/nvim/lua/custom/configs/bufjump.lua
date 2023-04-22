local status, bufjump = pcall(require, "bufjump")
if (not status) then return end

bufjump.setup({
  forward = "g<C-i>",
  backward = "g<C-o>",
  on_success = nil,
})
