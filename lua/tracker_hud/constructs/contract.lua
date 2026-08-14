-- lua/tracker_hud/constructs/contract.lua
--
-- Canonical Tracker_HUD construct contract.
--
-- Adapters map exact Tree-sitter node types onto:
--
--     construct.kind
--         Tracker_HUD's precise semantic identity.
--
--     construct.language_term
--         The term used by programmers of the active language.
--
--     construct.label
--         Human-facing display text.
--
-- Tree-sitter identity remains external to this vocabulary and is preserved
-- through construct_specs[tree_sitter_node_type] and runtime node_type.
--
-- Mutability is orthogonal to construct identity.
--
--     binding
--         Whether a name/binding may be rebound.
--
--     state
--         Whether an existing value/object may change internally.
--
--     shape
--         Whether members/fields/properties may be added or removed.

local core = require("tracker_hud.core")

local M = {}


M.construct_kinds = {
    -- High-level language constructs.
    ["function"] = true,
    method = true,
    constructor = true,
    destructor = true,

    class = true,
    struct = true,
    object = true,
    enum = true,
    union = true,
    interface = true,
    trait = true,
    delegate = true,
    closure = true,
    lambda = true,

    branch = true,
    loop = true,
    block = true,

    module = true,
    namespace = true,
    type = true,

    declaration = true,
    variable = true,
    parameter = true,
    field = true,
    property = true,

    assignment = true,
    ["return"] = true,
    call = true,

    literal = true,
    table = true,

    -- Low-level / token-like constructs.
    instruction = true,
    mnemonic = true,
    operand = true,
    register = true,
    immediate = true,
    symbol = true,
    label = true,
    label_reference = true,
}


M.scope_kinds = {
    lexical = true,
    structural = true,
    none = true,
}


M.member_kinds = {
    -- High-level language members.
    ["local"] = true,
    variable = true,
    parameter = true,
    field = true,
    property = true,
    method = true,
    ["function"] = true,
    entry = true,
    return_value = true,
    assignment = true,
    loop_variable = true,

    -- Low-level / ASM-friendly members.
    label = true,
    global = true,
    instruction = true,
    register = true,
    immediate = true,
    symbol = true,
}


M.owner_scope_kinds = {
    lexical = true,
    parent_lexical = true,
    structural = true,
    none = true,
}


M.value_kinds = {
    scalar = true,

    ["function"] = true,
    method = true,
    table = true,
    object = true,

    call = true,
    reference = true,
    unknown = true,

    -- Low-level / symbolic values.
    symbol = true,
}


M.mutability_binding_kinds = {
    mutable = true,
    immutable = true,
    conditional = true,
    unknown = true,
}


M.mutability_state_kinds = {
    mutable = true,
    immutable = true,
    conditional = true,
    unknown = true,
}


M.mutability_shape_kinds = {
    extensible = true,
    fixed = true,
    conditional = true,
    unknown = true,
}


local function validate_optional_string(value)
    return value == nil
        or core.is_non_empty_string(value)
end


local function validate_optional_mutability_value(
    value,
    allowed_values
)
    return value == nil
        or (
            core.is_non_empty_string(value)
            and allowed_values[value] == true
        )
end


function M.validate_construct_kind(kind)
    return core.is_non_empty_string(kind)
        and M.construct_kinds[kind] == true
end


function M.validate_scope_kind(kind)
    return core.is_non_empty_string(kind)
        and M.scope_kinds[kind] == true
end


function M.validate_member_kind(kind)
    return kind == nil
        or (
            core.is_non_empty_string(kind)
            and M.member_kinds[kind] == true
        )
end


function M.validate_owner_scope_kind(owner_scope)
    return owner_scope == nil
        or (
            core.is_non_empty_string(owner_scope)
            and M.owner_scope_kinds[owner_scope] == true
        )
end


function M.validate_value_kind(kind)
    return kind == nil
        or (
            core.is_non_empty_string(kind)
            and M.value_kinds[kind] == true
        )
end


function M.validate_mutability_spec(mutability)
    if mutability == nil then
        return true, nil
    end

    if not core.is_table(mutability) then
        return false, "mutability must be a table when provided"
    end

    if not validate_optional_mutability_value(
        mutability.binding,
        M.mutability_binding_kinds
    ) then
        return false, "mutability.binding is invalid"
    end

    if not validate_optional_mutability_value(
        mutability.state,
        M.mutability_state_kinds
    ) then
        return false, "mutability.state is invalid"
    end

    if not validate_optional_mutability_value(
        mutability.shape,
        M.mutability_shape_kinds
    ) then
        return false, "mutability.shape is invalid"
    end

    return true, nil
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


function M.validate_construct_spec(construct_spec)
    if not core.is_table(construct_spec) then
        return false, "construct must be a table"
    end

    if not M.validate_construct_kind(construct_spec.kind) then
        return false, "construct.kind is invalid or missing"
    end

    if not validate_optional_string(
        construct_spec.language_term
    ) then
        return false, "construct.language_term must be a non-empty string when provided"
    end

    if not core.is_non_empty_string(construct_spec.label) then
        return false, "construct.label must be a non-empty string"
    end

    local ok, err = M.validate_mutability_spec(
        construct_spec.mutability
    )

    if not ok then
        return false, err
    end

    return true, nil
end


function M.validate_scope_spec(scope_spec)
    if scope_spec == nil then
        return true, nil
    end

    if not core.is_table(scope_spec) then
        return false, "scope must be a table when provided"
    end

    if not M.validate_scope_kind(scope_spec.kind) then
        return false, "scope.kind is invalid"
    end

    if scope_spec.affects_visibility ~= nil
        and type(scope_spec.affects_visibility) ~= "boolean"
    then
        return false, "scope.affects_visibility must be a boolean when provided"
    end

    if scope_spec.owns_members ~= nil
        and type(scope_spec.owns_members) ~= "boolean"
    then
        return false, "scope.owns_members must be a boolean when provided"
    end

    return true, nil
end


function M.validate_member_spec(member_spec)
    if member_spec == nil then
        return true, nil
    end

    if not core.is_table(member_spec) then
        return false, "member must be a table when provided"
    end

    if not M.validate_member_kind(member_spec.kind) then
        return false, "member.kind is invalid"
    end

    if not validate_optional_string(
        member_spec.language_term
    ) then
        return false, "member.language_term must be a non-empty string when provided"
    end

    if not M.validate_owner_scope_kind(
        member_spec.owner_scope
    ) then
        return false, "member.owner_scope is invalid"
    end

    local ok, err = M.validate_mutability_spec(
        member_spec.mutability
    )

    if not ok then
        return false, err
    end

    return true, nil
end


function M.validate_value_spec(value_spec)
    if value_spec == nil then
        return true, nil
    end

    if not core.is_table(value_spec) then
        return false, "value must be a table when provided"
    end

    if not M.validate_value_kind(value_spec.kind) then
        return false, "value.kind is invalid"
    end

    if not validate_optional_string(
        value_spec.language_term
    ) then
        return false, "value.language_term must be a non-empty string when provided"
    end

    if value_spec.type_label ~= nil
        and not core.is_non_empty_string(value_spec.type_label)
    then
        return false, "value.type_label must be a non-empty string when provided"
    end

    local ok, err = M.validate_mutability_spec(
        value_spec.mutability
    )

    if not ok then
        return false, err
    end

    return true, nil
end


function M.validate_common_construct(construct)
    local ok, err = M.validate_construct_spec(
        construct.construct
    )

    if not ok then
        return false, err
    end

    ok, err = M.validate_scope_spec(
        construct.scope
    )

    if not ok then
        return false, err
    end

    ok, err = M.validate_member_spec(
        construct.member
    )

    if not ok then
        return false, err
    end

    ok, err = M.validate_value_spec(
        construct.value
    )

    if not ok then
        return false, err
    end

    if construct.signature ~= nil
        and not core.is_non_empty_string(
            construct.signature
        )
    then
        return false, "construct.signature must be a non-empty string when provided"
    end

    if construct.name ~= nil
        and not core.is_non_empty_string(
            construct.name
        )
    then
        return false, "construct.name must be a non-empty string when provided"
    end

    return true, nil
end


function M.validate_treesitter_construct(construct)
    if not core.is_non_empty_string(
        construct.node_type
    ) then
        return false, "construct.node_type must be a non-empty string"
    end

    if not M.validate_range(construct.range) then
        return false, "construct.range is invalid"
    end

    return true, nil
end


function M.validate_synthetic_construct(_construct)
    -- Synthetic constructs are Tracker_HUD-created constructs.
    -- They do not require Tree-sitter node_type/range.
    --
    -- Common fields are already validated by
    -- validate_common_construct().

    return true, nil
end


function M.validate_construct(construct)
    if not core.is_table(construct) then
        return false, "construct must be a table"
    end

    local ok, err = M.validate_common_construct(
        construct
    )

    if not ok then
        return false, err
    end

    if M.is_synthetic_construct(construct) then
        return M.validate_synthetic_construct(
            construct
        )
    end

    return M.validate_treesitter_construct(
        construct
    )
end


function M.new_construct(opts)
    opts = opts or {}

    local construct = {
        construct = opts.construct,
        scope = opts.scope,
        member = opts.member,
        value = opts.value,

        node_type = opts.node_type,
        name = opts.name,
        signature = opts.signature,
        range = opts.range,

        metadata = opts.metadata or {},
    }

    local ok, err = M.validate_construct(
        construct
    )

    if not ok then
        return nil, err
    end

    return construct, nil
end


return M
