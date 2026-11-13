-- lua/tracker_hud/syntax_spec.lua
--
-- Shared adapter syntax-spec accessors.
--
-- This module owns only read-only access to adapter syntax declarations plus
-- mnemonic normalization. It does not parse source nodes or apply semantics.

local core = require("tracker_hud.core")

local M = {}


function M.get(spec)
    if not core.is_table(spec)
        or not core.is_table(spec.syntax)
    then
        return {}
    end

    return spec.syntax
end


function M.get_node_type(spec)
    local syntax = M.get(spec)

    if core.is_non_empty_string(
        syntax.node_type
    ) then
        return syntax.node_type
    end

    return nil
end


function M.get_field(spec, key)
    local syntax = M.get(spec)
    local fields = syntax.fields or {}
    local field_name = fields[key]

    if core.is_non_empty_string(
        field_name
    ) then
        return field_name
    end

    if core.is_table(field_name)
        and core.is_non_empty_string(
            field_name.field
        )
    then
        return field_name.field
    end

    return nil
end


function M.get_field_text(spec, key)
    local syntax = M.get(spec)
    local fields = syntax.fields or {}
    local field_spec = fields[key]

    if not core.is_table(field_spec) then
        return nil
    end

    if core.is_non_empty_string(
        field_spec.text
    ) then
        return field_spec.text
    end

    if core.is_non_empty_string(
        field_spec.value
    ) then
        return field_spec.value
    end

    return nil
end


function M.get_tokens(spec)
    local syntax = M.get(spec)

    if core.is_table(syntax.tokens) then
        return syntax.tokens
    end

    -- Temporary compatibility while bundled adapters are migrated.
    if core.is_table(spec)
        and core.is_table(spec.tokens)
    then
        return spec.tokens
    end

    return nil
end


function M.normalize_mnemonic(mnemonic)
    if not core.is_non_empty_string(
        mnemonic
    ) then
        return nil
    end

    return mnemonic:lower()
end


return M
