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

            if event.role and event.role ~= "" then
                table.insert(node.children, {
                    id = event.id .. ":role",
                    label = "role: " .. event.role,
                    kind = "detail",
                    children = {},
                })
            end

            if event.source and event.source ~= "" then
                table.insert(node.children, {
                    id = event.id .. ":source",
                    label = "source: " .. event.source,
                    kind = "detail",
                    children = {},
                })
            end

            table.insert(nodes, node)
        end
    end

    return nodes
end

return M

