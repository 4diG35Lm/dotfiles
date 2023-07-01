local status, nvim_tree = pcall(require, "nvim-tree")
if not status then
  return
end

-- set termguicolors to enable highlight groups
vim.opt.termguicolors = true
local lib = require "nvim-tree.lib"
local view = require "nvim-tree.view"
local api = require "nvim-tree.api"

local function collapse_all()
  require("nvim-tree.actions.tree-modifiers.collapse-all").fn()
end

local function edit_or_open()
  -- open as vsplit on current node
  local action = "edit"
  local node = lib.get_node_at_cursor()

  -- Just copy what's done normally with vsplit
  if node.link_to and not node.nodes then
    require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
    view.close() -- Close the tree if file was opened
  elseif node.nodes ~= nil then
    lib.expand_or_collapse(node)
  else
    require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
    view.close() -- Close the tree if file was opened
  end
end

local function vsplit_preview()
  -- open as vsplit on current node
  local action = "vsplit"
  local node = lib.get_node_at_cursor()

  -- Just copy what's done normally with vsplit
  if node.link_to and not node.nodes then
    require("nvim-tree.actions.node.open-file").fn(action, node.link_to)
  elseif node.nodes ~= nil then
    lib.expand_or_collapse(node)
  else
    require("nvim-tree.actions.node.open-file").fn(action, node.absolute_path)
  end

  -- Finally refocus on tree if it was lost
  view.focus()
end

local git_add = function()
  local node = lib.get_node_at_cursor()
  local gs = node.git_status.file

  -- If the file is untracked, unstaged or partially staged, we stage it
  if gs == "??" or gs == "MM" or gs == "AM" or gs == " M" then
    vim.cmd("silent !git add " .. node.absolute_path)

  -- If the file is staged, we unstage
  elseif gs == "M " or gs == "A " then
    vim.cmd("silent !git restore --staged " .. node.absolute_path)
  end

  lib.refresh_tree()
end
local function custom_callback(callback_name)
  return string.format(":lua require('treeutils').%s()<CR>", callback_name)
end
local bindings = {
  a = "create",
  d = "remove",
  l = "parent_node",
  L = "dir_up",
  K = "last_sibling",
  J = "first_sibling",
  o = "system_open",
  p = "paste",
  r = "rename",
  R = "refresh",
  t = "next_sibling",
  T = "prev_sibling",
  v = "next_git_item",
  V = "prev_git_item",
  x = "cut",
  yl = "copy_name",
  yp = "copy_path",
  ya = "copy_absolute_path",
  yy = "copy",
  [";"] = "edit",
  ["."] = "toggle_ignored",
  ["h"] = "toggle_help",
  ["<bs>"] = "close_node",
  ["<tab>"] = "preview",
  ["<s-c>"] = "close_node",
  ["<c-r>"] = "full_rename",
  ["<c-t>"] = "tabnew",
  ["<c-x>"] = "split",
}

local function setup_bindings(buf_id)
  local cb = require("nvim-tree.config").nvim_tree_callback
  for key, value in pairs(bindings) do
    vim.api.nvim_buf_set_keymap(buf_id, "n", key, cb(value), { noremap = true, silent = true, nowait = true })
  end
end

-- https://github.com/sindrets/dotfiles/blob/cafb333578a1ad482531ba5091c5171b32525d24/.config/nvim/lua/nvim-config/plugins/nvim-tree.lua#L67-L120
local function custom_setup()
  local buf_id = vim.api.nvim_get_current_buf()
  local ok, custom_setup_done = pcall(vim.api.nvim_buf_get_var, buf_id, "custom_setup_done")

  if ok and custom_setup_done == 1 then
    return
  end

  vim.api.nvim_buf_set_var(buf_id, "custom_setup_done", 1)
  setup_bindings(buf_id)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = { "NvimTree" },
  callback = custom_setup,
})
local function change_root_to_global_cwd()
  local global_cwd = vim.fn.getcwd(-1, -1)
  api.tree.change_root(global_cwd)
end
local hint = [[
 _w_: cd CWD   _c_: Path yank           _/_: Filter
 _y_: Copy     _x_: Cut                 _p_: Paste
 _r_: Rename   _d_: Remove              _n_: New
 _h_: Hidden   _?_: Help
 ^
]]
-- ^ ^           _q_: exit

local nvim_tree_hydra = nil
local nt_au_group = vim.api.nvim_create_augroup("NvimTreeHydraAu", { clear = true })

local Hydra = require "hydra"
local function spawn_nvim_tree_hydra()
  nvim_tree_hydra =
    Hydra {
      name = "NvimTree",
      hint = hint,
      config = {
        color = "pink",
        invoke_on_body = true,
        buffer = 0, -- only for active buffer
        hint = {
          position = "bottom",
          border = "rounded",
        },
      },
      mode = "n",
      body = "H",
      heads = {
        { "w", change_root_to_global_cwd, { silent = true } },
        { "c", api.fs.copy.absolute_path, { silent = true } },
        { "/", api.live_filter.start, { silent = true } },
        { "y", api.fs.copy.node, { silent = true } },
        { "x", api.fs.cut, { exit = true, silent = true } },
        { "p", api.fs.paste, { exit = true, silent = true } },
        { "r", api.fs.rename, { silent = true } },
        { "d", api.fs.remove, { silent = true } },
        { "n", api.fs.create, { silent = true } },
        { "h", api.tree.toggle_hidden_filter, { silent = true } },
        { "?", api.tree.toggle_help, { silent = true } },
        -- { "q", nil, { exit = true, nowait = true } },
      },
    }, nvim_tree_hydra:activate()
end

vim.api.nvim_create_autocmd({ "BufEnter" }, {
  pattern = "*",
  callback = function(opts)
    if vim.bo[opts.buf].filetype == "NvimTree" then
      spawn_nvim_tree_hydra()
    else
      if nvim_tree_hydra then
        nvim_tree_hydra:exit()
      end
    end
  end,
  group = nt_au_group,
})
local function tree_actions_menu(node)
  local entry_maker = function(menu_item)
    return {
      value = menu_item,
      ordinal = menu_item.name,
      display = menu_item.name,
    }
  end

  local finder = require("telescope.finders").new_table {
    results = tree_actions,
    entry_maker = entry_maker,
  }

  local sorter = require("telescope.sorters").get_generic_fuzzy_sorter()

  local default_options = {
    finder = finder,
    sorter = sorter,
    attach_mappings = function(prompt_buffer_number)
      local actions = require "telescope.actions"

      -- On item select
      actions.select_default:replace(function()
        local state = require "telescope.actions.state"
        local selection = state.get_selected_entry()
        -- Closing the picker
        actions.close(prompt_buffer_number)
        -- Executing the callback
        selection.value.handler(node)
      end)

      -- The following actions are disabled in this example
      -- You may want to map them too depending on your needs though
      actions.add_selection:replace(function() end)
      actions.remove_selection:replace(function() end)
      actions.toggle_selection:replace(function() end)
      actions.select_all:replace(function() end)
      actions.drop_all:replace(function() end)
      actions.toggle_all:replace(function() end)

      return true
    end,
  }

  -- Opening the menu
  require("telescope.pickers").new({ prompt_title = "Tree menu" }, default_options):find()
end
local function natural_cmp(left, right)
  left = left.name:lower()
  right = right.name:lower()

  if left == right then
    return false
  end

  for i = 1, math.max(string.len(left), string.len(right)), 1 do
    local l = string.sub(left, i, -1)
    local r = string.sub(right, i, -1)

    if type(tonumber(string.sub(l, 1, 1))) == "number" and type(tonumber(string.sub(r, 1, 1))) == "number" then
      local l_number = tonumber(string.match(l, "^[0-9]+"))
      local r_number = tonumber(string.match(r, "^[0-9]+"))

      if l_number ~= r_number then
        return l_number < r_number
      end
    elseif string.sub(l, 1, 1) ~= string.sub(r, 1, 1) then
      return l < r
    end
  end
end

local config = {
  actions = {
    open_file = {
      quit_on_open = false,
    },
  },
  open_on_setup = not vim.g.started_by_firenvim,
  diagnostics = {
    enable = true,
  },
  disable_netrw = true,
  hijack_netrw = true,
  hijack_cursor = true,
  mappings = {
    custom_only = false,
    list = {
      { key = "l", action = "edit", action_cb = edit_or_open },
      { key = "L", action = "vsplit_preview", action_cb = vsplit_preview },
      { key = "h", action = "close_node" },
      { key = "H", action = "collapse_all", action_cb = collapse_all },
      { key = "<C-C>", action = "global_cwd", action_cb = change_root_to_global_cwd },
      { key = "<C-Space>", action = "tree actions", action_cb = tree_actions_menu },
      { key = "ga", action = "git_add", action_cb = git_add },
    },
  },
  live_filter = {
    prefix = "[FILTER]: ",
    always_show_folders = false, -- Turn into false from true by default
  },
  update_cwd = true,
  update_focused_file = {
    enable = true,
    update_cwd = true,
  },
  renderer = {
    highlight_opened_files = "name",
    group_empty = true,
  },
  view = {
    adaptive_size = true,
    mappings = { custom_only = true },
  },
  filters = {
    custom = { ".git" },
    dotfiles = true,
  },
  sort_by = function(nodes)
    table.sort(nodes, natural_cmp)
  end,
}
api.events.subscribe(api.events.Event.FileCreated, function(file)
  vim.cmd("edit " .. file.fname)
end)
nvim_tree.setup(config)
require("nvim-tree.events").on_file_created(function(ev)
  local fname = ev.fname
  -- makes relevant files executables
  if (fname:match "/%.local/bin/" or fname:match "^%.local/bin/") and not fname:match "%.local/bin/.+%." then
    os.execute(string.format("chmod +x %q", fname))
  end
  -- when new file belongs to an active stow package, stow it
  local dots = os.getenv "DOTFILES"
  if vim.fn.getcwd() == dots then
    local stow_package = fname:match("^(.-)/", #dots + 2)
    if require("utils.std").file_exists(string.format("%s/.config/stow/active/%s", os.getenv "HOME", stow_package)) then
      os.execute(string.format("stow %q", stow_package))
    end
  end
  vim.cmd(string.format("e %s", fname))
  require("templum").template_match()
end)
create_event = function()
  local win_n = require("colorful-winsep.utils").calculate_number_windows()
  if win_n == 2 then
    local win_id = vim.fn.win_getid(vim.fn.winnr "h")
    local filetype = api.nvim_buf_get_option(vim.api.nvim_win_get_buf(win_id), "filetype")
    if filetype == "NvimTree" then
      colorful_winsep.NvimSeparatorDel()
    end
  end
end
