-- custom.config.nvim-lint
local status, lint = pcall(require, "nvim-lint")
if not status then
  return
end

lint.linters_by_ft = {
  javascript = { "eslint_d", "cspell" },
  typescript = { "eslint_d", "cspell" },
  javascriptreact = { "eslint_d", "cspell" },
  typescriptreact = { "eslint_d", "cspell" },
  jsx = { "eslint_d", "cspell" },
  tsx = { "eslint_d", "cspell" },
  svelte = { "eslint_d", "cspell" },
  json = { "eslint_d", "cspell" },
  markdown = { "markdownlint", "cspell" },
  sh = { "shellcheck", "cspell" },
  sql = { "sqlfluff", "cspell" },
  yaml = { "eslint_d", "cspell" },
  lua = { "cspell" },
}
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end,
})

vim.keymap.set("n", "<leader>l", function()
  lint.try_lint()
end, { desc = "Trigger linting for current file" })
