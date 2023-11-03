local status, dap_python = pcall(require, "nvim-dap-python")
if not status then
  return
end
require("core.utils").load_mappings "dap_python"
local path = "~/.virtualenvs/debugpy/bin/python"

dap_python.setup(path)
