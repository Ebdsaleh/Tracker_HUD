-- tests/memory_access_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_access_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local access = require("tracker_hud.low_level.memory_access")

local rules = {
    mov = {
        { operand_index = 1, operand_kind = "memory", access = "write" },
        { operand_index = 2, operand_kind = "memory", access = "read" },
    },
    lea = {
        { operand_index = 2, operand_kind = "memory", access = "address_only" },
    },
}

local kind, metadata = access.resolve(
    rules,
    "MOV",
    2,
    { kind = "memory" }
)
assert(kind == "read"
    and metadata.declared == true
    and metadata.ambiguous == false
    and metadata.rule_count == 1,
    "MOV source memory must resolve to read")
print("PASS memory access: declared read intent resolves")

kind, metadata = access.resolve(
    rules,
    "mov",
    1,
    { kind = "memory" }
)
assert(kind == "write"
    and metadata.declared == true
    and metadata.rule_count == 1,
    "MOV destination memory must resolve to write")
print("PASS memory access: declared write intent resolves")

kind, metadata = access.resolve(
    rules,
    "lea",
    2,
    { kind = "memory" }
)
assert(kind == "address_only"
    and metadata.declared == true,
    "LEA memory operand must resolve to address_only")
print("PASS memory access: address-only intent remains distinct")

kind, metadata = access.resolve(
    rules,
    "inc",
    1,
    { kind = "memory" }
)
assert(kind == "unknown"
    and metadata.declared == false
    and metadata.rule_count == 0,
    "undeclared instruction must fail closed to unknown")
print("PASS memory access: undeclared intent fails closed")

kind, metadata = access.resolve(
    {
        x = {
            { operand_index = 1, access = "read" },
            { operand_index = 1, access = "write" },
        },
    },
    "x",
    1,
    { kind = "memory" }
)
assert(kind == "unknown"
    and metadata.declared == true
    and metadata.ambiguous == true
    and metadata.rule_count == 2,
    "conflicting direct rules must fail closed to unknown")
print("PASS memory access: conflicting rules fail closed")

assert(access.is_valid("read")
    and access.is_valid("write")
    and access.is_valid("read_write")
    and access.is_valid("address_only")
    and access.is_valid("unknown")
    and not access.is_valid("execute"),
    "access-kind contract changed")
print("PASS memory access: normalized access vocabulary")

print("PASS Tracker_HUD memory access-intent smoke")
