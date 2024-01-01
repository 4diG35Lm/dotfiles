local status, twilight = pcall(require, "twilight")
if not status then
  return
end
local fn, _, api = require("custom.core.utils").globals()

twilight.setup({
  exclude = { "help", "dashboard" },
  context = 15,
  expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
    "function",
    "method",
    "table",
    "if_statement",
    "statement",
    "cte",
  },
})
