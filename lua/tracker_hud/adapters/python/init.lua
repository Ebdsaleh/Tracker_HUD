-- lua/tracker_hud/adapters/python/init.lua
--
-- Python adapter entry point.
--
-- Load the visibility-first adapter so the HUD shows Scope and Scope Members
-- using the same working adapter pipeline as Lua.

return require("tracker_hud.adapters.python.adapter_visible")
