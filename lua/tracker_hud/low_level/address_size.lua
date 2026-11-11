-- lua/tracker_hud/low_level/address_size.lua
--
-- Architecture-neutral address-size resolution.
--
-- Adapters declare how source register widths map to effective address widths.
-- This module does not know x86 register names or mode rules.

local M = {}

local function unknown(reason, details)
    return {
        status = "unknown",
        bits = nil,
        source = nil,
        reason = reason,
        details = details or {},
    }
end

local function known(bits, source, details)
    return {
        status = "known",
        bits = bits,
        source = source,
        reason = nil,
        details = details or {},
    }
end

local function allowed(policy, bits)
    if type(policy.allowed_bits) ~= "table" then
        return true
    end

    for _, allowed_bits in ipairs(policy.allowed_bits) do
        if allowed_bits == bits then
            return true
        end
    end

    return false
end

local function mapped_bits(policy, register_bits)
    local map = policy.register_width_map

    if type(map) ~= "table" then
        return register_bits
    end

    return map[register_bits]
        or map[tostring(register_bits)]
end

function M.resolve(policy, components, resolve_register_bits)
    if type(policy) ~= "table" then
        return unknown("address-size policy unavailable")
    end

    local observed = {}
    local observed_by_bits = {}

    for _, component in ipairs(components or {}) do
        local role = component.structural_role or component.role

        if component.kind == "register"
            and (
                role == "base_register"
                or role == "index_register"
            )
        then
            if type(resolve_register_bits) ~= "function" then
                return unknown("register-width resolver unavailable")
            end

            local register_bits = resolve_register_bits(
                component.text,
                component
            )

            if type(register_bits) ~= "number" then
                return unknown("address register width unavailable", {
                    register = component.text,
                })
            end

            local address_bits = mapped_bits(
                policy,
                register_bits
            )

            if type(address_bits) ~= "number"
                or not allowed(policy, address_bits)
            then
                return unknown("unsupported address register width", {
                    register = component.text,
                    register_bits = register_bits,
                })
            end

            observed[#observed + 1] = {
                register = component.text,
                register_bits = register_bits,
                address_bits = address_bits,
            }
            observed_by_bits[address_bits] = true
        end
    end

    local unique_bits = {}

    for bits, _ in pairs(observed_by_bits) do
        unique_bits[#unique_bits + 1] = bits
    end

    table.sort(unique_bits)

    if #unique_bits > 1 then
        return unknown("mixed address register widths", {
            address_bits = unique_bits,
            registers = observed,
        })
    end

    if #unique_bits == 1 then
        return known(unique_bits[1], "register_width", {
            registers = observed,
        })
    end

    local default_bits = policy.default_bits

    if type(default_bits) ~= "number"
        or not allowed(policy, default_bits)
    then
        return unknown("default address size unavailable")
    end

    return known(default_bits, "default", {
        registers = observed,
    })
end

return M
