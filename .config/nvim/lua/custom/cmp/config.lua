local status, cmp = pcall(require, "cmp")
if not status then
  return
end

local fn, _, api = require("custom.core.utils").globals()
local keymap = vim.keymap
local palette = require("custom.core.utils.palette").nord
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

local check_back_space = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s" ~= nil
end

cmp.setup {
  preselect = cmp.PreselectMode.None,
  enabled = function()
    if vim.api.nvim_get_mode().mode == "c" then
      return true
    else
      return not context.in_treesitter_capture "comment" and not context.in_syntax_group "Comment"
    end
  end,
  window = {
    completion = {
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
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
  experimental = {
    ghost_text = true,
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
      local luasnip = prequire "luasnip"
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
  },
  formatting = {
    format = function(entry, vim_item)
      local icons = {
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
      }
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
}

cmp.setup.cmdline(":", {
  sources = cmp.config.sources {
    { name = "fuzzy_path", option = { fd_timeout_msec = 1500 } },
  },
})

cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  source = cmp.config.sources {
    { name = "buffer" },
  },
})

vim.cmd [[highlight Pmenu guibg=NONE]]
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
-- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- The following example advertise capabilities to `clangd`.
require("lspconfig").clangd.setup {
  capabilities = capabilities,
}
