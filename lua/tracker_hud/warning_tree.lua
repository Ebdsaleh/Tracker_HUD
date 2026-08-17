-- lua/tracker_hud/warning_tree.lua
--
-- Warning tree model for Tracker HUD.
--
-- warnings.lua collects warning facts.
-- warning_tree.lua turns those facts into expandable HUD nodes.
--
-- Warning detail nodes retain structured key/value meaning so the HUD can
-- target individual pieces for presentation without reparsing display text.

local M = {}


local PREFERRED_METADATA_ORDER = {
    "register",
    "argument_index",
    "argument_name",
    "value",
    "boundary_name",
    "boundary_kind",
    "rule_source",
    "rule_check",
    "resolved",
}


local function warning_id(warning, index)
    local category = warning.category or "state"
    local line = warning.source_line or "unknown"
    local message = warning.message or "warning"

    return table.concat({
        "warning",
        tostring(category),
        tostring(line),
        tostring(index),
        tostring(message),
    }, ":")
end


local function build_warning_label(warning)
    local severity = warning.severity or "warning"
    local category = warning.category or "state"
    local message = warning.message or "<warning>"

    return "("
        .. tostring(severity)
        .. " "
        .. tostring(category)
        .. ") "
        .. tostring(message)
end


local function detail_kind_for_key(key)
    key = tostring(key or "")

    if key == "line" or key == "source_line" then
        return "line"
    end

    if key == "source" then
        return "source"
    end

    if key == "register" then
        return "register"
    end

    if key == "boundary_name" or key == "boundary_kind" then
        return "boundary"
    end

    if key == "rule_source" or key == "rule_check" then
        return "rule"
    end

    if key == "resolved" then
        return "resolution"
    end

    if key == "argument_index" then
        return "argument_index"
    end

    if key == "argument_name" then
        return "argument_name"
    end

    if key == "value" then
        return "value"
    end

    return "metadata"
end


local function build_warning_detail_node(warning, key, value, id_suffix)
    if value == nil then
        return nil
    end

    local display_key = tostring(key)
    local display_value = tostring(value)

    return {
        id = warning.id .. ":" .. tostring(id_suffix or key),
        label = display_key .. ": " .. display_value,
        kind = "warning_detail",

        -- Structured warning-detail facts for semantic span rendering.
        warning = warning,
        detail_key = display_key,
        detail_value = value,
        detail_kind = detail_kind_for_key(display_key),

        source_line = warning.source_line,
        source_column = warning.source_column,
    }
end


local function append_source_children(children, warning)
    if warning.source_line then
        local node = build_warning_detail_node(
            warning,
            "line",
            warning.source_line,
            "source_line"
        )

        if node then
            table.insert(children, node)
        end
    end

    if warning.source ~= nil then
        local node = build_warning_detail_node(
            warning,
            "source",
            warning.source,
            "source"
        )

        if node then
            table.insert(children, node)
        end
    end
end


local function append_metadata_entry(children, warning, key, value)
    local node = build_warning_detail_node(
        warning,
        key,
        value,
        "metadata:" .. tostring(key)
    )

    if node then
        table.insert(children, node)
    end
end


local function append_metadata_children(children, warning)
    local metadata = warning.metadata

    if type(metadata) ~= "table" then
        return
    end

    local used = {}

    -- Important warning facts appear in a stable, readable order rather than
    -- depending on Lua table iteration order.
    for _, key in ipairs(PREFERRED_METADATA_ORDER) do
        if metadata[key] ~= nil then
            append_metadata_entry(
                children,
                warning,
                key,
                metadata[key]
            )
            used[key] = true
        end
    end

    local remaining_keys = {}

    for key, value in pairs(metadata) do
        if value ~= nil and not used[key] then
            table.insert(remaining_keys, tostring(key))
        end
    end

    table.sort(remaining_keys)

    for _, key in ipairs(remaining_keys) do
        append_metadata_entry(
            children,
            warning,
            key,
            metadata[key]
        )
    end
end


local function build_warning_node(warning, index)
    if type(warning) ~= "table" then
        return nil
    end

    local id = warning_id(warning, index)
    warning.id = id

    local children = {}

    append_source_children(children, warning)
    append_metadata_children(children, warning)

    return {
        id = id,
        label = build_warning_label(warning),
        kind = "warning",
        warning = warning,

        source_line = warning.source_line,
        source_column = warning.source_column,

        source_start_line = warning.source_start_line,
        source_start_column = warning.source_start_column,
        source_end_line = warning.source_end_line,
        source_end_column = warning.source_end_column,

        children = children,
    }
end


function M.build(warnings, _context)
    local nodes = {}

    for index, warning in ipairs(warnings or {}) do
        local node = build_warning_node(warning, index)

        if node then
            table.insert(nodes, node)
        elseif type(warning) == "string" then
            table.insert(nodes, {
                id = "warning:string:" .. tostring(index),
                label = warning,
                kind = "warning",
                children = {},
            })
        end
    end

    return nodes
end


return M

