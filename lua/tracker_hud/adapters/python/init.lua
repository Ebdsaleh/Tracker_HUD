-- lua/tracker_hud/adapters/python/init.lua
--
-- Python adapter entry point.
--
-- Load the targeted wrapper. It preserves the visibility-first implementation
-- while adding a stable Python target identity for the HUD header.

return require("tracker_hud.adapters.python.adapter_targeted")
