local status, tsht = pcall(require, "tsht")
if (not status) then return end

tsht.config.hint_keys = { "h", "j", "f", "d", "n", "v", "s", "l", "a" }
