-- lua/tracker_hud/low_level/memory_address_evaluator.lua
--
-- Source-time memory effective-address coordination.
--
-- This module chooses between instruction-relative evidence and a replayed
-- pre-instruction register snapshot, then delegates arithmetic to the existing
-- relative/effective-address evaluators. It never claims execution.

local core = require("tracker_hud.core")
local effective_address =
    require("tracker_hud.low_level.effective_address")
local relative_address =
    require("tracker_hud.low_level.relative_address")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")

local M = {}


local function profile_name(
    deps,
    suffix
)
    local prefix =
        deps
        and deps.profile_prefix
        or "memory_address_evaluator"

    return prefix
        .. "."
        .. suffix
end


local function profile_begin(
    deps,
    suffix
)
    if type(deps) ~= "table"
        or type(deps.profile_begin)
            ~= "function"
    then
        return nil
    end

    return deps.profile_begin(
        profile_name(
            deps,
            suffix
        )
    )
end


local function profile_end(
    deps,
    suffix,
    started
)
    if type(deps) ~= "table"
        or type(deps.profile_end)
            ~= "function"
    then
        return nil
    end

    return deps.profile_end(
        profile_name(
            deps,
            suffix
        ),
        started
    )
end


local function unknown(reason)
    return {
        status = "unknown",
        value = nil,
        reason = reason,
    }
end


local function register_fact_map_from_list(facts)
    local result = {}

    for _, fact in ipairs(facts or {}) do
        if core.is_table(fact)
            and core.is_non_empty_string(
                fact.name
            )
        then
            result[fact.name:lower()] =
                fact

            local canonical =
                fact.metadata
                and fact.metadata
                    .canonical_name

            if core.is_non_empty_string(
                canonical
            )
            then
                result[
                    canonical:lower()
                ] = fact
            end
        end
    end

    return result
end


function M.evaluate(
    bufnr,
    root_node,
    adapter,
    instruction,
    address,
    machine_addresses,
    instruction_relative_policy,
    deps
)
    deps = deps or {}

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(address)
    then
        return unknown(
            "evaluation context unavailable"
        )
    end

    local line =
        instruction.source_start_line
        or instruction.source_line

    local column =
        instruction.source_start_column
        or instruction.source_column
        or 0

    if not core.is_number(line) then
        return unknown(
            "instruction position unavailable"
        )
    end

    local phase =
        profile_begin(
            deps,
            "relative_check"
        )

    local requires_next_instruction =
        relative_address.requires_next_instruction(
            address,
            {
                instruction_relative_policy =
                    instruction_relative_policy,
            }
        )

    profile_end(
        deps,
        "relative_check",
        phase
    )

    if requires_next_instruction
    then
        phase =
            profile_begin(
                deps,
                "relative_evaluate"
            )

        local result =
            relative_address.evaluate(
                address,
                machine_addresses,
                {
                    bits = adapter.metadata
                        and adapter.metadata.bits
                        or nil,
                    instruction_relative_policy =
                        instruction_relative_policy,
                }
            )

        profile_end(
            deps,
            "relative_evaluate",
            phase
        )

        return result
    end

    if type(
        deps.collect_register_effects_before
    ) ~= "function"
        and type(
            deps.collect_register_effects
        ) ~= "function"
    then
        return unknown(
            "register collection unavailable"
        )
    end

    local limit_position = {
        line = line,
        column = column,
    }

    local facts = nil

    phase =
        profile_begin(
            deps,
            "register_replay"
        )

    if type(
        deps.collect_register_effects_before
    ) == "function"
    then
        facts =
            deps.collect_register_effects_before(
                limit_position
            )
    else
        facts =
            deps.collect_register_effects(
                {
                    cursor = {
                        line = line,
                        column = column + 1,
                    },
                },
                adapter,
                {
                    bufnr = bufnr,
                    root_node = root_node,
                    limit_position =
                        limit_position,
                }
            )
    end

    profile_end(
        deps,
        "register_replay",
        phase
    )

    phase =
        profile_begin(
            deps,
            "fact_map"
        )

    local facts_by_register =
        register_fact_map_from_list(
            facts
        )

    profile_end(
        deps,
        "fact_map",
        phase
    )

    local bits =
        adapter.metadata
        and adapter.metadata.bits
        or nil

    phase =
        profile_begin(
            deps,
            "effective_address"
        )

    local result =
        effective_address.evaluate(
            address,
            {
                bits = bits,

                resolve_register = function(
                    register_name
                )
                    local fact =
                        register_state_read
                            .get_fact_for_read(
                                facts_by_register,
                                adapter,
                                register_name
                            )

                    if not register_state_read
                        .fact_is_resolved(
                            fact
                        )
                    then
                        local partial =
                            fact
                            and fact.metadata
                            and fact.metadata
                                .partial_value
                            or nil

                        return nil, {
                            status =
                                partial
                                and "partial"
                                or "unknown",
                            fact_name =
                                fact
                                and fact.name
                                or nil,
                            partial_value =
                                partial,
                        }
                    end

                    return fact.value, {
                        status = "known",
                        fact_name = fact.name,
                    }
                end,
            }
        )

    profile_end(
        deps,
        "effective_address",
        phase
    )

    return result
end


return M
