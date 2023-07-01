local status, lspconfig = pcall(require, "lspconfig")
if not status then
  return
end

local protocol = require "vim.lsp.protocol"
local nlspsettings = require "nlspsettings"
local palette = require("custom.core.utils.palette").nord
local fn, uv, api = require("custom.core.utils").globals()
-- Lsp-config
-------------------------------------------------------------------------------
local lsputil = require "lspconfig.util"
local lsp_signature = require "lsp_signature"
lsp_signature.setup {
  hint_enable = false,
}
local function toggle_lsp_lines()
  local lines_shown = require("lsp_lines").toggle()
  vim.diagnostic.config { signs = not lines_shown }
end
local signature_config = {
  floating_window_off_x = 5, -- adjust float windows x position.
  floating_window_off_y = function() -- adjust float windows y position. e.g. set to -2 can make floating window move up 2 lines
    local linenr = vim.api.nvim_win_get_cursor(0)[1] -- buf line number
    local pumheight = vim.o.pumheight
    local winline = vim.fn.winline() -- line number in the window
    local winheight = vim.fn.winheight(0)

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
-- setup calls to specific language servers are located in ftplugins
function lsputil.on_setup(config)
  config.on_attach = lsputil.add_hook_before(config.on_attach, lsp_mappings)
end

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function lsp_mappings(_, buf)
  local bufopts = { buffer = buf, unpack(opts) }
  map("n", "gd", vim.lsp.buf.definition, bufopts)
  map("n", "gD", vim.lsp.buf.declaration, bufopts)
  map("n", "<leader>gi", vim.lsp.buf.implementation, bufopts)
  map("n", "<leader>gt", vim.lsp.buf.type_definition, bufopts)
  map("n", "K", vim.lsp.buf.hover, bufopts)
  map("n", "<C-k>", vim.lsp.buf.signature_help, bufopts)
  map("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, bufopts)
  map("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, bufopts)
  map("n", "<leader>wl", function()
    vim.pretty_print(vim.lsp.buf.list_workspace_folders())
  end, bufopts)
  map("n", "<leader>rn", vim.lsp.buf.rename, bufopts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, bufopts)
  map("n", "<leader>rf", vim.lsp.buf.references, bufopts)
  map("n", "<leader>fm", vim.lsp.buf.formatting, bufopts)
  map("v", "<leader>fm", ":lua vim.lsp.buf.range_formatting()<cr>", bufopts) -- return to normal mode
end

nlspsettings.setup {
  config_home = vim.fn.stdpath "config" .. "/nlsp-settings",
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

api.create_autocmd("LspAttach", {
  group = api.create_augroup("enable-lualine-lsp", {}),
  once = true,
  callback = function()
    --      require("modules.lualine.lualine").is_lsp_available = true
  end,
})
require("lsp_lines").setup()
-- Use lsp_lines
vim.diagnostic.config {
  virtual_text = {
    format = function(d)
      return ("%s (%s: %s)"):format(d.message, d.source, d.code)
    end,
  },
  virtual_lines = { only_current_line = true },
}
api.create_user_command("ShowLSPSettings", function()
  print(vim.inspect(vim.lsp.get_active_clients()))
end, { desc = "Show LSP settings" })

api.create_user_command("ReloadLSPSettings", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd.edit()
end, { desc = "Reload LSP settings" })
-- api.create_user_autocmd({"CursorHold"}, (
--   pattern = "*",
--   callback = function ()
--     vim.diagnostic.open_float()
--   end
-- ))

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  -- signs = true,
  -- Use lsp_lines instead
  virtual_text = false,
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
-- Reference highlight
vim.cmd [[
set updatetime=500
highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
augroup lsp_document_highlight
  autocmd!
  autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
augroup END
]]

vim.diagnostic.config {
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
local function custom_on_attach(client, bufnr)
  local function buf_set_option(...)
    vim.api.nvim_buf_set_option(bufnr, ...)
  end
  buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end

local global_capabilities = vim.lsp.protocol.make_client_capabilities()
global_capabilities.textDocument.completion.completionItem.snippetSupport = true

lsputil.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
  capabilities = global_capabilities,
})

-- LSPが持つフォーマット機能を無効化する
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities
if ok then
  local orig = vim.lsp.protocol.make_client_capabilities()
  capabilities = cmp_nvim_lsp.default_capabilities(orig)
end
local home_dir = function(p)
  return uv.os_homedir() .. (p or "")
end
-- needed for sumneko_lua
require("neodev").setup {}
vim.opt.completeopt = "menu,menuone,noselect"
require("lspconfig").pyright.setup {}

local function setup(config, opts)
  if not config then
    return
  end

  -- local server_opts0 = server_opts[config.name] and server_opts[config.name]()

  opts = vim.tbl_deep_extend("force", opts or {}, server_opts or {})

  opts.on_attach = custom_on_attach

  -- opts.flags = vim.tbl_deep_extend('keep', opts.flags or {}, {
  --   debounce_text_changes = 200,
  -- })

  --   local has_cmp_lsp, cmp_lsp = pcall(require, 'cmp_nvm_lsp')
  --   i:f has_cmp_lsp then
  --     -- The nvim-cmp almost supports LSP's capabilities so You should advertise it to LSP servers..
  --     opts.capabilities = vim.lsp.protocol.make_client_capabilities()
  --     opts.capabilities = cmp_lsp.update_capabilities(opts.capabilities)
  --   end

  config.setup(opts)
end
