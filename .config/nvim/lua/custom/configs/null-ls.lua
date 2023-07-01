local status, nls = pcall(require, "null-ls")
if not status then
  return
end

local helpers = require "null-ls.helpers"
local command_resolver = require "null-ls.helpers.command_resolver"
--local log = require "null-ls.logger"
local utils = require "null-ls.utils"
local mason_null_ls = require "mason-null-ls"
local function file_exists(fname)
  local stat = vim.loop.fs_stat(vim.fn.expand(fname))
  return (stat and stat.type) or false
end

mason_null_ls.setup {
  ensure_installed = { "prettier" },
  automatic_installation = true,
}

local function is_for_node(to_use)
  return function()
    local has_file = utils.make_conditional_utils().root_has_file {
      ".eslintrc",
      ".eslintrc.json",
      ".eslintrc.yaml",
      ".eslintrc.yml",
      ".prettierrc",
      ".prettierrc.json",
      ".prettierrc.yaml",
      ".prettierrc.yml",
    }
    return to_use and has_file or not has_file
  end
end

local cwd_for_eslint = helpers.cache.by_bufnr(function(params)
  return utils.root_pattern(
    ".eslintrc",
    ".eslintrc.js",
    ".eslintrc.cjs",
    ".eslintrc.yaml",
    ".eslintrc.yml",
    ".eslintrc.json"
  )(params.bufname)
end)
-- highlight whitespace

local ignored_filetypes = {
  "TelescopePrompt",
  "diff",
  "gitcommit",
  "unite",
  "qf",
  "help",
  "markdown",
  "minimap",
  "packer",
  "lazy",
  "dashboard",
  "telescope",
  "lsp-installer",
  "lspinfo",
  "NeogitCommitMessage",
  "NeogitCommitView",
  "NeogitGitCommandHistory",
  "NeogitLogView",
  "NeogitNotification",
  "NeogitPopup",
  "NeogitStatus",
  "NeogitStatusNew",
  "aerial",
  "null-ls-info",
  "mason",
  "noice",
  "notify",
}

local ignored_buftype = {
  "nofile",
}

local groupname = "vimrc_nls"
vim.api.nvim_create_augroup(groupname, { clear = true })
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = groupname,
  pattern = "*",
  callback = function()
    if vim.tbl_contains(ignored_filetypes, vim.bo.filetype) then
      return
    end
    if vim.tbl_contains(ignored_buftype, vim.bo.buftype) then
      return
    end

    vim.fn.matchadd("DiffDelete", "\\v\\s+$")
  end,
  once = false,
})
-- Helper to conditionally register eslint handlers only if eslint is
-- configured. If eslint is not configured for a project, it just fails.
local function has_eslint_configured(utils)
  return utils.root_has_file ".eslintrc.js"
end

local sources = {
  nls.builtins.formatting.stylua,
  -- LuaFormatter off
  nls.builtins.formatting.trim_whitespace.with {
    disabled_filetypes = ignored_filetypes,
    runtime_condition = function()
      local count = tonumber(vim.api.nvim_exec("execute 'silent! %s/\\v\\s+$//gn'", true):match "%w+")
      if count then
        return vim.fn.confirm("Whitespace found, delete it?", "&No\n&Yes", 1, "Question") == 2
      end
    end,
  },
  nls.builtins.formatting.stylua.with {
    condition = function()
      return vim.fn.executable "stylua" > 0
    end,
  },
  nls.builtins.diagnostics.selene.with {
    condition = function()
      return vim.fn.executable "selene" > 0
    end,
  },
  nls.builtins.formatting.black.with {
    condition = function()
      return vim.fn.executable "black" > 0
    end,
  },
  -- rust-analyzer
  -- nls.builtins.formatting.rustfmt,
  nls.builtins.formatting.prettier.with {
    condition = function()
      return vim.fn.executable "prettier" > 0 or vim.fn.executable "./node_modules/.bin/prettier" > 0
    end,
  },
  nls.builtins.diagnostics.eslint.with {
    runtime_condition = is_for_node(true),
    cwd = cwd_for_eslint,
    dynamic_command = find_on_gitdir_at_first,
  },
  nls.builtins.formatting.eslint.with {
    runtime_condition = is_for_node(true),
    cwd = cwd_for_eslint,
    dynamic_command = find_on_gitdir_at_first,
  },
  nls.builtins.formatting.eslint.with {
    runtime_condition = is_for_node(true),
    cwd = cwd_for_eslint,
    dynamic_command = find_on_gitdir_at_first,
  },

  nls.builtins.diagnostics.luacheck.with {
    extra_args = { "--globals", "vim", "--globals", "awesome" },
  },
  nls.builtins.diagnostics.yamllint,
  nls.builtins.formatting.gofmt,
  nls.builtins.formatting.rustfmt,
  nls.builtins.formatting.rubocop.with {
    prefer_local = "bundle_bin",
    condition = function(utils)
      return utils.root_has_file { ".rubocop.yml" }
    end,
  },

  -- nls.builtins.formatting.shfmt.with({
  -- 	condition = function()
  -- 		return vim.fn.executable("shfmt") > 0
  -- 	end,
  -- }),
  nls.builtins.diagnostics.zsh,
  nls.builtins.formatting.beautysh.with {
    extra_args = { "-t" },
    condition = function()
      return vim.fn.executable "beautysh" > 0
    end,
  },
  nls.builtins.diagnostics.shellcheck.with {
    condition = function()
      return vim.fn.executable "shellcheck" > 0
    end,
  },
  nls.builtins.diagnostics.editorconfig_checker.with {
    condition = function()
      return vim.fn.executable "ec" > 0
    end,
  },
  nls.builtins.diagnostics.cspell.with {
    diagnostics_postprocess = function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity["WARN"]
      local formatted = "[#{c}] #{m} (#{s})"
      formatted = formatted:gsub("#{m}", diagnostic.message)
      formatted = formatted:gsub("#{s}", diagnostic.source)
      formatted = formatted:gsub("#{c}", diagnostic.code or "")
      diagnostic.message = formatted
    end,
    condition = function()
      return vim.fn.executable "cspell" > 0
    end,
  },
  nls.builtins.diagnostics.vale.with {
    diagnostics_postprocess = function(diagnostic)
      diagnostic.severity = vim.diagnostic.severity["WARN"]
      local formatted = "[#{c}] #{m} (#{s})"
      formatted = formatted:gsub("#{m}", diagnostic.message)
      formatted = formatted:gsub("#{s}", diagnostic.source)
      formatted = formatted:gsub("#{c}", diagnostic.code or "")
      diagnostic.message = formatted
    end,
    condition = function()
      return vim.fn.executable "vale" > 0 and vim.fn.filereadable ".vale.ini" > 0
    end,
  },
  -- nls.builtins.diagnostics.codespell.with({
  -- 	args = spell_args,
  -- }),
  -- create
  -- occur 'Failed to load textlint's rule module' when rule does not installed
  -- nls.builtins.diagnostics.textlint.with({
  -- 	extra_args = { "--quiet" },
  -- 	condition = function()
  -- 		return vim.fn.executable("textlint") > 0
  -- 	end,
  -- }),
  nls.builtins.formatting.markdownlint.with {
    condition = function()
      return vim.fn.executable "markdownlint" > 0
    end,
  },
  nls.builtins.code_actions.gitsigns,
  nls.builtins.code_actions.eslint.with { condition = has_eslint_configured },
  nls.builtins.diagnostics.eslint.with { condition = has_eslint_configured },
  nls.builtins.formatting.eslint.with { condition = has_eslint_configured },
  nls.builtins.formatting.prettier.with {
    -- Enable conditionally if and only if eslint_d is not enabled.
    -- This can be for either non-project files and for filetypes that
    -- eslintd does not support.
    condition = function()
      local eslintd_enabled = #nls.get_source {
        name = "eslint_d",
        method = nls.methods.FORMATTING,
      }
      return eslintd_enabled == 0
    end,
  },
  nls.builtins.formatting.stylua,
  nls.builtins.formatting.pg_format,
  -- LuaFormatter on
}
if file_exists "./.nvim/local-null-ls.lua" then
  local local_null = dofile "./.nvim/local-null-ls.lua"
  sources = require("rc/utils").merge_lists(sources, local_null)
end

local lsp_formatting = function(bufnr)
  vim.lsp.buf.format {
    -- async = true,
    filter = function(client)
      return client.name ~= "tsserver" and client.name ~= "sumneko_lua"
    end,
    bufnr = bufnr,
  }
end
local augroup = vim.api.nvim_create_augroup("LspFormatting", { clear = true })
local on_attach = function(client, bufnr)
  if client.supports_method "textDocument/formatting" then
    vim.api.nvim_clear_autocmds { group = augroup, buffer = bufnr }
    vim.api.nvim_create_autocmd({ "BufWritePre" }, {
      -- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
      group = augroup,
      buffer = bufnr,
      callback = function()
        lsp_formatting(bufnr)
      end,
    })
  end
end

local no_really = {
  method = nls.methods.DIAGNOSTICS,
  filetypes = { "markdown", "text" },
  generator = {
    fn = function(params)
      local diagnostics = {}
      -- sources have access to a params object
      -- containing info about the current file and editor state
      for i, line in ipairs(params.content) do
        local col, end_col = line:find "really"
        if col and end_col then
          -- null-ls fills in undefined positions
          -- and converts source diagnostics into the required format
          table.insert(diagnostics, {
            row = i,
            col = col,
            end_col = end_col + 1,
            source = "no-really",
            message = "Don't use 'really!'",
            severity = vim.diagnostic.severity.WARN,
          })
        end
      end
      return diagnostics
    end,
  },
}

nls.register(no_really)

local capabilities = vim.lsp.protocol.make_client_capabilities()

nls.setup {
  debug = false,
  debounce = 150,
  save_after_format = false,
  capabilities = capabilities,
  diagnostics_format = "[#{c}] #{m} (#{s})",
  sources = sources,
  on_attach = on_attach,
  root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", ".git"),
}

function has_formatter(ft)
  local sources = require "null-ls.sources"
  local available = sources.get_available(ft, "NULL_LS_FORMATTING")
  return #available > 0
end
