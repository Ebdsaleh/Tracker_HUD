-- lua/tracker_hud/context.lua

local M = {}

local adapter_registry = require("tracker_hud.adapters.registry")
local context_engine = require("tracker_hud.context_engine")
local scope_members = require("tracker_hud.scope_members")
local registers = require("tracker_hud.sections.low_level.registers")
local events = require("tracker_hud.events")
local stack = require("tracker_hud.sections.low_level.stack")
local heap = require("tracker_hud.sections.low_level.heap")
local warnings = require("tracker_hud.warnings")
local section_layout = require("tracker_hud.section_layout")
local ts_utils = require("tracker_hud.treesitter_utils")
local target_diagnostics = require("tracker_hud.target_diagnostics")
local c_memory_facts = require("tracker_hud.adapters.c.memory_facts")
local source_node_snapshot = require("tracker_hud.source_node_snapshot")
local analysis_profile = require("tracker_hud.analysis_profile")


-- Range-scope discovery is source-derived and cursor-independent. Keep one
-- conservative persistent entry for the active HUD path, then select the
-- cursor-visible range freshly on every refresh.
local persistent_range_scope_cache = nil
local range_scope_module_token = tostring({})
local range_scope_buffer_token_serial = 0
local issued_range_scope_buffer_tokens = {}


local function range_scopes_are_stable(
    adapter
)
    return type(adapter) == "table"
        and type(
            adapter.validation_stable_components
        ) == "table"
        and adapter
            .validation_stable_components
            .range_scopes == true
        and type(adapter.range_scopes)
            == "table"
end


local function get_range_scope_buffer_revision(
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
        "tracker_hud_range_scope_cache_token"

    local ok_token, token =
        pcall(
            vim.api.nvim_buf_get_var,
            bufnr,
            variable_name
        )

    local expected_prefix =
        range_scope_module_token
        .. ":"

    if not ok_token
        or type(token) ~= "string"
        or token:sub(
            1,
            #expected_prefix
        ) ~= expected_prefix
        or issued_range_scope_buffer_tokens[
            token
        ] ~= true
    then
        range_scope_buffer_token_serial =
            range_scope_buffer_token_serial
            + 1

        token =
            expected_prefix
            .. tostring(
                range_scope_buffer_token_serial
            )

        issued_range_scope_buffer_tokens[
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


local function persistent_range_scope_matches(
    bufnr,
    adapter,
    revision
)
    local cached =
        persistent_range_scope_cache

    return type(cached) == "table"
        and type(revision) == "table"
        and cached.bufnr == bufnr
        and cached.buffer_token
            == revision.token
        and cached.changedtick
            == revision.changedtick
        and cached.adapter == adapter
        and cached.range_scopes
            == adapter.range_scopes
        and type(cached.entries)
            == "table"
end


local function remember_persistent_range_scopes(
    bufnr,
    adapter,
    revision,
    entries
)
    if not range_scopes_are_stable(
        adapter
    )
        or type(revision) ~= "table"
        or type(entries) ~= "table"
    then
        persistent_range_scope_cache =
            nil
        return
    end

    persistent_range_scope_cache = {
        bufnr = bufnr,
        buffer_token = revision.token,
        changedtick = revision.changedtick,
        adapter = adapter,
        range_scopes =
            adapter.range_scopes,
        entries = entries,
    }
end


local function profile_begin(
    profile_token,
    name
)
    if not profile_token then
        return nil
    end

    return analysis_profile.begin_phase(
        profile_token,
        name
    )
end


local function profile_end(
    profile_token,
    name,
    started
)
    if not profile_token then
        return nil
    end

    return analysis_profile.end_phase(
        profile_token,
        name,
        started
    )
end


local function nested_profile_options(
    profile_token,
    prefix
)
    if not profile_token then
        return {}
    end

    return {
        profile_prefix = prefix,
        profile_begin =
            function(name)
                return profile_begin(
                    profile_token,
                    name
                )
            end,
        profile_end =
            function(name, started)
                return profile_end(
                    profile_token,
                    name,
                    started
                )
            end,
        profile_counter =
            function(name, delta)
                return analysis_profile
                    .add_counter(
                        profile_token,
                        name,
                        delta
                    )
            end,
    }
end


local function try_parse_construct_with_adapter(bufnr, node)
    if not node then
        return nil
    end

    local filetype = vim.bo[bufnr].filetype

    if not filetype or filetype == "" then
        return nil
    end

    if not adapter_registry.has_adapter(filetype) then
        return nil
    end

    local construct, _err = adapter_registry.parse_node(filetype, node, bufnr)
    return construct
end


local function find_nearest_member_scope(scopes)
    for _, scope_entry in ipairs(scopes or {}) do
        local scope = scope_entry.scope

        if type(scope) == "table"
            and (
                scope.affects_visibility == true
                or scope.owns_members == true
            )
        then
            return scope_entry
        end
    end

    return nil
end


local function build_member_scope_context(scope_entry)
    if type(scope_entry) ~= "table" then
        return nil
    end

    return {
        label = scope_entry.label,
        raw_label = scope_entry.raw_label,
        node_type = scope_entry.node_type,
        kind = scope_entry.kind,
        start_line = scope_entry.start_line,
        end_line = scope_entry.end_line,
    }
end


local function get_first_descendant_text_by_type(node, bufnr, node_type)
    if not node or type(node_type) ~= "string" or node_type == "" then
        return nil
    end

    local found = ts_utils.find_first_descendant_by_type(node, node_type)

    if not found then
        return nil
    end

    return ts_utils.get_node_text(found, bufnr)
end


local function get_syntax(spec)
    if type(spec) ~= "table"
        or type(spec.syntax) ~= "table"
    then
        return {}
    end

    return spec.syntax
end


local function get_syntax_node_type(spec)
    local syntax = get_syntax(spec)

    if type(syntax.node_type) == "string"
        and syntax.node_type ~= ""
    then
        return syntax.node_type
    end

    -- Temporary compatibility for pre-syntax range-scope specs.
    if type(spec) == "table"
        and type(spec.node_type) == "string"
        and spec.node_type ~= ""
    then
        return spec.node_type
    end

    return nil
end


local function get_syntax_field(spec, key)
    local syntax = get_syntax(spec)
    local fields = syntax.fields

    if type(fields) ~= "table" then
        return nil
    end

    local field_name = fields[key]

    if type(field_name) == "string"
        and field_name ~= ""
    then
        return field_name
    end

    if type(field_name) == "table"
        and type(field_name.field) == "string"
        and field_name.field ~= ""
    then
        return field_name.field
    end

    return nil
end


local function get_syntax_child_node_types(spec, key)
    local syntax = get_syntax(spec)
    local children = syntax.children

    if type(children) ~= "table" then
        return {}
    end

    local child = children[key]

    if type(child) ~= "table" then
        return {}
    end

    local result = {}

    if type(child.node_type) == "string"
        and child.node_type ~= ""
    then
        table.insert(result, child.node_type)
    end

    for _, node_type in ipairs(
        child.node_types or {}
    ) do
        if type(node_type) == "string"
            and node_type ~= ""
        then
            table.insert(result, node_type)
        end
    end

    return result
end


local function get_range_scope_name(
    node,
    bufnr,
    range_scope_spec
)
    local name_field =
        get_syntax_field(
            range_scope_spec,
            "name"
        )

    if name_field then
        local name_node =
            ts_utils.get_child_by_field_name(
                node,
                name_field
            )

        if name_node then
            return ts_utils.get_node_text(
                name_node,
                bufnr
            )
        end
    end

    for _, node_type in ipairs(
        get_syntax_child_node_types(
            range_scope_spec,
            "name"
        )
    ) do
        local name =
            get_first_descendant_text_by_type(
                node,
                bufnr,
                node_type
            )

        if type(name) == "string"
            and name ~= ""
        then
            return name
        end
    end

    -- Temporary compatibility for pre-syntax range-scope specs.
    if type(range_scope_spec.name_node_type)
        == "string"
    then
        return get_first_descendant_text_by_type(
            node,
            bufnr,
            range_scope_spec.name_node_type
        )
    end

    return nil
end


local function collect_nodes_by_type(
    node,
    node_type,
    result,
    measurement
)
    result = result or {}

    if not node
        or type(node_type) ~= "string"
        or node_type == ""
    then
        return result
    end

    if type(measurement) == "table" then
        measurement.nodes_visited =
            (measurement.nodes_visited or 0)
            + 1
    end

    if node:type() == node_type then
        table.insert(result, node)

        if type(measurement) == "table" then
            measurement.nodes_matched =
                (measurement.nodes_matched or 0)
                + 1
        end
    end

    for child in node:iter_children() do
        collect_nodes_by_type(
            child,
            node_type,
            result,
            measurement
        )
    end

    return result
end


local function make_range_scope_entry(bufnr, node, range_scope_spec, start_line, end_line)
    if not node or type(range_scope_spec) ~= "table" then
        return nil
    end

    local name = get_range_scope_name(
        node,
        bufnr,
        range_scope_spec
    )

    local label = range_scope_spec.label or "Scope"
    local raw_label = label

    if type(name) == "string" and name ~= "" then
        raw_label = label .. " " .. name
    end

    local display_label = "[" .. tostring(start_line) .. "] " .. raw_label

    return {
        label = display_label,
        raw_label = raw_label,
        node_type = node:type(),
        kind = range_scope_spec.kind or "range_scope",
        scope = range_scope_spec.scope,
        value = range_scope_spec.value,
        start_line = start_line,
        end_line = end_line,
        construct = {
            node_type = node:type(),
            name = name,
            range = {
                start_line = start_line,
                end_line = end_line,
            },
            metadata = {
                display_label = display_label,
                range_strategy = range_scope_spec.range_strategy,
            },
        },
    }
end


local function scope_entry_exists(scopes, candidate)
    if type(candidate) ~= "table" then
        return false
    end

    for _, scope_entry in ipairs(scopes or {}) do
        if type(scope_entry) == "table"
            and scope_entry.node_type == candidate.node_type
            and scope_entry.start_line == candidate.start_line
            and scope_entry.end_line == candidate.end_line
        then
            return true
        end
    end

    return false
end


local function discover_range_scope_entries(
    bufnr,
    root_node,
    adapter,
    profile_token,
    shared_source_nodes
)
    local entries = {}
    local measurement = {
        scans = 0,
        nodes_visited = 0,
        nodes_matched = 0,
        shared_snapshot_hits = 0,
    }

    if not root_node
        or type(adapter) ~= "table"
        or type(adapter.range_scopes)
            ~= "table"
    then
        return entries
    end

    local revision = nil
    local reuse_unchanged_source =
        range_scopes_are_stable(
            adapter
        )

    if reuse_unchanged_source then
        revision =
            get_range_scope_buffer_revision(
                bufnr
            )

        if persistent_range_scope_matches(
            bufnr,
            adapter,
            revision
        ) then
            if profile_token then
                analysis_profile.add_counter(
                    profile_token,
                    "context.scopes.range_scope_cross_refresh_reuse_possible",
                    1
                )

                analysis_profile.add_counter(
                    profile_token,
                    "context.scopes.range_scope_cross_refresh_reuse_applied",
                    1
                )
            end

            return persistent_range_scope_cache
                .entries
        end

        if profile_token
            and type(revision) == "table"
        then
            analysis_profile.add_counter(
                profile_token,
                "context.scopes.range_scope_cross_refresh_reuse_miss",
                1
            )
        end
    end

    local file_end_line =
        vim.api.nvim_buf_line_count(
            bufnr
        )

    for _, range_scope_spec in ipairs(
        adapter.range_scopes
    ) do
        local node_type =
            get_syntax_node_type(
                range_scope_spec
            )

        if type(range_scope_spec)
                == "table"
            and range_scope_spec
                .range_strategy
                == "until_next_peer"
            and type(node_type)
                == "string"
        then
            measurement.scans =
                measurement.scans + 1

            local nodes =
                source_node_snapshot
                    .nodes_by_type(
                        shared_source_nodes,
                        node_type
                    )

            if type(nodes) == "table" then
                measurement.shared_snapshot_hits =
                    1
                measurement.nodes_matched =
                    measurement.nodes_matched
                    + #nodes
            else
                nodes =
                    collect_nodes_by_type(
                        root_node,
                        node_type,
                        nil,
                        measurement
                    )
            end

            for index, node in ipairs(
                nodes
            ) do
                local start_line =
                    node:start() + 1
                local end_line =
                    file_end_line

                local next_node =
                    nodes[index + 1]

                if next_node then
                    end_line =
                        next_node:start()
                end

                local entry =
                    make_range_scope_entry(
                        bufnr,
                        node,
                        range_scope_spec,
                        start_line,
                        end_line
                    )

                if entry then
                    table.insert(
                        entries,
                        entry
                    )
                end
            end
        end
    end

    if profile_token
        and measurement.scans > 0
    then
        analysis_profile.add_counter(
            profile_token,
            "context.scopes.range_scope_scans",
            measurement.scans
        )

        if measurement.nodes_visited > 0 then
            analysis_profile.add_counter(
                profile_token,
                "context.scopes.range_scope_nodes_visited",
                measurement.nodes_visited
            )
        end

        if measurement.shared_snapshot_hits > 0 then
            analysis_profile.add_counter(
                profile_token,
                "context.scopes.range_scope_shared_snapshot_hits",
                measurement.shared_snapshot_hits
            )
        end

        analysis_profile.add_counter(
            profile_token,
            "context.scopes.range_scope_nodes_matched",
            measurement.nodes_matched
        )
    end

    if reuse_unchanged_source then
        remember_persistent_range_scopes(
            bufnr,
            adapter,
            revision,
            entries
        )
    end

    return entries
end


local function select_range_scope_entries(
    entries,
    cursor_line
)
    local result = {}

    if type(cursor_line) ~= "number" then
        return result
    end

    for _, entry in ipairs(
        entries or {}
    ) do
        if type(entry) == "table"
            and type(entry.start_line)
                == "number"
            and type(entry.end_line)
                == "number"
            and cursor_line
                >= entry.start_line
            and cursor_line
                <= entry.end_line
        then
            table.insert(
                result,
                entry
            )
        end
    end

    return result
end


local function collect_range_scope_entries(
    bufnr,
    root_node,
    adapter,
    cursor_line,
    profile_token,
    shared_source_nodes
)
    return select_range_scope_entries(
        discover_range_scope_entries(
            bufnr,
            root_node,
            adapter,
            profile_token,
            shared_source_nodes
        ),
        cursor_line
    )
end

local function append_missing_range_scopes(scopes, range_scopes)
    for _, range_scope in ipairs(range_scopes or {}) do
        if not scope_entry_exists(scopes, range_scope) then
            -- scopes are stored innermost -> outermost.
            -- A label range is usually outside the current instruction node.
            table.insert(scopes, range_scope)
        end
    end
end


local function attach_context_sections(
    context,
    bufnr,
    root_node,
    adapter,
    scope_member_opts,
    config,
    profile_token,
    shared_source_nodes
)
    local phase =
        profile_begin(
            profile_token,
            "context.setup"
        )

    context.targets =
        vim.deepcopy(
            adapter.active_targets
                or {}
        )

    context.section_layout =
        section_layout.resolve(adapter)
    context.section_order =
        context.section_layout.order
    context.section_count =
        context.section_layout.count

    target_diagnostics.show(
        bufnr,
        context.targets
    )

    profile_end(
        profile_token,
        "context.setup",
        phase
    )

    -- Shared immutable register-effect source indexing for this refresh.
    -- Consumers still own independent mutable reduction/replay state.
    local register_source_cache = {}

    phase =
        profile_begin(
            profile_token,
            "context.scope_members"
        )

    -- Discover the immutable member set once per refresh. Current-scope and
    -- all-members sections are views over the same source traversal.
    local scope_discovery_opts =
        nested_profile_options(
            profile_token,
            "context.scope_members"
        )

    scope_discovery_opts
        .reuse_unchanged_source = true

    local scope_member_discovery =
        scope_members.discover(
            bufnr,
            root_node,
            adapter,
            scope_discovery_opts
        )

    context.scope_members =
        scope_members.select(
            scope_member_discovery,
            scope_member_opts
        )

    profile_end(
        profile_token,
        "context.scope_members",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.scope_members_all"
        )

    context.all_scope_members =
        scope_members.select(
            scope_member_discovery,
            {}
        )

    profile_end(
        profile_token,
        "context.scope_members_all",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.registers"
        )

    local paired_before_dynamic = nil
    local register_timeline = nil

    if context.cursor
        and type(context.cursor.line)
            == "number"
    then
        context.registers,
            paired_before_dynamic,
            register_timeline =
            registers
                .collect_with_before_snapshot(
                    context,
                    adapter,
                    vim.tbl_extend(
                        "force",
                        {
                            bufnr = bufnr,
                            root_node = root_node,
                            config = config,
                            register_source_cache =
                                register_source_cache,
                            source_node_snapshot =
                                shared_source_nodes,
                        },
                        nested_profile_options(
                            profile_token,
                            "context.registers"
                        )
                    ),
                    {
                        line =
                            context.cursor.line,
                        column = 0,
                    }
                )
    end

    -- If paired replay cannot be constructed, preserve the existing independent
    -- collection path rather than weakening source-time register semantics.
    if context.registers == nil then
        context.registers =
            registers.collect(
                context,
                adapter,
                vim.tbl_extend(
                    "force",
                    {
                        bufnr = bufnr,
                        root_node = root_node,
                        config = config,
                        register_source_cache =
                            register_source_cache,
                        source_node_snapshot =
                            shared_source_nodes,
                    },
                    nested_profile_options(
                        profile_token,
                        "context.registers"
                    )
                )
            )
    end

    profile_end(
        profile_token,
        "context.registers",
        phase
    )

    -- Keep an explicit reduced snapshot from BEFORE the current source line.
    -- The paired path snapshots this state before advancing the same reducer to
    -- the normal cursor-visible state. If paired replay is unavailable, fall
    -- back to the original independent reduction.
    context.registers_before_current_line = {}

    phase =
        profile_begin(
            profile_token,
            "context.registers_before"
        )

    if context.cursor
        and type(context.cursor.line)
            == "number"
    then
        local before_opts =
            vim.tbl_extend(
                "force",
                {
                    bufnr = bufnr,
                    root_node = root_node,
                    config = config,
                    register_source_cache =
                        register_source_cache,
                    source_node_snapshot =
                        shared_source_nodes,
                    limit_position = {
                        line =
                            context.cursor.line,
                        column = 0,
                    },
                },
                nested_profile_options(
                    profile_token,
                    "context.registers_before"
                )
            )

        if paired_before_dynamic ~= nil then
            before_opts.dynamic_registers =
                paired_before_dynamic
        end

        context.registers_before_current_line =
            registers.collect(
                context,
                adapter,
                before_opts
            )
    end

    profile_end(
        profile_token,
        "context.registers_before",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.stack"
        )

    context.stack =
        stack.collect(
            context,
            adapter,
            vim.tbl_extend(
                "force",
                {
                    bufnr = bufnr,
                    root_node = root_node,
                    register_source_cache =
                        register_source_cache,
                    register_timeline =
                        register_timeline,
                },
                nested_profile_options(
                    profile_token,
                    "context.stack"
                )
            )
        )

    profile_end(
        profile_token,
        "context.stack",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.boundary"
        )

    context.boundary_effects =
        context_engine
            .collect_boundary_effects(
                context,
                adapter,
                vim.tbl_extend(
                    "force",
                    {
                        bufnr = bufnr,
                        root_node = root_node,
                        register_source_cache =
                            register_source_cache,
                        register_timeline =
                            register_timeline,
                    },
                    nested_profile_options(
                        profile_token,
                        "context.boundary"
                    )
                )
            )

    profile_end(
        profile_token,
        "context.boundary",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.instruction_events"
        )

    context.instruction_events =
        context_engine
            .collect_instruction_events(
                context,
                adapter,
                vim.tbl_extend(
                    "force",
                    {
                        bufnr = bufnr,
                        root_node = root_node,
                        register_source_cache =
                            register_source_cache,
                    },
                    nested_profile_options(
                        profile_token,
                        "context.instruction_events"
                    )
                )
            )

    profile_end(
        profile_token,
        "context.instruction_events",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.source_memory"
        )

    -- ASM source memory operands are syntax-derived address structures.
    -- Keep them separate from Heap/Events: seeing [base + index*scale + disp]
    -- proves source structure, not that an access executed or an address exists.
    if adapter.name == "asm" then
        context.source_memory_operands =
            context_engine
                .collect_memory_source_operands(
                    bufnr,
                    root_node,
                    adapter,
                    context.cursor
                        and context.cursor.line,
                    vim.tbl_extend(
                        "force",
                        {
                            machine_address_providers =
                                config
                                    .machine_address_providers,
                            register_source_cache =
                                register_source_cache,
                            register_timeline =
                                register_timeline,
                            source_members =
                                context
                                    .all_scope_members,
                        },
                        nested_profile_options(
                            profile_token,
                            "context.source_memory"
                        )
                    )
                )
    end

    -- C/C++ source-observed memory operations. Only events that begin ON
    -- or BEFORE the cursor are visited. This records allocation/release
    -- expression sites, not successful allocations or ownership proofs.
    if adapter.name == "c"
        or adapter.name == "cpp"
    then
        context.source_memory_facts =
            c_memory_facts.collect(
                bufnr,
                root_node,
                adapter.name,
                context.cursor
                    and context.cursor.line
            )
    end

    profile_end(
        profile_token,
        "context.source_memory",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.events"
        )

    context.events =
        events.collect(context)

    profile_end(
        profile_token,
        "context.events",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.heap"
        )

    -- Heap is intentionally a shell for now.
    -- Later, boundary effects such as mmap/brk/munmap/malloc/free/new/delete
    -- can populate this section.
    context.heap =
        heap.collect(
            context,
            adapter,
            {
                bufnr = bufnr,
                root_node = root_node,
            }
        )

    profile_end(
        profile_token,
        "context.heap",
        phase
    )

    phase =
        profile_begin(
            profile_token,
            "context.warnings"
        )

    -- warnings are derived after boundary/heap facts exist.
    context.warnings =
        warnings.collect(
            context,
            adapter,
            vim.tbl_extend(
                "force",
                {
                    bufnr = bufnr,
                    root_node = root_node,
                    filetype =
                        vim.bo[bufnr].filetype,
                    source_node_snapshot =
                        shared_source_nodes,
                },
                nested_profile_options(
                    profile_token,
                    "context.warnings"
                )
            )
        )

    profile_end(
        profile_token,
        "context.warnings",
        phase
    )

    return context
end

function M.get_cursor_context(
    bufnr,
    config,
    opts
)
    config = config or {}
    opts = opts or {}

    local profile_token =
        opts.profile_token

    local filetype = vim.bo[bufnr].filetype

    local parser_phase =
        profile_begin(
            profile_token,
            "context.parser"
        )

    local ok, parser =
        pcall(
            vim.treesitter.get_parser,
            bufnr
        )

    if not ok or not parser then
        profile_end(
            profile_token,
            "context.parser",
            parser_phase
        )

        return context_engine.make_unavailable_context(
            "No Tree-sitter parser available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    if not adapter_registry.has_adapter(filetype) then
        profile_end(
            profile_token,
            "context.parser",
            parser_phase
        )

        return context_engine.make_unavailable_context(
            "No Tracker HUD adapter available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    local tree = parser:parse()[1]
    local root_node = nil

    if tree then
        root_node = tree:root()
    end

    profile_end(
        profile_token,
        "context.parser",
        parser_phase
    )

    local configure_profile_opts = nil

    if profile_token then
        configure_profile_opts = {
            profile_begin =
                function(name)
                    return profile_begin(
                        profile_token,
                        name
                    )
                end,
            profile_end =
                function(name, started)
                    return profile_end(
                        profile_token,
                        name,
                        started
                    )
                end,
            profile_counter =
                function(name, delta)
                    return analysis_profile.add_counter(
                        profile_token,
                        name,
                        delta
                    )
                end,
        }
    end

    local configure_phase =
        profile_begin(
            profile_token,
            "context.configure"
        )

    local configured, configure_err =
        adapter_registry
            .configure_adapter_for_buffer(
                filetype,
                bufnr,
                config,
                configure_profile_opts
            )

    profile_end(
        profile_token,
        "context.configure",
        configure_phase
    )

    if not configured then
        return context_engine.make_unavailable_context(
            "Tracker HUD adapter configuration failed for filetype: "
                .. tostring(filetype)
                .. " - "
                .. tostring(configure_err),
            filetype
        )
    end

    local adapter = adapter_registry.get_adapter(filetype)
    local cursor = context_engine.get_cursor_location()
    local node = vim.treesitter.get_node()

    local shared_source_nodes =
        source_node_snapshot.new(
            root_node,
            nested_profile_options(
                profile_token,
                "context.source_nodes"
            )
        )

    local scopes_phase =
        profile_begin(
            profile_token,
            "context.scopes"
        )

    if not node then
        local context = context_engine.make_global_context()
        local range_scopes = collect_range_scope_entries(
            bufnr,
            root_node,
            adapter,
            cursor.line,
            profile_token,
            shared_source_nodes
        )

        append_missing_range_scopes(context.scopes, range_scopes)

        if #context.scopes > 0 then
            context = context_engine.build_context_from_scopes(context.scopes, config)
        end

        local nearest_member_scope = find_nearest_member_scope(context.scopes)
        local scope_member_opts = {
            cursor_line = context.cursor and context.cursor.line,
        }

        if nearest_member_scope then
            scope_member_opts.start_line = nearest_member_scope.start_line
            scope_member_opts.end_line = nearest_member_scope.end_line
            context.member_scope = build_member_scope_context(nearest_member_scope)
        else
            scope_member_opts.scope_depth = 0
            context.member_scope = nil
        end

        profile_end(
            profile_token,
            "context.scopes",
            scopes_phase
        )

        return attach_context_sections(
            context,
            bufnr,
            root_node,
            adapter,
            scope_member_opts,
            config,
            profile_token,
            shared_source_nodes
        )
    end

    local scopes = {}

    while node do
        local construct = try_parse_construct_with_adapter(bufnr, node)

        if construct then
            local scope_entry = context_engine.build_scope_entry_from_construct(construct)

            if scope_entry then
                table.insert(scopes, scope_entry)
            end
        end

        node = node:parent()
    end

    local range_scopes = collect_range_scope_entries(
        bufnr,
        root_node,
        adapter,
        cursor.line,
        profile_token,
        shared_source_nodes
    )

    append_missing_range_scopes(scopes, range_scopes)

    local context = context_engine.build_context_from_scopes(scopes, config)

    local scope_member_opts = {
        cursor_line = context.cursor and context.cursor.line,
    }

    local nearest_member_scope = find_nearest_member_scope(context.scopes)

    if nearest_member_scope then
        scope_member_opts.start_line = nearest_member_scope.start_line
        scope_member_opts.end_line = nearest_member_scope.end_line
        context.member_scope = build_member_scope_context(nearest_member_scope)
    else
        scope_member_opts.scope_depth = 0
        context.member_scope = nil
    end

    profile_end(
        profile_token,
        "context.scopes",
        scopes_phase
    )

    return attach_context_sections(
        context,
        bufnr,
        root_node,
        adapter,
        scope_member_opts,
        config,
        profile_token,
        shared_source_nodes
    )
end

return M
