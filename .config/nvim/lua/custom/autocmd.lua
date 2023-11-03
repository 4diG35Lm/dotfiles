-- Autocmds
local group = vim.api.nvim_create_augroup
local cmd = vim.api.nvim_create_autocmd
local prefix = '_mine.'

local group_name = "vimrc_vimrc"

group(group_name, { clear = true })

cmd({ "BufEnter", "FocusGained", "InsertLeave", "WinEnter" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		if vim.o.nu and vim.fn.mode() ~= "i" then
			vim.o.rnu = true
		end
	end,
	once = false,
})
cmd({ "BufLeave", "FocusLost", "InsertEnter", "WinLeave" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		if vim.o.nu then
			vim.o.rnu = false
		end
	end,
	once = false,
})
cmd({ "QuickfixCmdPost" }, {
	group = group_name,
	pattern = { "make", "grep", "grepadd", "vimgrep", "vimgrepadd" },
	callback = function()
		vim.cmd([[cwin]])
	end,
	once = false,
})
cmd({ "QuickfixCmdPost" }, {
	group = group_name,
	pattern = { "lmake", "lgrep", "lgrepadd", "lvimgrep", "lvimgrepadd" },
	callback = function()
		vim.cmd([[lwin]])
	end,
	once = false,
})
cmd({ "FileType" }, {
	group = group_name,
	pattern = { "qf" },
	callback = function()
		vim.wo.wrap = true
	end,
	once = false,
})
cmd({ "BufWritePost" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		if string.match(vim.fn.getline(1), "^#!") then
			if string.match(vim.fn.getline(1), ".+/bin/.+") then
				vim.cmd([[silent !chmod a+x <afile>]])
			end
		end
	end,
	once = false,
})
cmd({ "CmdwinEnter" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		vim.cmd([[startinsert]])
	end,
	once = false,
})
-- Check timestamp more for 'autoread'.
cmd({ "WinEnter", "FocusGained" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		if vim.fn.bufexists("[Command Line]") == 0 then
			vim.cmd([[checktime]])
		end
	end,
	once = false,
})
cmd({ "TextYankPost" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		vim.highlight.on_yank({
			higroup = (vim.fn.hlexists("HighlightedyankRegion") > 0 and "HighlightedyankRegion" or "Visual"),
			timeout = 200,
		})
	end,
	once = false,
})
cmd({ "BufWinEnter", "WinEnter" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		if vim.bo.buftype == "prompt" then
			vim.keymap.set("i", "<C-j>", "<Esc><C-w>j", { noremap = true, silent = true, buffer = true })
			vim.keymap.set("i", "<C-k>", "<Esc><C-w>k", { noremap = true, silent = true, buffer = true })
			vim.keymap.set("i", "<C-h>", "<Esc><C-w>h", { noremap = true, silent = true, buffer = true })
			vim.keymap.set("i", "<C-l>", "<Esc><C-w>l", { noremap = true, silent = true, buffer = true })
		end
	end,
	once = false,
})
cmd({ "BufWritePre" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		local function auto_mkdir(dir, force)
			if
				vim.fn.empty(dir) == 1
				or string.match(dir, "^%w%+://")
				or vim.fn.isdirectory(dir) == 1
				or string.match(dir, "^suda:")
			then
				return
			end
			if not force then
				vim.fn.inputsave()
				local result = vim.fn.input(string.format('"%s" does not exist. Create? [y/N]', dir), "")
				if vim.fn.empty(result) == 1 then
					print("Canceled")
					return
				end
				vim.fn.inputrestore()
			end
			vim.fn.mkdir(dir, "p")
		end

		auto_mkdir(vim.fn.expand("<afile>:p:h"), vim.v.cmdbang)
	end,
	once = false,
})
cmd({ "FileType" }, {
	group = group_name,
	pattern = { "gitcommit" },
	callback = function()
		vim.cmd([[startinsert]])
	end,
	once = false,
})
-- https://github.com/vim/vim/pull/9531
-- LuaSnip insert mode overwrite register when I pasted
cmd({ "ModeChanged" }, {
	group = group_name,
	pattern = "*",
	callback = function()
		local mode = vim.api.nvim_get_mode().mode
		if mode == "s" then
			local key = vim.api.nvim_replace_termcodes("<C-r>_", true, false, true)
			vim.api.nvim_feedkeys(key, "s", false)
		end
		-- if vim.fn.mode() == "s" then
		-- 	vim.opt.clipboard:remove({ "unnamedplus", "unnamed" })
		-- else
		-- 	vim.opt.clipboard:append({ "unnamedplus", "unnamed" })
		-- end
	end,
	once = false,
})
cmd({ "ModeChanged" }, {
	group = group_name,
	pattern = "*:s",
	callback = function()
		vim.o.clipboard = ""
	end,
	once = false,
})
cmd({ "ModeChanged" }, {
	group = group_name,
	pattern = "s:*",
	callback = function()
		if vim.fn.has("clipboard") == 1 then
			vim.o.clipboard = "unnamedplus,unnamed"
		end
	end,
	once = false,
})
group("neotree", {})
cmd("UiEnter", {
	desc = "Open Neotree automatically",
	group = "neotree",
	callback = function()
		if vim.fn.argc() == 0 then
			vim.cmd("Neotree toggle")
		end
	end,
})
---------------------------------------------------------------------------------------------------
-- Terminal autocmd
---------------------------------------------------------------------------------------------------
local term = group(prefix .. 'Terminal', { clear = true })

-- Remove line numbers on terminal.
cmd('TermOpen', {
  command = 'silent setlocal nonumber norelativenumber nocul',
  group = term,
})
-- Start with insert mode
cmd('TermOpen', {
  command = 'startinsert',
  group = term,
})
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Quickfix to Trouble autocmd
---------------------------------------------------------------------------------------------------
local quickfix = group(prefix .. 'Quickfix', { clear = true })

---Defer to trouble when opening quickfix items.
function Quickfix_to_trouble()
  local ok, trouble = pcall(require, 'trouble')
  if ok then
    vim.defer_fn(function()
      vim.cmd('cclose')
      trouble.open('quickfix')
    end, 0)
  end
end

-- Push quickfix list to trouble.
cmd('BufWinEnter', {
  pattern = { 'quickfix' },
  command = 'silent lua Quickfix_to_trouble()',
  group = quickfix,
})
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- q on help and man
---------------------------------------------------------------------------------------------------
local q_help = group(prefix .. 'QHelp', { clear = true })

-- q to quit in help or man files
cmd('FileType', {
  pattern = {
    'help',
    'man',
    'vimdoc',
  },
  group = q_help,
  command = [[nnoremap <buffer><silent> q :close<CR>]],
})
---------------------------------------------------------------------------------------------------

---------------------------------------------------------------------------------------------------
-- Always open help on a vertical split.
---------------------------------------------------------------------------------------------------
local vertical_help = group(prefix .. 'verticalHelp', { clear = true })

cmd('BufEnter', {
  pattern = {
    '*.txt',
  },
  group = vertical_help,
  callback = function()
    if vim.o.filetype == 'help' then vim.cmd.wincmd('L') end
  end,
})
---------------------------------------------------------------------------------------------------