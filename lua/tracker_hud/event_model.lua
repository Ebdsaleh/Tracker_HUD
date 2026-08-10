-- lua/tracker_hud/event_model.lua

-- Normalizes adapter/context event facts into records the HUD can render.

local M = {}

function M.new_event(opts)
    opts = opts or {}

    return {
        id = opts.id,
        kind = opts.kind or "event",
        category = opts.category or "general",
        name = opts.name or "event",
        role = opts.role,
        source = opts.source,

        source_line = opts.source_line,
        source_column = opts.source_column,
        source_end_line = opts.source_end_line,
        source_end_column = opts.source_end_column,

        metadata = opts.metadata or {},
    }
end

function M.normalize_events(events)
    local normalized = {}

    if type(events) ~= "table" then
        return normalized
    end

    for index, event in ipairs(events) do
        if type(event) == "table" then
            table.insert(normalized, M.new_event({
                id = event.id or ("event:" .. tostring(index)),
                kind = event.kind,
                category = event.category,
                name = event.name,
                role = event.role,
                source = event.source,
                source_line = event.source_line,
                source_column = event.source_column,
                source_end_line = event.source_end_line,
                source_end_column = event.source_end_column,
                metadata = event.metadata,
            }))
        end
    end

    return normalized
end

return M
