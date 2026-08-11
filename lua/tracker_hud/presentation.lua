-- lua/tracker_hud/presentation.lua
--
-- Generic adapter-backed presentation helpers.
--
-- Adapters describe presentation.
-- Core sections consume those descriptions.
--
-- This module knows nothing about x86, ARM, Registers, Stack, Heap, or any
-- other architecture/section-specific semantics.

local core = require("tracker_hud.core")

local M = {}


local function normalized_text(value)
    return tostring(value or ""):lower()
end


local function natural_parts(value)
    local text = normalized_text(value)

    local prefix, number, suffix = text:match("^(.-)(%d+)(.*)$")

    if not prefix then
        return text, nil, ""
    end

    return prefix, tonumber(number), suffix
end


local function compare_alphabetical(left, right)
    return normalized_text(left.name) < normalized_text(right.name)
end


local function compare_natural(left, right)
    local left_name = normalized_text(left.name)
    local right_name = normalized_text(right.name)

    local left_prefix, left_number, left_suffix =
        natural_parts(left_name)

    local right_prefix, right_number, right_suffix =
        natural_parts(right_name)

    if left_prefix ~= right_prefix then
        return left_prefix < right_prefix
    end

    if left_number ~= nil
        and right_number ~= nil
        and left_number ~= right_number
    then
        return left_number < right_number
    end

    if left_number ~= nil and right_number == nil then
        return false
    end

    if left_number == nil and right_number ~= nil then
        return true
    end

    if left_suffix ~= right_suffix then
        return left_suffix < right_suffix
    end

    return left_name < right_name
end


local function build_custom_positions(custom_order)
    local positions = {}

    for index, name in ipairs(custom_order or {}) do
        if core.is_non_empty_string(name) then
            positions[name:lower()] = index
        end
    end

    return positions
end


local function compare_custom(left, right, custom_order)
    local positions = build_custom_positions(custom_order)

    local left_name = normalized_text(left.name)
    local right_name = normalized_text(right.name)

    local left_position = positions[left_name]
    local right_position = positions[right_name]

    if left_position and right_position then
        return left_position < right_position
    end

    if left_position then
        return true
    end

    if right_position then
        return false
    end

    -- Items not explicitly listed still receive deterministic,
    -- human-friendly ordering.
    return compare_natural(left, right)
end


function M.sort_items(items, item_order, custom_order)
    if not core.is_table(items) then
        return items
    end

    local order = item_order or "natural"

    if order == "alphabetical" then
        table.sort(items, compare_alphabetical)
        return items
    end

    if order == "custom" then
        table.sort(items, function(left, right)
            return compare_custom(left, right, custom_order)
        end)

        return items
    end

    -- "natural" is the generic default.
    table.sort(items, compare_natural)

    return items
end


local function list_contains(values, wanted)
    if not core.is_table(values) then
        return false
    end

    local normalized_wanted = normalized_text(wanted)

    for _, value in ipairs(values) do
        if normalized_text(value) == normalized_wanted then
            return true
        end
    end

    return false
end


function M.item_matches_group(item, group)
    if not core.is_table(item) or not core.is_table(group) then
        return false
    end

    local match = group.match

    if not core.is_table(match) then
        return false
    end

    if core.is_table(match.names)
        and list_contains(match.names, item.name)
    then
        return true
    end

    if core.is_table(match.kinds)
        and list_contains(match.kinds, item.kind)
    then
        return true
    end

    local metadata = item.metadata or {}
    local family_name = metadata.family_name

    if core.is_table(match.families)
        and list_contains(match.families, family_name)
    then
        return true
    end

    return false
end


function M.find_group(item, layout)
    if not core.is_table(layout)
        or not core.is_table(layout.groups)
    then
        return nil, nil
    end

    for index, group in ipairs(layout.groups) do
        if M.item_matches_group(item, group) then
            return group, index
        end
    end

    return nil, nil
end


function M.resolve_section(adapter, section_name, requested_layout)
    if not core.is_table(adapter)
        or not core.is_table(adapter.presentation)
        or not core.is_non_empty_string(section_name)
    then
        return nil, nil
    end

    local section = adapter.presentation[section_name]

    if not core.is_table(section) then
        return nil, nil
    end

    if not core.is_table(section.layouts) then
        return section, nil
    end

    local layout_name = requested_layout

    if not core.is_non_empty_string(layout_name) then
        layout_name = section.default_layout
    end

    if core.is_non_empty_string(layout_name)
        and core.is_table(section.layouts[layout_name])
    then
        return section.layouts[layout_name], layout_name
    end

    return nil, nil
end


return M
