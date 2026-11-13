-- lua/tracker_hud/low_level/boundary_effect_collection.lua
--
-- Boundary-effect collection orchestration.
--
-- This module owns source-node traversal, deduplication, ordering, effect
-- bucket selection and callback sequencing. It does not parse instructions,
-- infer boundary semantics, resolve register state, or construct facts.

local core = require("tracker_hud.core")

local M = {}


local function collect_nodes(
    context,
    effect_index,
    collect_nodes_by_type
)
    local cursor_line =
        context
        and context.cursor
        and context.cursor.line

    local nodes = {}
    local seen_nodes = {}

    for node_type, _ in pairs(
        effect_index.node_types
        or {}
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

    return nodes
end


function M.collect(opts)
    opts = opts or {}

    if not core.is_table(opts.context)
        or not core.is_table(opts.effect_index)
        or not core.is_table(
            opts.effect_index.node_types
        )
        or not core.is_table(
            opts.effect_index.by_node_type
        )
        or type(opts.collect_nodes) ~= "function"
        or type(opts.parse_instruction) ~= "function"
        or type(opts.normalize_mnemonic) ~= "function"
        or type(opts.collect_read_context) ~= "function"
        or type(opts.apply_effect) ~= "function"
    then
        return {}
    end

    local facts = {}

    local nodes = collect_nodes(
        opts.context,
        opts.effect_index,
        opts.collect_nodes
    )

    for _, entry in ipairs(nodes) do
        local node_bucket =
            opts.effect_index.by_node_type[
                entry.node:type()
            ]

        if node_bucket then
            local instruction =
                opts.parse_instruction(
                    entry.node,
                    node_bucket.__first
                )

            local mnemonic =
                instruction
                and opts.normalize_mnemonic(
                    instruction.mnemonic
                )

            local effect_specs =
                mnemonic
                and node_bucket[mnemonic]
                or nil

            -- Preserve the original ordering: read context is collected after
            -- parsing even if no candidate effect spec survives mnemonic
            -- lookup.
            local read_context =
                opts.collect_read_context(
                    instruction
                )

            for _, effect_spec in ipairs(
                effect_specs or {}
            ) do
                opts.apply_effect(
                    facts,
                    instruction,
                    effect_spec,
                    {
                        read_context =
                            read_context,
                        write_context =
                            opts.context,
                    }
                )
            end
        end
    end

    return facts
end


return M
