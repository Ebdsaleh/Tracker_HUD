-- lua/tracker_hud/section.lua
--
-- Fundamental Tracker_HUD section blueprint.
--
-- This module defines the common identity and inheritance mechanics shared by
-- all section templates and concrete section implementations.
--
-- It does not collect context, build models, build trees, or define
-- section-category behaviour. Those responsibilities belong to derived
-- templates and concrete sections.

local core = require("tracker_hud.core")

local M = {}


local function copy_table(value)
    if not core.is_table(value) then
        return {}
    end

    return vim.deepcopy(value)
end


function M.new(opts) 
    opts = opts or {}

    return {
        id = opts.id,
        label = opts.label,

        category = opts.category,
        abstract = opts.abstract == true,

        metadata = copy_table(opts.metadata),
    }
end


function M.extend(parent, overrides)
    if not core.is_table(parent) then
        return nil
    end

    overrides = overrides or {}

    local derived = vim.deepcopy(parent)

    for key, value in pairs(overrides) do
        if core.is_table(value) and core.is_table(derived[key]) then
            derived[key] = vim.tbl_deep_extend(
                "force",
                derived[key],
                vim.deepcopy(value)
            )
        else
            derived[key] = vim.deepcopy(value)
        end
    end

    return derived
end


function M.is_valid(section)
    if not core.is_table(section) then
        return false
    end

    -- Abstract templates do not need concrete section identity.
    if section.abstract == true then
        return true
    end

    return core.is_non_empty_string(section.id)
        and core.is_non_empty_string(section.label)
end


return M
