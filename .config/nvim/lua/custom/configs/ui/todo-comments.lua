local status, todo_comments = pcall(require, "todo-comments")
if (not status) then return end

local fn, _, api = require("custom.core.utils").globals()
local keymap = vim.keymap
local tbl = vim.tbl_deep_extend
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================
local opts = { noremap = true, silent = true }
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = tbl("force", options, opts)
  end
  keymap.set(mode, lhs, rhs, options)
end
todo_comments.setup({
	keywords = {
		FIX = {
			icon = "", -- icon used for the sign, and in search results
			color = "error", -- can be a hex color, or a named color (see below)
			alt = { "FIXME", "BUG", "FIXIT", "ISSUE" }, -- a set of other keywords that all map to this FIX keywords
			-- signs = false, -- configure signs for some keywords individually
		},
		TODO = { icon = "", color = "info" },
		HACK = { icon = "", color = "warning" },
		WARN = { icon = "", color = "warning", alt = { "WARNING", "XXX" } },
		PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
		NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
	},
})

map("n", "]t", function()
  todo_comments.jump_next()
end, { desc = "Next todo comment" })

map("n", "[t", function()
  todo_comments.jump_prev()
end, { desc = "Previous todo comment" })

-- You can also specify a list of valid jump keywords

map("n", "]t", function()
  todo_comments.jump_next({keywords = { "ERROR", "WARNING" }})
end, { desc = "Next error/warning todo comment" })
map("n",  "<leader>xt", "<cmd>TodoTrouble<cr>", {desc = "Todo (Trouble)"})
map("n",  "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>", {desc = "Todo/Fix/Fixme (Trouble)"} )
map("n",  "<leader>st", "<cmd>TodoTelescope<cr>", {desc = "Todo"})
map("n", "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", {desc = "Todo/Fix/Fixme"} )
