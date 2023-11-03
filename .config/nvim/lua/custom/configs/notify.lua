-- custom.configs.notify
local status, notify = pcall(require, "notify")
if not status then
	return
end

vim.opt.termguicolors = true
local client_notifs = {}
vim.keymap.set("n", "<BS>", function()
	for _, win in ipairs(vim.api.nvim_list_wins()) do
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.fn.bufexists(buf) == 1 and vim.api.nvim_buf_get_option(buf, "filetype") == "notify" then
			vim.api.nvim_win_close(win, { force = false })
		end
	end
end, { noremap = true, silent = false })

local function get_notif_data(id, token)
	if not client_notifs[id] then
		client_notifs[id] = {}
	end

	if not client_notifs[id][token] then
		client_notifs[id][token] = {}
	end

	return client_notifs[id][token]
end

local SPINNER_FRAMES = { "⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷" }

local function update_spinner(client_id, token)
	local notif_data = get_notif_data(client_id, token)

	if notif_data.spinner then
		notif_data.spinner = (notif_data.spinner + 1) % #SPINNER_FRAMES

		notif_data.notification = vim.notify(nil, nil, {
			hide_from_history = true,
			icon = SPINNER_FRAMES[notif_data.spinner],
			replace = notif_data.notification,
		})

		vim.defer_fn(function()
			update_spinner(client_id, token)
		end, 100)
	end
end

local function format_title(title, client_name)
	return client_name .. (title and #title > 0 and ": " .. title or "")
end

local function format_message(message, percentage)
	return (percentage and percentage .. "%\t" or "") .. (message or "")
end

local ignored = {
	["null-ls"] = true,
	["sumneko_lua"] = true,
}

vim.lsp.handlers["$/progress"] = function(_, result, ctx)
	local client_id = ctx.client_id

	local val = result.value

	local client_name = vim.lsp.get_client_by_id(client_id).name

	if ignored[client_name] then
		return
	end

	if not val or not val.kind then
		return
	end

	local notif_data = get_notif_data(client_id, result.token)

	if val.kind == "begin" then
		local message = format_message(val.message, val.percentage)

		notif_data.notification = vim.notify(message, "info", {
			title = format_title(val.title, client_name),
			icon = SPINNER_FRAMES[1],
			timeout = false,
			hide_from_history = false,
		})

		notif_data.spinner = 1
		update_spinner(client_id, result.token)
	elseif val.kind == "report" and notif_data then
		local message = format_message(val.message, val.percentage)
		notif_data.notification = vim.notify(message, "info", {
			replace = notif_data.notification,
			hide_from_history = false,
		})
	elseif val.kind == "end" and notif_data then
		local message = val.message and format_message(val.message) or "Complete"
		notif_data.notification = vim.notify(message, "info", {
			icon = "",
			replace = notif_data.notification,
			timeout = 200,
		})

		notif_data.spinner = nil
	end
end
local stages_util = require("notify.stages.util")

notify.setup({
	background_colour = "#000000",
	"This is an error messa1ggge.\nSomething went wrong!",
	"error",
})
