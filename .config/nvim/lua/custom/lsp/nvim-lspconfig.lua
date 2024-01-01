local status, nvim_lsp = pcall(require, "lspconfig")
if (not status) then return end

--local signs = { error = "", warn = "", Hint = "", Info = "" }
-- for type, icon in pairs(signs) do
-- 	local hl = "DiagnosticSign" .. type
-- 	vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
-- end
