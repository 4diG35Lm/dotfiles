local status, kommentary = pcall(require, "kommentary")
if (not status) then return end

require("kommentary.config").use_extended_mappings()
require("kommentary.config").configure_language("default", { prefer_single_line_comments = true })

vim.api.nvim_set_keymap("n", "<C-_>", "<Plug>kommentary_line_default", {})
vim.api.nvim_set_keymap("v", "<C-_>", "<Plug>kommentary_visual_default", {})

require("kommentary.config").configure_language("svelte", {
	-- hook_function = function() vim.api.nvim_buf_set_option(0, 'commentstring', '{%s}') end,
	hook_function = function()
		require("ts_context_commentstring.internal").update_commentstring()
	end,
	single_line_comment_string = "auto",
	multi_line_comment_strings = "auto",
})
local config = require('kommentary.config')
local M = {}

--[[ This function will be called automatically by the mapping, the first
argument will be the line that is being operated on. ]]
function M.insert_comment_below(...)
  local args = {...}
  -- This includes the commentstring
  local configuration = config.get_config(0)
  local line_number = args[1]
  -- Get the current content of the line
  local content = vim.api.nvim_buf_get_lines(0, line_number-1, line_number, false)[1]
  --[[ Get the level of indentation of that line (Find the index of the
  first non-whitespace character) ]]
  local indentation = string.find(content, "%S")
  --[[ Create a string with that indentation, with a dot at the end so that
  kommentary respects that indentation ]]
  local new_line = string.rep(" ", indentation-1) .. "."
  -- Insert the new line underneath the current one
  vim.api.nvim_buf_set_lines(0, line_number, line_number, false, {new_line})
  -- Comment in the new line
  require('kommentary.kommentary').comment_in_line(line_number+1, configuration)
  -- Set the cursor to the correct position
  vim.api.nvim_win_set_cursor(0, {vim.api.nvim_win_get_cursor(0)[1]+1, #new_line+2})
  -- Change the char under cursor (.)
  vim.api.nvim_feedkeys("cl", "n", false)
end

--[[ This is a method provided by kommentary's config, it will take care of
setting up a <Plug> mapping. The last argument is the optional callback
function, meaning when we execute this mapping, this function will be
called instead of the default. --]]
config.add_keymap("n", "kommentary_insert_below", config.context.line, { expr = true }, M.insert_comment_below)
-- Set up a regular keymapping to the new <Plug> mapping
vim.api.nvim_set_keymap('n', '<leader>co', '<Plug>kommentary_insert_below', { silent = true })

return M
