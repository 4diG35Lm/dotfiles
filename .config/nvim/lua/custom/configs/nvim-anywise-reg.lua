local status, anywise_reg = pcall(require, "anywise_reg")
if (not status) then return end
anywise_reg.setup({
  operators = { "y" },
  textobjects = { "af" },
  paste_keys = { [",p"] = "]p" }
})
