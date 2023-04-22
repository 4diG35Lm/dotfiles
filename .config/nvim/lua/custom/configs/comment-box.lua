local status,  comment_box = pcall(require,  "comment-box")
if (not status) then return end

vim.api.nvim_create_user_command("CommentBoxLeft", 'lua require("comment-box").lbox()', { force = true })
vim.api.nvim_create_user_command("CommentBoxCenter", 'lua require("comment-box").cbox()', { force = true })
