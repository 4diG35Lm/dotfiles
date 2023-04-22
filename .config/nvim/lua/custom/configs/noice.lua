local status, noice = pcall(require, "noice")
if not status then
  return
end

local function myMiniView(pattern, kind)
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

local focused = true
vim.api.nvim_create_autocmd("FocusGained", {
  callback = function()
    focused = true
  end,
})
vim.api.nvim_create_autocmd("FocusLost", {
  callback = function()
    focused = false
  end,
})
noice.setup {
  cmdline = {
    enabled = true, -- enables the Noice cmdline UI
    view = "cmdline_popup", -- view for rendering the cmdline. Change to `cmdline` to get a classic cmdline at the bottom
    format = {
      -- conceal: (default=true) This will hide the text in the cmdline that matches the pattern.
      -- view: (default is cmdline view)
      -- opts: any options passed to the view
      -- icon_hl_group: optional hl_group for the icon
      -- title: set to anything or empty string to hide
      cmdline = { pattern = "^:", icon = "", lang = "vim" },
      search_down = { kind = "search", pattern = "^/", icon = " ", lang = "regex" },
      search_up = { kind = "search", pattern = "^%?", icon = " ", lang = "regex" },
      filter = { pattern = "^:%s*!", icon = "$", lang = "bash" },
      lua = { pattern = { "^:%s*lua%s+", "^:%s*lua%s*=%s*", "^:%s*=%s*" }, icon = "", lang = "lua" },
      help = { pattern = "^:%s*he?l?p?%s+", icon = "" },
      input = {}, -- Used by input()
    },
  },
  debug = false,
  messages = {
    view = "mini",
    view_search = "notify",
    view_error = "notify",
    view_warn = "mini",
  },
  popupmenu = {
    backend = "cmp", -- backend to use to show regular cmdline completions
    relative = "editor",
    position = {
      row = 8,
      col = "50%",
    },
    size = {
      width = 60,
      height = 10,
    },
    border = {
      style = "rounded",
      padding = { 0, 1 },
    },
    win_options = {
      winhighlight = { Normal = "Normal", FloatBorder = "DiagnosticInfo" },
    },
  },
  redirect = {
    view = "popup",
    filter = { event = "msg_show" },
  },
  notify = {
    enabled = true,
    view = "notify",
  },
  lsp = {
    progress = {
      enabled = false,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000 / 30, -- frequency to update lsp progress message
      view = "mini",
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
    signature = {
      enabled = true,
      auto_open = {
        enabled = true,
        trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
        luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
        throttle = 50, -- Debounce lsp signature help request by 50ms
      },
      view = nil, -- when nil, use defaults from documentation
    },
    hover = {
      enabled = true,
      view = nil, -- when nil, use defaults from documentation
    },
  },
  routes = {
    {
      view = "mini",
      opts = { stop = false },
      filter = {
        cond = function()
          return not focused
        end,
        event = "notify",
        warning = true,
        find = "failed to run generator.*is not executable",
      },
    },
    {
      filter = {
        event = "notify",
        warning = true,
        find = "failed to run generator.*is not executable",
      },
      opts = { skip = true },
    },
    myMiniView "Already at .* change",
    myMiniView "written",
    myMiniView "yanked",
    myMiniView "more lines?",
    myMiniView "fewer lines?",
    myMiniView("fewer lines?", "lua_error"),
    myMiniView "change; before",
    myMiniView "change; after",
    myMiniView "line less",
    myMiniView "lines indented",
    myMiniView "No lines in buffer",
    myMiniView("search hit .*, continuing at", "wmsg"),
    myMiniView("E486: Pattern not found", "emsg"),
    myMiniView "Error executing vim.schedule lua callback: vim/shared.lua:0",
    myMiniView "Error detected while processing InsertEnter Autocommands",
  },
  health = {
    checker = true, -- Disable if you don't want health checks to run
  },
  smart_move = {
    -- noice tries to move out of the way of existing floating windows.
    enabled = true, -- you can disable this behaviour here
    -- add any filetypes here, that shouldn't trigger smart move.
    excluded_filetypes = { "cmp_menu", "cmp_docs", "notify" },
  },
  presets = {
    bottom_search = true,
    command_palette = true,
    long_message_to_split = true,
    inc_rename = true,
    cmdline_output_to_split = false,
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  commands = {
    all = {
      -- options for the message history that you get with `:Noice`
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {},
    },
    history = {
      -- options for the message history that you get with `:Noice`
      view = "split",
      opts = { enter = true, format = "details" },
      filter = {
        any = {
          { event = "notify" },
          { error = true },
          { warning = true },
          { event = "msg_show", kind = { "" } },
          { event = "lsp", kind = "message" },
        },
      },
    },
  },
  -- :Noice last
  last = {
    view = "popup",
    opts = { enter = true, format = "details" },
    filter = {
      any = {
        { event = "notify" },
        { error = true },
        { warning = true },
        { event = "msg_show", kind = { "" } },
        { event = "lsp", kind = "message" },
      },
    },
    filter_opts = { count = 1 },
  },
  -- :Noice errors
  errors = {
    -- options for the message history that you get with `:Noice`
    view = "popup",
    opts = { enter = true, format = "details" },
    filter = { error = true },
    filter_opts = { reverse = true },
  },
  sections = {
    lualine_x = {
      {
        noice.api.statusline.mode.get,
        cond = noice.api.statusline.mode.has,
        color = { fg = "#ff9e64" },
      },
    },
  },
  win_options = {
    cursorline = true,
    cursorlineopt = "line",
    winhighlight = {
      Normal = "NoicePopupmenu", -- change to NormalFloat to make it look like other floats
      FloatBorder = "NoicePopupmenuBorder", -- border highlight
      CursorLine = "NoicePopupmenuSelected", -- used for highlighting the selected item
      PmenuMatch = "NoicePopupmenuMatch", -- used to highlight the part of the item that matches the input
    },
  },
  throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
  views = {
    split = {
      enter = true,
    },
  },
}

-- vim.keymap.set("c", "<S-Enter>", function()
-- require("noice").redirect(vim.fn.getcmdline())
--end, { desc = "Redirect Cmdline" })

vim.keymap.set("n", "<leader>nl", function()
  noice.cmd "last"
end, { desc = "Noice Last Message" })

vim.keymap.set("n", "<leader>nh", function()
  noice.cmd "history"
end, { desc = "Noice History" })

vim.keymap.set("n", "<leader>na", function()
  noice.cmd "all"
end, { desc = "Noice All" })

vim.keymap.set("n", "<c-f>", function()
  if not noice.lsp.scroll(4) then
    return "<c-f>"
  end
end, { silent = true, expr = true })

vim.keymap.set("n", "<c-b>", function()
  if not noice.lsp.scroll(-4) then
    return "<c-b>"
  end
end, { silent = true, expr = true })

-- redirect ":hi"
noice.redirect "hi"

-- redirect some function
noice.redirect(function()
  print "test"
end)
