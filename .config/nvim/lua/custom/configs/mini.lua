local status, mini = pcall(require, "mini")
if not status then
  return
end
mini.setup{}
mini.bufremove{}
