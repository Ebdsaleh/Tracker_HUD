-- tests/boundary_effect_collection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/boundary_effect_collection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local collection =
    require("tracker_hud.low_level.boundary_effect_collection")

local function fake_node(
    id,
    node_type,
    start_row,
    start_column,
    end_row,
    end_column
)
    return {
        id = id,
        type = function()
            return node_type
        end,
        range = function()
            return start_row,
                start_column,
                end_row,
                end_column
        end,
    }
end

local first = fake_node(
    "first",
    "instruction",
    0,
    8,
    0,
    12
)

local first_duplicate = fake_node(
    "first-duplicate",
    "instruction",
    0,
    8,
    0,
    12
)

local second = fake_node(
    "second",
    "special_instruction",
    1,
    2,
    1,
    7
)

local unmatched = fake_node(
    "unmatched",
    "instruction",
    1,
    20,
    1,
    24
)

local after_cursor = fake_node(
    "after-cursor",
    "instruction",
    2,
    0,
    2,
    4
)

local effect_a = {
    id = "effect-a",
}

local effect_b = {
    id = "effect-b",
}

local effect_c = {
    id = "effect-c",
}

local representative_instruction = {
    id = "rep-instruction",
}

local representative_special = {
    id = "rep-special",
}

local effect_index = {
    node_types = {
        instruction = true,
        special_instruction = true,
    },
    by_node_type = {
        instruction = {
            __first =
                representative_instruction,
            foo = {
                effect_a,
                effect_b,
            },
        },
        special_instruction = {
            __first =
                representative_special,
            bar = {
                effect_c,
            },
        },
    },
}

local requested_types = {}
local parse_calls = {}
local read_calls = {}
local apply_calls = {}

local context = {
    cursor = {
        line = 2,
        column = 1,
    },
}

local nodes_by_type = {
    instruction = {
        after_cursor,
        unmatched,
        first_duplicate,
        first,
    },
    special_instruction = {
        second,
    },
}

local facts = collection.collect({
    context = context,
    effect_index = effect_index,

    collect_nodes = function(node_type)
        requested_types[node_type] = true
        return nodes_by_type[node_type]
            or {}
    end,

    parse_instruction = function(
        node,
        representative
    )
        table.insert(
            parse_calls,
            {
                node = node,
                representative =
                    representative,
            }
        )

        local mnemonic_by_id = {
            ["first-duplicate"] =
                "FOO",
            first = "foo",
            second = "bar",
            unmatched = "none",
        }

        return {
            mnemonic =
                mnemonic_by_id[node.id],
            node_id = node.id,
        }
    end,

    normalize_mnemonic = function(value)
        return type(value) == "string"
            and value:lower()
            or nil
    end,

    collect_read_context = function(
        instruction
    )
        table.insert(
            read_calls,
            instruction.node_id
        )

        return {
            read_for =
                instruction.node_id,
        }
    end,

    apply_effect = function(
        out,
        instruction,
        effect_spec,
        phase_contexts
    )
        table.insert(
            apply_calls,
            {
                node_id =
                    instruction.node_id,
                effect = effect_spec,
                phases =
                    phase_contexts,
            }
        )

        table.insert(
            out,
            instruction.node_id
                .. ":"
                .. effect_spec.id
        )
    end,
})

assert(requested_types.instruction == true
    and requested_types.special_instruction == true,
    "all indexed boundary node types must be traversed")
print("PASS boundary effect collection: indexed node types traversed")

assert(#parse_calls == 3
    and parse_calls[1].node
        == first_duplicate
    and parse_calls[1].representative
        == representative_instruction
    and parse_calls[2].node
        == second
    and parse_calls[2].representative
        == representative_special
    and parse_calls[3].node
        == unmatched,
    "boundary node deduplication or source ordering changed")
print("PASS boundary effect collection: visibility dedup and ordering preserved")

assert(#read_calls == 3
    and read_calls[1]
        == "first-duplicate"
    and read_calls[2]
        == "second"
    and read_calls[3]
        == "unmatched",
    "read-context sequencing changed")
print("PASS boundary effect collection: read context sequencing preserved")

assert(#facts == 3
    and facts[1]
        == "first-duplicate:effect-a"
    and facts[2]
        == "first-duplicate:effect-b"
    and facts[3]
        == "second:effect-c",
    "boundary effect bucket dispatch changed")
print("PASS boundary effect collection: effect dispatch preserved")

assert(#apply_calls == 3
    and apply_calls[1].phases
        .read_context.read_for
        == "first-duplicate"
    and apply_calls[1].phases
        .write_context
        == context
    and apply_calls[3].phases
        .read_context.read_for
        == "second",
    "boundary phase-context wiring changed")
print("PASS boundary effect collection: phase contexts preserved")

assert(#collection.collect({
        context = {},
        effect_index = {},
    }) == 0
    and #collection.collect({
        context = {},
        effect_index = {
            node_types = {},
            by_node_type = {},
        },
        collect_nodes = function()
            return {}
        end,
    }) == 0,
    "incomplete dependencies must fail closed")
print("PASS boundary effect collection: incomplete dependencies fail closed")

print("PASS Tracker_HUD boundary-effect collection smoke")
