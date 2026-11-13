-- lua/tracker_hud/low_level/relative_address.lua
--
-- Certainty-aware instruction-relative address evaluation.
--
-- This layer consumes only normalized source structure plus proven machine-
-- address evidence. Source locations are never treated as addresses.
--
-- Architecture adapters declare register-based instruction-relative forms.
-- Explicit source modes such as REL remain architecture-neutral syntax facts.

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

local function get_instruction_relative_base(address, policy)
    if type(address) ~= "table"
        or type(address.base) ~= "table"
        or type(address.base.name) ~= "string"
        or address.base.name == ""
        or type(policy) ~= "table"
        or type(policy.bases) ~= "table"
    then
        return nil, nil
    end

    local name = address.base.name:lower()
    local base_spec = policy.bases[name]

    if type(base_spec) ~= "table" then
        return nil, nil
    end

    return address.base, base_spec
end

local function source_displacement(address)
    if address.displacement == nil then
        return "0", nil
    end

    local value = integer_value.normalize(
        address.displacement.value
    )

    if not value then
        return nil, unknown(
            "relative displacement unresolved",
            {
                text = address.displacement.text,
            }
        )
    end

    return value, nil
end

local function wrap_target(exact_target, bits)
    if bits == nil then
        return exact_target, false, nil
    end

    local value = integer_value.wrap_unsigned(
        exact_target,
        bits
    )

    if not value then
        return nil, false, unknown(
            "machine address width invalid",
            {
                bits = bits,
                exact = exact_target,
            }
        )
    end

    return value, value ~= exact_target, nil
end

local function result_bits_for_base(
    address,
    basis_bits,
    opts,
    base_spec
)
    local width = base_spec.result_width

    if width == "address_size" then
        return address.address_size_bits
            or opts.bits
            or basis_bits
    end

    if width == "machine" or width == nil then
        return basis_bits
            or opts.bits
            or address.address_size_bits
    end

    if type(width) == "number" then
        return width
    end

    return nil
end

function M.requires_next_instruction(address, opts)
    opts = opts or {}

    if type(address) ~= "table" then
        return false
    end

    if address.address_mode == "relative" then
        return true
    end

    local _, base_spec =
        get_instruction_relative_base(
            address,
            opts.instruction_relative_policy
        )

    if not base_spec then
        return false
    end

    return (base_spec.basis or "next_instruction")
        == "next_instruction"
end

local function evaluate_explicit_relative(
    address,
    machine_addresses,
    opts
)
    if type(address.symbol) ~= "table"
        or type(address.symbol.name) ~= "string"
        or address.symbol.name == ""
    then
        return unknown("relative symbol unavailable", {
            address_mode = address.address_mode,
        })
    end

    if type(machine_addresses) ~= "table" then
        return unknown("relative address basis unresolved", {
            symbol = address.symbol.name,
            address_mode = address.address_mode,
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

    local displacement, displacement_error =
        source_displacement(address)

    if displacement_error then
        return displacement_error
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
        displacement
    )

    if not exact_target then
        return unknown("relative target arithmetic failed")
    end

    local bits = symbol_bits
        or basis_bits
        or opts.bits

    local target_value,
        wrapped,
        wrap_error = wrap_target(
            exact_target,
            bits
        )

    if wrap_error then
        return wrap_error
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
            source_displacement = displacement,
            relative_delta = relative_delta,
            exact_target = exact_target,
        },
        wrapped
    )
end

local function evaluate_register_relative(
    address,
    machine_addresses,
    opts,
    base,
    base_spec
)
    if (base_spec.basis or "next_instruction")
        ~= "next_instruction"
    then
        return unknown(
            "unsupported instruction-relative basis",
            {
                base = base.name,
                basis = base_spec.basis,
            }
        )
    end

    if type(machine_addresses) ~= "table" then
        return unknown("relative address basis unresolved", {
            base = base.name,
        })
    end

    local next_instruction =
        machine_addresses.next_instruction
    local basis_value =
        exact_evidence(next_instruction)

    if not basis_value then
        return unknown(
            "next-instruction machine address unresolved",
            {
                base = base.name,
                evidence_status = type(next_instruction) == "table"
                    and next_instruction.status
                    or nil,
                evidence_reason = type(next_instruction) == "table"
                    and next_instruction.reason
                    or nil,
            }
        )
    end

    if address.index ~= nil
        or address.scale ~= nil
    then
        return unknown(
            "instruction-relative index components unsupported",
            {
                base = base.name,
                has_index = address.index ~= nil,
                has_scale = address.scale ~= nil,
            }
        )
    end

    local displacement, displacement_error =
        source_displacement(address)

    if displacement_error then
        return displacement_error
    end

    local basis_bits =
        evidence_bits(next_instruction)
    local exact_target = nil
    local relative_delta = nil
    local symbol_component = nil

    if address.symbol ~= nil then
        if base_spec.symbol_mode ~= "target" then
            return unknown(
                "instruction-relative symbol component unsupported",
                {
                    base = base.name,
                    symbol = address.symbol.name,
                }
            )
        end

        local symbol_evidence =
            machine_addresses.symbol
        local symbol_value =
            exact_evidence(symbol_evidence)

        if not symbol_value then
            return unknown(
                "symbol machine address unresolved",
                {
                    base = base.name,
                    symbol = address.symbol.name,
                    evidence_status =
                        type(symbol_evidence) == "table"
                        and symbol_evidence.status
                        or nil,
                    evidence_reason =
                        type(symbol_evidence) == "table"
                        and symbol_evidence.reason
                        or nil,
                }
            )
        end

        local symbol_bits =
            evidence_bits(symbol_evidence)

        if basis_bits ~= nil
            and symbol_bits ~= nil
            and basis_bits ~= symbol_bits
        then
            return unknown(
                "machine address width mismatch",
                {
                    next_instruction_bits = basis_bits,
                    symbol_bits = symbol_bits,
                }
            )
        end

        exact_target = integer_value.add(
            symbol_value,
            displacement
        )

        if not exact_target then
            return unknown("relative target arithmetic failed")
        end

        relative_delta = integer_value.add(
            exact_target,
            integer_value.negate(basis_value)
        )

        if not relative_delta then
            return unknown("relative delta arithmetic failed")
        end

        symbol_component = {
            name = address.symbol.name,
            value = symbol_value,
            bits = symbol_bits,
            mode = base_spec.symbol_mode,
        }
    else
        exact_target = integer_value.add(
            basis_value,
            displacement
        )

        if not exact_target then
            return unknown("relative target arithmetic failed")
        end

        relative_delta = displacement
    end

    local bits = result_bits_for_base(
        address,
        basis_bits,
        opts,
        base_spec
    )

    local target_value,
        wrapped,
        wrap_error = wrap_target(
            exact_target,
            bits
        )

    if wrap_error then
        return wrap_error
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
            base = {
                name = base.name,
                result_width = base_spec.result_width,
                symbol_mode = base_spec.symbol_mode,
            },
            symbol = symbol_component,
            source_displacement = displacement,
            relative_delta = relative_delta,
            exact_target = exact_target,
        },
        wrapped
    )
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

    if address.address_size_status ~= nil
        and address.address_size_status ~= "known"
    then
        return unknown("address size unresolved", {
            reason = address.address_size_reason,
            details = address.address_size_details,
        })
    end

    if address.address_mode == "relative" then
        return evaluate_explicit_relative(
            address,
            machine_addresses,
            opts
        )
    end

    local base, base_spec =
        get_instruction_relative_base(
            address,
            opts.instruction_relative_policy
        )

    if base_spec then
        return evaluate_register_relative(
            address,
            machine_addresses,
            opts,
            base,
            base_spec
        )
    end

    return unknown("address is not explicit relative", {
        address_mode = address.address_mode,
    })
end

return M
