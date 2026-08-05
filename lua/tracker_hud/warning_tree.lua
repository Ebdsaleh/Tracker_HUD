-- lua/tracker_hud/warning_tree.lua
--
-- Warning tree model for Tracker HUD.
--
-- warnings.lua collects warning facts.
-- warning_tree.lua turns those facts into expandable HUD nodes.

local M = {}


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



local function append_source_children(children, warning)
    if warning.source_line then
        table.insert(children, {
            id = warning.id .. ":source_line",
            label = "line: " .. tostring(warning.source_line),
            kind = "warning_detail",
            source_line = warning.source_line,
            source_column = warning.source_column,
        })
    end


    if warning.source ~= nil then
        table.insert(children, {
            id = warning.id .. ":source",
            label = "source: " .. tostring(warning.source),
            kind = "warning_detail",
            source_line = warning.source_line,
            source_column = warning.source_column,
        })
    end
end



local function append_metadata_children(children, warning)
    local metadata = warning.metadata

    if type(metadata) ~= "table" then
        return
    end

    for key, value in pairs(metadata) do
        if value ~= nil then
            table.insert(children, {
                id = warning.id .. ":metadata:" .. tostring(key),
                label = tostring(key) .. ": " .. tostring(value),
                kind = "warning_detail",
                source_line = warning.source_line,
                source_column = warning.source_column,
            })
        end
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
