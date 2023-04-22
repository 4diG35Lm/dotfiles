local status,  baleia = pcall(require,  "baleia")
if (not status) then return end

vim.api.nvim_create_user_command("BaleiaColorize", function()
	baleia.setup({}).once(vim.fn.bufnr("%"))
end, { force = true })
