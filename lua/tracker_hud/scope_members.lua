-- lua/tracker_hud/scope_members.lua
--
-- Static scope member discovery.
--
-- This module discovers simple names that are visible candidates for the
-- Scope Members HUD section. It does not resolve values or lifetimes yet.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local construct_utils = require("tracker_hud.construct_utils")
local scope_member_model = require("tracker_hud.scope_member_model")
local scope_member_schema = require("tracker_hud.adapters.scope_member_schema")

local M = {}


-- One conservative persistent immutable discovery entry is enough for the
-- active HUD path. Switching buffers/specs safely misses and replaces it.
local persistent_discovery_cache = nil
local discovery_module_token = tostring({})
local discovery_buffer_token_serial = 0
local issued_discovery_buffer_tokens = {}


local function get_discovery_buffer_revision(
    bufnr
)
    if not vim
        or not vim.api
        or type(
            vim.api.nvim_buf_get_changedtick
        ) ~= "function"
        or type(
            vim.api.nvim_buf_get_var
        ) ~= "function"
        or type(
            vim.api.nvim_buf_set_var
        ) ~= "function"
    then
        return nil
    end

    local ok_tick, changedtick =
        pcall(
            vim.api.nvim_buf_get_changedtick,
            bufnr
        )

    if not ok_tick then
        return nil
    end

    local variable_name =
        "tracker_hud_scope_discovery_cache_token"

    local ok_token, token =
        pcall(
            vim.api.nvim_buf_get_var,
            bufnr,
            variable_name
        )

    local expected_prefix =
        discovery_module_token
        .. ":"

    if not ok_token
        or type(token) ~= "string"
        or token:sub(
            1,
            #expected_prefix
        ) ~= expected_prefix
        or issued_discovery_buffer_tokens[
            token
        ] ~= true
    then
        discovery_buffer_token_serial =
            discovery_buffer_token_serial
            + 1

        token =
            expected_prefix
            .. tostring(
                discovery_buffer_token_serial
            )

        issued_discovery_buffer_tokens[
            token
        ] = true

        local ok_set =
            pcall(
                vim.api.nvim_buf_set_var,
                bufnr,
                variable_name,
                token
            )

        if not ok_set then
            return nil
        end
    end

    return {
        token = token,
        changedtick = changedtick,
    }
end


local function persistent_discovery_matches(
    bufnr,
    adapter,
    revision
)
    local cached =
        persistent_discovery_cache

    return core.is_table(cached)
        and core.is_table(revision)
        and cached.bufnr == bufnr
        and cached.buffer_token
            == revision.token
        and cached.changedtick
            == revision.changedtick
        and cached.adapter == adapter
        and cached.scope_members
            == adapter.scope_members
        and core.is_table(
            cached.discovery
        )
end


local function remember_persistent_discovery(
    bufnr,
    adapter,
    revision,
    discovery
)
    if not core.is_table(revision)
        or not core.is_table(discovery)
    then
        persistent_discovery_cache = nil
        return
    end

    persistent_discovery_cache = {
        bufnr = bufnr,
        buffer_token = revision.token,
        changedtick = revision.changedtick,
        adapter = adapter,
        scope_members =
            adapter.scope_members,
        discovery = discovery,
    }
end


local function profile_counter(
    opts,
    suffix,
    delta
)
    if not core.is_table(opts)
        or type(opts.profile_counter)
            ~= "function"
    then
        return nil
    end

    local prefix =
        opts.profile_prefix
        or "context.scope_members"

    return opts.profile_counter(
        prefix
            .. "."
            .. suffix,
        delta
    )
end


local function count_measurement(
    state,
    key,
    delta
)
    local measurement =
        state
        and state.measurement

    if not core.is_table(
        measurement
    ) then
        return
    end

    measurement[key] =
        (measurement[key] or 0)
        + (delta or 1)
end


local function with_scope_depth_filter(
    state,
    enabled
)
    state = state or {
        opts = {},
        scope_depth = 0,
        structural_depth = 0,
    }

    return {
        opts = state.opts,
        scope_depth = state.scope_depth,
        scope_range = state.scope_range,
        structural_depth =
            state.structural_depth,
        structural_range =
            state.structural_range,
        direct_structural_visibility_range =
            state.direct_structural_visibility_range,
        inherited_structural_visibility_range =
            state.inherited_structural_visibility_range,
        structural_path =
            state.structural_path,
        lexical_path =
            state.lexical_path,
        annotation_depth =
            state.annotation_depth,
        annotation_range =
            state.annotation_range,
        annotation_path =
            state.annotation_path,
        measurement =
            state.measurement,
        scope_depth_filter =
            enabled ~= false,
    }
end


local function get_syntax(member_spec)
    if not core.is_table(member_spec)
        or not core.is_table(member_spec.syntax)
    then
        return {}
    end

    return member_spec.syntax
end


local function get_syntax_node_type(member_spec)
    local syntax = get_syntax(member_spec)

    if core.is_non_empty_string(syntax.node_type) then
        return syntax.node_type
    end

    --
    -- Temporary compatibility for adapters that have not yet migrated to the
    -- Tree-sitter-first syntax contract.
    --
    return member_spec and member_spec.node_type or nil
end


local member_group_names =
    scope_member_schema.group_names


local function build_member_group_index(
    specs
)
    local index = {
        by_node_type = {},
        untyped = {},
        candidates_by_node_type = {},
        spec_count = 0,
    }

    if not core.is_table(specs) then
        return index
    end

    for position, member_spec in ipairs(
        specs
    ) do
        index.spec_count =
            index.spec_count + 1

        local entry = {
            position = position,
            spec = member_spec,
        }

        local node_type =
            get_syntax_node_type(
                member_spec
            )

        if core.is_non_empty_string(
            node_type
        ) then
            local bucket =
                index.by_node_type[
                    node_type
                ]

            if not core.is_table(bucket) then
                bucket = {}
                index.by_node_type[
                    node_type
                ] = bucket
            end

            table.insert(
                bucket,
                entry
            )
        else
            table.insert(
                index.untyped,
                entry
            )
        end
    end

    return index
end


local function build_member_spec_index(
    scope_member_spec
)
    local index = {
        active_group_names = {},
        eligible_group_names_by_node_type = {},
        annotation_scope_specs_by_node_type = {},
    }

    scope_member_spec =
        core.is_table(scope_member_spec)
        and scope_member_spec
        or {}

    for _, group_name in ipairs(
        member_group_names
    ) do
        local group_index =
            build_member_group_index(
                scope_member_spec[
                    group_name
                ]
            )

        index[group_name] =
            group_index

        if (group_index.spec_count or 0) > 0 then
            table.insert(
                index.active_group_names,
                group_name
            )
        end

        for _, entry in pairs(
            group_index.by_node_type
                or {}
        ) do
            for _, typed_entry in ipairs(
                entry
            ) do
                local member_spec =
                    typed_entry.spec
                local member =
                    core.is_table(member_spec)
                    and core.is_table(
                        member_spec.member
                    )
                    and member_spec.member
                    or nil

                if member
                    and member.annotation_scope
                        == true
                then
                    local node_type =
                        get_syntax_node_type(
                            member_spec
                        )

                    index
                        .annotation_scope_specs_by_node_type[
                            node_type
                        ] =
                        index
                            .annotation_scope_specs_by_node_type[
                                node_type
                            ]
                        or {}

                    table.insert(
                        index
                            .annotation_scope_specs_by_node_type[
                                node_type
                            ],
                        member_spec
                    )
                end
            end
        end
    end

    return index
end


local function member_group_candidates(
    group_index,
    node_type
)
    if not core.is_table(group_index) then
        return {}
    end

    if not core.is_non_empty_string(
        node_type
    ) then
        return group_index.untyped
            or {}
    end

    local cached =
        group_index
            .candidates_by_node_type[
                node_type
            ]

    if core.is_table(cached) then
        return cached
    end

    local typed =
        group_index.by_node_type[
            node_type
        ]
        or {}

    local untyped =
        group_index.untyped
        or {}

    if #untyped == 0 then
        group_index
            .candidates_by_node_type[
                node_type
            ] = typed

        return typed
    end

    if #typed == 0 then
        group_index
            .candidates_by_node_type[
                node_type
            ] = untyped

        return untyped
    end

    local candidates = {}
    local typed_index = 1
    local untyped_index = 1

    while typed_index <= #typed
        or untyped_index <= #untyped
    do
        local typed_entry =
            typed[typed_index]

        local untyped_entry =
            untyped[untyped_index]

        if untyped_entry == nil
            or (
                typed_entry ~= nil
                and typed_entry.position
                    < untyped_entry.position
            )
        then
            table.insert(
                candidates,
                typed_entry
            )
            typed_index =
                typed_index + 1
        else
            table.insert(
                candidates,
                untyped_entry
            )
            untyped_index =
                untyped_index + 1
        end
    end

    group_index
        .candidates_by_node_type[
            node_type
        ] = candidates

    return candidates
end


local function member_group_can_match_node(
    group_index,
    node_type
)
    if not core.is_table(group_index) then
        return false
    end

    local untyped =
        group_index.untyped
        or {}

    if #untyped > 0 then
        return true
    end

    if not core.is_non_empty_string(
        node_type
    ) then
        return false
    end

    local typed =
        group_index.by_node_type[
            node_type
        ]

    return core.is_table(typed)
        and #typed > 0
end


local function member_group_names_for_node_type(
    member_spec_index,
    node_type
)
    if not core.is_table(
        member_spec_index
    ) then
        return {}
    end

    local active_group_names =
        member_spec_index.active_group_names

    if not core.is_table(
        active_group_names
    ) then
        active_group_names =
            member_group_names
    end

    if not core.is_non_empty_string(
        node_type
    ) then
        local untyped_group_names = {}

        for _, group_name in ipairs(
            active_group_names
        ) do
            local group_index =
                member_spec_index[
                    group_name
                ]

            local untyped =
                core.is_table(group_index)
                and group_index.untyped
                or {}

            if #untyped > 0 then
                table.insert(
                    untyped_group_names,
                    group_name
                )
            end
        end

        return untyped_group_names
    end

    local cache =
        member_spec_index
            .eligible_group_names_by_node_type

    if not core.is_table(cache) then
        cache = {}
        member_spec_index
            .eligible_group_names_by_node_type =
                cache
    end

    local cached =
        cache[node_type]

    if core.is_table(cached) then
        return cached
    end

    local eligible_group_names = {}

    for _, group_name in ipairs(
        active_group_names
    ) do
        local group_index =
            member_spec_index[
                group_name
            ]

        if member_group_can_match_node(
            group_index,
            node_type
        ) then
            table.insert(
                eligible_group_names,
                group_name
            )
        end
    end

    cache[node_type] =
        eligible_group_names

    return eligible_group_names
end


local function get_syntax_field_descriptor(
    member_spec,
    key
)
    local syntax = get_syntax(member_spec)
    local fields = syntax.fields or {}
    local field_spec = fields[key]

    if core.is_non_empty_string(field_spec) then
        return {
            field = field_spec,
        }
    end

    if core.is_table(field_spec)
        and core.is_non_empty_string(
            field_spec.field
        )
    then
        return field_spec
    end

    return nil
end


local function get_syntax_field(member_spec, key)
    local field_spec =
        get_syntax_field_descriptor(
            member_spec,
            key
        )

    return field_spec
        and field_spec.field
        or nil
end


local function syntax_field_node_matches(
    node,
    field_spec
)
    if not node or not core.is_table(field_spec) then
        return false
    end

    local has_filter = false

    if core.is_non_empty_string(
        field_spec.node_type
    ) then
        has_filter = true

        if ts_utils.node_type_matches(
            node,
            field_spec.node_type
        ) then
            return true
        end
    end

    for _, node_type in ipairs(
        field_spec.node_types or {}
    ) do
        if core.is_non_empty_string(
            node_type
        ) then
            has_filter = true

            if ts_utils.node_type_matches(
                node,
                node_type
            ) then
                return true
            end
        end
    end

    return not has_filter
end


local function recursive_field_node_type_matches(
    node_type,
    node_types
)
    for _, expected in ipairs(
        node_types or {}
    ) do
        if node_type == expected then
            return true
        end
    end

    return false
end


local function collect_recursive_field_nodes(
    node,
    recursive_spec,
    result
)
    if not node
        or not core.is_table(
            recursive_spec
        )
    then
        return
    end

    local node_type =
        node:type()

    if recursive_field_node_type_matches(
        node_type,
        recursive_spec
            .terminal_node_types
            or {}
    )
    then
        table.insert(
            result,
            node
        )

        return
    end

    if not recursive_field_node_type_matches(
        node_type,
        recursive_spec
            .container_node_types
            or {}
    )
    then
        return
    end

    for index = 0,
        node:named_child_count() - 1
    do
        collect_recursive_field_nodes(
            node:named_child(index),
            recursive_spec,
            result
        )
    end
end


local function get_syntax_field_nodes(
    node,
    member_spec,
    key
)
    local field_spec =
        get_syntax_field_descriptor(
            member_spec,
            key
        )

    if not field_spec or not node then
        return {}
    end

    local result = {}

    for _, field_node in ipairs(
        ts_utils.get_children_by_field_name(
            node,
            field_spec.field
        )
    ) do
        if syntax_field_node_matches(
            field_node,
            field_spec
        ) then
            if core.is_table(
                field_spec.recursive
            )
            then
                collect_recursive_field_nodes(
                    field_node,
                    field_spec.recursive,
                    result
                )
            else
                table.insert(
                    result,
                    field_node
                )
            end

            if field_spec.multiple
                ~= true
            then
                break
            end
        end
    end

    return result
end


local function get_syntax_child_node_type(member_spec, key)
    local syntax = get_syntax(member_spec)
    local children = syntax.children or {}
    local child = children[key]

    if core.is_non_empty_string(child) then
        return child
    end

    if core.is_table(child)
        and core.is_non_empty_string(child.node_type)
    then
        return child.node_type
    end

    return nil
end


local function get_syntax_child_node_types(
    member_spec,
    key
)
    local syntax = get_syntax(member_spec)
    local children = syntax.children or {}
    local child = children[key]
    local result = {}

    if core.is_non_empty_string(child) then
        table.insert(result, child)
        return result
    end

    if not core.is_table(child) then
        return result
    end

    if core.is_non_empty_string(
        child.node_type
    ) then
        table.insert(
            result,
            child.node_type
        )
    end

    for _, node_type in ipairs(
        child.node_types or {}
    ) do
        if core.is_non_empty_string(
            node_type
        ) then
            table.insert(result, node_type)
        end
    end

    return result
end


local function get_syntax_ancestor_exclusions(member_spec)
    local syntax = get_syntax(member_spec)
    local exclusions = syntax.exclusions or {}

    if core.is_table(exclusions.ancestor_node_types) then
        return exclusions.ancestor_node_types
    end

    --
    -- Temporary compatibility for adapters that have not yet migrated.
    --
    if core.is_table(member_spec)
        and core.is_table(member_spec.exclude_ancestor_node_types)
    then
        return member_spec.exclude_ancestor_node_types
    end

    return {}
end


local function with_member_owner_scope(
    state,
    member_spec
)
    local result = {}

    for key, value in pairs(
        state or {}
    ) do
        result[key] = value
    end

    local member =
        core.is_table(member_spec)
        and core.is_table(
            member_spec.member
        )
        and member_spec.member
        or nil

    result.member_is_binding =
        core.is_table(member)
        and core.is_table(
            member.mutability
        )
        and member.mutability.binding
            ~= nil

    local excluded =
        member
        and member
            .owner_scope_excluded_construct_kinds
        or nil

    if not core.is_table(excluded)
        or #excluded == 0
        or member.owner_scope ~= "lexical"
    then
        return result
    end

    local excluded_set = {}

    for _, construct_kind in ipairs(
        excluded
    ) do
        excluded_set[construct_kind] = true
    end

    local lexical_path =
        state
        and state.lexical_path
        or {}

    for index = #lexical_path, 1, -1 do
        local frame =
            lexical_path[index]

        if core.is_table(frame)
            and excluded_set[
                frame.construct_kind
            ] ~= true
        then
            result.scope_depth =
                frame.depth
                or 0
            result.scope_range =
                frame.range

            return result
        end
    end

    result.scope_depth = 0
    result.scope_range = nil

    return result
end


local function with_member_annotation_scope(
    state,
    member_spec
)
    local result = {}

    for key, value in pairs(
        state or {}
    ) do
        result[key] = value
    end

    local member =
        core.is_table(member_spec)
        and core.is_table(
            member_spec.member
        )
        and member_spec.member
        or nil

    if not member
        or member.annotation_scope
            ~= true
        or not core.is_table(
            state
            and state.annotation_range
        )
    then
        return result
    end

    result.member_annotation_depth =
        state.annotation_depth
    result.member_annotation_range =
        state.annotation_range
    result.member_annotation_path =
        state.annotation_path
    result.member_visibility_range =
        state.annotation_range
    result.scope_depth_filter = false

    return result
end


local function with_member_visibility(
    state,
    member_spec
)
    local result = {}

    for key, value in pairs(
        state or {}
    ) do
        result[key] = value
    end

    local visibility =
        core.is_table(member_spec)
        and core.is_table(
            member_spec.member
        )
        and member_spec.member.visibility
        or nil

    if core.is_table(visibility)
        and visibility.range
            == "structural_scope"
    then
        local structural_visibility_range =
            state
            and (
                state.structural_range
                or state
                    .direct_structural_visibility_range
                or state
                    .inherited_structural_visibility_range
            )
            or nil

        if core.is_table(
            structural_visibility_range
        ) then
            result.member_visibility_range =
                structural_visibility_range
        else
            result.member_visibility_range =
                nil
        end
    else
        result.member_visibility_range =
            nil
    end

    return result
end


local function make_state(
    opts,
    scope_depth,
    scope_range,
    structural_depth,
    structural_range,
    measurement,
    structural_path,
    lexical_path,
    annotation_depth,
    annotation_range,
    annotation_path
)
    return {
        opts = opts or {},
        scope_depth = scope_depth or 0,
        scope_range = scope_range,

        structural_depth = structural_depth or 0,
        structural_range = structural_range,
        structural_path = structural_path or {},
        lexical_path = lexical_path or {},

        annotation_depth =
            annotation_depth or 0,
        annotation_range =
            annotation_range,
        annotation_path =
            annotation_path or {},

        measurement = measurement,
    }
end


local function append_structural_path(
    path,
    frame
)
    local result = {}

    for index, existing in ipairs(
        path or {}
    ) do
        result[index] = existing
    end

    table.insert(result, frame)

    return result
end


local function append_lexical_path(
    path,
    frame
)
    local result = {}

    for index, existing in ipairs(
        path or {}
    ) do
        result[index] = existing
    end

    table.insert(result, frame)

    return result
end


local function append_annotation_path(
    path,
    frame
)
    local result = {}

    for index, existing in ipairs(
        path or {}
    ) do
        result[index] = existing
    end

    table.insert(result, frame)

    return result
end


local function get_field_value_node(node, member_spec)
    if not node then
        return nil
    end

    local value_field =
        get_syntax_field(member_spec, "value")
        or "value"

    local value_node =
        ts_utils.get_child_by_field_name(
            node,
            value_field
        )

    if value_node then
        return value_node
    end

    if node:named_child_count() >= 2 then
        return node:named_child(1)
    end

    return nil
end


local function strip_quotes(text)
    if not core.is_non_empty_string(text) then
        return text
    end

    return text
        :gsub('^"', "")
        :gsub('"$', "")
        :gsub("^'", "")
        :gsub("'$", "")
end


local function get_field_name(node, bufnr, member_spec)
    if not node then
        return nil
    end

    local name_field =
        get_syntax_field(member_spec, "name")
        or "name"

    local name_node =
        ts_utils.get_child_by_field_name(
            node,
            name_field
        )

    if name_node then
        return strip_quotes(
            ts_utils.get_node_text(
                name_node,
                bufnr
            )
        )
    end

    -- Some C/C++ parser variants do not expose every declaration's
    -- declarator/name field as a direct TSNode:field. Adapters may declare
    -- precise fallback named-node types under syntax.children.name; never
    -- guess an arbitrary child or introduce a source-text regex.
    for _, name_node_type in ipairs(
        get_syntax_child_node_types(member_spec, "name")
    ) do
        local fallback = ts_utils.find_first_descendant_by_type(node, name_node_type)
        if fallback then
            local value = ts_utils.get_node_text(fallback, bufnr)
            if core.is_non_empty_string(value) then
                return strip_quotes(value)
            end
        end
    end

    local first_named_child = node:named_child(0)

    if not first_named_child then
        return nil
    end

    local child_type = first_named_child:type()

    if child_type ~= "identifier" and child_type ~= "string" then
        return nil
    end

    return strip_quotes(ts_utils.get_node_text(first_named_child, bufnr))
end


local function should_skip_member_spec_node(
    node,
    member_spec
)
    return core.is_table(member_spec)
        and ts_utils.node_has_ancestor_type(
            node,
            get_syntax_ancestor_exclusions(
                member_spec
            )
        )
end


local function node_type_is_in_list(
    node_type,
    allowed_node_types
)
    if not core.is_non_empty_string(
        node_type
    )
        or not core.is_table(
            allowed_node_types
        )
    then
        return false
    end

    for _, allowed in ipairs(
        allowed_node_types
    ) do
        if node_type == allowed then
            return true
        end
    end

    return false
end


local function member_spec_constraints_match(
    node,
    member_spec
)
    local syntax =
        get_syntax(member_spec)
    local constraints =
        syntax.constraints

    if constraints == nil then
        return true
    end

    if not core.is_table(constraints)
        or not node
    then
        return false
    end

    local ancestor_node_types =
        constraints.ancestor_node_types

    if core.is_table(
        ancestor_node_types
    )
        and #ancestor_node_types > 0
        and not ts_utils.node_has_ancestor_type(
            node,
            ancestor_node_types
        )
    then
        return false
    end

    local parent_node_types =
        constraints.parent_node_types

    if core.is_table(
        parent_node_types
    )
        and #parent_node_types > 0
    then
        local parent = node:parent()

        if not parent
            or not node_type_is_in_list(
                parent:type(),
                parent_node_types
            )
        then
            return false
        end
    end

    if constraints.named_child_count
        ~= nil
        and node:named_child_count()
            ~= constraints.named_child_count
    then
        return false
    end

    return true
end


local function collect_names_with_values_from_list_nodes(
    name_list_node,
    value_list_node,
    bufnr,
    adapter,
    members,
    seen,
    kind,
    source_range,
    state
)
    if not name_list_node then
        return
    end

    for i = 0, name_list_node:named_child_count() - 1 do
        local name_node = name_list_node:named_child(i)
        local value_node = nil

        if value_list_node and i < value_list_node:named_child_count() then
            value_node = value_list_node:named_child(i)
        end

        local name = ts_utils.get_node_text(name_node, bufnr)
        local metadata = construct_utils.build_value_metadata(value_node, bufnr, adapter)

        scope_member_model.add(
            members,
            seen,
            name,
            kind,
            source_range,
            state,
            metadata
        )
    end
end


local function get_list_member_name(
    node,
    bufnr,
    member_spec
)
    if not node then
        return nil
    end

    -- List containers (for example function parameters) may contain richer
    -- binding nodes. Reuse the adapter-authorized syntax.children.name
    -- declaration instead of teaching shared core about language-specific
    -- syntax. When an adapter declares allowed name-node types, a list child
    -- without one is not a binding and must not fall through to whole-node
    -- text (for example a grammar separator node).
    local name_node_types =
        get_syntax_child_node_types(
            member_spec,
            "name"
        )

    for _, name_node_type in ipairs(
        name_node_types
    ) do
        local name_node =
            ts_utils.find_first_descendant_by_type(
                node,
                name_node_type
            )

        if name_node then
            local name =
                ts_utils.get_node_text(
                    name_node,
                    bufnr
                )

            if core.is_non_empty_string(name) then
                return strip_quotes(name)
            end
        end
    end

    if #name_node_types > 0 then
        return nil
    end

    return ts_utils.get_node_text(
        node,
        bufnr
    )
end


local function collect_names_from_list_node(
    list_node,
    bufnr,
    members,
    seen,
    kind,
    source_range,
    state,
    member_spec
)
    if not list_node then
        return
    end

    for i = 0, list_node:named_child_count() - 1 do
        local variable =
            list_node:named_child(i)

        local name =
            get_list_member_name(
                variable,
                bufnr,
                member_spec
            )

        local member_source_range =
            ts_utils.get_node_range_fields(
                variable
            )
            or source_range

        scope_member_model.add(
            members,
            seen,
            name,
            kind,
            member_source_range,
            state
        )
    end
end


local function collect_list_nodes_recursive(
    node,
    bufnr,
    list_node_type,
    members,
    seen,
    kind,
    source_range,
    state,
    member_spec
)
    if not node then
        return
    end

    if ts_utils.node_type_matches(
        node,
        list_node_type
    ) then
        collect_names_from_list_node(
            node,
            bufnr,
            members,
            seen,
            kind,
            source_range,
            state,
            member_spec
        )
        return
    end

    for child in node:iter_children() do
        collect_list_nodes_recursive(
            child,
            bufnr,
            list_node_type,
            members,
            seen,
            kind,
            source_range,
            state,
            member_spec
        )
    end
end


local function collect_declaration_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local name_list_node = ts_utils.find_first_descendant_by_type(
        node,
        get_syntax_child_node_type(
            member_spec,
            "names"
        )
    )

    if not name_list_node then
        return
    end

    local value_list_node = ts_utils.find_first_descendant_by_type(
        node,
        get_syntax_child_node_type(
            member_spec,
            "values"
        )
    )

    local source_range = ts_utils.get_node_range_fields(node)

    collect_names_with_values_from_list_nodes(
        name_list_node,
        value_list_node,
        bufnr,
        adapter,
        members,
        seen,
        member_spec.member and member_spec.member.kind,
        source_range,
        state
    )
end


local function collect_return_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local value_list_node = ts_utils.find_first_descendant_by_type(
        node,
        get_syntax_child_node_type(
            member_spec,
            "values"
        )
    )

    if not value_list_node then
        return
    end

    local source_range = ts_utils.get_node_range_fields(node)
    local kind = member_spec.member and member_spec.member.kind

    for i = 0, value_list_node:named_child_count() - 1 do
        local value_node = value_list_node:named_child(i)
        local metadata = construct_utils.build_value_metadata(value_node, bufnr, adapter)
        local name = "return"

        if value_list_node:named_child_count() > 1 then
            name = "return #" .. tostring(i + 1)
        end

        scope_member_model.add(
            members,
            seen,
            name,
            kind,
            source_range,
            state,
            metadata
        )
    end
end


local function get_function_name(node, bufnr, member_spec)
    if not node then
        return nil
    end

    local name_field = get_syntax_field(member_spec, "name")
    local name_node = name_field
        and ts_utils.get_child_by_field_name(node, name_field)
        or nil

    if name_node then
        local name = ts_utils.get_node_text(name_node, bufnr)
        if core.is_non_empty_string(name) then
            return name
        end
    end

    -- C/C++ function_definition.declarator may be a nested declarator.
    -- Only use adapter-authorized AST node-type fallbacks.
    for _, name_node_type in ipairs(
        get_syntax_child_node_types(member_spec, "name")
    ) do
        local child = ts_utils.find_first_descendant_by_type(node, name_node_type)
        if child then
            local name = ts_utils.get_node_text(child, bufnr)
            if core.is_non_empty_string(name) then
                return name
            end
        end
    end

    return nil
end

local function collect_function_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local name =
        get_function_name(
            node,
            bufnr,
            member_spec
        )

    if not core.is_non_empty_string(name) then
        return
    end

    local source_range = ts_utils.get_node_range_fields(node)
    local kind = member_spec.member and member_spec.member.kind
    local value_spec = construct_utils.get_value_spec_from_node(node, adapter)

    local metadata = {
        value_text = name,
        value_node_type = node:type(),
        value_start_line = source_range.start_line,
        value_end_line = source_range.end_line,
        value_start_column = source_range.start_column,
        value_end_column = source_range.end_column,
        value_kind = nil,
        type_label = nil,
        source_node_type = node:type(),
    }

    if core.is_table(value_spec) then
        metadata.value_kind = value_spec.kind
        metadata.type_label = value_spec.type_label
    end

    scope_member_model.add(
        members,
        seen,
        name,
        kind,
        source_range,
        state,
        metadata
    )
end


local function collect_loop_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local source_range = ts_utils.get_node_range_fields(node)
    local kind = member_spec.member and member_spec.member.kind

    local name_field_spec =
        get_syntax_field_descriptor(
            member_spec,
            "name"
        )

    if name_field_spec then
        local name_nodes =
            get_syntax_field_nodes(
                node,
                member_spec,
                "name"
            )

        if #name_nodes > 0 then
            for _, name_node in ipairs(
                name_nodes
            ) do
                local name =
                    ts_utils.get_node_text(
                        name_node,
                        bufnr
                    )

                scope_member_model.add(
                    members,
                    seen,
                    name,
                    kind,
                    ts_utils.get_node_range_fields(
                        name_node
                    )
                        or source_range,
                    state
                )
            end

            return
        end

        if not get_syntax_child_node_type(
            member_spec,
            "names"
        ) then
            return
        end
    end

    local name_list_node_type =
        get_syntax_child_node_type(
            member_spec,
            "names"
        )

    if not core.is_non_empty_string(
        name_list_node_type
    ) then
        return
    end

    local name_list_node =
        ts_utils.find_first_descendant_by_type(
            node,
            name_list_node_type
        )

    if not name_list_node then
        return
    end

    collect_names_from_list_node(
        name_list_node,
        bufnr,
        members,
        seen,
        kind,
        source_range,
        state,
        member_spec
    )
end


local function collect_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local source_range = ts_utils.get_node_range_fields(node)
    local list_owner = node
    local parameters_field =
        get_syntax_field(
            member_spec,
            "parameters"
        )

    -- Parameter-style list members may declare the exact syntax field that
    -- owns their list container. Restrict discovery to that field so nested
    -- lexical declarations cannot leak their parameter lists into the outer
    -- owner's scope. Adapters without a container field retain the legacy
    -- recursive behavior.
    if core.is_non_empty_string(
        parameters_field
    ) then
        list_owner =
            ts_utils.get_child_by_field_name(
                node,
                parameters_field
            )

        if not list_owner then
            return
        end
    end

    collect_list_nodes_recursive(
        list_owner,
        bufnr,
        get_syntax_child_node_type(
            member_spec,
            "names"
        ),
        members,
        seen,
        member_spec.member and member_spec.member.kind,
        source_range,
        state,
        member_spec
    )
end


local function make_structural_member_state(state)
    if not state then
        return make_state()
    end

    local result =
        make_state(
            state.opts,
            state.scope_depth,
            state.structural_range or state.scope_range,
            state.structural_depth,
            state.structural_range,
            state.measurement,
            state.structural_path,
            state.lexical_path,
            state.annotation_depth,
            state.annotation_range,
            state.annotation_path
        )

    result.scope_depth_filter =
        state.scope_depth_filter

    return result
end


local function collect_field_member_spec(node, bufnr, member_spec, members, seen, state, adapter)
    if not core.is_table(member_spec) then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local name =
        get_field_name(
            node,
            bufnr,
            member_spec
        )

    if not core.is_non_empty_string(name) then
        return
    end

    local source_range = ts_utils.get_node_range_fields(node)
    local member_state = state
    local value_node =
        get_field_value_node(
            node,
            member_spec
        )
    local metadata = construct_utils.build_value_metadata(value_node, bufnr, adapter)

    metadata.source_node_type = node:type()

    if member_spec.member and member_spec.member.owner_scope == "structural" then
        member_state = make_structural_member_state(state)
    end

    scope_member_model.add(
        members,
        seen,
        name,
        member_spec.member and member_spec.member.kind,
        source_range,
        member_state,
        metadata
    )
end


local function get_first_descendant_text_by_type(node, bufnr, node_type)
    if not node or not core.is_non_empty_string(node_type) then
        return nil
    end

    local found = ts_utils.find_first_descendant_by_type(node, node_type)

    if not found then
        return nil
    end

    return ts_utils.get_node_text(found, bufnr)
end


local function parse_instruction_with_adapter(
    adapter,
    bufnr,
    node
)
    if not core.is_table(adapter)
        or not core.is_table(
            adapter.instruction_parser
        )
    then
        return nil
    end

    local parser_spec = adapter.instruction_parser
    local module_name = parser_spec.module
    local function_name =
        parser_spec.function_name
        or "parse_instruction"

    if not core.is_non_empty_string(
        module_name
    ) then
        return nil
    end

    local ok, parser_module = pcall(
        require,
        module_name
    )

    if not ok
        or not core.is_table(parser_module)
    then
        return nil
    end

    local parser_fn = parser_module[function_name]

    if type(parser_fn) ~= "function" then
        return nil
    end

    return parser_fn(
        bufnr,
        node,
        nil,
        adapter
    )
end


local function build_symbol_metadata(node, bufnr, name, member_spec)
    local source_range = ts_utils.get_node_range_fields(node)
    local value_spec = member_spec.value or {}

    return {
        value_text = name,
        value_node_type = node and node:type() or nil,
        value_start_line = source_range.start_line,
        value_end_line = source_range.end_line,
        value_start_column = source_range.start_column,
        value_end_column = source_range.end_column,
        value_kind = value_spec.kind,
        type_label = value_spec.type_label,
        source_node_type = node and node:type() or nil,
    }
end


local function collect_symbol_member_spec(node, bufnr, member_spec, members, seen, state)
    if not core.is_table(member_spec) then
        return
    end

    local opts = state.opts or {}
    local scope_depth = state.scope_depth or 0

    if opts and opts.scope_depth ~= nil and scope_depth ~= opts.scope_depth then
        return
    end

    if not ts_utils.node_type_matches(node, get_syntax_node_type(member_spec)) then
        return
    end

    local name = nil

    -- A single syntax node may declare several bindings (for example import
    -- lists). Adapter Contract field descriptors already carry multiple=true
    -- and optional node-type filters; consume that generic declaration here.
    -- Name resolution remains adapter-owned through syntax.fields.name and
    -- syntax.children.name, evaluated relative to each binding node.
    local binding_field =
        get_syntax_field_descriptor(
            member_spec,
            "bindings"
        )

    if binding_field then
        local kind =
            member_spec.member
            and member_spec.member.kind

        for _, binding_node in ipairs(
            get_syntax_field_nodes(
                node,
                member_spec,
                "bindings"
            )
        ) do
            local source_range =
                ts_utils.get_node_range_fields(
                    binding_node
                )
            local recursive_binding =
                core.is_table(
                    binding_field.recursive
                )

            local binding_name = nil

            if recursive_binding then
                binding_name =
                    ts_utils.get_node_text(
                        binding_node,
                        bufnr
                    )
            else
                binding_name =
                    get_field_name(
                        binding_node,
                        bufnr,
                        member_spec
                    )
            end

            if core.is_non_empty_string(
                binding_name
            ) then
                local metadata =
                    build_symbol_metadata(
                        recursive_binding
                            and node
                            or binding_node,
                        bufnr,
                        binding_name,
                        member_spec
                    )

                scope_member_model.add(
                    members,
                    seen,
                    binding_name,
                    kind,
                    source_range,
                    state,
                    metadata
                )
            end
        end

        return
    end

    if core.is_non_empty_string(member_spec.mnemonic) then
        local instruction =
            parse_instruction_with_adapter(
                adapter,
                bufnr,
                node
            )

        if not core.is_table(instruction)
            or instruction.mnemonic
                ~= member_spec.mnemonic:lower()
        then
            return
        end

        local operand_index =
            tonumber(member_spec.operand_index)
            or 1

        local operand = instruction.operands
            and instruction.operands[
                operand_index
            ]

        if core.is_table(operand) then
            name = operand.text
        end
    else
        local name_field =
            get_syntax_field(
                member_spec,
                "name"
            )

        if core.is_non_empty_string(
            name_field
        ) then
            local name_node =
                ts_utils.get_child_by_field_name(
                    node,
                    name_field
                )

            if name_node then
                name = ts_utils.get_node_text(
                    name_node,
                    bufnr
                )
            end
        end

        if not core.is_non_empty_string(name) then
            for _, name_node_type in ipairs(
                get_syntax_child_node_types(
                    member_spec,
                    "name"
                )
            ) do
                if ts_utils.node_type_matches(
                    node,
                    name_node_type
                ) then
                    name =
                        ts_utils.get_node_text(
                            node,
                            bufnr
                        )
                else
                    name =
                        get_first_descendant_text_by_type(
                            node,
                            bufnr,
                            name_node_type
                        )
                end

                if core.is_non_empty_string(name) then
                    break
                end
            end
        end

        -- Temporary compatibility for pre-syntax adapters.
        if not core.is_non_empty_string(name)
            and core.is_non_empty_string(
                member_spec.name_node_type
            )
        then
            name =
                get_first_descendant_text_by_type(
                    node,
                    bufnr,
                    member_spec.name_node_type
                )
        end
    end

    if not core.is_non_empty_string(name) then
        return
    end

    local source_range = ts_utils.get_node_range_fields(node)
    local kind = member_spec.member and member_spec.member.kind
    local metadata = build_symbol_metadata(node, bufnr, name, member_spec)

    scope_member_model.add(
        members,
        seen,
        name,
        kind,
        source_range,
        state,
        metadata
    )
end


local function should_collect_before_scope_enter(member_spec)
    return core.is_table(member_spec)
        and core.is_table(member_spec.member)
        and member_spec.member.owner_scope == "parent_lexical"
end


local function collect_member_group(
    node,
    bufnr,
    group_index,
    members,
    seen,
    state,
    collector,
    adapter,
    node_type
)
    count_measurement(
        state,
        "group_dispatch_calls",
        1
    )

    if not core.is_table(group_index)
        or (group_index.spec_count or 0)
            == 0
    then
        return
    end

    collector =
        collector
        or collect_member_spec

    if not member_group_can_match_node(
        group_index,
        node_type
    ) then
        return
    end

    count_measurement(
        state,
        "group_candidate_lookups",
        1
    )

    local candidates =
        member_group_candidates(
            group_index,
            node_type
        )

    if #candidates == 0 then
        return
    end

    local group_state =
        with_scope_depth_filter(
            state,
            collector
                ~= collect_field_member_spec
        )

    count_measurement(
        group_state,
        "scope_filter_state_builds",
        1
    )

    for _, entry in ipairs(
        candidates
    ) do
        local member_spec =
            entry.spec

        count_measurement(
            group_state,
            "spec_checks",
            1
        )

        if not should_skip_member_spec_node(
            node,
            member_spec
        )
            and member_spec_constraints_match(
                node,
                member_spec
            )
            and not should_collect_before_scope_enter(
                member_spec
            )
        then
            local member_state =
                with_member_owner_scope(
                    group_state,
                    member_spec
                )

            member_state =
                with_member_visibility(
                    member_state,
                    member_spec
                )

            member_state =
                with_member_annotation_scope(
                    member_state,
                    member_spec
                )

            collector(
                node,
                bufnr,
                member_spec,
                members,
                seen,
                member_state,
                adapter
            )
        end
    end
end


local function collect_member_group_before_scope_enter(
    node,
    bufnr,
    group_index,
    members,
    seen,
    state,
    collector,
    adapter,
    node_type
)
    count_measurement(
        state,
        "group_dispatch_calls",
        1
    )

    if not core.is_table(group_index)
        or (group_index.spec_count or 0)
            == 0
    then
        return
    end

    if not member_group_can_match_node(
        group_index,
        node_type
    ) then
        return
    end

    count_measurement(
        state,
        "group_candidate_lookups",
        1
    )

    local candidates =
        member_group_candidates(
            group_index,
            node_type
        )

    if #candidates == 0 then
        return
    end

    local group_state =
        with_scope_depth_filter(
            state,
            true
        )

    count_measurement(
        group_state,
        "scope_filter_state_builds",
        1
    )

    for _, entry in ipairs(
        candidates
    ) do
        local member_spec =
            entry.spec

        count_measurement(
            group_state,
            "spec_checks",
            1
        )

        if not should_skip_member_spec_node(
            node,
            member_spec
        )
            and member_spec_constraints_match(
                node,
                member_spec
            )
            and should_collect_before_scope_enter(
                member_spec
            )
        then
            local member_state =
                with_member_owner_scope(
                    group_state,
                    member_spec
                )

            member_state =
                with_member_visibility(
                    member_state,
                    member_spec
                )

            member_state =
                with_member_annotation_scope(
                    member_state,
                    member_spec
                )

            collector(
                node,
                bufnr,
                member_spec,
                members,
                seen,
                member_state,
                adapter
            )
        end
    end
end


local member_group_collectors = {
    declarations =
        collect_declaration_member_spec,
    assignments =
        collect_declaration_member_spec,
    functions =
        collect_function_member_spec,
    loops =
        collect_loop_member_spec,
    returns =
        collect_return_member_spec,
    fields =
        collect_field_member_spec,
    symbols =
        collect_symbol_member_spec,
}


local function collect_from_node(
    node,
    bufnr,
    adapter,
    member_spec_index,
    members,
    seen,
    state,
    node_type
)
    if not node
        or not core.is_table(adapter)
        or not core.is_table(
            member_spec_index
        )
    then
        return
    end

    local eligible_group_names =
        member_group_names_for_node_type(
            member_spec_index,
            node_type
        )

    for _, group_name in ipairs(
        eligible_group_names
    ) do
        collect_member_group(
            node,
            bufnr,
            member_spec_index[
                group_name
            ],
            members,
            seen,
            state,
            member_group_collectors[
                group_name
            ],
            adapter,
            node_type
        )
    end
end


local function build_scope_binding_modifier_index(
    modifiers
)
    local result = {}

    for _, spec in ipairs(modifiers or {}) do
        local node_type =
            core.is_table(spec)
            and core.is_table(spec.syntax)
            and spec.syntax.node_type
            or nil

        if core.is_non_empty_string(
            node_type
        ) then
            result[node_type] =
                result[node_type]
                or {}

            table.insert(
                result[node_type],
                spec
            )
        end
    end

    return result
end


local function modifier_child_matches(
    child,
    descriptor
)
    if not child
        or not core.is_table(
            descriptor
        )
    then
        return false
    end

    local child_type =
        child:type()

    if descriptor.node_type
        == child_type
    then
        return true
    end

    for _, node_type in ipairs(
        descriptor.node_types
        or {}
    ) do
        if node_type == child_type then
            return true
        end
    end

    return false
end


local function collect_scope_binding_modifiers(
    node,
    bufnr,
    modifier_spec_index,
    modifiers,
    state,
    node_type
)
    local candidates =
        core.is_table(
            modifier_spec_index
        )
        and modifier_spec_index[
            node_type
        ]
        or nil

    if not core.is_table(candidates)
        or #candidates == 0
    then
        return
    end

    for _, spec in ipairs(candidates) do
        local names =
            spec.syntax
            and spec.syntax.children
            and spec.syntax.children.names
            or nil

        local target =
            spec.target or {}

        for child in node:iter_children() do
            if modifier_child_matches(
                child,
                names
            )
            then
                local name =
                    ts_utils.get_node_text(
                        child,
                        bufnr
                    )

                if core.is_non_empty_string(
                    name
                )
                then
                    table.insert(
                        modifiers,
                        {
                            name = name,
                            strategy =
                                target.strategy,
                            eligible_construct_kinds =
                                target
                                .eligible_construct_kinds,
                            lexical_path =
                                state.lexical_path
                                or {},
                            declaring_scope_depth =
                                state.scope_depth,
                            declaring_scope_range =
                                state.scope_range,
                            source_range =
                                ts_utils
                                .get_node_range(
                                    node
                                ),
                        }
                    )
                end
            end
        end
    end
end


local function scope_range_matches(
    member,
    frame
)
    local range =
        frame and frame.range

    return core.is_table(member)
        and core.is_table(frame)
        and core.is_table(range)
        and member.scope_depth
            == frame.depth
        and member.scope_start_line
            == range.start_line
        and member.scope_start_column
            == range.start_column
        and member.scope_end_line
            == range.end_line
        and member.scope_end_column
            == range.end_column
end


local function frame_kind_is_eligible(
    frame,
    eligible_construct_kinds
)
    if not core.is_table(
        eligible_construct_kinds
    )
        or #eligible_construct_kinds
            == 0
    then
        return true
    end

    for _, kind in ipairs(
        eligible_construct_kinds
    ) do
        if frame.construct_kind
            == kind
        then
            return true
        end
    end

    return false
end


local function frame_has_binding(
    members,
    name,
    frame
)
    for _, member in ipairs(
        members or {}
    ) do
        if member.name == name
            and not scope_member_model
                .is_annotation_owned(
                    member
                )
            and scope_range_matches(
                member,
                frame
            )
        then
            return true
        end
    end

    return false
end


local function resolve_modifier_target(
    members,
    modifier
)
    local path =
        modifier.lexical_path
        or {}

    if modifier.strategy
        == "outermost_lexical"
    then
        return path[1]
    end

    if modifier.strategy
        ~= "nearest_enclosing_binding"
    then
        return nil
    end

    for index = #path - 1, 1, -1 do
        local frame =
            path[index]

        if frame_kind_is_eligible(
            frame,
            modifier
                .eligible_construct_kinds
        )
            and frame_has_binding(
                members,
                modifier.name,
                frame
            )
        then
            return frame
        end
    end

    return nil
end


local function modifier_sort(
    left,
    right
)
    local left_depth =
        left.declaring_scope_depth
        or 0
    local right_depth =
        right.declaring_scope_depth
        or 0

    if left_depth ~= right_depth then
        return left_depth
            < right_depth
    end

    local left_line =
        left.source_range
        and left.source_range.start_line
        or 0
    local right_line =
        right.source_range
        and right.source_range.start_line
        or 0

    return left_line < right_line
end


local function resolve_scope_binding_modifiers(
    members,
    modifiers
)
    table.sort(
        modifiers,
        modifier_sort
    )

    for _, modifier in ipairs(
        modifiers or {}
    ) do
        local declaring_frame =
            modifier.lexical_path
            and modifier.lexical_path[
                #modifier.lexical_path
            ]
            or nil

        local target_frame =
            resolve_modifier_target(
                members,
                modifier
            )

        if declaring_frame
            and target_frame
        then
            for _, member in ipairs(
                members or {}
            ) do
                if member.name
                        == modifier.name
                    and scope_range_matches(
                        member,
                        declaring_frame
                    )
                then
                    scope_member_model
                        .set_owner_scope(
                            member,
                            target_frame.depth,
                            target_frame.range
                        )
                end
            end
        end
    end
end


local function persisted_frame_matches_member(
    frame,
    member
)
    return core.is_table(frame)
        and core.is_table(member)
        and member.scope_depth
            == frame.depth
        and member.scope_start_line
            == frame.start_line
        and member.scope_start_column
            == frame.start_column
        and member.scope_end_line
            == frame.end_line
        and member.scope_end_column
            == frame.end_column
end


local function member_can_participate_in_shadowing(
    member
)
    return core.is_table(member)
        and member.is_binding == true
        and member.owner_scope_redirected
            ~= true
        and not scope_member_model
            .is_annotation_owned(
                member
            )
        and core.is_non_empty_string(
            member.name
        )
end


local function find_member_owner_frame_index(
    member
)
    local path =
        core.is_table(member)
        and member.lexical_path
        or {}

    for index = #path, 1, -1 do
        if persisted_frame_matches_member(
            path[index],
            member
        )
        then
            return index
        end
    end

    return nil
end


local function shadow_candidate_for_frame(
    members,
    member,
    frame
)
    local candidate = nil

    for _, possible in ipairs(
        members or {}
    ) do
        if possible ~= member
            and member_can_participate_in_shadowing(
                possible
            )
            and possible.name
                == member.name
            and persisted_frame_matches_member(
                frame,
                possible
            )
            and (
                possible.line == nil
                or member.line == nil
                or possible.line
                    <= member.line
            )
            and (
                candidate == nil
                or (
                    possible.line
                        or math.huge
                )
                    < (
                        candidate.line
                        or math.huge
                    )
            )
        then
            candidate = possible
        end
    end

    return candidate
end


local function resolve_lexical_shadowing(
    members
)
    for _, member in ipairs(
        members or {}
    ) do
        member.shadows_member_id = nil

        if member_can_participate_in_shadowing(
            member
        )
        then
            local path =
                member.lexical_path
                or {}
            local owner_index =
                find_member_owner_frame_index(
                    member
                )

            if owner_index then
                for index =
                    owner_index - 1,
                    1,
                    -1
                do
                    local frame =
                        path[index]

                    if frame
                        and frame.binding_parent
                            ~= false
                    then
                        local candidate =
                            shadow_candidate_for_frame(
                                members,
                                member,
                                frame
                            )

                        if candidate then
                            member.shadows_member_id =
                                candidate.id
                            break
                        end
                    end
                end
            end
        end
    end
end


local function member_spec_opens_annotation_scope(
    node,
    member_spec
)
    if not node
        or not core.is_table(member_spec)
    then
        return false
    end

    local parameters_field =
        get_syntax_field(
            member_spec,
            "parameters"
        )

    if not core.is_non_empty_string(
        parameters_field
    ) then
        return false
    end

    local list_owner =
        ts_utils.get_child_by_field_name(
            node,
            parameters_field
        )

    if not list_owner then
        return false
    end

    local list_node_type =
        get_syntax_child_node_type(
            member_spec,
            "names"
        )

    if not core.is_non_empty_string(
        list_node_type
    ) then
        return false
    end

    return ts_utils.find_first_descendant_by_type(
        list_owner,
        list_node_type
    ) ~= nil
end


local function walk_node(
    node,
    bufnr,
    adapter,
    member_spec_index,
    modifier_spec_index,
    binding_modifiers,
    members,
    seen,
    state
)
    if not node then
        return
    end

    state = state or make_state()

    count_measurement(
        state,
        "nodes_visited",
        1
    )

    count_measurement(
        state,
        "node_type_requests",
        1
    )

    local node_type =
        node:type()

    local measurement =
        state.measurement

    if core.is_table(measurement)
        and core.is_non_empty_string(
            node_type
        )
    then
        local seen_node_types =
            measurement.seen_node_types

        if not core.is_table(
            seen_node_types
        ) then
            seen_node_types = {}
            measurement.seen_node_types =
                seen_node_types
        end

        if seen_node_types[
            node_type
        ] ~= true
        then
            seen_node_types[
                node_type
            ] = true

            count_measurement(
                state,
                "distinct_node_types",
                1
            )
        end
    end

    local current_state = state

    local function_group_index =
        member_spec_index.functions

    if core.is_table(function_group_index)
        and (function_group_index.spec_count or 0)
            > 0
        and member_group_can_match_node(
            function_group_index,
            node_type
        )
    then
        collect_member_group_before_scope_enter(
            node,
            bufnr,
            function_group_index,
            members,
            seen,
            state,
            collect_function_member_spec,
            adapter,
            node_type
        )
    end

    local construct_spec =
        construct_utils.get_construct_spec(
            node,
            adapter,
            node_type
        )

    count_measurement(
        state,
        "construct_scope_lookups",
        1
    )

    if core.is_table(
        construct_spec
    ) then
        count_measurement(
            state,
            "construct_spec_hits",
            1
        )
    end

    local construct_scope =
        core.is_table(construct_spec)
        and core.is_table(
            construct_spec.scope
        )
        and construct_spec.scope
        or nil

    if core.is_table(
        construct_scope
    ) then
        count_measurement(
            state,
            "construct_scope_hits",
            1
        )
    end

    local creates_lexical_scope =
        core.is_table(construct_scope)
        and construct_scope.kind
            == "lexical"
        and construct_scope
            .affects_visibility
            == true

    if creates_lexical_scope then
        local lexical_range =
            ts_utils.get_node_range(
                node
            )

        local construct =
            core.is_table(
                construct_spec.construct
            )
            and construct_spec.construct
            or {}

        local lexical_depth =
            state.scope_depth + 1

        local lexical_path =
            append_lexical_path(
                state.lexical_path,
                {
                    depth = lexical_depth,
                    node_type = node_type,
                    construct_kind =
                        construct.kind,
                    language_term =
                        construct.language_term,
                    label =
                        construct.label,
                    binding_parent =
                        construct_scope
                            .binding_parent
                        ~= false,
                    range =
                        lexical_range,
                }
            )

        current_state = make_state(
            state.opts,
            lexical_depth,
            lexical_range,
            state.structural_depth,
            state.structural_range,
            state.measurement,
            state.structural_path,
            lexical_path,
            state.annotation_depth,
            state.annotation_range,
            state.annotation_path
        )
    end

    local creates_structural_scope =
        core.is_table(construct_scope)
        and construct_scope.kind
            == "structural"
        and construct_scope
            .owns_members
            == true

    if creates_structural_scope then
        local structural_range =
            ts_utils.get_node_range(node)

        local construct =
            core.is_table(
                construct_spec.construct
            )
            and construct_spec.construct
            or {}

        local structural_depth =
            current_state.structural_depth
            + 1

        local structural_path =
            append_structural_path(
                current_state.structural_path,
                {
                    depth = structural_depth,
                    node_type = node_type,
                    construct_kind =
                        construct.kind,
                    language_term =
                        construct.language_term,
                    label = construct.label,

                    start_line =
                        structural_range
                        and structural_range.start_line,
                    start_column =
                        structural_range
                        and structural_range.start_column,
                    end_line =
                        structural_range
                        and structural_range.end_line,
                    end_column =
                        structural_range
                        and structural_range.end_column,
                }
            )

        current_state = make_state(
            current_state.opts,
            current_state.scope_depth,
            current_state.scope_range,
            structural_depth,
            structural_range,
            current_state.measurement,
            structural_path,
            current_state.lexical_path,
            current_state.annotation_depth,
            current_state.annotation_range,
            current_state.annotation_path
        )
    end

    local annotation_specs =
        member_spec_index
            .annotation_scope_specs_by_node_type[
                node_type
            ]
        or {}

    for _, annotation_spec in ipairs(
        annotation_specs
    ) do
        if member_spec_opens_annotation_scope(
            node,
            annotation_spec
        ) then
            local annotation_range =
                ts_utils.get_node_range(
                    node
                )
            local annotation_depth =
                current_state.annotation_depth
                + 1
            local annotation_path =
                append_annotation_path(
                    current_state
                        .annotation_path,
                    {
                        depth =
                            annotation_depth,
                        node_type =
                            node_type,
                        start_line =
                            annotation_range
                            and annotation_range
                                .start_line,
                        start_column =
                            annotation_range
                            and annotation_range
                                .start_column,
                        end_line =
                            annotation_range
                            and annotation_range
                                .end_line,
                        end_column =
                            annotation_range
                            and annotation_range
                                .end_column,
                    }
                )

            current_state =
                make_state(
                    current_state.opts,
                    current_state.scope_depth,
                    current_state.scope_range,
                    current_state.structural_depth,
                    current_state.structural_range,
                    current_state.measurement,
                    current_state.structural_path,
                    current_state.lexical_path,
                    annotation_depth,
                    annotation_range,
                    annotation_path
                )

            break
        end
    end

    collect_scope_binding_modifiers(
        node,
        bufnr,
        modifier_spec_index,
        binding_modifiers,
        current_state,
        node_type
    )

    local member_collection_state =
        current_state

    if core.is_table(
        construct_scope
    )
        and construct_scope.kind
            == "structural"
        and construct_scope
            .affects_visibility
            == true
        and construct_scope
            .owns_members
            ~= true
    then
        member_collection_state = {}

        for key, value in pairs(
            current_state or {}
        ) do
            member_collection_state[key] =
                value
        end

        member_collection_state
            .direct_structural_visibility_range =
            ts_utils.get_node_range(
                node
            )
    end

    collect_from_node(
        node,
        bufnr,
        adapter,
        member_spec_index,
        members,
        seen,
        member_collection_state,
        node_type
    )

    local child_state =
        current_state

    if core.is_table(
        construct_scope
    )
        and construct_scope.kind
            == "structural"
        and construct_scope
            .affects_visibility
            == true
        and construct_scope
            .owns_members
            ~= true
    then
        child_state = {}

        for key, value in pairs(
            current_state or {}
        ) do
            child_state[key] =
                value
        end

        child_state
            .inherited_structural_visibility_range =
            ts_utils.get_node_range(
                node
            )
    end

    for child in node:iter_children() do
        walk_node(
            child,
            bufnr,
            adapter,
            member_spec_index,
            modifier_spec_index,
            binding_modifiers,
            members,
            seen,
            child_state
        )
    end
end


local function collect_internal(
    bufnr,
    root_node,
    adapter,
    opts
)
    local members = {}
    local seen = {}
    local measurement = {
        nodes_visited = 0,
        spec_checks = 0,
        construct_scope_lookups = 0,
        construct_spec_hits = 0,
        construct_scope_hits = 0,
        distinct_node_types = 0,
        seen_node_types = {},
        node_type_requests = 0,
        group_dispatch_calls = 0,
        group_candidate_lookups = 0,
        scope_filter_state_builds = 0,
    }

    if not root_node or not core.is_table(adapter) then
        return members
    end

    if not core.is_table(adapter.scope_members) then
        return members
    end

    local member_spec_index =
        build_member_spec_index(
            adapter.scope_members
        )

    local modifier_spec_index =
        build_scope_binding_modifier_index(
            adapter
                .scope_binding_modifiers
        )

    local binding_modifiers = {}

    walk_node(
        root_node,
        bufnr,
        adapter,
        member_spec_index,
        modifier_spec_index,
        binding_modifiers,
        members,
        seen,
        make_state(
            opts,
            0,
            nil,
            nil,
            nil,
            measurement
        )
    )

    resolve_scope_binding_modifiers(
        members,
        binding_modifiers
    )

    resolve_lexical_shadowing(
        members
    )

    profile_counter(
        opts,
        "nodes_visited",
        measurement.nodes_visited
    )

    profile_counter(
        opts,
        "spec_checks",
        measurement.spec_checks
    )

    profile_counter(
        opts,
        "construct_scope_lookups",
        measurement.construct_scope_lookups
    )

    profile_counter(
        opts,
        "construct_spec_hits",
        measurement.construct_spec_hits
    )

    profile_counter(
        opts,
        "construct_scope_hits",
        measurement.construct_scope_hits
    )

    profile_counter(
        opts,
        "distinct_node_types",
        measurement.distinct_node_types
    )

    profile_counter(
        opts,
        "node_type_requests",
        measurement.node_type_requests
    )

    profile_counter(
        opts,
        "group_dispatch_calls",
        measurement.group_dispatch_calls
    )

    profile_counter(
        opts,
        "group_candidate_lookups",
        measurement.group_candidate_lookups
    )

    profile_counter(
        opts,
        "scope_filter_state_builds",
        measurement.scope_filter_state_builds
    )

    profile_counter(
        opts,
        "members_emitted",
        #members
    )

   table.sort(members, function(left, right)
        local left_line =
            scope_member_model.get_line(left)

        local right_line =
            scope_member_model.get_line(right)

        if left_line and right_line then
            if left_line ~= right_line then
                return left_line < right_line
            end

            local left_column =
                tonumber(left.source_start_column) or 0

            local right_column =
                tonumber(right.source_start_column) or 0

            if left_column ~= right_column then
                return left_column < right_column
            end
        end

        return (left.label or "")
            < (right.label or "")
    end)

    return members
end


function M.collect(
    bufnr,
    root_node,
    adapter,
    opts
)
    return collect_internal(
        bufnr,
        root_node,
        adapter,
        opts
    )
end


local function discovery_profile_options(
    opts
)
    if not core.is_table(opts) then
        return {}
    end

    return {
        profile_prefix =
            opts.profile_prefix,
        profile_counter =
            opts.profile_counter,
    }
end


function M.discover(
    bufnr,
    root_node,
    adapter,
    opts
)
    opts = opts or {}

    local reuse_unchanged_source =
        opts.reuse_unchanged_source
            == true

    local revision = nil

    if reuse_unchanged_source then
        revision =
            get_discovery_buffer_revision(
                bufnr
            )

        if persistent_discovery_matches(
            bufnr,
            adapter,
            revision
        ) then
            profile_counter(
                opts,
                "cross_refresh_reuse_possible",
                1
            )

            profile_counter(
                opts,
                "cross_refresh_reuse_applied",
                1
            )

            return persistent_discovery_cache
                .discovery
        end

        if core.is_table(revision) then
            profile_counter(
                opts,
                "cross_refresh_reuse_miss",
                1
            )
        end
    end

    local discovery = {
        members =
            collect_internal(
                bufnr,
                root_node,
                adapter,
                discovery_profile_options(
                    opts
                )
            ),
    }

    if reuse_unchanged_source then
        remember_persistent_discovery(
            bufnr,
            adapter,
            revision,
            discovery
        )
    end

    return discovery
end


local function member_matches_view(
    member,
    opts
)
    opts = opts or {}

    local line =
        scope_member_model.get_line(
            member
        )

    if opts.start_line
        and line
        and line < opts.start_line
    then
        return false
    end

    if opts.end_line
        and line
        and line > opts.end_line
    then
        return false
    end

    if opts.cursor_line
        and line
        and line > opts.cursor_line
    then
        return false
    end

    if opts.cursor_line
        and member.visibility_start_line
        and member.visibility_end_line
        and (
            opts.cursor_line
                < member.visibility_start_line
            or opts.cursor_line
                > member.visibility_end_line
        )
    then
        return false
    end

    if opts.scope_depth ~= nil
        and scope_member_model
            .scope_depth_filter_enabled(
                member
            )
        and member.scope_depth
            ~= opts.scope_depth
    then
        return false
    end

    return true
end


function M.select(
    discovery,
    opts
)
    local result = {}

    if not core.is_table(discovery)
        or not core.is_table(
            discovery.members
        )
    then
        return result
    end

    for _, member in ipairs(
        discovery.members
    ) do
        if member_matches_view(
            member,
            opts
        ) then
            table.insert(
                result,
                member
            )
        end
    end

    return result
end


return M
