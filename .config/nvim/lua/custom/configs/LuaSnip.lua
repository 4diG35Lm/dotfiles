local status, ls = pcall(require, "luasnip")
if not status then
  return
end
local s = ls.s
local sn = ls.sn
local t = ls.t
local i = ls.i
local f = ls.f
local c = ls.c
local d = ls.d
local types = ls.util.types
ls.loaders.from_vscode.lazy_load {}
-- If you're reading this file for the first time, best skip to around line 190
-- where the actual snippet-definitions start.

-- Every unspecified option will be set to the default.
ls.config.set_config {
  history = true,
}
ls.snippet = {
  all = {
    snip({
      trig = "date",
      namr = "Date",
      dscr = "Date in the form of YYYY-MM-DD",
    }, {
      func(date, {}),
    }),
    s({ trig = "sample" }, {
      t { "Sample Text!" },
      i(0),
    }),
  },
  lua = {
    s({ trig = "lam" }, {
      t { "function(" },
      i(1),
      t { ")" },
      t { "", "" },
      t { "  " },
      i(0),
      t { "", "" },
      t { "end" },
    }),
    parse({ trig = "lam" }, {
      "function(${1})",
      "\t${0}",
      "end",
    }),
  },
}

vim.cmd [[imap <silent><expr> <C-k> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<C-k>']]
