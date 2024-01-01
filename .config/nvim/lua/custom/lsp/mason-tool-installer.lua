local status, mason_tool_installer= pcall(require, "mason-tool-installer")
if (not status) then return end

mason_tool_installer.setup {
  ensure_installed = {
    { 'golangci-lint', version = 'v1.47.0' },

    { 'bash-language-server', auto_update = true },

    'lua-language-server',
    'vim-language-server',
    'gopls',
    'stylua',
    'shellcheck',
    'editorconfig-checker',
    'gofumpt',
    'golines',
    'gomodifytags',
    'gotests',
    'impl',
    'json-to-struct',
    'luacheck',
    'misspell',
    'revive',
    'shellcheck',
    'shfmt',
    'staticcheck',
    'vint',
  },
  auto_update = true,
  run_on_start = true,
  start_delay = 3000, -- 3 second delay
  debounce_hours = 5, -- at least 5 hours between attempts to install/update
}
