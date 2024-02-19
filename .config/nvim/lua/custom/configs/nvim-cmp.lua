local status, cmp = pcall(require, "cmp")
if (not status) then return end
local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end
-- require('luasnip.loaders.from_vscode').lazy_load()
vim.g.completeopt = { "menu", "menuone", "noselect" }
-- local cmp_under_comparator = require("cmp-under-comparator")
local types = require("cmp.types")
local luasnip = require("luasnip")
local lspkind = require('lspkind')
local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

--local fn, _, api = require("core.utils").globals()
local keymap = vim.keymap
-- local palette = require "core.utils.palette" "nord"
local source_names = {
  buffer     = {'BUF'  , 'String'},
  nvim_lsp   = {nil    , 'Question'},
  luasnip    = {'Snip' , 'CmpItemMenu'},
  -- nvim_lua   = {'Lua'  , 'ErrorMsg'},
  nvim_lua   = {'  '  , 'ErrorMsg'},
  nvim_lua   = {nil    , 'ErrorMsg'},
  path       = {'Path' , 'WarningMsg'},
  -- tmux       = {'Tmux' , 'CursorLineNr'},
  tmux       = {nil    , 'CursorLineNr'},
  gh         = {'GH'   , 'CmpItemMenu'},
  rg         = {'RG'   , 'CmpItemMenu'},
  cmdline    = {'CMD'  , 'CmpItemMenu'},
  spell      = {'Spell', 'CmpItemMenu'},
  -- treesitter = {'TS'   , 'Delimiter'}
  treesitter = {''    , 'Delimiter'}
}

local symbols = {
  Array = '',
  Boolean = '',
  Class = 'ﴯ',
  Color = '',
  Constant = '',
  Constructor = '',
  Enum = '',
  EnumMember = '',
  Event = '',
  Field = 'ﰠ',
  File = '',
  Folder = '',
  Function = '',
  Interface = '',
  Key = '',
  Keyword = '',
  Method = '',
  Module = '',
  Namespace = '',
  Null = 'ﳠ',
  Number = '',
  Object = '',
  Operator = '',
  Package = '',
  Property = 'ﰠ',
  Reference = '',
  Snippet = '',
  String = '',
  Struct = '',
  Text = '',
  TypeParameter = '',
  Unit = '',
  Value = '',
  Variable = '',
}
local aliases = {
  nvim_lsp = 'lsp',
  luasnip = 'snippet',
}

local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local select_opts = {behavior = cmp.SelectBehavior.Select}
local WIDE_HEIGHT = 60
require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

cmp.setup({
  formatting = {
    fields = {'abbr', 'kind', 'menu'},
    format = lspkind.cmp_format({
      with_text = true,
      -- Kind icons
      menu = {
        buffer = "[Buffer]",
        nvim_lsp = "[LSP]",
        cmp_tabnine = "[TabNine]",
        copilot = "[Copilot]",
        luasnip = "[LuaSnip]",
        nvim_lua = "[NeovimLua]",
        latex_symbols = "[LaTeX]",
        path = "[Path]",
        omni = "[Omni]",
        spell = "[Spell]",
        emoji = "[Emoji]",
        calc = "[Calc]",
        rg = "[Rg]",
        treesitter = "[TS]",
        dictionary = "[Dictionary]",
        mocword = "[mocword]",
        cmdline_history = "[History]",
      },
      mode = 'symbol', -- show only symbol annotations
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      ellipsis_char = '...', -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
    }),
  },
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  sorting = {
    comparators = {
      cmp.config.compare.offset,
      cmp.config.compare.exact,
      cmp.config.compare.score,
      -- cmp_under_comparator.under,
      function(entry1, entry2)
        local kind1 = entry1:get_kind()
        kind1 = kind1 == types.lsp.CompletionItemKind.Text and 100 or kind1
        local kind2 = entry2:get_kind()
        kind2 = kind2 == types.lsp.CompletionItemKind.Text and 100 or kind2
        if kind1 ~= kind2 then
          if kind1 == types.lsp.CompletionItemKind.Snippet then
            return false
          end
          if kind2 == types.lsp.CompletionItemKind.Snippet then
            return true
          end
          local diff = kind1 - kind2
          if diff < 0 then
            return true
          elseif diff > 0 then
            return false
          end
        end
      end,
      cmp.config.compare.sort_text,
      cmp.config.compare.length,
      cmp.config.compare.order,
    },
  },
  documentation = {
    border = "solid",
  },
  mapping = {
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    ["<Up>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        vim.api.nvim_feedkeys(t("<Up>"), "n", true)
      end
    end, { "i" }),
    ["<Down>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        vim.api.nvim_feedkeys(t("<Down>"), "n", true)
      end
    end, { "i" }),

    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
        -- elseif luasnip.expand_or_jumpable() then
        --  luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-Down>"] = cmp.mapping(function(fallback)
      if luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<C-Up>"] = cmp.mapping(function(fallback)
      if luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-q>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  -- LuaFormatter off
  sources = cmp.config.sources({
    -- { name = "copilot", priority = 90 }, -- For luasnip users.
    { name = "nvim_lsp", priority = 100 },
    { name = "cmp_tabnine", priority = 30 },
    { name = "luasnip", priority = 20 }, -- For luasnip users.
    { name = "path", priority = 100 },
    { name = "emoji", insert = true, priority = 60 },
    { name = "nvim_lua", priority = 50 },
    { name = "nvim_lsp_signature_help", priority = 80 },
    { name = "buffer", priority = 50 },
    -- slow
    -- { name = "omni", priority = 40 },
    { name = "spell", priority = 40 },
    { name = "calc", priority = 50 },
    { name = "treesitter", priority = 30 },
    { name = "dictionary", keyword_length = 2, priority = 10 },
  }),
  window = {
    completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
    documentation = {
      cmp.config.window.bordered(),
      border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
      max_height = math.floor(WIDE_HEIGHT * (WIDE_HEIGHT / vim.o.lines)),
      max_width = math.floor((WIDE_HEIGHT * 2) * (vim.o.columns / (WIDE_HEIGHT * 2 * 16 / 9))),
    },
  },
  experimental = {
    ghost_text = false,
    native_menu = false,
  },
  -- LuaFormatter on
})

cmp.setup.filetype({ "gitcommit", "markdown" }, {
  sources = cmp.config.sources({
    -- { name = "copilot", priority = 90 }, -- For luasnip users.
    { name = "nvim_lsp", priority = 100 },
    { name = "cmp_tabnine", priority = 30 },
    { name = "luasnip", priority = 80 }, -- For luasnip users.
    { name = "rg", priority = 70 },
    { name = "path", priority = 100 },
    { name = "emoji", insert = true, priority = 60 },
  }, {
    { name = "buffer", priority = 50 },
    -- { name = "omni", priority = 40 },
    { name = "spell", priority = 40 },
    { name = "calc", priority = 50 },
    { name = "treesitter", priority = 30 },
    { name = "mocword", priority = 60 },
    { name = "dictionary", keyword_length = 2, priority = 10 },
  }),
})

-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline("/", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "nvim_lsp_document_symbol" },
    { name = "path",
      option = {
        get_cwd = function(params)
          ---@diagnostic disable-next-line: missing-parameter
          local dir_name = vim.fn.expand(("#%d:p:h"):format(params.context.bufnr))
          if dir_name == "/tmp" then
            -- body
            return vim.fn.getcwd()
          end
          return dir_name
        end,
      },
    },
    -- { name = "cmdline_history" },
    {
      name = "buffer",
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    },
  }, {}),
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(":", {
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "c" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "c" }),
    ["<C-y>"] = {
      c = cmp.mapping.confirm({ select = false }),
    },
    ["<C-q>"] = {
      c = cmp.mapping.abort(),
    },
  },
  sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" }, { { name = "cmdline_history" } } }),
})

local sign = function(opts)
  vim.fn.sign_define(opts.name, {
    texthl = opts.name,
    text = opts.text,
    numhl = ''
  })
end

sign({name = 'DiagnosticSignError', text = '✘'})
sign({name = 'DiagnosticSignWarn', text = '▲'})
sign({name = 'DiagnosticSignHint', text = '⚑'})
sign({name = 'DiagnosticSignInfo', text = ''})

vim.diagnostic.config({
  virtual_text = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'always',
    header = '',
    prefix = '',
  },
})

-- autopairs
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
local handlers = require('nvim-autopairs.completion.handlers')

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
          ---@param item item completion
          ---@param bufnr buffer number
          handler = function(char, item, bufnr)
            -- Your handler function. Inpect with print(vim.inspect{char, item, bufnr})
          end
        }
      },
      -- Disable for tex
      tex = false
    }
  })
)
