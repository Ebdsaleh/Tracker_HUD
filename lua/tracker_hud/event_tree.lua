-- lua/tracker_hud/event_tree.lua

-- Builds HUD tree nodes for normalized Events.

local M = {}


local function make_event_label(event)
    local category = event.category or "general"
    local name = event.name or "event"

    if event.role and event.role ~= "" then
        return "(" .. category .. ") " .. name .. " - " .. event.role
    end

    return "(" .. category .. ") " .. name
end


local function as_table(value)
    if type(value) == "table" then
        return value
    end

    return {}
end


local function append_detail(node, id_suffix, label)
    if type(node) ~= "table" or type(label) ~= "string" or label == "" then
        return
    end

    table.insert(node.children, {
        id = tostring(node.id or "event") .. ":" .. id_suffix,
        label = label,
        kind = "detail",
        children = {},
    })
end


local function format_value(value, resolved)
    if value == nil or resolved == false then
        return "<unknown>"
    end

    return tostring(value)
end


local function get_boundary_effect(event)
    local metadata = as_table(event and event.metadata)

    if type(metadata.boundary_effect) == "table" then
        return metadata.boundary_effect
    end

    return nil
end


local function get_known_boundary_effect(event)
    local boundary_effect = get_boundary_effect(event)

    if type(boundary_effect) == "table"
        and type(boundary_effect.known_effect) == "table"
    then
        return boundary_effect.known_effect
    end

    return nil
end


local function index_required_arguments(known_effect)
    local result = {}

    if type(known_effect) ~= "table"
        or type(known_effect.required_arguments) ~= "table"
    then
        return nil
    end

    for _, argument_index in ipairs(known_effect.required_arguments) do
        local numeric_index = tonumber(argument_index)

        if numeric_index then
            result[numeric_index] = true
        end
    end

    return result
end


local function read_is_relevant_for_known_boundary(event, read)
    if type(read) ~= "table" then
        return false
    end

    if read.role ~= "argument" then
        return true
    end

    local known_effect = get_known_boundary_effect(event)

    if type(known_effect) ~= "table" then
        return true
    end

    local required_arguments = index_required_arguments(known_effect)

    if type(required_arguments) ~= "table" then
        return true
    end

    return required_arguments[tonumber(read.index)] == true
end


local function get_read_argument_name(event, read)
    if type(read) ~= "table" or read.index == nil then
        return nil
    end

    local boundary_effect = get_boundary_effect(event)

    if type(boundary_effect) ~= "table"
        or type(boundary_effect.known_effect) ~= "table"
        or type(boundary_effect.known_effect.argument_names) ~= "table"
    then
        return nil
    end

    return boundary_effect.known_effect.argument_names[tonumber(read.index)]
end


local function format_read_label(event, read)
    if type(read) ~= "table" then
        return nil
    end

    local register = read.register or read.location or "<unknown>"
    local value = format_value(read.value, read.resolved)

    if read.role == "number" then
        return "read syscall number: " .. tostring(register) .. " = " .. value
    end

    if read.role == "argument" then
        local argument_label = "argument " .. tostring(read.index or "?")
        local argument_name = get_read_argument_name(event, read)

        if type(argument_name) == "string" and argument_name ~= "" then
            argument_label = argument_label .. " " .. argument_name
        end

        return "read " .. argument_label .. ": " .. tostring(register) .. " = " .. value
    end

    local role = read.role or "input"

    return "read " .. tostring(role) .. ": " .. tostring(register) .. " = " .. value
end


local function format_write_label(write)
    if type(write) ~= "table" then
        return nil
    end

    local register = write.register or write.location or "<unknown>"
    local role = write.role or "output"

    if write.value ~= nil then
        return "write " .. tostring(role) .. ": " .. tostring(register) .. " = " .. tostring(write.value)
    end

    return "write " .. tostring(role) .. ": " .. tostring(register)
end


local function format_not_preserved_label(entry)
    if type(entry) ~= "table" then
        return nil
    end

    local register = entry.register or entry.location or "<unknown>"
    local label = "not preserved after: " .. tostring(register)

    if entry.previous_value ~= nil and entry.previous_resolved ~= false then
        label = label .. " (previous = " .. tostring(entry.previous_value) .. ")"
    end

    return label
end


local function append_boundary_io_details(node, event)
    local metadata = as_table(event and event.metadata)
    local reads = as_table(metadata.reads)
    local writes = as_table(metadata.writes)
    local not_preserved = as_table(metadata.not_preserved)

    for index, read in ipairs(reads) do
        if read_is_relevant_for_known_boundary(event, read) then
            local label = format_read_label(event, read)

            if label then
                append_detail(node, "read:" .. tostring(index), label)
            end
        end
    end

    for index, write in ipairs(writes) do
        local label = format_write_label(write)

        if label then
            append_detail(node, "write:" .. tostring(index), label)
        end
    end

    for index, entry in ipairs(not_preserved) do
        local label = format_not_preserved_label(entry)

        if label then
            append_detail(node, "not_preserved:" .. tostring(index), label)
        end
    end
end


local function append_base_details(node, event)
    if event.role and event.role ~= "" then
        append_detail(node, "role", "role: " .. event.role)
    end

    if event.source and event.source ~= "" then
        append_detail(node, "source", "source: " .. event.source)
    end
end


function M.build(events)
    local nodes = {}

    if type(events) ~= "table" then
        return nodes
    end

    for _, event in ipairs(events) do
        if type(event) == "table" then
            local node = {
                id = event.id,
                label = make_event_label(event),
                kind = event.kind or "event",
                category = event.category,
                source_line = event.source_line,
                source_column = event.source_column,
                source_end_line = event.source_end_line,
                source_end_column = event.source_end_column,
                children = {},
                default_expanded = false,
                metadata = event.metadata or {},
                event = event,
            }

            append_base_details(node, event)
            append_boundary_io_details(node, event)

            table.insert(nodes, node)
        end
    end

    return nodes
end

return M
