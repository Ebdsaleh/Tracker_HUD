-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local M = {}


local function is_number(value)
    return type(value) == "number"
end

local function is_table(value)
    return type(value) == "table"
end


function M.make_global_context()
    return {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
    }
end

function M.make_unavailable_context(message, filetype)
    return {
        label = message,
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        unavailable = true,
        filetype = filetype,
    }
end

function M.position_in_node(row, col, node)
    if not node then
        return false
    end

    local start_row, start_col, end_row, end_col = node:range()

    if not is_number(start_row) or not is_number(end_row) then
        return false
    end

    if row < start_row or row > end_row then
        return false
    end

    if row == start_row and is_number(start_col) and col < start_col then
        return false
    end    

    if row == end_row and is_number(end_col) and col > end_col then
        return false
    end

    return true
end


function M.get_first_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()


    if not is_number(start_row) then
        return nil
    end

    return start_row + 1
end


function M.build_scope_entry_from_construct(construct)
    if not is_table(construct) or not is_table(construct.range) then
        return nil
    end

    local line_number = construct.range.start_line
    local label = construct.signature or construct.label
    local display_label = nil

    if construct.metadata then
        display_label = construct.metadata.display_label
    end

    display_label = display_label or "[" .. line_number .. "] " .. label

    return {
        label = display_label,
        raw_label = label,
        node_type = construct.node_type,
        kind = construct.kind,
        start_line = construct.range.start_line,
        end_line = construct.range.end_line,
        construct = construct,
    }
end  


function M.build_context_from_scopes(scopes, config)
    local context = M.make_global_context()

    if not is_table(scopes) or #scopes == 0 then
        return context
    end

    local path = {}

    -- Scopes are collected innermost -> outermost.
    -- Reverse them so HUD reads outermost -> innermost.
    for i = #scopes, 1, -1 do
        table.insert(path, scopes[i].label)
    end
    
    local innermost = scopes[1]
    local separator = (config and config.separator) or " -> "


    context.label = "Scope: " .. table.concat(path, separator)
    context.node_type = innermost.node_type
    context.start_line = innermost.start_line
    context.end_line = innermost.end_line
    context.depth = #scopes
    context.path = path
    context.scopes = scopes

    return context
end


function M.get_node_range(node)
    if not node then
        return nil
    end
    
    local start_row, _, end_row, _ = node:range()

    if not is_number(start_row) or not is_number(end_row) then
        return nil
    end
    
    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
end


function M.get_construct_spec(construct_specs, node_type)
    if not is_table(construct_specs) then
        return nil, "construct_specs must be table"
    end

    if type(node_type) ~= "string" or node_type == "" then
        return nil, "node_type must be a non-empty string"
    end

    local spec = construct_specs[node_type]

    if not spec then
        return nil, nil
    end

    local ok, err = M.validate_construct_spec(spec)

    if not ok then
        return nil, err
    end

    return spec, nil

end


function M.validate_construct_spec(spec)
    if not is_table(spec) then
        return false, "construct spec must be a table"
    end

    
    if type(spec.kind) ~= "string" or spec.kind == "" then
        return false, "construct spec kind must be a non-empty string"
    end

    if type(spec.label) ~= "string" or spec.label == "" then
        return false, "construct spec label must be a non-empty string"
    end

    if spec.tokens ~= nil and not is_table(spec.tokens) then
        return false, "construct spec tokens must be a table when provided"
    end

    if spec.markers ~= nil then
        if not is_table(spec.markers) then
            return false, "construct spec markers must be a table when provided"
        end

        local required = spec.markers.required or {}
        local optional = spec.markers.optional or {}

        if not is_table(required) then
            return false, "construct spec markers.required must be a table"
        end

        if not is_table(optional) then
            return false, "construct spec markers.optional must be a table"
        end

        if spec.tokens == nil then
            return false, "construct spec markers require a tokens table"
        end

        for _, marker_name in ipairs(required) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "required marker names must be non-empty strings" 
            end

            if spec.tokens[marker_name] == nil then
                return false, "required marker '" .. marker_name .. "' is missing from tokens"
            end
        end

        for _, marker_name in ipairs(optional) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "optional marker names must be non-empty strings"
            end

            if spec.tokens[marker_name] == nil then
                return false, "optional marker '" .. marker_name .. "' is missing from tokens"
            end
        end

        if spec.markers.total_required ~= nil
            and spec.markers.total_required ~= #required then
            return false, "markers.total_required does not match number of required markers"
        end
    end

    return true, nil
end


return M
