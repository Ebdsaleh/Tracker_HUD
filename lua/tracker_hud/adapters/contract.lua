-- lua/tracker_hud/adapters/contract.lua
--
-- Canonical Tracker_HUD Adapter Contract validator.
--
-- Adapter Contract v1 is Tree-sitter-first:
--
--     syntax
--         exact Tree-sitter node / field / child / token relationships
--
--     construct / member / value / scope
--         language-native and Tracker_HUD semantic meaning layered onto syntax
--
-- Instruction-driven semantic datasets are mnemonic-indexed and each rule
-- carries its own exact Tree-sitter syntax declaration.

local core = require("tracker_hud.core")
local construct_contract = require("tracker_hud.constructs.contract")
local scope_member_schema = require("tracker_hud.adapters.scope_member_schema")
local target_dimension_helpers = require("tracker_hud.adapters.target_dimensions")

local M = {}


M.current_version = 1


local function profile_begin(
    opts,
    name
)
    if type(opts) ~= "table"
        or type(opts.profile_begin) ~= "function"
    then
        return nil
    end

    return opts.profile_begin(name)
end


local function profile_end(
    opts,
    name,
    started
)
    if type(opts) ~= "table"
        or type(opts.profile_end) ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        name,
        started
    )
end


local function validate_phase(
    opts,
    name,
    validator,
    ...
)
    local started =
        profile_begin(
            opts,
            name
        )

    local ok, err =
        validator(...)

    profile_end(
        opts,
        name,
        started
    )

    return ok, err
end


local function path_error(path, message)
    if core.is_non_empty_string(path) then
        return false, path .. "." .. message
    end

    return false, message
end


local function validate_optional_boolean(value, path)
    if value == nil or type(value) == "boolean" then
        return true, nil
    end

    return path_error(path, "must be a boolean when provided")
end


local function validate_string_list(values, path, opts)
    opts = opts or {}

    if not core.is_table(values) then
        return path_error(path, "must be a table")
    end

    if opts.non_empty and #values == 0 then
        return path_error(path, "must contain at least one entry")
    end

    local seen = {}

    for index, value in ipairs(values) do
        if not core.is_non_empty_string(value) then
            return path_error(
                path .. "[" .. tostring(index) .. "]",
                "must be a non-empty string"
            )
        end

        if opts.unique and seen[value] then
            return path_error(
                path .. "[" .. tostring(index) .. "]",
                "duplicates '" .. value .. "'"
            )
        end

        seen[value] = true
    end

    return true, nil
end


local function validate_field_descriptor(field_spec, path)
    if core.is_non_empty_string(field_spec) then
        return true, nil
    end

    if not core.is_table(field_spec) then
        return path_error(
            path,
            "must be a Tree-sitter field name string or descriptor table"
        )
    end

    if not core.is_non_empty_string(field_spec.field) then
        return path_error(path .. ".field", "must be a non-empty string")
    end

    if field_spec.node_type ~= nil
        and not core.is_non_empty_string(field_spec.node_type)
    then
        return path_error(
            path .. ".node_type",
            "must be a non-empty string when provided"
        )
    end

    if field_spec.node_types ~= nil then
        local ok, err = validate_string_list(
            field_spec.node_types,
            path .. ".node_types",
            { non_empty = true, unique = true }
        )

        if not ok then
            return false, err
        end
    end

    if field_spec.text ~= nil
        and not core.is_non_empty_string(field_spec.text)
    then
        return path_error(
            path .. ".text",
            "must be a non-empty string when provided"
        )
    end

    if field_spec.recursive ~= nil then
        if not core.is_table(
            field_spec.recursive
        )
        then
            return path_error(
                path .. ".recursive",
                "must be a table when provided"
            )
        end

        if field_spec.recursive.field ~= nil
            and not core.is_non_empty_string(field_spec.recursive.field)
        then
            return path_error(
                path .. ".recursive.field",
                "must be a non-empty string when provided"
            )
        end

        local terminal_types =
            field_spec.recursive
                .terminal_node_types

        local container_types =
            field_spec.recursive
                .container_node_types

        local recursive_ok,
            recursive_err =
            validate_string_list(
                terminal_types,
                path
                    .. ".recursive.terminal_node_types",
                {
                    non_empty = true,
                    unique = true,
                }
            )

        if not recursive_ok then
            return false, recursive_err
        end

        recursive_ok,
            recursive_err =
            validate_string_list(
                container_types,
                path
                    .. ".recursive.container_node_types",
                {
                    non_empty = true,
                    unique = true,
                }
            )

        if not recursive_ok then
            return false, recursive_err
        end

        local single_child_types = field_spec.recursive.single_named_child_node_types
        if single_child_types ~= nil then
            local child_path = path .. ".recursive.single_named_child_node_types"
            if not core.is_non_empty_string(field_spec.recursive.field) then
                return path_error(child_path, "requires an explicit recursive.field")
            end
            local child_ok, child_err = validate_string_list(
                single_child_types, child_path, { non_empty = true, unique = true }
            )
            if not child_ok then
                return false, child_err
            end
            local containers = {}
            for _, node_type in ipairs(container_types) do
                containers[node_type] = true
            end
            for index, node_type in pairs(single_child_types) do
                if type(index) ~= "number" or index % 1 ~= 0
                    or index < 1 or index > #single_child_types then
                    return path_error(child_path, "must be a dense list")
                end
                if not containers[node_type] then
                    return path_error(child_path, "must be a subset of container_node_types")
                end
            end
            for index = 1, #single_child_types do
                if not core.is_non_empty_string(single_child_types[index]) then
                    return path_error(child_path, "must be a dense list")
                end
            end
        end

        local terminal_seen = {}

        for _, node_type in ipairs(
            terminal_types
        ) do
            terminal_seen[node_type] =
                true
        end

        for _, node_type in ipairs(
            container_types
        ) do
            if terminal_seen[
                node_type
            ]
            then
                return path_error(
                    path .. ".recursive",
                    "terminal/container node types must not overlap"
                )
            end
        end
    end

    local ok, err = validate_optional_boolean(
        field_spec.optional,
        path .. ".optional"
    )

    if not ok then
        return false, err
    end

    return validate_optional_boolean(
        field_spec.multiple,
        path .. ".multiple"
    )
end


local function validate_fields(fields, path)
    if fields == nil then
        return true, nil
    end

    if not core.is_table(fields) then
        return path_error(path, "must be a table when provided")
    end

    for semantic_name, field_spec in pairs(fields) do
        if not core.is_non_empty_string(semantic_name) then
            return path_error(path, "keys must be non-empty strings")
        end

        local ok, err = validate_field_descriptor(
            field_spec,
            path .. "." .. semantic_name
        )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_child_descriptor(child_spec, path)
    if not core.is_table(child_spec) then
        return path_error(path, "must be a table")
    end

    local has_node_type = core.is_non_empty_string(child_spec.node_type)
    local has_node_types = core.is_table(child_spec.node_types)

    if not has_node_type and not has_node_types then
        return path_error(
            path,
            "must declare node_type or node_types"
        )
    end

    if child_spec.node_type ~= nil and not has_node_type then
        return path_error(
            path .. ".node_type",
            "must be a non-empty string when provided"
        )
    end

    if has_node_types then
        local ok, err = validate_string_list(
            child_spec.node_types,
            path .. ".node_types",
            { non_empty = true, unique = true }
        )

        if not ok then
            return false, err
        end
    end

    local ok, err = validate_optional_boolean(
        child_spec.optional,
        path .. ".optional"
    )

    if not ok then
        return false, err
    end

    return validate_optional_boolean(
        child_spec.multiple,
        path .. ".multiple"
    )
end


local function validate_children(children, path)
    if children == nil then
        return true, nil
    end

    if not core.is_table(children) then
        return path_error(path, "must be a table when provided")
    end

    for semantic_name, child_spec in pairs(children) do
        if not core.is_non_empty_string(semantic_name) then
            return path_error(path, "keys must be non-empty strings")
        end

        local ok, err = validate_child_descriptor(
            child_spec,
            path .. "." .. semantic_name
        )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_tokens(tokens, path)
    if tokens == nil then
        return true, nil
    end

    if not core.is_table(tokens) then
        return path_error(path, "must be a table when provided")
    end

    for token_name, token_text in pairs(tokens) do
        if not core.is_non_empty_string(token_name) then
            return path_error(path, "keys must be non-empty strings")
        end

        if not core.is_non_empty_string(token_text) then
            return path_error(
                path .. "." .. token_name,
                "must be a non-empty string"
            )
        end
    end

    return true, nil
end


-- Ordered path from immediate parent outwards. Repeated node types are
-- meaningful (nested syntax), so validate density rather than uniqueness.
local function validate_parent_path(values, path)
    local ok, err = validate_string_list(values, path, { non_empty = true })
    if not ok then
        return false, err
    end
    for key in pairs(values) do
        if type(key) ~= "number" or key < 1 or key > #values
            or key ~= math.floor(key)
        then
            return path_error(path, "must be a dense list")
        end
    end
    for index = 1, #values do
        if not core.is_non_empty_string(values[index]) then
            return path_error(path, "must be a dense list of non-empty strings")
        end
    end
    return true, nil
end


-- Alternatives are ordered paths, not independent ancestor-type matches.
local function validate_parent_paths(spec, path)
    if spec.parent_paths == nil then
        return true, nil
    end
    local paths = spec.parent_paths
    local where = path .. ".parent_paths"
    if spec.parent_path ~= nil then
        return path_error(where, "must not accompany parent_path")
    end
    if not core.is_table(paths) or #paths == 0 then
        return path_error(where, "must be a non-empty dense list of paths")
    end
    for key in pairs(paths) do
        if type(key) ~= "number" or key < 1 or key > #paths
            or key ~= math.floor(key)
        then
            return path_error(where, "must be a dense list")
        end
    end
    for index = 1, #paths do
        local entry = paths[index]
        local ok, err = validate_parent_path(entry, where .. "[" .. index .. "]")
        if not ok then return false, err end
        for previous = 1, index - 1 do
            local other = paths[previous]
            local equal = #entry == #other
            for position = 1, #entry do
                if entry[position] ~= other[position] then equal = false end
            end
            if equal then return path_error(where, "must not contain duplicate paths") end
        end
    end
    return true, nil
end


local function validate_exclusions(exclusions, path)
    if exclusions == nil then
        return true, nil
    end

    if not core.is_table(exclusions) then
        return path_error(path, "must be a table when provided")
    end

    if exclusions.ancestor_node_types ~= nil then
        local ok, err = validate_string_list(
            exclusions.ancestor_node_types,
            path .. ".ancestor_node_types",
            { non_empty = true, unique = true }
        )
        if not ok then
            return false, err
        end
    end

    if exclusions.parent_path ~= nil then
        local ok, err = validate_parent_path(
            exclusions.parent_path, path .. ".parent_path"
        )
        if not ok then
            return false, err
        end
    end

    local paths_ok, paths_err = validate_parent_paths(exclusions, path)
    if not paths_ok then return false, paths_err end

    -- A field path excludes only a specific syntactic role, not arbitrary
    -- descendants (such as declarations inside an initializer expression).
    if exclusions.field_paths ~= nil then
        local paths = exclusions.field_paths
        local paths_path = path .. ".field_paths"
        if not core.is_table(paths) or #paths == 0 then
            return path_error(paths_path, "must be a non-empty list")
        end
        for key in pairs(paths) do
            if type(key) ~= "number" or key < 1 or key > #paths
                or key ~= math.floor(key)
            then
                return path_error(paths_path, "must be a dense list")
            end
        end
        for index = 1, #paths do
            local entry = paths[index]
            local entry_path = paths_path .. "[" .. index .. "]"
            if not core.is_table(entry) then
                return path_error(entry_path, "must be a table")
            end
            for _, key in ipairs({ "fields", "node_types" }) do
                local values = entry[key]
                local ok, err = validate_string_list(
                    values, entry_path .. "." .. key,
                    { non_empty = true, unique = key == "node_types" }
                )
                if not ok then
                    return false, err
                end
                for position in pairs(values) do
                    if type(position) ~= "number" or position < 1
                        or position > #values or position ~= math.floor(position)
                    then
                        return path_error(entry_path .. "." .. key,
                            "must be a dense list")
                    end
                end
                for position = 1, #values do
                    if not core.is_non_empty_string(values[position]) then
                        return path_error(entry_path .. "." .. key,
                            "must be a dense list of non-empty strings")
                    end
                end
            end
        end
    end

    return true, nil
end


local function validate_constraints(constraints, path)
    if constraints == nil then
        return true, nil
    end

    if not core.is_table(constraints) then
        return path_error(
            path,
            "must be a table when provided"
        )
    end

    for _, key in ipairs({
        "ancestor_node_types",
        "parent_node_types",
    }) do
        if constraints[key] ~= nil then
            local ok, err =
                validate_string_list(
                    constraints[key],
                    path .. "." .. key,
                    {
                        non_empty = true,
                        unique = true,
                    }
                )

            if not ok then
                return false, err
            end
        end
    end

    if constraints.parent_path ~= nil then
        local ok, err = validate_parent_path(
            constraints.parent_path, path .. ".parent_path"
        )
        if not ok then
            return false, err
        end
    end

    local paths_ok, paths_err = validate_parent_paths(constraints, path)
    if not paths_ok then return false, paths_err end

    if constraints.named_child_count ~= nil then
        local count =
            constraints.named_child_count

        if type(count) ~= "number"
            or count < 0
            or count ~= math.floor(count)
        then
            return path_error(
                path .. ".named_child_count",
                "must be a non-negative integer when provided"
            )
        end
    end

    return true, nil
end


function M.validate_syntax(syntax, path)
    path = path or "syntax"

    if not core.is_table(syntax) then
        return path_error(path, "must be a table")
    end

    if not core.is_non_empty_string(syntax.node_type) then
        return path_error(
            path .. ".node_type",
            "must be a non-empty Tree-sitter node type string"
        )
    end

    local ok, err = validate_fields(
        syntax.fields,
        path .. ".fields"
    )

    if not ok then
        return false, err
    end

    ok, err = validate_children(
        syntax.children,
        path .. ".children"
    )

    if not ok then
        return false, err
    end

    ok, err = validate_tokens(
        syntax.tokens,
        path .. ".tokens"
    )

    if not ok then
        return false, err
    end

    ok, err = validate_exclusions(
        syntax.exclusions,
        path .. ".exclusions"
    )

    if not ok then
        return false, err
    end

    return validate_constraints(
        syntax.constraints,
        path .. ".constraints"
    )
end


local function validate_markers(markers, syntax, path)
    if markers == nil then
        return true, nil
    end

    if not core.is_table(markers) then
        return path_error(path, "must be a table when provided")
    end

    local required = markers.required or {}
    local optional = markers.optional or {}

    local ok, err = validate_string_list(
        required,
        path .. ".required",
        { unique = true }
    )

    if not ok then
        return false, err
    end

    ok, err = validate_string_list(
        optional,
        path .. ".optional",
        { unique = true }
    )

    if not ok then
        return false, err
    end

    local tokens = syntax.tokens or {}

    for _, marker_name in ipairs(required) do
        if not core.is_non_empty_string(tokens[marker_name]) then
            return path_error(
                path .. ".required",
                "references missing syntax token '" .. marker_name .. "'"
            )
        end
    end

    for _, marker_name in ipairs(optional) do
        if not core.is_non_empty_string(tokens[marker_name]) then
            return path_error(
                path .. ".optional",
                "references missing syntax token '" .. marker_name .. "'"
            )
        end
    end

    if markers.total_required ~= nil then
        if not core.is_number(markers.total_required) then
            return path_error(
                path .. ".total_required",
                "must be a number when provided"
            )
        end

        if markers.total_required ~= #required then
            return path_error(
                path .. ".total_required",
                "must equal the number of required markers"
            )
        end
    end

    return true, nil
end


local function validate_branch(branch, path)
    if branch == nil then
        return true, nil
    end

    if not core.is_table(branch) then
        return path_error(path, "must be a table when provided")
    end

    local ok, err = validate_optional_boolean(
        branch.grouped,
        path .. ".grouped"
    )

    if not ok then
        return false, err
    end

    if branch.alternatives == nil then
        return true, nil
    end

    if not core.is_table(branch.alternatives) then
        return path_error(
            path .. ".alternatives",
            "must be a table when provided"
        )
    end

    for index, alternative in ipairs(branch.alternatives) do
        local alternative_path = path
            .. ".alternatives["
            .. tostring(index)
            .. "]"

        if not core.is_table(alternative) then
            return path_error(alternative_path, "must be a table")
        end

        ok, err = M.validate_syntax(
            alternative.syntax,
            alternative_path .. ".syntax"
        )

        if not ok then
            return false, err
        end

        if not core.is_non_empty_string(alternative.label) then
            return path_error(
                alternative_path .. ".label",
                "must be a non-empty string"
            )
        end
    end

    return true, nil
end


local function validate_memory_operand_spec(memory, path)
    if memory == nil then
        return true, nil
    end

    if not core.is_table(memory) then
        return path_error(path, "must be a table when provided")
    end

    for _, key in ipairs({
        "kind",
        "container_kind",
        "address_kind",
    }) do
        if memory[key] ~= nil
            and not core.is_non_empty_string(memory[key])
        then
            return path_error(
                path .. "." .. key,
                "must be a non-empty string when provided"
            )
        end
    end

    if memory.brackets ~= nil then
        if not core.is_table(memory.brackets) then
            return path_error(path .. ".brackets", "must be a table")
        end

        for _, key in ipairs({ "open", "close" }) do
            if not core.is_non_empty_string(memory.brackets[key]) then
                return path_error(
                    path .. ".brackets." .. key,
                    "must be a non-empty string"
                )
            end
        end
    end

    if memory.address_modes ~= nil then
        if not core.is_table(memory.address_modes) then
            return path_error(path .. ".address_modes", "must be a table")
        end

        for token, mode in pairs(memory.address_modes) do
            if not core.is_non_empty_string(token) then
                return path_error(
                    path .. ".address_modes",
                    "keys must be non-empty strings"
                )
            end

            if not core.is_table(mode)
                or not core.is_non_empty_string(mode.kind)
            then
                return path_error(
                    path .. ".address_modes[" .. tostring(token) .. "]",
                    "must declare a non-empty kind"
                )
            end
        end
    end

    if memory.symbol_resolution ~= nil then
        local policy = memory.symbol_resolution
        local policy_path = path .. ".symbol_resolution"

        if not core.is_table(policy) then
            return path_error(policy_path, "must be a table")
        end

        if not core.is_table(policy.member_kinds)
            or #policy.member_kinds == 0
        then
            return path_error(
                policy_path .. ".member_kinds",
                "must be a non-empty array"
            )
        end

        local seen_kinds = {}

        for index, kind in ipairs(policy.member_kinds) do
            if not core.is_non_empty_string(kind) then
                return path_error(
                    policy_path
                        .. ".member_kinds["
                        .. tostring(index)
                        .. "]",
                    "must be a non-empty string"
                )
            end

            if seen_kinds[kind] then
                return path_error(
                    policy_path .. ".member_kinds",
                    "must not contain duplicate kinds"
                )
            end

            seen_kinds[kind] = true
        end

        if policy.allow_forward ~= nil
            and type(policy.allow_forward) ~= "boolean"
        then
            return path_error(
                policy_path .. ".allow_forward",
                "must be boolean when provided"
            )
        end

        if policy.case_sensitive ~= nil
            and type(policy.case_sensitive) ~= "boolean"
        then
            return path_error(
                policy_path .. ".case_sensitive",
                "must be boolean when provided"
            )
        end
    end

    if memory.address_size_policy ~= nil then
        local policy = memory.address_size_policy
        local policy_path = path .. ".address_size_policy"

        if not core.is_table(policy) then
            return path_error(policy_path, "must be a table")
        end

        if not core.is_number(policy.default_bits)
            or policy.default_bits <= 0
            or policy.default_bits ~= math.floor(policy.default_bits)
        then
            return path_error(
                policy_path .. ".default_bits",
                "must be a positive integer"
            )
        end

        if not core.is_table(policy.allowed_bits)
            or #policy.allowed_bits == 0
        then
            return path_error(
                policy_path .. ".allowed_bits",
                "must be a non-empty array"
            )
        end

        local allowed = {}

        for index, bits in ipairs(policy.allowed_bits) do
            if not core.is_number(bits)
                or bits <= 0
                or bits ~= math.floor(bits)
            then
                return path_error(
                    policy_path
                        .. ".allowed_bits["
                        .. tostring(index)
                        .. "]",
                    "must be a positive integer"
                )
            end

            if allowed[bits] then
                return path_error(
                    policy_path .. ".allowed_bits",
                    "must not contain duplicate widths"
                )
            end

            allowed[bits] = true
        end

        if not allowed[policy.default_bits] then
            return path_error(
                policy_path .. ".default_bits",
                "must be present in allowed_bits"
            )
        end

        if policy.prefixes ~= nil then
            if not core.is_table(policy.prefixes) then
                return path_error(
                    policy_path .. ".prefixes",
                    "must be a table"
                )
            end

            for prefix, bits in pairs(policy.prefixes) do
                if not core.is_non_empty_string(prefix) then
                    return path_error(
                        policy_path .. ".prefixes",
                        "keys must be non-empty strings"
                    )
                end

                if not core.is_number(bits)
                    or bits <= 0
                    or bits ~= math.floor(bits)
                    or not allowed[bits]
                then
                    return path_error(
                        policy_path
                            .. ".prefixes["
                            .. tostring(prefix)
                            .. "]",
                        "must map to a width declared in allowed_bits"
                    )
                end
            end
        end

        if policy.register_width_map ~= nil then
            if not core.is_table(policy.register_width_map) then
                return path_error(
                    policy_path .. ".register_width_map",
                    "must be a table"
                )
            end

            for register_bits, address_bits in pairs(
                policy.register_width_map
            ) do
                local numeric_register_bits = tonumber(register_bits)

                if not numeric_register_bits
                    or numeric_register_bits <= 0
                    or numeric_register_bits
                        ~= math.floor(numeric_register_bits)
                then
                    return path_error(
                        policy_path .. ".register_width_map",
                        "keys must be positive integer widths"
                    )
                end

                if not core.is_number(address_bits)
                    or address_bits <= 0
                    or address_bits ~= math.floor(address_bits)
                    or not allowed[address_bits]
                then
                    return path_error(
                        policy_path
                            .. ".register_width_map["
                            .. tostring(register_bits)
                            .. "]",
                        "must map to a width declared in allowed_bits"
                    )
                end
            end
        end
    end

    if memory.size_prefixes ~= nil then
        if not core.is_table(memory.size_prefixes) then
            return path_error(path .. ".size_prefixes", "must be a table")
        end

        for prefix, size in pairs(memory.size_prefixes) do
            if not core.is_non_empty_string(prefix) then
                return path_error(
                    path .. ".size_prefixes",
                    "keys must be non-empty strings"
                )
            end

            if not core.is_table(size)
                or not core.is_number(size.bits)
                or size.bits <= 0
                or size.bits ~= math.floor(size.bits)
            then
                return path_error(
                    path .. ".size_prefixes[" .. tostring(prefix) .. "].bits",
                    "must be a positive integer"
                )
            end

            if size.label ~= nil
                and not core.is_non_empty_string(size.label)
            then
                return path_error(
                    path .. ".size_prefixes[" .. tostring(prefix) .. "].label",
                    "must be a non-empty string when provided"
                )
            end
        end
    end

    if memory.component_roles ~= nil then
        if not core.is_table(memory.component_roles) then
            return path_error(path .. ".component_roles", "must be a table")
        end

        for role, role_spec in pairs(memory.component_roles) do
            if not core.is_non_empty_string(role) then
                return path_error(
                    path .. ".component_roles",
                    "keys must be non-empty strings"
                )
            end

            if not core.is_table(role_spec) then
                return path_error(
                    path .. ".component_roles[" .. tostring(role) .. "]",
                    "must be a table"
                )
            end

            if role_spec.label ~= nil
                and not core.is_non_empty_string(role_spec.label)
            then
                return path_error(
                    path .. ".component_roles[" .. tostring(role) .. "].label",
                    "must be a non-empty string when provided"
                )
            end

            if role_spec.kind ~= nil
                and not core.is_non_empty_string(role_spec.kind)
            then
                return path_error(
                    path .. ".component_roles[" .. tostring(role) .. "].kind",
                    "must be a non-empty string when provided"
                )
            end
        end
    end

    if memory.register_role_overrides ~= nil then
        if not core.is_table(memory.register_role_overrides) then
            return path_error(
                path .. ".register_role_overrides",
                "must be a table"
            )
        end

        for register_name, role in pairs(memory.register_role_overrides) do
            if not core.is_non_empty_string(register_name)
                or not core.is_non_empty_string(role)
            then
                return path_error(
                    path .. ".register_role_overrides",
                    "must map non-empty register names to non-empty roles"
                )
            end
        end
    end

    return true, nil
end


local function is_non_blank_string(value)
    return core.is_non_empty_string(value)
        and value:find("%S") ~= nil
end


local function validate_availability_string_list(
    values,
    path
)
    local ok, err =
        validate_string_list(
            values,
            path,
            {
                non_empty = true,
                unique = true,
            }
        )

    if not ok then
        return false, err
    end

    -- Reject entries that ipairs() would silently skip, including named,
    -- zero-indexed, fractional, and sparse list keys.
    local length = #values
    local entries = 0

    for key in pairs(values) do
        if type(key) ~= "number"
            or key < 1
            or key > length
            or key ~= math.floor(key)
        then
            return path_error(
                path,
                "must be a dense integer-indexed list"
            )
        end

        entries = entries + 1
    end

    if entries ~= length then
        return path_error(
            path,
            "must be a dense integer-indexed list"
        )
    end

    for index, value in ipairs(values) do
        if not is_non_blank_string(value) then
            return path_error(
                path
                    .. "["
                    .. tostring(index)
                    .. "]",
                "must be a non-blank string"
            )
        end
    end

    return true, nil
end


local function validate_availability(
    availability,
    path
)
    if availability == nil then
        return true, nil
    end

    if not core.is_table(availability) then
        return path_error(
            path,
            "must be a table when provided"
        )
    end

    if not is_non_blank_string(
        availability.language
    ) then
        return path_error(
            path .. ".language",
            "must be a non-empty string"
        )
    end

    local dimension =
        availability.dimension

    if dimension ~= nil
        and not is_non_blank_string(
            dimension
        )
    then
        return path_error(
            path .. ".dimension",
            "must be a non-empty string when provided"
        )
    end

    local since = availability.since
    local until_value =
        availability["until"]
    local standards =
        availability.standards
    local values =
        availability.values

    if since ~= nil
        and not is_non_blank_string(
            since
        )
    then
        return path_error(
            path .. ".since",
            "must be a non-empty string when provided"
        )
    end

    if until_value ~= nil
        and not is_non_blank_string(
            until_value
        )
    then
        return path_error(
            path .. ".until",
            "must be a non-empty string when provided"
        )
    end

    if standards ~= nil then
        local ok, err =
            validate_availability_string_list(
                standards,
                path .. ".standards"
            )

        if not ok then
            return false, err
        end

        if since ~= nil
            or until_value ~= nil
        then
            return path_error(
                path,
                "standards must not be combined with since/until"
            )
        end
    end

    if values ~= nil then
        if dimension == nil then
            return path_error(
                path .. ".dimension",
                "is required when values are declared"
            )
        end

        local ok, err =
            validate_availability_string_list(
                values,
                path .. ".values"
            )

        if not ok then
            return false, err
        end

        if since ~= nil
            or until_value ~= nil
            or standards ~= nil
        then
            return path_error(
                path,
                "values must not be combined with since/until/standards"
            )
        end
    end

    if since == nil
        and until_value == nil
        and standards == nil
        and values == nil
    then
        return path_error(
            path,
            "must declare since, until, standards, or values"
        )
    end

    return true, nil
end

local function validate_construct_entry(node_type, spec, path)
    if not core.is_table(spec) then
        return path_error(path, "must be a table")
    end

    local ok, err = M.validate_syntax(
        spec.syntax,
        path .. ".syntax"
    )

    if not ok then
        return false, err
    end

    if spec.syntax.node_type ~= node_type then
        return path_error(
            path .. ".syntax.node_type",
            "must match construct_specs key '" .. node_type .. "'"
        )
    end

    ok, err = construct_contract.validate_construct_spec(
        spec.construct
    )

    if not ok then
        return path_error(path, err)
    end

    if not core.is_non_empty_string(spec.construct.language_term) then
        return path_error(
            path .. ".construct.language_term",
            "is required by Adapter Contract v1"
        )
    end

    ok, err = construct_contract.validate_scope_spec(spec.scope)

    if not ok then
        return path_error(path, err)
    end

    ok, err = validate_availability(
        spec.availability,
        path .. ".availability"
    )

    if not ok then
        return false, err
    end

    ok, err = construct_contract.validate_value_spec(spec.value)

    if not ok then
        return path_error(path, err)
    end

    if core.is_table(spec.value)
        and not core.is_non_empty_string(spec.value.language_term)
    then
        return path_error(
            path .. ".value.language_term",
            "is required when value is declared"
        )
    end

    if core.is_table(spec.operand) then
        ok, err = validate_memory_operand_spec(
            spec.operand.memory,
            path .. ".operand.memory"
        )

        if not ok then
            return false, err
        end
    end

    ok, err = validate_branch(
        spec.branch,
        path .. ".branch"
    )

    if not ok then
        return false, err
    end

    return validate_markers(
        spec.markers,
        spec.syntax,
        path .. ".markers"
    )
end


local function validate_construct_specs(construct_specs)
    if not core.is_table(construct_specs) then
        return false, "adapter.construct_specs must be a table"
    end

    local count = 0

    for node_type, spec in pairs(construct_specs) do
        count = count + 1

        if not core.is_non_empty_string(node_type) then
            return false,
                "adapter.construct_specs keys must be non-empty Tree-sitter node type strings"
        end

        local ok, err = validate_construct_entry(
            node_type,
            spec,
            "adapter.construct_specs[" .. node_type .. "]"
        )

        if not ok then
            return false, err
        end
    end

    if count == 0 then
        return false, "adapter.construct_specs must contain at least one construct"
    end

    return true, nil
end


local function validate_scope_member_entry(group_name, index, entry)
    local path = "adapter.scope_members."
        .. group_name
        .. "["
        .. tostring(index)
        .. "]"

    if not core.is_table(entry) then
        return path_error(path, "must be a table")
    end

    local ok, err = M.validate_syntax(
        entry.syntax,
        path .. ".syntax"
    )

    if not ok then
        return false, err
    end

    ok, err = construct_contract.validate_member_spec(entry.member)

    if not ok then
        return path_error(path, err)
    end

    if not core.is_table(entry.member) then
        return path_error(path .. ".member", "must be a table")
    end

    if not core.is_non_empty_string(entry.member.language_term) then
        return path_error(
            path .. ".member.language_term",
            "is required by Adapter Contract v1"
        )
    end

    ok, err = construct_contract.validate_value_spec(entry.value)

    if not ok then
        return path_error(path, err)
    end

    if core.is_table(entry.value)
        and not core.is_non_empty_string(entry.value.language_term)
    then
        return path_error(
            path .. ".value.language_term",
            "is required when value is declared"
        )
    end

    if entry.mnemonic ~= nil
        and not core.is_non_empty_string(entry.mnemonic)
    then
        return path_error(
            path .. ".mnemonic",
            "must be a non-empty string when provided"
        )
    end

    if entry.operand_index ~= nil
        and (
            not core.is_number(entry.operand_index)
            or entry.operand_index < 1
        )
    then
        return path_error(
            path .. ".operand_index",
            "must be a positive number when provided"
        )
    end

    return true, nil
end


local function validate_scope_members(scope_members)
    if scope_members == nil then
        return true, nil
    end

    if not core.is_table(scope_members) then
        return false, "adapter.scope_members must be a table when provided"
    end

    for group_name, entries in pairs(scope_members) do
        if not core.is_non_empty_string(group_name) then
            return false, "adapter.scope_members keys must be non-empty strings"
        end

        if not scope_member_schema.is_supported_group(
            group_name
        ) then
            return false,
                "adapter.scope_members."
                .. tostring(group_name)
                .. " is not a supported Scope Member group; expected one of: "
                .. scope_member_schema.supported_groups_text()
        end

        if not core.is_table(entries) then
            return false,
                "adapter.scope_members."
                .. group_name
                .. " must be a table"
        end

        for index, entry in ipairs(entries) do
            local ok, err = validate_scope_member_entry(
                group_name,
                index,
                entry
            )

            if not ok then
                return false, err
            end
        end
    end

    return true, nil
end


local binding_scope_modifier_strategies = {
    outermost_lexical = true,
    nearest_enclosing_binding = true,
}


local function validate_scope_binding_modifiers(
    modifiers
)
    if modifiers == nil then
        return true, nil
    end

    if not core.is_table(modifiers) then
        return false,
            "adapter.scope_binding_modifiers must be a table when provided"
    end

    for index, spec in ipairs(modifiers) do
        local path =
            "adapter.scope_binding_modifiers["
            .. tostring(index)
            .. "]"

        if not core.is_table(spec) then
            return path_error(
                path,
                "must be a table"
            )
        end

        local ok, err =
            M.validate_syntax(
                spec.syntax,
                path .. ".syntax"
            )

        if not ok then
            return false, err
        end

        local names =
            spec.syntax
            and spec.syntax.children
            and spec.syntax.children.names

        if not core.is_table(names)
            or (
                not core.is_non_empty_string(
                    names.node_type
                )
                and not core.is_table(
                    names.node_types
                )
            )
        then
            return path_error(
                path .. ".syntax.children.names",
                "must declare direct binding-name node type(s)"
            )
        end

        if not core.is_table(spec.target) then
            return path_error(
                path .. ".target",
                "must be a table"
            )
        end

        if not core.is_non_empty_string(
            spec.target.strategy
        )
            or not binding_scope_modifier_strategies[
                spec.target.strategy
            ]
        then
            return path_error(
                path .. ".target.strategy",
                "must be outermost_lexical or nearest_enclosing_binding"
            )
        end

        if spec.target.eligible_construct_kinds
            ~= nil
        then
            ok, err =
                validate_string_list(
                    spec.target
                        .eligible_construct_kinds,
                    path
                        .. ".target.eligible_construct_kinds",
                    {
                        non_empty = true,
                        unique = true,
                    }
                )

            if not ok then
                return false, err
            end
        end
    end

    return true, nil
end


local function validate_range_scopes(range_scopes)
    if range_scopes == nil then
        return true, nil
    end

    if not core.is_table(range_scopes) then
        return false, "adapter.range_scopes must be a table when provided"
    end

    for index, spec in ipairs(range_scopes) do
        local path = "adapter.range_scopes[" .. tostring(index) .. "]"

        if not core.is_table(spec) then
            return path_error(path, "must be a table")
        end

        local ok, err = M.validate_syntax(
            spec.syntax,
            path .. ".syntax"
        )

        if not ok then
            return false, err
        end

        if not core.is_non_empty_string(spec.label) then
            return path_error(
                path .. ".label",
                "must be a non-empty string"
            )
        end

        if not core.is_non_empty_string(spec.range_strategy) then
            return path_error(
                path .. ".range_strategy",
                "must be a non-empty string"
            )
        end

        ok, err = construct_contract.validate_scope_spec(spec.scope)

        if not ok then
            return path_error(path, err)
        end
    end

    return true, nil
end


local function get_rule_mnemonic(rule)
    local syntax = core.is_table(rule) and rule.syntax or nil
    local fields = core.is_table(syntax) and syntax.fields or nil
    local kind_field = core.is_table(fields) and fields.kind or nil

    if core.is_table(kind_field)
        and core.is_non_empty_string(kind_field.text)
    then
        return kind_field.text:lower()
    end

    return nil
end


local function validate_operands(operands, path)
    if operands == nil then
        return true, nil
    end

    if not core.is_table(operands) then
        return path_error(path, "must be a table when provided")
    end

    for index, operand in ipairs(operands) do
        if not core.is_table(operand) then
            return path_error(
                path .. "[" .. tostring(index) .. "]",
                "must be a table"
            )
        end

        if operand.index ~= nil
            and (
                not core.is_number(operand.index)
                or operand.index < 1
            )
        then
            return path_error(
                path .. "[" .. tostring(index) .. "].index",
                "must be a positive number when provided"
            )
        end
    end

    return true, nil
end


local function valid_positive_integer(value)
    return core.is_number(value)
        and value == math.floor(value)
        and value >= 1
end


local function validate_integer_interpretation(spec, path)
    if spec == nil then
        return true, nil
    end

    if not core.is_table(spec) then
        return path_error(path, "must be a table when provided")
    end

    local kind = spec.kind

    if kind ~= "exact"
        and kind ~= "signed_bits"
        and kind ~= "unsigned_bits"
    then
        return path_error(
            path .. ".kind",
            "must be 'exact', 'signed_bits', or 'unsigned_bits'"
        )
    end

    if kind == "exact" then
        if spec.bits ~= nil
            or spec.bits_from ~= nil
            or spec.max_bits ~= nil
            or spec.min_bits ~= nil
        then
            return path_error(
                path,
                "exact interpretation must not declare width fields"
            )
        end

        return true, nil
    end

    local has_fixed_bits = spec.bits ~= nil
    local has_derived_bits = spec.bits_from ~= nil

    if has_fixed_bits == has_derived_bits then
        return path_error(
            path,
            "must declare exactly one of bits or bits_from"
        )
    end

    if has_fixed_bits and not valid_positive_integer(spec.bits) then
        return path_error(
            path .. ".bits",
            "must be a positive integer"
        )
    end

    if has_derived_bits and spec.bits_from ~= "target" then
        return path_error(
            path .. ".bits_from",
            "must be 'target'"
        )
    end

    if spec.max_bits ~= nil
        and not valid_positive_integer(spec.max_bits)
    then
        return path_error(
            path .. ".max_bits",
            "must be a positive integer when provided"
        )
    end

    if spec.min_bits ~= nil
        and not valid_positive_integer(spec.min_bits)
    then
        return path_error(
            path .. ".min_bits",
            "must be a positive integer when provided"
        )
    end

    if spec.max_bits ~= nil
        and spec.min_bits ~= nil
        and spec.min_bits > spec.max_bits
    then
        return path_error(
            path,
            "min_bits must not exceed max_bits"
        )
    end

    return true, nil
end


local function effect_has_target(effect)
    local target_operand = tonumber(effect.target_operand)

    return (target_operand
            and target_operand >= 1
            and target_operand == math.floor(target_operand))
        or core.is_non_empty_string(effect.target_register)
end


local function effect_has_operand(effect, key)
    local index = tonumber(effect[key])

    return index
        and index >= 1
        and index == math.floor(index)
end


local function validate_effect_semantics(effect, path)
    if not core.is_table(effect) then
        return true, nil
    end

    if effect.value_width_policy ~= nil then
        if effect.value_width_policy ~= "wrap_unsigned_target" then
            return path_error(
                path .. ".value_width_policy",
                "must be 'wrap_unsigned_target' when provided"
            )
        end

        if not effect_has_target(effect) then
            return path_error(
                path .. ".value_width_policy",
                "requires target_operand or target_register"
            )
        end
    end

    local ok, err = validate_integer_interpretation(
        effect.value_operand_interpretation,
        path .. ".value_operand_interpretation"
    )

    if not ok then
        return false, err
    end

    if effect.value_operand_interpretation ~= nil
        and not effect_has_operand(effect, "value_operand")
    then
        return path_error(
            path .. ".value_operand_interpretation",
            "requires value_operand"
        )
    end

    ok, err = validate_integer_interpretation(
        effect.value_delta_operand_interpretation,
        path .. ".value_delta_operand_interpretation"
    )

    if not ok then
        return false, err
    end

    if effect.value_delta_operand_interpretation ~= nil
        and not effect_has_operand(effect, "value_delta_operand")
    then
        return path_error(
            path .. ".value_delta_operand_interpretation",
            "requires value_delta_operand"
        )
    end

    return true, nil
end


local function validate_instruction_rule_set(
    rule_set,
    dataset_name,
    opts
)
    opts = opts or {}

    if rule_set == nil then
        return true, nil
    end

    if not core.is_table(rule_set) then
        return false,
            "adapter."
            .. dataset_name
            .. " must be a table when provided"
    end

    for mnemonic, rules in pairs(rule_set) do
        if type(mnemonic) ~= "string" or mnemonic == "" then
            return false,
                "adapter."
                .. dataset_name
                .. " must be mnemonic-indexed; numeric/legacy entries are not allowed by Adapter Contract v1"
        end

        if not core.is_table(rules) or #rules == 0 then
            return false,
                "adapter."
                .. dataset_name
                .. "."
                .. mnemonic
                .. " must contain at least one rule"
        end

        for index, rule in ipairs(rules) do
            local path = "adapter."
                .. dataset_name
                .. "."
                .. mnemonic
                .. "["
                .. tostring(index)
                .. "]"

            if not core.is_table(rule) then
                return path_error(path, "must be a table")
            end

            local ok, err = M.validate_syntax(
                rule.syntax,
                path .. ".syntax"
            )

            if not ok then
                return false, err
            end

            if rule.syntax.node_type ~= "instruction" then
                return path_error(
                    path .. ".syntax.node_type",
                    "must be 'instruction' for an instruction-driven semantic rule"
                )
            end

            local rule_mnemonic = get_rule_mnemonic(rule)

            if rule_mnemonic ~= mnemonic:lower() then
                return path_error(
                    path .. ".syntax.fields.kind.text",
                    "must match mnemonic bucket '" .. mnemonic .. "'"
                )
            end

            ok, err = validate_operands(
                rule.operands,
                path .. ".operands"
            )

            if not ok then
                return false, err
            end

            if opts.require_effect and not core.is_table(rule.effect) then
                return path_error(path .. ".effect", "must be a table")
            end

            if core.is_table(rule.effect) then
                ok, err = validate_effect_semantics(
                    rule.effect,
                    path .. ".effect"
                )

                if not ok then
                    return false, err
                end
            end

            if opts.require_event and not core.is_table(rule.event) then
                return path_error(path .. ".event", "must be a table")
            end
        end
    end

    return true, nil
end


local reusable_validation_components = {
    construct_specs = true,
    scope_members = true,
    scope_binding_modifiers = true,
    presentation = true,
    instruction_parser = true,
    memory_accesses = true,
    boundary_effects = true,
    register_effects = true,
    instruction_events = true,
    stack_effects = true,
    range_scopes = true,
}


local function validate_stable_validation_components(components)
    if components == nil then
        return true, nil
    end

    if not core.is_table(components) then
        return false,
            "adapter.validation_stable_components must be a table when provided"
    end

    for component, enabled in pairs(components) do
        if not reusable_validation_components[component] then
            return false,
                "adapter.validation_stable_components contains unsupported component: "
                .. tostring(component)
        end

        if enabled ~= true then
            return false,
                "adapter.validation_stable_components."
                .. tostring(component)
                .. " must be true when declared"
        end
    end

    return true, nil
end


local function validation_component_is_reusable(
    opts,
    component,
    value
)
    if type(opts) ~= "table"
        or type(opts.validated_components) ~= "table"
    then
        return false
    end

    return value ~= nil
        and opts.validated_components[component]
            == value
end


local function profile_reused_component(
    opts,
    name
)
    local started =
        profile_begin(
            opts,
            name
        )

    profile_end(
        opts,
        name,
        started
    )
end


local function validate_capabilities(capabilities)
    if capabilities == nil then
        return true, nil
    end

    if not core.is_table(capabilities) then
        return false, "adapter.capabilities must be a table when provided"
    end

    for capability, enabled in pairs(capabilities) do
        if not core.is_non_empty_string(capability) then
            return false, "adapter.capabilities keys must be non-empty strings"
        end

        if type(enabled) ~= "boolean" then
            return false,
                "adapter.capabilities."
                .. capability
                .. " must be a boolean"
        end
    end

    return true, nil
end


local function validate_sections(sections)
    if sections == nil then
        return true, nil
    end

    if not core.is_table(sections) then
        return false, "adapter.sections must be a table when provided"
    end

    for section_key, descriptor in pairs(sections) do
        local path = "adapter.sections." .. tostring(section_key)

        if not core.is_non_empty_string(section_key) then
            return false, "adapter.sections keys must be non-empty strings"
        end

        if not core.is_table(descriptor) then
            return path_error(path, "must be a table")
        end

        if descriptor.id ~= section_key then
            return path_error(
                path .. ".id",
                "must match section key '" .. section_key .. "'"
            )
        end

        if not core.is_non_empty_string(descriptor.label) then
            return path_error(
                path .. ".label",
                "must be a non-empty string"
            )
        end

        local ok, err = validate_optional_boolean(
            descriptor.use_source_index,
            path .. ".use_source_index"
        )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_presentation(presentation)
    if presentation == nil then
        return true, nil
    end

    if not core.is_table(presentation) then
        return false, "adapter.presentation must be a table when provided"
    end

    if presentation.sections == nil then
        return true, nil
    end

    if not core.is_table(presentation.sections) then
        return false,
            "adapter.presentation.sections must be a table when provided"
    end

    if presentation.sections.order == nil then
        return true, nil
    end

    return validate_string_list(
        presentation.sections.order,
        "adapter.presentation.sections.order",
        { unique = true }
    )
end


local function validate_memory_accesses(memory_accesses)
    if memory_accesses == nil then
        return true, nil
    end

    if not core.is_table(memory_accesses) then
        return false,
            "adapter.memory_accesses must be a table when provided"
    end

    local valid_access = {
        read = true,
        write = true,
        read_write = true,
        address_only = true,
        unknown = true,
    }

    for mnemonic, rules in pairs(memory_accesses) do
        local path = "adapter.memory_accesses[" .. tostring(mnemonic) .. "]"

        if not core.is_non_empty_string(mnemonic) then
            return false,
                "adapter.memory_accesses keys must be non-empty strings"
        end

        if not core.is_table(rules) or #rules == 0 then
            return path_error(
                path,
                "must be a non-empty array of rules"
            )
        end

        local seen_operand_indexes = {}

        for index, rule in ipairs(rules) do
            local rule_path = path .. "[" .. tostring(index) .. "]"

            if not core.is_table(rule) then
                return path_error(rule_path, "must be a table")
            end

            if not core.is_number(rule.operand_index)
                or rule.operand_index < 1
                or rule.operand_index ~= math.floor(rule.operand_index)
            then
                return path_error(
                    rule_path .. ".operand_index",
                    "must be a positive integer"
                )
            end

            if seen_operand_indexes[rule.operand_index] then
                return path_error(
                    rule_path .. ".operand_index",
                    "duplicates an earlier rule for this mnemonic"
                )
            end

            seen_operand_indexes[rule.operand_index] = true

            if rule.operand_kind ~= nil
                and not core.is_non_empty_string(rule.operand_kind)
            then
                return path_error(
                    rule_path .. ".operand_kind",
                    "must be a non-empty string when provided"
                )
            end

            if not core.is_non_empty_string(rule.access)
                or not valid_access[rule.access]
            then
                return path_error(
                    rule_path .. ".access",
                    "must be one of read, write, read_write, address_only, unknown"
                )
            end
        end
    end

    return true, nil
end


local function validate_instruction_parser(instruction_parser)
    if instruction_parser == nil then
        return true, nil
    end

    if not core.is_table(instruction_parser) then
        return false,
            "adapter.instruction_parser must be a table when provided"
    end

    if not core.is_non_empty_string(instruction_parser.module) then
        return false,
            "adapter.instruction_parser.module must be a non-empty string"
    end

    if not core.is_non_empty_string(instruction_parser.function_name) then
        return false,
            "adapter.instruction_parser.function_name must be a non-empty string"
    end

    if instruction_parser.cache_identity ~= nil
        and instruction_parser.cache_identity ~= "node"
        and instruction_parser.cache_identity ~= "node_and_spec"
    then
        return false,
            "adapter.instruction_parser.cache_identity must be 'node' or 'node_and_spec' when provided"
    end

    return true, nil
end


local function normalize_filetypes(filetypes)
    if core.is_string(filetypes) then
        return { filetypes }
    end

    if core.is_table(filetypes) then
        return filetypes
    end

    return {}
end


local function validate_target_dimensions(
    target_dimensions
)
    if target_dimensions == nil then
        return true, nil
    end

    if not core.is_table(target_dimensions) then
        return false,
            "adapter.target_dimensions must be a table when provided"
    end

    for dimension_name, descriptor in pairs(
        target_dimensions
    ) do
        if not core.is_non_empty_string(
            dimension_name
        ) then
            return false,
                "adapter.target_dimensions keys must be non-empty strings"
        end

        -- Descriptor names are literal source/config keys, not user values.
        -- Boundary whitespace makes those declared dimensions unreachable.
        if dimension_name:match("^%s")
            or dimension_name:match("%s$")
        then
            return false,
                "adapter.target_dimensions keys must not have boundary whitespace"
        end

        local path =
            "adapter.target_dimensions."
            .. dimension_name

        if not core.is_table(descriptor) then
            return path_error(
                path,
                "must be a table"
            )
        end

        if not core.is_non_empty_string(
            descriptor.default
        ) then
            return path_error(
                path .. ".default",
                "must be a non-empty string"
            )
        end

        local supported_ok,
            supported_err =
            validate_string_list(
                descriptor.supported,
                path .. ".supported",
                {
                    non_empty = true,
                    unique = true,
                }
            )

        if not supported_ok then
            return false, supported_err
        end

        local supported = {}

        for _, value in ipairs(
            descriptor.supported
        ) do
            supported[value] = true
        end

        if not supported[
            descriptor.default
        ] then
            return path_error(
                path .. ".default",
                "must name a supported canonical value"
            )
        end

        if descriptor.aliases ~= nil then
            if not core.is_table(
                descriptor.aliases
            ) then
                return path_error(
                    path .. ".aliases",
                    "must be a table when provided"
                )
            end

            for alias, canonical in pairs(
                descriptor.aliases
            ) do
                if not core.is_non_empty_string(
                    alias
                ) then
                    return path_error(
                        path .. ".aliases",
                        "keys must be non-empty strings"
                    )
                end

                if not core.is_non_empty_string(
                    canonical
                ) then
                    return path_error(
                        path
                            .. ".aliases."
                            .. alias,
                        "must be a non-empty string"
                    )
                end

                if not supported[canonical] then
                    return path_error(
                        path
                            .. ".aliases."
                            .. alias,
                        "must resolve directly to a supported canonical value"
                    )
                end
            end
        end

        -- Enforce the same case-folded identity used by runtime lookup.
        local unique, uniqueness_err =
            target_dimension_helpers.validate_name_uniqueness(
                descriptor
            )

        if not unique then
            return path_error(
                path,
                uniqueness_err
            )
        end
    end

    return true, nil
end


local function validate_filetypes(filetypes)
    local normalized = normalize_filetypes(filetypes)

    if #normalized == 0 then
        return false,
            "adapter.filetypes must contain at least one filetype"
    end

    return validate_string_list(
        normalized,
        "adapter.filetypes",
        { non_empty = true, unique = true }
    )
end


function M.validate_adapter(
    adapter,
    opts
)
    opts = type(opts) == "table"
        and opts
        or nil

    if not core.is_table(adapter) then
        return false, "adapter must be a table"
    end

    if not core.is_number(adapter.contract_version) then
        return false,
            "adapter.contract_version is required and must be a number"
    end

    if adapter.contract_version ~= M.current_version then
        return false,
            "unsupported adapter.contract_version: "
            .. tostring(adapter.contract_version)
            .. " (expected "
            .. tostring(M.current_version)
            .. ")"
    end

    if not core.is_non_empty_string(adapter.name) then
        return false, "adapter.name must be a non-empty string"
    end

    local ok, err =
        validate_phase(
            opts,
            "context.configure.validate.filetypes",
            validate_filetypes,
            adapter.filetypes
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_phase(
            opts,
            "context.configure.validate.target_dimensions",
            validate_target_dimensions,
            adapter.target_dimensions
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_phase(
            opts,
            "context.configure.validate.stable_components",
            validate_stable_validation_components,
            adapter.validation_stable_components
        )

    if not ok then
        return false, err
    end

    if validation_component_is_reusable(
        opts,
        "construct_specs",
        adapter.construct_specs
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.construct_specs_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.construct_specs",
                validate_construct_specs,
                adapter.construct_specs
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "scope_members",
        adapter.scope_members
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.scope_members_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.scope_members",
                validate_scope_members,
                adapter.scope_members
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "scope_binding_modifiers",
        adapter.scope_binding_modifiers
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.scope_binding_modifiers_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.scope_binding_modifiers",
                validate_scope_binding_modifiers,
                adapter.scope_binding_modifiers
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "range_scopes",
        adapter.range_scopes
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.range_scopes_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.range_scopes",
                validate_range_scopes,
                adapter.range_scopes
            )

        if not ok then
            return false, err
        end
    end

    ok, err =
        validate_phase(
            opts,
            "context.configure.validate.capabilities",
            validate_capabilities,
            adapter.capabilities
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_phase(
            opts,
            "context.configure.validate.sections",
            validate_sections,
            adapter.sections
        )

    if not ok then
        return false, err
    end

    if validation_component_is_reusable(
        opts,
        "presentation",
        adapter.presentation
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.presentation_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.presentation",
                validate_presentation,
                adapter.presentation
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "instruction_parser",
        adapter.instruction_parser
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.instruction_parser_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.instruction_parser",
                validate_instruction_parser,
                adapter.instruction_parser
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "memory_accesses",
        adapter.memory_accesses
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.memory_accesses_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.memory_accesses",
                validate_memory_accesses,
                adapter.memory_accesses
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "register_effects",
        adapter.register_effects
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.register_effects_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.register_effects",
                validate_instruction_rule_set,
                adapter.register_effects,
                "register_effects",
                { require_effect = true }
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "instruction_events",
        adapter.instruction_events
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.instruction_events_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.instruction_events",
                validate_instruction_rule_set,
                adapter.instruction_events,
                "instruction_events",
                {
                    require_effect = true,
                    require_event = true,
                }
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "stack_effects",
        adapter.stack_effects
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.stack_effects_reuse"
        )
    else
        ok, err =
            validate_phase(
                opts,
                "context.configure.validate.stack_effects",
                validate_instruction_rule_set,
                adapter.stack_effects,
                "stack_effects",
                { require_effect = true }
            )

        if not ok then
            return false, err
        end
    end

    if validation_component_is_reusable(
        opts,
        "boundary_effects",
        adapter.boundary_effects
    )
    then
        profile_reused_component(
            opts,
            "context.configure.validate.boundary_effects_reuse"
        )

        return true, nil
    end

    return validate_phase(
        opts,
        "context.configure.validate.boundary_effects",
        validate_instruction_rule_set,
        adapter.boundary_effects,
        "boundary_effects"
    )
end


return M
