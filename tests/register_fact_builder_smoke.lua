-- tests/register_fact_builder_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_fact_builder_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local builder =
    require("tracker_hud.low_level.register_fact_builder")

local family = {
    bits = 64,
    aliases = {
        rax = {},
        eax = {},
    },
}

local adapter = {
    name = "asm",
    architecture = "x86_64",
    active_variant_name = "x86_64",

    registers = {
        static = {
            {
                name = "rax",
                kind = "general",
                role = "accumulator",
                bits = 64,
            },
            {
                name = "eax",
                kind = "general",
                role = "accumulator",
                bits = 32,
            },
        },
    },

    register_alias_index = {
        rax = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 64,
                offset = 0,
                write_mode = "partial",
            },
        },

        eax = {
            canonical = "rax",
            family = family,
            alias = {
                bits = 32,
                offset = 0,
                write_mode = "zero_extend_64",
            },
        },
    },
}

local instruction = {
    mnemonic = "mov",
    source_line = 4,
    source_column = 0,
    source_start_line = 4,
    source_start_column = 0,
    source_end_line = 4,
    source_end_column = 19,

    operands = {
        {
            text = "eax",
            kind = "register",
            source_line = 4,
            source_column = 4,
            source_start_line = 4,
            source_start_column = 4,
            source_end_line = 4,
            source_end_column = 7,
        },
        {
            text = "0xFFFFFFFF",
            kind = "integer",
            source_line = 4,
            source_column = 9,
            source_start_line = 4,
            source_start_column = 9,
            source_end_line = 4,
            source_end_column = 19,
        },
    },
}

local effect_spec = {
    effect = {
        name = "mov_register_immediate",
        target_operand = 1,
        value_operand = 2,
        role = "written destination",
    },
}

local fact =
    builder.build(
        {},
        {},
        adapter,
        instruction,
        effect_spec,
        nil
    )

assert(
    fact
        and fact.name == "eax"
        and fact.kind == "general"
        and fact.role
            == "written destination",
    "register fact identity changed"
)
print("PASS register fact builder: target identity and role preserved")

assert(
    fact.resolved == true
        and fact.value
            == "0x00000000FFFFFFFF"
        and fact.metadata.write_value
            == "4294967295"
        and fact.metadata.write_resolved
            == true
        and fact.metadata.canonical_name
            == "rax",
    "32-bit alias composition changed"
)
print("PASS register fact builder: EAX canonical zero-extension preserved")

assert(
    fact.metadata.adapter == "asm"
        and fact.metadata.architecture
            == "x86_64"
        and fact.metadata.variant
            == "x86_64"
        and fact.metadata.mnemonic
            == "mov"
        and fact.metadata.effect
            == "mov_register_immediate"
        and fact.metadata.effect_target_origin
            == "operand",
    "register fact metadata identity changed"
)
print("PASS register fact builder: semantic metadata preserved")

assert(
    fact.source_line == 4
        and fact.source_column == 4
        and fact.source_start_line == 4
        and fact.source_start_column == 4
        and fact.source_end_line == 4
        and fact.source_end_column == 7,
    "target operand source range precedence changed"
)
print("PASS register fact builder: target source range precedence preserved")

local implicit =
    builder.build(
        {},
        {},
        adapter,
        {
            mnemonic = "implicit",
            source_line = 9,
            source_column = 2,
            operands = {},
        },
        {
            effect = {
                name = "implicit_rax",
                target_register = "rax",
                value = "7",
            },
        },
        nil
    )

assert(
    implicit
        and implicit.name == "rax"
        and implicit.value == "7"
        and implicit.metadata
            .effect_target_origin
            == "implicit_register"
        and implicit.source_line == 9
        and implicit.source_column == 2,
    "implicit target construction changed"
)
print("PASS register fact builder: implicit-register target preserved")

assert(
    builder.build(
        nil,
        {},
        adapter,
        instruction,
        effect_spec,
        nil
    ) == nil
        and builder.build(
            {},
            {},
            adapter,
            instruction,
            {
                effect = {
                    target_operand = 3,
                },
            },
            nil
        ) == nil,
    "invalid register fact inputs must fail closed"
)
print("PASS register fact builder: invalid inputs fail closed")

print("PASS Tracker_HUD register-fact builder smoke")
