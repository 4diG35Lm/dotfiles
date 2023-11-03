-- "custom.configs.nvim-lsp-installer"
local status, lsp_installer = pcall(require, "nvim-lsp-installer")
if not status then
	return
end
lsp_installer.setup({
	automatic_installation = true, -- automatically detect which servers to install (based on which servers are set up via lspconfig)
	ui = {
		icons = {
			-- installされたserverのicon
			server_installed = "◍",
			-- install待ちserverのicon
			server_pending = "◍",
			-- installしていないserverのicon
			server_uninstalled = "◍",
		},
		keymaps = {
			-- cursorのserverの詳細を表示するkey
			toggle_server_expand = "<CR>",
			-- cursorのserverをinstallするkey
			install_server = "i",
			-- cursorのserverをupdateするkey
			update_server = "u",
			-- cursorのserverをuninstallするkey
			uninstall_server = "x",
		},
	},
})
-- installしているserverのdictを取得します。
local servers = lsp_installer.get_installed_servers()
-- serversの値はServer Classなので `setup` を実行できます。
servers[1]:setup({})

lsp_installer.on_server_ready(function(server)
	local opts = {}

	-- serverに対応しているfiletypeのbufferを開いたら、
	-- 実行するfunctionを設定します。
	-- sumneko_luaはluaのLSP serverなので、
	-- luaのbufferを開いたら、実行するfunctionです。
	opts.on_attach = function(client, buffer_number)
		print(vim.inspect(client))
		print(buffer_number)
	end

	-- LSPのsetupをします。
	-- setupをしないとserverは動作しません。
	server:setup(opts)
end)
local lsp_servers = {
	"sumneko_lua",
	"tsserver",
}
local server_available, requested_server = lsp_installer_servers.get_server(lsp_servers)

-- nvim-lsp-installerに対応していないserverだったら、
-- error messageを表示して終了します。
if not server_available then
	error(string.format("nvim-lsp-installer doesn't support %s server.", name))
	return
end

requested_server:on_ready(function()
	local opts = {}
	-- LSPのsetupをします。
	requested_server:setup(opts)
end)
-- serverがinstallされていない場合、そのserverをinstallします。
if not requested_server:is_installed() then
	requested_server:install()
end

local path = require("nvim-lsp-installer.path")

lsp_installer.settings({
	-- install先のroot directory
	install_root_dir = path.concat({ vim.fn.stdpath("data"), "lsp_servers" }),
	pip = {
		-- `pip install` に渡す引数
		-- 必要ない引数を渡すことは推奨されていません。
		-- 動作に影響を与える可能性が高いからです。
		-- e.g. `{ "--proxy", "https://proxyserver" }`
		install_args = {},
	},
	-- log level
	-- installに問題がありdebugする際、`vim.log.levels.DEBUG` にすると便利です。
	log_level = vim.log.levels.INFO,
	-- 同時にinstallできるserverの最大数
	max_concurrent_installers = 4,
})
