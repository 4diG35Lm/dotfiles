local status, mason = pcall(require, "mason")
if not status then
  return
end
local mason_lspconfig = require "mason-lspconfig"
local lsp_status = require "lsp-status"
local lspconfig = require "lspconfig"
local mason_nls = require 'mason-null-ls'
local registry = require("mason-registry")
local mason_tool_installer = require "mason-tool-installer"
mason_tool_installer.run_on_start()
mason_nls.setup({
  ensure_installed = { "stylua", "jq", "pyright", "tsserver" },
  handlers = {
  },
})
mason.setup({
  ui = {
    icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
    },
  }
})
mason_lspconfig.setup {
	ensure_installed = {
    "bashls",
    "clangd",
    "cssls",
    "efm",
    "gopls",
    "html",
    "jsonls",
    "lua_ls",
    "marksman",
    "pylsp",
    "pyright",
    "vimls",
	},
  auto_update = true,
  run_on_start = true,
  start_delay = 3000,
}

-- auto lspconfig setting
mason_lspconfig.setup_handlers {
  function(server_name)
    lspconfig[server_name].setup {}
  end,
}
