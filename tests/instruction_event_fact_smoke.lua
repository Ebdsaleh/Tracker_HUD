-- tests/instruction_event_fact_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/instruction_event_fact_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local event_fact =
    require("tracker_hud.low_level.instruction_event_fact")

local adapter = {
    name = "asm",
    architecture = "x86_64",
    active_variant_name = "x86_64",
}

local instruction = {
    mnemonic = "call",
    source_line = 7,
    source_column = 3,
    source_end_column = 14,
    operands = {
        {
            text = "target",
            kind = "symbol",
        },
    },
}

local event_spec = {
    kind = "control_event",
    category = "control_flow",
    name = "call",
    role = "calls target",

    operands = {
        {
            index = 1,
            role = "call_target",
        },
    },

    condition = {
        kind = "always",
    },

    control_flow = {
        kind = "call",
    },

    writes_after = {
        {
            register = "rip",
            role = "output",
            value = "target",
        },
    },
}

local function get_mnemonic(spec)
    return spec.name
end

local fact =
    event_fact.build(
        {},
        adapter,
        instruction,
        event_spec,
        {
            get_mnemonic =
                get_mnemonic,
        }
    )

assert(
    fact
        and fact.kind
            == "control_event"
        and fact.category
            == "control_flow"
        and fact.name == "call"
        and fact.role
            == "calls target",
    "instruction-event fact identity changed"
)
print("PASS instruction event fact: identity preserved")

assert(
    fact.source == "instruction"
        and fact.source_line == 7
        and fact.source_column == 3
        and fact.source_start_line == 7
        and fact.source_start_column == 3
        and fact.source_end_line == 7
        and fact.source_end_column == 14,
    "instruction-event source range changed"
)
print("PASS instruction event fact: source range preserved")

assert(
    fact.metadata.adapter == "asm"
        and fact.metadata.architecture
            == "x86_64"
        and fact.metadata.variant
            == "x86_64"
        and fact.metadata.mnemonic
            == "call"
        and fact.metadata.event
            == "call"
        and fact.metadata.operands
            == instruction.operands
        and fact.metadata.operand_specs
            == event_spec.operands,
    "instruction-event core metadata changed"
)
print("PASS instruction event fact: core metadata preserved")

assert(
    fact.metadata.condition
            == event_spec.condition
        and fact.metadata.control_flow
            == event_spec.control_flow
        and #fact.metadata.writes == 1
        and fact.metadata.writes[1]
            .register == "rip"
        and fact.metadata.writes[1]
            .value == "target"
        and fact.metadata.writes[1]
            .resolved == true,
    "instruction-event inferred metadata changed"
)
print("PASS instruction event fact: control metadata preserved")

local facts = {}

event_fact.apply(
    facts,
    {},
    adapter,
    instruction,
    event_spec,
    {
        get_mnemonic =
            get_mnemonic,

        matches = function(
            candidate_instruction,
            candidate_spec
        )
            return candidate_instruction
                    == instruction
                and candidate_spec
                    == event_spec
        end,
    }
)

assert(
    #facts == 1
        and facts[1].name
            == "call",
    "matched event application changed"
)

event_fact.apply(
    facts,
    {},
    adapter,
    instruction,
    event_spec,
    {
        get_mnemonic =
            get_mnemonic,

        matches = function()
            return false
        end,
    }
)

assert(
    #facts == 1,
    "non-matching event must not append a fact"
)
print("PASS instruction event fact: match-gated append preserved")

event_fact.apply(
    nil,
    {},
    adapter,
    instruction,
    event_spec,
    {
        matches = function()
            return true
        end,
    }
)

assert(
    event_fact.build(
        {},
        nil,
        instruction,
        event_spec,
        {}
    ) == nil,
    "invalid instruction-event inputs must fail closed"
)
print("PASS instruction event fact: invalid inputs fail closed")

print("PASS Tracker_HUD instruction-event fact smoke")
