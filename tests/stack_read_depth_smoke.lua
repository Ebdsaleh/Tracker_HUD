-- tests/stack_read_depth_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local stack_infer =
    require("tracker_hud.low_level.stack_infer")

local state = {}

local pushed_value = {
    value = "7",
    resolved = true,
    source = "instruction",
    source_kind = "integer",
    source_text = "7",
}

local pushed = stack_infer.push(
    state,
    pushed_value,
    {
        size = 8,
        offset_delta = -8,
    }
)

assert(
    pushed
        and pushed.stack_depth_before == 0
        and pushed.stack_depth_after == -8
        and pushed.stack_depth_delta == -8,
    "push transition setup changed"
)
print("PASS stack read depth: push transition setup preserved")

local popped, read_state =
    stack_infer.pop(
        state,
        {
            size = 8,
            offset_delta = 8,
        }
    )

assert(
    popped == pushed
        and popped.stack_read_depth_before == -8
        and popped.stack_read_depth_after == 0
        and popped.stack_read_depth_delta == 8,
    "pop transition setup changed"
)
print("PASS stack read depth: pop transition metadata preserved")

local fact =
    stack_infer.make_effect_fact(
        {
            name = "asm",
            architecture = "x86",
            active_variant_name = "x86_64",
        },
        {
            mnemonic = "pop",
            source_line = 2,
            operands = {
                {
                    kind = "register",
                    text = "rax",
                    source_line = 2,
                    source_column = 4,
                    source_start_line = 2,
                    source_start_column = 4,
                    source_end_line = 2,
                    source_end_column = 7,
                },
            },
        },
        {
            effect = {
                kind = "stack_pop",
                name = "pop_register",
                value_operand = 1,
                size = 8,
                offset_delta = 8,
                role = "popped stack value into register",
            },
        },
        {
            stack_pop = popped,
            stack_read_state = read_state,
            stack_depth_before = -8,
            stack_depth_after = 0,
            stack_depth_delta = 8,
        }
    )

assert(
    fact
        and fact.resolved == true
        and tostring(fact.value) == "7"
        and fact.destination_register == "rax",
    "pop value or destination changed"
)
print("PASS stack read depth: pop value resolution preserved")

assert(
    fact.stack_depth_before == -8
        and fact.stack_depth_after == 0
        and fact.stack_depth_delta == 8
        and fact.stack_depth_label == "0",
    "pop fact must prefer read transition over original push transition"
)
print("PASS stack read depth: pop fact prefers read transition")

print("PASS Tracker_HUD stack-read depth smoke")
