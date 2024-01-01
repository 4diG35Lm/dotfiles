local status, lspconfig = pcall(require, "lspconfig")
if not status then
  return
end

local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd
local keymap = vim.keymap
local g = vim.g
local o = vim.o
local opt = vim.opt
local tbl = vim.tbl_deep_extend
local lsp = vim.lsp
local diagnostic = vim.diagnostic
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================

local opts = { noremap = true, silent = true }
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = tbl("force", options, opts)
  end
  keymap.set(mode, lhs, rhs, options)
end
local Lsp
if vim.lsp.status then
  Lsp = vim.lsp.status()
else
  Lsp = vim.lsp.util.get_progress_messages()[1]
end

local nlspsettings = require "nlspsettings"
local palette = require("custom.core.utils.palette").nord
-- LSPが持つフォーマット機能を無効化する
local cmp_nvim_lsp = require "cmp_nvim_lsp"
local orig = lsp.protocol.make_client_capabilities()
local capabilities = cmp_nvim_lsp.default_capabilities(orig)
local signature = require "lsp_signature"
local signature_config = {
  floating_window_off_x = 5, -- adjust float windows x position.
  floating_window_off_y = function() -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
    local linenr = api.nvim_win_get_cursor(0)[1] -- buf line number
    local pumheight = o.pumheight
    local winline = fn.winline() -- line number in the window
    local winheight = fn.winheight(0)

    -- window top
    if winline - 1 < pumheight then
      return pumheight
    end

    -- window bottom
    if winheight - winline < pumheight then
      return -pumheight
    end
    return 0
  end,
}

signature.setup({
  bind = true, -- This is mandatory, otherwise border config won't get registered.
  handler_opts = {
    border = "rounded"
  },
  log_path = fn.expand("$HOME") .. "/tmp/sig.log",
  debug = true,
  hint_enable = false,
  max_width = 80,
  config = signature_config,
})
local lines = require "lsp_lines"
local function toggle_lsp_lines()
  local lines_shown = lines.toggle()
  diagnostic.config { signs = not lines_shown }
end
lines.setup()
-- Use lsp_lines
diagnostic.config {
  virtual_text = {
    format = function(d)
      return ("%s (%s: %s)"):format(d.message, d.source, d.code)
    end,
  },
  virtual_lines = { only_current_line = true },
}
lsp.set_log_level("trace")
lsp.log.set_format_func(vim.inspect)
local lsp_status = require "lsp-status"
-- Register the progress handler
lsp_status.register_progress()
lsp_status.config {
  indicator_errors = 'E',
  indicator_warnings = 'W',
  indicator_info = 'i',
  indicator_hint = '?',
  indicator_ok = 'Ok',
  select_symbol = function(cursor_pos, symbol)
    if symbol.valueRange then
      local value_range = {
        ["start"] = {
          character = 0,
          line = fn.byte2line(symbol.valueRange[1])
        },
        ["end"] = {
          character = 0,
          line = fn.byte2line(symbol.valueRange[2])
        }
      }

      return lsp_status.util.in_range(cursor_pos, value_range)
    end
  end
}
-- Register client for messages and set up buffer autocommands to update
-- the statusline and the current function.
-- NOTE: on_attach is called with the client object, which is the "client" parameter below
local on_attach = function(_, bufnr)
  local function buf_set_option(...)
    api.nvim_buf_set_extmark(bufnr, ...)
  end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  map('n', 'gD', lsp.buf.declaration, opts)
  map('n', 'gd', lsp.buf.definition, opts)
  map('n', 'K', lsp.buf.hover, opts)
  map('n', 'gi', lsp.buf.implementation, opts)
  map('n', '<C-k>', lsp.buf.signature_help, opts)
  map('n', '<space>wa', lsp.buf.add_workspace_folder, opts)
  map('n', '<space>wr', lsp.buf.remove_workspace_folder, opts)
  map('n', '<space>wl', function()
    print(vim.inspect(lsp.buf.list_workspace_folders()))
  end, opts)
  map('n', '<space>D', lsp.buf.type_definition, opts)
  map('n', '<space>rn',lsp.buf.rename, opts)
  map('n', 'gr', lsp.buf.references, opts)
  map('n', '<space>e', vim.diagnostic.open_float, opts)
  map('n', '[d', vim.diagnostic.goto_prev, opts)
  map('n', ']d', vim.diagnostic.goto_next, opts)
  map('n', '<space>q', vim.diagnostic.setloclist, opts)
end
-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
api.nvim_create_autocmd('LspAttach', {
  group = api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    map('n', 'gD', lsp.buf.declaration, opts)
    map('n', 'gd', lsp.buf.definition, opts)
    map('n', 'K', lsp.buf.hover, opts)
    map('n', 'gi', lsp.buf.implementation, opts)
    map('n', '<C-k>', lsp.buf.signature_help, opts)
    map('n', '<space>wa', lsp.buf.add_workspace_folder, opts)
    map('n', '<space>wr', lsp.buf.remove_workspace_folder, opts)
    map('n', '<space>wl', function()
      print(vim.inspect(lsp.buf.list_workspace_folders()))
    end, opts)
    map('n', '<space>D', lsp.buf.type_definition, opts)
    map('n', '<space>rn', lsp.buf.rename, opts)
    map({ 'n', 'v' }, '<space>ca', lsp.buf.code_action, opts)
    map('n', 'gr', lsp.buf.references, opts)
    map('n', '<space>f', function()
      lsp.buf.format { async = true }
    end, opts)
  end,
})
-- Lsp-config
-------------------------------------------------------------------------------
local lsputil = lspconfig.util
lspconfig.efm.setup({
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
  on_attach = on_attach,
  settings = {
    rootMarkers = {
      ".git/",
    },
    languages = {
      lua = {
        {
          formatCommand = "stylua --color Never --config-path ~/.config/.stylua.toml -",
        },
        {
          lintCommand = "luacheck --no-color --quiet --config ~/.config/.luacheckrc -",
          lintFormats = { "%f:%l:%c: %m" },
        },
      },
      python = {
        {
          formatCommand = 'black -',
          formatStdin = true
        },
        {
          formatCommand = 'isort --stdout --profile black -',
          formatStdin = true,
        },
        {
          lintCommand = "flake8 --format efm --stdin-display-name ${INPUT} -",
          lintStdin = true,
          lintIgnoreExitCode = true,
          lintFormats = {
            "%f:%l:%c:%t:%m",
          },
        },
      },
      markdown = {
        { lintIgnoreExitCode = true,
          lintCommand = [[npx textlint -f json ${INPUT} | jq -r '.[] | .filePath as $filePath | .messages[] | "1;\($filePath):\(.line):\(.column):\n2;\(.message | split("\n")[0])\n3;[\(.ruleId)]"']],
          lintFormats = { '%E1;%E%f:%l:%c:', '%C2;%m', '%C3;%m%Z' }
        },
      },
    },
  },
  filetypes = {
    "lua",
    "python",
    "markdown",
  },
})
nlspsettings.setup {
  config_home = fn.stdpath "config" .. "/nlsp-settings",
  local_settings_dir = ".nlsp-settings",
  local_settings_root_markers_fallback = { ".git" },
  append_default_schemas = true,
  loader = "json",
  api.create_autocmd("ColorScheme", {
    group = api.create_augroup("lspconfig-colors", {}),
    pattern = "nord",
    callback = function()
      api.set_hl(0, "DiagnosticError", { fg = palette.red })
      api.set_hl(0, "DiagnosticWarn", { fg = palette.orange })
      api.set_hl(0, "DiagnosticInfo", { fg = palette.bright_cyan })
      api.set_hl(0, "DiagnosticHint", { fg = palette.bright_black })
      api.set_hl(0, "DiagnosticUnderlineError", { sp = palette.red, undercurl = true })
      api.set_hl(0, "DiagnosticUnderlineWarn", { sp = palette.orange, undercurl = true })
      api.set_hl(0, "DiagnosticUnderlineInfo", { sp = palette.bright_cyan, undercurl = true })
      api.set_hl(0, "DiagnosticUnderlineHint", { sp = palette.bright_black, undercurl = true })
      api.set_hl(0, "LspBorderTop", { fg = palette.border, bg = palette.dark_black })
      api.set_hl(0, "LspBorderLeft", { fg = palette.border, bg = palette.black })
      api.set_hl(0, "LspBorderRight", { fg = palette.border, bg = palette.black })
      api.set_hl(0, "LspBorderBottom", { fg = palette.border, bg = palette.dark_black })
    end,
  }),
}

fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "●" })
fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "○" })
fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "■" })
fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "□" })

lsp.handlers["textDocument/publishDiagnostics"] = lsp.with(lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  -- signs = true,
  -- Use lsp_lines instead
  virtual_text = false,
})
lsp.handlers["textDocument/hover"] = lsp.with(lsp.handlers.hover, { border = "single" })
lsp.handlers["textDocument/signatureHelp"] = lsp.with(lsp.handlers.hover, { border = "single" })
-- Reference highlight
cmd [[
set updatetime=500
highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
augroup lsp_document_highlight
  autocmd!
  autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
augroup END
]]

diagnostic.config {
  float = {
    border = "single",
    title = "Diagnostics",
    focusable = false,
    header = {},
    format = function(diag)
      if diag.code then
        return ("[%s](%s): %s"):format(diag.source, diag.code, diag.message)
      else
        return ("[%s]: %s"):format(diag.source, diag.message)
      end
    end,
  },
}
