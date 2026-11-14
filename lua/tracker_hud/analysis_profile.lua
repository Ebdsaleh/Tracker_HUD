-- lua/tracker_hud/analysis_profile.lua
--
-- Opt-in refresh performance instrumentation.
--
-- This module observes existing Tracker_HUD work. It does not cache facts,
-- change source visibility, alter inference, or decide whether a refresh
-- should run. When disabled, begin_refresh returns nil without reading a clock.

local M = {}

local DEFAULT_MAX_SAMPLES = 256
local DEFAULT_LARGE_JUMP_LINES = 50

local state = {
    enabled = false,
    max_samples = DEFAULT_MAX_SAMPLES,
    large_jump_lines =
        DEFAULT_LARGE_JUMP_LINES,
    samples = {},
    refresh_count = 0,
    reasons = {},
    phases = {},
    last_cursor_by_buffer = {},
    seen_buffers = {},
}


local function now_ns()
    local uv = vim.uv or vim.loop

    if uv and type(uv.hrtime)
        == "function"
    then
        return uv.hrtime()
    end

    return 0
end


local function positive_integer(
    value,
    fallback
)
    local number = tonumber(value)

    if not number then
        return fallback
    end

    number = math.floor(number)

    if number < 1 then
        return fallback
    end

    return number
end


local function copy_table(value)
    local result = {}

    if type(value) ~= "table" then
        return result
    end

    for key, item in pairs(value) do
        result[key] = item
    end

    return result
end


local function milliseconds(delta_ns)
    return (tonumber(delta_ns) or 0)
        / 1000000
end


local function add_phase_stat(
    name,
    value_ms
)
    local phase =
        state.phases[name]
        or {
            count = 0,
            total_ms = 0,
            min_ms = nil,
            max_ms = nil,
        }

    phase.count = phase.count + 1
    phase.total_ms =
        phase.total_ms + value_ms

    phase.min_ms =
        phase.min_ms == nil
        and value_ms
        or math.min(
            phase.min_ms,
            value_ms
        )

    phase.max_ms =
        phase.max_ms == nil
        and value_ms
        or math.max(
            phase.max_ms,
            value_ms
        )

    state.phases[name] = phase
end


local function cursor_line(cursor)
    if type(cursor) ~= "table" then
        return nil
    end

    local line = tonumber(
        cursor[1]
        or cursor.line
    )

    return line
        and math.floor(line)
        or nil
end


local function cursor_column(cursor)
    if type(cursor) ~= "table" then
        return nil
    end

    local column = tonumber(
        cursor[2]
        or cursor.column
    )

    return column
        and math.floor(column)
        or nil
end


local function normalize_event(
    event_name
)
    if type(event_name) ~= "string"
        or event_name == ""
    then
        return "manual"
    end

    return event_name
end


function M.configure(opts)
    opts = type(opts) == "table"
        and opts
        or {}

    state.enabled =
        opts.enabled == true

    state.max_samples =
        positive_integer(
            opts.max_samples,
            DEFAULT_MAX_SAMPLES
        )

    state.large_jump_lines =
        positive_integer(
            opts.large_jump_lines,
            DEFAULT_LARGE_JUMP_LINES
        )

    M.reset()
end


function M.set_enabled(value)
    state.enabled =
        value == true

    return state.enabled
end


function M.is_enabled()
    return state.enabled
end


function M.reset()
    state.samples = {}
    state.refresh_count = 0
    state.reasons = {}
    state.phases = {}
    state.last_cursor_by_buffer = {}
    state.seen_buffers = {}
end


function M.classify_reason(
    event_name,
    bufnr,
    cursor
)
    local event =
        normalize_event(event_name)

    local line =
        cursor_line(cursor)

    local previous =
        bufnr
        and state
            .last_cursor_by_buffer[
                bufnr
            ]
        or nil

    local seen =
        bufnr
        and state.seen_buffers[bufnr]
        or false

    if not seen then
        return "first_refresh",
            previous
                and line
                and math.abs(
                    line - previous
                )
                or nil
    end

    if event == "TextChanged"
        or event == "TextChangedI"
    then
        return "edit", 0
    end

    if event == "BufWinEnter" then
        return "buffer_enter", 0
    end

    if event == "CursorMoved"
        or event == "CursorMovedI"
    then
        local delta =
            previous
            and line
            and math.abs(
                line - previous
            )
            or 0

        if delta >= state
            .large_jump_lines
        then
            return "cursor_large_jump",
                delta
        end

        if delta == 1 then
            return "cursor_step",
                delta
        end

        if delta > 1 then
            return "cursor_move",
                delta
        end

        return "cursor_same_line",
            delta
    end

    return "manual",
        previous
            and line
            and math.abs(
                line - previous
            )
            or nil
end


function M.begin_refresh(
    event_name,
    bufnr,
    cursor,
    timestamp_ns
)
    if not state.enabled then
        return nil
    end

    local reason,
        line_delta =
        M.classify_reason(
            event_name,
            bufnr,
            cursor
        )

    return {
        event =
            normalize_event(
                event_name
            ),
        reason = reason,
        bufnr = bufnr,
        cursor_line =
            cursor_line(cursor),
        cursor_column =
            cursor_column(cursor),
        line_delta = line_delta,
        started_ns =
            timestamp_ns
            or now_ns(),
        phases = {},
        phase_started = {},
        finished = false,
    }
end


function M.begin_phase(
    token,
    name,
    timestamp_ns
)
    if type(token) ~= "table"
        or token.finished == true
        or type(name) ~= "string"
        or name == ""
    then
        return nil
    end

    local started =
        timestamp_ns
        or now_ns()

    token.phase_started[name] =
        started

    return started
end


function M.end_phase(
    token,
    name,
    started_ns,
    timestamp_ns
)
    if type(token) ~= "table"
        or token.finished == true
        or type(name) ~= "string"
        or name == ""
    then
        return nil
    end

    local started =
        started_ns
        or token.phase_started[name]

    if not tonumber(started) then
        return nil
    end

    local finished =
        timestamp_ns
        or now_ns()

    local value_ms =
        milliseconds(
            finished - started
        )

    token.phases[name] =
        value_ms

    token.phase_started[name] = nil

    return value_ms
end


function M.finish_refresh(
    token,
    outcome,
    timestamp_ns
)
    if type(token) ~= "table"
        or token.finished == true
    then
        return nil
    end

    token.finished = true

    local finished =
        timestamp_ns
        or now_ns()

    token.total_ms =
        milliseconds(
            finished
                - token.started_ns
        )

    outcome =
        type(outcome) == "table"
        and outcome
        or {}

    token.updated =
        outcome.updated ~= false
    token.failed =
        outcome.failed == true

    state.refresh_count =
        state.refresh_count + 1

    state.reasons[token.reason] =
        (state.reasons[
            token.reason
        ] or 0) + 1

    add_phase_stat(
        "total",
        token.total_ms
    )

    for name, value_ms in pairs(
        token.phases
    ) do
        add_phase_stat(
            name,
            value_ms
        )
    end

    table.insert(
        state.samples,
        {
            event = token.event,
            reason = token.reason,
            bufnr = token.bufnr,
            cursor_line =
                token.cursor_line,
            cursor_column =
                token.cursor_column,
            line_delta =
                token.line_delta,
            total_ms =
                token.total_ms,
            phases =
                copy_table(
                    token.phases
                ),
            updated =
                token.updated,
            failed =
                token.failed,
        }
    )

    while #state.samples
        > state.max_samples
    do
        table.remove(
            state.samples,
            1
        )
    end

    if token.bufnr then
        state.seen_buffers[
            token.bufnr
        ] = true

        if token.cursor_line then
            state
                .last_cursor_by_buffer[
                    token.bufnr
                ] = token.cursor_line
        end
    end

    return token.total_ms
end


function M.snapshot()
    local phases = {}

    for name, phase in pairs(
        state.phases
    ) do
        phases[name] = {
            count = phase.count,
            total_ms =
                phase.total_ms,
            min_ms = phase.min_ms,
            max_ms = phase.max_ms,
            average_ms =
                phase.count > 0
                and phase.total_ms
                    / phase.count
                or 0,
        }
    end

    local samples = {}

    for index, sample in ipairs(
        state.samples
    ) do
        samples[index] = {
            event = sample.event,
            reason = sample.reason,
            bufnr = sample.bufnr,
            cursor_line =
                sample.cursor_line,
            cursor_column =
                sample.cursor_column,
            line_delta =
                sample.line_delta,
            total_ms =
                sample.total_ms,
            phases =
                copy_table(
                    sample.phases
                ),
            updated =
                sample.updated,
            failed =
                sample.failed,
        }
    end

    return {
        enabled = state.enabled,
        max_samples =
            state.max_samples,
        large_jump_lines =
            state.large_jump_lines,
        refresh_count =
            state.refresh_count,
        reasons =
            copy_table(
                state.reasons
            ),
        phases = phases,
        samples = samples,
    }
end


local function sorted_keys(value)
    local keys = {}

    for key, _ in pairs(
        value or {}
    ) do
        table.insert(keys, key)
    end

    table.sort(keys)

    return keys
end


function M.format_report(opts)
    opts = type(opts) == "table"
        and opts
        or {}

    local snapshot =
        M.snapshot()

    local lines = {
        "Tracker_HUD profile: "
            .. (
                snapshot.enabled
                and "on"
                or "off"
            )
            .. ", "
            .. tostring(
                snapshot.refresh_count
            )
            .. " refresh(es)",
    }

    local reason_parts = {}

    for _, name in ipairs(
        sorted_keys(
            snapshot.reasons
        )
    ) do
        table.insert(
            reason_parts,
            name
                .. "="
                .. tostring(
                    snapshot.reasons[name]
                )
        )
    end

    if #reason_parts > 0 then
        table.insert(
            lines,
            "Reasons: "
                .. table.concat(
                    reason_parts,
                    ", "
                )
        )
    end

    for _, name in ipairs(
        sorted_keys(
            snapshot.phases
        )
    ) do
        local phase =
            snapshot.phases[name]

        table.insert(
            lines,
            string.format(
                "%s: n=%d avg=%.3f ms max=%.3f ms",
                name,
                phase.count,
                phase.average_ms,
                phase.max_ms or 0
            )
        )
    end

    local recent =
        positive_integer(
            opts.recent,
            16
        )

    local first =
        math.max(
            1,
            #snapshot.samples
                - recent
                + 1
        )

    for index = first,
        #snapshot.samples
    do
        local sample =
            snapshot.samples[index]

        local phase_parts = {}

        for _, name in ipairs({
            "context",
            "state",
            "render",
            "hex",
        }) do
            local value =
                sample.phases[name]

            if value ~= nil then
                table.insert(
                    phase_parts,
                    string.format(
                        "%s=%.3f",
                        name,
                        value
                    )
                )
            end
        end

        local nested = {}

        for name, value in pairs(
            sample.phases
        ) do
            if name ~= "context"
                and name ~= "state"
                and name ~= "render"
                and name ~= "hex"
            then
                table.insert(
                    nested,
                    {
                        name = name,
                        value = value,
                    }
                )
            end
        end

        table.sort(
            nested,
            function(left, right)
                if left.value
                    == right.value
                then
                    return left.name
                        < right.name
                end

                return left.value
                    > right.value
            end
        )

        local nested_parts = {}

        for nested_index = 1,
            math.min(
                #nested,
                4
            )
        do
            local item =
                nested[nested_index]

            table.insert(
                nested_parts,
                string.format(
                    "%s=%.3f",
                    item.name,
                    item.value
                )
            )
        end

        table.insert(
            lines,
            string.format(
                "#%d %s line=%s delta=%s total=%.3f ms%s%s",
                index,
                sample.reason,
                tostring(
                    sample.cursor_line
                        or "?"
                ),
                tostring(
                    sample.line_delta
                        or "-"
                ),
                sample.total_ms,
                #phase_parts > 0
                    and " ["
                        .. table.concat(
                            phase_parts,
                            " "
                        )
                        .. "]"
                    or "",
                #nested_parts > 0
                    and " top=["
                        .. table.concat(
                            nested_parts,
                            " "
                        )
                        .. "]"
                    or ""
            )
        )
    end

    return lines
end


return M
