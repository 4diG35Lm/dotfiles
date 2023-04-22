-- loading the plugin
vim.g[vim-devicons#webdevicons_enable] = 1
-- adding the flags to NERDTree
vim.g[vim-devicons#webdevicons_enable_nerdtree] = 1
-- adding the custom source to unite
vim.g[vim-devicons#webdevicons_enable_unite] = 1
-- adding the column to vimfiler
vim.g[vim-devicons#webdevicons_enable_vimfiler] = 1
-- adding to vim-airline's tabline
vim.g[vim-devicons#webdevicons_enable_airline_tabline] = 1
-- adding to vim-airline's statusline
vim.g[vim-devicons#webdevicons_enable_airline_statusline] = 1
-- ctrlp glyphs
vim.g[vim-devicons#webdevicons_enable_ctrlp] = 1
-- adding to vim-startify screen
vim.g[vim-devicons#webdevicons_enable_startify] = 1
-- adding to flagship's statusline
vim.g[vim-devicons#webdevicons_enable_flagship_statusline] = 1
-- turn on/off file node glyph decorations (not particularly useful)
vim.g[vim-devicons#WebDevIconsUnicodeDecorateFileNodes] = 1
-- use double-width(1) or single-width(0) glyphs
-- only manipulates padding, has no effect on terminal or set(guifont) font
vim.g[vim-devicons#WebDevIconsUnicodeGlyphDoubleWidth] = 1
-- whether or not to show the nerdtree brackets around flags
vim.g[vim-devicons#webdevicons_conceal_nerdtree_brackets] = 1
-- the amount of space to use after the glyph character (default ' ')
vim.g[vim-devicons#WebDevIconsNerdTreeAfterGlyphPadding] = '  '
-- Force extra padding in NERDTree so that the filetype icons line up vertically
vim.g[vim-devicons#WebDevIconsNerdTreeGitPluginForceVAlign] = 1
-- Adding the custom source to denite
vim.g[vim-devicons#webdevicons_enable_denite] = 1
-- The amount of space to use after the glyph character in vim-airline tabline(default '')
vim.g[vim-devicons#WebDevIconsTabAirLineAfterGlyphPadding] = ' '
-- The amount of space to use before the glyph character in vim-airline tabline(default ' ')
vim.g[vim-devicons#WebDevIconsTabAirLineBeforeGlyphPadding] = ' '
-- Character Mappings
-- ƛ is used as an example below, substitute for the glyph you actually want to use
-- change the default character when no match found
vim.g[vim-devicons#WebDevIconsUnicodeDecorateFileNodesDefaultSymbol] = 'ƛ'
-- set a byte character marker (BOM) utf-8 symbol when retrieving file encoding
-- disabled by default with no value
vim.g[vim-devicons#WebDevIconsUnicodeByteOrderMarkerDefaultSymbol] = ''
-- enable folder/directory glyph flag (disabled by default with 0)
vim.g[vim-devicons#WebDevIconsUnicodeDecorateFolderNodes] = 1
-- enable open and close folder/directory glyph flags (disabled by default with 0)
vim.g[vim-devicons#DevIconsEnableFoldersOpenClose] = 1
-- enable pattern matching glyphs on folder/directory (enabled by default with 1)
vim.g[vim-devicons#DevIconsEnableFolderPatternMatching] = 1
-- enable file extension pattern matching glyphs on folder/directory (disabled by default with 0)
vim.g[vim-devicons#DevIconsEnableFolderExtensionPatternMatching] = 0
-- enable custom folder/directory glyph exact matching
-- (enabled by default when g:WebDevIconsUnicodeDecorateFolderNodes is set to 1)
let WebDevIconsUnicodeDecorateFolderNodesExactMatches] = 1
-- change the default folder/directory glyph/icon
vim.g[vim-devicons#WebDevIconsUnicodeDecorateFolderNodesDefaultSymbol] = 'ƛ'
-- change the default open folder/directory glyph/icon (default is '')
vim.g[vim-devicons#DevIconsDefaultFolderOpenSymbol] = 'ƛ'
