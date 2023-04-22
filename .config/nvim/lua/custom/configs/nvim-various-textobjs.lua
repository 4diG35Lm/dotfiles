local status, various_textobjs = pcall(require, "various-textobjs")
if (not status) then return end
various-textobjs.setup({ 
  useDefaultKeymaps = false 
  lookForwardLines = 5, -- set to 0 to only look in the current line
})
