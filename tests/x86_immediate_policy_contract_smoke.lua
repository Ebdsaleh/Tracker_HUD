-- tests/x86_immediate_policy_contract_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/x86_immediate_policy_contract_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local arithmetic = require(
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.arithmetic"
)
local data_movement = require(
    "tracker_hud.adapters.asm.arch.x86_64.register_effects.integer.data_movement"
)

local expected = {
    add_register_immediate = true,
    sub_register_immediate = true,
}

local found = {}
local policy_count = 0

for mnemonic, rules in pairs(arithmetic) do
    assert(type(mnemonic) == "string", "arithmetic mnemonic key must be a string")
    assert(type(rules) == "table", "arithmetic mnemonic bucket must be a table")

    for _, rule in ipairs(rules) do
        local effect = rule.effect or {}
        local policy = effect.value_delta_operand_interpretation

        if policy ~= nil then
            policy_count = policy_count + 1

            assert(expected[effect.name] == true,
                "unexpected immediate interpretation policy on "
                    .. tostring(effect.name))
            assert(effect.value_delta_operand ~= nil,
                tostring(effect.name)
                    .. " declares delta-operand interpretation without a delta operand")
            assert(policy.kind == "signed_bits"
                and policy.bits_from == "target"
                and policy.max_bits == 32,
                tostring(effect.name)
                    .. " must use signed target-derived source width capped at 32 bits")

            found[effect.name] = true
        end
    end
end

for name, _ in pairs(expected) do
    assert(found[name], "missing immediate interpretation policy for " .. name)
end

assert(policy_count == 2,
    "only ADD/SUB reduced register-immediate effects should declare this policy")

local mov_policy
for _, rule in ipairs(data_movement.mov or {}) do
    local effect = rule.effect or {}
    if effect.name == "mov_register_immediate" then
        mov_policy = effect.value_operand_interpretation
        break
    end
end

assert(mov_policy == nil,
    "MOV immediate must not inherit arithmetic source interpretation")
print("PASS x86 immediate policy: ADD/SUB declare signed target-capped interpretation")
print("PASS x86 immediate policy: MOV remains outside arithmetic interpretation")
print("PASS Tracker_HUD x86 immediate-policy contract smoke")
