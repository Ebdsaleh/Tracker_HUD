-- lua/tracker_hud/section_layout.lua
--
-- Generic HUD section resolution.
--
-- Section identity is always a stable string ID.
--
-- Core provides the mandatory sections:
--
--     scope
--     scope_members
--     warnings
--
-- Adapters may provide additional section descriptors through:
--
--     adapter.sections
--
-- Presentation controls only which section IDs are visible and in what order:
--
--     adapter.presentation.sections.order
--
-- The resolved layout contains one authoritative descriptor table:
--
--     layout.by_id
--
-- and an ordered list of IDs:
--
--     layout.order
--
-- Code that needs a specific section accesses it by stable ID.
-- Code that renders or cycles sections follows layout.order.

local core = require("tracker_hud.core")

local M = {}


local core_sections = {
    scope = {
        id = "scope",
        label = "Scope",
        core = true,
    },

    scope_members = {
        id = "scope_members",
        label = "Scope Members",
        core = true,
    },

    warnings = {
        id = "warnings",
        label = "Warnings",
        core = true,
    },
}


local core_order = {
    "scope",
    "scope_members",
    "warnings",
}


local function copy_descriptor(section)
    if not core.is_table(section) then
        return nil
    end

    return vim.deepcopy(section)
end


local function copy_order(order)
    local result = {}

    for _, section_id in ipairs(order or {}) do
        table.insert(result, section_id)
    end

    return result
end


local function build_sections_by_id(adapter)
    local by_id = {}

    -- Mandatory Tracker_HUD core sections always exist.
    for section_id, section in pairs(core_sections) do
        by_id[section_id] = copy_descriptor(section)
    end

    if not core.is_table(adapter)
        or not core.is_table(adapter.sections)
    then
        return by_id
    end

    for section_id, section in pairs(adapter.sections) do
        if core.is_non_empty_string(section_id)
            and core.is_table(section)
            and not core_sections[section_id]
        then
            local descriptor = copy_descriptor(section)

            descriptor.id = section_id
            descriptor.core = false

            if not core.is_non_empty_string(descriptor.label) then
                descriptor.label = section_id
            end

            by_id[section_id] = descriptor
        end
    end

    return by_id
end


local function get_requested_order(adapter)
    if not core.is_table(adapter)
        or not core.is_table(adapter.presentation)
        or not core.is_table(adapter.presentation.sections)
        or not core.is_table(adapter.presentation.sections.order)
    then
        return copy_order(core_order)
    end

    return copy_order(adapter.presentation.sections.order)
end


local function append_unique(result, seen, section_id, by_id)
    if not core.is_non_empty_string(section_id)
        or seen[section_id]
        or not by_id[section_id]
    then
        return
    end

    seen[section_id] = true
    table.insert(result, section_id)
end


local function ensure_core_sections(order, by_id)
    local result = {}
    local seen = {}

    -- Scope is always the first fallback insertion.
    if not vim.tbl_contains(order, "scope") then
        append_unique(result, seen, "scope", by_id)
    end

    for _, section_id in ipairs(order) do
        append_unique(result, seen, section_id, by_id)

        -- If Scope Members was omitted, keep its natural core relationship
        -- directly after Scope.
        if section_id == "scope"
            and not vim.tbl_contains(order, "scope_members")
        then
            append_unique(result, seen, "scope_members", by_id)
        end
    end

    -- If Scope was present but Scope Members still has not been inserted,
    -- include it before Warnings where possible.
    if not seen.scope_members then
        local warnings_index = nil

        for index, section_id in ipairs(result) do
            if section_id == "warnings" then
                warnings_index = index
                break
            end
        end

        if warnings_index then
            table.insert(result, warnings_index, "scope_members")
            seen.scope_members = true
        else
            append_unique(result, seen, "scope_members", by_id)
        end
    end

    -- Warnings are mandatory and naturally fall at the end when an adapter
    -- does not explicitly position them.
    append_unique(result, seen, "warnings", by_id)

    return result
end


function M.get_core_sections()
    return vim.deepcopy(core_sections)
end


function M.get_core_order()
    return copy_order(core_order)
end


function M.resolve(adapter)
    local by_id = build_sections_by_id(adapter)
    local requested_order = get_requested_order(adapter)
    local order = ensure_core_sections(requested_order, by_id)

    return {
        by_id = by_id,
        order = order,
        count = #order,
    }
end


return M
