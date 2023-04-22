local status, treesitter_context = pcall(require, "treesitter-context")
if (not status) then return end

treesitter_context.setup({
 max_lines = 1,
})
