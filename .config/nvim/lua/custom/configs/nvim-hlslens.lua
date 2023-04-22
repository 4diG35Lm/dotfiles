local status, hlslens = pcall(require, "hlslens")
if (not status) then return end

hlslens.setup({
  calm_down = true,
  nearest_only = true,
  nearest_float_when = 'always',
  build_position_cb = function(plist, _, _, _)
    require("scrollbar.handlers.search").handler.show(plist.start_pos)
  end,
})

vim.cmd([[
  augroup scrollbar_search_hide
    autocmd!
    autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
  augroup END
]])

local kopts = {noremap = true, silent = true}

vim.api.nvim_set_keymap('n', 'n',
   [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
   kopts)
vim.api.nvim_set_keymap('n', 'N',
   [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
   kopts)
vim.api.nvim_set_keymap('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
vim.api.nvim_set_keymap('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)

vim.api.nvim_set_keymap('n', '<Leader>l', '<Cmd>noh<CR>', kopts)

vim.keymap.set("n", "n", function() pcall(vim.cmd, "normal! " .. vim.v.count1 .. "n") require("hlslens").start() end, { noremap = true, silent = true })
vim.keymap.set("n", "N", function() pcall(vim.cmd, "normal! " .. vim.v.count1 .. "N") require("hlslens").start() end, { noremap = true, silent = true })
vim.keymap.set({ "n", "x" }, "*", function() require("lasterisk").search({ is_whole = false }) require("hlslens").start() end, {}) vim.keymap.set({ "n", "x" }, "g*", function() require("lasterisk").search() require("hlslens").start() end, {})
