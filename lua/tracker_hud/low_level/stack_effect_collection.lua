-- lua/tracker_hud/low_level/stack_effect_collection.lua
--
-- Stack-effect collection orchestration.
--
-- This module owns the ordered union of stack-effect and register-effect
-- instruction nodes, deduplication, parsing dispatch, and callback sequencing.
-- It does not infer stack values, match operands, apply register semantics, or
-- construct stack/register facts.

local core = require("tracker_hud.core")

local M = {}


local function add_nodes_from_index(
    nodes,
    seen_nodes,
    cursor_line,
    effect_index,
    collect_nodes_by_type
)
    if not core.is_table(effect_index)
        or not core.is_table(
            effect_index.node_types
        )
    then
        return
    end

    for node_type, _ in pairs(
        effect_index.node_types
    ) do
        for _, node in ipairs(
            collect_nodes_by_type(node_type)
            or {}
        ) do
            local start_row,
                start_column,
                end_row,
                end_column =
                node:range()

            local node_line =
                start_row + 1

            if not cursor_line
                or node_line <= cursor_line
            then
                local key = table.concat({
                    node:type(),
                    tostring(start_row),
                    tostring(start_column),
                    tostring(end_row),
                    tostring(end_column),
                }, ":")

                if not seen_nodes[key] then
                    seen_nodes[key] = true

                    table.insert(
                        nodes,
                        {
                            node = node,
                            line = node_line,
                            column = start_column,
                        }
                    )
                end
            end
        end
    end
end


function M.collect(opts)
    opts = opts or {}

    if not core.is_table(
            opts.stack_effect_index
        )
        or not core.is_table(
            opts.register_effect_index
        )
        or type(opts.collect_nodes) ~= "function"
        or type(opts.parse_instruction) ~= "function"
        or type(opts.normalize_mnemonic) ~= "function"
        or type(opts.new_state) ~= "function"
        or type(opts.prepare_stack_state) ~= "function"
        or type(opts.apply_stack_effect) ~= "function"
        or type(opts.apply_register_effect) ~= "function"
    then
        return {}
    end

    local cursor_line =
        opts.context
        and opts.context.cursor
        and opts.context.cursor.line

    local nodes = {}
    local seen_nodes = {}

    -- Preserve the original traversal order: stack index first, then register
    -- index, while deduplicating identical Tree-sitter ranges across both.
    add_nodes_from_index(
        nodes,
        seen_nodes,
        cursor_line,
        opts.stack_effect_index,
        opts.collect_nodes
    )

    add_nodes_from_index(
        nodes,
        seen_nodes,
        cursor_line,
        opts.register_effect_index,
        opts.collect_nodes
    )

    table.sort(
        nodes,
        function(left, right)
            if left.line == right.line then
                return left.column
                    < right.column
            end

            return left.line
                < right.line
        end
    )

    local facts = {}
    local low_level_state =
        opts.new_state()
    local facts_by_register = {}

    for _, entry in ipairs(nodes) do
        local node_type =
            entry.node:type()

        local stack_bucket =
            opts.stack_effect_index
                .by_node_type
            and opts.stack_effect_index
                .by_node_type[node_type]
            or nil

        local register_bucket =
            opts.register_effect_index
                .by_node_type
            and opts.register_effect_index
                .by_node_type[node_type]
            or nil

        local representative_effect_spec =
            stack_bucket
            and stack_bucket.__first
            or register_bucket
            and register_bucket.__first
            or nil

        if representative_effect_spec then
            local instruction =
                opts.parse_instruction(
                    entry.node,
                    representative_effect_spec
                )

            local mnemonic =
                instruction
                and opts.normalize_mnemonic(
                    instruction.mnemonic
                )

            local stack_effect_specs =
                mnemonic
                and stack_bucket
                and stack_bucket[mnemonic]
                or nil

            local register_effect_specs =
                mnemonic
                and register_bucket
                and register_bucket[mnemonic]
                or nil

            local instruction_state = {}

            if core.is_table(
                stack_effect_specs
            ) then
                instruction_state =
                    opts.prepare_stack_state(
                        low_level_state,
                        facts_by_register,
                        instruction,
                        stack_effect_specs
                    )

                for _, effect_spec in ipairs(
                    stack_effect_specs
                ) do
                    opts.apply_stack_effect(
                        facts,
                        instruction,
                        effect_spec,
                        instruction_state
                    )
                end
            end

            if core.is_table(
                register_effect_specs
            ) then
                for _, effect_spec in ipairs(
                    register_effect_specs
                ) do
                    opts.apply_register_effect(
                        facts_by_register,
                        instruction,
                        effect_spec,
                        instruction_state
                    )
                end
            end
        end
    end

    return facts
end


return M
