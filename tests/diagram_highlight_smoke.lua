-- tests/diagram_highlight_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/diagram_highlight_smoke.lua" -c "qa!"
vim.opt.runtimepath:prepend(vim.fn.getcwd())

local diagram = require("tracker_hud.presenters.byte_diagram")
local learning = require("tracker_hud.presenters.learning")
local bank = require("tracker_hud.presenters.register_state_bank")
local hud_text = require("tracker_hud.hud_text")
local x86_64 = require("tracker_hud.architectures.x86_64.registers")

local function record(name, line, value, resolved, alias)
    local family = assert(x86_64.register_families[name])
    return {
        name = name,
        source = "instruction",
        source_line = line,
        source_start_column = 8,
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

local function context_for(record_value, line)
    return {
        cursor = { line = line or record_value.source_line, column = 13 },
        targets = { architecture = "x86-64" },
        registers = { record_value },
    }
end

local function line_with(lines, needle)
    for _, line in ipairs(lines) do
        if hud_text.to_text(line):find(needle, 1, true) then
            return line
        end
    end
    return nil
end

local function count_spans(line, style, relevance)
    local count = 0
    for _, span in ipairs(hud_text.spans(line)) do
        if span.style == style
            and (relevance == nil or span.relevance == relevance)
        then
            count = count + 1
        end
    end
    return count
end

local rax_fact = assert(learning.select_fact(
    context_for(record("rax", 9, 60, true, "rax"))
))
local rax_rich = diagram.rich_lines(rax_fact)
local rax_value = assert(line_with(rax_rich, "[00][00][00][00][00][00][00][3C]"))
assert(count_spans(rax_value, "affected", "current") == 8,
    "RAX current effect must highlight all eight value bytes")
local rax_alias = assert(line_with(rax_rich, "> RAX"))
assert(count_spans(rax_alias, "register_alias", "current") == 1,
    "current RAX alias label must be emphasized")
assert(count_spans(rax_alias, "affected", "current") == 8,
    "current RAX alias map must highlight all eight covered cells")
local eax_alias = assert(line_with(rax_rich, "EAX"))
assert(count_spans(eax_alias, "register_alias", "historical") == 1,
    "non-current aliases must remain visually quieter")
print("PASS diagram highlights: RAX current alias and all covered bytes")

local ah_fact = assert(learning.select_fact(
    context_for(record("rax", 9, 60, true, "ah"))
))
local ah_rich = diagram.rich_lines(ah_fact)
local ah_value = assert(line_with(ah_rich, "[00][00][00][00][00][00][00][3C]"))
assert(count_spans(ah_value, "affected", "current") == 1,
    "AH current effect must highlight exactly one value byte")
local ah_alias = assert(line_with(ah_rich, "> AH"))
assert(count_spans(ah_alias, "affected", "current") == 1,
    "AH alias map must highlight exactly bits 15..8 byte cell")
assert(hud_text.to_text(ah_alias):find("[..][..][..][..][..][..][##][..]", 1, true),
    "AH structural map must remain second-lowest byte only")
print("PASS diagram highlights: AH highlights only bits 15..8")

local unknown_fact = assert(learning.select_fact(
    context_for(record("rax", 9, nil, false, "rax"))
))
local unknown_rich = diagram.rich_lines(unknown_fact)
local unknown_value = assert(line_with(unknown_rich, "[??][??][??][??][??][??][??][??]"))
assert(count_spans(unknown_value, "unresolved", "current") == 8,
    "unknown current bytes must use unresolved semantics")
assert(count_spans(unknown_value, "affected", "current") == 0,
    "unknown current bytes must not look like known affected values")
print("PASS diagram highlights: unknown current bytes use unresolved semantics")

local persistent_context = {
    cursor = { line = 10, column = 13 },
    targets = { architecture = "x86-64" },
    registers = {
        record("rax", 9, 60, true, "rax"),
        record("rdi", 10, 0, true, "rdi"),
    },
}
local state = learning.state_facts(persistent_context)
local rich_bank = bank.rich_lines(state, 10)
local rax_row = assert(line_with(rich_bank, "RAX"))
local rdi_row = assert(line_with(rich_bank, "> RDI"))
assert(count_spans(rax_row, "register", "historical") == 1,
    "carried RAX identity must use historical relevance")
assert(count_spans(rax_row, "immediate", "historical") == 8,
    "carried RAX bytes must be visually quieter")
assert(count_spans(rdi_row, "affected", "current") >= 9,
    "current RDI name and eight bytes must use affected/current emphasis")
assert(hud_text.to_text(rdi_row):find("> RDI", 1, true),
    "plain-mode-safe current marker must remain in text")
print("PASS persistent highlights: current row prominent, carried row historical")

local plain_bank = bank.lines(state, 10)
for index, line in ipairs(rich_bank) do
    assert(hud_text.to_text(line) == plain_bank[index],
        "semantic highlighting must not change persistent bank text")
end
print("PASS diagram highlights: rich spans preserve plain-text meaning")

print("PASS Tracker_HUD diagram highlight smoke")
