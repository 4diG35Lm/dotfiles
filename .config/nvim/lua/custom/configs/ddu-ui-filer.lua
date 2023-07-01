local status, ddu_ui_filer = pcall(require, "ddu-ui-filer")
if not status then
  return
end

ddu_ui_filer.setup()
