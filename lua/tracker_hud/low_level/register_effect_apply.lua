-- lua/tracker_hud/low_level/register_effect_apply.lua
--
-- Register-effect matching, fact construction, and publication.
--
-- Syntax-derived mnemonic policy is injected by the caller. Register value
-- resolution, fact construction, alias composition, and state publication
-- remain owned by their existing register modules.

local core = require("tracker_hud.core")
local effect_match =
    require("tracker_hud.low_level.effect_match")
local register_fact_builder =
    require("tracker_hud.low_level.register_fact_builder")
local register_state_write =
    require("tracker_hud.low_level.register_state_write")

local M = {}


function M.matches(
    instruction,
    effect_spec,
    opts
)
    opts = opts or {}

    if not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or type(opts.get_mnemonic)
            ~= "function"
        or type(opts.normalize_mnemonic)
            ~= "function"
    then
        return false
    end

    local expected_mnemonic =
        opts.get_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and opts.normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return false
    end

    if not effect_match
        .operands_match_effect(
            instruction,
            effect_spec
        )
    then
        return false
    end

    if not effect_match.condition_matches(
        instruction,
        effect_spec.condition
    )
    then
        return false
    end

    return true
end


function M.build(
    facts_by_register,
    family_state,
    adapter,
    instruction,
    effect_spec,
    instruction_state
)
    return register_fact_builder.build(
        facts_by_register,
        family_state,
        adapter,
        instruction,
        effect_spec,
        instruction_state
    )
end


function M.apply(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    instruction,
    effect_spec,
    instruction_state,
    opts
)
    opts = opts or {}

    if not core.is_table(facts_by_register)
        or not core.is_table(family_state)
        or not core.is_table(latest_state_facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if not M.matches(
        instruction,
        effect_spec,
        opts
    )
    then
        return
    end

    local fact =
        M.build(
            facts_by_register,
            family_state,
            adapter,
            instruction,
            effect_spec,
            instruction_state
        )

    if fact then
        register_state_write.publish(
            facts_by_register,
            family_state,
            latest_state_facts,
            adapter,
            fact
        )
    end
end


return M
