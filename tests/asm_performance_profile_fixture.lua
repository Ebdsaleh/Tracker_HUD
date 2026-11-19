-- tests/asm_performance_profile_fixture.lua
-- Automated, non-gating ERIDU performance fixture.
-- Run through tracker_profile.bat from a VS Native Tools cmd.exe prompt.
--
-- This intentionally has no wall-clock thresholds. It reproduces the
-- committed cursor/edit/target-change workload and prints :HudProfile-style
-- measurements for comparison between accepted semantic baselines.

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    package.loaded[
        "tracker_hud.analysis_profile"
    ] = nil
    package.loaded[
        "tracker_hud"
    ] = nil

    local path =
        "samples/asm/x86_64/performance_baseline.asm"

    local source =
        vim.fn.readfile(path)

    local marker_a = nil
    local marker_c = nil
    local edit_line = nil
    local platform_line = nil

    for line_number, line in ipairs(source) do
        if line == "; PROFILE MARKER A" then
            marker_a = line_number
        elseif line == "; PROFILE MARKER C" then
            marker_c = line_number
        elseif line == "; platform=linux;" then
            platform_line = line_number
        elseif not edit_line
            and line:find(
                "Synthetic source fixture",
                1,
                true
            )
        then
            edit_line = line_number
        end
    end

    assert(
        marker_a
            and marker_c
            and marker_c - marker_a >= 50,
        "performance markers no longer provide the large-jump workload"
    )

    assert(
        edit_line
            and platform_line,
        "performance fixture edit/directive anchors changed"
    )

    -- Use a normal source buffer. scratch=true sets buftype=nofile,
    -- and Tracker_HUD intentionally ignores non-source buffers.
    local buffer =
        vim.api.nvim_create_buf(
            false,
            false
        )

    assert(
        vim.bo[buffer].buftype == "",
        "performance fixture must use a normal source buffer"
    )

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        -1,
        false,
        source
    )

    vim.bo[buffer].filetype = "asm"
    vim.api.nvim_set_current_buf(buffer)

    local tracker =
        require("tracker_hud")

    tracker.setup({
        keymaps = {
            enabled = false,
        },
        analysis = {
            profile = {
                enabled = true,
                max_samples = 64,
                large_jump_lines = 50,
            },
        },
    })

    local profile =
        require(
            "tracker_hud.analysis_profile"
        )

    profile.reset()
    profile.set_enabled(true)

    local function refresh(
        event,
        line
    )
        if line then
            vim.api.nvim_win_set_cursor(
                0,
                {
                    line,
                    0,
                }
            )
        end

        vim.api.nvim_exec_autocmds(
            event,
            {
                buffer = buffer,
                modeline = false,
            }
        )
    end

    local function replace_line(
        line_number,
        text
    )
        vim.api.nvim_buf_set_lines(
            buffer,
            line_number - 1,
            line_number,
            false,
            {
                text,
            }
        )

        refresh(
            "TextChanged",
            line_number
        )
    end

    -- Repeatable equivalent of the former manual HudProfile choreography.
    refresh(
        "CursorMoved",
        marker_a
    )

    refresh(
        "CursorMoved",
        marker_a + 1
    )

    refresh(
        "CursorMoved",
        marker_c
    )

    refresh(
        "CursorMoved",
        edit_line
    )

    local original_edit =
        source[edit_line]

    replace_line(
        edit_line,
        original_edit .. " "
    )

    replace_line(
        edit_line,
        original_edit
    )

    refresh(
        "CursorMoved",
        platform_line
    )

    replace_line(
        platform_line,
        "; platform=windows;"
    )

    replace_line(
        platform_line,
        "; platform=linux;"
    )

    local snapshot =
        profile.snapshot()

    assert(
        snapshot.refresh_count == 9,
        "automated performance workload refresh count changed: "
            .. tostring(
                snapshot.refresh_count
            )
    )

    local cursor_refreshes = 0
    local edit_refreshes = 0

    for _, sample in ipairs(
        snapshot.samples
    ) do
        if sample.event == "CursorMoved" then
            cursor_refreshes =
                cursor_refreshes + 1
        elseif sample.event == "TextChanged" then
            edit_refreshes =
                edit_refreshes + 1
        end
    end

    assert(
        cursor_refreshes == 5
            and edit_refreshes == 4,
        "automated performance workload event mix changed: "
            .. "CursorMoved="
            .. tostring(cursor_refreshes)
            .. " TextChanged="
            .. tostring(edit_refreshes)
    )

    local required_phases = {
        "context",
        "context.configure",
        "context.configure.lookup",
        "context.configure.changedtick",
        "context.configure.cache_check",
        "context.registers",
        "context.registers.dynamic",
        "context.registers.dynamic.prepare_source",
        "context.registers.dynamic.prepare_source.index",
        "context.registers.dynamic.prepare_source.collect_nodes",
        "context.registers.dynamic.process",
        "context.registers.dynamic.process.parse",
        "context.registers.dynamic.process.prepare_state",
        "context.registers.dynamic.process.apply",
        "context.registers.dynamic.process.apply.match",
        "context.registers.dynamic.process.apply.build",
        "context.registers.dynamic.process.apply.build.target",
        "context.registers.dynamic.process.apply.build.resolve_value",
        "context.registers.dynamic.process.apply.build.width_policy",
        "context.registers.dynamic.process.apply.build.alias_lookup",
        "context.registers.dynamic.process.apply.build.alias_compose",
        "context.registers.dynamic.process.apply.build.static_spec",
        "context.registers.dynamic.process.apply.build.metadata",
        "context.registers.dynamic.process.apply.build.metadata.base",
        "context.registers.dynamic.process.apply.build.metadata.source_integer_merge",
        "context.registers.dynamic.process.apply.build.metadata.source_build",
        "context.registers.dynamic.process.apply.build.metadata.source_merge",
        "context.registers.dynamic.process.apply.publish",
        "context.registers.dynamic.process.snapshot",
        "context.registers.dynamic.process.timeline_capture",
        "context.stack",
        "context.stack.dynamic",
        "context.stack.dynamic.index",
        "context.stack.dynamic.collect",
        "context.stack.dynamic.nodes",
        "context.stack.dynamic.parse",
        "context.stack.dynamic.prepare_state",
        "context.stack.dynamic.apply_stack",
        "context.stack.dynamic.timeline_lookup",
        "context.stack.static",
        "context.stack.sort",
        "context.boundary",
        "context.boundary.index",
        "context.boundary.replay_session",
        "context.boundary.collect",
        "context.boundary.nodes",
        "context.boundary.parse",
        "context.boundary.read_context",
        "context.boundary.read_context.timeline_lookup",
        "context.instruction_events",
        "context.instruction_events.index",
        "context.instruction_events.collect",
        "context.instruction_events.nodes",
        "context.instruction_events.parse",
        "context.source_memory",
        "context.source_memory.effect_index",
        "context.source_memory.source_members",
        "context.source_memory.nodes",
        "context.source_memory.collect",
        "context.source_memory.collect.filter",
        "context.source_memory.collect.parse",
        "context.source_memory.collect.match",
        "context.source_memory.collect.evidence",
        "context.source_memory.collect.evaluate",
        "context.source_memory.collect.evaluate.relative_check",
        "context.source_memory.collect.evaluate.register_replay",
        "context.source_memory.collect.evaluate.timeline_lookup",
        "context.source_memory.collect.evaluate.fact_map",
        "context.source_memory.collect.evaluate.effective_address",
        "context.source_memory.collect.role_access",
        "context.source_memory.collect.fact",
        "context.source_memory.collect.sort",
        "render",
        "total",
    }

    for _, name in ipairs(required_phases) do
        assert(
            type(snapshot.phases[name])
                == "table"
                and snapshot.phases[name].count
                    > 0,
            "automated performance fixture missing phase: "
                .. tostring(name)
        )
    end

    local required_counters = {
        "context.registers.dynamic.process.processed_entries",
        "context.registers.dynamic.process.timeline_checkpoints",
        "context.registers.dynamic.process.cross_refresh_timeline_reuse_possible",
        "context.registers.dynamic.process.cross_refresh_timeline_reuse_applied",
        "context.registers.dynamic.process.cross_refresh_timeline_reuse_miss",
        "context.stack.dynamic.processed_entries",
        "context.stack.dynamic.timeline_hits",
        "context.boundary.read_context.timeline_hits",
        "context.source_memory.collect.evaluate.timeline_hits",
        "context.scope_members.cross_refresh_reuse_possible",
        "context.scope_members.cross_refresh_reuse_applied",
        "context.scope_members.cross_refresh_reuse_miss",
        "context.scope_members.nodes_visited",
        "context.scope_members.spec_checks",
        "context.scope_members.construct_scope_lookups",
        "context.scope_members.group_candidate_lookups",
        "context.scope_members.scope_filter_state_builds",
        "context.scope_members.candidate_bearing_group_lookups",
        "context.scope_members.members_emitted",
        "context.scopes.range_scope_cross_refresh_reuse_possible",
        "context.scopes.range_scope_cross_refresh_reuse_applied",
        "context.scopes.range_scope_cross_refresh_reuse_miss",
        "context.warnings.syntax.cross_refresh_reuse_possible",
        "context.warnings.syntax.cross_refresh_reuse_applied",
        "context.warnings.syntax.cross_refresh_reuse_miss",
        "context.warnings.syntax.shared_snapshot_hits",
        "context.warnings.syntax.candidates",
        "context.source_nodes.walks",
        "context.source_nodes.nodes_visited",
        "context.registers.dynamic.prepare_source.collect_nodes.shared_snapshot_hits",
        "context.registers.dynamic.prepare_source.collect_nodes.nodes_matched",
        "context.configure.adapter.directive_scans",
        "context.configure.adapter.directive_scans.shared",
        "context.configure.adapter.variant.identity_checks",
        "context.configure.adapter.variant.same_identity",
        "context.scopes.range_scope_scans",
        "context.scopes.range_scope_shared_snapshot_hits",
        "context.scopes.range_scope_nodes_matched",
        "context.stack.dynamic.nodes.lookup_attempts",
        "context.boundary.nodes.lookup_attempts",
        "context.instruction_events.nodes.lookup_attempts",
        "context.source_memory.nodes.lookup_attempts",
    }

    for _, name in ipairs(
        required_counters
    ) do
        local counter =
            snapshot.counters[name]

        assert(
            type(counter) == "table"
                and counter.count > 0,
            "automated performance fixture missing replay-work counter: "
                .. tostring(name)
        )
    end

    local reuse_hits =
        snapshot.counters[
            "context.registers.dynamic.process.cross_refresh_timeline_reuse_possible"
        ]

    local reuse_applied =
        snapshot.counters[
            "context.registers.dynamic.process.cross_refresh_timeline_reuse_applied"
        ]

    local reuse_misses =
        snapshot.counters[
            "context.registers.dynamic.process.cross_refresh_timeline_reuse_miss"
        ]

    assert(
        reuse_hits.total
            + reuse_misses.total
            == snapshot.refresh_count,
        "cross-refresh Register timeline eligibility checks changed"
    )

    assert(
        reuse_applied.total
            == reuse_hits.total,
        "eligible cross-refresh Register timeline was not always reused"
    )

    local fresh_work =
        snapshot.counters[
            "context.registers.dynamic.process.processed_entries"
        ]

    assert(
        fresh_work.count
            == reuse_misses.total,
        "fresh Register replay did not align with timeline reuse misses"
    )

    print(
        "[Tracker_HUD] Cross-refresh Register timeline: "
            .. tostring(reuse_applied.total)
            .. " reused / "
            .. tostring(snapshot.refresh_count)
            .. " refreshes"
    )

    local scope_reuse_possible =
        snapshot.counters[
            "context.scope_members.cross_refresh_reuse_possible"
        ]

    local scope_reuse_applied =
        snapshot.counters[
            "context.scope_members.cross_refresh_reuse_applied"
        ]

    local scope_reuse_miss =
        snapshot.counters[
            "context.scope_members.cross_refresh_reuse_miss"
        ]

    assert(
        scope_reuse_possible.total == 4
            and scope_reuse_applied.total == 4
            and scope_reuse_miss.total == 5
            and scope_reuse_possible.total
                + scope_reuse_miss.total
                == snapshot.refresh_count,
        "Scope Member persistent discovery reuse changed"
    )

    print(
        "[Tracker_HUD] Cross-refresh Scope-member discovery: "
            .. tostring(
                scope_reuse_applied.total
            )
            .. " reused / "
            .. tostring(
                snapshot.refresh_count
            )
            .. " refreshes"
    )

    local scope_nodes =
        snapshot.counters[
            "context.scope_members.nodes_visited"
        ]

    local scope_checks =
        snapshot.counters[
            "context.scope_members.spec_checks"
        ]

    assert(
        scope_nodes.count
            == scope_reuse_miss.total
            and scope_checks.count
                == scope_reuse_miss.total,
        "fresh Scope Member discovery work did not align with cache misses"
    )

    assert(
        snapshot.counters[
            "context.scope_members_all.nodes_visited"
        ] == nil
            and snapshot.counters[
                "context.scope_members_all.spec_checks"
            ] == nil
            and snapshot.counters[
                "context.scope_members_all.members_emitted"
            ] == nil,
        "all-members view unexpectedly repeated scope-member discovery"
    )

    print(
        "[Tracker_HUD] Scope-member shared discovery: "
            .. tostring(
                scope_nodes.total
            )
            .. " nodes + "
            .. tostring(
                scope_checks.total
            )
            .. " spec checks feed current/all views"
    )

    assert(
        scope_checks.total == 1315,
        "Scope Member node-type indexed spec work changed"
    )

    assert(
        snapshot.counters[
            "context.scope_members.node_type_candidate_checks"
        ] == nil
            and snapshot.counters[
                "context.scope_members_all.node_type_candidate_checks"
            ] == nil,
        "Scope Member opportunity-only candidate counter leaked into production"
    )

    print(
        "[Tracker_HUD] Scope-member node-type index: "
            .. tostring(
                scope_nodes.total
            )
            .. " nodes + "
            .. tostring(
                scope_checks.total
            )
            .. " indexed spec check(s) across "
            .. tostring(
                scope_reuse_miss.total
            )
            .. " fresh discoverie(s)"
    )

    local scope_construct_lookups =
        snapshot.counters[
            "context.scope_members.construct_scope_lookups"
        ]

    assert(
        type(scope_construct_lookups) == "table"
            and scope_construct_lookups.count
                == scope_reuse_miss.total
            and scope_construct_lookups.total
                == 5590
            and scope_nodes.total
                == 5590
            and snapshot.counters[
                "context.scope_members.construct_scope_lookup_requests"
            ] == nil,
        "Scope Member shared construct-scope lookup changed"
    )

    print(
        "[Tracker_HUD] Scope-member construct-scope lookup reuse: "
            .. tostring(
                scope_construct_lookups.total
            )
            .. " construct-spec lookup(s) across "
            .. tostring(
                scope_nodes.total
            )
            .. " visited node(s); lexical + structural decisions share one lookup"
    )

    local scope_group_lookups =
        snapshot.counters[
            "context.scope_members.group_candidate_lookups"
        ]

    assert(
        type(scope_group_lookups) == "table"
            and scope_group_lookups.count
                == scope_reuse_miss.total
            and scope_group_lookups.total
                == 11180
            and snapshot.counters[
                "context.scope_members.group_candidate_lookup_requests"
            ] == nil
            and snapshot.counters[
                "context.scope_members.active_group_candidate_lookup_requests"
            ] == nil,
        "Scope Member empty-group lookup elimination changed"
    )

    print(
        "[Tracker_HUD] Scope-member empty-group lookup elimination: "
            .. tostring(
                scope_group_lookups.total
            )
            .. " candidate-group lookup(s) remain across "
            .. tostring(
                scope_reuse_miss.total
            )
            .. " fresh discoverie(s); empty groups return before candidate lookup"
    )

    local scope_filter_state_builds =
        snapshot.counters[
            "context.scope_members.scope_filter_state_builds"
        ]

    local scope_candidate_group_lookups =
        snapshot.counters[
            "context.scope_members.candidate_bearing_group_lookups"
        ]

    assert(
        type(scope_filter_state_builds) == "table"
            and type(scope_candidate_group_lookups) == "table"
            and scope_filter_state_builds.count
                == scope_reuse_miss.total
            and scope_filter_state_builds.total
                == 11180
            and scope_candidate_group_lookups.count
                == scope_reuse_miss.total
            and scope_candidate_group_lookups.total
                == 1315,
        "Scope Member scope-filter state opportunity changed"
    )

    print(
        "[Tracker_HUD] Scope-member scope-filter state opportunity: "
            .. tostring(
                scope_filter_state_builds.total
            )
            .. " filtered-state build(s) vs "
            .. tostring(
                scope_candidate_group_lookups.total
            )
            .. " candidate-bearing group lookup(s) across "
            .. tostring(
                scope_reuse_miss.total
            )
            .. " fresh discoverie(s)"
    )

    local range_scope_reuse_possible =
        snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_possible"
        ]

    local range_scope_reuse_applied =
        snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_applied"
        ]

    local range_scope_reuse_miss =
        snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_miss"
        ]

    assert(
        range_scope_reuse_possible.total
            == 4
            and range_scope_reuse_applied.total
                == 4
            and range_scope_reuse_miss.total
                == 5
            and range_scope_reuse_possible.total
                + range_scope_reuse_miss.total
                == snapshot.refresh_count,
        "Range Scope persistent discovery reuse changed"
    )

    print(
        "[Tracker_HUD] Cross-refresh Range-scope discovery: "
            .. tostring(
                range_scope_reuse_applied.total
            )
            .. " reused / "
            .. tostring(
                snapshot.refresh_count
            )
            .. " refreshes"
    )

    local range_scope_scans =
        snapshot.counters[
            "context.scopes.range_scope_scans"
        ]

    local range_scope_snapshot_hits =
        snapshot.counters[
            "context.scopes.range_scope_shared_snapshot_hits"
        ]

    local range_scope_matches =
        snapshot.counters[
            "context.scopes.range_scope_nodes_matched"
        ]

    assert(
        range_scope_scans.count
            == range_scope_reuse_miss.total
            and range_scope_snapshot_hits.count
                == range_scope_reuse_miss.total
            and range_scope_matches.count
                == range_scope_reuse_miss.total
            and range_scope_scans.total
                == range_scope_reuse_miss.total
            and range_scope_snapshot_hits.total
                == range_scope_reuse_miss.total
            and snapshot.counters[
                "context.scopes.range_scope_nodes_visited"
            ] == nil,
        "fresh Range Scope discovery did not reuse shared source nodes"
    )

    print(
        "[Tracker_HUD] Range-scope shared source: "
            .. tostring(
                range_scope_snapshot_hits.total
            )
            .. " snapshot hit(s) across "
            .. tostring(
                range_scope_scans.total
            )
            .. " discovery scan(s), "
            .. tostring(
                range_scope_matches.total
            )
            .. " matching node(s)"
    )

    local function counter_total(
        name
    )
        local counter =
            snapshot.counters[name]

        return type(counter) == "table"
            and counter.total
            or 0
    end

    local prepared_node_consumers = {
        {
            label = "stack",
            prefix =
                "context.stack.dynamic.nodes",
            phase =
                "context.stack.dynamic.nodes",
        },
        {
            label = "boundary",
            prefix =
                "context.boundary.nodes",
            phase =
                "context.boundary.nodes",
        },
        {
            label = "events",
            prefix =
                "context.instruction_events.nodes",
            phase =
                "context.instruction_events.nodes",
        },
        {
            label = "memory",
            prefix =
                "context.source_memory.nodes",
            phase =
                "context.source_memory.nodes",
        },
    }

    local prepared_node_summary = {}

    for _, consumer in ipairs(
        prepared_node_consumers
    ) do
        local attempt_counter =
            snapshot.counters[
                consumer.prefix
                    .. ".lookup_attempts"
            ]
        local attempts =
            counter_total(
                consumer.prefix
                    .. ".lookup_attempts"
            )
        local hits =
            counter_total(
                consumer.prefix
                    .. ".prepared_hits"
            )
        local fallbacks =
            counter_total(
                consumer.prefix
                    .. ".prepared_fallbacks"
            )
        local phase =
            snapshot.phases[
                consumer.phase
            ]

        assert(
            attempts
                == hits + fallbacks
                and type(
                    attempt_counter
                ) == "table"
                and type(phase) == "table"
                and attempt_counter.count
                    == phase.count,
            "prepared instruction-node measurement lost coverage for "
                .. consumer.label
        )

        table.insert(
            prepared_node_summary,
            consumer.label
                .. "="
                .. tostring(hits)
                .. " hit/"
                .. tostring(fallbacks)
                .. " fallback"
        )
    end

    print(
        "[Tracker_HUD] Prepared instruction-node reuse: "
            .. table.concat(
                prepared_node_summary,
                ", "
            )
    )

    local parse_cache_consumers = {
        {
            label = "stack",
            requests = 108,
            hits = 93,
            misses = 15,
        },
        {
            label = "events",
            requests = 108,
            hits = 108,
            misses = 0,
        },
    }

    local parse_cache_summary = {}

    for _, consumer in ipairs(
        parse_cache_consumers
    ) do
        local prefix =
            "context.instruction_parse_cache."
            .. consumer.label

        local requests =
            counter_total(
                prefix .. ".requests"
            )
        local hits =
            counter_total(
                prefix .. ".hits"
            )
        local misses =
            counter_total(
                prefix .. ".misses"
            )

        assert(
            requests
                == consumer.requests
                and hits
                    == consumer.hits
                and misses
                    == consumer.misses
                and requests
                    == hits + misses,
            "node-stable instruction parse cache changed for "
                .. consumer.label
        )

        table.insert(
            parse_cache_summary,
            consumer.label
                .. "="
                .. tostring(hits)
                .. " hit/"
                .. tostring(misses)
                .. " miss"
        )
    end

    print(
        "[Tracker_HUD] Node-stable instruction parse cache: "
            .. table.concat(
                parse_cache_summary,
                ", "
            )
    )

    local warning_reuse_possible =
        snapshot.counters[
            "context.warnings.syntax.cross_refresh_reuse_possible"
        ]

    local warning_reuse_applied =
        snapshot.counters[
            "context.warnings.syntax.cross_refresh_reuse_applied"
        ]

    local warning_reuse_miss =
        snapshot.counters[
            "context.warnings.syntax.cross_refresh_reuse_miss"
        ]

    assert(
        warning_reuse_possible.total
            == 4
            and warning_reuse_applied.total
                == 4
            and warning_reuse_miss.total
                == 5
            and warning_reuse_possible.total
                + warning_reuse_miss.total
                == snapshot.refresh_count,
        "Tree-sitter warning persistent discovery reuse changed"
    )

    print(
        "[Tracker_HUD] Cross-refresh Tree-sitter warning discovery: "
            .. tostring(
                warning_reuse_applied.total
            )
            .. " reused / "
            .. tostring(
                snapshot.refresh_count
            )
            .. " refreshes"
    )

    local warning_snapshot_hits =
        snapshot.counters[
            "context.warnings.syntax.shared_snapshot_hits"
        ]

    local warning_candidates =
        snapshot.counters[
            "context.warnings.syntax.candidates"
        ]

    assert(
        warning_snapshot_hits.count
            == warning_reuse_miss.total
            and warning_snapshot_hits.total
                == warning_reuse_miss.total
            and warning_candidates.count
                == warning_reuse_miss.total
            and warning_candidates.total
                == 15
            and snapshot.counters[
                "context.warnings.syntax.scans"
            ] == nil
            and snapshot.counters[
                "context.warnings.syntax.nodes_visited"
            ] == nil,
        "fresh Tree-sitter warning discovery did not reuse shared source nodes"
    )

    print(
        "[Tracker_HUD] Tree-sitter warning shared source: "
            .. tostring(
                warning_snapshot_hits.total
            )
            .. " snapshot hit(s), "
            .. tostring(
                warning_candidates.total
            )
            .. " ERROR/MISSING candidate(s)"
    )

    local shared_source_walks =
        snapshot.counters[
            "context.source_nodes.walks"
        ]

    local shared_source_nodes =
        snapshot.counters[
            "context.source_nodes.nodes_visited"
        ]

    assert(
        range_scope_reuse_miss.total == 5
            and warning_reuse_miss.total == 5
            and shared_source_walks.count == 5
            and shared_source_walks.total == 5
            and shared_source_nodes.count == 5
            and shared_source_nodes.total == 5590
            and range_scope_snapshot_hits.total == 5
            and warning_snapshot_hits.total == 5,
        "shared Tree-sitter source snapshot work changed"
    )

    print(
        "[Tracker_HUD] Shared Tree-sitter source snapshot: "
            .. tostring(
                shared_source_walks.total
            )
            .. " full-tree walk(s), "
            .. tostring(
                shared_source_nodes.total
            )
            .. " node visit(s); Range Scopes + syntax warnings both reused it on 5 source revision(s)"
    )

    local register_source_snapshot_hits =
        snapshot.counters[
            "context.registers.dynamic.prepare_source.collect_nodes.shared_snapshot_hits"
        ]

    local register_source_matches =
        snapshot.counters[
            "context.registers.dynamic.prepare_source.collect_nodes.nodes_matched"
        ]

    assert(
        type(register_source_snapshot_hits) == "table"
            and type(register_source_matches) == "table"
            and register_source_snapshot_hits.count == 5
            and register_source_snapshot_hits.total == 5
            and register_source_matches.count == 5
            and register_source_matches.total == 645
            and snapshot.counters[
                "context.registers.dynamic.prepare_source.collect_nodes.full_tree_scans"
            ] == nil
            and shared_source_walks.total == 5
            and shared_source_nodes.total == 5590,
        "Register prepared-source shared snapshot reuse changed"
    )

    print(
        "[Tracker_HUD] Register prepared-source shared source: "
            .. tostring(
                register_source_snapshot_hits.total
            )
            .. " snapshot hit(s), "
            .. tostring(
                register_source_matches.total
            )
            .. " matching instruction node(s); 0 recursive full-tree scans"
    )

    local directive_scan_counter =
        snapshot.counters[
            "context.configure.adapter.directive_scans"
        ]

    local shared_directive_scans =
        counter_total(
            "context.configure.adapter.directive_scans.shared"
        )

    local configure_adapter_phase =
        snapshot.phases[
            "context.configure.adapter"
        ]

    assert(
        type(directive_scan_counter)
            == "table"
            and type(configure_adapter_phase)
                == "table"
            and directive_scan_counter.count
                == configure_adapter_phase.count
            and directive_scan_counter.total
                == 5
            and shared_directive_scans
                == 5
            and snapshot.counters[
                "context.configure.adapter.directive_scans.variant"
            ] == nil
            and snapshot.counters[
                "context.configure.adapter.directive_scans.targets"
            ] == nil,
        "ASM configuration shared directive-scan reuse changed"
    )

    print(
        "[Tracker_HUD] ASM configuration directive scans: "
            .. tostring(
                shared_directive_scans
            )
            .. " shared scan(s) across "
            .. tostring(
                configure_adapter_phase.count
            )
            .. " configuration miss(es)"
    )

    local variant_identity_checks =
        snapshot.counters[
            "context.configure.adapter.variant.identity_checks"
        ]

    local variant_same_identity =
        snapshot.counters[
            "context.configure.adapter.variant.same_identity"
        ]

    assert(
        type(variant_identity_checks)
            == "table"
            and type(variant_same_identity)
                == "table"
            and variant_identity_checks.count
                == configure_adapter_phase.count
            and variant_identity_checks.total
                == 5
            and variant_same_identity.total
                == 5
            and snapshot.counters[
                "context.configure.adapter.variant.changed_identity"
            ] == nil
            and snapshot.counters[
                "context.configure.adapter.variant.apply_calls"
            ] == nil
            and snapshot.counters[
                "context.configure.adapter.variant.presentation_rebuilds"
            ] == nil,
        "ASM same-identity variant reuse changed"
    )

    print(
        "[Tracker_HUD] ASM variant reuse: "
            .. tostring(
                variant_same_identity.total
            )
            .. " same-identity skip(s) across "
            .. tostring(
                configure_adapter_phase.count
            )
            .. " configuration miss(es), "
            .. "0 static reapplies, "
            .. "0 presentation rebuilds"
    )

    local reusable_validation_components = {
        "construct_specs",
        "scope_members",
        "presentation",
        "instruction_parser",
        "memory_accesses",
        "boundary_effects",
    }

    for _, component in ipairs(
        reusable_validation_components
    ) do
        local full_phase =
            snapshot.phases[
                "context.configure.validate."
                    .. component
            ]

        local reuse_phase =
            snapshot.phases[
                "context.configure.validate."
                    .. component
                    .. "_reuse"
            ]

        assert(
            full_phase == nil
                and type(reuse_phase)
                    == "table"
                and reuse_phase.count
                    == configure_adapter_phase.count,
            "ASM stable validation reuse changed: "
                .. component
        )
    end

    print(
        "[Tracker_HUD] ASM validation reuse: "
            .. table.concat(
                reusable_validation_components,
                ", "
            )
            .. " reused across "
            .. tostring(
                configure_adapter_phase.count
            )
            .. " configuration miss(es)"
    )

    assert(
        snapshot.counters[
            "context.registers_before.dynamic.process.processed_entries"
        ] == nil,
        "Registers-before unexpectedly replayed the shared register prefix"
    )

    assert(
        snapshot.counters[
            "context.boundary.read_context.register_replay.processed_entries"
        ] == nil,
        "Boundary unexpectedly replayed register history instead of using timeline"
    )

    assert(
        snapshot.counters[
            "context.boundary.read_context.timeline_fallbacks"
        ] == nil,
        "Boundary timeline coverage unexpectedly fell back to register replay"
    )

    assert(
        snapshot.counters[
            "context.source_memory.collect.evaluate.register_replay.processed_entries"
        ] == nil,
        "Source Memory unexpectedly replayed register history instead of using timeline"
    )

    assert(
        snapshot.counters[
            "context.source_memory.collect.evaluate.timeline_fallbacks"
        ] == nil,
        "Source Memory timeline coverage unexpectedly fell back to register replay"
    )

    assert(
        snapshot.phases[
            "context.stack.dynamic.apply_register"
        ] == nil,
        "Stack unexpectedly restored local register-effect application"
    )

    assert(
        snapshot.counters[
            "context.stack.dynamic.timeline_fallbacks"
        ] == nil,
        "Stack timeline coverage unexpectedly fell back to legacy mixed replay"
    )

    print(
        "[Tracker_HUD] Stack register carry: "
            .. "pre-instruction timeline hits without local register application"
    )

    print(
        "[Tracker_HUD] Source Memory register context: "
            .. "pre-instruction timeline hits without replay fallback"
    )

    print(
        "[Tracker_HUD] Boundary register context: "
            .. "pre-instruction timeline hits without replay fallback"
    )

    local processed =
        snapshot.counters[
            "context.registers.dynamic.process.processed_entries"
        ]

    local checkpoints =
        snapshot.counters[
            "context.registers.dynamic.process.timeline_checkpoints"
        ]

    assert(
        processed
            and checkpoints
            and checkpoints.total
                == processed.total,
        "timeline checkpoint count diverged from processed Register entries"
    )

    print(
        "[Tracker_HUD] Register timeline capture: "
            .. "one checkpoint per processed entry"
    )

    print(
        "[Tracker_HUD] Paired register replay: "
            .. "Registers-before reuses current reduction"
    )

    print(
        "[Tracker_HUD] Automated ASM performance profile"
    )

    print(
        "[Tracker_HUD] Fixture: "
            .. path
    )

    print(
        "[Tracker_HUD] Workload: marker A -> step -> marker C -> "
            .. "top edit/undo -> platform toggle/undo"
    )

    for _, line in ipairs(
        profile.format_report({
            recent = 16,
        })
    ) do
        print(line)
    end

    profile.set_enabled(false)

    print(
        "[GREEN] Tracker_HUD automated performance profile completed."
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "[RED] Tracker_HUD automated performance profile failed: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
