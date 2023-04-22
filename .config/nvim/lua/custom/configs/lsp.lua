local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then return end

local fn, uv, api = require("core.utils").globals()
local fn = vim.fn
local keymap = vim.keymap
local lsp = vim.lsp
local diagnostic = vim.diagnostic
local palette = require "core.utils.palette" "nord"
-- local utils = require('nvim-lsputils')
local system_name

if vim.fn.has("mac") == 1 then
  system_name = "macOS"
elseif vim.fn.has("unix") == 1 then
  system_name = "Linux"
elseif vim.fn.has('win32') == 1 then
  system_name = "Windows"
else
  print("Unsupported system for sumneko")
end

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
})

local signs = { error = "", warn = "", Hint = "", Info = "" }
for type, icon in pairs(signs) do
	local hl = "DiagnosticSign" .. type
	fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "●" })
fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "○" })
fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "■" })
fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "□" })

api.create_autocmd("LspAttach", {
  group = api.create_augroup("enable-lualine-lsp", {}),
  once = true,
  desc = 'LSP actions',
  callback = function()
    require("modules.start.config.lualine").is_lsp_available = true
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end

    -- Displays hover information about the symbol under the cursor
    bufmap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>')

    -- Jump to the definition
    bufmap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>')

    -- Jump to declaration
    bufmap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>')

    -- Lists all the implementations for the symbol under the cursor
    bufmap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>')

    -- Jumps to the definition of the type symbol
    bufmap('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>')

    -- Lists all the references
    bufmap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>')

    -- Displays a function's signature information
    bufmap('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>')

    -- Renames all references to the symbol under the cursor
    bufmap('n', '<F2>', '<cmd>lua vim.lsp.buf.rename()<cr>')

    -- Selects a code action available at the current cursor position
    bufmap('n', '<F4>', '<cmd>lua vim.lsp.buf.code_action()<cr>')
    bufmap('x', '<F4>', '<cmd>lua vim.lsp.buf.range_code_action()<cr>')

    -- Show diagnostics in a floating window
    bufmap('n', 'gl', '<cmd>lua vim.diagnostic.open_float()<cr>')

    -- Move to the previous diagnostic
    bufmap('n', '[d', '<cmd>lua vim.diagnostic.goto_prev()<cr>')

    -- Move to the next diagnostic
    bufmap('n', ']d', '<cmd>lua vim.diagnostic.goto_next()<cr>')
  end,
})

-- Add additional capabilities supported by nvim-cmp
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities
if ok then
  local orig = vim.lsp.protocol.make_client_capabilities()
  capabilities = cmp_nvim_lsp.default_capabilities(orig)
end
local home_dir = function(p)
  return uv.os_homedir() .. (p or "")
end

local protocol = require('vim.lsp.protocol')
local lspconfig = require("lspconfig")
local lsp_defaults = lspconfig.util.default_config
lsp_defaults.capabilities = vim.tbl_deep_extend(
  'force',
  lsp_defaults.capabilities,
  require('cmp_nvim_lsp').default_capabilities()
)

local nlspsettings = require("nlspsettings")
local palette = require "core.utils.palette" "nord"

local completion = require('completion')
local lsp_status = require('lsp-status')
lsp_status.register_progress()
local pyright = require('lspconfig').pyright

local texlab_search_status = vim.tbl_add_reverse_lookup {
  Success = 0,
  Error = 1,
  Failure = 2,
  Unconfigured = 3
}

-- Lsp-config
-------------------------------------------------------------------------------
local lsputil = require('lspconfig.util')

local function map(mode, lhs, rhs, opts)
  local options = { noremap=true, silent=true }
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

local function lsp_mappings(_, buf)
  local bufopts = {buffer = buf, unpack(opts)}
  map("n", "gd",         lsp.buf.definition, bufopts)
  map("n", "gD",         lsp.buf.declaration, bufopts)
  map("n", "<leader>gi", lsp.buf.implementation, bufopts)
  map("n", "<leader>gt", lsp.buf.type_definition, bufopts)
  map("n", "<C-k>",      lsp.buf.signature_help, bufopts)
  map("n", "<leader>wa", lsp.buf.add_workspace_folder, bufopts)
  map("n", "<leader>wr", lsp.buf.remove_workspace_folder, bufopts)
  map("n", "<leader>wl", function() vim.pretty_print(vim.lsp.buf.list_workspace_folders()) end, bufopts)
  map("n", "<leader>rn", lsp.buf.rename, bufopts)
  map("n", "<leader>ca", lsp.buf.code_action, bufopts)
  map("n", "<leader>rf", lsp.buf.references, bufopts)
  map("n", "<leader>fm", lsp.buf.formatting, bufopts)
  map("v", "<leader>fm", ":lua vim.lsp.buf.range_formatting()<cr>", bufopts) -- return to normal mode
end

fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "●" })
fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "○" })
fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "■" })
fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "□" })

require('luasnip.loaders.from_vscode').lazy_load()
require("lsp_lines").setup()
-- Use lsp_lines
diagnostic.config {
  virtual_text = {
    format = function(d)
      return ("%s (%s: %s)"):format(d.message, d.source, d.code)
    end,
  },
  virtual_lines = { only_current_line = true },
  update_in_insert = false,
  underline = true,
}
api.create_user_command("ShowLSPSettings", function()
  print(vim.inspect(vim.lsp.get_active_clients()))
end, { desc = "Show LSP settings" })

api.create_user_command("ReloadLSPSettings", function()
  vim.lsp.stop_client(vim.lsp.get_active_clients())
  vim.cmd.edit()
end, { desc = "Reload LSP settings" })

--vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
--  vim.lsp.handlers.hover,
--  {border = 'rounded'}
--)

--vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
--  vim.lsp.handlers.signature_help,
--  {border = 'rounded'}
--)

-- Taken from https://www.reddit.com/r/neovim/comments/gyb077/nvimlsp_peek_defination_javascript_ttserver/
function preview_location(location, context, before_context)
  -- location may be LocationLink or Location (more useful for the former)
  context = context or 10
  before_context = before_context or 5
  local uri = location.targetUri or location.uri
  if uri == nil then
    return
  end
  local bufnr = vim.uri_to_bufnr(uri)
  if not vim.api.nvim_buf_is_loaded(bufnr) then
    vim.fn.bufload(bufnr)
  end
  local range = location.targetRange or location.range
  local contents =
    vim.api.nvim_buf_get_lines(bufnr, range.start.line - before_context, range["end"].line + 1 + context, false)
  local filetype = vim.api.nvim_buf_get_option(bufnr, "filetype")
  return vim.lsp.util.open_floating_preview(contents, filetype)
end

function preview_location_callback(_, method, result)
  local context = 10
  if result == nil or vim.tbl_isempty(result) then
    print("No location found: " .. method)
    return nil
  end
  if vim.tbl_islist(result) then
    floating_buf, floating_win = preview_location(result[1], context)
  else
    floating_buf, floating_win = preview_location(result, context)
  end
end
local completion_callback = function (client, bufnr)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap = true, silent = true})
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', {noremap = true, silent = true})
  require('completion').on_attach(client)
end

function peek_definition()
  if vim.tbl_contains(vim.api.nvim_list_wins(), floating_win) then
    vim.api.nvim_set_current_win(floating_win)
  else
    local params = vim.lsp.util.make_position_params()
    return vim.lsp.buf_request(0, "textDocument/definition", params, preview_location_callback)
  end
end

local on_attach = function(client, bufnr)
  api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  completion.on_attach({
    sorting = 'alphabet',
    matching_strategy_list = {'exact', 'fuzzy'},
    chain_complete_list = chain_complete_list,
  })
  lsp_status.on_attach(client, bufnr)
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre",  {
      group = vim.api.nvim_create_augroup("Fromat",  {clear = true }),
      buffer =bufnr,
      callback = function() vim.lsp.buf.formatting_seq_sync() end
    })
 end
  local opts = { noremap=true, silent=true }
  api.nvim_create_autocmd("CursorHold", {
    buffer = bufnr,
    callback = function()
      local float_opts = {
        focusable = false,
        close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
        border = "rounded",
        source = "always", -- show source in diagnostic popup window
        prefix = " ",
      }

      if not vim.b.diagnostics_pos then
        vim.b.diagnostics_pos = { nil, nil }
      end

      local cursor_pos = api.nvim_win_get_cursor(0)
      if (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
          and #diagnostic.get() > 0
      then
        diagnostic.open_float(nil, float_opts)
      end

      vim.b.diagnostics_pos = cursor_pos
    end,
  })

  -- The blow command will highlight the current variable and its usages in the buffer.
  if client.server_capabilities.documentHighlightProvider then
    vim.cmd([[
      hi! link LspReferenceRead Visual
      hi! link LspReferenceText Visual
      hi! link LspReferenceWrite Visual
    ]])

    local gid = api.nvim_create_augroup("lsp_document_highlight", { clear = true })

    api.nvim_create_autocmd("CursorMoved" , {
      group = gid,
      buffer = bufnr,
      callback = function ()
        lsp.buf.clear_references()
      end
    })
  end

  if vim.g.logging_level == "debug" then
    local msg = string.format("Language server %s started!", client.name)
    vim.notify(msg, vim.log.levels.DEBUG, { title = "Nvim-config" })
  end
end
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
  allow_incremental_sync = true,
}
local node_root_dir = nvim_lsp.util.root_pattern("package.json", "node_modules")
local buf_name = vim.api.nvim_buf_get_name(0)
local current_buf = vim.api.nvim_get_current_buf()
local is_node_repo = node_root_dir(buf_name, current_buf) ~= nil
local function on_cursor_hold()
  if vim.lsp.buf.server_ready() then
    vim.diagnostic.open_float()
  end
end

local diagnostic_hover_augroup_name = "lspconfig-diagnostic"

local function enable_diagnostics_hover()
  vim.api.nvim_create_augroup(diagnostic_hover_augroup_name, { clear = true })
  vim.api.nvim_create_autocmd({ "CursorHold" }, { group = diagnostic_hover_augroup_name, callback = on_cursor_hold })
end

local function disable_diagnostics_hover()
  vim.api.nvim_clear_autocmds({ group = diagnostic_hover_augroup_name })
end

vim.api.nvim_set_option('updatetime', 500)
enable_diagnostics_hover()

-- diagnosticがある行でホバーをするとすぐにdiagnosticのfloating windowで上書きされてしまうのを阻止する
-- ホバーをしたら一時的にdiagnosticを開くautocmdを無効化する
local function on_hover()
  disable_diagnostics_hover()

  vim.lsp.buf.hover()

  vim.api.nvim_create_augroup("lspconfig-enable-diagnostics-hover", { clear = true })
  -- ウィンドウの切り替えなどのイベントが絡んでくるとおかしくなるかもしれない
  vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, { group = "lspconfig-enable-diagnostics-hover", callback = function()
    vim.api.nvim_clear_autocmds({ group = "lspconfig-enable-diagnostics-hover" })
    enable_diagnostics_hover()
  end })
end

vim.keymap.set('n', '<Leader>lk', on_hover, opt)
-- needed for sumneko_lua
require("neodev").setup {}

local servers = {
  bashls = {},
  clangd = {
    cmd = {
      'clangd', -- '--background-index',
      '--clang-tidy', '--completion-style=bundled', '--header-insertion=iwyu',
      '--suggest-missing-includes', '--cross-file-rename'
    },
    handlers = lsp_status.extensions.clangd.setup(),
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true
    }
  },
  cssls = {
    filetypes = {"css", "scss", "less", "sass"},
    root_dir = lspconfig.util.root_pattern("package.json", ".git")
  },
  ghcide = {
  },
  html = {},
  jsonls = {cmd = {'json-languageserver', '--stdio'}},
  julials = {
    settings = {julia = {format = {indent = 2}}}
  },
  ocamllsp = {},
  -- pyls_ms = {
  --   cmd = {'mspyls'},
  --   handlers = lsp_status.extensions.pyls_ms.setup(),
  --   settings = {
  --     python = {
  --       jediEnabled = false,
  --       analysis = {cachingLevel = 'Library'},
  --       formatting = {provider = 'yapf'},
  --       venvFolders = {"envs", ".pyenv", ".direnv", ".cache/pypoetry/virtualenvs"},
  --       workspaceSymbols = {enabled = true}
  --     }
  --   },
  --   root_dir = function(fname)
  --     return lspconfig.util.root_pattern('pyproject.toml', 'setup.py', 'setup.cfg',
  --     'requirements.txt', 'mypy.ini', '.pylintrc', '.flake8rc',
  --     '.gitignore')(fname) or
  --     lspconfig.util.find_git_ancestor(fname) or vim.loop.os_homedir()
  --   end
  -- },
  -- pyright = {
  --  handlers = {
  --    ['client/registerCapability'] = function(_, _, z, j)
  --      -- print(vim.inspect(y), vim.inspect(z), vim.inspect(j))
  --      return {
  --        result = nil;
  --       error = nil;
  --     }
  --    end
  --  },
  -- settings = {
  --    python = {
  --    formatting = { provider = 'yapf' }
  -- }
  --   },
  -- },
  pylsp = {
    on_attach = on_attach,
    settings = {
      pylsp = {
        plugins = {
          pylint = { enabled = true, executable = "pylint" },
          pyflakes = { enabled = false },
          pycodestyle = { enabled = false },
          jedi_completion = { fuzzy = true },
          pyls_isort = { enabled = true },
          pylsp_mypy = { enabled = true },
        },
      },
    },
    flags = lsp_flags,
    capabilities = capabilities,
  },

  rust_analyzer = {
    on_attach = lsp_status.on_attach,
    capabilities = lsp_status.capabilities,
    settings = {
      ['rust-analyzer'] = {
        cargo = {
          allFeatures = true,
        },
        checkOnSave = {
          allFeatures = true,
          command = 'clippy',
        },
        procMacro = {
          ignored = {
            ['async-trait'] = { 'async_trait' },
            ['napi-derive'] = { 'napi' },
            ['async-recursion'] = { 'async_recursion' },
          },
        },
      },
    },
  },
  sumneko_lua = {
    cmd = {'lua-language-server'},
    settings = {
      Lua = {
        diagnostics = {
          enable = true,
          globals = require("core.utils.lsp").lua_globals,
        },
        format = { enable = false },
        hint = { enable = true },
        -- completion = {keywordSnippet = 'Disable'},
        runtime = {version = 'LuaJIT', path = vim.split(package.path, ';')},
        workspace = {
          library = {
            library = library,
            maxPreload = 2000,
            preloadFileSize = 50000,
            [vim.fn.expand("$VIMRUNTIME/lua")] = true,
            [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
            unpack(api.list_runtime_paths()),
          },
          checkThirdParty = false,
        },
        completion = {
          enable = true,
          showWord = 'Disable',
          callSnippet = "Both",
          -- keywordSnippet = 'Disable',
        },
        -- Do not send telemetry data containing a randomized but unique identifier
         telemetry = {
           enable = false,
         },
      }
    },
    on_new_config = function(config, _)
      config.settings.Lua.workspace.library = api.get_runtime_file("", true)
    end,
  },
  texlab = {
    settings = {
      latex = {forwardSearch = {executable = 'okular', args = {'--unique', 'file:%p#src:%l%f'}}}
    },
    commands = {
      TexlabForwardSearch = {
        function()
          local pos = vim.api.nvim_win_get_cursor(0)
          local params = {
            textDocument = {uri = vim.uri_from_bufnr(0)},
            position = {line = pos[1] - 1, character = pos[2]}
          }

          vim.lsp.buf_request(0, 'textDocument/forwardSearch', params, function(err, _, result, _)
            if err then error(tostring(err)) end
            print('Forward search ' .. vim.inspect(pos) .. ' ' .. texlab_search_status[result])
          end)
        end,
        description = 'Run synctex forward search'
      }
    }
  },
  tsserver = {},
  vimls = {},
  hls = {},
  solargraph = {},
  tailwindcss = {},
  lua_ls = {
    single_file_support = true,
    flags = {
      debounce_text_changes = 150,
    },
  },
}

-- local snippet_capabilities = {
--   textDocument = {
--     completion = {
--       completionItem = {
--         snippetSupport = true
--       }
--     }
--   }
-- }
--   local result = {}
--   local function helper(policy, k, v1, v2)
--     if type(v1) ~= 'table' or type(v2) ~= 'table' then
--       if policy == 'error' then
--         error('Key ' .. vim.inspect(k) .. ' is already present with value ' .. vim.inspect(v1))
--       elseif policy == 'force' then
--         return v2
--       else
--         return v1
--       end
--     else
--       return deep_extend(policy, v1, v2)
--     end
--   end
--
--   for _, t in ipairs({...}) do
--     for k, v in pairs(t) do
--       if result[k] ~= nil then
--         result[k] = helper(policy, k, result[k], v)
--       else
--         result[k] = v
--       end
--     end
--   end
--
--   return result
-- end
--
-- for server, config in ipairs(servers) do
--   config.flag = lsp_flags
--   config.on_attach = on_attach(config)
--   config.capabilities = deep_extend('keep', config.capabilities or {}, lsp_status.capabilities,
--   snippet_capabilities)
--
--   lspconfig[server].setup(config)
-- end
for _, lsp in ipairs(servers) do
  lsp_status.register_progress()
  lsp_status.config({
    kind_labels = vim.g.completion_customize_lsp_label,
    select_symbol = function(cursor_pos, symbol)
      if symbol.valueRange then
        local value_range = {
          ['start'] = {
            character = 0,
            line = vim.fn.byte2line(symbol.valueRange[1])
          },
          ['end'] = {
            character = 0,
            line = vim.fn.byte2line(symbol.valueRange[2])
          }
        }

        return require('lsp-status/util').in_range(cursor_pos, value_range)
      end
    end,
    current_function = false,
    status_symbol = '',
    indicator_errors = 'e',
    indicator_warnings = 'w',
    indicator_info = 'i',
    indicator_hint = 'h',
    indicator_ok = '✔️',
    spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  })
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = lsp_status.capabilities,
    flags = {
      debounce_text_changes = 150,
      allow_incremental_sync = true,
    },
    settings = {
      solargraph = {
        diagnostics = false
      },
    },
    formatting = {
      format_on_save = true, -- enable or disable automatic formatting on save
      timeout_ms = 3200, -- adjust the timeout_ms variable for formatting
      disabled = { "sumneko_lua" },
      filter = function(client)
        -- only enable null-ls for javascript files
        if vim.bo.filetype == "javascript" then
          return client.name == "null-ls"
        end

        -- enable all other clients
        return true
      end,
    },
  }
end
