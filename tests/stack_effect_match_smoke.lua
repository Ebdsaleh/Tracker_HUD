-- tests/stack_effect_match_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/stack_effect_match_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local match =
    require("tracker_hud.low_level.stack_effect_match")

local adapter = {
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
}

local symbol_like_rax = {
    kind = "symbol",
    text = "rax",
}

assert(
    match.operand_matches_spec(
        adapter,
        symbol_like_rax,
        {
            kind = "register",
        }
    ),
    "known register-shaped symbol no longer satisfies register stack spec"
)
print("PASS stack effect match: register-shaped symbol compatibility preserved")

assert(
    not match.operand_matches_spec(
        adapter,
        {
            kind = "symbol",
            text = "not_a_register",
        },
        {
            kind = "register",
        }
    ),
    "unknown symbol must not satisfy register stack spec"
)
print("PASS stack effect match: unknown symbols still fail register matching")

assert(
    match.operand_value_matches(
        {
            kind = "symbol",
            text = "RAX",
        },
        {
            value = "rax",
        }
    )
        and not match.operand_value_matches(
            {
                kind = "symbol",
                text = "rbx",
            },
            {
                value = "rax",
            }
        ),
    "stack operand value matching changed"
)
print("PASS stack effect match: case-insensitive value matching preserved")

assert(
    match.operands_match_effect(
        adapter,
        {
            operands = {
                symbol_like_rax,
            },
        },
        {
            operands = {
                {
                    index = 1,
                    kind = "register",
                    value = "RAX",
                },
            },
        }
    ),
    "stack effect operand-list matching changed"
)

assert(
    not match.operands_match_effect(
        adapter,
        {
            operands = {},
        },
        {
            operands = {
                {
                    index = 1,
                    kind = "register",
                },
            },
        }
    ),
    "missing stack operand must fail closed"
)
print("PASS stack effect match: effect operand-list contract preserved")

assert(
    not match.operands_match_effect(
        nil,
        {},
        {}
    )
        and not match.operand_matches_spec(
            adapter,
            nil,
            {}
        )
        and not match.operand_value_matches(
            nil,
            {
                value = "rax",
            }
        ),
    "invalid stack match inputs must fail closed"
)
print("PASS stack effect match: invalid inputs fail closed")

print("PASS Tracker_HUD stack-effect match smoke")
