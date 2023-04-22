local status, project_nvim = pcall(require, "project")
if (not status) then return end

require("project_nvim").setup({ manual_mode = false })
