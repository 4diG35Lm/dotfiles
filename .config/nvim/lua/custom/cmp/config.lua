local status, cmp = pcall(require, "cmp")
if not status then
  return
end

local capabilities = require("cmp_nvim_lsp").default_capabilities()
local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd
local lsp = vim.lsp
local palette = require("custom.core.utils.palette").nord
local uv = vim.uv

local opts = { noremap = true, silent = true }
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end

local t = function(str)
  return api.nvim_replace_termcodes(str, true, true, true)
end
local lspkind = require("lspkind")
lspkind.init({
  mode = 'symbol_text',
  preset = 'codicons',
  symbol_map = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "",
  },
})

local luasnip = require "luasnip"
local lsp_colors = require("lsp-colors")
lsp_colors.setup({
  Error = "#db4b4b",
  Warning = "#e0af68",
  Information = "#0db9d7",
  Hint = "#10B981"
})

local saga = require "lspsaga"

saga.setup({
  -- defaults ...
  code_action_icon = " ",
  code_action_lightbulb = {
    virtual_text = false,
  },
  finder = {
    edit = { "o", "<CR>" },
    vsplit = "s",
    split = "i",
    tabe = "t",
    quit = { "q", "<ESC>" },
  },
  finder_action_keys = {
    open = "o",
    vsplit = "s",
    split = "i",
    tabe = "t",
    quit = "q",
    scroll_down = "<C-f>",
    scroll_up = "<C-b>", -- quit can be a table
  },
  code_action = {
    num_shortcut = true,
    keys = {
      -- string | table type
      quit = "q",
      exec = "<CR>",
    },
  },
  symbol_in_winbar = {
    enable = false,
  },
  ui = {
    border = "single",
    title = false,
  },
  lightbulb = {
    enable = false,
  },
})
local on_attach = function(client, bufnr)
  client.server_capabilities.documentFormattingProvider = false
  local set = vim.keymap.set
  set("n", "K", "<cmd>Lspsaga hover_doc<CR>")
  set("n", "<leader>1", "<cmd>Lspsaga finder<CR>")
  set("n", "<leader>2", "<cmd>Lspsaga rename<CR>")
  set("n", "<leader>3", "<cmd>Lspsaga code_action<CR>")
  set("n", "<leader>4", "<cmd>Lspsaga show_line_diagnostics<CR>")
  set("n", "<leader>5", "<cmd>Lspsaga peek_definition<CR>")
  set("n", "<leader>[", "<cmd>Lspsaga diagnostic_jump_prev<CR>")
  set("n", "<leaaer>]", "<cmd>Lspsaga diagnostic_jump_next<CR>")
end
lsp.handlers["textDocument/publishDiagnostics"] =
  lsp.with(lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })

map("n", "[_Lsp]r", "<cmd>Lspsaga rename<cr>", opts)
map("n", "M", "<cmd>Lspsaga code_action<cr>", opts)
map("x", "M", ":<c-u>Lspsaga range_code_action<cr>", opts)
map("n", "?", "<cmd>Lspsaga hover_doc<cr>", opts)
map("n", "[_Lsp]o", "<cmd>Lspsaga show_line_diagnostics<cr>", opts)
map("n", "[_Lsp]j", "<cmd>Lspsaga diagnostic_jump_next<cr>", opts)
map("n", "[_Lsp]k", "<cmd>Lspsaga diagnostic_jump_prev<cr>", opts)
map("n", "[_Lsp]f", "<cmd>Lspsaga lsp_finder<CR>", opts)
map("n", "[_Lsp]s", "<Cmd>Lspsaga signature_help<CR>", opts)
map("n", "[_Lsp]d", "<cmd>Lspsaga preview_definition<CR>", { silent = true })
map("n", "[_Lsp]o", "<cmd>LSoutlineToggle<CR>", { silent = true })

require("luasnip/loaders/from_vscode").lazy_load()

local lspkind = require "lspkind"
lspkind.init({
	mode = "symbol_text",
	preset = "codicons",
	symbol_map = {
		Text = "",
		Method = "",
		Function = "",
		Constructor = "",
		Field = "ﰠ",
		Variable = "",
		Class = "ﴯ",
		Interface = "",
		Module = "",
		Property = "ﰠ",
		Unit = "塞",
		Value = "",
		Enum = "",
		Keyword = "",
		Snippet = "",
		Color = "",
		File = "",
		Reference = "",
		Folder = "",
		EnumMember = "",
		Constant = "",
		Struct = "פּ",
		Event = "",
		Operator = "",
		TypeParameter = "",
	},
})

local cmp_dictionary = require  "cmp_dictionary"

local file = vim.fn.stdpath("data") .. "/fish/dictionary/my.dict"
local dic = {}
if fn.filereadable(file) ~= 0 then
	dic = file
end
cmp_dictionary.setup({
	dic = { ["*"] = dic },
	-- The following are default values, so you don't need to write them if you don't want to change them
	exact = 2,
	async = false,
	capacity = 5,
	debug = false,
})
-- If you want insert `(` after select function or method item
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local handlers = require('nvim-autopairs.completion.handlers')

cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done({
    filetypes = {
      -- "*" is a alias to all filetypes
      ["*"] = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method,
          },
          handler = handlers["*"]
        }
      },
      lua = {
        ["("] = {
          kind = {
            cmp.lsp.CompletionItemKind.Function,
            cmp.lsp.CompletionItemKind.Method
          },
          ---@param char string
          ---@param item table item completion
          ---@param bufnr number buffer number
          ---@param rules table
          ---@param commit_character table<string>
          handler = function(char, item, bufnr, rules, commit_character)
            -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr, rules, commit_character})
          end
        }
      },
      -- Disable for tex
      tex = false
    }
  })
)
local check_backspace = function()
  local col = fn.col "." - 1
  return col == 0 or fn.getline("."):sub(col, col):match "%s"
end

local check_back_space = function()
  local col = fn.col "." - 1
  return col == 0 or fn.getline("."):sub(col, col):match "%s" ~= nil
end
local has_words_before = function()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then
    return false
  end
  local line, col = vim.uv(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
end
cmp.setup {
  preselect = cmp.PreselectMode.None,
  enabled = function()
    if vim.api.nvim_get_mode().mode == "c" then
      return true
    end
  end,
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
      fn["vsnip#anonymous"](args.body)
      if not luasnip then
        return
      end
      luasnip.lsp_expand(args.body)
    end,
  },
  callback = function()
    local val = fn.mode():match "[icrR]" and 1 or 0
    set_karabiner(val)()
  end,
  api.create_autocmd("ColorScheme", {
    group = api.create_augroup("cmp_nord", {}),
    pattern = "nord",
    callback = function()
      api.set_hl(0, "CmpItemAbbrDeprecated", { fg = palette.brighter_black, bold = true })
      api.set_hl(0, "CmpItemAbbrMatch", { fg = palette.yellow })
      api.set_hl(0, "CmpItemAbbrMatchFuzzy", { fg = palette.orange })
      api.set_hl(0, "CmpItemMenu", { fg = palette.brighter_black, bold = true })
      api.set_hl(0, "CmpItemKindText", { fg = palette.blue })
      api.set_hl(0, "CmpItemKindMethod", { fg = palette.magenta })
      api.set_hl(0, "CmpItemKindFunction", { fg = palette.magenta })
      api.set_hl(0, "CmpItemKindConstructor", { fg = palette.magenta, bold = true })
      api.set_hl(0, "CmpItemKindField", { fg = palette.green })
      api.set_hl(0, "CmpItemKindVariable", { fg = palette.cyan })
      api.set_hl(0, "CmpItemKindClass", { fg = palette.yellow })
      api.set_hl(0, "CmpItemKindInterface", { fg = palette.bright_cyan })
      api.set_hl(0, "CmpItemKindModule", { fg = palette.yellow })
      api.set_hl(0, "CmpItemKindProperty", { fg = palette.green })
      api.set_hl(0, "CmpItemKindUnit", { fg = palette.magenta })
      api.set_hl(0, "CmpItemKindValue", { fg = palette.bright_cyan })
      api.set_hl(0, "CmpItemKindEnum", { fg = palette.bright_cyan })
      api.set_hl(0, "CmpItemKindKeyword", { fg = palette.dark_blue })
      api.set_hl(0, "CmpItemKindSnippet", { fg = palette.orange })
      api.set_hl(0, "CmpItemKindColor", { fg = palette.yellow })
      api.set_hl(0, "CmpItemKindFile", { fg = palette.green })
      api.set_hl(0, "CmpItemKindReference", { fg = palette.magenta })
      api.set_hl(0, "CmpItemKindFolder", { fg = palette.green })
      api.set_hl(0, "CmpItemKindEnumMember", { fg = palette.bright_cyan })
      api.set_hl(0, "CmpItemKindConstant", { fg = palette.dark_blue })
      api.set_hl(0, "CmpItemKindStruct", { fg = palette.bright_cyan })
      api.set_hl(0, "CmpItemKindEvent", { fg = palette.orange })
      api.set_hl(0, "CmpItemKindOperator", { fg = palette.magenta })
      api.set_hl(0, "CmpItemKindTypeParameter", { fg = palette.bright_cyan })
    end,
  }),
  mapping = cmp.mapping.preset.insert {
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-p>"] = cmp.mapping.select_prev_item(),
    ["<C-n>"] = cmp.mapping.select_next_item(),
    ["<C-l>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
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
  },
  sources = cmp.config.sources {
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
--     {
--       name = "tmux",
--       option = {
--         -- Source from all panes in session instead of adjacent panes
--         all_panes = false,
--
--         -- Completion popup label
--         label = "[tmux]",
--
--         -- Trigger character
--         trigger_characters = { "." },
--
--         -- Specify trigger characters for filetype(s)
--         -- { filetype = { '.' } }
--         trigger_characters_ft = {},
--
--         -- Keyword patch mattern
--         keyword_pattern = [[\w\+]],
--       },
--     },
    { name = "fuzzy_path" },
    { name = "treesitter" },
    {
      name = "fonts",
      option = {
        space_filter = "-",
      },
    },
    { name = "luasnip" },
    { name = "vsnip"},
  },
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50,
      ellipsis_char = '...',
      before = function (entry, vim_item)
        return vim_item
      end
    })
--     format = function(_, vim_item)
--       local icons = require("custom.constants").icons.kinds
--       -- fancy icons and a name of kind
--       vim_item.kind = lspkind.presets.default[vim_item.kind] .. " " .. vim_item.kind
--       -- set a name for each source
--       vim_item.menu = ({
--         buffer = "[buf]",
--         nvim_lsp = "[LSP]",
--         path = "[path]",
--       })[entry.source.name]
--       if icons[vim_item.kind] then
--         vim_item.kind = icons[vim_item.kind].. vim_item.kind
--       end
--       return vim_item
--     end,
  },
  experimental = {
    ghost_text = true,
  },
}

cmp.setup.cmdline(":", {
  sources = cmp.config.sources {
    { name = "fuzzy_path", option = { fd_timeout_msec = 1500 } },
  },
})

cmp.setup.cmdline({"/",  "?"}, {
  mapping = cmp.mapping.preset.cmdline(),
  source = cmp.config.sources {
    { name = "buffer" },
  },
})
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
cmd [[highlight Pmenu guibg=NONE]]
local cmp_autopairs = require "nvim-autopairs.completion.cmp"
local handlers = require "nvim-autopairs.completion.handlers"

cmp.event:on(
  "confirm_done",
  cmp_autopairs.on_confirm_done {
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
          ---@param char string
          ---@param item item completion
          ---@param bufnr buffer number
          handler = function(char, item, bufnr)
            -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr})
          end,
        },
      },
      -- Disable for tex
      tex = false,
    },
  }
)

-- The following example advertise capabilities to `clangd`.
require("lspconfig").clangd.setup {
  capabilities = capabilities,
}
