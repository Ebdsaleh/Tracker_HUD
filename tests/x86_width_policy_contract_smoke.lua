-- tests/x86_width_policy_contract_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/x86_width_policy_contract_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local arithmetic = require(
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.arithmetic"
)

local expected = {
    add_register_immediate = true,
    sub_register_immediate = true,
    inc_register = true,
    dec_register = true,
    incb_writes_destination = true,
    incw_writes_destination = true,
    incl_writes_destination = true,
    incq_writes_destination = true,
    decb_writes_destination = true,
    decw_writes_destination = true,
    decl_writes_destination = true,
    decq_writes_destination = true,
}

local found = {}
local delta_count = 0
local policy_count = 0

for mnemonic, rules in pairs(arithmetic) do
    assert(type(mnemonic) == "string", "arithmetic mnemonic key must be a string")
    assert(type(rules) == "table", "arithmetic mnemonic bucket must be a table")

    for _, rule in ipairs(rules) do
        local effect = rule.effect or {}
        local has_delta = effect.value_delta ~= nil
            or effect.value_delta_operand ~= nil
        local has_policy = effect.value_width_policy ~= nil

        if has_delta then
            delta_count = delta_count + 1
            assert(effect.value_width_policy == "wrap_unsigned_target",
                tostring(effect.name)
                    .. " must declare target-width modular arithmetic")
            assert(expected[effect.name] == true,
                "unexpected delta effect in width-policy contract: "
                    .. tostring(effect.name))
            found[effect.name] = true
        end

        if has_policy then
            policy_count = policy_count + 1
            assert(has_delta,
                tostring(effect.name)
                    .. " declares width wrapping without a reduced arithmetic delta")
        end
    end
end

for effect_name, _ in pairs(expected) do
    assert(found[effect_name],
        "missing expected width-policy effect " .. effect_name)
end

assert(delta_count == 12,
    "expected exactly 12 currently reduced arithmetic delta effects")
assert(policy_count == delta_count,
    "every reduced arithmetic delta must have exactly one width policy")

print("PASS x86 width policy: all reduced delta effects declare target wrapping")
print("PASS x86 width policy: no non-delta arithmetic effect declares wrapping")
print("PASS Tracker_HUD x86 width-policy contract smoke")
