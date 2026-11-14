-- tests/boundary_effect_apply_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/boundary_effect_apply_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local boundary_apply =
    require("tracker_hud.low_level.boundary_effect_apply")

local adapter = {
    name = "asm",
    architecture = "x86-64",
    active_variant_name = "x86-64",
}

local instruction = {
    mnemonic = "syscall",
    source_line = 5,
}

local effect_spec = {
    mnemonic = "syscall",
    kind = "syscall",
    category = "system",
    reads = {},
    writes = {},
    not_preserved = {},
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
    boundary_apply.matches(
        instruction,
        effect_spec,
        opts
    ),
    "matching boundary instruction rejected"
)

assert(
    not boundary_apply.matches(
        {
            mnemonic = "int",
        },
        effect_spec,
        opts
    ),
    "mismatched boundary mnemonic accepted"
)
print("PASS boundary effect apply: mnemonic matching preserved")

local fact =
    boundary_apply.build(
        {},
        adapter,
        instruction,
        effect_spec,
        {}
    )

assert(
    fact
        and fact.kind == "syscall"
        and fact.category == "system"
        and fact.name == "syscall"
        and fact.source == "instruction"
        and fact.source_line == 5,
    "boundary fact construction changed"
)
print("PASS boundary effect apply: fact identity preserved")

assert(
    fact.metadata
        and fact.metadata.adapter == "asm"
        and fact.metadata.architecture
            == "x86-64"
        and fact.metadata.variant
            == "x86-64"
        and fact.metadata.mnemonic
            == "syscall"
        and fact.metadata.boundary_reads_state
            == "before_instruction"
        and fact.metadata.boundary_writes_state
            == "after_instruction",
    "boundary phase/adapter metadata changed"
)
print("PASS boundary effect apply: phase metadata preserved")

local facts = {}

boundary_apply.apply(
    facts,
    {},
    adapter,
    instruction,
    effect_spec,
    {},
    opts
)

assert(
    #facts == 1
        and facts[1].kind == "syscall",
    "matching boundary fact was not appended"
)

boundary_apply.apply(
    facts,
    {},
    adapter,
    {
        mnemonic = "int",
        source_line = 6,
    },
    effect_spec,
    {},
    opts
)

assert(
    #facts == 1,
    "mismatched boundary must not append"
)
print("PASS boundary effect apply: match-gated append preserved")

boundary_apply.apply(
    nil,
    {},
    adapter,
    instruction,
    effect_spec,
    {},
    opts
)

assert(
    not boundary_apply.matches(
        instruction,
        effect_spec,
        {}
    ),
    "missing matcher dependencies must fail closed"
)
print("PASS boundary effect apply: invalid dependencies fail closed")

print("PASS Tracker_HUD boundary-effect apply smoke")
