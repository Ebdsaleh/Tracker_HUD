-- lua/tracker_hud/constructs/contract.lua

local core = require("tracker_hud.core")

local M = {}

M.kinds = {
    -- Lexical / control constructs
    callable = true,
    branch = true,
    loop = true,
    block = true,
    module = true,
    type = true,

    -- Data / symbol constructs
    variable = true,
    parameter = true,
    assignment = true,

    -- Structural / object-like constructs
    structural = true,
    field = true,
    property = true,
    return_value = true,
    literal = true,
}

M.scope_kinds = {
    lexical = true,
    structural = true,
    none = true,
}

function M.validate_kind(kind)
    return core.is_non_empty_string(kind)
        and M.kinds[kind] == true
end

function M.validate_scope_kind(scope_kind)
    return scope_kind == nil
        or (
            core.is_non_empty_string(scope_kind)
            and M.scope_kinds[scope_kind] == true
        )
end


function M.validate_scope_effect(scope_effect)
    if scope_effect == nil then
        return true
    end

    if not core.is_table(scope_effect) then 
        return false
    end

    if scope_effect.lexical ~= nil and type(scope_effect.lexical) ~= "boolean" then
        return false
    end

    if scope_effect.structural ~= nil and type(scope_effect.structural) ~= "boolean" then
        return false
    end

    return true
end


function M.validate_range(range)
    if not core.is_table(range) then
        return false
    end

    return core.is_number(range.start_line)
        and core.is_number(range.end_line)
        and range.start_line <= range.end_line
end


function M.is_synthetic_construct(construct)
    return core.is_table(construct)
        and core.is_table(construct.metadata)
        and construct.metadata.synthetic == true
end


function M.validate_common_construct(construct)
    if not M.validate_kind(construct.kind) then
        return false, "construct.kind is invalid or missing"
    end

    if not M.validate_scope_kind(construct.scope_kind) then
        return false, "construct.scope_kind is invalid"
    end

    if not M.validate_scope_effect(construct.scope_effect) then
        return false, "construct.scope_effect is invalid"
    end

    if not core.is_non_empty_string(construct.label) then
        return false, "construct.label must be a non-empty string"
    end

    if construct.signature ~= nil and not core.is_non_empty_string(construct.signature) then
        return false, "construct.signature must be a non-empty string when provided"
    end

    if construct.name ~= nil and not core.is_non_empty_string(construct.name) then
        return false, "construct.name must be a non-empty string when provided"
    end

    return true, nil
end


function M.validate_treesitter_construct(construct)
    if not core.is_non_empty_string(construct.node_type) then
        return false, "construct.node_type must be a non-empty string"
    end

    if not M.validate_range(construct.range) then
        return false, "construct.range is invalid"
    end

    return true, nil
end

function M.validate_synthetic_construct(_construct)
    -- Synthetic constructs are Tracker HUD-created constructs.
    -- They do not require Tree-sitter node_type/range.
    --
    -- Common fields are already validated by validate_common_construct().
    return true, nil
end


function M.validate_construct(construct)
    if not core.is_table(construct) then
        return false, "construct must be a table"
    end

    local ok, err = M.validate_common_construct(construct)

    if not ok then
        return false, err
    end

    if M.is_synthetic_construct(construct) then
        return M.validate_synthetic_construct(construct)
    end

    return M.validate_treesitter_construct(construct)
end


function M.new_construct(opts)
    opts = opts or {}

    local construct = {
        kind = opts.kind,
        scope_kind = opts.scope_kind,
        scope_effect = opts.scope_effect,
        label = opts.label,
        node_type = opts.node_type,
        name = opts.name,
        signature = opts.signature,
        range = opts.range,
        creates_scope = opts.creates_scope == true,
        metadata = opts.metadata or {},
    }

    local ok, err = M.validate_construct(construct)

    if not ok then
        return nil, err
    end

    return construct, nil
end

return M
