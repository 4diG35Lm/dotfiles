local status, trim = pcall(require, "trim")
if (not status) then return end

trim.setup({
    -- you can specify filetypes.
    disable = {"markdown"},
    -- if you want to ignore space of top
    patterns = {
        [[%s/\s\+$//e]],
        [[%s/\($\n\s*\)\+\%$//]],
        [[%s/\(\n\n\)\n\+/\1/]],
    },
})
