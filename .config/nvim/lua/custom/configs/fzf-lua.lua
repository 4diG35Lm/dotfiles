-- The reason I added  'opts' as a paraameter is so you can
-- call this function with your own parameters / customizations
-- for example: 'git_files_cwd_aware({ cwd = <another git repo> })'
local function git_files_cwd_aware(opts)
    opts = opts or {}
    local fzf_lua = require("fzf-lua")
        -- git_root() will warn us if we're not inside a git repo
	    -- so we don't have to add another warning here, if
	    -- you want to avoid the error message change it to:
	    -- local git_root = fzf_lua.path.git_root(opts, true)
	    local git_root = fzf_lua.path.git_root(opts)
	    if not git_root then
		    return
	    end
	    local relative = fzf_lua.path.relative(vim.loop.cwd(), git_root)
	    opts.fzf_opts = { ["--query"] = git_root ~= relative and relative .. "/" or nil }
	    return fzf_lua.git_files(opts)
end
require'fzf-lua'.setup({
  winopts = {
    height     = 0.85,     -- window height
    width      = 0.80,     -- window width
    row        = 0.35,     -- window row position (0=top, 1=bottom)
    col        = 0.50,     -- window col position (0=left, 1=right)
    border     = 'rounded',  -- 'none', 'single', 'double', 'thicc' or 'rounded'
    fullscreen = false,    -- start fullscreen?
  },
})

vim.api.nvim_set_keymap('n', '<c-P>',
  "<cmd>lua require('fzf-lua').files()<CR>",
  { noremap = true, silent = true })

