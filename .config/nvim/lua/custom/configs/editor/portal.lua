local status,  portal = pcall(require, "portal")
if (not status) then return end
local builtin = require("portal.builtin")
--local query = portal.query.resolve({ "grapple" })
-- portal.jump.select(jumps[1])
portal.setup({
  query = { "grapple", ... },

})

