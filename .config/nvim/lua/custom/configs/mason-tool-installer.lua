-- custom.configs.mason-tool-installer
local status, mason_tool_installer = pcall(require, "mason-tool-installer")
if not status then
	return
end

mason_tool_installer.setup({
	-- a list of all tools you want to ensure are installed upon
	-- start; they should be the names Mason uses for each tool
	ensure_installed = {

		-- you can pin a tool to a particular version
		{ "golangci-lint", version = "v1.47.0" },

		-- you can turn off/on auto_update per tool
		{ "bash-language-server", auto_update = true },

		"lua-language-server",
		"vim-language-server",
		"gopls",
		"stylua",
		"shellcheck",
		"editorconfig-checker",
		"gofumpt",
		"golines",
		"gomodifytags",
		"gotests",
		"impl",
		"json-to-struct",
		"luacheck",
		"misspell",
		"revive",
		"shellcheck",
		"shfmt",
		"staticcheck",
		"vint",
	},

	auto_update = false,
	run_on_start = true,
	start_delay = 3000, -- 3 second delay
	debounce_hours = 5, -- at least 5 hours between attempts to install/update
})

vim.api.nvim_create_autocmd("User", {
	pattern = "MasonToolsStartingInstall",
	callback = function()
		vim.schedule(function()
			print("mason-tool-installer is starting")
		end)
	end,
})
vim.api.nvim_create_autocmd("User", {
	pattern = "MasonToolsUpdateCompleted",
	callback = function(e)
		vim.schedule(function()
			print(vim.inspect(e.data)) -- print the table that lists the programs that were installed
		end)
	end,
})
