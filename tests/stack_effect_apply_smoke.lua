-- tests/stack_effect_apply_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/stack_effect_apply_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local stack_apply =
    require("tracker_hud.low_level.stack_effect_apply")

local adapter = {
    name = "asm",
    architecture = "x86-64",
    active_variant_name = "x86-64",
}

local instruction = {
    mnemonic = "push",
    source_line = 3,
    source_column = 0,
    operands = {
        {
            kind = "integer",
            text = "7",
            source_line = 3,
            source_column = 5,
        },
    },
}

local effect_spec = {
    mnemonic = "push",
    operands = {
        {
            index = 1,
            kind = "integer",
        },
    },
    effect = {
        name = "push_immediate",
        kind = "stack_push",
        size = 8,
        value_operand = 1,
    },
}

local opts = {
    get_mnemonic = function(spec)
        return spec.mnemonic
    end,

    normalize_mnemonic = function(value)
        return type(value) == "string"
            and value:lower()
            or nil
    end,
}

assert(
    stack_apply.matches(
        adapter,
        instruction,
        effect_spec,
        opts
    ),
    "matching stack instruction rejected"
)

assert(
    not stack_apply.matches(
        adapter,
        {
            mnemonic = "pop",
            operands = instruction.operands,
        },
        effect_spec,
        opts
    ),
    "mismatched stack mnemonic accepted"
)

assert(
    not stack_apply.matches(
        adapter,
        {
            mnemonic = "push",
            operands = {
                {
                    kind = "register",
                    text = "rax",
                },
            },
        },
        effect_spec,
        opts
    ),
    "mismatched stack operand accepted"
)
print("PASS stack effect apply: mnemonic and operand matching preserved")

local fact =
    stack_apply.build(
        adapter,
        instruction,
        effect_spec,
        {}
    )

assert(
    fact
        and fact.kind == "stack_push"
        and fact.resolved == true
        and tostring(fact.value) == "7"
        and fact.metadata
        and fact.metadata.effect
            == "push_immediate",
    "stack fact construction changed"
)
print("PASS stack effect apply: fact construction preserved")

local facts = {}

stack_apply.apply(
    facts,
    adapter,
    instruction,
    effect_spec,
    {},
    opts
)

assert(
    #facts == 1
        and facts[1].kind
            == "stack_push",
    "matching stack fact was not appended"
)

stack_apply.apply(
    facts,
    adapter,
    {
        mnemonic = "pop",
        operands = instruction.operands,
    },
    effect_spec,
    {},
    opts
)

assert(
    #facts == 1,
    "mismatched stack effect must not append"
)
print("PASS stack effect apply: match-gated append preserved")

stack_apply.apply(
    nil,
    adapter,
    instruction,
    effect_spec,
    {},
    opts
)

assert(
    not stack_apply.matches(
        adapter,
        instruction,
        effect_spec,
        {}
    ),
    "missing matcher dependencies must fail closed"
)
print("PASS stack effect apply: invalid dependencies fail closed")

print("PASS Tracker_HUD stack-effect apply smoke")
