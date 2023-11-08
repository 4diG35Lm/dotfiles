local status, colorful_winsep = pcall(require, "colorful-winsep")
if not status then
  return
end
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

colorful_winsep.setup {
  highlight = {
    bg = "",
    fg = "#E8AEAA"
  },
}
