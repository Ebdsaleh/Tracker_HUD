-- lua/tracker_hud/low_level/register_source_collection.lua
--
-- Register source-occurrence collection orchestration for Inspect.
--
-- Parsing, effect matching and effective-address evaluation are injected by
-- context_engine. This module owns line filtering, duplicate node suppression,
-- occurrence construction and attachment of source-memory certainty evidence.

local core = require("tracker_hud.core")
local memory_source_evidence =
    require("tracker_hud.low_level.memory_source_evidence")
local register_source_occurrence =
    require("tracker_hud.low_level.register_source_occurrence")

local M = {}


local function node_key(node)
    if not node then
        return nil
    end

    local start_row,
        start_column,
        end_row,
        end_column = node:range()

    return table.concat({
        node:type(),
        tostring(start_row),
        tostring(start_column),
        tostring(end_row),
        tostring(end_column),
    }, ":"),
        start_row + 1
end


local function append_memory_evidence(
    metadata,
    evaluation,
    symbol_identity,
    machine_addresses
)
    memory_source_evidence.append_effective_address_metadata(
        metadata,
        evaluation,
        "memory_effective_address"
    )

    memory_source_evidence.append_source_symbol_metadata(
        metadata,
        symbol_identity
    )

    memory_source_evidence.append_machine_address_metadata(
        metadata,
        machine_addresses
    )
end


function M.collect(opts)
    opts = opts or {}

    if not core.is_table(opts.adapter)
        or not core.is_number(opts.line_number)
        or not core.is_table(opts.node_types)
        or type(opts.collect_nodes) ~= "function"
        or type(opts.parse_and_match) ~= "function"
        or type(opts.evaluate_address) ~= "function"
    then
        return {}
    end

    local adapter = opts.adapter
    local occurrences = {}
    local seen_nodes = {}

    for node_type, _ in pairs(
        opts.node_types
    ) do
        for _, node in ipairs(
            opts.collect_nodes(node_type)
                or {}
        ) do
            local key, source_line =
                node_key(node)

            if key
                and source_line == opts.line_number
                and not seen_nodes[key]
            then
                seen_nodes[key] = true

                local instruction,
                    matching_specs =
                    opts.parse_and_match(node)

                matching_specs =
                    matching_specs or {}

                -- Source occurrences are syntax, not semantic effects.
                -- Matching rules enrich roles and state transitions, but
                -- their absence must not hide syntax already identified by
                -- the parser.
                if instruction then
                local mnemonic_occurrence =
                    register_source_occurrence.build_mnemonic(
                        adapter,
                        instruction,
                        matching_specs
                    )

                if mnemonic_occurrence then
                    table.insert(
                        occurrences,
                        mnemonic_occurrence
                    )
                end

                for operand_index, operand in ipairs(
                    instruction.operands or {}
                ) do
                    local evaluation
                    local symbol_identity
                    local machine_addresses

                    if operand.kind == "memory"
                        and core.is_table(operand.memory)
                        and core.is_table(
                            operand.memory.normalized
                        )
                    then
                        symbol_identity =
                            memory_source_evidence.resolve_symbol_identity(
                                opts.source_members,
                                adapter,
                                operand
                            )

                        local instruction_relative_policy =
                            memory_source_evidence.get_instruction_relative_policy(
                                adapter,
                                operand
                            )

                        machine_addresses =
                            memory_source_evidence.resolve_machine_addresses(
                                opts.machine_address_providers,
                                adapter,
                                instruction,
                                operand.memory.normalized,
                                symbol_identity,
                                instruction_relative_policy
                            )

                        evaluation =
                            opts.evaluate_address(
                                instruction,
                                operand.memory.normalized,
                                machine_addresses,
                                instruction_relative_policy
                            )
                    end

                    local operand_occurrence =
                        register_source_occurrence.build_operand(
                            adapter,
                            instruction,
                            operand,
                            operand_index,
                            matching_specs
                        )

                    if operand_occurrence then
                        append_memory_evidence(
                            operand_occurrence.metadata,
                            evaluation,
                            symbol_identity,
                            machine_addresses
                        )

                        table.insert(
                            occurrences,
                            operand_occurrence
                        )
                    end

                    for _, component_occurrence in ipairs(
                        register_source_occurrence.build_memory_components(
                            adapter,
                            instruction,
                            operand,
                            operand_index,
                            matching_specs
                        )
                    ) do
                        append_memory_evidence(
                            component_occurrence.metadata,
                            evaluation,
                            symbol_identity,
                            machine_addresses
                        )

                        table.insert(
                            occurrences,
                            component_occurrence
                        )
                    end
                    end
                end
            end
        end
    end

    return occurrences
end


return M
