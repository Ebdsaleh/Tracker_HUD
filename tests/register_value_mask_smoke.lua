-- tests/register_value_mask_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local compose = require("tracker_hud.low_level.register_value_mask")
local x86 = require("tracker_hud.architectures.x86_64.registers")
local rax = assert(x86.register_families.rax)

local ah = assert(compose.apply_alias_write(
    nil,
    rax.aliases.ah,
    "0x3C",
    true
))
assert(ah.status == "partial"
    and ah.resolved == false
    and ah.partial_value.known_mask == "0x000000000000FF00"
    and ah.partial_value.known_value == "0x0000000000003C00",
    "AH into unknown canonical state must prove exactly bits 15..8")
print("PASS alias composer: AH into unknown state produces exact partial mask")

local previous = {
    value = "0x0011223344556677",
    resolved = true,
    metadata = {},
}
local ah_known = assert(compose.apply_alias_write(
    previous,
    rax.aliases.ah,
    "0xAA",
    true
))
assert(ah_known.status == "known"
    and ah_known.value == "0x001122334455AA77",
    "AH must preserve every known bit outside bits 15..8")

local al_known = assert(compose.apply_alias_write(
    {
        value = ah_known.value,
        resolved = true,
        metadata = {},
    },
    rax.aliases.al,
    "0xBB",
    true
))
assert(al_known.value == "0x001122334455AABB",
    "AL must replace only low byte")

local ax_known = assert(compose.apply_alias_write(
    {
        value = al_known.value,
        resolved = true,
        metadata = {},
    },
    rax.aliases.ax,
    "0xCCDD",
    true
))
assert(ax_known.value == "0x001122334455CCDD",
    "AX must replace only low word")
print("PASS alias composer: known AH/AL/AX writes preserve surrounding bits")

local eax_known = assert(compose.apply_alias_write(
    nil,
    rax.aliases.eax,
    "0x12345678",
    true
))
assert(eax_known.status == "known"
    and eax_known.value == "0x0000000012345678",
    "known EAX write must zero upper 32 bits and fully determine RAX")
print("PASS alias composer: known EAX write fully determines zero-extended RAX")

local unknown_ah = assert(compose.apply_alias_write(
    {
        value = "0x0000000012345678",
        resolved = true,
        metadata = {},
    },
    rax.aliases.ah,
    nil,
    false
))
assert(unknown_ah.status == "partial"
    and unknown_ah.partial_value.known_mask == "0xFFFFFFFFFFFF00FF"
    and unknown_ah.partial_value.known_value == "0x0000000012340078",
    "unknown AH must invalidate only its own byte")
print("PASS alias composer: unknown AH preserves proven surrounding state")

local unknown_eax = assert(compose.apply_alias_write(
    {
        value = "0xFFFFFFFFFFFFFFFF",
        resolved = true,
        metadata = {},
    },
    rax.aliases.eax,
    nil,
    false
))
assert(unknown_eax.status == "partial"
    and unknown_eax.partial_value.known_mask == "0xFFFFFFFF00000000"
    and unknown_eax.partial_value.known_value == "0x0000000000000000",
    "unknown EAX must still prove upper 32 bits are zero")
print("PASS alias composer: unknown EAX still proves architectural zero extension")

local overflow = assert(compose.apply_alias_write(
    nil,
    rax.aliases.al,
    "0x100",
    true
))
assert(overflow.status == "unknown",
    "out-of-width AL source must not be truncated into false certainty")
print("PASS alias composer: out-of-width source does not fabricate truncated bits")

print("PASS Tracker_HUD register value mask smoke")
