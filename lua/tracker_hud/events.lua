-- lua/tracker_hud/events.lua

-- Event collection entry point.
--
-- Events are meaningful instruction/runtime/API actions that are not always
-- direct register, stack, or heap state.
--
-- Examples:
--   - syscall boundary entered
--   - cpuid processor query
--   - memory fence / serialization instruction
--   - future runtime/API calls such as malloc/free/Instantiate/SpawnActor

local event_model = require("tracker_hud.event_model")

local M = {}

local function add_event(events, seen, opts)
    if type(events) ~= "table" or type(opts) ~= "table" then
        return
    end

    local id = opts.id

    if type(id) ~= "string" or id == "" then
        id = "event:" .. tostring(#events + 1)
    end

    if seen[id] then
        return
    end

    seen[id] = true

    table.insert(events, event_model.new_event(vim.tbl_extend("force", opts, {
        id = id,
    })))
end

local function build_boundary_event_id(boundary_effect, index)
    local source_line = boundary_effect.source_line
        or boundary_effect.source_start_line
        or "unknown"

    local name = boundary_effect.name
        or boundary_effect.kind
        or "boundary"

    return "event:boundary:" .. tostring(source_line) .. ":" .. tostring(index) .. ":" .. tostring(name)
end

local function make_boundary_event_role(boundary_effect)
    local kind = boundary_effect.kind or "boundary"
    local name = boundary_effect.name or kind
    local category = boundary_effect.category or "unknown"

    if kind == "syscall" then
        return "enters syscall boundary: " .. tostring(name)
    end

    return "boundary effect: " .. tostring(name) .. " (" .. tostring(category) .. ")"
end

local function add_boundary_event(events, seen, boundary_effect, index)
    if type(boundary_effect) ~= "table" then
        return
    end

    local event_kind = "boundary_event"

    if boundary_effect.kind == "syscall" then
        event_kind = "syscall_event"
    end

    add_event(events, seen, {
        id = build_boundary_event_id(boundary_effect, index),
        kind = event_kind,
        category = boundary_effect.category or "boundary",
        name = boundary_effect.name or boundary_effect.kind or "boundary",
        role = make_boundary_event_role(boundary_effect),
        source = boundary_effect.source or "boundary_effect",

        source_line = boundary_effect.source_line or boundary_effect.source_start_line,
        source_column = boundary_effect.source_column or boundary_effect.source_start_column,
        source_end_line = boundary_effect.source_end_line,
        source_end_column = boundary_effect.source_end_column,

        metadata = {
            boundary_effect = boundary_effect,
            effect_key = boundary_effect.effect_key,
            reads = boundary_effect.reads or {},
            writes = boundary_effect.writes or {},
        },
    })
end

local function collect_boundary_events(events, seen, context)
    if type(context) ~= "table" or type(context.boundary_effects) ~= "table" then
        return
    end

    for index, boundary_effect in ipairs(context.boundary_effects) do
        add_boundary_event(events, seen, boundary_effect, index)
    end
end

function M.collect(context)
    local events = {}
    local seen = {}

    if type(context) ~= "table" then
        return events
    end

    collect_boundary_events(events, seen, context)

    table.sort(events, function(left, right)
        local left_line = left.source_line
        local right_line = right.source_line

        if left_line and right_line then
            if left_line == right_line then
                return tostring(left.name or "") < tostring(right.name or "")
            end

            return left_line < right_line
        end

        if left_line then
            return true
        end

        if right_line then
            return false
        end

        return tostring(left.name or "") < tostring(right.name or "")
    end)

    return event_model.normalize_events(events)
end

return M
