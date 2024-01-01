local status, nui = pcall(require, "nui")
if not status then
  return
end

local Popup = require "nui.popup"
local Layout = require "nui.layout"
local Input = require "nui.input"
local NuiTree = require "nui.tree"
local Split = require("nui.split")
local event = require("nui.utils.autocmd").event
local Timer = Popup:extend("Timer")
local NuiLine = require("nui.line")
local line = NuiLine()

function Timer:init(popup_options)
  local options = vim.tbl_deep_extend("force", popup_options or {}, {
    border = "double",
    focusable = false,
    position = { row = 0, col = "100%" },
    size = { width = 10, height = 1 },
    win_options = {
      winhighlight = "Normal:Normal,FloatBorder:SpecialChar",
    },
  })

  Timer.super.init(self, options)
end

function Timer:countdown(time, step, format)
  local function draw_content(text)
    local gap_width = 10 - vim.api.nvim_strwidth(text)
    vim.api.nvim_buf_set_lines(self.bufnr, 0, -1, false, {
      string.format(
        "%s%s%s",
        string.rep(" ", math.floor(gap_width / 2)),
        text,
        string.rep(" ", math.ceil(gap_width / 2))
      ),
    })
  end

  self:mount()

  local remaining_time = time

  draw_content(format(remaining_time))

  vim.fn.timer_start(step, function()
    remaining_time = remaining_time - step

    draw_content(format(remaining_time))

    if remaining_time <= 0 then
      self:unmount()
    end
  end, { ["repeat"] = math.ceil(remaining_time / step) })
end

local timer = Timer()

timer:countdown(10000, 1000, function(time)
  return tostring(time / 1000) .. "s"
end)

local split = Split({
  relative = "editor",
  position = "bottom",
  size = "20%",
})

-- mount/open the component
split:mount()

-- unmount component when cursor leaves buffer
split:on(event.BufLeave, function()
  split:unmount()
end)

line:append("Something Went Wrong!", "Error")

local bufnr, ns_id, linenr_start = 0, -1, 1

line:render(bufnr, ns_id, linenr_start)
local Popup = require("nui.popup")
local Layout = require("nui.layout")

local popup_one, popup_two = Popup({
  enter = true,
  border = "single",
}), Popup({
  border = "double",
})

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

layout:mount()

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
