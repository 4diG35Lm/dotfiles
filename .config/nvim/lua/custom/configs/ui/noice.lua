local status, noice = pcall(require, "noice")
if not status then
  return
end
local fn, _, api = require("custom.core.utils").globals()
local utils = require("noice.util")
local cfg = require("noice.config")
 vim.diagnostic.config({
     update_in_insert = false
  })
local function customMiniView(pattern, kind)
	kind = kind or ""
	return {
		view = "mini",
		filter = {
			event = "msg_show",
			kind = kind,
			find = pattern,
		},
	}
end
local function get_options(view)
  if not view then
    utils.panic("View is missing?")
  end

  local opts = { view = view }

  local done = {}
  while opts.view and not done[opts.view] do
    done[opts.view] = true

    local view_opts = vim.deepcopy(cfg.options.views[opts.view] or {})
    opts = vim.tbl_deep_extend("keep", opts, view_opts)
    opts.view = view_opts.view
  end

  return opts
end
noice.setup({
  cmdline = {
    format = {
      cmdline = { icon = ">" },
      search_down = { icon = "🔍⌄" },
      search_up = { icon = "🔍⌃" },
      filter = { icon = "$" },
      lua = { icon = "☾" },
      help = { icon = "?" },
    },
  },
  default = { "{level} ", "{title} ", "{message}" },
  details = {
    "{level} ",
    "{date} ",
    "{event}",
    { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
    " ",
    "{title} ",
    "{cmdline} ",
    "{message}",
  },
  format = {
    level = {
      icons = {
        error = "✖",
        warn = "▼",
        info = "●",
      },
    },
  },
  popupmenu = {
    kind_icons = false,
    relative = "editor",
    zindex = 65,
    position = "auto", -- when auto, then it will be positioned to the cmdline or cursor
    size = {
      width = "auto",
      height = "auto",
      max_height = 20,
      -- min_width = 10,
    },
    win_options = {
      winbar = "",
      foldenable = false,
      cursorline = true,
      cursorlineopt = "line",
      winhighlight = {
        Normal = "NoicePopupmenu", -- change to NormalFloat to make it look like other floats
        FloatBorder = "NoicePopupmenuBorder", -- border highlight
        CursorLine = "NoicePopupmenuSelected", -- used for highlighting the selected item
        PmenuMatch = "NoicePopupmenuMatch", -- used to highlight the part of the item that matches the input
      },
    },
    border = {
      padding = { 0, 1 },
    },
  },
  inc_rename = {
    cmdline = {
      format = {
        IncRename = { icon = "⟳" },
      },
    },
  },
  cmdline_popupmenu = {
    view = "popupmenu",
    zindex = 200,
  },
  virtualtext = {
    backend = "virtualtext",
    format = { "{message}" },
    hl_group = "NoiceVirtualText",
  },
  notify = {
    backend = "notify",
    fallback = "mini",
    format = "notify",
    replace = false,
    merge = false,
  },
  split = {
    backend = "split",
    enter = false,
    relative = "editor",
    position = "bottom",
    size = "20%",
    close = {
      keys = { "q" },
    },
    win_options = {
      winhighlight = { Normal = "NoiceSplit", FloatBorder = "NoiceSplitBorder" },
      wrap = true,
    },
  },
  cmdline_output = {
    format = "details",
    view = "split",
  },
  messages = {
    view_search = "mini",
    view = "split",
    enter = true,
  },
  routes = {
		{
			filter = {
				event = "notify",
				warning = true,
				find = "failed to run generator.*is not executable",
        min_height = 15
			},
      view = 'split',
			opts = { skip = true },
		},
    customMiniView("Already at .* change"),
		customMiniView("written"),
		customMiniView("yanked"),
		customMiniView("more lines?"),
		customMiniView("fewer lines?"),
		customMiniView("fewer lines?", "lua_error"),
		customMiniView("change; before"),
		customMiniView("change; after"),
		customMiniView("line less"),
		customMiniView("lines indented"),
		customMiniView("No lines in buffer"),
		customMiniView("search hit .*, continuing at", "wmsg"),
		customMiniView("E486: Pattern not found", "emsg"),
	},
  vsplit = {
    view = "split",
    position = "right",
  },
  lsp = {
    progress = { enabled = false },
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  telescope = {
    "{level} ",
    "{date} ",
    "{title} ",
    "{message}",
  },
  telescope_preview = {
    "{level} ",
    "{date} ",
    "{event}",
    { "{kind}", before = { ".", hl_group = "NoiceFormatKind" } },
    "\n",
    "{title}\n",
    "\n",
    "{message}",
  },
  lsp_progress = {
    {
      "{progress} ",
      key = "progress.percentage",
      contents = {
        { "{data.progress.message} " },
      },
    },
    "({data.progress.percentage}%) ",
    { "{spinner} ", hl_group = "NoiceLspProgressSpinner" },
    { "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
    { "{data.progress.client} ", hl_group = "NoiceLspProgressClient" },
  },
  lsp_progress_done = {
    { "✔ ", hl_group = "NoiceLspProgressSpinner" },
    { "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
    { "{data.progress.client} ", hl_group = "NoiceLspProgressClient" },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  popup = {
    backend = "popup",
    relative = "editor",
    close = {
      events = { "BufLeave" },
      keys = { "q" },
    },
    enter = true,
    border = {
      style = "rounded",
    },
    position = "50%",
    size = {
      width = "120",
      height = "20",
    },
    win_options = {
      winhighlight = { Normal = "NoicePopup", FloatBorder = "NoicePopupBorder" },
      winbar = "",
      foldenable = false,
    },
  },
  hover = {
    view = "popup",
    relative = "cursor",
    zindex = 45,
    enter = false,
    anchor = "auto",
    size = {
      width = "auto",
      height = "auto",
      max_height = 20,
      max_width = 120,
    },
    border = {
      style = "none",
      padding = { 0, 2 },
    },
    position = { row = 1, col = 0 },
    win_options = {
      wrap = true,
      linebreak = true,
    },
  },
  mini = {
    backend = "mini",
    relative = "editor",
    align = "message-right",
    timeout = 2000,
    reverse = true,
    focusable = false,
    position = {
      row = -1,
      col = "100%",
      -- col = 0,
    },
    size = "auto",
    border = {
      style = "none",
    },
    zindex = 60,
    win_options = {
      winbar = "",
      foldenable = false,
      winblend = 30,
      winhighlight = {
        Normal = "NoiceMini",
        IncSearch = "",
        CurSearch = "",
        Search = "",
      },
    },
  },
  cmdline_popup = {
    backend = "popup",
    relative = "editor",
    focusable = false,
    enter = false,
    zindex = 200,
    position = {
      row = "50%",
      col = "50%",
    },
    size = {
      min_width = 60,
      width = "auto",
      height = "auto",
    },
    border = {
      style = "rounded",
      padding = { 0, 1 },
    },
    win_options = {
      winhighlight = {
        Normal = "NoiceCmdlinePopup",
        FloatTitle = "NoiceCmdlinePopupTitle",
        FloatBorder = "NoiceCmdlinePopupBorder",
        IncSearch = "",
        CurSearch = "",
        Search = "",
      },
      winbar = "",
      foldenable = false,
      cursorline = false,
    },
  },
  confirm = {
    backend = "popup",
    relative = "editor",
    focusable = false,
    align = "center",
    enter = false,
    zindex = 210,
    format = { "{confirm}" },
    position = {
      row = "50%",
      col = "50%",
    },
    size = "auto",
    border = {
      style = "rounded",
      padding = { 0, 1 },
      text = {
        top = " Confirm ",
      },
    },
    win_options = {
      winhighlight = {
        Normal = "NoiceConfirm",
        FloatBorder = "NoiceConfirmBorder",
      },
      winbar = "",
      foldenable = false,
    },
  },
})
