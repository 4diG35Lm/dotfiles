local status,  autoclose = pcall(require,  "autoclose")
if (not status) then return end

autoclose.setup({
  keys = {
      ["$"] = { escape = true, close = true, pair = "$$"},
      [">"] = { escape = false, close = false, pair = "<>"},
      ["("] = { escape = false, close = true, pair = "()"},
      ["["] = { escape = false, close = true, pair = "[]"},
      ["{"] = { escape = false, close = true, pair = "{}"},

      [">"] = { escape = true, close = false, pair = "<>"},
      [")"] = { escape = true, close = false, pair = "()"},
      ["]"] = { escape = true, close = false, pair = "[]"},
      ["}"] = { escape = true, close = false, pair = "{}"},

      ['"'] = { escape = true, close = true, pair = '""'},
      ["'"] = { escape = true, close = true, pair = "''"},
      ["`"] = { escape = true, close = true, pair = "``"},
   },

})
