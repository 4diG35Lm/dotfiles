local status,  conform = pcall(require,  "conform")
if (not status) then return end

conform.setup({
  formatters_by_ft = {
    lua = { "stylua" },
    python = { "isort", "black" },
    javascript = { { "prettierd", "prettier" } },
    go = { "gofmt", "goimports" },
    typescript = { { "prettierd", "prettier" } },
    rust = { "rustfmt" },
    nix = { "nixfmt" },
  },
  format_on_save = {
    timeout_ms = 5000,
    lsp_fallback = true,
  },
  formatters = {
    injected = { options = { ignore_errors = true } },
  },
  init = function()
    vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
  end,
})
