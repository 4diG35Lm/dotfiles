local status, telescope = pcall(require, "telescope")
if (not status) then return end

local fn, uv, api = require("core.utils").globals()
local keymap = vim.keymap
local actions = require("telescope.actions")
local action_layout = require("telescope.actions.layout")
local config = require("telescope.config")
local finders = require("telescope.finders")
local make_entry = require("telescope.make_entry")
local previewers = require("telescope.previewers")
local utils = require("telescope.utils")
local conf = require("telescope.config").values
local telescope_builtin = require("telescope.builtin")
local Path = require("plenary.path")
local trouble = require("trouble.providers.telescope")
local frecency = require"telescope".load_extension("frecency")
local action_state = require("telescope.actions.state")
local transform_mod = require("telescope.actions.mt").transform_mod
local live_grep_args = require("telescope").load_extension("live_grep_args")
local lga_actions = require("telescope-live-grep-args.actions")

local function multiopen(prompt_bufnr, method)
	local edit_file_cmd_map = {
		vertical = "vsplit",
		horizontal = "split",
		tab = "tabedit",
		default = "edit",
	}
	local edit_buf_cmd_map = {
		vertical = "vert sbuffer",
		horizontal = "sbuffer",
		tab = "tab sbuffer",
		default = "buffer",
	}
	 local picker = action_state.get_current_picker(prompt_bufnr)
	 local multi_selection = picker:get_multi_selection()

	if #multi_selection > 1 then
		 telescope.pickers.on_close_prompt(prompt_bufnr)
		 pcall(vim.api.nvim_set_current_win, picker.original_win_id)

		for i, entry in ipairs(multi_selection) do
			local filename, row, col

			if entry.path or entry.filename then
				filename = entry.path or entry.filename

				row = entry.row or entry.lnum
				col = vim.F.if_nil(entry.col, 1)
			elseif not entry.bufnr then
				local value = entry.value
				if not value then
					return
				end

				if type(value) == "table" then
					value = entry.display
				end

				local sections = vim.split(value, ":")

				filename = sections[1]
				row = tonumber(sections[2])
				col = tonumber(sections[3])
			end

			local entry_bufnr = entry.bufnr

			if entry_bufnr then
				if not vim.api.nvim_buf_get_option(entry_bufnr, "buflisted") then
					vim.api.nvim_buf_set_option(entry_bufnr, "buflisted", true)
				end
				local command = i == 1 and "buffer" or edit_buf_cmd_map[method]
				pcall(vim.cmd, string.format("%s %s", command, vim.api.nvim_buf_get_name(entry_bufnr)))
			else
				local command = i == 1 and "edit" or edit_file_cmd_map[method]
				if vim.api.nvim_buf_get_name(0) ~= filename or command ~= "edit" then
					filename = require("plenary.path"):new(vim.fn.fnameescape(filename)):normalize(vim.loop.cwd())
					pcall(vim.cmd, string.format("%s %s", command, filename))
				end
			end

			if row and col then
				pcall(vim.api.nvim_win_set_cursor, 0, { row, col })
			end
		end
	else
		actions["select_" .. method](prompt_bufnr)
	end
end

local custom_actions = transform_mod({
	multi_selection_open_vertical = function(prompt_bufnr)
		multiopen(prompt_bufnr, "vertical")
	end,
	multi_selection_open_horizontal = function(prompt_bufnr)
		multiopen(prompt_bufnr, "horizontal")
	end,
	multi_selection_open_tab = function(prompt_bufnr)
		multiopen(prompt_bufnr, "tab")
	end,
	multi_selection_open = function(prompt_bufnr)
		multiopen(prompt_bufnr, "default")
	end,
})

local function use_normal_mapping(key)
	return function()
		vim.cmd.stopinsert()
		local key_code = vim.api.nvim_replace_termcodes(key, true, false, true)
		vim.api.nvim_feedkeys(key_code, "m", false)
	end
end
api.create_autocmd("ColorScheme", {
  group = api.create_augroup("telescope-colors", {}),
  pattern = "nord",
  callback = function()
    api.set_hl(0, "TelescopeMatching", { fg = palette.magenta })
    api.set_hl(0, "TelescopePreviewBorder", { fg = palette.green })
    api.set_hl(0, "TelescopePromptBorder", { fg = palette.cyan })
    api.set_hl(0, "TelescopeResultsBorder", { fg = palette.blue })
    api.set_hl(0, "TelescopeSelection", { fg = palette.blue })
    api.set_hl(0, "TelescopeSelectionCaret", { fg = palette.blue })

    api.set_hl(0, "TelescopeBufferLoaded", { fg = palette.magenta })
    api.set_hl(0, "TelescopePathSeparator", { fg = palette.brighter_black })
    api.set_hl(0, "TelescopeFrecencyScores", { fg = palette.yellow })
    api.set_hl(0, "TelescopeQueryFilter", { fg = palette.bright_cyan })
  end,
})

local function builtin(name)
  return function(opt)
    return function()
      return require('telescope.builtin')[name](opt or {})
    end
  end
end

local function extensions(name, prop)
  return function(opt)
    return function()
      local telescope = require "telescope"
      telescope.load_extension(name)
      return telescope.extensions[name][prop](opt or {})
    end
  end
end

-- Lines
keymap.set("n", "#", builtin "current_buffer_fuzzy_find" {})

-- Files
keymap.set("n", "<Leader>fB", builtin "buffers" {})
keymap.set("n", "<Leader>fb", function()
  local cwd = fn.expand "%:h"
  extensions("file_browser", "file_browser") { cwd = cwd == "" and nil or cwd }()
end)
keymap.set("n", "<Leader>ff", function()
  -- TODO: stopgap measure
  if uv.cwd() == uv.os_homedir() then
    api.echo({
      {
        "find_files on $HOME is danger. Launch file_browser instead.",
        "WarningMsg",
      },
    }, true, {})
    extensions("file_browser", "file_browser") {}()
    -- TODO: use uv.fs_stat ?
  elseif fn.isdirectory(uv.cwd() .. "/.git") == 1 then
    builtin "git_files" { show_untracked = true }()
  else
    builtin "find_files" { hidden = true }()
  end
end)

local function input_grep_string(prompt, func)
  return function()
    vim.ui.input({ prompt = prompt }, function(input)
      if input then
        func { only_sort_text = true, search = input }()
      else
        vim.notify "cancelled"
      end
    end)
  end
end

keymap.set("n", "<Leader>f:", builtin "command_history" {})
keymap.set("n", "<Leader>fG", builtin "grep_string" {})
keymap.set("n", "<Leader>fH", builtin "help_tags" { lang = "en" })
keymap.set("n", "<Leader>fN", extensions("node_modules", "list") {})
keymap.set("n", "<Leader>fg", input_grep_string("Grep For ❯ ", builtin "grep_string"))
keymap.set("n", "<Leader>fh", builtin "help_tags" {})
keymap.set("n", "<Leader>fm", builtin "man_pages" { sections = { "ALL" } })
keymap.set("n", "<Leader>fn", extensions("noice", "noice") {})
keymap.set("n", "<leader>nl", function()
  require("noice").cmd("last")
end)
keymap.set("n", "<leader>nh", function()
  require("noice").cmd("history")
end)
keymap.set("n", "<Leader>fo", extensions("frecency", "frecency") { path_display = frecency.path_display })
keymap.set("n", "<Leader>fp", extensions("projects", "projects") {})
keymap.set(
  "n",
  "<Leader>fq",
  extensions("ghq", "list") {
    attach_mappings = function(_)
      local actions_set = require "telescope.actions.set"
      actions_set.select:replace(function(_, _)
        local from_entry = require "telescope.from_entry"
        local actions_state = require "telescope.actions.state"
        local entry = actions_state.get_selected_entry()
        local dir = from_entry.path(entry)
        builtin "git_files" { cwd = dir, show_untracked = true }()
      end)
      return true
    end,
  }
)
keymap.set("n", "<Leader>fr", builtin "resume" {})

keymap.set(
  "n",
  "<Leader>fv",
  extensions("file_browser", "file_browser") {
    add_dirs = false,
    depth = false,
    hide_parent_dir = true,
    path = "$VIMRUNTIME",
  }
)
keymap.set("n", "<Leader>fy", extensions("yank_history", "yank_history") {})

keymap.set("n", "<Leader>fz", function()
  extensions("z", "list") {
    previewer = require("telescope.previewers.term_previewer").new_termopen_previewer {
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
          vim.cmd.normal { args = { count .. input }, bang = true }
        end)
      end,
    },
  }
end)

-- Memo
keymap.set("n", "<Leader>mm", extensions("memo", "list") {})
keymap.set("n", "<Leader>mg", input_grep_string("Memo Grep For ❯ ", extensions("memo", "grep_string")))

-- LSP
keymap.set("n", "<Leader>sr", builtin "lsp_references" {})
keymap.set("n", "<Leader>sd", builtin "lsp_document_symbols" {})
keymap.set("n", "<Leader>sw", builtin "lsp_workspace_symbols" {})
keymap.set("n", "<Leader>sc", builtin "lsp_code_actions" {})

-- Git
keymap.set("n", "<Leader>gc", builtin "git_commits" {})
keymap.set("n", "<Leader>gb", builtin "git_bcommits" {})
keymap.set("n", "<Leader>gr", builtin "git_branches" {})
keymap.set("n", "<Leader>gs", builtin "git_status" {})

-- Copied from telescope.nvim
keymap.set("n", "q:", builtin "command_history" {})
-- keymap.set(
--   "c",
--   "<A-r>",
--   [[<C-\>e ]]
--     .. [["lua require'telescope.builtin'.command_history{]]
--     .. [[default_text = [=[" . escape(getcmdline(), '"') . "]=]}"<CR><CR>]],
--   { silent = true }
-- )

-- for telescope-frecency
api.create_autocmd({ "BufWinEnter", "BufWritePost" }, {
  group = api.create_augroup("TelescopeFrecency", {}),
  callback = function(args)
    local path = args.match
    if path and path ~= "" then
      local st = uv.fs_stat(path)
      if st then
        local db_client = require "telescope._extensions.frecency.db_client"
        db_client.init(nil, nil, true, true)
        db_client.autocmd_handler(args.match)
      end
    end
  end,
})

-- This is needed to setup telescope-fzf-native. It overrides the sorters
-- in this.
--	This is needed to setup telescope-smart-history.
telescope.load_extension "smart_history"
-- This is needed to setup projects.nvim
telescope.load_extension "projects"
-- This is needed to setup noice.nvim
telescope.load_extension "noice"
-- This is needed to setup yanky
telescope.load_extension "yank_history"

telescope.load_extension 'dap'

telescope.load_extension 'ghn'
telescope.load_extension 'noice'

require("dressing").setup {}

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
		},
		mappings = {
      i = {
        -- map actions.which_key to <C-h> (default: <C-/>)
        -- actions.which_key shows the mappings for your picker,
        -- e.g. git_{create, delete, ...}_branch for the git_branches picker
        ["<C-h>"] = "which_key"
      },
		},
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
	path_display = { "truncate" },
	dynamic_preview_title = true,
	winblend = 0,
	border = {},
	borderchars = {
	  { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
	  -- prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
	  -- results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
	  -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
	  -- fzf-preview style
			prompt = { "─", "│", " ", "│", "┌", "┬", "│", "│" },
	    results = { "─", "│", "─", "│", "├", "┤", "┴", "└" },
			preview = { "─", "│", "─", " ", "─", "┐", "┘", "─" },
	},
	color_devicons = true,
	use_less = true,
	scroll_strategy = "cycle",
	set_env = { ["COLORTERM"] = "truecolor" },  -- default { }, currently unsupported for shells like cmd.exe / powershell.exe
	-- file_previewer = require'telescope.previewers'.cat.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_cat.new`
	-- grep_previewer = require'telescope.previewers'.vimgrep.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_vimgrep.new`
	-- qflist_previewer = require'telescope.previewers'.qflist.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_qflist.new`
	-- Developer configurations: Not meant for general override
	buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
	mappings = {
		n = {
		  ["<C-t>"] = action_layout.toggle_preview,
			["<C-v>"] = use_normal_mapping("<C-v>"),
			["<C-s>"] = use_normal_mapping("<C-s>"),
			["<CR>"] = use_normal_mapping("<CR>"),
      ["<c-e>"] = trouble.open_with_trouble,
		},
		i = {
			["<C-t>"] = action_layout.toggle_preview,
			["<C-x>"] = false,
			-- ["<C-s>"] = actions.select_horizontal,
			["<Tab>"] = actions.toggle_selection + actions.move_selection_next,
			["<C-q>"] = actions.send_selected_to_qflist,
			-- ["<CR>"] = actions.select_default + actions.center,
			["<C-g>"] = custom_actions.multi_selection_open,
			["<C-v>"] = custom_actions.multi_selection_open_vertical,
			["<C-s>"] = custom_actions.multi_selection_open_horizontal,
			-- ["<C-t>"] = custom_actions.multi_selection_open_tab,
			["<CR>"] = custom_actions.multi_selection_open,
      ["<c-e>"] = trouble.open_with_trouble
		},
	},
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
	history = { path = vim.fn.stdpath("state") .. "/databases/telescope_history.sqlite3", limit = 100 },
	pickers = {
		colorscheme = {
			enable_preview = true,
		},
	},
	extensions = {
		media_files = {
			filetypes = { "png", "webp", "jpg", "jpeg" }, -- filetypes whitelist
			find_cmd = "rg", -- find command
		},
		arecibo = {
			["selected_engine"] = "google",
			["url_open_command"] = "xdg-open",
			["show_http_headers"] = false,
			["show_domain_icons"] = false,
		},
		frecency = {
			db_root = vim.fn.stdpath("state"),
			show_scores = false,
      show_unindexed = true,
			ignore_patterns = { "*.git/*", "*/tmp/*", "*/node_modules/*" },
			disable_devicons = false,
			db_safe_mode = false,
			auto_validate = true,
		},
		project = {
			base_dirs = (function()
				local dirs = {}
				local function file_exists(fname)
					local stat = vim.loop.fs_stat(vim.fn.expand(fname))
					return (stat and stat.type) or false
				end

        if file_exists("~/.ghq") then
					dirs[#dirs + 1] = { "~/.ghq", max_depth = 5 }
        end
		   if file_exists("~/Workspace") then
					dirs[#dirs + 1] = { "~/Workspace", max_depth = 3 }
				end
				if #dirs == 0 then
					return nil
		    end
		    return dirs
			end),
		},
		undo = {
			side_by_side = true,
			layout_strategy = "vertical",
			layout_config = {
				preview_height = 0.8,
			},
		},
		aerial = {
      -- Display symbols as <root>.<parent>.<symbol>
      show_nesting = {
        ['_'] = false, -- This key will be the default
        json = true,   -- You can set the option for specific filetypes
        yaml = true,
      }
		},
		fzf = {
		  fuzzy = true,
		  override_generic_sorter = true,
		  override_file_sorter = true,
		  case_mode = "smart_case",
		},
		live_grep_args = {
      auto_quoting = true, -- enable/disable auto-quoting
      -- define mappings, e.g.
      mappings = { -- extend mappings
        i = {
          ["<C-k>"] = lga_actions.quote_prompt(),
          ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
        },
      },
		},
	},
})

-- Set mappings for yanky here to avoid cycle referencing
local utils = require "yanky.utils"
local mapping = require "yanky.telescope.mapping"
local options = require("yanky.config").options
-- options.picker.telescope.mappings = {
--   default = mapping.put "p",
--   i = {
--     ["<A-p>"] = mapping.put "p",
--     ["<A-P>"] = mapping.put "P",
--     ["<A-d>"] = mapping.delete(),
--     ["<A-r>"] = mapping.set_register(utils.get_default_register()),
--   },
--   n = {
--     p = mapping.put "p",
--     P = mapping.put "P",
--     d = mapping.delete(),
--     r = mapping.set_register(utils.get_default_register()),
--   },
-- },
require("yanky.config").setup(options)

yanky = {
  setup = function()
    vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
    vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
    vim.keymap.set("n", "<A-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set("n", "<A-p>", "<Plug>(YankyCycleBackward)")
    vim.keymap.set("n", "<A-y>", "<Cmd>YankyRingHistory<CR>")
  end,

  config = function()
    require("yanky").setup {
      ring = { storage = "sqlite" },
    }
  end,
}
local function remove_duplicate_paths(tbl, cwd)
	local res = {}
	local hash = {}
	for _, v in ipairs(tbl) do
		local v1 = Path:new(v):normalize(cwd)
		if not hash[v1] then
			res[#res + 1] = v1
			hash[v1] = true
		end
	end
	return res
end

local function join_uniq(tbl, tbl2)
	local res = {}
	local hash = {}
	for _, v1 in ipairs(tbl) do
		res[#res + 1] = v1
		hash[v1] = true
	end

	for _, v in pairs(tbl2) do
		if not hash[v] then
			table.insert(res, v)
		end
	end
	return res
end

local function filter_by_cwd_paths(tbl, cwd)
	local res = {}
	local hash = {}
	for _, v in ipairs(tbl) do
		if v:find(cwd, 1, true) then
			local v1 = Path:new(v):normalize(cwd)
			if not hash[v1] then
				res[#res + 1] = v1
				hash[v1] = true
			end
		end
	end
	return res
end

local function requiref(module)
	require(module)
end

telescope_builtin.my_mru = function(opts)
	local get_mru = function(opts2)
		local res = pcall(requiref, "telescope._extensions.frecency")
		if not res then
			return vim.tbl_filter(function(val)
				return 0 ~= vim.fn.filereadable(val)
			end, vim.v.oldfiles)
		else
			local db_client = require("telescope._extensions.frecency.db_client")
			db_client.init()
			-- too slow
			-- local tbl = db_client.get_file_scores(opts, vim.fn.getcwd())
			local tbl = db_client.get_file_scores(opts2)
			local get_filename_table = function(tbl2)
				local res2 = {}
				for _, v in pairs(tbl2) do
					res2[#res2 + 1] = v["filename"]
				end
				return res2
			end
			return get_filename_table(tbl)
		end
	end
	local results_mru = get_mru(opts)
	local results_mru_cur = filter_by_cwd_paths(results_mru, vim.loop.cwd())

	local show_untracked = vim.F.if_nil(opts.show_untracked, true)
	local recurse_submodules = vim.F.if_nil(opts.recurse_submodules, false)
	if show_untracked and recurse_submodules then
		error("Git does not suppurt both --others and --recurse-submodules")
	end
	local cmd = {
		"git",
		"ls-files",
		"--exclude-standard",
		"--cached",
		show_untracked and "--others" or nil,
		recurse_submodules and "--recurse-submodules" or nil,
	}
	local results_git = utils.get_os_command_output(cmd)

	local results = join_uniq(results_mru_cur, results_git)

	 pickers
		.new(opts, {
			prompt_title = "MRU",
			finder = finders.new_table({
				results = results,
				entry_maker = opts.entry_maker or make_entry.gen_from_file(opts),
			}),
			-- default_text = vim.fn.getcwd(),
			sorter = conf.file_sorter(opts),
			previewer = conf.file_previewer(opts),
		})
		:find()
end

telescope_builtin.grep_prompt = function(opts)
	vim.ui.input({ prompt = "Grep String > " }, function(input)
		if input == nil then
			return
		end
		opts.search = input
		telescope_builtin.my_grep(opts)
	end)
end

telescope_builtin.my_grep = function(opts)
	require("telescope.builtin").grep_string({
		opts = opts,
		prompt_title = "grep_string: " .. opts.search,
		search = opts.search,
		use_regex = true,
	})
end

telescope_builtin.my_grep_in_dir = function(opts)
	vim.ui.input({ prompt = "Grep String > " }, function(input)
		if input == nil then
			return
		end
		opts.search = input
		opts.search_dirs = {}
		vim.ui.input({ prompt = "Target Directory > " }, function(input_dir)
			if input_dir == nil then
				return
			end
			opts.search_dirs[1] = input_dir
			require("telescope.builtin").grep_string({
				opts = opts,
				prompt_title = "grep_string(dir): " .. opts.search,
				search = opts.search,
				search_dirs = opts.search_dirs,
			})
		end)
	end)
end

telescope_builtin.memo = function(opts)
	require("telescope.builtin").find_files({
		opts = opts,
		prompt_title = "MemoList",
		find_command = { "find", vim.g.memolist_path, "-type", "f", "-exec", "ls", "-1ta", "{}", "+" },
	})
end

vim.api.nvim_set_keymap("n", "<Leader><Leader>", "<Cmd>Telescope my_mru<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]<Leader>",
	"<Cmd>Telescope find_files<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "<Leader>;", "<Cmd>Telescope git_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder];", "<Cmd>Telescope git_files<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"<Leader>.",
	"<Cmd>Telecwoc diagnosticsscope find_files<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap("n", "[_FuzzyFinder].", "<Cmd>Telescope my_mru<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<Leader>,", "<Cmd>Telescope grep_prompt<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder],", "<Cmd>Telescope grep_prompt<CR>", { noremap = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]>", "<Cmd>Telescope my_grep_in_dir<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"v",
	"[_FuzzyFinder],",
	"y:Telescope my_grep search=<C-r>=escape(@\", '\\.*$^[] ')<CR>",
	{ noremap = true }
)
vim.api.nvim_set_keymap(
	"n",
	"<Leader>/",
	":<C-u>Telescope my_grep search=<C-r>=expand('<cword>')<CR>",
	{ noremap = true }
)
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]/",
	":<C-u>Telescope my_grep search=<C-r>=expand('<cword>')<CR>",
	{ noremap = true }
)
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]s", "<Cmd>Telescope live_grep<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]b", "<Cmd>Telescope buffers<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]h", "<Cmd>Telescope help_tags<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]c", "<Cmd>Telescope commands<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]t", "<Cmd>Telescope treesitter<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]q", "<Cmd>Telescope quickfix<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]l", "<Cmd>Telescope loclist<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]m", "<Cmd>Telescope marks<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]r", "<Cmd>Telescope registers<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "[_FuzzyFinder]*", "<Cmd>Telescope grep_string<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]f",
	"<Cmd>Telescope file_browser file_browser<CR>",
	{ noremap = true, silent = true }
)
-- git
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]gs",
	"<Cmd>lua require('telescope.builtin').git_status()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]gc",
	"<Cmd>lua require('telescope.builtin').git_commits()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]gC",
	"<Cmd>lua require('telescope.builtin').git_bcommits()<CR>",
	{ noremap = true, silent = true }
)
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]gb",
	"<Cmd>lua require('telescope.builtin').git_branches()<CR>",
	{ noremap = true, silent = true }
)
-- extension
vim.api.nvim_set_keymap(
	"n",
	"[_FuzzyFinder]S",
	"<Cmd>lua require('telescope').extensions.arecibo.websearch()<CR>",
	{ noremap = true, silent = true }
)

vim.api.nvim_set_keymap("n", "[_FuzzyFinder]:", "<Cmd>Telescope command_history<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("c", "<C-t>", "<BS><Cmd>Telescope command_history<CR>", { noremap = true, silent = true })
-- telescope.load_extension "fzf"
--vim.api.nvim_set_keymap("n", "<leader>fg", ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>")
