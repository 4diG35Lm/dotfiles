-- custom.Telescope.config
local status, telescope = pcall(require, "telescope")
if not status then
	return
end

local fn, uv, api = require("custom.core.utils").globals()
local keymap = vim.keymap
local Path = require("plenary.path")
local actions = require("telescope.actions")
local actions_state = require("telescope.actions.state")
local fb_actions = require("telescope._extensions.file_browser.actions")
local from_entry = require("telescope.from_entry")

local function builtin(name)
	return function(opt)
		return function()
			return require("telescope.builtin")[name](opt or {})
		end
	end
end

local function extensions(name, prop)
	return function(opt)
		return function()
			telescope.load_extension(name)
			return telescope.extensions[name][prop](opt or {})
		end
	end
end

for k, v in pairs(require("telescope.builtin")) do
	if type(v) == "function" then
		vim.keymap.set("n", "<Plug>(telescope." .. k .. ")", v)
	end
end

-- Lines
keymap.set("n", "#", builtin("current_buffer_fuzzy_find")({}))

-- Files
keymap.set("n", "<Leader>fB", builtin("buffers")({}))
keymap.set("n", "<Leader>fb", function()
	local cwd = fn.expand("%:h")
	extensions("file_browser", "file_browser")({ cwd = cwd == "" and nil or cwd })()
end)
keymap.set("n", "<Leader>ff", function()
	-- TODO: stopgap measure
	if uv.cwd() == uv.os_homedir() then
		vim.notify("find_files on $HOME is danger. Launch file_browser instead.", vim.log.levels.WARN)
		extensions("file_browser", "file_browser")({})()
	elseif Path:new(uv.cwd() .. "/.git"):is_dir() then
		builtin("git_files")({ show_untracked = true })()
	else
		builtin("find_files")({ hidden = true })()
	end
end)

local function input_grep_string(prompt, func)
	return function()
		vim.ui.input({ prompt = prompt }, function(input)
			if input then
				func({ only_sort_text = true, search = input })()
			else
				vim.notify("cancelled")
			end
		end)
	end
end

keymap.set("n", "<Leader>f:", builtin("command_history")({}))
keymap.set("n", "<Leader>fG", builtin("grep_string")({}))
keymap.set("n", "<Leader>fH", builtin("help_tags")({ lang = "en" }))
keymap.set("n", "<Leader>fN", extensions("node_modules", "list")({}))
keymap.set("n", "<Leader>fg", input_grep_string("Grep For ❯ ", builtin("grep_string")))
keymap.set("n", "<Leader>fh", builtin("help_tags")({}))
keymap.set("n", "<Leader>fm", builtin("man_pages")({ sections = { "ALL" } }))
keymap.set("n", "<Leader>fn", extensions("noice", "noice")({}))
keymap.set("n", "<Leader>fp", extensions("projects", "projects")({}))
keymap.set(
	"n",
	"<Leader>fq",
	extensions("ghq", "list")({
		attach_mappings = function(_)
			local actions_set = require("telescope.actions.set")
			actions_set.select:replace(function(_, _)
				local entry = actions_state.get_selected_entry()
				local dir = from_entry.path(entry)
				builtin("git_files")({ cwd = dir, show_untracked = true })()
			end)
			return true
		end,
	})
)
keymap.set("n", "<Leader>fr", builtin("resume")({}))

keymap.set(
	"n",
	"<Leader>fv",
	extensions("file_browser", "file_browser")({
		add_dirs = false,
		depth = false,
		hide_parent_dir = true,
		path = "$VIMRUNTIME",
	})
)
keymap.set("n", "<Leader>fy", extensions("yank_history", "yank_history")({}))

keymap.set("n", "<Leader>fz", function()
	extensions("z", "list")({
		previewer = require("telescope.previewers.term_previewer").new_termopen_previewer({
			get_command = function(entry)
				return { "tree", "-hL", "3", require("telescope.from_entry").path(entry) }
			end,
			scroll_fn = function(self, direction)
				if not self.state then
					return
				end
				local bufnr = self.state.termopen_bufnr
				-- 0x05 -> <C-e>
				-- 0x19 -> <C-y>
				local input = direction > 0 and string.char(0x05) or string.char(0x19)
				local count = math.abs(direction)
				api.win_call(fn.bufwinid(bufnr), function()
					vim.cmd.normal({ args = { count .. input }, bang = true })
				end)
			end,
		}),
	})()
end)

-- Memo
keymap.set("n", "<Leader>mm", extensions("memo", "list")({}))
keymap.set("n", "<Leader>mg", input_grep_string("Memo Grep For ❯ ", extensions("memo", "grep_string")))

-- LSP
keymap.set("n", "<Leader>sr", builtin("lsp_references")({}))
keymap.set("n", "<Leader>sd", builtin("lsp_document_symbols")({}))
keymap.set("n", "<Leader>sw", builtin("lsp_workspace_symbols")({}))
keymap.set("n", "<Leader>sc", builtin("lsp_code_actions")({}))

-- Git
keymap.set("n", "<Leader>gc", builtin("git_commits")({}))
keymap.set("n", "<Leader>gb", builtin("git_bcommits")({}))
keymap.set("n", "<Leader>gr", builtin("git_branches")({}))
keymap.set("n", "<Leader>gs", builtin("git_status")({}))

-- Copied from telescope.nvim
keymap.set("n", "q:", builtin("command_history")({}))
keymap.set(
	"c",
	"<A-r>",
	[[<C-\>e ]]
		.. [["lua require'telescope.builtin'.command_history{]]
		.. [[default_text = [=[" . escape(getcmdline(), '"') . "]=]}"<CR><CR>]],
	{ silent = true }
)

local run_in_dir = function(name)
	return function()
		local source = require("telescope.builtin")[name]
		local entry = actions_state.get_selected_entry()
		local dir = from_entry.path(entry)
		if fn.isdirectory(dir) then
			source({ cwd = dir })
		else
			vim.notify(("This is not a directory: %s"):format(dir), vim.log.levels.ERROR)
		end
	end
end

local preview_scroll = function(direction)
	return function(prompt_bufnr)
		actions.get_current_picker(prompt_bufnr).previewer:scroll_fn(direction)
	end
end

telescope.setup({
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
		}, --column
	},
	prompt_prefix = "> ",
	selection_caret = "> ",
	entry_prefix = "  ",
	initial_mode = "insert",
	selection_strategy = "reset",
	sorting_strategy = "ascending",
	layout_strategy = "flex",
	layout_config = {
		width = 0.8,
		horizontal = {
			mirror = false,
			prompt_position = "top",
			preview_cutoff = 120,
			preview_width = 0.5,
		},
		vertical = {
			mirror = false,
			prompt_position = "top",
			preview_cutoff = 120,
			preview_width = 0.5,
		},
	},
	file_sorter = require("telescope.sorters").get_fuzzy_file,
	file_ignore_patterns = { "node_modules/*" },
	generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
	dynamic_preview_title = true,
	winblend = 0,
	border = {},
	borderchars = {
		{ "─", "│", "─", "│", "┌", "┐", "┘", "└" },
		prompt = { "─", "│", " ", "│", "┌", "┬", "│", "│" },
		results = { "─", "│", "─", "│", "├", "┤", "┴", "└" },
		preview = { "─", "│", "─", " ", "─", "┐", "┘", "─" },
	},
	color_devicons = true,
	use_less = true,
	scroll_strategy = "cycle",
	set_env = { ["COLORTERM"] = "truecolor" }, -- default { }, currently unsupported for shells like cmd.exe / powershell.exe
	-- file_previewer = require'telescope.previewers'.cat.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_cat.new`
	-- grep_previewer = require'telescope.previewers'.vimgrep.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_vimgrep.new`
	-- qflist_previewer = require'telescope.previewers'.qflist.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_qflist.new`
	-- Developer configurations: Not meant for general override
	buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
	mappings = {
		i = {
			["<C-a>"] = run_in_dir("find_files"),
			["<C-c>"] = actions.close,
			["<C-g>"] = run_in_dir("live_grep"),
			["<C-j>"] = actions.move_selection_next,
			["<C-k>"] = actions.move_selection_previous,
			["<C-s>"] = actions.select_horizontal,
			["<C-n>"] = actions.cycle_history_next,
			["<C-p>"] = actions.cycle_history_prev,
			["<C-d>"] = actions.preview_scrolling_down,
			["<C-u>"] = actions.preview_scrolling_up,
			["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
			["<M-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
		},
		n = {
			["<Space>"] = actions.toggle_selection,
			["<C-a>"] = run_in_dir("find_files"),
			["<C-b>"] = actions.results_scrolling_up,
			["<C-c>"] = actions.close,
			["<C-f>"] = actions.results_scrolling_down,
			["<C-g>"] = run_in_dir("live_grep"),
			["<C-j>"] = actions.move_selection_next,
			["<C-k>"] = actions.move_selection_previous,
			["<C-s>"] = actions.select_horizontal,
			["<C-n>"] = actions.select_horizontal,
			["<C-d>"] = preview_scroll(3),
			["<C-u>"] = preview_scroll(-3),
			["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
			["<M-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
		},
	},
	history = {
		path = Path:new(fn.stdpath("data"), "telescope_history.sqlite3").filename,
		limit = 100,
	},
	hijack_netrw = true,
	dir_icon_hl = "Directory",
	icon_width = 2,
	path_display = { "shorten", "smart" },
	respect_gitignore = false,
	fzf = {
		fuzzy = true,
		override_generic_sorter = true,
		override_file_sorter = true,
		case_mode = "smart_case",
	},
	extensions = {
		file_browser = {
			mappings = {
				i = {
					["<A-d>"] = fb_actions.remove,
					["<A-e>"] = fb_actions.create, -- Original: <A-c>
					["<A-g>"] = fb_actions.goto_parent_dir, -- Original: <C-g>
					["<A-h>"] = fb_actions.toggle_hidden, -- Original: <C-h>
					["<A-m>"] = fb_actions.move,
					["<A-r>"] = fb_actions.rename,
					["<A-s>"] = fb_actions.toggle_all, -- Original: <C-s>
					["<A-y>"] = fb_actions.copy,
					["<C-a>"] = run_in_dir("find_files"),
					["<C-d>"] = preview_scroll(3),
					["<C-e>"] = fb_actions.goto_home_dir,
					["<C-f>"] = fb_actions.toggle_browser,
					["<C-g>"] = run_in_dir("live_grep"),
					["<C-n>"] = actions.select_horizontal,
					["<C-o>"] = fb_actions.open,
					["<C-s>"] = actions.select_horizontal,
					["<C-t>"] = fb_actions.change_cwd,
					["<C-u>"] = preview_scroll(-3),
					["<C-w>"] = fb_actions.goto_cwd,
				},
				n = {
					["<C-a>"] = run_in_dir("find_files"),
					["<C-d>"] = preview_scroll(3),
					["<C-g>"] = run_in_dir("live_grep"),
					["<C-u>"] = preview_scroll(-3),
					["c"] = fb_actions.create,
					["d"] = fb_actions.remove,
					["e"] = fb_actions.goto_home_dir,
					["f"] = fb_actions.toggle_browser,
					["g"] = fb_actions.goto_parent_dir,
					["h"] = fb_actions.toggle_hidden,
					["m"] = fb_actions.move,
					["o"] = fb_actions.open,
					["r"] = fb_actions.rename,
					["s"] = fb_actions.toggle_all,
					["t"] = fb_actions.change_cwd,
					["w"] = fb_actions.goto_cwd,
					["y"] = fb_actions.copy,
				},
			},
			theme = "ivy",
			hijack_netrw = true,
			dir_icon_hl = "Directory",
			icon_width = 2,
			path_display = { "shorten", "smart" },
			respect_gitignore = false,
			layout_config = {
				height = function(_, _, max_lines)
					return math.max(math.floor(max_lines / 2), 5)
				end,
			},
		},
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
})
telescope.load_extension("file_browser")
-- This is needed to setup telescope-frecency.
-- in this.
telescope.load_extension("fzf")
-- This is needed to setup telescope-smart-history.
telescope.load_extension("smart_history")
-- This is needed to setup projects.nvim
telescope.load_extension("projects")
-- This is needed to setup noice.nvim
telescope.load_extension("noice")
-- This is needed to setup yanky
telescope.load_extension("yank_history")

-- Set mappings for yanky here to avoid cycle referencing
local options = require("yanky.config").options
require("yanky.config").setup(options)
