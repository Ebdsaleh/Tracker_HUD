-- tests/effect_semantic_contract_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/effect_semantic_contract_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local contract = require("tracker_hud.adapters.contract")
local asm_source = require("tracker_hud.adapters.asm.init")

local function fresh_adapter()
    return vim.deepcopy(asm_source)
end

local function find_effect(adapter, effect_name)
    for _, rules in pairs(adapter.register_effects or {}) do
        for _, rule in ipairs(rules or {}) do
            if rule.effect and rule.effect.name == effect_name then
                return rule.effect
            end
        end
    end

    error("missing effect " .. tostring(effect_name))
end

local function expect_invalid(adapter, needle)
    local valid, err = contract.validate_adapter(adapter)
    assert(not valid, "malformed effect semantics unexpectedly validated")
    assert(type(err) == "string"
        and err:find(needle, 1, true),
        "validation error did not identify " .. needle
            .. ": " .. tostring(err))
end

local valid, err = contract.validate_adapter(fresh_adapter())
assert(valid, "current ASM adapter must satisfy semantic contract: " .. tostring(err))
print("PASS effect contract: current ASM semantic policies validate")

local bad_kind = fresh_adapter()
find_effect(
    bad_kind,
    "add_register_immediate"
).value_delta_operand_interpretation.kind = "signed_bit"
expect_invalid(bad_kind, "value_delta_operand_interpretation.kind")
print("PASS effect contract: unknown integer interpretation is rejected")

local bad_width = fresh_adapter()
find_effect(
    bad_width,
    "add_register_immediate"
).value_delta_operand_interpretation.max_bits = 0
expect_invalid(bad_width, "value_delta_operand_interpretation.max_bits")
print("PASS effect contract: invalid integer source width is rejected")

local missing_operand = fresh_adapter()
find_effect(
    missing_operand,
    "add_register_immediate"
).value_delta_operand = nil
expect_invalid(missing_operand, "value_delta_operand_interpretation")
print("PASS effect contract: interpretation requires its source operand")

local bad_width_policy = fresh_adapter()
find_effect(
    bad_width_policy,
    "inc_register"
).value_width_policy = "wrap_somehow"
expect_invalid(bad_width_policy, "value_width_policy")
print("PASS effect contract: unknown destination width policy is rejected")

local missing_target = fresh_adapter()
find_effect(
    missing_target,
    "inc_register"
).target_operand = nil
expect_invalid(missing_target, "value_width_policy")
print("PASS effect contract: target width policy requires a target")

local valid_exact = fresh_adapter()
find_effect(
    valid_exact,
    "mov_register_immediate"
).value_operand_interpretation = {
    kind = "exact",
}
local exact_valid, exact_err = contract.validate_adapter(valid_exact)
assert(exact_valid,
    "exact value-operand interpretation should be contract-valid: "
        .. tostring(exact_err))
print("PASS effect contract: exact value-operand policy is supported")

print("PASS Tracker_HUD effect semantic contract smoke")
