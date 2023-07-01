local status, nui = pcall(require, "nui")
if not status then
  return
end

local Popup = require "nui.popup"
local Layout = require "nui.layout"
local Input = require "nui.input"
local Split = require "nui.split"
local NuiTree = require "nui.tree"
local NuiLine = require "nui.line"
local event = require("nui.utils.autocmd").event
Popup {
  enter = true,
  focusable = true,
  border = {
    style = "rounded",
    text = {
      top = "[Rename]",
      top_align = "left",
    },
  },
  position = "50%",
  size = {
    width = "80%",
    height = "60%",
  },
  highlight = "Normal:Normal",
  -- place the popup window relative to the
  -- buffer position of the identifier
  relative = {
    type = "buf",
    position = {
      -- this is the same `params` we got earlier
      row = params.position.line,
      col = params.position.character,
    },
  },
}
-- mount/open the component
popup:mount()

-- unmount component when cursor leaves buffer
popup:on(event.BufLeave, function()
  popup:unmount()
end)

-- set content
vim.api.nvim_buf_set_lines(popup.bufnr, 0, 1, false, { "Hello World" })

local popup_one, popup_two = Popup {
  enter = true,
  border = "single",
}, Popup {
  border = "double",
}

local layout = Layout(
  {
    position = "50%",
    size = {
      width = 80,
      height = "60%",
    },
  },
  Layout.Box({
    Layout.Box(popup_one, { size = "40%" }),
    Layout.Box(popup_two, { size = "60%" }),
  }, { dir = "row" })
)

local current_dir = "row"

popup_one:map("n", "r", function()
  if current_dir == "col" then
    layout:update(Layout.Box({
      Layout.Box(popup_one, { size = "40%" }),
      Layout.Box(popup_two, { size = "60%" }),
    }, { dir = "row" }))

    current_dir = "row"
  else
    layout:update(Layout.Box({
      Layout.Box(popup_two, { size = "60%" }),
      Layout.Box(popup_one, { size = "40%" }),
    }, { dir = "col" }))

    current_dir = "col"
  end
end, {})

local input = Input({
  position = "50%",
  size = {
    width = 20,
  },
  border = {
    style = "single",
    text = {
      top = "[Howdy?]",
      top_align = "center",
    },
  },
  win_options = {
    winhighlight = "Normal:Normal,FloatBorder:Normal",
  },
}, {
  prompt = "> ",
  default_value = "Hello",
  on_close = function()
    print "Input Closed!"
  end,
  on_submit = function(value)
    print("Input Submitted: " .. value)
  end,
})

-- mount/open the component
input:mount()

-- unmount component when cursor leaves buffer
input:on(event.BufLeave, function()
  input:unmount()
end)

local split = Split {
  relative = "editor",
  position = "bottom",
  size = "20%",
}

-- mount/open the component
split:mount()

-- unmount component when cursor leaves buffer
split:on(event.BufLeave, function()
  split:unmount()
end)

local tree = NuiTree {
  winid = split.winid,
  nodes = {
    NuiTree.Node { text = "a" },
    NuiTree.Node({ text = "b" }, {
      NuiTree.Node { text = "b-1" },
      NuiTree.Node({ text = "b-2" }, {
        NuiTree.Node { text = "b-1-a" },
        NuiTree.Node { text = "b-2-b" },
      }),
    }),
    NuiTree.Node({ text = "c" }, {
      NuiTree.Node { text = "c-1" },
      NuiTree.Node { text = "c-2" },
    }),
  },
  prepare_node = function(node)
    local line = NuiLine()

    line:append(string.rep("  ", node:get_depth() - 1))

    if node:has_children() then
      line:append(node:is_expanded() and " " or " ", "SpecialChar")
    else
      line:append "  "
    end

    line:append(node.text)

    return line
  end,
}

local map_options = { noremap = true, nowait = true }

-- print current node
split:map("n", "<CR>", function()
  local node = tree:get_node()
  print(vim.inspect(node))
end, map_options)

-- collapse current node
split:map("n", "h", function()
  local node = tree:get_node()

  if node:collapse() then
    tree:render()
  end
end, map_options)

-- collapse all nodes
split:map("n", "H", function()
  local updated = false

  for _, node in pairs(tree.nodes.by_id) do
    updated = node:collapse() or updated
  end

  if updated then
    tree:render()
  end
end, map_options)

-- expand current node
split:map("n", "l", function()
  local node = tree:get_node()

  if node:expand() then
    tree:render()
  end
end, map_options)

-- expand all nodes
split:map("n", "L", function()
  local updated = false

  for _, node in pairs(tree.nodes.by_id) do
    updated = node:expand() or updated
  end

  if updated then
    tree:render()
  end
end, map_options)

-- add new node under current node
split:map("n", "a", function()
  local node = tree:get_node()
  tree:add_node(
    NuiTree.Node({ text = "d" }, {
      NuiTree.Node { text = "d-1" },
    }),
    node:get_id()
  )
  tree:render()
end, map_options)

-- delete current node
split:map("n", "d", function()
  local node = tree:get_node()
  tree:remove_node(node:get_id())
  tree:render()
end, map_options)

tree:render()
