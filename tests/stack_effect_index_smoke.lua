-- tests/stack_effect_index_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/stack_effect_index_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local stack_effect_index =
    require("tracker_hud.low_level.stack_effect_index")

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

local legacy_push = {
    node_type = "instruction",
    mnemonic = "PUSH",
    tag = "legacy-push",
}

local legacy_pop = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                text = "pop",
            },
        },
    },
    tag = "legacy-pop",
}

local keyed_call = {
    syntax = {
        node_type = "instruction",
    },
    tag = "keyed-call",
}

local invalid = {
    mnemonic = "nop",
}

local stack_effects = {
    legacy_push,
    legacy_pop,
    invalid,

    call = {
        keyed_call,
    },
}

local opts = {
    get_node_type = get_node_type,
    get_mnemonic = get_mnemonic,
}

local index =
    stack_effect_index.build(
        stack_effects,
        opts
    )

assert(index.node_types.instruction == true
    and index.by_node_type.instruction
    and #index.by_node_type.instruction.push == 1
    and index.by_node_type.instruction.push[1]
        == legacy_push
    and #index.by_node_type.instruction.pop == 1
    and index.by_node_type.instruction.pop[1]
        == legacy_pop
    and #index.by_node_type.instruction.call == 1
    and index.by_node_type.instruction.call[1]
        == keyed_call,
    "stack effect index must preserve flat and keyed rules")
print("PASS stack effect index: legacy and keyed rules preserved")

assert(index.by_node_type.instruction.__first
        == legacy_push
    and index.by_node_type.instruction.nop
        == nil,
    "stack representative rule or invalid filtering changed")
print("PASS stack effect index: representative rule and invalid filtering preserved")

local adapter = {
    stack_effects =
        stack_effects,
}

local cached_a =
    stack_effect_index.get(
        adapter,
        opts
    )

local cached_b =
    stack_effect_index.get(
        adapter,
        opts
    )

assert(cached_a == cached_b
    and cached_a.by_node_type.instruction.push[1]
        == legacy_push,
    "stack effect index cache identity changed")
print("PASS stack effect index: adapter cache preserved")

local empty =
    stack_effect_index.build(
        stack_effects,
        {}
    )

assert(next(empty.node_types) == nil
    and next(empty.by_node_type) == nil,
    "missing syntax accessors must produce empty stack index")

local missing =
    stack_effect_index.get(
        {},
        opts
    )

assert(next(missing.node_types) == nil
    and next(missing.by_node_type) == nil,
    "adapter without stack effects must fail closed")
print("PASS stack effect index: incomplete inputs fail closed")

print("PASS Tracker_HUD stack-effect index smoke")
