-- tests/effect_match_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/effect_match_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local effect_match =
    require("tracker_hud.low_level.effect_match")

assert(
    effect_match.normalize_operand_value(
        "  %RAX "
    ) == "rax",
    "operand value normalization changed"
)
print("PASS effect match: operand normalization preserved")

local operand = {
    kind = "register",
    text = "%RAX",
    name = "rax",
}

assert(
    effect_match.operand_value_matches(
        operand,
        "rax"
    )
        and effect_match.operand_value_matches(
            operand,
            { "rbx", "RAX" }
        )
        and not effect_match
            .operand_value_matches(
                operand,
                "rcx"
            ),
    "operand value matching changed"
)
print("PASS effect match: value alternatives preserved")

assert(
    effect_match.operand_matches_spec(
        operand,
        {
            kind = "register",
            value = "rax",
        }
    )
        and not effect_match
            .operand_matches_spec(
                operand,
                {
                    kind = "integer",
                    value = "rax",
                }
            ),
    "operand kind matching changed"
)
print("PASS effect match: operand kind contract preserved")

local instruction = {
    operands = {
        {
            kind = "register",
            text = "rax",
        },
        {
            kind = "integer",
            text = "42",
        },
    },
}

assert(
    effect_match.operands_match_effect(
        instruction,
        {
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
        }
    )
        and not effect_match
            .operands_match_effect(
                instruction,
                {
                    operands = {
                        {
                            index = 3,
                            kind = "register",
                        },
                    },
                }
            ),
    "effect operand matching changed"
)
print("PASS effect match: effect operand contract preserved")

assert(
    effect_match.condition_matches(
        {
            operands = {
                { text = "RAX" },
                { text = "rax" },
            },
        },
        {
            operands_equal = {
                1,
                2,
            },
        }
    )
        and not effect_match
            .condition_matches(
                {
                    operands = {
                        { text = "rax" },
                        { text = "rbx" },
                    },
                },
                {
                    operands_equal = {
                        1,
                        2,
                    },
                }
            ),
    "operand equality condition changed"
)
print("PASS effect match: equality condition preserved")

assert(
    effect_match.operand_value_matches(
        {},
        nil
    )
        and effect_match.condition_matches(
            {},
            nil
        )
        and not effect_match
            .operand_matches_spec(
                nil,
                {}
            )
        and not effect_match
            .operands_match_effect(
                nil,
                {}
            ),
    "invalid inputs must preserve fail-closed behavior"
)
print("PASS effect match: invalid inputs preserve contract")

print("PASS Tracker_HUD effect-match smoke")
