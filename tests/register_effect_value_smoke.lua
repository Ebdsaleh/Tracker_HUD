-- tests/register_effect_value_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_value_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local resolver =
    require("tracker_hud.low_level.register_effect_value")

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

    register_alias_index = {
        rax = {
            canonical = "rax",
            alias = {
                bits = 64,
                offset = 0,
            },
        },

        rbx = {
            canonical = "rbx",
            alias = {
                bits = 64,
                offset = 0,
            },
        },
    },
}

local facts = {
    rax = {
        name = "rax",
        value = "40",
        resolved = true,
    },
}

local value, resolved =
    resolver.resolve(
        facts,
        {
            operands = {},
        },
        {
            value = "7",
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    value == "7"
        and resolved == true,
    "literal effect value changed"
)
print("PASS register effect value: literal value preserved")

value, resolved =
    resolver.resolve(
        facts,
        {
            operands = {},
        },
        {
            value_from_stack_top = true,
        },
        {
            stack_pop = {
                value = "9",
                resolved = true,
            },
        },
        adapter,
        "rbx"
    )

assert(
    value == "9"
        and resolved == true,
    "stack-top value resolution changed"
)
print("PASS register effect value: stack-top resolution preserved")

value, resolved =
    resolver.resolve(
        facts,
        {
            operands = {},
        },
        {
            value_from_register = "rax",
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    value == "40"
        and resolved == true,
    "explicit register value resolution changed"
)

local unresolved_value,
    unresolved =
    resolver.resolve(
        {},
        {
            operands = {},
        },
        {
            value_from_register = "rax",
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    unresolved_value == "rax"
        and unresolved == false,
    "unresolved register fallback changed"
)
print("PASS register effect value: register read and unresolved fallback preserved")

value, resolved =
    resolver.resolve(
        facts,
        {
            operands = {
                {
                    text = "rax",
                    kind = "register",
                },
            },
        },
        {
            value_from_register_operand = 1,
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    value == "40"
        and resolved == true,
    "register-operand value resolution changed"
)
print("PASS register effect value: register-operand resolution preserved")

local delta_metadata

value,
resolved,
delta_metadata =
    resolver.resolve(
        {
            rbx = {
                name = "rbx",
                value = "40",
                resolved = true,
            },
        },
        {
            operands = {
                {
                    text = "rbx",
                    kind = "register",
                },
                {
                    text = "0xFFFFFFFF",
                    kind = "integer",
                },
            },
        },
        {
            target_operand = 1,
            value_delta_operand = 2,
            value_delta_operand_interpretation = {
                kind = "signed_bits",
                bits_from = "target",
                max_bits = 32,
            },
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    value == "39"
        and resolved == true
        and delta_metadata
            .source_integer_value
            == "-1"
        and delta_metadata
            .source_integer_bits
            == 32,
    "delta operand interpretation/arithmetic changed"
)
print("PASS register effect value: interpreted delta arithmetic preserved")

value, resolved =
    resolver.resolve(
        {
            rbx = {
                name = "rbx",
                value = "40",
                resolved = true,
            },
        },
        {
            operands = {
                {
                    text = "rbx",
                    kind = "register",
                },
            },
        },
        {
            target_operand = 1,
            value_delta = "2",
            value_delta_sign = -1,
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    value == "38"
        and resolved == true,
    "fixed signed delta arithmetic changed"
)
print("PASS register effect value: fixed delta sign preserved")

local immediate_metadata

value,
resolved,
immediate_metadata =
    resolver.resolve(
        facts,
        {
            operands = {
                {
                    text = "0xFFFFFFFF",
                    kind = "integer",
                },
            },
        },
        {
            value_operand = 1,
            value_operand_interpretation = {
                kind = "signed_bits",
                bits_from = "target",
                max_bits = 32,
            },
        },
        nil,
        adapter,
        "rbx"
    )

assert(
    value == "-1"
        and resolved == true
        and immediate_metadata
            .source_integer_raw_value
            == "4294967295",
    "integer operand interpretation changed"
)
print("PASS register effect value: immediate operand interpretation preserved")

local bad_value,
    bad_resolved =
    resolver.resolve(
        {},
        {
            operands = {},
        },
        {
            value_delta = "1",
            target_register = "rax",
            value_delta_sign = 2,
        },
        nil,
        adapter,
        "rax"
    )

assert(
    bad_value == nil
        and bad_resolved == false,
    "invalid delta path must fail closed"
)
print("PASS register effect value: invalid arithmetic fails closed")

print("PASS Tracker_HUD register-effect value smoke")
