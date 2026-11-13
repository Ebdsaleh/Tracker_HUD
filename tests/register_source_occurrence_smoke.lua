-- tests/register_source_occurrence_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_source_occurrence_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local occurrence =
    require("tracker_hud.low_level.register_source_occurrence")

local adapter = {
    register_families = {
        rax = {
            canonical = "rax",
            aliases = {
                rax = { bits = 64 },
                eax = { bits = 32 },
            },
        },
        rbp = {
            canonical = "rbp",
            aliases = {
                rbp = { bits = 64 },
                ebp = { bits = 32 },
            },
        },
        rsi = {
            canonical = "rsi",
            aliases = {
                rsi = { bits = 64 },
                esi = { bits = 32 },
            },
        },
    },

    memory_accesses = {
        mov = {
            {
                operand_index = 2,
                operand_kind = "memory",
                access = "read",
            },
        },
    },
}

assert(occurrence.resolve_register_name(
        adapter,
        "EAX"
    ) == "rax"
    and occurrence.resolve_register_name(
        adapter,
        "R10"
    ) == "r10",
    "register occurrence alias canonicalization changed")
print("PASS register source occurrence: register aliases canonicalize")

assert(occurrence.normalize_role(
        "destination_register"
    ) == "destination"
    and occurrence.normalize_role(
        "source_memory"
    ) == "source"
    and occurrence.normalize_role(
        "implicit"
    ) == "implicit",
    "register occurrence role normalization changed")
print("PASS register source occurrence: semantic roles normalize")

local memory_operand = {
    kind = "memory",
    text = "[rbp + rax*4 - 8]",
    source_line = 2,
    source_start_column = 9,
    source_end_line = 2,
    source_end_column = 26,
    memory = {
        address_text = "rbp + rax*4 - 8",
        address_kind = "bracketed",
        normalized = {
            address_mode = "default",
            address_size_bits = 64,
            address_size_status = "known",
            address_size_source = "register_width",
            base = {
                name = "rbp",
            },
            index = {
                name = "rax",
            },
            scale = {
                value = "4",
            },
            displacement = {
                value = "-8",
            },
        },
        components = {
            {
                kind = "register",
                text = "rbp",
                role = "base",
                role_label = "base register",
                structural_role = "base",
                source_start_column = 10,
                source_end_column = 13,
            },
            {
                kind = "register",
                text = "rax",
                role = "index",
                role_label = "index register",
                structural_role = "index",
                source_start_column = 16,
                source_end_column = 19,
            },
            {
                kind = "integer",
                text = "4",
                role = "scale",
                structural_role = "scale",
                source_start_column = 20,
                source_end_column = 21,
            },
            {
                kind = "integer",
                text = "-8",
                role = "displacement",
                structural_role = "displacement",
                source_start_column = 24,
                source_end_column = 26,
            },
        },
    },
}

local instruction = {
    mnemonic = "mov",
    source_start_column = 4,
    source_end_column = 26,
    mnemonic_range = {
        source_start_column = 4,
        source_end_column = 7,
    },
    operands = {
        {
            kind = "register",
            text = "eax",
            source_start_column = 8,
            source_end_column = 11,
        },
        memory_operand,
    },
}

local effect_specs = {
    {
        operands = {
            {
                index = 1,
                role = "destination_register",
            },
            {
                index = 2,
                role = "source_memory",
            },
        },
        effect = {
            target_operand = 1,
            target_register = "rflags",
        },
    },
}

local mnemonic = occurrence.build_mnemonic(
    adapter,
    instruction,
    effect_specs
)

assert(mnemonic
    and mnemonic.kind == "mnemonic"
    and mnemonic.text == "mov"
    and mnemonic.start_column == 4
    and mnemonic.end_column == 7
    and #mnemonic.targets.state == 2
    and mnemonic.targets.state[1] == "register:rflags"
    and mnemonic.targets.state[2] == "register:rax"
    and mnemonic.metadata.target_roles["register:rax"]
        == "destination"
    and mnemonic.metadata.inspection_kind == "operation",
    "mnemonic occurrence target contract changed")
print("PASS register source occurrence: mnemonic targets preserved")

local destination = occurrence.build_operand(
    adapter,
    instruction,
    instruction.operands[1],
    1,
    effect_specs
)

assert(destination
    and destination.kind == "operand"
    and destination.text == "eax"
    and destination.role == "destination"
    and #destination.targets.state == 1
    and destination.targets.state[1] == "register:rax"
    and destination.metadata.target_roles["register:rax"]
        == "destination"
    and destination.metadata.register_name == "rax"
    and destination.metadata.written_name == "eax",
    "destination operand occurrence contract changed")
print("PASS register source occurrence: destination operand preserved")

local source = occurrence.build_operand(
    adapter,
    instruction,
    memory_operand,
    2,
    effect_specs
)

assert(source
    and source.kind == "operand"
    and source.text == memory_operand.text
    and source.role == "source"
    and #source.targets.state == 2
    and source.targets.state[1] == "register:rflags"
    and source.targets.state[2] == "register:rax"
    and source.metadata.target_roles["register:rflags"]
        == "source"
    and source.metadata.target_roles["register:rax"]
        == "source"
    and source.metadata.memory_access_intent == "read"
    and source.metadata.memory_access_declared == true
    and source.metadata.memory_access_ambiguous == false
    and source.metadata.memory_access_rule_count == 1
    and source.metadata.memory_execution_status
        == "not_observed",
    "source memory operand occurrence contract changed")
print("PASS register source occurrence: source operand targets preserved")

local components = occurrence.build_memory_components(
    adapter,
    instruction,
    memory_operand,
    2,
    effect_specs
)

assert(#components == 4,
    "all memory components should remain inspectable")

local base = components[1]

assert(base.kind == "memory_component"
    and base.text == "rbp"
    and base.role == "source"
    and #base.targets.state == 3
    and base.targets.state[1] == "register:rbp"
    and base.targets.state[2] == "register:rflags"
    and base.targets.state[3] == "register:rax"
    and base.metadata.target_roles["register:rbp"]
        == "base register"
    and base.metadata.target_roles["register:rflags"]
        == "source"
    and base.metadata.target_roles["register:rax"]
        == "source"
    and base.metadata.focused_token == "rbp"
    and base.metadata.address_role == "base register"
    and base.metadata.address_role_id == "base",
    "memory-component occurrence target contract changed")
print("PASS register source occurrence: memory components preserve address roles")

local syntax_only = occurrence.build_operand(
    adapter,
    {
        mnemonic = "mystery",
        source_start_column = 0,
        source_end_column = 11,
        operands = {},
    },
    {
        kind = "register",
        text = "rsi",
        source_start_column = 4,
        source_end_column = 7,
    },
    1,
    {}
)

assert(syntax_only
    and syntax_only.role == nil
    and #syntax_only.targets.state == 1
    and syntax_only.targets.state[1] == "register:rsi"
    and syntax_only.metadata.register_name == "rsi",
    "syntax-only register occurrence must survive missing semantic rules")
print("PASS register source occurrence: syntax-only register focus preserved")

assert(occurrence.build_operand(
        adapter,
        instruction,
        {},
        1,
        effect_specs
    ) == nil
    and #occurrence.build_memory_components(
        adapter,
        instruction,
        {},
        2,
        effect_specs
    ) == 0,
    "invalid occurrence inputs must fail closed")
print("PASS register source occurrence: invalid inputs fail closed")

print("PASS Tracker_HUD register-source occurrence smoke")
