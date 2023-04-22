local status, debugprint = pcall(require, "debugprint")
if (not status) then return end

debugprint.setup({ create_keymaps = false })
vim.keymap.set("n", "sp", function()
	require("debugprint").debugprint()
end)
vim.keymap.set("n", "sP", function()
	require("debugprint").debugprint({ above = true })
end)
