-- tests/boundary_effect_index_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/boundary_effect_index_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local boundary_effect_index =
    require("tracker_hud.low_level.boundary_effect_index")

local function get_node_type(effect_spec)
    return effect_spec
        and effect_spec.syntax
        and effect_spec.syntax.node_type
        or effect_spec
        and effect_spec.node_type
        or nil
end

local function get_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    local fields = effect_spec
        and effect_spec.syntax
        and effect_spec.syntax.fields
        or nil

    local kind = fields
        and fields.kind
        or nil

    return kind
        and (kind.text or kind.value)
        or effect_spec
        and effect_spec.mnemonic
        or fallback_mnemonic
end

local legacy_call = {
    node_type = "instruction",
    mnemonic = "CALL",
    tag = "legacy-call",
}

local legacy_ret = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                text = "ret",
            },
        },
    },
    tag = "legacy-ret",
}

local keyed_syscall = {
    syntax = {
        node_type = "instruction",
    },
    tag = "keyed-syscall",
}

local invalid = {
    mnemonic = "nop",
}

local boundary_effects = {
    legacy_call,
    legacy_ret,
    invalid,

    syscall = {
        keyed_syscall,
    },
}

local opts = {
    get_node_type = get_node_type,
    get_mnemonic = get_mnemonic,
}

local index =
    boundary_effect_index.build(
        boundary_effects,
        opts
    )

assert(index.node_types.instruction == true
    and index.by_node_type.instruction
    and #index.by_node_type.instruction.call == 1
    and index.by_node_type.instruction.call[1]
        == legacy_call
    and #index.by_node_type.instruction.ret == 1
    and index.by_node_type.instruction.ret[1]
        == legacy_ret
    and #index.by_node_type.instruction.syscall == 1
    and index.by_node_type.instruction.syscall[1]
        == keyed_syscall,
    "boundary effect index must preserve flat and keyed rules")
print("PASS boundary effect index: legacy and keyed rules preserved")

assert(index.by_node_type.instruction.__first
        == legacy_call
    and index.by_node_type.instruction.nop
        == nil,
    "boundary representative rule or invalid filtering changed")
print("PASS boundary effect index: representative rule and invalid filtering preserved")

local adapter = {
    boundary_effects =
        boundary_effects,
}

local cached_a =
    boundary_effect_index.get(
        adapter,
        opts
    )

local cached_b =
    boundary_effect_index.get(
        adapter,
        opts
    )

assert(cached_a == cached_b
    and cached_a.by_node_type.instruction.call[1]
        == legacy_call,
    "boundary effect index cache identity changed")
print("PASS boundary effect index: adapter cache preserved")

local empty =
    boundary_effect_index.build(
        boundary_effects,
        {}
    )

assert(next(empty.node_types) == nil
    and next(empty.by_node_type) == nil,
    "missing syntax accessors must produce empty boundary index")

local missing =
    boundary_effect_index.get(
        {},
        opts
    )

assert(next(missing.node_types) == nil
    and next(missing.by_node_type) == nil,
    "adapter without boundary effects must fail closed")
print("PASS boundary effect index: incomplete inputs fail closed")

print("PASS Tracker_HUD boundary-effect index smoke")
