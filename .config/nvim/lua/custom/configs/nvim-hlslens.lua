local status, hlslens = pcall(require, "hlslens")
if not status then
  return
end

hlslens.setup {
  calm_down = true,
  nearest_only = true,
  nearest_float_when = "always",
  build_position_cb = function(plist, _, _, _)
    require("scrollbar.handlers.search").handler.show(plist.start_pos)
  end,
  override_lens = function(render, posList, nearest, idx, relIdx)
    local sfw = vim.v.searchforward == 1
    local indicator, text, chunks
    local absRelIdx = math.abs(relIdx)
    if absRelIdx > 1 then
      indicator = ("%d%s"):format(absRelIdx, sfw ~= (relIdx > 1) and "▲" or "▼")
    elseif absRelIdx == 1 then
      indicator = sfw ~= (relIdx == 1) and "▲" or "▼"
    else
      indicator = ""
    end

    local lnum, col = table.unpack(posList[idx])
    if nearest then
      local cnt = #posList
      if indicator ~= "" then
        text = ("[%s %d/%d]"):format(indicator, idx, cnt)
      else
        text = ("[%d/%d]"):format(idx, cnt)
      end
      chunks = { { " ", "Ignore" }, { text, "HlSearchLensNear" } }
    else
      text = ("[%s %d]"):format(indicator, idx)
      chunks = { { " ", "Ignore" }, { text, "HlSearchLens" } }
    end
    render.setVirt(0, lnum - 1, col - 1, chunks, nearest)
  end,
}

vim.cmd [[
  augroup scrollbar_search_hide
    autocmd!
    autocmd CmdlineLeave : lua require('scrollbar.handlers.search').handler.hide()
  augroup END
]]

local kopts = { noremap = true, silent = true }

-- run `:nohlsearch` and export results to quickfix
-- if Neovim is 0.8.0 before, remap yourself.
vim.keymap.set({ "n", "x" }, "<Leader>L", function()
  vim.schedule(function()
    if require("hlslens").exportLastSearchToQuickfix() then
      vim.cmd "cw"
    end
  end)
  return ":noh<CR>"
end, { expr = true })

-- if Neovim is 0.8.0 before, remap yourself.
local function nN(char)
  local ok, winid = hlslens.nNPeekWithUFO(char)
  if ok and winid then
    -- Safe to override buffer scope keymaps remapped by ufo,
    -- ufo will restore previous buffer keymaps before closing preview window
    -- Type <CR> will switch to preview window and fire `trace` action
    vim.keymap.set("n", "<CR>", function()
      local keyCodes = api.nvim_replace_termcodes("<Tab><CR>", true, false, true)
      api.nvim_feedkeys(keyCodes, "im", false)
    end, { buffer = true })
  end
end

vim.keymap.set({ "n", "x" }, "n", function()
  nN "n"
end)
vim.keymap.set({ "n", "x" }, "N", function()
  nN "N"
end)
