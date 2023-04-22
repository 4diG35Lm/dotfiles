local status, mason = pcall(require, "mason")
if not status then
  return
end

local status_ok_1, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok_1 then
  return
end
local status_ok_2, lsp_status = pcall(require, "lsp-status")
if not status_ok_2 then
  return
end
local lspconfig = require "lspconfig"

local servers = {
  bashls = {},
  clangd = {
    cmd = {
      "clangd", -- '--background-index',
      "--clang-tidy",
      "--completion-style=bundled",
      "--header-insertion=iwyu",
      "--suggest-missing-includes",
      "--cross-file-rename",
    },
    handlers = lsp_status.extensions.clangd.setup(),
    init_options = {
      clangdFileStatus = true,
      usePlaceholders = true,
      completeUnimported = true,
      semanticHighlighting = true,
    },
  },
  cssls = {
    filetypes = { "css", "scss", "less", "sass" },
    root_dir = lspconfig.util.root_pattern("package.json", ".git"),
  },
  ghcide = {},
  html = {},
  jsonls = { cmd = { "json-languageserver", "--stdio" } },
  julials = {
    settings = { julia = { format = { indent = 2 } } },
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
  pyright = {
    handlers = {
      ["client/registerCapability"] = function(_, _, z, j)
        -- print(vim.inspect(y), vim.inspect(z), vim.inspect(j))
        return {
          result = nil,
          error = nil,
        }
      end,
    },
    settings = {
      python = {
        formatting = { provider = "yapf" },
      },
    },
  },
  rust_analyzer = {
    settings = {
      ["rust-analyzer"] = {
        cargo = {
          allFeatures = true,
        },
        checkOnSave = {
          allFeatures = true,
          command = "clippy",
        },
        procMacro = {
          ignored = {
            ["async-trait"] = { "async_trait" },
            ["napi-derive"] = { "napi" },
            ["async-recursion"] = { "async_recursion" },
          },
        },
      },
    },
  },
  sumneko_lua = {
    cmd = { "lua-language-server" },
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
        -- completion = {keywordSnippet = 'Disable'},
        runtime = { version = "LuaJIT", path = vim.split(package.path, ";") },
        workspace = {
          library = {
            [vim.fn.expand "$VIMRUNTIME/lua"] = true,
            [vim.fn.expand "$VIMRUNTIME/lua/vim/lsp"] = true,
          },
        },
        completion = {
          enable = true,
          showWord = "Disable",
          -- keywordSnippet = 'Disable',
        },
        -- Do not send telemetry data containing a randomized but unique identifier
        telemetry = {
          enable = false,
        },
      },
    },
  },
  texlab = {
    settings = {
      latex = { forwardSearch = { executable = "okular", args = { "--unique", "file:%p#src:%l%f" } } },
    },
    commands = {
      TexlabForwardSearch = {
        function()
          local pos = vim.api.nvim_win_get_cursor(0)
          local params = {
            textDocument = { uri = vim.uri_from_bufnr(0) },
            position = { line = pos[1] - 1, character = pos[2] },
          }

          vim.lsp.buf_request(0, "textDocument/forwardSearch", params, function(err, _, result, _)
            if err then
              error(tostring(err))
            end
            print("Forward search " .. vim.inspect(pos) .. " " .. texlab_search_status[result])
          end)
        end,
        description = "Run synctex forward search",
      },
    },
  },
  tsserver = {},
  vimls = {},
  hls = {},
  solargraph = {},
}

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").update_capabilities(capabilities)

-- Here we declare which settings to pass to the mason, and also ensure servers are installed. If not, they will be installed automatically.
local settings = {
  ui = {
    check_outdated_packages_on_open = false,
    border = "rounded",
    icons = {
      package_installed = "◍",
      package_pending = "◍",
      package_uninstalled = "◍",
    },
  },
  log_level = vim.log.levels.WARN,
  max_concurrent_installers = 4,
  registries = {
    "lua:mason-registry.index",
  },
  providers = {
    "mason.providers.registry-api",
    "mason.providers.client",
  },
}

mason.setup(settings)
mason_lspconfig.setup_handlers {
  function(server_name)
    local opts = {}
    opts.on_attach = function(_, bufnr)
      local bufopts = { silent = true, buffer = bufnr }
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, bufopts)
      vim.keymap.set("n", "gtD", vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set("n", "grf", vim.lsp.buf.references, bufopts)
      vim.keymap.set("n", "<space>p", vim.lsp.buf.format, bufopts)
    end
    lspconfig[server_name].setup(opts)
  end,
}
mason_lspconfig.setup {
  ensure_installed = servers,
  automatic_installation = true,
}
local mason_package = require "mason-core.package"
