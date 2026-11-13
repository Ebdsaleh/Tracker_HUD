-- tests/register_source_metadata_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_source_metadata_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local metadata =
    require("tracker_hud.low_level.register_source_metadata")

local effect_spec = {
    operands = {
        {
            index = 2,
            role = "source_memory",
        },
    },
}

local source_operand = {
    kind = "memory",
    text = "[rbp + 8]",
    source_line = 12,
    source_column = 9,
    source_start_line = 12,
    source_start_column = 9,
    source_end_line = 12,
    source_end_column = 18,
    memory = {
        address_text = "rbp + 8",
        address_kind = "bracketed",
        size = {
            prefix = "qword",
            bits = 64,
        },
        normalized = {
            address_mode = "default",
            address_size_bits = 64,
            address_size_status = "known",
            address_size_source = "register_width",
            base = {
                name = "rbp",
            },
            displacement = {
                value = "8",
            },
        },
    },
}

local instruction = {
    operands = {
        {
            kind = "register",
            text = "rax",
        },
        source_operand,
    },
}

assert(metadata.get_effect_operand_spec(
        effect_spec,
        2
    ) == effect_spec.operands[1]
    and metadata.get_effect_operand_spec(
        effect_spec,
        1
    ) == nil,
    "effect operand lookup changed")
print("PASS register source metadata: effect operand lookup preserved")

assert(metadata.get_source_operand_index({
        value_operand = "2",
        value_from_register_operand = 3,
        value_delta_operand = 4,
        size_operand = 5,
    }) == 2
    and metadata.get_source_operand_index({
        value_from_register_operand = "3",
    }) == 3
    and metadata.get_source_operand_index({}) == nil,
    "source operand precedence changed")
print("PASS register source metadata: source index precedence preserved")

local operand_result = metadata.build(
    effect_spec,
    instruction,
    {
        value_operand = 2,
    },
    {}
)

assert(operand_result.source_operand_index == 2
    and operand_result.source_operand == "[rbp + 8]"
    and operand_result.source_operand_kind == "memory"
    and operand_result.source_kind == "memory"
    and operand_result.source_operand_role == "source_memory"
    and operand_result.source_role == "source memory"
    and operand_result.value_source == "memory [rbp + 8]"
    and operand_result.source_operand_start_column == 9
    and operand_result.source_operand_end_column == 18
    and operand_result.containing_operand == "[rbp + 8]"
    and operand_result.memory_size == "qword (64-bit)"
    and operand_result.memory_base_register == "rbp"
    and operand_result.memory_displacement == "8",
    "source operand metadata contract changed")
print("PASS register source metadata: operand source fields preserved")

local stack_result = metadata.build(
    {},
    {
        operands = {},
    },
    {
        value_from_stack_top = true,
    },
    {
        stack_pop = {
            source_kind = "memory",
            source_name = "stack-slot",
            source_text = "[rsp]",
            resolved = false,
        },
    }
)

assert(stack_result.source_operand_kind == "stack"
    and stack_result.source_operand_role == "stack_top"
    and stack_result.source_operand == "[rsp]"
    and stack_result.value_source == "stack [rsp]"
    and stack_result.stack_value_source_kind == "memory"
    and stack_result.stack_value_source_name == "stack-slot"
    and stack_result.stack_value_source_text == "[rsp]"
    and stack_result.stack_value_resolved == false,
    "stack source metadata contract changed")
print("PASS register source metadata: stack source fields preserved")

local register_result = metadata.build(
    {},
    {
        operands = {},
    },
    {
        value_from_register = "rsp",
    },
    {}
)

assert(register_result.source_operand_kind == "register"
    and register_result.source_operand_role == "source_register"
    and register_result.source_role == "source register"
    and register_result.source_operand == "rsp"
    and register_result.value_source == "register rsp",
    "implicit register source metadata changed")
print("PASS register source metadata: implicit register source preserved")

local target = {
    existing = true,
    keep_nil = "unchanged",
}

local merged = metadata.merge(
    target,
    {
        added = "value",
        keep_nil = nil,
    }
)

assert(merged == target
    and target.existing == true
    and target.added == "value"
    and target.keep_nil == "unchanged",
    "metadata merge semantics changed")
print("PASS register source metadata: merge semantics preserved")

assert(next(metadata.build(
        nil,
        nil,
        nil,
        nil
    )) == nil
    and metadata.merge(
        "not-a-table",
        {}
    ) == "not-a-table",
    "invalid inputs must fail closed")
print("PASS register source metadata: invalid inputs fail closed")

print("PASS Tracker_HUD register-source metadata smoke")
