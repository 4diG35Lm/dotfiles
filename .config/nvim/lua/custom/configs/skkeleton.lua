-- "custom.configs.none-ls"
local status, skkeleton = pcall(require, "skkeleton")
if not status then
  return
end
local prev_buffer_config
--local pum_close_timer

function _G.skkeleton_enable_pre()
  prev_buffer_config = vim.fn["ddc#custom#get_buffer"]()
  vim.fn["ddc#custom#patch_buffer"]({
    completionMenu = "native",
    sources = { "skkeleton" },
  })
end

function _G.skkeleton_disable_pre()
  vim.fn["ddc#custom#set_buffer"](prev_buffer_config)
end

vim.cmd([[
  augroup skkeleton_callbacks
    autocmd!
    autocmd User skkeleton-enable-pre call v:lua.skkeleton_enable_pre()
    autocmd User skkeleton-disable-pre call v:lua.skkeleton_disable_pre()
  augroup END
]])

local dictionaries = {}
local handle = io.popen("ls $HOME/.skk/*") -- フルバスで取得
-- 辞書を探す
if handle then
  for file in handle:lines() do
    table.insert(dictionaries, file)
  end
  handle:close()
end

vim.api.nvim_create_autocmd("User", {
  pattern = "skkeleton-initialize-pre",
  callback = function()
    vim.fn["skkeleton#config"]({
      eggLikeNewline = true,
      registerConvertResult = true,
      globalDictionaries = dictionaries,
    })
  end,
})
skkeleton.setup({})
