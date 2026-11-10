-- lua/tracker_hud/architectures/x86_64/init.lua
--
-- Composite x86-64 architecture profile.
--
-- Hardware register truth and platform/ABI overlays are kept in independent
-- modules so language adapters can consume one shared target description.

local registers = require("tracker_hud.architectures.x86_64.registers")
local targets = require("tracker_hud.architectures.x86_64.targets")

return {
    name = registers.name,
    metadata = registers.metadata,

    register_families = registers.register_families,
    registers = registers.registers,
    register_alias_index = registers.register_alias_index,

    platforms = targets.platforms,
    default_platform = targets.default_platform,
    platform_aliases = targets.platform_aliases,
    calling_conventions = targets.calling_conventions,
    register_roles = targets.register_roles,
}
