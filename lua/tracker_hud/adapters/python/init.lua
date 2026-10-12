-- lua/tracker_hud/adapters/python/init.lua
--
-- Python adapter entry point.
--
-- Load the contract-safe MVP adapter first. The broader adapter.lua remains in
-- the tree as the next expansion target after the core semantic vocabulary is
-- widened.

return require("tracker_hud.adapters.python.adapter_mvp")
