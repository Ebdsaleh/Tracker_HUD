-- tests/register_effect_apply_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_apply_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local register_apply =
    require("tracker_hud.low_level.register_effect_apply")

local adapter = {
    name = "test",
    architecture = "test-64",
    active_variant_name = "test-64",
    registers = {
        static = {
            {
                name = "rax",
                bits = 64,
                kind = "integer",
                role = "general",
            },
        },
    },
}

local instruction = {
    mnemonic = "mov",
    source_line = 4,
    source_column = 0,
    operands = {},
}

local effect_spec = {
    mnemonic = "mov",
    operands = {},
    effect = {
        name = "set_rax",
        kind = "register_write",
        target_register = "rax",
        value = "7",
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
    register_apply.matches(
        instruction,
        effect_spec,
        opts
    ),
    "matching register instruction rejected"
)

assert(
    not register_apply.matches(
        {
            mnemonic = "inc",
            operands = {},
        },
        effect_spec,
        opts
    ),
    "mismatched register mnemonic accepted"
)

local operand_spec = {
    mnemonic = "mov",
    operands = {
        {
            index = 1,
            kind = "register",
        },
    },
    effect = effect_spec.effect,
}

assert(
    not register_apply.matches(
        instruction,
        operand_spec,
        opts
    ),
    "missing required register operand accepted"
)
print("PASS register effect apply: mnemonic and operand matching preserved")

local facts_by_register = {}
local family_state = {}
local latest_state_facts = {}

register_apply.apply(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    instruction,
    effect_spec,
    {},
    opts
)

assert(
    facts_by_register.rax
        and tostring(
            facts_by_register.rax.value
        ) == "7"
        and facts_by_register.rax.resolved
            == true
        and family_state.rax
        and latest_state_facts.rax,
    "matching register fact was not published"
)
print("PASS register effect apply: build and publication preserved")

local before = latest_state_facts.rax

register_apply.apply(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    {
        mnemonic = "inc",
        operands = {},
    },
    effect_spec,
    {},
    opts
)

assert(
    latest_state_facts.rax == before,
    "mismatched register effect changed state"
)
print("PASS register effect apply: match-gated publication preserved")

register_apply.apply(
    nil,
    family_state,
    latest_state_facts,
    adapter,
    instruction,
    effect_spec,
    {},
    opts
)

assert(
    not register_apply.matches(
        instruction,
        effect_spec,
        {}
    ),
    "missing matcher dependencies must fail closed"
)
print("PASS register effect apply: invalid dependencies fail closed")

print("PASS Tracker_HUD register-effect apply smoke")
