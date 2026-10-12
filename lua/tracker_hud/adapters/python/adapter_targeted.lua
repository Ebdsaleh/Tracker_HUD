-- lua/tracker_hud/adapters/python/adapter_targeted.lua
--
-- Thin Python adapter wrapper.
--
-- The visibility-first adapter is the active implementation. This wrapper keeps
-- that implementation intact and adds a stable high-level target identity so the
-- HUD no longer reports Python files as arch/platform/abi/syntax/mode unknown.

local M = require("tracker_hud.adapters.python.adapter_visible")

M.active_targets = {
    architecture = "python",
    platform = "python",
    abi = "python-runtime",
    syntax = "python",
    mode = "dynamic",
}

return M
