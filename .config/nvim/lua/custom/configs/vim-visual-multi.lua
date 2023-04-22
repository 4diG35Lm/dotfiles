vim.cmd([[
    aug VMlens
        au!
        au User visual_multi_start lua require('configs.vmlens').start()
        au User visual_multi_exit lua require('configs.vmlens').exit()
    aug END
]])
