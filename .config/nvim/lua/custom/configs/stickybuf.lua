local status, stickybuf = pcall(require, "stickybuf")
if (not status) then return end

stickybuf.setup({
  -- This function is run on BufEnter to determine pinning should be activated
  get_auto_pin = function(bufnr)
    -- You can return "bufnr", "buftype", "filetype", or a custom function to set how the window will be pinned
    -- The function below encompasses the default logic. Inspect the source to see what it does.
    return stickybuf.should_auto_pin(bufnr)
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  desc = "Pin the buffer to any window that is fixed width or height",
  callback = function(args)
    local stickybuf = require("stickybuf")
    if not stickybuf.is_pinned() and (vim.wo.winfixwidth or vim.wo.winfixheight) then
      stickybuf.pin()
    end
  end
})
