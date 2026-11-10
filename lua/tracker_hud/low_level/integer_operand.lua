-- lua/tracker_hud/low_level/integer_operand.lua
--
-- Architecture-neutral interpretation of exact integer source operands.
--
-- The source text is first normalized by integer_value. A declarative policy
-- then decides how that exact integer is interpreted before instruction
-- semantics consume it. Register-width ownership remains outside this module:
-- callers provide target_bits when a policy derives width from the target.

local integer_value = require("tracker_hud.low_level.integer_value")

local M = {}

local function positive_integer(value)
    return type(value) == "number"
        and value == math.floor(value)
        and value >= 1
end

local function resolve_bits(spec, context)
    spec = spec or {}
    context = context or {}

    local has_fixed_bits = spec.bits ~= nil
    local has_derived_bits = spec.bits_from ~= nil

    if has_fixed_bits == has_derived_bits then
        return nil, nil, "source width policy is ambiguous"
    end

    local bits
    local bits_source

    if has_fixed_bits then
        if not positive_integer(spec.bits) then
            return nil, nil, "invalid fixed source width"
        end

        bits = spec.bits
        bits_source = "fixed"
    else
        if spec.bits_from ~= "target" then
            return nil, nil, "unsupported source width derivation"
        end

        if not positive_integer(context.target_bits) then
            return nil, nil, "source width unavailable"
        end

        bits = context.target_bits
        bits_source = "target"
    end

    if spec.max_bits ~= nil then
        if not positive_integer(spec.max_bits) then
            return nil, nil, "invalid maximum source width"
        end

        if bits > spec.max_bits then
            bits = spec.max_bits
            bits_source = bits_source .. "_capped"
        end
    end

    if spec.min_bits ~= nil then
        if not positive_integer(spec.min_bits) then
            return nil, nil, "invalid minimum source width"
        end

        if bits < spec.min_bits then
            bits = spec.min_bits
            bits_source = bits_source .. "_floored"
        end
    end

    if spec.max_bits ~= nil
        and spec.min_bits ~= nil
        and spec.min_bits > spec.max_bits
    then
        return nil, nil, "minimum source width exceeds maximum"
    end

    return bits, bits_source, nil
end

function M.interpret(value, spec, context)
    spec = spec or {}
    context = context or {}

    local raw = integer_value.normalize(value)
    local metadata = {
        interpretation = spec.kind,
        raw_value = raw,
        value = nil,
        bits = nil,
        bits_source = nil,
        max_bits = spec.max_bits,
        min_bits = spec.min_bits,
        error = nil,
    }

    if not raw then
        metadata.error = "value is not an exact integer"
        return nil, metadata
    end

    if spec.kind == nil or spec.kind == "exact" then
        if spec.kind == "exact"
            and (
                spec.bits ~= nil
                or spec.bits_from ~= nil
                or spec.max_bits ~= nil
                or spec.min_bits ~= nil
            )
        then
            metadata.interpretation = "exact"
            metadata.error = "exact interpretation does not use source width"
            return nil, metadata
        end

        metadata.interpretation = spec.kind or "exact"
        metadata.value = raw
        return raw, metadata
    end

    if spec.kind ~= "signed_bits"
        and spec.kind ~= "unsigned_bits"
    then
        metadata.error = "unsupported integer interpretation"
        return nil, metadata
    end

    local bits, bits_source, bits_error = resolve_bits(spec, context)
    metadata.bits = bits
    metadata.bits_source = bits_source

    if bits_error then
        metadata.error = bits_error
        return nil, metadata
    end

    local interpreted

    if spec.kind == "signed_bits" then
        interpreted = integer_value.reinterpret_signed(raw, bits)
    else
        interpreted = integer_value.normalize_unsigned(raw, bits)
    end

    if interpreted == nil then
        metadata.error = "value does not fit source width"
        return nil, metadata
    end

    metadata.value = interpreted
    return interpreted, metadata
end

return M
