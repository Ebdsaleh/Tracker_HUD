-- lua/tracker_hud/section_tree.lua
--
-- Generic section tree-node construction helpers.
--
-- Concrete section trees decide which nodes and details exist. This module
-- provides the common HUD tree-node shape plus structured detail-node
-- semantics so derived sections inherit the same visual language instead of
-- reimplementing key/value styling one section at a time.

local core = require("tracker_hud.core")
local visual_language = require("tracker_hud.visual_language")

local M = {}


local function copy_table(value)
    if not core.is_table(value) then
        return {}
    end

    return vim.deepcopy(value)
end


local function parse_detail_label(label)
    if type(label) ~= "string" then
        return nil, nil
    end

    local key, value = label:match("^([^:]+):%s?(.*)$")

    if type(key) ~= "string" then
        return nil, nil
    end

    return key, value or ""
end


local function make_detail_label(key, value)
    return tostring(key) .. ": " .. tostring(value)
end


local function apply_detail_semantics(node, opts)
    opts = opts or {}

    if not core.is_table(node) then
        return node
    end

    local detail_key = opts.detail_key
    local detail_value = opts.detail_value

    if detail_key == nil then
        detail_key, detail_value = parse_detail_label(node.label)
    end

    if detail_key ~= nil then
        node.detail_key = tostring(detail_key)
    end

    if detail_value ~= nil then
        node.detail_value = detail_value
    end

    node.detail_kind = opts.detail_kind or node.detail_kind

    local key_style, value_style = visual_language.detail_styles_for_key(
        node.detail_key,
        node.detail_value,
        opts.semantic_override or opts.style
    )

    node.detail_key_style = opts.detail_key_style
        or node.detail_key_style
        or key_style
    node.detail_value_style = opts.detail_value_style
        or node.detail_value_style
        or value_style

    if opts.style then
        node.style = opts.style
    end

    if opts.metadata then
        node.metadata = copy_table(opts.metadata)
    end

    return node
end


function M.new_node(entry, opts)
    if not core.is_table(entry) then
        return nil
    end

    opts = opts or {}

    return {
        id = opts.id or entry.id,
        kind = opts.kind or entry.kind or "section_entry",
        label = opts.label or entry.label or entry.name or "<unknown>",
        style = opts.style,
        metadata = copy_table(opts.metadata),

        source_line = entry.source_line,
        source_column = entry.source_column or 0,
        source_start_line = entry.source_start_line,
        source_start_column = entry.source_start_column or 0,
        source_end_line = entry.source_end_line,
        source_end_column = entry.source_end_column or entry.source_column or 0,

        children = opts.children or {},
    }
end


function M.new_detail_node(entry, detail_id, label, opts)
    if not core.is_table(entry)
        or not core.is_non_empty_string(detail_id)
    then
        return nil
    end

    opts = opts or {}

    local node = M.new_node(entry, {
        id = opts.id or (entry.id .. ":" .. detail_id),
        kind = opts.kind or "detail",
        label = label,
        style = opts.style,
        metadata = opts.metadata,
        children = {},
    })

    if not node then
        return nil
    end

    node.detail_id = detail_id

    return apply_detail_semantics(node, opts)
end


function M.new_detail(entry, detail_id, key, value, opts)
    if value == nil then
        return nil
    end

    if type(value) == "string" and value == "" then
        return nil
    end

    opts = opts or {}

    return M.new_detail_node(
        entry,
        detail_id,
        opts.label or make_detail_label(key, value),
        vim.tbl_deep_extend("force", opts, {
            detail_key = key,
            detail_value = value,
        })
    )
end


function M.add_detail(children, entry, detail_id, key, value, opts)
    if not core.is_table(children) then
        return nil
    end

    local node = M.new_detail(
        entry,
        detail_id,
        key,
        value,
        opts
    )

    if node then
        table.insert(children, node)
    end

    return node
end


return M
