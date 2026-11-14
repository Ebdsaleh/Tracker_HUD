-- tests/register_effect_pipeline_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_pipeline_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local pipeline =
    require("tracker_hud.low_level.register_effect_pipeline")

local function fake_node(id, row, column)
    return {
        id = id,
        type = function()
            return "instruction"
        end,
        range = function()
            return row,
                column,
                row,
                column + 12
        end,
        iter_children = function()
            return function()
                return nil
            end
        end,
    }
end

local first =
    fake_node("immediate", 0, 0)
local second =
    fake_node("copy", 1, 0)

local root = {
    type = function()
        return "program"
    end,
    range = function()
        return 0, 0, 2, 0
    end,
    iter_children = function()
        local nodes = {
            first,
            second,
        }
        local index = 0

        return function()
            index = index + 1
            return nodes[index]
        end
    end,
}

local immediate_rule = {
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

local copy_rule = {
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
            kind = "register",
        },
    },
    effect = {
        name = "mov_register_register",
        target_operand = 1,
        value_from_register_operand = 2,
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
            {
                name = "rbx",
                bits = 64,
            },
        },
    },
    register_effects = {
        mov = {
            immediate_rule,
            copy_rule,
        },
    },
}

local parse_calls = 0

local facts =
    pipeline.collect(
        {
            cursor = {
                line = 2,
                column = 200,
            },
        },
        adapter,
        {
            bufnr = 1,
            root_node = root,
            limit_position = {
                line = 3,
                column = 0,
            },
        },
        {
            parse_instruction = function(
                node,
                representative
            )
                parse_calls =
                    parse_calls + 1

                assert(
                    representative
                        == immediate_rule,
                    "register pipeline representative dispatch changed"
                )

                if node == first then
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
                                text = "41",
                                source_line = 1,
                            },
                        },
                    }
                end

                assert(
                    node == second,
                    "unexpected register pipeline node"
                )

                return {
                    mnemonic = "mov",
                    source_line = 2,
                    operands = {
                        {
                            kind = "register",
                            text = "rbx",
                            source_line = 2,
                        },
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
    parse_calls == 2,
    "register pipeline parser sequencing changed"
)
print("PASS register pipeline: indexed parser sequencing preserved")

local by_name = {}

for _, fact in ipairs(facts) do
    by_name[fact.name] = fact
end

assert(
    by_name.rax
        and by_name.rax.resolved == true
        and tostring(by_name.rax.value)
            == "41",
    "register pipeline immediate state changed"
)
print("PASS register pipeline: immediate state publication preserved")

assert(
    by_name.rbx
        and by_name.rbx.resolved == true
        and tostring(by_name.rbx.value)
            == "41"
        and by_name.rbx.metadata.effect
            == "mov_register_register",
    "register pipeline carried register read changed"
)
print("PASS register pipeline: carried register copy preserved")

assert(
    #pipeline.collect(
        {},
        {},
        {},
        {}
    ) == 0,
    "invalid register pipeline inputs must fail closed"
)
print("PASS register pipeline: invalid inputs fail closed")

print("PASS Tracker_HUD register-effect pipeline smoke")
