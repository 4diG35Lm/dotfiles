local windline = require('windline')
windline.setup({
  -- this function will run on ColorScheme autocmd
  colors_name = function(colors)
      --- add new colors
      colors.FilenameFg = colors.white_light
      colors.FilenameBg = colors.black

      -- this color will not update if you change a colorscheme
      colors.gray = "#fefefe"

      -- dynamically get color from colorscheme hightlight group
      local searchFg, searchBg = require('windline.themes').get_hl_color('Search')
      colors.SearchFg = searchFg or colors.white
      colors.SearchBg = searchBg or colors.yellow

      return colors
  end,
})
