-- lua/tracker_hud/low_level/effective_address.lua
--
-- Architecture-neutral effective-address evaluation.
--
-- This module evaluates a normalized memory-address structure only from
-- proven numeric inputs supplied by the caller. It never reads process memory,
-- never claims execution, and never resolves symbols on its own.

local integer_value = require("tracker_hud.low_level.integer_value")

local M = {}

local function unknown(reason, details)
    return {
        status = "unknown",
        value = nil,
        reason = reason,
        details = details or {},
    }
end

local function known(value, bits, components, wrapped)
    return {
        status = "known",
        value = value,
        bits = bits,
        wrapped = wrapped == true,
        components = components,
    }
end

local function resolve_register(resolve_register, component, role)
    if not component then
        return "0", nil
    end

    if type(resolve_register) ~= "function" then
        return nil, {
            reason = "register resolver unavailable",
            role = role,
            register = component.name,
        }
    end

    local value, metadata = resolve_register(component.name, component, role)
    value = integer_value.normalize(value)

    if not value then
        return nil, {
            reason = "register value unresolved",
            role = role,
            register = component.name,
            metadata = metadata,
        }
    end

    return value, metadata
end

local function ambiguous_fields(address)
    local ambiguous = address
        and address.metadata
        and address.metadata.ambiguous
        or nil

    if type(ambiguous) ~= "table" then
        return nil
    end

    local fields = {}

    for key, value in pairs(ambiguous) do
        if value == true then
            fields[#fields + 1] = key
        end
    end

    table.sort(fields)

    return #fields > 0 and fields or nil
end

function M.evaluate(address, opts)
    opts = opts or {}

    if type(address) ~= "table" then
        return unknown("address structure unavailable")
    end

    local ambiguous = ambiguous_fields(address)
    if ambiguous then
        return unknown("address structure ambiguous", {
            fields = ambiguous,
        })
    end

    if address.address_size_status ~= nil
        and address.address_size_status ~= "known"
    then
        return unknown("address size unresolved", {
            reason = address.address_size_reason,
            details = address.address_size_details,
        })
    end

    if address.address_mode == "relative" then
        return unknown("relative address basis unresolved", {
            symbol = address.symbol and address.symbol.name or nil,
            address_mode = address.address_mode,
        })
    end

    if address.symbol ~= nil then
        return unknown("symbol address unresolved", {
            symbol = address.symbol.name,
            address_mode = address.address_mode,
        })
    end

    if address.scale and not address.index then
        return unknown("scale has no index register")
    end

    local base_value, base_metadata = resolve_register(
        opts.resolve_register,
        address.base,
        "base"
    )

    if not base_value then
        return unknown("base register unresolved", base_metadata)
    end

    local index_value, index_metadata = resolve_register(
        opts.resolve_register,
        address.index,
        "index"
    )

    if not index_value then
        return unknown("index register unresolved", index_metadata)
    end

    local scale_value = "1"

    if address.scale then
        scale_value = integer_value.normalize(address.scale.value)

        if not scale_value then
            return unknown("scale unresolved", {
                text = address.scale.text,
            })
        end
    end

    local displacement_value = "0"

    if address.displacement then
        displacement_value = integer_value.normalize(
            address.displacement.value
        )

        if not displacement_value then
            return unknown("displacement unresolved", {
                text = address.displacement.text,
            })
        end
    end

    local scaled_index = integer_value.multiply(
        index_value,
        scale_value
    )

    if not scaled_index then
        return unknown("scaled index arithmetic failed")
    end

    local exact = integer_value.add(
        integer_value.add(base_value, scaled_index),
        displacement_value
    )

    if not exact then
        return unknown("effective address arithmetic failed")
    end

    local bits = address.address_size_bits
        or opts.bits
    local final_value = exact
    local wrapped = false

    if bits ~= nil then
        final_value = integer_value.wrap_unsigned(exact, bits)

        if not final_value then
            return unknown("address width invalid", {
                bits = bits,
                exact = exact,
            })
        end

        wrapped = final_value ~= exact
    end

    return known(
        final_value,
        bits,
        {
            base = address.base and {
                name = address.base.name,
                value = base_value,
                metadata = base_metadata,
            } or nil,
            index = address.index and {
                name = address.index.name,
                value = index_value,
                metadata = index_metadata,
            } or nil,
            scale = scale_value,
            displacement = displacement_value,
            exact = exact,
        },
        wrapped
    )
end

return M
