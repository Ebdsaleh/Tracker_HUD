-- lua/tracker_hud/low_level/memory_source_collection.lua
--
-- Source-memory collection orchestration.
--
-- Parsing, effect matching, register-state replay and access-policy decisions
-- are injected by the context engine. This module owns the repeated collection
-- mechanics: source-line filtering, duplicate node suppression, per-operand
-- evidence assembly, normalized fact construction and stable ordering.

local core = require("tracker_hud.core")
local memory_source_evidence =
    require("tracker_hud.low_level.memory_source_evidence")
local memory_source_fact =
    require("tracker_hud.low_level.memory_source_fact")

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


local function sort_facts(facts)
    table.sort(facts, function(left, right)
        local left_line = left.source_line or 0
        local right_line = right.source_line or 0

        if left_line ~= right_line then
            return left_line < right_line
        end

        local left_column =
            left.source_start_column or 0
        local right_column =
            right.source_start_column or 0

        if left_column == right_column then
            return (left.operand_index or 0)
                < (right.operand_index or 0)
        end

        return left_column < right_column
    end)
end


function M.collect(opts)
    opts = opts or {}

    if not core.is_table(opts.adapter)
        or type(opts.line_predicate) ~= "function"
        or type(opts.parse_instruction) ~= "function"
        or type(opts.match_effects) ~= "function"
        or type(opts.evaluate_address) ~= "function"
        or type(opts.get_operand_role) ~= "function"
        or type(opts.resolve_access) ~= "function"
    then
        return {}
    end

    local adapter = opts.adapter
    local result = {}
    local seen_nodes = {}

    for _, node in ipairs(opts.nodes or {}) do
        local key, source_line = node_key(node)

        if key
            and opts.line_predicate(source_line)
            and not seen_nodes[key]
        then
            seen_nodes[key] = true

            local instruction =
                opts.parse_instruction(node)

            if instruction then
                local matching_specs =
                    opts.match_effects(
                        node,
                        instruction
                    ) or {}

                for operand_index, operand in ipairs(
                    instruction.operands or {}
                ) do
                    local symbol_identity =
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

                    local machine_addresses =
                        memory_source_evidence.resolve_machine_addresses(
                            opts.machine_address_providers,
                            adapter,
                            instruction,
                            operand.memory
                                and operand.memory.normalized
                                or nil,
                            symbol_identity,
                            instruction_relative_policy
                        )

                    local evaluation

                    if operand.kind == "memory"
                        and core.is_table(operand.memory)
                        and core.is_table(
                            operand.memory.normalized
                        )
                    then
                        evaluation =
                            opts.evaluate_address(
                                instruction,
                                operand.memory.normalized,
                                machine_addresses,
                                instruction_relative_policy
                            )
                    end

                    local memory_operand = nil

                    if operand.kind == "memory"
                        and core.is_table(operand.memory)
                        and core.is_table(
                            operand.memory.normalized
                        )
                    then
                        local role =
                            opts.get_operand_role(
                                matching_specs,
                                operand_index
                            )

                        local access,
                            access_metadata =
                            opts.resolve_access(
                                instruction,
                                operand_index,
                                operand
                            )

                        memory_operand =
                            memory_source_fact.new({
                                instruction = instruction,
                                operand = operand,
                                operand_index = operand_index,
                                role = role,
                                access = access,
                                access_metadata =
                                    access_metadata,
                                evaluation = evaluation,
                                symbol_identity =
                                    symbol_identity,
                                machine_addresses =
                                    machine_addresses,
                            })
                    end

                    if memory_operand then
                        table.insert(
                            result,
                            memory_operand
                        )
                    end
                end
            end
        end
    end

    sort_facts(result)

    return result
end


return M
