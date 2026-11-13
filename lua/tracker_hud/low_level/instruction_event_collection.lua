-- lua/tracker_hud/low_level/instruction_event_collection.lua
--
-- Instruction-event collection orchestration.
--
-- This module owns indexed node traversal, duplicate suppression, source
-- ordering, parser callback sequencing, event bucket dispatch and final fact
-- ordering. It does not parse instructions, match event semantics, or build
-- event facts.

local core = require("tracker_hud.core")

local M = {}


local function collect_nodes(
    context,
    event_index,
    collect_nodes_by_type
)
    local cursor_line =
        context
        and context.cursor
        and context.cursor.line

    local nodes = {}
    local seen_nodes = {}

    for node_type, _ in pairs(
        event_index.node_types
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


local function sort_facts(facts)
    table.sort(
        facts,
        function(left, right)
            local left_line =
                left.source_line
            local right_line =
                right.source_line

            if left_line and right_line then
                if left_line == right_line then
                    return tostring(
                        left.name or ""
                    ) < tostring(
                        right.name or ""
                    )
                end

                return left_line
                    < right_line
            end

            if left_line then
                return true
            end

            if right_line then
                return false
            end

            return tostring(
                left.name or ""
            ) < tostring(
                right.name or ""
            )
        end
    )
end


function M.collect(opts)
    opts = opts or {}

    if not core.is_table(opts.context)
        or not core.is_table(opts.event_index)
        or not core.is_table(
            opts.event_index.node_types
        )
        or not core.is_table(
            opts.event_index.by_node_type
        )
        or type(opts.collect_nodes) ~= "function"
        or type(opts.parse_instruction) ~= "function"
        or type(opts.normalize_mnemonic) ~= "function"
        or type(opts.apply_event) ~= "function"
    then
        return {}
    end

    local facts = {}

    local nodes = collect_nodes(
        opts.context,
        opts.event_index,
        opts.collect_nodes
    )

    for _, entry in ipairs(nodes) do
        local node_bucket =
            opts.event_index.by_node_type[
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

            local event_specs =
                mnemonic
                and node_bucket[mnemonic]
                or nil

            for _, event_spec in ipairs(
                event_specs or {}
            ) do
                opts.apply_event(
                    facts,
                    instruction,
                    event_spec
                )
            end
        end
    end

    sort_facts(facts)

    return facts
end


return M
