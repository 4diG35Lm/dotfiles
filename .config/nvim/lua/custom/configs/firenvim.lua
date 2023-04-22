local status, firenvim = pcall(require, "firenvim")
if (not status) then return end

vim.fn["firenvim#install"](0)

if vim.g.started_by_firenvim then
  vim.g.firenvim_config = {
    localSettings = {
      [".*"] = {
        cmdline = "none",
      },
   },
 }
end
vim.opt.laststatus = 0
vim.api.nvim_create_autocmd("UIEnter", {
  once = true,
  callback = function()
    vim.go.lines = 20
  end,
})
