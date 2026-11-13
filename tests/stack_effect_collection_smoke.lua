-- tests/stack_effect_collection_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/stack_effect_collection_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local collection =
    require("tracker_hud.low_level.stack_effect_collection")

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

local register_first = fake_node(
    "register-first",
    "instruction",
    0,
    2,
    0,
    8
)

local stack_second = fake_node(
    "stack-second",
    "instruction",
    1,
    4,
    1,
    10
)

local duplicate_stack_second = fake_node(
    "stack-second-duplicate",
    "instruction",
    1,
    4,
    1,
    10
)

local after_cursor = fake_node(
    "after-cursor",
    "instruction",
    2,
    0,
    2,
    6
)

local stack_rep = {
    id = "stack-representative",
}

local register_rep = {
    id = "register-representative",
}

local push_effect = {
    id = "push-effect",
}

local mov_effect = {
    id = "mov-effect",
}

local stack_index = {
    node_types = {
        instruction = true,
    },
    by_node_type = {
        instruction = {
            __first = stack_rep,
            push = {
                push_effect,
            },
        },
    },
}

local register_index = {
    node_types = {
        instruction = true,
    },
    by_node_type = {
        instruction = {
            __first = register_rep,
            mov = {
                mov_effect,
            },
        },
    },
}

local collect_count = 0
local parse_calls = {}
local state_calls = {}
local stack_calls = {}
local register_calls = {}

local shared_nodes = {
    after_cursor,
    duplicate_stack_second,
    register_first,
    stack_second,
}

local state_token = {
    id = "low-level-state",
}

local facts = collection.collect({
    context = {
        cursor = {
            line = 2,
            column = 1,
        },
    },
    stack_effect_index = stack_index,
    register_effect_index = register_index,

    collect_nodes = function(node_type)
        assert(
            node_type == "instruction",
            "unexpected node type"
        )

        collect_count = collect_count + 1
        return shared_nodes
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
            ["register-first"] =
                "MOV",
            ["stack-second-duplicate"] =
                "push",
            ["stack-second"] =
                "push",
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

    new_state = function()
        return state_token
    end,

    prepare_stack_state = function(
        low_level_state,
        facts_by_register,
        instruction,
        stack_effect_specs
    )
        table.insert(
            state_calls,
            {
                low_level_state =
                    low_level_state,
                facts_by_register =
                    facts_by_register,
                instruction =
                    instruction,
                stack_effect_specs =
                    stack_effect_specs,
                carried_register =
                    facts_by_register.moved,
            }
        )

        return {
            prepared_for =
                instruction.node_id,
        }
    end,

    apply_stack_effect = function(
        out,
        instruction,
        effect_spec,
        instruction_state
    )
        table.insert(
            stack_calls,
            {
                instruction =
                    instruction,
                effect_spec =
                    effect_spec,
                instruction_state =
                    instruction_state,
            }
        )

        table.insert(
            out,
            instruction.node_id
                .. ":"
                .. effect_spec.id
        )
    end,

    apply_register_effect = function(
        facts_by_register,
        instruction,
        effect_spec,
        instruction_state
    )
        table.insert(
            register_calls,
            {
                instruction =
                    instruction,
                effect_spec =
                    effect_spec,
                instruction_state =
                    instruction_state,
            }
        )

        facts_by_register.moved =
            instruction.node_id
    end,
})

assert(
    collect_count == 2,
    "stack and register indexes must both be traversed"
)
print("PASS stack effect collection: both indexes traversed")

assert(
    #parse_calls == 2
        and parse_calls[1].node
            == register_first
        and parse_calls[2].node
            == duplicate_stack_second
        and parse_calls[1].representative
            == stack_rep
        and parse_calls[2].representative
            == stack_rep,
    "stack/register union deduplication, ordering, or representative precedence changed"
)
print("PASS stack effect collection: union dedup ordering preserved")

assert(
    #register_calls == 1
        and register_calls[1]
            .instruction.node_id
            == "register-first"
        and register_calls[1]
            .effect_spec
            == mov_effect
        and type(
            register_calls[1]
                .instruction_state
        ) == "table",
    "register callback sequencing changed"
)
print("PASS stack effect collection: register callback sequencing preserved")

assert(
    #state_calls == 1
        and state_calls[1]
            .low_level_state
            == state_token
        and state_calls[1]
            .carried_register
            == "register-first"
        and state_calls[1]
            .stack_effect_specs[1]
            == push_effect,
    "carried register state or stack preparation sequencing changed"
)
print("PASS stack effect collection: carried state reaches stack preparation")

assert(
    #stack_calls == 1
        and stack_calls[1]
            .instruction.node_id
            == "stack-second-duplicate"
        and stack_calls[1]
            .effect_spec
            == push_effect
        and stack_calls[1]
            .instruction_state
            .prepared_for
            == "stack-second-duplicate"
        and #facts == 1
        and facts[1]
            == "stack-second-duplicate:push-effect",
    "stack effect dispatch changed"
)
print("PASS stack effect collection: stack dispatch preserved")

assert(
    #collection.collect({
        stack_effect_index = {},
        register_effect_index = {},
    }) == 0
    and #collection.collect({
        stack_effect_index = {},
        register_effect_index = {},
        collect_nodes = function()
            return {}
        end,
    }) == 0,
    "incomplete dependencies must fail closed"
)
print("PASS stack effect collection: incomplete dependencies fail closed")

print("PASS Tracker_HUD stack-effect collection smoke")
