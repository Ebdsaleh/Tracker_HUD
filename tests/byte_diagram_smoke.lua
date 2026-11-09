-- tests/byte_diagram_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local diagram = require("tracker_hud.presenters.byte_diagram")
local learning = require("tracker_hud.presenters.learning")
local x86_64 = require("tracker_hud.architectures.x86_64.registers")
assert(x86_64.register_families.rax.bits == 64,
    "RAX width must come from the shared architecture profile")

local function check(value, expected)
    local bytes, err = diagram.bytes_for(value)
    assert(bytes, tostring(value) .. ": " .. tostring(err))
    local cells = diagram.cells(bytes)
    assert(cells == expected,
        tostring(value) .. ": expected " .. expected .. "; got " .. cells)
end

check(60, "[00][00][00][00][00][00][00][3C]")
check(0, "[00][00][00][00][00][00][00][00]")
check(-1, "[FF][FF][FF][FF][FF][FF][FF][FF]")
check("0xFFFFFFFFFFFFFFFF",
    "[FF][FF][FF][FF][FF][FF][FF][FF]")
check("18446744073709551615",
    "[FF][FF][FF][FF][FF][FF][FF][FF]")
check("9007199254740993",
    "[00][20][00][00][00][00][00][01]")
check("-9223372036854775808",
    "[80][00][00][00][00][00][00][00]")
check("0x000000000000003C",
    "[00][00][00][00][00][00][00][3C]")
assert(not diagram.bytes_for("18446744073709551616"),
    "unsigned overflow must not wrap")
assert(not diagram.bytes_for("0x10000000000000000"),
    "hex overflow must not wrap")
assert(not diagram.bytes_for("-9223372036854775809"),
    "signed overflow must not wrap")
assert(not diagram.bytes_for(9007199254740992),
    "unsafe Lua number must not be treated as exact")
assert(not diagram.bytes_for("1.25"),
    "fractional number must not be drawn as integer bits")
assert(not diagram.bytes_for("1e9"),
    "scientific notation must not be guessed from a symbol")
assert(not diagram.bytes_for(false),
    "boolean facts cannot be presented as numeric register bytes")
print("PASS byte diagram: exact integer values and overflow/precision guards")

local function fixture(value, resolved, bits)
    return {
        cursor = { line = 9, column = 13 },
        targets = { architecture = "x86-64" },
        registers = {
            {
                name = "rax",
                source = "instruction",
                source_line = 9,
                source_start_column = 8,
                role = "written by mov",
                resolved = resolved,
                value = value,
                metadata = {
                    family = bits == 64
                        and x86_64.register_families.rax
                        or (bits and { canonical = "rax", bits = bits }
                            or nil),
                },
            },
        },
    }
end

local known = assert(learning.select_fact(fixture(60, true, 64)))
assert(known.subject.width_bits == 64,
    "diagram width must be inherited from architectural profile")
local known_lines = table.concat(diagram.lines(known), "\n")
assert(known_lines:find("[00][00][00][00][00][00][00][3C]", 1, true))
assert(known_lines:find("0x000000000000003C", 1, true))
assert(known_lines:find("not live CPU state", 1, true))
assert(known_lines:find("NOT memory order", 1, true))
print("PASS byte diagram: 64-bit register high-to-low byte projection")

local no_value = assert(learning.select_fact(fixture(nil, false, 64)))
local unknown_lines = table.concat(diagram.lines(no_value), "\n")
assert(unknown_lines:find("[??][??][??][??][??][??][??][??]", 1, true))
assert(not unknown_lines:find("[00][00]", 1, true))
local unresolved_number = assert(learning.select_fact(fixture(60, false, 64)))
assert(table.concat(diagram.lines(unresolved_number), "\n")
    :find("[??][??][??][??]", 1, true),
    "numerical-looking but unresolved value must never show known bytes")
local symbolic = assert(learning.select_fact(fixture("[rbp + rax*4 - 8]", true, 64)))
assert(table.concat(diagram.lines(symbolic), "\n")
    :find("value status: partial", 1, true),
    "symbolic expression must be unknown rather than numeric")
local no_width = assert(learning.select_fact(fixture(60, true, nil)))
local no_width_lines = table.concat(diagram.lines(no_width), "\n")
assert(no_width_lines:find("no verified 64-bit", 1, true))
assert(not no_width_lines:find("[00]", 1, true))
local non_64 = assert(learning.select_fact(fixture(60, true, 32)))
assert(table.concat(diagram.lines(non_64), "\n")
    :find("no verified 64-bit", 1, true))

local before = fixture(60, true, 64)
before.cursor.column = 8   -- source col 7, before token col 8
assert(learning.select_fact(before) == nil,
    "diagram must respect ON/PAST source token cursor gate")
before.cursor.column = 9   -- source col 8, ON token
assert(learning.select_fact(before) ~= nil,
    "diagram must show a fact ON the first source token character")
print("PASS byte diagram: unknown/partial/width fallback and ON/PAST gates")
print("PASS Tracker_HUD byte diagram smoke")
