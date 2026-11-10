-- tests/persistent_register_diagram_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/persistent_register_diagram_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local learning = require("tracker_hud.presenters.learning")
local bank = require("tracker_hud.presenters.register_state_bank")
local x86_64 = require("tracker_hud.architectures.x86_64.registers")

local function record(name, line, value, resolved, alias)
    local family = x86_64.register_families[name]
    return {
        name = name,
        source = "instruction",
        source_line = line,
        source_start_column = 4,
        role = "written by test",
        resolved = resolved,
        value = value,
        metadata = {
            family = family,
            family_name = family.canonical,
            alias_written = alias or name,
            alias_spec = family.aliases[alias or name],
        },
    }
end

local context = {
    cursor = { line = 10, column = 9 },
    targets = { architecture = "x86-64" },
    registers = {
        record("rax", 9, 60, true, "rax"),
        record("rdi", 10, 0, true, "rdi"),
        -- Untouched architecture-only row: must not become persistent state.
        {
            name = "rbx",
            source = "adapter",
            value = nil,
            metadata = { family = x86_64.register_families.rbx },
        },
    },
}

local facts = learning.state_facts(context)
assert(#facts == 2,
    "persistent facts must include reduced dynamic state but exclude static rows")
assert(facts[1].subject.name == "rax" and facts[1].source.line == 9,
    "RAX state from the prior line must persist")
assert(facts[2].subject.name == "rdi" and facts[2].source.line == 10,
    "RDI current-line state must be included")

local lines = table.concat(bank.lines(facts, 10), "\n")
assert(lines:find("RAX", 1, true)
    and lines:find("[00][00][00][00][00][00][00][3C]", 1, true)
    and lines:find("@ line 9", 1, true),
    "carried RAX=60 state must remain visible at line 10")
assert(lines:find("> RDI", 1, true)
    and lines:find("[00][00][00][00][00][00][00][00]", 1, true)
    and lines:find("@ line 10", 1, true),
    "current-line RDI=0 state must be visible and marked")
assert(not lines:find("RBX", 1, true),
    "untouched static register rows must not masquerade as state")
print("PASS persistent diagram: prior RAX state carries through RDI update")

context.cursor.line = 11
context.registers = {
    record("rax", 11, nil, false, "rax"),
    record("rdi", 10, 0, true, "rdi"),
}
facts = learning.state_facts(context)
lines = table.concat(bank.lines(facts, 11), "\n")
assert(lines:find("> RAX", 1, true)
    and lines:find("[??][??][??][??][??][??][??][??]", 1, true)
    and lines:find("unknown", 1, true),
    "new unknown RAX state must replace the previously known RAX value")
assert(lines:find("RDI", 1, true)
    and lines:find("@ line 10", 1, true),
    "RDI state must persist when RAX changes later")
print("PASS persistent diagram: later unknown update replaces only its register")

context.cursor.line = 12
facts = learning.state_facts(context)
lines = table.concat(bank.lines(facts, 12), "\n")
assert(lines:find("RAX", 1, true) and lines:find("RDI", 1, true),
    "reduced state must remain visible on a later non-effect line")
assert(not lines:find("> RAX", 1, true) and not lines:find("> RDI", 1, true),
    "no register should be marked current when its last change was earlier")
print("PASS persistent diagram: state survives onto later non-effect lines")

print("PASS Tracker_HUD persistent register diagram smoke")
