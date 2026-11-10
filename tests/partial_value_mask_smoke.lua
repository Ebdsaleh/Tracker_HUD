-- tests/partial_value_mask_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/partial_value_mask_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local facts = require("tracker_hud.facts.contract")
local learning = require("tracker_hud.presenters.learning")
local diagram = require("tracker_hud.presenters.byte_diagram")
local bank = require("tracker_hud.presenters.register_state_bank")
local x86_64 = require("tracker_hud.architectures.x86_64.registers")

local partial = assert(facts.new({
    id = "register:rax@9",
    kind = "register",
    subject = {
        kind = "register",
        name = "rax",
        architecture = "x86-64",
        width_bits = 64,
    },
    source = { line = 9, start_column = 8 },
    value = {
        status = "partial",
        known_mask = "0x000000000000FF00",
        known_value = "0x0000000000003C00",
    },
}))

local lines = table.concat(diagram.lines(partial), "\n")
assert(lines:find("[??][??][??][??][??][??][3C][??]", 1, true),
    "fully known byte inside partial value must render exactly")
assert(lines:find("Known mask: 0x000000000000FF00", 1, true),
    "partial diagram must expose exact known mask")
assert(lines:find("Known bits: 0x0000000000003C00", 1, true),
    "partial diagram must expose exact known bit values")
assert(not lines:find("Bits: 0x0000000000003C00", 1, true),
    "partial known bits must not be mislabeled as a fully known value")
print("PASS partial masks: fully-known byte renders without fabricating neighbours")

local subbyte = assert(facts.new({
    id = "register:rax@10",
    kind = "register",
    subject = {
        kind = "register",
        name = "rax",
        architecture = "x86-64",
        width_bits = 64,
    },
    source = { line = 10, start_column = 8 },
    value = {
        status = "partial",
        known_mask = "0x00000000000000F0",
        known_value = "0x00000000000000A0",
    },
}))
local subbyte_lines = table.concat(diagram.lines(subbyte), "\n")
assert(subbyte_lines:find("[??][??][??][??][??][??][??][~?]", 1, true),
    "partially-known byte must not pretend to be an exact hex byte")
assert(subbyte_lines:find("Known mask: 0x00000000000000F0", 1, true)
    and subbyte_lines:find("Known bits: 0x00000000000000A0", 1, true),
    "sub-byte knowledge must remain exact in mask/value lines")
print("PASS partial masks: sub-byte knowledge stays explicit and honest")

local symbolic = assert(facts.new({
    id = "register:rax@11",
    kind = "register",
    subject = {
        kind = "register",
        name = "rax",
        architecture = "x86-64",
        width_bits = 64,
    },
    source = { line = 11, start_column = 8 },
    value = { status = "partial", data = "symbolic expression" },
}))
local symbolic_lines = table.concat(diagram.lines(symbolic), "\n")
assert(symbolic_lines:find("[??][??][??][??][??][??][??][??]", 1, true),
    "legacy symbolic partial facts must remain completely unknown")
assert(not symbolic_lines:find("Known mask:", 1, true),
    "symbolic partial without proof must not acquire a mask")
print("PASS partial masks: legacy symbolic partial remains all unknown")

local context = {
    cursor = { line = 12, column = 13 },
    targets = { architecture = "x86-64" },
    registers = {
        {
            name = "rax",
            source = "instruction",
            source_line = 9,
            source_start_column = 8,
            role = "partial test",
            resolved = false,
            value = nil,
            metadata = {
                family = x86_64.register_families.rax,
                family_name = "rax",
                alias_written = "ah",
                alias_spec = x86_64.register_families.rax.aliases.ah,
                partial_value = {
                    known_mask = "0x000000000000FF00",
                    known_value = "0x0000000000003C00",
                },
            },
        },
    },
}
local state = learning.state_facts(context)
assert(#state == 1 and state[1].value.status == "partial",
    "normalized register fact must preserve explicit partial certainty")
assert(state[1].value.known_mask == "0x000000000000FF00"
    and state[1].value.known_value == "0x0000000000003C00",
    "partial mask/value must survive normalization")
local bank_lines = table.concat(bank.lines(state, 12), "\n")
assert(bank_lines:find("RAX", 1, true)
    and bank_lines:find("[??][??][??][??][??][??][3C][??]", 1, true)
    and bank_lines:find("partial", 1, true),
    "persistent bank must show mixed known/unknown cells for partial state")
print("PASS partial masks: normalized and persistent presentations preserve certainty")

print("PASS Tracker_HUD partial value mask smoke")
