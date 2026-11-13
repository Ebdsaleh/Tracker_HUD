-- lua/tracker_hud/low_level/memory_source_fact.lua
--
-- Normalized source-memory fact construction.
--
-- The context engine decides which instruction/operand is visible and what
-- semantic role/access intent applies. This module only turns those already
-- resolved inputs into the stable source-memory fact shape.

local core = require("tracker_hud.core")
local memory_source_evidence =
    require("tracker_hud.low_level.memory_source_evidence")

local M = {}


function M.new(opts)
    opts = opts or {}

    local instruction = opts.instruction
    local operand = opts.operand
    local operand_index = opts.operand_index
    local access_metadata = opts.access_metadata or {}

    if not core.is_table(instruction)
        or not core.is_table(operand)
        or operand.kind ~= "memory"
        or not core.is_table(operand.memory)
        or not core.is_table(operand.memory.normalized)
    then
        return nil
    end

    local address = operand.memory.normalized

    local fact = {
        id = table.concat({
            "memory-operand",
            tostring(
                operand.source_line
                or instruction.source_line
                or "?"
            ),
            tostring(
                operand.source_start_column
                or operand.source_column
                or "?"
            ),
            tostring(operand_index),
        }, ":"),
        kind = "memory_operand",
        category = "memory",
        source = "asm_source_memory",
        text = operand.text,
        role = opts.role,
        access = opts.access,
        operand_index = operand_index,

        source_line = operand.source_line,
        source_column = operand.source_column,
        source_start_line = operand.source_start_line,
        source_start_column = operand.source_start_column,
        source_end_line = operand.source_end_line,
        source_end_column = operand.source_end_column,

        address = address,
        effective_address = opts.evaluation,
        symbol_identity = opts.symbol_identity,
        machine_addresses = opts.machine_addresses,

        metadata = {
            observation = "source memory operand only",
            mnemonic = instruction.mnemonic,
            operand_role = opts.role,
            access_intent = opts.access,
            access_declared = access_metadata.declared,
            access_ambiguous = access_metadata.ambiguous,
            access_rule_count = access_metadata.rule_count,
            address_size_bits = address.address_size_bits,
            address_size_status = address.address_size_status,
            address_size_source = address.address_size_source,
            address_size_reason = address.address_size_reason,
            runtime_address = "unknown",
            execution_status = "not_observed",
        },
    }

    memory_source_evidence.append_effective_address_metadata(
        fact.metadata,
        opts.evaluation,
        "effective_address"
    )

    memory_source_evidence.append_source_symbol_metadata(
        fact.metadata,
        opts.symbol_identity
    )

    memory_source_evidence.append_machine_address_metadata(
        fact.metadata,
        opts.machine_addresses
    )

    return fact
end


return M
