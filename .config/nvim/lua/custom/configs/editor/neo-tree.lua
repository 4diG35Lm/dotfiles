local status, neo_tree = pcall(require, "neo-tree")
if not status then
  return
end
local fn, _, api = require("custom.core.utils").globals()
local cmd = vim.cmd
local opts = { noremap = true, silent = true }

-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================

local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = vim.tbl_extend("force", options, opts)
  end
  vim.keymap.set(mode, lhs, rhs, options)
end
vim.api.nvim_create_autocmd("TermClose", {
  pattern = "*lazygit",
  callback = function()
    if package.loaded["neo-tree.sources.git_status"] then
      require("neo-tree.sources.git_status").refresh()
    end
  end,
})
-- See ":help neo-tree-highlights" for a list of available highlight groups
cmd [[
  hi link NeoTreeDirectoryName Directory
  hi link NeoTreeDirectoryIcon NeoTreeDirectoryName
]]
local deactivate = function()
  cmd([[Neotree close]])
end
local highlights = require("neo-tree.ui.highlights")
-- If you want icons for diagnostic errors, you'll need to define them somewhere:
fn.sign_define("DiagnosticSignError",
  {text = " ", texthl = "DiagnosticSignError"})
fn.sign_define("DiagnosticSignWarn",
  {text = " ", texthl = "DiagnosticSignWarn"})
fn.sign_define("DiagnosticSignInfo",
  {text = " ", texthl = "DiagnosticSignInfo"})
fn.sign_define("DiagnosticSignHint",
  {text = "󰌵", texthl = "DiagnosticSignHint"})
local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    attach_mappings = function (prompt_bufnr, map)
      local actions = require "telescope.actions"
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local action_state = require "telescope.actions.state"
        local selection = action_state.get_selected_entry()
        local filename = selection.filename
        if (filename == nil) then
          filename = selection[1]
        end
        -- any way to open the file without triggering auto-close event of neo-tree?
        require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
      end)
      return true
    end
  }
end

neo_tree.setup {
  source = {
    "filesystem",
    "buffers",
    "git_status",
    "document_symbols",
    "diagnostics"
  },
  open_files_do_not_replace_types = {
    "terminal",
    "Trouble",
    "qf",
    "Outline"
  },
  add_blank_line_at_top = true, --ツリーの最上部に空白行を追加します。
  auto_clean_after_session_restore = false, --セッションに保存された壊れたネオツリー バッファを自動的にクリーンアップします
  close_if_last_window = true, --それがタブに残された最後のウィンドウである場合、Neo-tree を閉じます
  diagnostics = {
    components = {
      linenr = function(config, node)
        local lnum = tostring(node.extra.diag_struct.lnum + 1)
        local pad = string.rep(" ", 4 - #lnum)
        return {
          {
            text = pad .. lnum,
            highlight = "LineNr",
          },
          {
            text = "▕ ",
            highlight = "NeoTreeDimText",
          }
        }
      end
    },
  },
  disable_netrw = true,
  enable_git_status = true,
  enable_diagnostics = true,
  enable_normal_mode_for_inputs = false, -- Enable normal mode for input dialogs.
  popup_border_style = "NC",
  hijack_netrw = true,
  actions = {
    open_file = {
      quit_on_open = true,
    },
  },
  sort_case_insensitive = false, -- used when sorting files and directories in the tree
  sort_function = nil , -- use a custom function for sorting files and directories in the tree
  -- sort_function = function (a,b)
  --       if a.type == b.type then
  --           return a.path > b.path
  --       else
  --           return a.type > b.type
  --       end
  --   end , -- this sorts files and directories descendantly
  default_component_configs = {
    container = {
      enable_character_fade = true,
    },
    diagnostics = {
      auto_preview = { -- May also be set to `true` or `false`
        enabled = false, -- Whether to automatically enable preview mode
        preview_config = {}, -- Config table to pass to auto preview (for example `{ use_float = true }`)
        event = "neo_tree_buffer_enter", -- The event to enable auto preview upon (for example `"neo_tree_window_after_open"`)
      },
      --bind_to_cwd = true,
      diag_sort_function = "severity", -- "severity" means diagnostic items are sorted by severity in addition to their positions.
                                      -- "position" means diagnostic items are sorted strictly by their positions.
                                      -- May also be a function.
      follow_current_file = { -- May also be set to `true` or `false`
        enabled = true, -- This will find and focus the file in the active buffer every time
        always_focus_file = false, -- Focus the followed file, even when focus is currently on a diagnostic item belonging to that file
        expand_followed = true, -- Ensure the node of the followed file is expanded
        leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        leave_files_open = false, -- `false` closes auto expanded files, such as with `:Neotree reveal`
      },
      group_dirs_and_files = true, -- when true, empty folders and files will be grouped together
      group_empty_dirs = true, -- when true, empty directories will be grouped together
      show_unloaded = true, -- show diagnostics from unloaded buffers
      refresh = {
        delay = 100, -- Time (in ms) to wait before updating diagnostics. Might resolve some issues with Neovim hanging.
        event = "vim_diagnostic_changed", -- Event to use for updating diagnostics (for example `"neo_tree_buffer_enter"`)
                                          -- Set to `false` or `"none"` to disable automatic refreshing
        max_items = 10000, -- The maximum number of diagnostic items to attempt processing
                          -- Set to `false` for no maximum
      },
    },
    indent = {
      indent_size = 2,
      padding = 1, -- extra padding on left hand side
      with_markers = true,
      indent_marker = "│",
      last_indent_marker = "└",
      highlight = "NeoTreeIndentMarker",
      with_expanders = nil, -- if nil and file nesting is enabled, will enable expanders
      expander_collapsed = "",
      expander_expanded = "",
      expander_highlight = "NeoTreeExpander",
    },
    icon = {
      folder_closed = "",
      folder_open = "",
      folder_empty = "ﰊ",
      folder_empty_open = "󰜌",
      default = "*",
      highlight = "NeoTreeFileIcon",
    },
    modified = {
      symbol = "[+]",
      highlight = "NeoTreeModified",
    },
    name = {
      trailing_slash = false,
      use_git_status_colors = true,
    },
    git_status = {
      symbols = {
        -- Change type
        added = "", -- or "✚", but this is redundant info if you use git_status_colors on the name
        modified = "", -- or "", but this is redundant info if you use git_status_colors on the name
        deleted = "✖", -- this can only be used in the git_status source
        renamed = "", -- this can only be used in the git_status source
        -- Status type
        untracked = "",
        ignored = "",
        unstaged = "",
        staged = "",
        conflict = "",
      },
      highlight = "NeoTreeDimText", -- if you remove this the status will be colorful
    },
  },
  nesting_rules = {},
  filesystem = {
    filtered_items = {
      visible = false, -- when true, they will just be displayed differently than normal items
      hide_dotfiles = false,
      hide_gitignored = false,
      hide_by_name = {
        ".DS_Store",
        "thumbs.db",
        "node_modules",
      },
      never_show = { -- remains hidden even if visible is toggled to true
        ".git",
        ".DS_Store",
        "thumbs.db",
        "history",
      },
    },
    follow_current_file = { enable = true }, -- This will find and focus the file in the active buffer every
    -- time the current file is changed while the tree is open.
    use_libuv_file_watcher = true, -- This will use the OS level file watchers
    -- to detect changes instead of relying on nvim autocmd events.
    --hijack_netrw_behavior = "open_current", -- netrw disabled, opening a directory opens neo-tree
    -- in whatever position is specified in window.position
    -- "open_split",  -- netrw disabled, opening a directory opens within the
    -- window like netrw would, regardless of window.position
    -- "disabled",    -- netrw left alone, neo-tree does not handle opening dirs
    window = {
      position = "left",
      width = 30,
      mapping_options = {
        noremap = true,
        nowait = true,
      },
      mappings = {
        ["<space>"] = false,
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["C"] = "close_node",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["H"] = "toggle_hidden",
        ["I"] = "toggle_gitignore",
        ["R"] = "refresh",
        ["/"] = "fuzzy_finder",
        --["/"] = "filter_as_you_type", -- this was the default until v1.28
        --["/"] = "none" -- Assigning a key to "none" will remove the default mapping
        ["f"] = "filter_on_submit",
        ["<c-x>"] = "clear_filter",
        ["a"] = "add",
        ["d"] = "delete",
        ["r"] = "rename",
        ["c"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["m"] = "move", -- takes text input for destination
        ["q"] = "close_window",
        ['o'] = "system_open",
      },
      commands = {
        system_open = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          -- Linux: open file in default application
          vim.fn.jobstart({ "xdg-open", path }, { detach = true })
        end,
        open_and_clear_filter = function (state)
          local node = state.tree:get_node()
          if node and node.type == "file" then
            local file_path = node:get_id()
            -- reuse built-in commands to open and clear filter
            local cmds = require("neo-tree.sources.filesystem.commands")
            cmds.open(state)
            cmds.clear_filter(state)
            -- reveal the selected file without focusing the tree
            require("neo-tree.sources.filesystem").navigate(state, state.path, file_path)
          end
        end,
        run_command = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          api.nvim_input(": " .. path .. "<Home>")
        end,
        telescope_find = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require('telescope.builtin').find_files(getTelescopeOpts(state, path))
        end,
        telescope_grep = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          require('telescope.builtin').live_grep(getTelescopeOpts(state, path))
        end,
      },
    },
    components = {
      harpoon_index = function(config, node, state)
        local Marked = require("harpoon.mark")
        local path = node:get_id()
        local succuss, index = pcall(Marked.get_index_of, path)
        if succuss and index and index > 0 then
          return {
            text = string.format(" ⥤ %d", index), -- <-- Add your favorite harpoon like arrow here
            highlight = config.highlight or "NeoTreeDirectoryIcon",
          }
        else
          return {}
        end
      end,

      icon = function(config, node, state)
        local icon = config.default or " "
        local padding = config.padding or " "
        local highlight = config.highlight or highlights.FILE_ICON

        if node.type == "directory" then
          highlight = highlights.DIRECTORY_ICON
          if node:is_expanded() then
            icon = config.folder_open or "-"
          else
            icon = config.folder_closed or "+"
          end
        elseif node.type == "file" then
          local success, web_devicons = pcall(require, "nvim-web-devicons")
          if success then
            local devicon, hl = web_devicons.get_icon(node.name, node.ext)
            icon = devicon or icon
            highlight = hl or highlight
          end
        end

        return {
          text = icon .. padding,
          highlight = highlight,
        }
      end,
    },
    renderers = {
      file = {
        {"icon"},
        {"name", use_git_status_colors = true},
        {"harpoon_index"}, --> This is what actually adds the component in where you want it
        {"diagnostics"},
        {"git_status", highlight = "NeoTreeDimText"},
      }
    },
  },
  buffers = {
    show_unloaded = true,
    window = {
      position = "left",
      mappings = {
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["<bs>"] = "navigate_up",
        ["."] = "set_root",
        ["R"] = "refresh",
        ["a"] = "add",
        ["d"] = "delete",
        ["r"] = "rename",
        ["c"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["bd"] = "buffer_delete",
        ["o"] = "system_open",
        ['e'] = function() api.nvim_exec('Neotree focus filesystem left', true) end,
        ['b'] = function() api.nvim_exec('Neotree focus buffers left', true) end,
        ['g'] = function() api.nvim_exec('Neotree focus git_status left', true) end,
        ["i"] = "run_command",
        ["tf"] = "telescope_find",
        ["tg"] = "telescope_grep",
        ['D'] = "diff_files",
      },
    },
  },
  git_status = {
    window = {
      position = "float",
      mappings = {
        ["<2-LeftMouse>"] = "open",
        ["<cr>"] = "open",
        ["S"] = "open_split",
        ["s"] = "open_vsplit",
        ["C"] = "close_node",
        ["R"] = "refresh",
        ["d"] = "delete",
        ["r"] = "rename",
        ["c"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["A"] = "git_add_all",
        ["gu"] = "git_unstage_file",
        ["ga"] = "git_add_file",
        ["gr"] = "git_revert_file",
        ["gc"] = "git_commit",
        ["gp"] = "git_push",
        ["gg"] = "git_commit_and_push",
      },
    },
  },
  renderers = {
    directory = {
      { "indent" },
      { "icon" },
      { "current_filter" },
      { "name" },
      { "clipboard" },
      { "diagnostics", errors_only = true },
    },
    file = {
      { "indent" },
      { "icon" },
      {
        "name",
        use_git_status_colors = true,
        zindex = 10,
      },
      { "clipboard" },
      { "bufnr" },
      { "modified" },
      { "diagnostics" },
      { "git_status" },
    },
  },
  source_selector = {
    winbar = true,
    statusline = false,
  },
  events = {
    {
      event = "file_renamed",
      handler = function(args)
        -- fix references to file
        print(args.source, " renamed to ", args.destination)
      end
    },
    {
      event = "file_moved",
      handler = function(args)
        -- fix references to file
        print(args.source, " moved to ", args.destination)
      end
    },
  },
}
map("n", "gx", "<Cmd>Neotree toggle<CR>", opts)
map("n", "G,", "<Cmd>Neotree float git_status git_base=main<CR>", opts)
