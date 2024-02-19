local status, telescope = pcall(require, "telescope")
if not status then
  return
end

local fn, _, api = require("custom.core.utils").globals()
local palette = require("custom.core.utils.palette").nord
local cmd = vim.cmd
local keymap = vim.keymap
local g = vim.g
local o = vim.o
local opt = vim.opt
local tbl = vim.tbl_deep_extend
local lsp = vim.lsp
local diagnostic = vim.diagnostic
-----------------------------------------------------------
-- Define keymaps of Neovim and installed plugins.
-----------------------------------------------------------
-- =============================================================================
-- = Keybindings =
-- =============================================================================
g.mapleader = " "
g.maplocalleader = " "

local opts = { noremap = true, silent = true }
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true, silent = true }
  if opts then
    options = tbl("force", options, opts)
  end
  keymap.set(mode, lhs, rhs, options)
end
local Path = require "plenary.path"
local action_layout = require "telescope.actions.layout"
local actions = require "telescope.actions"
local actions_state = require "telescope.actions.state"
local conf = require("telescope.config").values
local config = require "telescope.config"
local finders = require "telescope.finders"
local from_entry = require "telescope.from_entry"
local make_entry = require "telescope.make_entry"
local previewers = require "telescope.previewers"
local telescope_builtin = require "telescope.builtin"
local trouble = require "trouble.providers.telescope"
local utils = require "telescope.utils"

local action_state = require "telescope.actions.state"
local transform_mod = require("telescope.actions.mt").transform_mod
local lazygit = require('telescope').load_extension('lazygit')

api.create_autocmd("ColorScheme", {
  group = api.create_augroup("telescope-colors", {}),
  pattern = "nord",
  callback = function()
    api.set_hl(0, "TelescopeMatching", { fg = palette.magenta })
    api.set_hl(0, "TelescopePreviewBorder", { fg = palette.green })
    api.set_hl(0, "TelescopePromptBorder", { fg = palette.cyan })
    api.set_hl(0, "TelescopeResultsBorder", { fg = palette.blue })
    api.set_hl(0, "TelescopeSelection", { fg = palette.blue })
    api.set_hl(0, "TelescopeSelectionCaret", { fg = palette.blue })
    api.set_hl(0, "TelescopeBufferLoaded", { fg = palette.magenta })
    api.set_hl(0, "TelescopePathSeparator", { fg = palette.brighter_black })
    api.set_hl(0, "TelescopeQueryFilter", { fg = palette.bright_cyan })
  end,
})

local function builtin(name)
  return function(opt)
    return function()
      return require("telescope.builtin")[name](opt or {})
    end
  end
end

local function extensions(name, prop)
  return function(opt)
    return function()
      local telescope = require "telescope"
      telescope.load_extension(name)
      return telescope.extensions[name][prop](opt or {})
    end
  end
end

for k, v in pairs(require "telescope.builtin") do
  if type(v) == "function" then
    vim.keymap.set("n", "<Plug>(telescope." .. k .. ")", v)
  end
end

-- Lines
keymap.set("n", "#", builtin "current_buffer_fuzzy_find" {})

local function input_grep_string(prompt, func)
  return function()
    vim.ui.input({ prompt = prompt }, function(input)
      if input then
        func { only_sort_text = true, search = input }()
      else
        vim.notify "cancelled"
      end
    end)
  end
end

map("n", "<Leader>f:", builtin "command_history" {})
map("n", "<Leader>fG", builtin "grep_string" {})
map("n", "<Leader>fH", builtin "help_tags" { lang = "en" })
map("n", "<Leader>fN", extensions("node_modules", "list") {})
map("n", "<Leader>fg", input_grep_string("Grep For ❯ ", builtin "grep_string"))
map("n", "<Leader>fh", builtin "help_tags" {})
map("n", "<Leader>fm", builtin "man_pages" { sections = { "ALL" } })
map("n", "<Leader>fn", extensions("noice", "noice") {})
map("n", "<Leader>fp", extensions("projects", "projects") {})
map(
  "n",
  "<Leader>fq",
  extensions("ghq", "list") {
    attach_mappings = function(_)
      local actions_set = require "telescope.actions.set"
      actions_set.select:replace(function(_, _)
        local from_entry = require "telescope.from_entry"
        local actions_state = require "telescope.actions.state"
        local entry = actions_state.get_selected_entry()
        local dir = from_entry.path(entry)
        builtin "git_files" { cwd = dir, show_untracked = true }()
      end)
      return true
    end,
  }
)
map("n", "<Leader>fr", builtin "resume" {})

map("n", "<Leader>fy", extensions("yank_history", "yank_history") {})

map("n", "<Leader>fz", function()
  extensions("z", "list") {
    previewer = require("telescope.previewers.term_previewer").new_termopen_previewer {
      get_command = function(entry)
        return { "tree", "-hL", "3", require("telescope.from_entry").path(entry) }
      end,
      scroll_fn = function(self, direction)
        if not self.state then
          return
        end
        local bufnr = self.state.termopen_bufnr
        -- 0x05 -> <C-e>
        -- 0x19 -> <C-y>
        local input = direction > 0 and string.char(0x05) or string.char(0x19)
        local count = math.abs(direction)
        api.win_call(fn.bufwinid(bufnr), function()
          cmd.normal { args = { count .. input }, bang = true }
        end)
      end,
    },
  }()
end)

-- Memo
map("n", "<Leader>mm", extensions("memo", "list") {})
map("n", "<Leader>mg", input_grep_string("Memo Grep For ❯ ", extensions("memo", "grep_string")))

-- Copied from telescope.nvim
map("n", "q:", builtin "command_history" {})
map(
  "c",
  "<A-r>",
  [[<C-\>e ]]
    .. [["lua require'telescope.builtin'.command_history{]]
    .. [[default_text = [=[" . escape(getcmdline(), '"') . "]=]}"<CR><CR>]],
  { silent = true }
)

local run_in_dir = function(name)
  return function()
    local source = require("telescope.builtin")[name]
    local entry = actions_state.get_selected_entry()
    local dir = from_entry.path(entry)
    if fn.isdirectory(dir) then
      source { cwd = dir }
    else
      vim.notify(("This is not a directory: %s"):format(dir), vim.log.levels.ERROR)
    end
  end
end

local preview_scroll = function(direction)
  return function(prompt_bufnr)
    actions.get_current_picker(prompt_bufnr).previewer:scroll_fn(direction)
  end
end

telescope.setup {
  defaults = {
    vimgrep_arguments = {
      "rg",
      "--color=never",
      "--no-heading",
      "--with-filename",
      "--line-number",
      "--column",
      "--smart-case",
    }, --column
  },
  prompt_prefix = "> ",
  selection_caret = "> ",
  entry_prefix = "  ",
  initial_mode = "insert",
  selection_strategy = "reset",
  sorting_strategy = "ascending",
  layout_strategy = "flex",
  layout_config = {
    width = 0.8,
    horizontal = {
      mirror = false,
      prompt_position = "top",
      preview_cutoff = 120,
      preview_width = 0.5,
    },
    vertical = {
      mirror = false,
      prompt_position = "top",
      preview_cutoff = 120,
      preview_width = 0.5,
    },
  },
  file_sorter = require("telescope.sorters").get_fuzzy_file,
  file_ignore_patterns = { "node_modules/*" },
  generic_sorter = require("telescope.sorters").get_generic_fuzzy_sorter,
  dynamic_preview_title = true,
  winblend = 0,
  border = {},
  borderchars = {
    { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    -- prompt = {"─", "│", " ", "│", '┌', '┐', "│", "│"},
    -- results = {"─", "│", "─", "│", "├", "┤", "┘", "└"},
    -- preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└'},
    -- fzf-preview style
    prompt = { "─", "│", " ", "│", "┌", "┬", "│", "│" },
    results = { "─", "│", "─", "│", "├", "┤", "┴", "└" },
    preview = { "─", "│", "─", " ", "─", "┐", "┘", "─" },
  },
  color_devicons = true,
  use_less = true,
  scroll_strategy = "cycle",
  set_env = { ["COLORTERM"] = "truecolor" }, -- default { }, currently unsupported for shells like cmd.exe / powershell.exe
  -- file_previewer = require'telescope.previewers'.cat.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_cat.new`
  -- grep_previewer = require'telescope.previewers'.vimgrep.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_vimgrep.new`
  -- qflist_previewer = require'telescope.previewers'.qflist.new, -- For buffer previewer use `require'telescope.previewers'.vim_buffer_qflist.new`
  -- Developer configurations: Not meant for general override
  buffer_previewer_maker = require("telescope.previewers").buffer_previewer_maker,
  mappings = {
    i = {
      ["<C-a>"] = run_in_dir "find_files",
      ["<C-c>"] = actions.close,
      ["<C-g>"] = run_in_dir "live_grep",
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
      ["<C-s>"] = actions.select_horizontal,
      ["<C-n>"] = actions.cycle_history_next,
      ["<C-p>"] = actions.cycle_history_prev,
      ["<C-d>"] = actions.preview_scrolling_down,
      ["<C-u>"] = actions.preview_scrolling_up,
      ["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
      ["<M-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
    },
    n = {
      ["<Space>"] = actions.toggle_selection,
      ["<C-a>"] = run_in_dir "find_files",
      ["<C-b>"] = actions.results_scrolling_up,
      ["<C-c>"] = actions.close,
      ["<C-f>"] = actions.results_scrolling_down,
      ["<C-g>"] = run_in_dir "live_grep",
      ["<C-j>"] = actions.move_selection_next,
      ["<C-k>"] = actions.move_selection_previous,
      ["<C-s>"] = actions.select_horizontal,
      ["<C-n>"] = actions.select_horizontal,
      ["<C-d>"] = preview_scroll(3),
      ["<C-u>"] = preview_scroll(-3),
      ["<C-l>"] = actions.send_to_loclist + actions.open_loclist,
      ["<M-l>"] = actions.send_selected_to_loclist + actions.open_loclist,
    },
  },
  history = {
    path = Path:new(fn.stdpath "data", "telescope_history.sqlite3").filename,
    limit = 100,
  },
  hijack_netrw = true,
  dir_icon_hl = "Directory",
  icon_width = 2,
  path_display = { "shorten", "smart" },
  respect_gitignore = false,
  fzf = {
    fuzzy = true,
    override_generic_sorter = true,
    override_file_sorter = true,
    case_mode = "smart_case",
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
  },
}
-- This is needed to setup telescope-frecency.
-- in this.
telescope.load_extension "fzf"
-- This is needed to setup telescope-smart-history.
telescope.load_extension "smart_history"
-- This is needed to setup projects.nvim
telescope.load_extension "projects"
-- This is needed to setup noice.nvim
telescope.load_extension "noice"
-- This is needed to setup yanky
telescope.load_extension "yank_history"

-- Set mappings for yanky here to avoid cycle referencing
local utils = require "yanky.utils"
local mapping = require "yanky.telescope.mapping"
local options = require("yanky.config").options
require("yanky.config").setup(options)

yanky = {
  setup = function()
    vim.keymap.set({ "n", "x" }, "p", "<Plug>(YankyPutAfter)")
    vim.keymap.set({ "n", "x" }, "P", "<Plug>(YankyPutBefore)")
    vim.keymap.set({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)")
    vim.keymap.set({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)")
    vim.keymap.set("n", "<A-n>", "<Plug>(YankyCycleForward)")
    vim.keymap.set("n", "<A-p>", "<Plug>(YankyCycleBackward)")
    vim.keymap.set("n", "<A-y>", "<Cmd>YankyRingHistory<CR>")
  end,

  config = function()
    require("yanky").setup {
      ring = { storage = "sqlite" },
    }
  end,
}
