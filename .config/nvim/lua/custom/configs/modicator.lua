local status, modicator = pcall(require, "modicator")
if (not status) then return end

vim.o.cursorline = true

modicator.setup({
  show_warnings = false,
  line_numbers = false,
  cursorline = true,
  highlights = {
	modes = {
	  ["i"] = "#81b29a",
	  ["v"] = "#9d79d6",
	  ["V"] = "#9d79d6",
	  [""] = "#9d79d6",
	  ["s"] = "#dbc074",
	  ["S"] = "#dbc074",
	  ["R"] = "#c94f6d",
	  ["c"] = "#719cd6",
	},
  },
})