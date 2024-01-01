local status, devicons = pcall(require, "nvim-web-devicons")
if (not status) then return end
devicons.setup {
 color_icons = true;
 default = true;
}
devicons.get_icon(filename, extension, { default = true })
devicons.get_icon_by_filetype(filetype, opts)
devicons.get_icon_colors_by_filetype(filetype, opts)
devicons.get_icon_color_by_filetype(filetype, opts)
devicons.get_icon_cterm_color_by_filetype(filetype, opts)
