-- custom.configs.nvim-tree
local status, nvim_tree = pcall(require, "nvim-tree")
if not status then
	return
end
-- recommended settings from nvim-tree documentation
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- change color for arrows in tree to light blue
vim.cmd([[ highlight NvimTreeFolderArrowClosed guifg=#3FC5FF ]])
vim.cmd([[ highlight NvimTreeFolderArrowOpen guifg=#3FC5FF ]])

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
local lib = require("nvim-tree.lib")
local view = require("nvim-tree.view")
local api = require("nvim-tree.api")

local function collapse_all()
	require("nvim-tree.actions.tree-modifiers.collapse-all").fn()
end

local function edit_or_open()
	-- open as vsplit on current node
	local action = "edit"
	local node = lib.get_node_at_cursor()

	-- Just copy what's done normally with vsplit
	if node.link_to and not node.nodes then
		require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
		view.close() -- Close the tree if file was opened
	elseif node.nodes ~= nil then
		lib.expand_or_collapse(node)
	else
		require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
		view.close() -- Close the tree if file was opened
	end
end

local function vsplit_preview()
	-- open as vsplit on current node
	local action = "vsplit"
	local node = lib.get_node_at_cursor()

	-- Just copy what's done normally with vsplit
	if node.link_to and not node.nodes then
		require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
	elseif node.nodes ~= nil then
		lib.expand_or_collapse(node)
	else
		require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
	end

	-- Finally refocus on tree if it was lost
	view.focus()
end

local git_add = function()
	local node = lib.get_node_at_cursor()
	local gs = node.git_status.file

	-- If the file is untracked, unstaged or partially staged, we stage it
	if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
		vim.cmd("silent !git add " .. node.absolute_path)

	-- If the file is staged, we unstage
	elseif gs == "M " or gs == "A " then
		vim.cmd("silent !git restore --staged " .. node.absolute_path)
	end

	lib.refresh_tree()
end
local bindings = {
	a = "create",
	d = "remove",
	l = "parent_node",
	L = "dir_up",
	K = "last_sibling",
	J = "first_sibling",
	o = "system_open",
	p = "paste",
	r = "rename",
	R = "refresh",
	t = "next_sibling",
	T = "prev_sibling",
	v = "next_git_item",
	V = "prev_git_item",
	x = "cut",
	yl = "copy_name",
	yp = "copy_path",
	ya = "copy_absolute_path",
	yy = "copy",
	[";"] = "edit",
	["."] = "toggle_ignored",
	["h"] = "toggle_help",
	["<bs>"] = "close_node",
	["<tab>"] = "preview",
	["<s-c>"] = "close_node",
	["<c-r>"] = "full_rename",
	["<c-t>"] = "tabnew",
	["<c-x>"] = "split",
}

local function setup_bindings(buf_id)
	local cb = require("nvim-tree.config").nvim_tree_callback
	for key, value in pairs(bindings) do
		vim.api.nvim_buf_set_keymap(buf_id, "n", key, cb(value), { noremap = true, silent = true, nowait = true })
	end
end

-- https://github.com/sindrets/dotfiles/blob/cafb333578a1ad482531ba5091c5171b32525d24/.config/nvim/lua/nvim-config/plugins/nvim-tree.lua#L67-L120
local function custom_setup()
	local buf_id = vim.api.nvim_get_current_buf()
	local ok, custom_setup_done = pcall(vim.api.nvim_buf_get_var, buf_id, "custom_setup_done")

	if ok and custom_setup_done == 1 then
		return
	end

	vim.api.nvim_buf_set_var(buf_id, "custom_setup_done", 1)
	setup_bindings(buf_id)
end

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "NvimTree" },
	callback = custom_setup,
})
local function change_root_to_global_cwd()
	local global_cwd = vim.fn.getcwd(-1, -1)
	api.tree.change_root(global_cwd)
end

local config = {
	actions = {
		open_file = {
			quit_on_open = false,
			window_picker = {
				enable = false,
			},
		},
	},
	open_on_setup = not vim.g.started_by_firenvim,
	diagnostics = {
		enable = true,
	},
	disable_netrw = true,
	hijack_netrw = true,
	hijack_cursor = true,
	mappings = {
		custom_only = false,
		list = {
			{ key = "l", action = "edit", action_cb = edit_or_open },
			{ key = "L", action = "vsplit_preview", action_cb = vsplit_preview },
			{ key = "h", action = "close_node" },
			{ key = "H", action = "collapse_all", action_cb = collapse_all },
			{ key = "<C-C>", action = "global_cwd", action_cb = change_root_to_global_cwd },
			{ key = "ga", action = "git_add", action_cb = git_add },
		},
	},
	live_filter = {
		prefix = "[FILTER]: ",
		always_show_folders = false, -- Turn into false from true by default
	},
	update_cwd = true,
	update_focused_file = {
		enable = true,
		update_cwd = true,
	},
	renderer = {
		indent_markers = {
			enable = true,
		},
		icons = {
			glyphs = {
				folder = {
					arrow_closed = "", -- arrow when folder is closed
					arrow_open = "", -- arrow when folder is open
				},
			},
		},
		highlight_opened_files = "name",
		group_empty = true,
	},
	view = {
		adaptive_size = true,
		mappings = { custom_only = true },
		relativenumber = true,
	},
	filters = {
		custom = { ".git", ".DS_Store" },
		dotfiles = true,
	},
	git = {
		ignore = false,
	},
}
api.events.subscribe(api.events.Event.FileCreated, function(file)
	vim.cmd("edit " .. file.fname)
end)
nvim_tree.setup(config)
nvim_tree.events.on_file_created(function(ev)
	local fname = ev.fname
	-- makes relevant files executables
	if (fname:match("/%.local/bin/") or fname:match("^%.local/bin/")) and not fname:match("%.local/bin/.+%.") then
		os.execute(string.format("chmod +x %q", fname))
	end
	-- when new file belongs to an active stow package, stow it
	local dots = os.getenv("DOTFILES")
	if vim.fn.getcwd() == dots then
		local stow_package = fname:match("^(.-)/", #dots + 2)
		if
			require("utils.std").file_exists(
				string.format("%s/.config/stow/active/%s", os.getenv("HOME"), stow_package)
			)
		then
			os.execute(string.format("stow %q", stow_package))
		end
	end
	vim.cmd(string.format("e %s", fname))
	require("templum").template_match()
end)
