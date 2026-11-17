-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local memory_address_evaluator = require("tracker_hud.low_level.memory_address_evaluator")
local memory_source_discovery = require("tracker_hud.low_level.memory_source_discovery")
local register_source_discovery = require("tracker_hud.low_level.register_source_discovery")
local register_effect_pipeline = require("tracker_hud.low_level.register_effect_pipeline")
local line_summary = require("tracker_hud.low_level.line_summary")
local boundary_effect_pipeline = require("tracker_hud.low_level.boundary_effect_pipeline")
local instruction_event_pipeline = require("tracker_hud.low_level.instruction_event_pipeline")
local stack_effect_pipeline = require("tracker_hud.low_level.stack_effect_pipeline")
local instruction_source = require("tracker_hud.low_level.instruction_source")
local instruction_parser_dispatch = require("tracker_hud.low_level.instruction_parser_dispatch")
local context_primitives = require("tracker_hud.constructs.context_primitives")
local branch_presentation = require("tracker_hud.constructs.branch_presentation")
local construct_spec_validation = require("tracker_hud.constructs.spec_validation")
local construct_source_identity = require("tracker_hud.constructs.source_identity")
local construct_parser = require("tracker_hud.constructs.parser")

local M = {}



local get_register_effect_index =
    register_effect_pipeline.get_index


local parse_instruction_with_adapter =
    instruction_parser_dispatch.parse


M.make_global_context =
    context_primitives.make_global_context

M.make_unavailable_context =
    context_primitives.make_unavailable_context


M.get_first_line_text =
    construct_source_identity.get_first_line_text

M.build_signature =
    construct_source_identity.build_signature

M.extract_name_from_signature =
    construct_source_identity.extract_name_from_signature

M.extract_name_from_syntax =
    construct_source_identity.extract_name_from_syntax

M.build_construct =
    construct_source_identity.build_construct


M.get_cursor_position =
    context_primitives.get_cursor_position

M.get_cursor_location =
    context_primitives.get_cursor_location


function M.resolve_line_summary_options(config)
    return line_summary.resolve_options(config)
end


function M.classify_instruction_cursor_position(
    instruction_start_column,
    instruction_end_column,
    source_column
)
    return line_summary.classify_instruction_position(
        instruction_start_column,
        instruction_end_column,
        source_column
    )
end


function M.line_summary_allows_position(
    config,
    position
)
    return line_summary.allows_position(
        config,
        position
    )
end


function M.get_compiled_line_instruction_range(
    compiled_line
)
    return line_summary.get_compiled_line_instruction_range(
        compiled_line
    )
end


function M.classify_compiled_line_cursor_position(
    compiled_line,
    source_column
)
    return line_summary.classify_compiled_line_position(
        compiled_line,
        source_column
    )
end


function M.line_summary_allows_compiled_line_position(
    config,
    compiled_line,
    source_column
)
    return line_summary.allows_compiled_line_position(
        config,
        compiled_line,
        source_column
    )
end


M.format_branch_display_label =
    branch_presentation.format_display_label

M.node_matches_branch_alternative =
    branch_presentation.node_matches_alternative

M.get_node_alternatives =
    branch_presentation.get_node_alternatives

M.get_branch_alternative_label =
    branch_presentation.get_alternative_label

M.build_branch_display_label =
    branch_presentation.build_display_label


M.position_in_node =
    context_primitives.position_in_node

M.get_node_type =
    context_primitives.get_node_type

M.get_first_node_line =
    context_primitives.get_first_node_line

M.build_scope_entry_from_construct =
    context_primitives.build_scope_entry_from_construct

M.build_context_from_scopes =
    context_primitives.build_context_from_scopes

M.get_node_range =
    context_primitives.get_node_range


M.match_node =
    construct_parser.match_node

M.parse_node =
    construct_parser.parse_node


M.get_construct_spec =
    construct_spec_validation.get

M.validate_construct_spec =
    construct_spec_validation.validate


local function instruction_source_options()
    return {
        parse_with_adapter =
            parse_instruction_with_adapter,
        get_node_text =
            ts_utils.get_node_text,
    }
end


local function collect_instruction_operands(
    adapter,
    node,
    bufnr,
    effect_spec
)
    return instruction_source.collect_instruction(
        adapter,
        node,
        bufnr,
        effect_spec,
        instruction_source_options()
    )
end


local register_instruction_parse_nil = {}
local register_instruction_parse_no_spec = {}


local function get_register_instruction_parse_cache(
    register_source_cache
)
    if not core.is_table(
        register_source_cache
    ) then
        return nil
    end

    if not core.is_table(
        register_source_cache
            .instruction_parse_cache
    )
    then
        register_source_cache
            .instruction_parse_cache = {}
    end

    return register_source_cache
        .instruction_parse_cache
end


local function collect_instruction_operands_cached(
    adapter,
    node,
    bufnr,
    effect_spec,
    register_source_cache
)
    local parse_cache =
        get_register_instruction_parse_cache(
            register_source_cache
        )

    if not parse_cache
        or node == nil
    then
        return collect_instruction_operands(
            adapter,
            node,
            bufnr,
            effect_spec
        )
    end

    local by_spec =
        parse_cache[node]

    if not core.is_table(by_spec) then
        by_spec = {}
        parse_cache[node] =
            by_spec
    end

    local spec_key =
        effect_spec
        or register_instruction_parse_no_spec

    local cached =
        by_spec[spec_key]

    if cached ~= nil then
        return cached
            ~= register_instruction_parse_nil
            and cached
            or nil
    end

    local parsed =
        collect_instruction_operands(
            adapter,
            node,
            bufnr,
            effect_spec
        )

    by_spec[spec_key] =
        parsed
        or register_instruction_parse_nil

    return parsed
end


-- Register-effect reduction is owned by register_effect_pipeline.


local persistent_register_source_cache = nil
local register_source_buffer_token_serial = 0
local register_source_module_token =
    tostring({})
local issued_register_source_buffer_tokens = {}


local function register_effects_are_stable(
    adapter
)
    return core.is_table(adapter)
        and core.is_table(
            adapter.validation_stable_components
        )
        and adapter
            .validation_stable_components
            .register_effects == true
        and core.is_table(
            adapter.register_effects
        )
end


local function get_register_source_buffer_revision(
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
        "tracker_hud_register_source_cache_token"

    local ok_token, token =
        pcall(
            vim.api.nvim_buf_get_var,
            bufnr,
            variable_name
        )

    local expected_prefix =
        register_source_module_token
        .. ":"

    if not ok_token
        or type(token) ~= "string"
        or token:sub(
            1,
            #expected_prefix
        ) ~= expected_prefix
        or issued_register_source_buffer_tokens[
            token
        ] ~= true
    then
        register_source_buffer_token_serial =
            register_source_buffer_token_serial
            + 1

        token =
            expected_prefix
            .. tostring(
                register_source_buffer_token_serial
            )

        issued_register_source_buffer_tokens[
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


local function copy_prepared_source_for_root(
    prepared_source,
    root_node
)
    if not core.is_table(prepared_source) then
        return nil
    end

    local rebound = {}

    for key, value in pairs(
        prepared_source
    ) do
        rebound[key] = value
    end

    rebound.source_root_node =
        prepared_source.source_root_node
        or prepared_source.root_node
    rebound.root_node = root_node

    return rebound
end


local function persistent_register_source_matches(
    adapter,
    bufnr,
    revision
)
    local cached =
        persistent_register_source_cache

    return core.is_table(cached)
        and core.is_table(revision)
        and cached.bufnr == bufnr
        and cached.buffer_token
            == revision.token
        and cached.changedtick
            == revision.changedtick
        and cached.adapter == adapter
        and cached.register_effects
            == adapter.register_effects
        and core.is_table(
            cached.prepared_source
        )
end


local function remember_persistent_register_source(
    adapter,
    bufnr,
    revision,
    prepared_source
)
    if not register_effects_are_stable(
        adapter
    )
        or not core.is_table(revision)
        or not core.is_table(
            prepared_source
        )
    then
        persistent_register_source_cache =
            nil
        return
    end

    persistent_register_source_cache = {
        bufnr = bufnr,
        buffer_token = revision.token,
        changedtick = revision.changedtick,
        adapter = adapter,
        register_effects =
            adapter.register_effects,
        prepared_source =
            prepared_source,
    }
end


local function persistent_register_timeline(
    adapter,
    bufnr
)
    local revision =
        get_register_source_buffer_revision(
            bufnr
        )

    if not persistent_register_source_matches(
        adapter,
        bufnr,
        revision
    ) then
        return nil
    end

    local timeline =
        persistent_register_source_cache
            .timeline

    if core.is_table(timeline)
        and type(
            timeline.snapshot_before
        ) == "function"
        and type(
            timeline.snapshot_visible
        ) == "function"
        and type(
            timeline.stats
        ) == "function"
    then
        return timeline
    end

    return nil
end


local function remember_persistent_register_timeline(
    adapter,
    bufnr,
    timeline
)
    if not core.is_table(timeline)
        or type(timeline.stats)
            ~= "function"
    then
        return
    end

    local revision =
        get_register_source_buffer_revision(
            bufnr
        )

    if not persistent_register_source_matches(
        adapter,
        bufnr,
        revision
    ) then
        return
    end

    local incoming_stats =
        timeline:stats()

    if not core.is_table(
        incoming_stats
    ) then
        return
    end

    local existing =
        persistent_register_source_cache
            .timeline

    if core.is_table(existing)
        and type(existing.stats)
            == "function"
    then
        local existing_stats =
            existing:stats()

        if core.is_table(
            existing_stats
        )
            and (
                existing_stats
                    .processed_count
                or 0
            ) >= (
                incoming_stats
                    .processed_count
                or 0
            )
        then
            return
        end
    end

    persistent_register_source_cache
        .timeline = timeline
end


local function register_profile_name(
    opts,
    suffix
)
    local prefix =
        opts
        and opts.profile_prefix
        or "context.registers"

    return prefix
        .. ".dynamic."
        .. suffix
end


local function register_profile_begin(
    opts,
    suffix
)
    if type(opts) ~= "table"
        or type(opts.profile_begin)
            ~= "function"
    then
        return nil
    end

    return opts.profile_begin(
        register_profile_name(
            opts,
            suffix
        )
    )
end


local function register_profile_counter(
    opts,
    suffix,
    delta
)
    if type(opts) ~= "table"
        or type(opts.profile_counter)
            ~= "function"
    then
        return nil
    end

    return opts.profile_counter(
        register_profile_name(
            opts,
            suffix
        ),
        delta
    )
end


local function register_profile_end(
    opts,
    suffix,
    started
)
    if type(opts) ~= "table"
        or type(opts.profile_end)
            ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        register_profile_name(
            opts,
            suffix
        ),
        started
    )
end


local function get_prepared_register_source(
    adapter,
    opts
)
    opts = opts or {}

    local cache =
        opts.register_source_cache

    if not core.is_table(cache) then
        return nil
    end

    if cache.adapter == adapter
        and cache.root_node
            == opts.root_node
        and cache.prepared_source
    then
        return cache.prepared_source
    end

    local revision = nil

    if register_effects_are_stable(
        adapter
    ) then
        revision =
            get_register_source_buffer_revision(
                opts.bufnr
            )

        if persistent_register_source_matches(
            adapter,
            opts.bufnr,
            revision
        )
        then
            local rebound =
                copy_prepared_source_for_root(
                    persistent_register_source_cache
                        .prepared_source,
                    opts.root_node
                )

            cache.adapter = adapter
            cache.root_node =
                opts.root_node
            cache.prepared_source =
                rebound

            persistent_register_source_cache
                .prepared_source =
                rebound

            return rebound
        end
    end

    local prepare_opts = {
        root_node =
            opts.root_node,
        profile_prefix =
            opts.profile_prefix,
        profile_begin =
            opts.profile_begin,
        profile_end =
            opts.profile_end,
    }

    local prepared_source =
        register_effect_pipeline
            .prepare_source(
                adapter,
                prepare_opts
            )

    cache.adapter = adapter
    cache.root_node =
        opts.root_node
    cache.prepared_source =
        prepared_source

    remember_persistent_register_source(
        adapter,
        opts.bufnr,
        revision,
        prepared_source
    )

    return prepared_source
end


local function register_pipeline_dependencies(
    adapter,
    bufnr,
    register_source_cache
)
    return {
        parse_instruction = function(
            node,
            representative_effect_spec
        )
            return collect_instruction_operands_cached(
                adapter,
                node,
                bufnr,
                representative_effect_spec,
                register_source_cache
            )
        end,
    }
end


function M.collect_register_effects(
    context,
    adapter,
    opts
)
    opts = opts or {}

    local phase =
        register_profile_begin(
            opts,
            "prepare_source"
        )

    opts.prepared_source =
        opts.prepared_source
        or get_prepared_register_source(
            adapter,
            opts
        )

    register_profile_end(
        opts,
        "prepare_source",
        phase
    )

    return register_effect_pipeline.collect(
        context,
        adapter,
        opts,
        register_pipeline_dependencies(
            adapter,
            opts.bufnr,
            opts.register_source_cache
        )
    )
end


function M.collect_register_effect_pair(
    context,
    adapter,
    opts
)
    opts = opts or {}

    if not opts.before_position then
        return nil, nil
    end

    local phase =
        register_profile_begin(
            opts,
            "prepare_source"
        )

    opts.prepared_source =
        opts.prepared_source
        or get_prepared_register_source(
            adapter,
            opts
        )

    register_profile_end(
        opts,
        "prepare_source",
        phase
    )

    if not opts.prepared_source then
        return nil, nil
    end

    local prior_timeline =
        persistent_register_timeline(
            adapter,
            opts.bufnr
        )

    local reusable_before = nil
    local reusable_visible = nil

    if prior_timeline then
        reusable_before =
            prior_timeline:snapshot_before(
                opts.before_position
            )

        reusable_visible =
            prior_timeline:snapshot_visible(
                context,
                {
                    config = opts.config,
                }
            )
    end

    if reusable_before ~= nil
        and reusable_visible ~= nil
    then
        register_profile_counter(
            opts,
            "process.cross_refresh_timeline_reuse_possible",
            1
        )

        register_profile_counter(
            opts,
            "process.cross_refresh_timeline_reuse_applied",
            1
        )

        return reusable_before,
            reusable_visible,
            prior_timeline
    end

    register_profile_counter(
        opts,
        "process.cross_refresh_timeline_reuse_miss",
        1
    )

    local replay_opts = {}

    for key, value in pairs(opts) do
        replay_opts[key] = value
    end

    replay_opts.profile_prefix =
        register_profile_name(
            opts,
            "process"
        )

    -- Capture read-only pre-instruction checkpoints on fresh paired replay.
    -- Proven unchanged refreshes may return from the persistent timeline above.
    replay_opts.capture_timeline = true

    local session =
        register_effect_pipeline
            .new_replay_session(
                context,
                adapter,
                replay_opts,
                register_pipeline_dependencies(
                    adapter,
                    opts.bufnr,
                    opts.register_source_cache
                )
            )

    if not session then
        return nil, nil
    end

    phase =
        register_profile_begin(
            opts,
            "process"
        )

    local before, visible =
        session:collect_before_and_visible(
            opts.before_position,
            context,
            {
                config = opts.config,
            }
        )

    register_profile_end(
        opts,
        "process",
        phase
    )

    local timeline =
        session:get_timeline()

    remember_persistent_register_timeline(
        adapter,
        opts.bufnr,
        timeline
    )

    return before,
        visible,
        timeline
end


-- Source-time address evaluation is shared by memory and register discovery.


local function evaluate_memory_address_before_instruction(
    bufnr,
    root_node,
    adapter,
    instruction,
    address,
    machine_addresses,
    instruction_relative_policy,
    register_replay_session,
    register_timeline,
    profile_opts
)
    return memory_address_evaluator.evaluate(
        bufnr,
        root_node,
        adapter,
        instruction,
        address,
        machine_addresses,
        instruction_relative_policy,
        {
            collect_register_effects =
                M.collect_register_effects,

            collect_register_effects_before =
                register_replay_session
                and function(
                    limit_position
                )
                    return register_replay_session
                        :collect_before(
                            limit_position
                        )
                end
                or nil,

            register_timeline =
                register_timeline,

            profile_prefix =
                profile_opts
                and profile_opts
                    .profile_prefix
                or nil,
            profile_begin =
                profile_opts
                and profile_opts
                    .profile_begin
                or nil,
            profile_end =
                profile_opts
                and profile_opts
                    .profile_end
                or nil,
            profile_counter =
                profile_opts
                and profile_opts
                    .profile_counter
                or nil,
        }
    )
end


local function collect_memory_source_operands_where(
    bufnr,
    root_node,
    adapter,
    line_predicate,
    opts
)
    opts = opts or {}

    local prepared_source =
        get_prepared_register_source(
            adapter,
            {
                bufnr = bufnr,
                root_node = root_node,
                register_source_cache =
                    opts.register_source_cache,
            }
        )

    local replay_opts = {
        bufnr = bufnr,
        root_node = root_node,
        prepared_source =
            prepared_source,
        profile_prefix =
            (
                opts.profile_prefix
                or "context.source_memory"
            )
            .. ".collect.evaluate.register_replay",
        profile_begin =
            opts.profile_begin,
        profile_end =
            opts.profile_end,
        profile_counter =
            opts.profile_counter,
    }

    local register_replay_session =
        register_effect_pipeline
            .new_replay_session(
                {},
                adapter,
                replay_opts,
                register_pipeline_dependencies(
                    adapter,
                    bufnr,
                    opts.register_source_cache
                )
            )

    local discovery_opts = {}

    for key, value in pairs(
        opts
    ) do
        discovery_opts[key] =
            value
    end

    if core.is_table(
        prepared_source
    )
        and core.is_table(
            prepared_source.nodes
        )
        and core.is_table(
            prepared_source.effect_index
        )
        and core.is_table(
            prepared_source
                .effect_index
                .node_types
        )
    then
        discovery_opts
            .instruction_nodes =
            prepared_source.nodes
        discovery_opts
            .instruction_node_types =
            prepared_source
                .effect_index
                .node_types
    end

    return memory_source_discovery.collect(
        bufnr,
        root_node,
        adapter,
        line_predicate,
        discovery_opts,
        {
            get_register_effect_index =
                get_register_effect_index,

            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands_cached(
                    adapter,
                    node,
                    bufnr,
                    representative_effect_spec,
                    opts.register_source_cache
                )
            end,

            evaluate_address = function(
                instruction,
                address,
                machine_addresses,
                instruction_relative_policy
            )
                return evaluate_memory_address_before_instruction(
                    bufnr,
                    root_node,
                    adapter,
                    instruction,
                    address,
                    machine_addresses,
                    instruction_relative_policy,
                    register_replay_session,
                    opts.register_timeline,
                    {
                        profile_prefix =
                            (
                                opts.profile_prefix
                                or "context.source_memory"
                            )
                            .. ".collect.evaluate",
                        profile_begin =
                            opts.profile_begin,
                        profile_end =
                            opts.profile_end,
                        profile_counter =
                            opts.profile_counter,
                    }
                )
            end,
        }
    )
end


function M.discover_memory_source_operands(
    bufnr,
    root_node,
    adapter,
    line_number,
    opts
)
    if not core.is_number(line_number) then
        return {}
    end

    local exact_line = math.floor(line_number)

    return collect_memory_source_operands_where(
        bufnr,
        root_node,
        adapter,
        function(source_line)
            return source_line == exact_line
        end,
        opts
    )
end


function M.collect_memory_source_operands(
    bufnr,
    root_node,
    adapter,
    cursor_line,
    opts
)
    if not core.is_number(cursor_line) then
        return {}
    end

    local visible_line = math.floor(cursor_line)

    return collect_memory_source_operands_where(
        bufnr,
        root_node,
        adapter,
        function(source_line)
            return source_line <= visible_line
        end,
        opts
    )
end


function M.discover_register_source_occurrences(
    bufnr,
    root_node,
    adapter,
    line_number,
    opts
)
    return register_source_discovery.collect(
        bufnr,
        root_node,
        adapter,
        line_number,
        opts,
        {
            get_register_effect_index =
                get_register_effect_index,

            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    bufnr,
                    representative_effect_spec
                )
            end,

            evaluate_address = function(
                instruction,
                address,
                machine_addresses,
                instruction_relative_policy
            )
                return evaluate_memory_address_before_instruction(
                    bufnr,
                    root_node,
                    adapter,
                    instruction,
                    address,
                    machine_addresses,
                    instruction_relative_policy,
                    nil,
                    nil
                )
            end,
        }
    )
end


function M.collect_boundary_effects(
    context,
    adapter,
    opts
)
    opts = opts or {}

    opts.prepared_register_source =
        opts.prepared_register_source
        or get_prepared_register_source(
            adapter,
            opts
        )

    return boundary_effect_pipeline.collect(
        context,
        adapter,
        opts,
        {
            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands_cached(
                    adapter,
                    node,
                    opts.bufnr,
                    representative_effect_spec,
                    opts.register_source_cache
                )
            end,

            collect_register_effects =
                M.collect_register_effects,

            create_register_replay_session =
                function()
                    local replay_opts = {}

                    for key, value in pairs(
                        opts
                    ) do
                        replay_opts[key] =
                            value
                    end

                    replay_opts.prepared_source =
                        replay_opts.prepared_source
                        or get_prepared_register_source(
                            adapter,
                            opts
                        )

                    if opts.profile_prefix then
                        replay_opts.profile_prefix =
                            opts.profile_prefix
                            .. ".read_context.register_replay"
                    end

                    return register_effect_pipeline
                        .new_replay_session(
                            context,
                            adapter,
                            replay_opts,
                            register_pipeline_dependencies(
                                adapter,
                                opts.bufnr,
                                opts.register_source_cache
                            )
                        )
                end,
        }
    )
end


function M.collect_instruction_events(
    context,
    adapter,
    opts
)
    opts = opts or {}

    opts.prepared_register_source =
        opts.prepared_register_source
        or get_prepared_register_source(
            adapter,
            opts
        )

    return instruction_event_pipeline.collect(
        context,
        adapter,
        opts,
        {
            parse_instruction = function(
                node,
                representative_event_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    opts.bufnr,
                    representative_event_spec
                )
            end,
        }
    )
end


function M.collect_stack_effects(
    context,
    adapter,
    opts
)
    opts = opts or {}

    opts.prepared_register_source =
        opts.prepared_register_source
        or get_prepared_register_source(
            adapter,
            opts
        )

    return stack_effect_pipeline.collect(
        context,
        adapter,
        opts,
        {
            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    opts.bufnr,
                    representative_effect_spec
                )
            end,
        }
    )
end


return M
