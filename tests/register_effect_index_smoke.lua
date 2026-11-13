-- tests/register_effect_index_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_index_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local register_effect_index =
    require("tracker_hud.low_level.register_effect_index")

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

local legacy_mov = {
    node_type = "instruction",
    mnemonic = "MOV",
    tag = "legacy-mov",
    operands_ok = true,
    condition = {
        allow = true,
    },
}

local rejected_mov = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                text = "mov",
            },
        },
    },
    tag = "rejected-mov",
    operands_ok = true,
    condition = {
        allow = false,
    },
}

local legacy_add = {
    node_type = "instruction",
    mnemonic = "add",
    tag = "legacy-add",
    operands_ok = true,
    condition = {
        allow = true,
    },
}

local keyed_lea = {
    syntax = {
        node_type = "instruction",
    },
    tag = "keyed-lea",
    operands_ok = true,
    condition = {
        allow = true,
    },
}

local invalid = {
    mnemonic = "nop",
    tag = "invalid-no-node",
}

local register_effects = {
    legacy_mov,
    rejected_mov,
    legacy_add,
    invalid,

    lea = {
        keyed_lea,
    },
}

local opts = {
    get_node_type = get_node_type,
    get_mnemonic = get_mnemonic,
}

local index = register_effect_index.build(
    register_effects,
    opts
)

assert(index.node_types.instruction == true
    and index.by_node_type.instruction
    and #index.by_node_type.instruction.mov == 2
    and index.by_node_type.instruction.mov[1]
        == legacy_mov
    and index.by_node_type.instruction.mov[2]
        == rejected_mov
    and #index.by_node_type.instruction.add == 1
    and index.by_node_type.instruction.add[1]
        == legacy_add
    and #index.by_node_type.instruction.lea == 1
    and index.by_node_type.instruction.lea[1]
        == keyed_lea,
    "register effect index must preserve flat and mnemonic-indexed rules")
print("PASS register effect index: legacy and keyed rules preserved")

assert(index.by_node_type.instruction.__first
        == legacy_mov
    and index.by_node_type.instruction.nop
        == nil,
    "representative rule or invalid-rule filtering changed")
print("PASS register effect index: representative rule and invalid filtering preserved")

local adapter = {
    register_effects = register_effects,
}

local cached_a = register_effect_index.get(
    adapter,
    opts
)
local cached_b = register_effect_index.get(
    adapter,
    opts
)

assert(cached_a == cached_b
    and cached_a.by_node_type.instruction.mov[1]
        == legacy_mov,
    "register effect index cache identity changed")
print("PASS register effect index: adapter index cache preserved")

local function fake_node(node_type)
    return {
        type = function()
            return node_type
        end,
    }
end

local parse_count = 0
local representative_seen = nil

local instruction, matching =
    register_effect_index.match_node(
        cached_a,
        fake_node("instruction"),
        {
            parse_instruction = function(
                _node,
                representative_effect_spec
            )
                parse_count = parse_count + 1
                representative_seen =
                    representative_effect_spec

                return {
                    mnemonic = "MOV",
                    operands = {
                        {
                            kind = "register",
                            text = "rax",
                        },
                    },
                }
            end,

            operands_match = function(
                _instruction,
                effect_spec
            )
                return effect_spec.operands_ok
                    == true
            end,

            condition_match = function(
                _instruction,
                condition
            )
                return condition
                    and condition.allow
                    == true
            end,
        }
    )

assert(parse_count == 1
    and representative_seen == legacy_mov
    and instruction
    and instruction.mnemonic == "MOV"
    and #matching == 1
    and matching[1] == legacy_mov,
    "candidate selection must parse once and preserve operand/condition callbacks")
print("PASS register effect index: matching candidate selection preserved")

local unknown_instruction,
    unknown_matching =
    register_effect_index.match_node(
        cached_a,
        fake_node("unknown_node"),
        {
            parse_instruction = function()
                error("unknown node type must not parse")
            end,
            operands_match = function()
                return true
            end,
            condition_match = function()
                return true
            end,
        }
    )

assert(unknown_instruction == nil
    and #unknown_matching == 0,
    "unknown node type must fail closed before parsing")
print("PASS register effect index: unknown node types fail closed")

local parse_nil_instruction,
    parse_nil_matching =
    register_effect_index.match_node(
        cached_a,
        fake_node("instruction"),
        {
            parse_instruction = function()
                return nil
            end,
            operands_match = function()
                return true
            end,
            condition_match = function()
                return true
            end,
        }
    )

assert(parse_nil_instruction == nil
    and #parse_nil_matching == 0,
    "failed instruction parse must fail closed")
print("PASS register effect index: parse failures fail closed")

local empty = register_effect_index.build(
    register_effects,
    {}
)

assert(next(empty.node_types) == nil
    and next(empty.by_node_type) == nil,
    "missing syntax accessors must produce an empty index")

local missing_instruction,
    missing_matching =
    register_effect_index.match_node(
        cached_a,
        fake_node("instruction"),
        {}
    )

assert(missing_instruction == nil
    and #missing_matching == 0,
    "missing matcher dependencies must fail closed")
print("PASS register effect index: incomplete dependencies fail closed")

print("PASS Tracker_HUD register-effect index smoke")
