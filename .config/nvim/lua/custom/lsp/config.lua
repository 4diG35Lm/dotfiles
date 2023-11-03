-- custom.lsp.config
local status, lspconfig = pcall(require, "lspconfig")
if not status then
	return
end

local nlspsettings = require("nvim-lspsettings")
local palette = require("custom.core.utils.palette").nord

local keymap = vim.keymap -- for conciseness

local opts = { noremap = true, silent = true }
local on_attach = function(client, bufnr)
  opts.buffer = bufnr
	-- set keybinds
	opts.desc = "Show LSP references"
	keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

	opts.desc = "Go to declaration"
	keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

	opts.desc = "Show LSP definitions"
	keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

	opts.desc = "Show LSP implementations"
	keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

	opts.desc = "Show LSP type definitions"
	keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

	opts.desc = "See available code actions"
	keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- see available code actions, in visual mode will apply to selection

	opts.desc = "Smart rename"
	keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts) -- smart rename

	opts.desc = "Show buffer diagnostics"
	keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

	opts.desc = "Show line diagnostics"
	keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts) -- show diagnostics for line

	opts.desc = "Go to previous diagnostic"
	keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

	opts.desc = "Go to next diagnostic"
	keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

	opts.desc = "Show documentation for what is under cursor"
	keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

	opts.desc = "Restart LSP"
	keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
end 

-- Lsp-config
-------------------------------------------------------------------------------
local lsputil = require("lspconfig.util")

-- LSP handlers
vim.lsp.handlers["textDocument/publishDiagnostics"] =
	vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, { virtual_text = false })
nlspsettings.setup({
	config_home = vim.fn.stdpath("config") .. "/nlsp-settings",
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
})

fn.sign_define("DiagnosticSignError", { texthl = "DiagnosticSignError", text = "●" })
fn.sign_define("DiagnosticSignWarn", { texthl = "DiagnosticSignWarn", text = "○" })
fn.sign_define("DiagnosticSignInfo", { texthl = "DiagnosticSignInfo", text = "■" })
fn.sign_define("DiagnosticSignHint", { texthl = "DiagnosticSignHint", text = "□" })
local group = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd
local prefix = '_mine.'

---------------------------------------------------------------------------------------------------
-- LSP Attach and detach
---------------------------------------------------------------------------------------------------
local lsp = group(prefix .. 'lsppp', { clear = true })

cmd('LspAttach', {
  group = lsp,
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local ft = vim.api.nvim_get_option_value('filetype', { buf = bufnr })
    if client then
      if client.server_capabilities.completionProvider then
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
      end
      if client.server_capabilities.definitionProvider then
        vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
      end
      if ft == 'java' then
        -- Disable semantic tokens for Java
        client.server_capabilities.semanticTokenProvider = nil
        local dap_overrides = require('lsp.setup.java').dap_overrides
        require('jdtls').setup_dap(dap_overrides)
      end
    end
    -- register language specific keymaps
    require('lsp.keymaps').register_keymaps(ft)
    -- enable inlay hints
    if not ft == 'java' then vim.lsp.inlay_hint(bufnr, true) end
  end,
})

cmd('LspDetach', {
  group = lsp,
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then vim.cmd('setlocal tagfunc< omnifunc<') end
  end,
})
require("lsp_lines").setup()
-- Use lsp_lines
vim.diagnostic.config({
	virtual_text = {
		format = function(d)
			return ("%s (%s: %s)"):format(d.message, d.source, d.code)
		end,
	},
	virtual_lines = { only_current_line = true },
})
cmd("ShowLSPSettings", function()
	print(vim.inspect(vim.lsp.get_active_clients()))
end, { desc = "Show LSP settings" })

cmd("ReloadLSPSettings", function()
	vim.lsp.stop_client(vim.lsp.get_active_clients())
	vim.cmd.edit()
end, { desc = "Reload LSP settings" })

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
	underline = true,
	-- signs = true,
	-- Use lsp_lines instead
	virtual_text = false,
})
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.hover, { border = "single" })
-- Reference highlight
vim.cmd([[
set updatetime=500
highlight LspReferenceText  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceRead  cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
highlight LspReferenceWrite cterm=underline ctermfg=1 ctermbg=8 gui=underline guifg=#A00000 guibg=#104040
augroup lsp_document_highlight
  autocmd!
  autocmd CursorHold,CursorHoldI * lua vim.lsp.buf.document_highlight()
  autocmd CursorMoved,CursorMovedI * lua vim.lsp.buf.clear_references()
augroup END
]])

vim.diagnostic.config({
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
})

local global_capabilities = vim.lsp.protocol.make_client_capabilities()
global_capabilities.textDocument.completion.completionItem.snippetSupport = true

lsputil.default_config = vim.tbl_extend("force", lspconfig.util.default_config, {
	capabilities = global_capabilities,
})

-- LSPが持つフォーマット機能を無効化する
local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok then
	local orig = vim.lsp.protocol.make_client_capabilities()
	capabilities = cmp_nvim_lsp.default_capabilities(orig)
end
-- needed for sumneko_lua
require("neodev").setup({})
vim.opt.completeopt = "menu,menuone,noselect"

lspconfig.efm.setup({
	init_options = {
		documentFormatting = true,
		documentRangeFormatting = true,
	},
	settings = {
		rootMarkers = {
			".git/",
		},
		languages = {},
	},
	filetypes = {},
})
-- Change the Diagnostic symbols in the sign column (gutter)
-- (not in youtube nvim video)
local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
end
-- configure html server
lspconfig["html"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure typescript server with plugin
lspconfig["tsserver"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure css server
lspconfig["cssls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure tailwindcss server
lspconfig["tailwindcss"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure svelte server
lspconfig["svelte"].setup({
	capabilities = capabilities,
	on_attach = function(client, bufnr)
		on_attach(client, bufnr)

		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.js", "*.ts" },
			callback = function(ctx)
				if client.name == "svelte" then
					client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
				end
			end,
		})
	end,
})

-- configure prisma orm server
lspconfig["prismals"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure graphql language server
lspconfig["graphql"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
})

-- configure emmet language server
lspconfig["emmet_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
})

-- configure python server
lspconfig["pyright"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
})

-- configure lua server (with special settings)
lspconfig["lua_ls"].setup({
	capabilities = capabilities,
	on_attach = on_attach,
	settings = { -- custom settings for lua
		Lua = {
			-- make the language server recognize "vim" global
			diagnostics = {
				globals = { "vim" },
			},
			workspace = {
				-- make language server aware of runtime files
				library = {
					[vim.fn.expand("$VIMRUNTIME/lua")] = true,
					[vim.fn.stdpath("config") .. "/lua"] = true,
				},
			},
		},
	},
})