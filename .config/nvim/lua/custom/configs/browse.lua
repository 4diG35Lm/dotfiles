local status,  browse = pcall(require,  "browse")
if (not status) then return end

 local function command(name, rhs, opts)
   opts = opts or {}
   vim.api.nvim_create_user_command(name, rhs, opts)
 end

 command("BrowseInputSearch", function()
   browse.input_search()
 end, {})

 command("BrowseDevdocsSearch", function()
   browse.devdocs.search()
 end, {})

 command("BrowseDevdocsFiletypeSearch", function()
   browse.devdocs.search_with_filetype()
 end, {})

 command("BrowseMdnSearch", function()
   browse.mdn.search()
 end, {})
