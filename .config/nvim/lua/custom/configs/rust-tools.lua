local status, rust_tools = pcall(require, "rust-tools")
if not status then
  return
end

-- use nvim-lsp-installer
rust_tools.setup {}
