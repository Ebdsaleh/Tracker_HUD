-- lua/tracker_hud/low_level/memory_address.lua
--
-- Architecture-neutral normalized memory-address structure.
--
-- Adapters/parsers remain responsible for identifying source components.
-- This module turns those parser observations into a stable semantic shape
-- without inventing an effective runtime address.

local integer_value = require("tracker_hud.low_level.integer_value")

local M = {}

local function copy_source(component)
    if type(component) ~= "table" then
        return nil
    end

    return {
        line = component.source_line,
        column = component.source_column,
        start_line = component.source_start_line,
        start_column = component.source_start_column,
        end_line = component.source_end_line,
        end_column = component.source_end_column,
    }
end

local function normalize_component(component)
    if type(component) ~= "table"
        or type(component.text) ~= "string"
        or component.text == ""
    then
        return nil
    end

    local structural_role = component.structural_role
        or component.role

    local normalized = {
        text = component.text,
        kind = component.kind,
        role = structural_role,
        display_role = component.role,
        role_label = component.role_label,
        source = copy_source(component),
        value = nil,
        resolved = nil,
    }

    if structural_role == "scale"
        or structural_role == "displacement"
    then
        normalized.value = integer_value.normalize(component.text)
        normalized.resolved = normalized.value ~= nil
        normalized.value_status = normalized.resolved
            and "known"
            or "unknown"
    elseif component.kind == "register"
        or structural_role == "base_register"
        or structural_role == "index_register"
    then
        normalized.name = component.text:lower()
        normalized.identity_known = true
        normalized.value_status = "not_evaluated"
    elseif structural_role == "symbol"
        or component.kind == "symbol"
    then
        normalized.name = component.text
        normalized.identity_known = true
        normalized.value_status = "not_evaluated"
    end

    return normalized
end

local function assign_unique(result, key, component)
    if result[key] == nil then
        result[key] = component
        return
    end

    result.metadata.ambiguous[key] = true
end

function M.normalize(memory)
    if type(memory) ~= "table" then
        return nil
    end

    local result = {
        version = 1,
        kind = memory.kind or "memory",
        container_kind = memory.container_kind or "memory",
        address_kind = memory.address_kind or "address_expression",

        address_text = memory.address_text,
        address_mode = memory.address_mode or "default",
        address_mode_token = memory.address_mode_token,

        memory_size_bits = type(memory.size) == "table"
            and memory.size.bits
            or nil,
        memory_size_prefix = type(memory.size) == "table"
            and memory.size.prefix
            or nil,
        memory_size_label = type(memory.size) == "table"
            and memory.size.label
            or nil,

        base = nil,
        index = nil,
        scale = nil,
        displacement = nil,
        symbol = nil,

        terms = {},

        source = {
            line = memory.source_line,
            start_column = memory.address_start_column,
            end_column = memory.address_end_column,
        },

        metadata = {
            effective_address = "unknown",
            runtime_address = "unknown",
            ambiguous = {},
        },
    }

    for _, raw_component in ipairs(memory.components or {}) do
        local component = normalize_component(raw_component)

        if component then
            result.terms[#result.terms + 1] = component

            if component.role == "base_register" then
                assign_unique(result, "base", component)
            elseif component.role == "index_register" then
                assign_unique(result, "index", component)
            elseif component.role == "scale" then
                assign_unique(result, "scale", component)
            elseif component.role == "displacement" then
                assign_unique(result, "displacement", component)
            elseif component.role == "symbol" then
                assign_unique(result, "symbol", component)
            end
        end
    end

    return result
end

return M
