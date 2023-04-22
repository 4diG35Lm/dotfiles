local status, replacer = pcall(require, "replacer")
if (not status) then return end

vim.api.nvim_create_user_command("QfReplacer", function()
	replacer.run()
end, { force = true })
