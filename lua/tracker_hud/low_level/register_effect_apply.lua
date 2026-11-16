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


local function profile_name(
    opts,
    suffix
)
    local prefix =
        opts
        and opts.profile_prefix
        or "register_effect_apply"

    return prefix
        .. "."
        .. suffix
end


local function profile_begin(
    opts,
    suffix
)
    if type(opts) ~= "table"
        or type(opts.profile_begin)
            ~= "function"
    then
        return nil
    end

    return opts.profile_begin(
        profile_name(
            opts,
            suffix
        )
    )
end


local function profile_end(
    opts,
    suffix,
    started
)
    if type(opts) ~= "table"
        or type(opts.profile_end)
            ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        profile_name(
            opts,
            suffix
        ),
        started
    )
end


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
    instruction_state,
    opts
)
    return register_fact_builder.build(
        facts_by_register,
        family_state,
        adapter,
        instruction,
        effect_spec,
        instruction_state,
        opts
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

    local phase =
        profile_begin(
            opts,
            "match"
        )

    local matched =
        M.matches(
            instruction,
            effect_spec,
            opts
        )

    profile_end(
        opts,
        "match",
        phase
    )

    if not matched then
        return
    end

    phase =
        profile_begin(
            opts,
            "build"
        )

    local fact =
        M.build(
            facts_by_register,
            family_state,
            adapter,
            instruction,
            effect_spec,
            instruction_state,
            opts
        )

    profile_end(
        opts,
        "build",
        phase
    )

    if fact then
        phase =
            profile_begin(
                opts,
                "publish"
            )

        register_state_write.publish(
            facts_by_register,
            family_state,
            latest_state_facts,
            adapter,
            fact
        )

        profile_end(
            opts,
            "publish",
            phase
        )
    end
end


return M
