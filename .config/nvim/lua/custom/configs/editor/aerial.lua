local status,  aerial = pcall(require,  "aerial")
if (not status) then return end

local const = require("custom.constants")
local icons = vim.deepcopy(const.icons.kinds)
icons.lua = { Package = icons.Control }
-- Call the setup function to change the default behavior
aerial.setup({
	backends = { "treesitter", "lsp", "markdown", "man" },
	layout = {
    resize_to_content = true,
		max_width = { 40, 0.2 },
		width = nil,
		min_width = 10,
		default_direction = "prefer_right",
		placement = "window",
    win_opts = {
      winhl = "Normal:NormalFloat,FloatBorder:NormalFloat,SignColumn:SignColumnSB",
      signcolumn = "yes",
      statuscolumn = " ",
    },
	},
	attach_mode = "window",
	close_automatic_events = {},
	default_bindings = true,
	disable_max_lines = 10000,
	disable_max_size = 2000000, -- Default 2MB
	filter_kind = {
		"Class",
		"Constructor",
		"Enum",
		"Function",
		"Interface",
		"Method",
		"Module",
		"Struct",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    "Package",
    "Property",
    "Struct",
    "Trait",
	},
	highlight_mode = "split_width",
	highlight_closest = true,
	highlight_on_hover = false,
	highlight_on_jump = 300,
	icons = icons,
	ignore = {
		unlisted_buffers = true,
		filetypes = {},
		buftypes = "special",
		wintypes = "special",
	},
	link_folds_to_tree = false,
	link_tree_to_folds = true,
	manage_folds = false,
	nerd_font = "auto",
	on_attach = nil,
	on_first_symbols = nil,
	open_automatic = false,
	post_jump_cmd = "normal! zz",
	close_on_select = false,
	show_guides = false,
	update_events = "TextChanged,InsertLeave",
	guides = {
		mid_item = "├─",
		last_item = "└─",
		nested_top = "│ ",
		whitespace = "  ",
	},

	float = {
		border = "rounded",
		relative = "cursor",
		max_height = 0.9,
		height = nil,
		min_height = { 8, 0.1 },

		override = function(conf)
			return conf
		end,
	},

	lsp = {
		diagnostics_trigger_update = true,
		update_when_errors = true,
		update_delay = 300,
	},

	treesitter = {
		update_delay = 300,
	},

	markdown = {
		update_delay = 300,
	},
  help = false,
  lua = {
    "Class",
    "Constructor",
    "Enum",
    "Field",
    "Function",
    "Interface",
    "Method",
    "Module",
    "Namespace",
    -- "Package", -- remove package since luals uses it for control flow structures
    "Property",
    "Struct",
    "Trait",
  },
  -- stylua: ignore
  guides = {
    mid_item   = "├╴",
    last_item  = "└╴",
    nested_top = "│ ",
    whitespace = "  ",
  },
})

vim.keymap.set("n", "gt", "<Cmd>:AerialToggle<CR>", { noremap = true, silent = true })
