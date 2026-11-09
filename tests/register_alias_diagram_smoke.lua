-- tests/register_alias_diagram_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local diagram = require("tracker_hud.presenters.byte_diagram")
local learning = require("tracker_hud.presenters.learning")
local x86_64 = require("tracker_hud.architectures.x86_64.registers")

local function fixture(family_name, source_alias, value, resolved)
    local family = assert(x86_64.register_families[family_name])
    return {
        cursor = { line = 9, column = 13 },
        targets = { architecture = "x86-64" },
        registers = {
            {
                name = family.canonical,
                source = "instruction",
                source_line = 9,
                source_start_column = 8,
                role = "written by mov",
                resolved = resolved,
                value = value,
                metadata = {
                    family = family,
                    family_name = family.canonical,
                    alias_written = source_alias,
                    alias_spec = family.aliases[source_alias],
                },
            },
        },
    }
end

local function rendered(context)
    local fact = assert(learning.select_fact(context), "expected source-visible fact")
    return table.concat(diagram.lines(fact), "\n"), fact
end

local rax_lines, rax_fact = rendered(fixture("rax", "rax", 60, true))
assert(rax_fact.metadata.source_alias == "rax",
    "normalized fact must preserve actual source alias")
assert(rax_fact.metadata.register_family.aliases.ah.offset == 8,
    "normalized fact must preserve architecture-owned AH offset")
assert(rax_lines:find("[##][##][##][##][##][##][##][##]", 1, true),
    "RAX must cover all eight byte cells")
assert(rax_lines:find("[..][..][..][..][##][##][##][##]", 1, true),
    "EAX must cover the low four byte cells")
assert(rax_lines:find("[..][..][..][..][..][..][##][##]", 1, true),
    "AX must cover the low two byte cells")
assert(rax_lines:find("[..][..][..][..][..][..][##][..]", 1, true),
    "AH must cover bits 15..8, not the low byte")
assert(rax_lines:find("[..][..][..][..][..][..][..][##]", 1, true),
    "AL must cover bits 7..0")
assert(rax_lines:find("bits 15..8", 1, true),
    "AH bit range must be explicit")
assert(rax_lines:find("> RAX", 1, true),
    "source alias marker must identify RAX")
assert(rax_lines:find("if RAX is written, all 64 bits", 1, true),
    "full-width architecture write rule missing")
print("PASS alias diagram: RAX/EAX/AX/AH/AL byte placement and full write")

local eax_lines = rendered(fixture("rax", "eax", 60, true))
assert(eax_lines:find("> EAX", 1, true),
    "source alias marker must follow EAX source spelling")
assert(eax_lines:find("if EAX is written, the upper 32 bits are cleared to zero", 1, true),
    "EAX zero-extension write rule must be explained")
print("PASS alias diagram: EAX source focus and zero_extend_64 wording")

local ah_lines = rendered(fixture("rax", "ah", 60, true))
assert(ah_lines:find("> AH", 1, true),
    "source alias marker must follow AH source spelling")
assert(ah_lines:find("if AH is written, only its covered bits change; other bits are preserved", 1, true),
    "partial-write preservation rule must be explained")
print("PASS alias diagram: AH source focus and partial-write wording")

local r8_lines = rendered(fixture("r8", "r8b", 7, true))
assert(r8_lines:find("R8D", 1, true)
    and r8_lines:find("R8W", 1, true)
    and r8_lines:find("R8B", 1, true),
    "R8 family aliases must come from its own architecture profile")
assert(not r8_lines:find(" AH ", 1, true)
    and not r8_lines:find(" AL ", 1, true),
    "R8 must not inherit legacy high/low-byte aliases from RAX")
assert(r8_lines:find("> R8B", 1, true),
    "R8B source alias must be marked")
print("PASS alias diagram: register-family isolation")

local unknown_lines = rendered(fixture("rax", "al", nil, false))
assert(unknown_lines:find("[??][??][??][??][??][??][??][??]", 1, true),
    "unknown value must stay unknown")
assert(unknown_lines:find("Alias map", 1, true)
    and unknown_lines:find("> AL", 1, true),
    "architectural alias shape may remain visible when value is unknown")
assert(not unknown_lines:find("Bits: 0x", 1, true),
    "unknown source value must not gain fabricated numeric bits")
print("PASS alias diagram: structural architecture facts do not invent values")

print("PASS Tracker_HUD register alias diagram smoke")
