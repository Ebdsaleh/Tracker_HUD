-- tests/instruction_event_index_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/instruction_event_index_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local instruction_event_index =
    require("tracker_hud.low_level.instruction_event_index")

local function get_node_type(event_spec)
    return event_spec
        and event_spec.syntax
        and event_spec.syntax.node_type
        or event_spec
        and event_spec.node_type
        or nil
end

local function get_mnemonic(
    event_spec,
    fallback_mnemonic
)
    local fields = event_spec
        and event_spec.syntax
        and event_spec.syntax.fields
        or nil

    local kind = fields
        and fields.kind
        or nil

    return kind
        and (kind.text or kind.value)
        or event_spec
        and event_spec.mnemonic
        or fallback_mnemonic
end

local legacy_call = {
    node_type = "instruction",
    mnemonic = "CALL",
    tag = "legacy-call",
}

local legacy_ret = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                text = "ret",
            },
        },
    },
    tag = "legacy-ret",
}

local keyed_jmp = {
    syntax = {
        node_type = "instruction",
    },
    tag = "keyed-jmp",
}

local invalid = {
    mnemonic = "nop",
    tag = "invalid-no-node",
}

local instruction_events = {
    legacy_call,
    legacy_ret,
    invalid,

    jmp = {
        keyed_jmp,
    },
}

local opts = {
    get_node_type = get_node_type,
    get_mnemonic = get_mnemonic,
}

local index =
    instruction_event_index.build(
        instruction_events,
        opts
    )

assert(index.node_types.instruction == true
    and index.by_node_type.instruction
    and #index.by_node_type.instruction.call == 1
    and index.by_node_type.instruction.call[1]
        == legacy_call
    and #index.by_node_type.instruction.ret == 1
    and index.by_node_type.instruction.ret[1]
        == legacy_ret
    and #index.by_node_type.instruction.jmp == 1
    and index.by_node_type.instruction.jmp[1]
        == keyed_jmp,
    "instruction event index must preserve flat and keyed rules")
print("PASS instruction event index: legacy and keyed rules preserved")

assert(index.by_node_type.instruction.__first
        == legacy_call
    and index.by_node_type.instruction.nop
        == nil,
    "representative event or invalid-event filtering changed")
print("PASS instruction event index: representative rule and invalid filtering preserved")

local adapter = {
    instruction_events =
        instruction_events,
}

local cached_a =
    instruction_event_index.get(
        adapter,
        opts
    )

local cached_b =
    instruction_event_index.get(
        adapter,
        opts
    )

assert(cached_a == cached_b
    and cached_a.by_node_type.instruction.call[1]
        == legacy_call,
    "instruction event cache identity changed")
print("PASS instruction event index: adapter cache preserved")

assert(instruction_event_index.matches(
        {
            mnemonic = "call",
        },
        legacy_call,
        {
            get_mnemonic =
                get_mnemonic,
        }
    ) == true
    and instruction_event_index.matches(
        {
            mnemonic = "CALL",
        },
        legacy_call,
        {
            get_mnemonic =
                get_mnemonic,
        }
    ) == true
    and instruction_event_index.matches(
        {
            mnemonic = "ret",
        },
        legacy_call,
        {
            get_mnemonic =
                get_mnemonic,
        }
    ) == false,
    "instruction event mnemonic matching changed")
print("PASS instruction event index: mnemonic matching preserved")

local unconstrained_event = {
    syntax = {
        node_type = "instruction",
    },
}

assert(instruction_event_index.matches(
        {
            mnemonic = "anything",
        },
        unconstrained_event,
        {
            get_mnemonic =
                function()
                    return nil
                end,
        }
    ) == true,
    "event without mnemonic constraint must remain matchable")
print("PASS instruction event index: unconstrained events preserved")

local empty =
    instruction_event_index.build(
        instruction_events,
        {}
    )

assert(next(empty.node_types) == nil
    and next(empty.by_node_type) == nil,
    "missing syntax accessors must produce empty index")

assert(instruction_event_index.matches(
        nil,
        legacy_call,
        {
            get_mnemonic =
                get_mnemonic,
        }
    ) == false
    and instruction_event_index.matches(
        {
            mnemonic = "call",
        },
        legacy_call,
        {}
    ) == false,
    "invalid match dependencies must fail closed")
print("PASS instruction event index: incomplete dependencies fail closed")

print("PASS Tracker_HUD instruction-event index smoke")
