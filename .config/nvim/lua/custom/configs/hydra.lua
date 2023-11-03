-- custom.configs.hydra
local status, hydra = pcall(require, "hydra")
if not status then
	return
end

local hint = [[
  ^ ^        Options
  ^
  _v_ %{ve} virtual edit
  _i_ %{list} invisible characters
  _s_ %{spell} spell
  _c_ %{cul} cursor line
  _w_ %{wrap} wrap
  _n_ %{nu} number
  _r_ %{rnu} relative number
  ^
       ^^^^                _<Esc>_
]]
hydra({
	name = "Git",
	hint = hint,
	config = {
		color = "red",
		invoke_on_body = true,
		hint = {
			border = "rounded",
		},
		on_key = function()
			vim.wait(50)
		end,
		on_enter = function()
			vim.cmd("mkview")
			vim.cmd("silent! %foldopen!")
		end,
		on_exit = function()
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			vim.cmd("loadview")
			vim.api.nvim_win_set_cursor(0, cursor_pos)
			vim.cmd("normal zv")
		end,
	},
	mode = { "n", "x" },
	body = "<leader>g",
	heads = {
		{
			"s",
			function()
				local mode = vim.api.nvim_get_mode().mode:sub(1, 1)
				if mode == "V" then -- visual-line mode
					local esc = vim.api.nvim_replace_termcodes("<Esc>", true, true, true)
					vim.api.nvim_feedkeys(esc, "x", false) -- exit visual mode
					vim.cmd("'<,'>Gitsigns stage_hunk")
				else
					vim.cmd("Gitsigns stage_hunk")
				end
			end,
			{ desc = "stage hunk" },
		},
		{
			"<Enter>",
			function()
				vim.cmd("Neogit")
			end,
			{ exit = true, desc = "Neogit" },
		},
		{ "q", nil, { exit = true, nowait = true, desc = "exit" } },
	},
})
