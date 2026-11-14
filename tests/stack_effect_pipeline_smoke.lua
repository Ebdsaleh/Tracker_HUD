-- tests/stack_effect_pipeline_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/stack_effect_pipeline_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local pipeline =
    require("tracker_hud.low_level.stack_effect_pipeline")

local function fake_node(id, row)
    return {
        id = id,
        type = function()
            return "instruction"
        end,
        range = function()
            return row, 0, row, 12
        end,
        iter_children = function()
            return function()
                return nil
            end
        end,
    }
end

local mov_node =
    fake_node("mov", 0)
local push_node =
    fake_node("push", 1)

local root = {
    type = function()
        return "program"
    end,
    range = function()
        return 0, 0, 2, 0
    end,
    iter_children = function()
        local nodes = {
            mov_node,
            push_node,
        }
        local index = 0

        return function()
            index = index + 1
            return nodes[index]
        end
    end,
}

local mov_rule = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                field = "kind",
                node_type = "word",
                text = "mov",
            },
        },
    },
    operands = {
        {
            index = 1,
            kind = "register",
        },
        {
            index = 2,
            kind = "integer",
        },
    },
    effect = {
        name = "mov_register_immediate",
        target_operand = 1,
        value_operand = 2,
    },
}

local push_rule = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                field = "kind",
                node_type = "word",
                text = "push",
            },
        },
    },
    operands = {
        {
            index = 1,
            kind = "register",
        },
    },
    effect = {
        name = "push",
        kind = "stack_push",
        value_operand = 1,
        size = 8,
    },
}

local adapter = {
    name = "asm",
    architecture = "test",
    active_variant_name = "test",
    registers = {
        static = {
            {
                name = "rax",
                bits = 64,
            },
        },
    },
    register_effects = {
        mov = {
            mov_rule,
        },
    },
    stack_effects = {
        push = {
            push_rule,
        },
    },
}

local parse_calls = {}

local facts =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 1,
            },
        },
        adapter,
        {
            bufnr = 1,
            root_node = root,
        },
        {
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

                if node == mov_node then
                    return {
                        mnemonic = "mov",
                        source_line = 1,
                        operands = {
                            {
                                kind = "register",
                                text = "rax",
                                source_line = 1,
                            },
                            {
                                kind = "integer",
                                text = "42",
                                source_line = 1,
                            },
                        },
                    }
                end

                assert(
                    node == push_node,
                    "unexpected stack pipeline node"
                )

                return {
                    mnemonic = "push",
                    source_line = 2,
                    operands = {
                        {
                            kind = "register",
                            text = "rax",
                            source_line = 2,
                        },
                    },
                }
            end,
        }
    )

assert(
    #parse_calls == 2
        and parse_calls[1]
            .representative
            == push_rule
        and parse_calls[2]
            .representative
            == push_rule,
    "stack pipeline mixed-index representative precedence changed"
)
print("PASS stack pipeline: mixed index traversal preserved")

assert(
    #facts == 1
        and facts[1].kind
            == "stack_push"
        and facts[1].resolved
            == true
        and tostring(facts[1].value)
            == "42",
    "stack pipeline register carry changed"
)
print("PASS stack pipeline: carried register value reaches push")

assert(
    facts[1].metadata
        and facts[1].metadata
            .value_source_kind
            == "register"
        and facts[1].metadata
            .value_source_text
            == "rax",
    "stack pipeline source metadata changed"
)
print("PASS stack pipeline: pushed register provenance preserved")

assert(
    #pipeline.collect(
        {},
        {},
        {},
        {}
    ) == 0,
    "invalid stack pipeline inputs must fail closed"
)
print("PASS stack pipeline: invalid inputs fail closed")

print("PASS Tracker_HUD stack-effect pipeline smoke")
