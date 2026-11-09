-- tests/normalized_fact_contract_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())
local facts = require("tracker_hud.facts.contract")

local function make(value, source)
    return facts.new({
        id = "register:rax@12",
        kind = "register",
        subject = { kind = "register", name = "rax", architecture = "x86-64" },
        source = source or { line = 12, start_column = 4, end_column = 7 },
        effect = { operation = "write", role = "destination" },
        value = value,
        provenance = { kind = "inferred", rule = "mov-immediate" },
        known_through = { line = 12, column = 7 },
    })
end

local zero, zero_err = make({ status = "known", data = 0 })
assert(zero and not zero_err and zero.value.data == 0 and facts.is_known(zero))
local no, no_err = make({ status = "known", data = false })
assert(no and not no_err and no.value.data == false and facts.is_known(no))
local nil_value = assert(make({ status = "known", is_nil = true }))
assert(facts.is_known(nil_value) and nil_value.value.is_nil)
assert(not make({ status = "known" }), "nil must not be silently known")
local unknown = assert(make({ status = "unknown" }))
assert(not facts.is_known(unknown) and unknown.value.data == nil)
local partial = assert(make({ status = "partial", data = "low 8 bits" }))
assert(partial.value.status == "partial")
local conditional = assert(make({ status = "conditional" }))
assert(conditional.value.status == "conditional")
print("PASS fact v1: known zero/false/nil distinct from unknown, partial, conditional")

assert(not facts.visible_at(zero, { line = 11, column = 100 }))
assert(not facts.visible_at(zero, { line = 12, column = 3 }))
assert(facts.visible_at(zero, { line = 12, column = 4 }))
assert(facts.visible_at(zero, { line = 12, column = 12 }))
assert(facts.visible_at(zero, { line = 13, column = 0 }))
assert(not facts.visible_at(zero, { line = 0, column = 0 }))
assert(not make({ status = "known", data = 1 },
    { line = 12, start_column = -1 }), "invalid column accepted")
assert(not facts.new({
    id = "register:test", kind = "register",
    subject = { name = "rax" },
    source = { line = 12, start_column = 4 },
    value = { status = "unknown" },
    known_through = { line = -4 },
}), "invalid known-through must not be silently replaced")
print("PASS fact v1: ON/PAST source discovery and invalid position guard")

local original = {
    id = "event:one",
    kind = "event",
    subject = { kind = "event", name = "mov" },
    source = { line = 2, start_column = 0 },
    value = { status = "unknown" },
    provenance = { kind = "source", rule = "test" },
    metadata = { nested = { flag = true } },
}
local copy = assert(facts.new(original))
original.subject.name = "modified"
original.metadata.nested.flag = false
assert(copy.subject.name == "mov" and copy.metadata.nested.flag == true)
copy.metadata.nested.flag = false
assert(original.metadata.nested.flag == false)
assert(not facts.new({ id = "x", kind = "register",
    subject = { name = "rax" }, source = { line = 1 } }),
    "missing certainty was accepted")
print("PASS fact v1: input isolation and mandatory certainty")
print("PASS normalized fact contract smoke")
