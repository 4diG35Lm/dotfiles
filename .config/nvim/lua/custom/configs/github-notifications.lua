
local status_ok, github_notifications = pcall(require, 'github-notifications')
if not status_ok then
  return
end
local secrets = require 'secrets'

github_notifications.setup({
  username = secrets.username,
  token = secrets.token,
})
