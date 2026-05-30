-- lua/tracker_hud/construct_utils.lua
--
-- Adapter-backed construct/value helpers.
--
-- These helpers interpret Tree-sitter nodes using the active language adapter.
-- They should stay generic and avoid Scope Members-specific behavior.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")

local M = {}


function M.get_construct_spec(node, adapter)
    if not node or not core.is_table(adapter) or not core.is_table(adapter.construct_specs) then
        return nil
    end

    return adapter.construct_specs[node:type()]
end


function M.get_value_spec_from_node(node, adapter)
    local spec = M.get_construct_spec(node, adapter)

    if not core.is_table(spec) or not core.is_table(spec.value) then
        return nil
    end

    return spec.value
end


function M.build_value_metadata(value_node, bufnr, adapter)
    local metadata = {
        value_text = nil,
        value_node_type = nil,
        value_start_line = nil,
        value_end_line = nil,
        value_kind = nil,
        type_label = nil,
    }

    if not value_node then
        return metadata
    end

    metadata.value_text = ts_utils.get_node_text(value_node, bufnr)
    metadata.value_node_type = value_node:type()

    local value_range = ts_utils.get_node_range_fields(value_node)
    metadata.value_start_line = value_range.start_line
    metadata.value_end_line = value_range.end_line

    local value_spec = M.get_value_spec_from_node(value_node, adapter)

    if core.is_table(value_spec) then
        metadata.value_kind = value_spec.kind
        metadata.type_label = value_spec.type_label
    end

    return metadata
end


function M.node_creates_lexical_scope(node, adapter)
    local spec = M.get_construct_spec(node, adapter)

    if not core.is_table(spec) or not core.is_table(spec.scope) then
        return false
    end

    return spec.scope.kind == "lexical"
        and spec.scope.affects_visibility == true
end


function M.node_creates_structural_scope(node, adapter)
    local spec = M.get_construct_spec(node, adapter)

    if not core.is_table(spec) or not core.is_table(spec.scope) then
        return false
    end

    return spec.scope.kind == "structural"
        and spec.scope.owns_members == true
end


return M
