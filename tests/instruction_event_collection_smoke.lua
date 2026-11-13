-- tests/instruction_event_collection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local collection =
    require("tracker_hud.low_level.instruction_event_collection")

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
    10,
    0,
    16
)

local first_duplicate = fake_node(
    "first-duplicate",
    "instruction",
    0,
    10,
    0,
    16
)

local second = fake_node(
    "second",
    "special_instruction",
    1,
    2,
    1,
    8
)

local after_cursor = fake_node(
    "after-cursor",
    "instruction",
    2,
    0,
    2,
    5
)

local representative_instruction = {
    id = "rep-instruction",
}

local representative_special = {
    id = "rep-special",
}

local event_zeta = {
    name = "zeta",
}

local event_alpha = {
    name = "alpha",
}

local event_beta = {
    name = "beta",
}

local event_index = {
    node_types = {
        instruction = true,
        special_instruction = true,
    },
    by_node_type = {
        instruction = {
            __first =
                representative_instruction,
            alpha = {
                event_zeta,
                event_alpha,
            },
        },
        special_instruction = {
            __first =
                representative_special,
            beta = {
                event_beta,
            },
        },
    },
}

local requested_types = {}
local parse_calls = {}
local apply_calls = {}

local nodes_by_type = {
    instruction = {
        after_cursor,
        first_duplicate,
        first,
    },
    special_instruction = {
        second,
    },
}

local facts = collection.collect({
    context = {
        cursor = {
            line = 2,
            column = 1,
        },
    },
    event_index = event_index,

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

        if node.id == "first-duplicate" then
            return {
                mnemonic = "ALPHA",
                source_line = 1,
            }
        end

        if node.id == "second" then
            return {
                mnemonic = "beta",
                source_line = 2,
            }
        end

        return {
            mnemonic = "ignored",
            source_line = 99,
        }
    end,

    normalize_mnemonic = function(value)
        return type(value) == "string"
            and value:lower()
            or nil
    end,

    apply_event = function(
        out,
        instruction,
        event_spec
    )
        table.insert(
            apply_calls,
            {
                instruction =
                    instruction,
                event_spec =
                    event_spec,
            }
        )

        table.insert(
            out,
            {
                source_line =
                    instruction.source_line,
                name =
                    event_spec.name,
            }
        )
    end,
})

assert(
    requested_types.instruction == true
        and requested_types
            .special_instruction == true,
    "all indexed event node types must be traversed"
)
print("PASS instruction event collection: indexed node types traversed")

assert(
    #parse_calls == 2
        and parse_calls[1].node
            == first_duplicate
        and parse_calls[1].representative
            == representative_instruction
        and parse_calls[2].node
            == second
        and parse_calls[2].representative
            == representative_special,
    "event visibility, deduplication, source ordering, or representative dispatch changed"
)
print("PASS instruction event collection: visibility dedup and ordering preserved")

assert(
    #apply_calls == 3
        and apply_calls[1].event_spec
            == event_zeta
        and apply_calls[2].event_spec
            == event_alpha
        and apply_calls[3].event_spec
            == event_beta,
    "event bucket dispatch changed"
)
print("PASS instruction event collection: event dispatch preserved")

assert(
    #facts == 3
        and facts[1].source_line == 1
        and facts[1].name == "alpha"
        and facts[2].source_line == 1
        and facts[2].name == "zeta"
        and facts[3].source_line == 2
        and facts[3].name == "beta",
    "final event fact ordering changed"
)
print("PASS instruction event collection: final fact ordering preserved")

assert(
    #collection.collect({
        context = {},
        event_index = {},
    }) == 0
        and #collection.collect({
            context = {},
            event_index = {
                node_types = {},
                by_node_type = {},
            },
            collect_nodes = function()
                return {}
            end,
        }) == 0,
    "incomplete dependencies must fail closed"
)
print("PASS instruction event collection: incomplete dependencies fail closed")

print("PASS Tracker_HUD instruction-event collection smoke")
