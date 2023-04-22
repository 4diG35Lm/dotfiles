local windows = require("toolwindow")
local function open_fn(plugin, args)
    _ = args
    plugin:open()
end

local function close_fn(plugin)
    plugin:close()
end

-- params: name, plugin, function to close window, function to open window
windows.register("term", Terminal:new({hidden = true}), close_fn, open_fn)
local function cowsay_open(plugin, args)
    _ = args
    if plugin == nil then
      plugin = Terminal:new({
          cmd = "fortune | cowsay",
          hidden = true,
          on_exit = function(job, data, name)
              _, _, _ = job, data, name
              vim.cmd("echo finished cowsay")
          end,
      })
    end
    plugin:open()
    return plugin
end

local function cowsay_close(plugin)
    if plugin:is_open() then
        plugin:close()
    end
end

-- Plugin is nil here as the terminal will be created on each open
windows.register("cowsay", nil, cowsay_close, cowsay_open)
vim.keymap.set("n", "[_Lsp]bc", "<Cmd>lua require('toolwindow').close()<CR>", { noremap = true, silent = true })
vim.keymap.set(
	"n",
	"[_Lsp]bt",
	"<Cmd>lua require('toolwindow').open_window('quickfix', nil)<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"[_Lsp]bt",
	"<Cmd>lua require('toolwindow').open_window('term', nil)<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"[_Lsp]bd",
	"<Cmd>lua require('toolwindow').open_window('trouble', nil)<CR>",
	{ noremap = true, silent = true }
)
vim.keymap.set(
	"n",
	"[_Lsp]bn",
	"<Cmd>lua require('toolwindow').open_window('todo', nil)<CR>",
	{ noremap = true, silent = true }
)
