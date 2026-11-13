-- lua/tracker_hud/low_level/register_value_policy.lua
--
-- Register value-width and source-integer interpretation policy.
--
-- This module owns pure value transformation and metadata shaping. It does
-- not read or mutate register state beyond querying target width.

local core = require("tracker_hud.core")
local integer_value =
    require("tracker_hud.low_level.integer_value")
local integer_operand =
    require("tracker_hud.low_level.integer_operand")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")

local M = {}


function M.apply_width_policy(
    adapter,
    target_register,
    effect,
    value,
    resolved
)
    local policy =
        core.is_table(effect)
        and effect.value_width_policy
        or nil

    if policy == nil then
        return value, resolved, nil
    end

    local metadata = {
        value_width_policy = policy,
        pre_width_write_value = value,
    }

    if resolved == false
        or value == nil
    then
        return value,
            resolved,
            metadata
    end

    if policy
        ~= "wrap_unsigned_target"
    then
        metadata.value_width_error =
            "unsupported policy"

        return nil,
            false,
            metadata
    end

    local bits =
        register_state_read
            .get_value_width(
                adapter,
                target_register
            )

    metadata.value_width_bits =
        bits

    if not bits then
        metadata.value_width_error =
            "target width unavailable"

        return nil,
            false,
            metadata
    end

    local wrapped =
        integer_value.wrap_unsigned(
            value,
            bits
        )

    if wrapped == nil then
        metadata.value_width_error =
            "value is not an exact integer"

        return nil,
            false,
            metadata
    end

    local normalized =
        integer_value.normalize(value)

    metadata.value_wrapped =
        normalized ~= wrapped

    return wrapped,
        true,
        metadata
end


function M.parse_numeric_value(value)
    return integer_value.normalize(value)
end


function M.parse_numeric_number(value)
    return integer_value.to_safe_number(
        value
    )
end


function M.build_integer_operand_metadata(
    metadata
)
    if not core.is_table(metadata) then
        return nil
    end

    return {
        source_integer_interpretation =
            metadata.interpretation,

        source_integer_bits =
            metadata.bits,

        source_integer_bits_source =
            metadata.bits_source,

        source_integer_max_bits =
            metadata.max_bits,

        source_integer_min_bits =
            metadata.min_bits,

        source_integer_raw_value =
            metadata.raw_value,

        source_integer_value =
            metadata.value,

        source_integer_error =
            metadata.error,
    }
end


function M.interpret_integer_operand(
    adapter,
    target_register,
    value,
    policy
)
    if not core.is_table(policy) then
        local normalized =
            M.parse_numeric_value(
                value
            )

        return normalized,
            normalized ~= nil,
            nil
    end

    local interpreted,
        metadata =
        integer_operand.interpret(
            value,
            policy,
            {
                target_bits =
                    register_state_read
                        .get_value_width(
                            adapter,
                            target_register
                        ),
            }
        )

    return interpreted,
        interpreted ~= nil,
        M.build_integer_operand_metadata(
            metadata
        )
end


return M
