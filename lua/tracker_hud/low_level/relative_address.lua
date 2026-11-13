-- lua/tracker_hud/low_level/relative_address.lua
--
-- Certainty-aware explicit relative-address evaluation.
--
-- This layer consumes only normalized source structure plus proven machine-
-- address evidence. Source locations are never treated as addresses.
--
-- Version 1 intentionally resolves explicit relative symbols only. Register-
-- based instruction-relative forms (for example RIP/EIP bases) remain a
-- separate adapter-policy tranche.

local integer_value = require("tracker_hud.low_level.integer_value")

local M = {}

local function unknown(reason, details)
    return {
        status = "unknown",
        value = nil,
        bits = nil,
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

local function exact_evidence(evidence)
    if type(evidence) ~= "table"
        or evidence.status ~= "known"
    then
        return nil
    end

    return integer_value.normalize(evidence.value)
end

local function evidence_bits(evidence)
    if type(evidence) == "table"
        and type(evidence.bits) == "number"
    then
        return evidence.bits
    end

    return nil
end

function M.evaluate(address, machine_addresses, opts)
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

    if address.address_mode ~= "relative" then
        return unknown("address is not explicit relative", {
            address_mode = address.address_mode,
        })
    end

    if type(address.symbol) ~= "table"
        or type(address.symbol.name) ~= "string"
        or address.symbol.name == ""
    then
        return unknown("relative symbol unavailable", {
            address_mode = address.address_mode,
        })
    end

    if type(machine_addresses) ~= "table" then
        return unknown("machine-address evidence unavailable", {
            symbol = address.symbol.name,
        })
    end

    local next_instruction =
        machine_addresses.next_instruction
    local symbol_evidence =
        machine_addresses.symbol

    local basis_value =
        exact_evidence(next_instruction)

    if not basis_value then
        return unknown(
            "next-instruction machine address unresolved",
            {
                symbol = address.symbol.name,
                evidence_status = type(next_instruction) == "table"
                    and next_instruction.status
                    or nil,
                evidence_reason = type(next_instruction) == "table"
                    and next_instruction.reason
                    or nil,
            }
        )
    end

    local symbol_value =
        exact_evidence(symbol_evidence)

    if not symbol_value then
        return unknown(
            "symbol machine address unresolved",
            {
                symbol = address.symbol.name,
                evidence_status = type(symbol_evidence) == "table"
                    and symbol_evidence.status
                    or nil,
                evidence_reason = type(symbol_evidence) == "table"
                    and symbol_evidence.reason
                    or nil,
            }
        )
    end

    local basis_bits =
        evidence_bits(next_instruction)
    local symbol_bits =
        evidence_bits(symbol_evidence)

    if basis_bits ~= nil
        and symbol_bits ~= nil
        and basis_bits ~= symbol_bits
    then
        return unknown("machine address width mismatch", {
            next_instruction_bits = basis_bits,
            symbol_bits = symbol_bits,
        })
    end

    local bits = symbol_bits
        or basis_bits
        or opts.bits

    local source_displacement = "0"

    if address.displacement ~= nil then
        source_displacement =
            integer_value.normalize(
                address.displacement.value
            )

        if not source_displacement then
            return unknown("relative displacement unresolved", {
                text = address.displacement.text,
            })
        end
    end

    if address.base ~= nil
        or address.index ~= nil
        or address.scale ~= nil
    then
        return unknown(
            "explicit relative address has unsupported register components",
            {
                has_base = address.base ~= nil,
                has_index = address.index ~= nil,
                has_scale = address.scale ~= nil,
            }
        )
    end

    local exact_target = integer_value.add(
        symbol_value,
        source_displacement
    )

    if not exact_target then
        return unknown("relative target arithmetic failed")
    end

    local target_value = exact_target
    local wrapped = false

    if bits ~= nil then
        target_value = integer_value.wrap_unsigned(
            exact_target,
            bits
        )

        if not target_value then
            return unknown("machine address width invalid", {
                bits = bits,
                exact = exact_target,
            })
        end

        wrapped = target_value ~= exact_target
    end

    local relative_delta = integer_value.add(
        target_value,
        integer_value.negate(basis_value)
    )

    if not relative_delta then
        return unknown("relative delta arithmetic failed")
    end

    return known(
        target_value,
        bits,
        {
            basis = {
                kind = "next_instruction",
                value = basis_value,
                bits = basis_bits,
            },
            symbol = {
                name = address.symbol.name,
                value = symbol_value,
                bits = symbol_bits,
            },
            source_displacement = source_displacement,
            relative_delta = relative_delta,
            exact_target = exact_target,
        },
        wrapped
    )
end

return M
