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
            not_preserved = boundary_effect.not_preserved or {},
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


local function build_instruction_event_id(instruction_event, index)
    local source_line = instruction_event.source_line
        or instruction_event.source_start_line
        or "unknown"

    local name = instruction_event.name
        or instruction_event.kind
        or "instruction"

    return "event:instruction:" .. tostring(source_line) .. ":" .. tostring(index) .. ":" .. tostring(name)
end


local function add_instruction_event(events, seen, instruction_event, index)
    if type(instruction_event) ~= "table" then
        return
    end

    add_event(events, seen, {
        id = build_instruction_event_id(instruction_event, index),
        kind = instruction_event.kind or "instruction_event",
        category = instruction_event.category or "instruction",
        name = instruction_event.name or instruction_event.kind or "instruction",
        role = instruction_event.role,
        source = instruction_event.source or "instruction",

        source_line = instruction_event.source_line or instruction_event.source_start_line,
        source_column = instruction_event.source_column or instruction_event.source_start_column,
        source_end_line = instruction_event.source_end_line,
        source_end_column = instruction_event.source_end_column,

        metadata = vim.tbl_extend(
            "force",
            instruction_event.metadata or {},
            {
                instruction_event = instruction_event,
            }
        ),
    })
end


local function collect_instruction_events(events, seen, context)
    if type(context) ~= "table" or type(context.instruction_events) ~= "table" then
        return
    end

    for index, instruction_event in ipairs(context.instruction_events) do
        add_instruction_event(events, seen, instruction_event, index)
    end
end


function M.collect(context)
    local events = {}
    local seen = {}

    if type(context) ~= "table" then
        return events
    end

    collect_boundary_events(events, seen, context)
    collect_instruction_events(events, seen, context)

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
