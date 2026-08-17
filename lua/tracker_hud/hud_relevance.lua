-- lua/tracker_hud/hud_relevance.lua
--
-- Generic HUD relevance-state classification.
--
-- Semantic identity answers WHAT a piece of information is (register,
-- warning, value, boundary, ...). Relevance answers HOW important that same
-- information is to the source cursor right now.
--
-- This module deliberately knows nothing about colors, highlight-group names,
-- x86, or concrete HUD sections. Callers provide a section id, Inspect Mode,
-- cursor position, and ordinary source ranges.

local M = {}

local VALID = {
    focused = true,
    current = true,
    contextual = true,
    historical = true,
}


local function number_or_nil(value)
    local number = tonumber(value)

    if not number then
        return nil
    end

    return number
end


function M.is_valid(state)
    return type(state) == "string"
        and VALID[state] == true
end


function M.get_node_range(node)
    if type(node) ~= "table" then
        return nil
    end

    if node.source_start_line and node.source_end_line then
        return {
            start_line = number_or_nil(node.source_start_line),
            start_column = number_or_nil(node.source_start_column) or 0,
            end_line = number_or_nil(node.source_end_line),
            end_column = number_or_nil(node.source_end_column) or 0,
        }
    end

    if node.scope_start_line and node.scope_end_line then
        return {
            start_line = number_or_nil(node.scope_start_line),
            start_column = number_or_nil(node.scope_start_column) or 0,
            end_line = number_or_nil(node.scope_end_line),
            end_column = number_or_nil(node.scope_end_column) or 0,
        }
    end

    if type(node.member) == "table" then
        local member = node.member

        if member.value_start_line and member.value_end_line then
            return {
                start_line = number_or_nil(member.value_start_line),
                start_column = number_or_nil(member.value_start_column) or 0,
                end_line = number_or_nil(member.value_end_line),
                end_column = number_or_nil(member.value_end_column) or 0,
            }
        end

        if member.source_start_line and member.source_end_line then
            return {
                start_line = number_or_nil(member.source_start_line),
                start_column = number_or_nil(member.source_start_column) or 0,
                end_line = number_or_nil(member.source_end_line),
                end_column = number_or_nil(member.source_end_column) or 0,
            }
        end

        if member.line then
            return {
                start_line = number_or_nil(member.line),
                start_column = 0,
                end_line = number_or_nil(member.line),
                end_column = 0,
            }
        end
    end

    if node.source_line then
        local line = number_or_nil(node.source_line)
        local column = number_or_nil(node.source_column) or 0

        return {
            start_line = line,
            start_column = column,
            end_line = line,
            end_column = column,
        }
    end

    return nil
end


function M.range_contains_line(range, source_line)
    source_line = number_or_nil(source_line)

    if type(range) ~= "table" or not source_line then
        return false
    end

    local start_line = number_or_nil(range.start_line)
    local end_line = number_or_nil(range.end_line)

    if not start_line or not end_line then
        return false
    end

    return source_line >= start_line
        and source_line <= end_line
end


function M.position_is_in_range(range, source_line, source_column)
    source_line = number_or_nil(source_line)
    source_column = number_or_nil(source_column) or 0

    if type(range) ~= "table" or not source_line then
        return false
    end

    local start_line = number_or_nil(range.start_line)
    local end_line = number_or_nil(range.end_line)

    if not start_line or not end_line then
        return false
    end

    local start_column = number_or_nil(range.start_column) or 0
    local end_column = number_or_nil(range.end_column) or start_column

    if source_line < start_line or source_line > end_line then
        return false
    end

    if start_line == end_line then
        return source_column >= start_column
            and source_column <= end_column
    end

    if source_line == start_line then
        return source_column >= start_column
    end

    if source_line == end_line and end_column > 0 then
        return source_column <= end_column
    end

    return true
end


function M.classify(opts)
    opts = opts or {}

    if opts.affected_line ~= true then
        return "historical"
    end

    if opts.inspect_match ~= true then
        return "contextual"
    end

    if opts.exact_symbol == true then
        return "focused"
    end

    return "current"
end


function M.classify_node(node, opts, inherited_relevance)
    opts = opts or {}

    local range = M.get_node_range(node)

    -- Range-less presentation/container nodes inherit the relevance of the
    -- owning node when possible. At the tree root they inherit the section's
    -- relevance. This keeps labels such as register groups visually coherent
    -- without pretending those containers own source locations.
    if not range then
        if M.is_valid(inherited_relevance) then
            return inherited_relevance
        end

        if M.is_valid(opts.section_relevance) then
            return opts.section_relevance
        end

        return "historical"
    end

    local affected_line = M.range_contains_line(
        range,
        opts.active_source_line
    )

    if not affected_line then
        return "historical"
    end

    local inspect_match = type(opts.section_id) == "string"
        and opts.section_id ~= ""
        and opts.inspect_mode == opts.section_id

    if not inspect_match then
        return "contextual"
    end

    local exact_symbol = false
    local focused_ids = opts.focused_node_ids

    if type(focused_ids) == "table" then
        exact_symbol = focused_ids[node.id] == true

        if opts.focused_node_ids_strict == true then
            return M.classify({
                affected_line = true,
                inspect_match = true,
                exact_symbol = exact_symbol,
            })
        end
    end

    if not exact_symbol then
        exact_symbol = M.position_is_in_range(
            range,
            opts.active_source_line,
            opts.active_source_column
        )
    end

    return M.classify({
        affected_line = true,
        inspect_match = true,
        exact_symbol = exact_symbol,
    })
end


return M
