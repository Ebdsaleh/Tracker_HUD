-- tests/register_value_policy_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_value_policy_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local policy =
    require("tracker_hud.low_level.register_value_policy")

local adapter = {
    registers = {
        static = {
            {
                name = "rax",
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

        eax = {
            canonical = "rax",
            alias = {
                bits = 32,
                offset = 0,
            },
        },

        al = {
            canonical = "rax",
            alias = {
                bits = 8,
                offset = 0,
            },
        },
    },
}

local value,
    resolved,
    metadata =
    policy.apply_width_policy(
        adapter,
        "rax",
        {},
        "18446744073709551616",
        true
    )

assert(
    value
        == "18446744073709551616"
        and resolved == true
        and metadata == nil,
    "missing width policy must remain pass-through"
)
print("PASS register value policy: no-policy pass-through preserved")

value,
resolved,
metadata =
    policy.apply_width_policy(
        adapter,
        "al",
        {
            value_width_policy =
                "wrap_unsigned_target",
        },
        "-1",
        true
    )

assert(
    value == "255"
        and resolved == true
        and metadata.value_width_bits
            == 8
        and metadata.pre_width_write_value
            == "-1"
        and metadata.value_wrapped
            == true,
    "8-bit modular wrap changed"
)
print("PASS register value policy: target-width modular wrap preserved")

local bad_value,
    bad_resolved,
    bad_metadata =
    policy.apply_width_policy(
        adapter,
        "rax",
        {
            value_width_policy =
                "unsupported",
        },
        "1",
        true
    )

assert(
    bad_value == nil
        and bad_resolved == false
        and bad_metadata
            .value_width_error
            == "unsupported policy",
    "unsupported width policy must fail closed"
)

local no_width_value,
    no_width_resolved,
    no_width_metadata =
    policy.apply_width_policy(
        adapter,
        "missing",
        {
            value_width_policy =
                "wrap_unsigned_target",
        },
        "1",
        true
    )

assert(
    no_width_value == nil
        and no_width_resolved == false
        and no_width_metadata
            .value_width_error
            == "target width unavailable",
    "missing target width must fail closed"
)
print("PASS register value policy: unsupported and missing-width paths fail closed")

local interpreted,
    interpreted_resolved,
    integer_metadata =
    policy.interpret_integer_operand(
        adapter,
        "rax",
        "0xFFFFFFFF",
        {
            kind = "signed_bits",
            bits_from = "target",
            max_bits = 32,
        }
    )

assert(
    interpreted == "-1"
        and interpreted_resolved == true
        and integer_metadata
            .source_integer_interpretation
            == "signed_bits"
        and integer_metadata
            .source_integer_bits
            == 32
        and integer_metadata
            .source_integer_bits_source
            == "target_capped"
        and integer_metadata
            .source_integer_raw_value
            == "4294967295"
        and integer_metadata
            .source_integer_value
            == "-1"
        and integer_metadata
            .source_integer_error
            == nil,
    "signed target-derived immediate interpretation changed"
)
print("PASS register value policy: signed immediate interpretation preserved")

local exact,
    exact_resolved,
    exact_metadata =
    policy.interpret_integer_operand(
        adapter,
        "rax",
        "0x2A",
        nil
    )

assert(
    exact == "42"
        and exact_resolved == true
        and exact_metadata == nil,
    "policy-free integer normalization changed"
)

local overflow,
    overflow_resolved,
    overflow_metadata =
    policy.interpret_integer_operand(
        adapter,
        "rax",
        "0x100000000",
        {
            kind = "signed_bits",
            bits_from = "target",
            max_bits = 32,
        }
    )

assert(
    overflow == nil
        and overflow_resolved == false
        and overflow_metadata
            .source_integer_bits
            == 32
        and overflow_metadata
            .source_integer_error
            == "value does not fit source width",
    "out-of-range immediate must fail closed"
)
print("PASS register value policy: exact and overflow interpretation preserved")

assert(
    policy.parse_numeric_value(
        "0x2A"
    ) == "42"
        and policy.parse_numeric_number(
            "42"
        ) == 42
        and policy.build_integer_operand_metadata(
            nil
        ) == nil,
    "numeric helper contract changed"
)
print("PASS register value policy: numeric helpers preserved")

print("PASS Tracker_HUD register-value policy smoke")
