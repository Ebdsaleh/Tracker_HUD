-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control_flow.lua
--
-- Legacy compatibility module.
--
-- All former control-flow register effects have been migrated into:
--
--     register_effects/control/branches.lua
--     register_effects/control/calls_returns.lua
--     register_effects/control/loops.lua
--
-- New code must use the categorized Tree-sitter-first modules.

return {}

