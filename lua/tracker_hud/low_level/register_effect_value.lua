-- lua/tracker_hud/low_level/register_effect_value.lua
--
-- Register-effect value resolution.
--
-- This module decides where a register write value comes from and performs
-- exact arithmetic/read-only lookup. It does not construct facts or mutate
-- register state.

local core = require("tracker_hud.core")
local integer_value =
    require("tracker_hud.low_level.integer_value")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")
local register_value_policy =
    require("tracker_hud.low_level.register_value_policy")

local M = {}


local function profile_name(
    opts,
    suffix
)
    local prefix =
        opts
        and opts.profile_prefix
        or "register_effect_value"

    return prefix
        .. ".build.resolve_value."
        .. suffix
end


local function profile_begin(
    opts,
    suffix
)
    if type(opts) ~= "table"
        or type(opts.profile_begin) ~= "function"
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
        or type(opts.profile_end) ~= "function"
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


function M.resolve(
    facts_by_register,
    instruction,
    effect,
    instruction_state,
    adapter,
    target_register,
    opts
)
    opts = opts or {}

    local value = effect.value
    local resolved =
        value ~= nil

    if effect.value_from_stack_top
            == true
        or effect.value_from_stack
            == "top"
    then
        local phase =
            profile_begin(
                opts,
                "stack"
            )

        local stack_value =
            core.is_table(
                instruction_state
            )
            and instruction_state
                .stack_pop
            or nil

        if core.is_table(
            stack_value
        )
        then
            profile_end(
                opts,
                "stack",
                phase
            )
            return stack_value.value,
                stack_value.resolved
                    ~= false
        end

        profile_end(
            opts,
            "stack",
            phase
        )
        return nil, false
    end

    if core.is_non_empty_string(
        effect.value_from_register
    )
    then
        local phase =
            profile_begin(
                opts,
                "register"
            )

        local source_fact =
            register_state_read
                .get_fact_for_read(
                    facts_by_register,
                    adapter,
                    effect
                        .value_from_register
                )

        if register_state_read
            .fact_is_resolved(
                source_fact
            )
        then
            profile_end(
                opts,
                "register",
                phase
            )
            return source_fact.value,
                true
        end

        profile_end(
            opts,
            "register",
            phase
        )
        return effect
            .value_from_register,
            false
    end

    if tonumber(
        effect
            .value_from_register_operand
    )
    then
        local phase =
            profile_begin(
                opts,
                "register_operand"
            )

        local source_operand =
            instruction.operands[
                tonumber(
                    effect
                        .value_from_register_operand
                )
            ]

        if source_operand
            and core.is_non_empty_string(
                source_operand.text
            )
        then
            local source_fact =
                register_state_read
                    .get_fact_for_read(
                        facts_by_register,
                        adapter,
                        source_operand.text
                    )

            if register_state_read
                .fact_is_resolved(
                    source_fact
                )
            then
                profile_end(
                    opts,
                    "register_operand",
                    phase
                )
                return source_fact.value,
                    true
            end

            profile_end(
                opts,
                "register_operand",
                phase
            )
            return source_operand.text,
                false
        end

        profile_end(
            opts,
            "register_operand",
            phase
        )
    end

    if tonumber(
        effect.value_delta_operand
    )
        or effect.value_delta ~= nil
    then
        local delta_phase =
            profile_begin(
                opts,
                "delta"
            )

        local phase =
            profile_begin(
                opts,
                "delta.target_read"
            )

        local target_operand = nil
        local delta_target_register =
            effect.target_register

        if tonumber(
            effect.target_operand
        )
        then
            target_operand =
                instruction.operands[
                    tonumber(
                        effect.target_operand
                    )
                ]

            if target_operand then
                delta_target_register =
                    target_operand.text
            end
        end

        local target_fact =
            delta_target_register
            and register_state_read
                .get_fact_for_read(
                    facts_by_register,
                    adapter,
                    delta_target_register
                )

        profile_end(
            opts,
            "delta.target_read",
            phase
        )

        if not register_state_read
            .fact_is_resolved(
                target_fact
            )
        then
            profile_end(
                opts,
                "delta",
                delta_phase
            )
            return nil, false
        end

        phase =
            profile_begin(
                opts,
                "delta.parse_current"
            )

        local current_value =
            register_value_policy
                .parse_numeric_value(
                    target_fact.value
                )

        profile_end(
            opts,
            "delta.parse_current",
            phase
        )

        if not current_value then
            profile_end(
                opts,
                "delta",
                delta_phase
            )
            return nil, false
        end

        local total_delta = "0"
        local has_delta = false

        if effect.value_delta
            ~= nil
        then
            phase =
                profile_begin(
                    opts,
                    "delta.fixed"
                )

            local fixed_delta =
                register_value_policy
                    .parse_numeric_value(
                        effect.value_delta
                    )

            if not fixed_delta then
                profile_end(
                    opts,
                    "delta.fixed",
                    phase
                )
                profile_end(
                    opts,
                    "delta",
                    delta_phase
                )
                return nil, false
            end

            total_delta =
                integer_value.add(
                    total_delta,
                    fixed_delta
                )

            has_delta =
                total_delta ~= nil

            profile_end(
                opts,
                "delta.fixed",
                phase
            )
        end

        local source_integer_metadata =
            nil

        if tonumber(
            effect.value_delta_operand
        )
        then
            phase =
                profile_begin(
                    opts,
                    "delta.operand"
                )

            local delta_operand =
                instruction.operands[
                    tonumber(
                        effect
                            .value_delta_operand
                    )
                ]

            if delta_operand
                and delta_operand.text
                    ~= nil
            then
                local operand_delta
                local operand_resolved

                operand_delta,
                    operand_resolved,
                    source_integer_metadata =
                    register_value_policy
                        .interpret_integer_operand(
                            adapter,
                            delta_target_register,
                            delta_operand.text,
                            effect
                                .value_delta_operand_interpretation
                        )

                if not operand_resolved
                    or not operand_delta
                then
                    profile_end(
                        opts,
                        "delta.operand",
                        phase
                    )
                    profile_end(
                        opts,
                        "delta",
                        delta_phase
                    )
                    return nil,
                        false,
                        source_integer_metadata
                end

                total_delta =
                    integer_value.add(
                        total_delta,
                        operand_delta
                    )

                has_delta =
                    total_delta ~= nil

                profile_end(
                    opts,
                    "delta.operand",
                    phase
                )
            elseif effect.value_delta
                == nil
            then
                profile_end(
                    opts,
                    "delta.operand",
                    phase
                )
                profile_end(
                    opts,
                    "delta",
                    delta_phase
                )
                return nil, false
            else
                profile_end(
                    opts,
                    "delta.operand",
                    phase
                )
            end
        end

        if not has_delta
            or not total_delta
        then
            profile_end(
                opts,
                "delta",
                delta_phase
            )
            return nil, false
        end

        phase =
            profile_begin(
                opts,
                "delta.arithmetic"
            )

        local sign =
            tonumber(
                effect.value_delta_sign
            )
            or 1

        if sign == -1 then
            total_delta =
                integer_value.negate(
                    total_delta
                )
        elseif sign ~= 1 then
            profile_end(
                opts,
                "delta.arithmetic",
                phase
            )
            profile_end(
                opts,
                "delta",
                delta_phase
            )
            return nil, false
        end

        local result =
            integer_value.add(
                current_value,
                total_delta
            )

        profile_end(
            opts,
            "delta.arithmetic",
            phase
        )
        profile_end(
            opts,
            "delta",
            delta_phase
        )

        return result,
            result ~= nil,
            source_integer_metadata
    end

    if value == nil
        and tonumber(
            effect.value_operand
        )
    then
        local value_phase =
            profile_begin(
                opts,
                "value_operand"
            )

        local value_operand =
            instruction.operands[
                tonumber(
                    effect.value_operand
                )
            ]

        if value_operand then
            value =
                value_operand.text

            if value_operand.kind
                == "register"
            then
                local phase =
                    profile_begin(
                        opts,
                        "value_operand.register"
                    )

                local source_fact =
                    register_state_read
                        .get_fact_for_read(
                            facts_by_register,
                            adapter,
                            value_operand.text
                        )

                resolved =
                    register_state_read
                        .fact_is_resolved(
                            source_fact
                        )

                if resolved then
                    value =
                        source_fact.value
                end

                profile_end(
                    opts,
                    "value_operand.register",
                    phase
                )
            elseif value_operand.kind
                == "integer"
            then
                local phase =
                    profile_begin(
                        opts,
                        "value_operand.integer"
                    )

                local source_integer_metadata

                value,
                    resolved,
                    source_integer_metadata =
                    register_value_policy
                        .interpret_integer_operand(
                            adapter,
                            target_register,
                            value_operand.text,
                            effect
                                .value_operand_interpretation
                        )

                profile_end(
                    opts,
                    "value_operand.integer",
                    phase
                )
                profile_end(
                    opts,
                    "value_operand",
                    value_phase
                )

                return value,
                    resolved,
                    source_integer_metadata
            else
                resolved =
                    value ~= nil
            end
        end

        profile_end(
            opts,
            "value_operand",
            value_phase
        )
    end

    local phase =
        profile_begin(
            opts,
            "literal_or_fallback"
        )

    profile_end(
        opts,
        "literal_or_fallback",
        phase
    )

    return value, resolved
end


return M
