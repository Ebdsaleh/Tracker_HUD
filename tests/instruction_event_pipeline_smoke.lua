-- tests/instruction_event_pipeline_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/instruction_event_pipeline_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local pipeline =
    require("tracker_hud.low_level.instruction_event_pipeline")

local function fake_node(
    node_type,
    start_row,
    start_column,
    end_row,
    end_column,
    children
)
    local node = {
        _type = node_type,
        _children = children or {},
    }

    function node:type()
        return self._type
    end

    function node:range()
        return start_row,
            start_column,
            end_row,
            end_column
    end

    function node:iter_children()
        local index = 0

        return function()
            index = index + 1
            return self._children[index]
        end
    end

    return node
end

local node =
    fake_node(
        "instruction",
        0,
        0,
        0,
        11
    )

local root =
    fake_node(
        "program",
        0,
        0,
        1,
        0,
        {
            node,
        }
    )

local event_spec = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                field = "kind",
                node_type = "word",
                text = "call",
            },
        },
    },
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
}

local adapter = {
    name = "asm",
    architecture = "x86_64",
    active_variant_name = "x86_64",
    instruction_events = {
        call = {
            event_spec,
        },
    },
}

local instruction = {
    mnemonic = "call",
    source_line = 1,
    source_column = 0,
    source_end_column = 11,
    operands = {
        {
            kind = "symbol",
            text = "target",
        },
    },
}

local parse_calls = 0

local facts =
    pipeline.collect(
        {
            cursor = {
                line = 1,
                column = 1,
            },
        },
        adapter,
        {
            bufnr = 11,
            root_node = root,
        },
        {
            parse_instruction = function(
                seen_node,
                representative
            )
                parse_calls =
                    parse_calls + 1

                assert(
                    seen_node == node
                        and representative
                            == event_spec,
                    "instruction-event pipeline parse dispatch changed"
                )

                return instruction
            end,
        }
    )

assert(
    parse_calls == 1,
    "instruction-event pipeline parser sequencing changed"
)
print("PASS instruction event pipeline: parser dispatch preserved")

assert(
    #facts == 1
        and facts[1].name == "call"
        and facts[1].kind
            == "control_event"
        and facts[1].category
            == "control_flow",
    "instruction-event fact identity changed"
)
print("PASS instruction event pipeline: event identity preserved")

assert(
    facts[1].metadata
        and facts[1].metadata.mnemonic
            == "call"
        and facts[1].metadata.operands
            == instruction.operands
        and facts[1].metadata
            .operand_specs
            == event_spec.operands,
    "instruction-event pipeline metadata changed"
)
print("PASS instruction event pipeline: metadata preservation preserved")

assert(
    #pipeline.collect(
        {},
        {},
        {},
        {}
    ) == 0,
    "invalid instruction-event pipeline inputs must fail closed"
)
print("PASS instruction event pipeline: invalid inputs fail closed")

print("PASS Tracker_HUD instruction-event pipeline smoke")
