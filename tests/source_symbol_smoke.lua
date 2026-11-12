-- tests/source_symbol_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/source_symbol_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local source_symbol = require("tracker_hud.low_level.source_symbol")

local members = {
    {
        id = "member:2:label:msg",
        kind = "label",
        name = "msg",
        line = 8,
        source_start_line = 8,
        source_start_column = 0,
        source_end_line = 8,
        source_end_column = 4,
    },
    {
        id = "member:2:global:msg",
        kind = "global",
        name = "msg",
        line = 1,
        source_start_line = 1,
        source_start_column = 0,
        source_end_line = 1,
        source_end_column = 10,
    },
}

local result = source_symbol.resolve(
    members,
    "msg",
    {
        member_kinds = { "label" },
        allow_forward = true,
        case_sensitive = true,
        reference_line = 3,
    }
)

assert(result.status == "known"
    and result.name == "msg"
    and result.kind == "label"
    and result.source_line == 8
    and result.forward_reference == true
    and result.machine_address_status == "unknown"
    and result.machine_address == nil,
    "forward ASM label must resolve source identity without machine address")
print("PASS source symbol: forward label identity resolves")

result = source_symbol.resolve(
    members,
    "msg",
    {
        member_kinds = { "label" },
        allow_forward = false,
        reference_line = 3,
    }
)

assert(result.status == "unknown"
    and result.reason == "source symbol declaration not found",
    "forward label must be excluded when forward references are disabled")
print("PASS source symbol: forward-reference policy is explicit")

result = source_symbol.resolve(
    {
        members[1],
        {
            id = "member:other",
            kind = "label",
            name = "msg",
            line = 12,
            source_start_line = 12,
        },
    },
    "msg",
    {
        member_kinds = { "label" },
        allow_forward = true,
        reference_line = 3,
    }
)

assert(result.status == "unknown"
    and result.reason == "source symbol declaration ambiguous"
    and type(result.candidates) == "table"
    and #result.candidates == 2,
    "duplicate visible labels must fail closed")
print("PASS source symbol: duplicate declarations fail closed")

result = source_symbol.resolve(
    members,
    "MSG",
    {
        member_kinds = { "label" },
        allow_forward = true,
        case_sensitive = true,
    }
)

assert(result.status == "unknown",
    "case-sensitive source symbols must not silently case-fold")
print("PASS source symbol: case-sensitive matching")

result = source_symbol.resolve(
    members,
    "MSG",
    {
        member_kinds = { "label" },
        allow_forward = true,
        case_sensitive = false,
    }
)

assert(result.status == "known"
    and result.name == "msg",
    "case-insensitive policy must be opt-in")
print("PASS source symbol: case-insensitive matching is policy-controlled")

result = source_symbol.resolve(
    members,
    "missing",
    {
        member_kinds = { "label" },
        allow_forward = true,
    }
)

assert(result.status == "unknown"
    and result.reason == "source symbol declaration not found"
    and result.machine_address_status == "unknown",
    "missing source symbol must stay unresolved")
print("PASS source symbol: missing declaration stays unknown")

print("PASS Tracker_HUD source-symbol identity smoke")
