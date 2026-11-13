-- lua/tracker_hud/low_level/register_effect_collection.lua
--
-- Register-effect instruction-node selection and ordering.
--
-- This module does not parse instructions or apply register effects. It owns
-- only visibility filtering, duplicate node suppression and source ordering.

local core = require("tracker_hud.core")

local M = {}


local function node_key(
    node,
    start_row,
    start_column,
    end_row,
    end_column
)
    return table.concat({
        node:type(),
        tostring(start_row),
        tostring(start_column),
        tostring(end_row),
        tostring(end_column),
    }, ":")
end


function M.collect(opts)
    opts = opts or {}

    if not core.is_table(opts.node_types)
        or type(opts.collect_nodes) ~= "function"
        or type(opts.normalize_position) ~= "function"
        or type(opts.position_is_before) ~= "function"
        or type(opts.classify_position) ~= "function"
        or type(opts.allows_position) ~= "function"
    then
        return {}
    end

    local cursor_line =
        opts.context
        and opts.context.cursor
        and opts.context.cursor.line

    local limit_position =
        opts.normalize_position(
            opts.limit_position
            or opts.stop_before
            or opts.before_position
        )

    local nodes = {}
    local seen_nodes = {}

    for node_type, _ in pairs(
        opts.node_types
    ) do
        for _, node in ipairs(
            opts.collect_nodes(node_type)
            or {}
        ) do
            local start_row,
                start_column,
                end_row,
                end_column =
                node:range()

            local node_line =
                start_row + 1

            local should_collect = false

            if limit_position then
                should_collect =
                    opts.position_is_before(
                        {
                            line = node_line,
                            column = start_column,
                        },
                        limit_position
                    )
            elseif not cursor_line
                or node_line < cursor_line
            then
                should_collect = true
            elseif node_line == cursor_line then
                local cursor_column =
                    opts.context
                    and opts.context.cursor
                    and opts.context.cursor.column

                if core.is_number(
                    cursor_column
                ) then
                    cursor_column =
                        math.max(
                            0,
                            cursor_column - 1
                        )
                end

                local cursor_position =
                    opts.classify_position(
                        start_column,
                        end_column,
                        cursor_column
                    )

                should_collect =
                    opts.allows_position(
                        opts.config,
                        cursor_position
                    )
            end

            if should_collect then
                local key = node_key(
                    node,
                    start_row,
                    start_column,
                    end_row,
                    end_column
                )

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


return M
