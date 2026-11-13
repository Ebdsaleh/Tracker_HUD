-- tests/asm_syntax_spec_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/asm_syntax_spec_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local syntax_spec =
    require("tracker_hud.syntax_spec")

local movement = require(
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.data_movement"
)

local stack_data = require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects.data"
)

local boundaries = require(
    "tracker_hud.adapters.asm.arch.x86_64.boundary_effects.system_calls"
)

local mov = movement.mov
    and movement.mov[1]
local push = stack_data.push
    and stack_data.push[1]
local syscall = boundaries.syscall
    and boundaries.syscall[1]

assert(
    mov
        and syntax_spec.get_node_type(
            mov
        ) == "instruction"
        and syntax_spec.get_field_text(
            mov,
            "kind"
        ) == "mov",
    "x86 mov syntax contract changed"
)
print("PASS ASM syntax spec: mov rule preserved")

assert(
    push
        and syntax_spec.get_node_type(
            push
        ) == "instruction"
        and syntax_spec.get_field_text(
            push,
            "kind"
        ) == "push",
    "x86 push syntax contract changed"
)
print("PASS ASM syntax spec: push rule preserved")

assert(
    syscall
        and syntax_spec.get_node_type(
            syscall
        ) == "instruction"
        and syntax_spec.get_field_text(
            syscall,
            "kind"
        ) == "syscall",
    "x86 syscall syntax contract changed"
)
print("PASS ASM syntax spec: syscall rule preserved")

assert(
    syntax_spec.normalize_mnemonic(
        syntax_spec.get_field_text(
            mov,
            "kind"
        )
    ) == "mov"
        and syntax_spec.normalize_mnemonic(
            syntax_spec.get_field_text(
                push,
                "kind"
            )
        ) == "push"
        and syntax_spec.normalize_mnemonic(
            syntax_spec.get_field_text(
                syscall,
                "kind"
            )
        ) == "syscall",
    "real adapter mnemonic normalization changed"
)
print("PASS ASM syntax spec: real adapter mnemonics normalize")

print("PASS Tracker_HUD ASM syntax-spec smoke")
