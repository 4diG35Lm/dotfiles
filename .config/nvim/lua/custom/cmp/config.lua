-- custom.plugins.cmp.config
local status, cmp = pcall(require, "cmp")
if not status then
	return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

-- loads vscode style snippets from installed plugins (e.g. friendly-snippets)
require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	completion = {
		completeopt = "menu,menuone,preview,noselect",
	},
	preselect = cmp.PreselectMode.None,
	window = {
		completion = {
			col_offset = -3,
			side_padding = 0,
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
			winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
		},
		documentation = {
			border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
			winhighlight = "Normal:CmpPmenu,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
		},
	},
	snippet = {
		expand = function(args)
			vim.fn["vsnip#anonymous"](args.body)
			luasnip.lsp_expand(args.body)
		end,
	},
	mapping = cmp.mapping.preset.insert({
		["<C-p>"] = cmp.mapping.select_prev_item(),
		["<C-n>"] = cmp.mapping.select_next_item(),
		["<C-l>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<CR>"] = cmp.mapping.confirm({ select = true }),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			else
				fallback()
			end
		end, { "i", "s" }),
		["<C-k>"] = cmp.mapping(function(fallback)
			if luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { "i", "s" }),
	}),

	sources = cmp.config.sources({
		{
			name = "nvim_lsp",
			option = {
				php = {
					keyword_pattern = [=[[\%(\$\k*\)\|\k\+]]=],
				},
			},
		},
		{ name = "nvim_lsp_signature_help" },
		{ name = "path" },
		{ name = "buffer" },
		{ name = "nvim_lua" },
		{ name = "luasnip" },
		{ name = "cmdline" },
		{ name = "git" },
		{ name = "omni" },
		{ name = "emoji" },
		{ name = "calc" },
		{ name = "mocword" },
		{
			name = "dictionary",
			keyword_length = 2,
		},
		{ name = "nvim_lsp_document_symbol" },
		{ name = "nvim_lsp_signature_help" },
		{ name = "fish" },
		{ name = "tags" },
		{ name = "vim_lsp" },
		{
			name = "tmux",
			option = {
				-- Source from all panes in session instead of adjacent panes
				all_panes = false,

				-- Completion popup label
				label = "[tmux]",

				-- Trigger character
				trigger_characters = { "." },

				-- Specify trigger characters for filetype(s)
				-- { filetype = { '.' } }
				trigger_characters_ft = {},

				-- Keyword patch mattern
				keyword_pattern = [[\w\+]],
			},
		},
		{ name = "fuzzy_path" },
		{ name = "treesitter" },
		{
			name = "fonts",
			option = {
				space_filter = "-",
			},
		},
		{ name = "luasnip" },
	}),
	formatting = {
		format = function(entry, vim_item)
			-- fancy icons and a name of kind
			vim_item.kind = require("lspkind").presets.default[vim_item.kind] .. " " .. vim_item.kind
			-- set a name for each source
			vim_item.menu = ({
				buffer = "[buf]",
				nvim_lsp = "[LSP]",
				path = "[path]",
			})[entry.source.name]
			return vim_item
		end,
	},
	experimental = {
		ghost_text = true,
	},
})

cmp.setup.cmdline(":", {
	sources = cmp.config.sources({
		{ name = "fuzzy_path", option = { fd_timeout_msec = 1500 } },
	}),
})

cmp.setup.cmdline("/", {
	mapping = cmp.mapping.preset.cmdline(),
	source = cmp.config.sources({
		{ name = "buffer" },
	}),
})

vim.cmd([[highlight Pmenu guibg=NONE]])
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local handlers = require("nvim-autopairs.completion.handlers")

vim.cmd([[
  set completeopt=menuone,noinsert,noselect
  highlight! default link CmpItemKind CmpItemMenuDefault
]])

cmp.event:on(
	"confirm_done",
	cmp_autopairs.on_confirm_done({
		filetypes = {
			-- "*" is a alias to all filetypes
			["*"] = {
				["("] = {
					kind = {
						cmp.lsp.CompletionItemKind.Function,
						cmp.lsp.CompletionItemKind.Method,
					},
					handler = handlers["*"],
				},
			},
			lua = {
				["("] = {
					kind = {
						cmp.lsp.CompletionItemKind.Function,
						cmp.lsp.CompletionItemKind.Method,
					},
				},
			},
			-- Disable for tex
			tex = false,
		},
	})
)
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- The following example advertise capabilities to `clangd`.
require("lspconfig").clangd.setup({
	capabilities = capabilities,
})

local dict = require("cmp_dictionary")

dict.setup({
	-- The following are default values.
	exact = 2,
	first_case_insensitive = false,
	document = false,
	document_command = "wn %s -over",
	sqlite = false,
	max_items = -1,
	capacity = 5,
	debug = false,
})

dict.switcher({
	filetype = {
		lua = {},
		javascript = {},
	},
	filepath = {
		[".*xmake.lua"] = {},
	},
	spelllang = {
		en = "/path/to/english.dict",
	},
})
