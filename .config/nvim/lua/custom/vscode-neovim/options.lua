local status, nvim_surround = pcall(require, "nvim-surround")
if not status then
  return
end

if not vim.g.vscode then
  vim.opt.number = true
  vim.opt.shiftwidth = 2
  vim.opt.scrolloff = 6
  vim.opt.list = true
  vim.opt.listchars = { tab = ">-", trail = "-" }
  vim.opt.cursorline = true
  vim.opt.completeopt = "menuone"
  vim.opt.termguicolors = true
end
