local status, rust = pcall(require, "rust")
if (not status) then return end

vim.g["rust_doc#define_map_K"] = 0
