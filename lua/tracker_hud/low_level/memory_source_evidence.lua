-- lua/tracker_hud/low_level/memory_source_evidence.lua
--
-- Memory-source certainty and machine-address evidence helpers.
--
-- This module owns the evidence plumbing shared by source-memory facts and
-- source Inspect occurrences. It does not parse instructions, infer register
-- state, or decide whether a memory access executed.

local core = require("tracker_hud.core")
local source_symbol = require("tracker_hud.low_level.source_symbol")
local machine_address = require("tracker_hud.low_level.machine_address")
local relative_address = require("tracker_hud.low_level.relative_address")

local M = {}


local function get_memory_spec(adapter, operand)
    if not core.is_table(adapter)
        or not core.is_table(operand)
        or not core.is_non_empty_string(operand.node_type)
    then
        return nil
    end

    local construct_specs = adapter.construct_specs
    local construct = core.is_table(construct_specs)
        and construct_specs[operand.node_type]
        or nil
    local operand_spec = core.is_table(construct)
        and construct.operand
        or nil

    return core.is_table(operand_spec)
        and core.is_table(operand_spec.memory)
        and operand_spec.memory
        or nil
end


function M.get_instruction_relative_policy(
    adapter,
    operand
)
    local memory_spec = get_memory_spec(
        adapter,
        operand
    )

    return core.is_table(memory_spec)
        and memory_spec.instruction_relative
        or nil
end


function M.resolve_symbol_identity(
    members,
    adapter,
    operand
)
    if not core.is_table(operand)
        or not core.is_table(operand.memory)
        or not core.is_table(operand.memory.normalized)
        or not core.is_table(operand.memory.normalized.symbol)
    then
        return nil
    end

    local symbol = operand.memory.normalized.symbol
    local memory_spec = get_memory_spec(
        adapter,
        operand
    )
    local policy = core.is_table(memory_spec)
        and core.is_table(memory_spec.symbol_resolution)
        and memory_spec.symbol_resolution
        or {}

    return source_symbol.resolve(
        members,
        symbol.name,
        {
            member_kinds = policy.member_kinds,
            allow_forward = policy.allow_forward == true,
            case_sensitive = policy.case_sensitive ~= false,
            reference_line = operand.source_line,
        }
    )
end


local function has_machine_address_providers(providers)
    return type(providers) == "table"
        and #providers > 0
end


function M.resolve_machine_addresses(
    providers,
    adapter,
    instruction,
    address,
    symbol_identity,
    instruction_relative_policy
)
    if not has_machine_address_providers(providers)
        or not core.is_table(instruction)
        or not core.is_table(address)
    then
        return nil
    end

    local bits = (
            adapter
            and adapter.metadata
            and adapter.metadata.bits
        )
        or address.address_size_bits
        or nil

    local common = {
        source_line = instruction.source_start_line
            or instruction.source_line,
        source_column = instruction.source_start_column
            or instruction.source_column,
        mnemonic = instruction.mnemonic,
    }

    local result = {
        instruction = machine_address.resolve(
            providers,
            {
                kind = "instruction",
                source_line = common.source_line,
                source_column = common.source_column,
                mnemonic = common.mnemonic,
            },
            {
                bits = bits,
            }
        ),
    }

    if relative_address.requires_next_instruction(
        address,
        {
            instruction_relative_policy =
                instruction_relative_policy,
        }
    )
    then
        result.next_instruction = machine_address.resolve(
            providers,
            {
                kind = "next_instruction",
                source_line = common.source_line,
                source_column = common.source_column,
                mnemonic = common.mnemonic,
            },
            {
                bits = bits,
            }
        )
    end

    if address.symbol
        and core.is_non_empty_string(address.symbol.name)
    then
        result.symbol = machine_address.resolve(
            providers,
            {
                kind = "symbol",
                name = address.symbol.name,
                source_line = common.source_line,
                source_column = common.source_column,
                source_symbol_member_id =
                    symbol_identity
                    and symbol_identity.member_id
                    or nil,
                source_symbol_line =
                    symbol_identity
                    and symbol_identity.source_line
                    or nil,
            },
            {
                bits = bits,
            }
        )
    end

    return result
end


function M.append_effective_address_metadata(
    metadata,
    evaluation,
    prefix
)
    if not core.is_table(metadata) then
        return
    end

    prefix = prefix or "effective_address"

    local status = core.is_table(evaluation)
        and evaluation.status
        or "unknown"
    local value = core.is_table(evaluation)
        and evaluation.value
        or nil
    local reason = core.is_table(evaluation)
        and evaluation.reason
        or nil
    local bits = core.is_table(evaluation)
        and evaluation.bits
        or nil
    local wrapped = core.is_table(evaluation)
        and evaluation.wrapped == true
        or false

    metadata[prefix] = value or "unknown"
    metadata[prefix .. "_status"] = status
    metadata[prefix .. "_value"] = value
    metadata[prefix .. "_reason"] = reason
    metadata[prefix .. "_bits"] = bits
    metadata[prefix .. "_wrapped"] = wrapped
end


function M.append_source_symbol_metadata(
    metadata,
    identity
)
    if not core.is_table(metadata)
        or not core.is_table(identity)
    then
        return
    end

    metadata.source_symbol_status = identity.status
    metadata.source_symbol_name = identity.name
    metadata.source_symbol_kind = identity.kind
    metadata.source_symbol_member_id = identity.member_id
    metadata.source_symbol_line = identity.source_line
    metadata.source_symbol_start_column =
        identity.source_start_column
    metadata.source_symbol_end_line =
        identity.source_end_line
    metadata.source_symbol_end_column =
        identity.source_end_column
    metadata.source_symbol_forward_reference =
        identity.forward_reference
    metadata.source_symbol_reason = identity.reason

    metadata.symbol_machine_address_status =
        identity.machine_address_status
    metadata.symbol_machine_address =
        identity.machine_address
    metadata.symbol_machine_address_reason =
        identity.machine_address_reason
end


local function append_one_machine_address_metadata(
    metadata,
    prefix,
    evidence
)
    if not core.is_table(metadata)
        or not core.is_non_empty_string(prefix)
        or not core.is_table(evidence)
    then
        return
    end

    metadata[prefix .. "_status"] = evidence.status
    metadata[prefix] = evidence.value or "unknown"
    metadata[prefix .. "_value"] = evidence.value
    metadata[prefix .. "_reason"] = evidence.reason
    metadata[prefix .. "_bits"] = evidence.bits
end


function M.append_machine_address_metadata(
    metadata,
    evidence
)
    if not core.is_table(metadata)
        or not core.is_table(evidence)
    then
        return
    end

    append_one_machine_address_metadata(
        metadata,
        "instruction_machine_address",
        evidence.instruction
    )

    append_one_machine_address_metadata(
        metadata,
        "next_instruction_machine_address",
        evidence.next_instruction
    )

    append_one_machine_address_metadata(
        metadata,
        "symbol_machine_address",
        evidence.symbol
    )
end


return M
