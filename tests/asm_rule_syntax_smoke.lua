-- tests/asm_rule_syntax_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/asm_rule_syntax_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")

local movement = require(
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.data_movement"
)

local stack_data = require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects.data"
)

local boundaries = require(
    "tracker_hud.adapters.asm.arch.x86_64.boundary_effects.system_calls"
)

local call_returns = require(
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.control.call_returns"
)

local cases = {
    {
        label = "register",
        rule = movement.mov
            and movement.mov[1],
        mnemonic = "mov",
    },
    {
        label = "stack",
        rule = stack_data.push
            and stack_data.push[1],
        mnemonic = "push",
    },
    {
        label = "boundary",
        rule = boundaries.syscall
            and boundaries.syscall[1],
        mnemonic = "syscall",
    },
    {
        label = "event",
        rule = call_returns.call
            and call_returns.call[1],
        mnemonic = "call",
    },
}

for _, case in ipairs(cases) do
    assert(
        case.rule
            and rule_syntax.get_node_type(
                case.rule
            ) == "instruction"
            and rule_syntax.get_mnemonic(
                case.rule
            ) == case.mnemonic,
        "real ASM "
            .. case.label
            .. " rule syntax changed"
    )

    print(
        "PASS ASM rule syntax: "
            .. case.label
            .. " rule preserved"
    )
end

print("PASS Tracker_HUD ASM low-level rule-syntax smoke")
