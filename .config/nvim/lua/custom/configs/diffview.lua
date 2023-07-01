local status, diffview = pcall(require, "diffview")
if not status then
  return
end

local actions = diffview.actions

diffview.setup {
  hooks = {
    diff_buf_read = function(bufnr)
      -- Change local options in diff buffers
      vim.opt_local.wrap = false
      vim.opt_local.list = false
      vim.opt_local.colorcolumn = { 80 }
    end,
    view_opened = function(view)
      print(("A new %s was opened on tab page %d!"):format(view.class:name(), view.tabpage))
    end,
  },
}
vim.api.nvim_set_keymap("n", "[_Git]d", "<Cmd>DiffviewOpen<CR>", { noremap = true, silent = true })
