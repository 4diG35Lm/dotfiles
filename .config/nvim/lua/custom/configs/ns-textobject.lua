local status, nstextobject = pcall(require, "ns-textobject")
if (not status) then return end

nstextobject.setup({
  auto_mapping = {
      -- automatically mapping for nvim-surround's aliases
      aliases = true,
      -- for nvim-surround's surrounds
      surrounds = true,
  },
  disable_builtin_mapping = {
      enabled = true,
      -- list of char which shouldn't mapping by auto_mapping
      chars = { "b", "B", "t", "`", "'", '"', "{", "}", "(", ")", "[", "]", "<", ">" },
  },
})
