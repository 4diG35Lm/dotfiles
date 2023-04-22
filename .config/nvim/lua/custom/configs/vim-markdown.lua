local status, vim_markdown = pcall(require, "vim-markdown")
if (not status) then return end

vim.g.vim_markdown_new_list_item_indent = 2
