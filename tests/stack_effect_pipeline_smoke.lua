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

local root_walks = 0

local root = {
    type = function()
        return "program"
    end,
    range = function()
        return 0, 0, 2, 0
    end,
    iter_children = function()
        root_walks =
            root_walks + 1

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

local fallback_root_walks =
    root_walks

assert(
    fallback_root_walks > 0,
    "standalone stack pipeline did not retain recursive node fallback"
)
print(
    "PASS stack pipeline: standalone node traversal fallback preserved"
)

root_walks = 0
parse_calls = {}

local prepared_facts =
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
            prepared_register_source = {
                effect_index = {
                    node_types = {
                        instruction = true,
                    },
                },
                nodes = {
                    {
                        node = mov_node,
                        line = 1,
                        column = 0,
                    },
                    {
                        node = push_node,
                        line = 2,
                        column = 0,
                    },
                },
            },
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
    root_walks == 0,
    "complete prepared register-node coverage did not bypass stack tree walk"
)

assert(
    #prepared_facts == 1
        and prepared_facts[1].resolved
            == true
        and tostring(
            prepared_facts[1].value
        ) == "42",
    "prepared-node stack collection changed semantic result"
)

print(
    "PASS stack pipeline: prepared register nodes bypass duplicate traversal"
)

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


root_walks = 0
parse_calls = {}

local timeline_queries = 0
local timeline_counters = {}

local timeline_facts =
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
            register_timeline = {
                snapshot_before =
                    function(
                        _self,
                        position
                    )
                        timeline_queries =
                            timeline_queries + 1

                        assert(
                            position.line == 2
                                and position.column == 0,
                            "stack timeline query position changed"
                        )

                        return {
                            {
                                name = "rax",
                                value = "42",
                                resolved = true,
                                metadata = {
                                    canonical_name = "rax",
                                    write_value = "42",
                                    write_resolved = true,
                                },
                            },
                        }
                    end,
            },
            profile_counter =
                function(name, delta)
                    timeline_counters[name] =
                        (timeline_counters[name] or 0)
                        + delta
                end,
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
    timeline_queries == 1
        and #timeline_facts == 1
        and timeline_facts[1].resolved
            == true
        and tostring(
            timeline_facts[1].value
        ) == "42"
        and timeline_counters[
            "context.stack.dynamic.timeline_hits"
        ] == 1,
    "stack timeline did not preserve pre-instruction register carry"
)

print(
    "PASS stack pipeline: "
        .. "timeline snapshot replaces local register carry"
)

local fallback_queries = 0
local fallback_counters = {}

local fallback_facts =
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
            register_timeline = {
                snapshot_before =
                    function()
                        fallback_queries =
                            fallback_queries + 1
                        return nil
                    end,
            },
            profile_counter =
                function(name, delta)
                    fallback_counters[name] =
                        (fallback_counters[name] or 0)
                        + delta
                end,
        },
        {
            parse_instruction = function(node)
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
    fallback_queries == 1
        and #fallback_facts == 1
        and fallback_facts[1].resolved
            == true
        and tostring(
            fallback_facts[1].value
        ) == "42"
        and fallback_counters[
            "context.stack.dynamic.timeline_fallbacks"
        ] == 1,
    "stack timeline miss did not rerun legacy register carry"
)

print(
    "PASS stack pipeline: "
        .. "incomplete timeline reruns legacy mixed reducer"
)


print("PASS Tracker_HUD stack-effect pipeline smoke")
