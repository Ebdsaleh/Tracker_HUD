-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/stack_frame.lua
--
-- Legacy compatibility module.
--
-- All former stack-frame register effects have been migrated into:
--
--     register_effects/stack/frames.lua
--     register_effects/stack/push_pop.lua
--
-- POPCNT entries that were incorrectly grouped by their "pop" prefix were
-- moved to:
--
--     register_effects/integer/bit_manipulation.lua
--
-- New code must use the categorized Tree-sitter-first modules.

return {}

