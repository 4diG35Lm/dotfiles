 local status, lexima = pcall(require, "lexima")
 if (not status) then return end
vim.g["lexima_no_default_rules"] = 1
vim.fn["lexima#set_default_rules"]()

-- シングルクォート補完の無効化
vim.fn["lexima#add_rule"] {
    filetype = { "latex", "tex", "satysfi" },
    char = "'",
    input = "'",
}

vim.fn["lexima#add_rule"] {
    char = "{",
    at = [=[\%#[-0-9a-zA-Z_]]=],
    input = "{",
}

-- TeX/LaTeX
vim.fn["lexima#add_rule"] {
    filetype = { "latex", "tex" },
    char = "{",
    input = "{",
    at = [[\%#\\]],
}
vim.fn["lexima#add_rule"] {
    filetype = { "latex", "tex" },
    char = "$",
    input_after = "$",
}
vim.fn["lexima#add_rule"] {
    filetype = { "latex", "tex" },
    char = "$",
    at = [[$\%#\$]],
    leave = 1,
}
vim.fn["lexima#add_rule"] {
    filetype = { "latex", "tex" },
    char = "<BS>",
    at = [[\$\%#\$]],
    leave = 1,
}

-- SATySFi
vim.fn["lexima#add_rule"] {
    filetype = { "satysfi" },
    char = "$",
    input = "${",
    input_after = "}",
}
vim.fn["lexima#add_rule"] {
    filetype = { "satysfi" },
    char = "$",
    at = [[\\\%#]],
    leave = 1,
}

-- reST
vim.fn["lexima#add_rule"] {
    filetype = { "rst" },
    char = "``",
    input_after = "``",
}
