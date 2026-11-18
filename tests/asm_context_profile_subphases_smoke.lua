-- tests/asm_context_profile_subphases_smoke.lua
-- nvim --headless -c "luafile tests/asm_context_profile_subphases_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local source =
        vim.fn.readfile(
            "samples/asm/x86_64/performance_baseline.asm"
        )

    local buffer =
        vim.api.nvim_create_buf(
            false,
            true
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
    vim.api.nvim_win_set_cursor(
        0,
        { 103, 0 }
    )

    local ok_parser, parser =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "asm"
        )

    assert(
        ok_parser and parser,
        "Missing Tree-sitter 'asm' parser. "
            .. "Install it in your Neovim configuration before running "
            .. "this parser-backed test. Error: "
            .. tostring(parser)
    )

    local tree = parser:parse()[1]

    assert(
        tree,
        "ASM parser yielded no tree"
    )

    local root = tree:root()

    local adapter =
        require(
            "tracker_hud.adapters.asm.init"
        )

    local registry =
        require(
            "tracker_hud.adapters.registry"
        )

    assert(
        registry.register(adapter)
    )

    local profile =
        require(
            "tracker_hud.analysis_profile"
        )

    profile.configure({
        enabled = true,
        max_samples = 16,
        large_jump_lines = 50,
    })

    local token =
        profile.begin_refresh(
            "CursorMoved",
            buffer,
            { 103, 0 }
        )

    assert(
        token,
        "profiling token was not created"
    )

    local context =
        require("tracker_hud.context")
            .get_cursor_context(
                buffer,
                {},
                {
                    profile_token = token,
                }
            )

    assert(
        type(context) == "table"
            and type(context.registers)
                == "table",
        "profiled context collection failed"
    )

    profile.finish_refresh(
        token,
        {
            updated = true,
        }
    )

    local scope_collector =
        require(
            "tracker_hud.scope_members"
        )

    local discovery =
        scope_collector.discover(
            buffer,
            root,
            adapter
        )

    local current_opts = {
        cursor_line =
            context.cursor
                and context.cursor.line,
    }

    if context.member_scope then
        current_opts.start_line =
            context.member_scope.start_line
        current_opts.end_line =
            context.member_scope.end_line
    else
        current_opts.scope_depth = 0
    end

    local function member_ids(
        members
    )
        local result = {}

        for _, member in ipairs(
            members or {}
        ) do
            table.insert(
                result,
                tostring(member.id)
            )
        end

        return table.concat(
            result,
            "\n"
        )
    end

    assert(
        member_ids(
            scope_collector.select(
                discovery,
                current_opts
            )
        ) == member_ids(
            context.scope_members
        ),
        "ASM shared scope-member discovery changed current-scope view"
    )

    assert(
        member_ids(
            scope_collector.select(
                discovery,
                {}
            )
        ) == member_ids(
            context.all_scope_members
        ),
        "ASM shared scope-member discovery changed all-members view"
    )

    print(
        "PASS ASM context profile: "
            .. "shared scope-member discovery preserves current/all views"
    )

    local snapshot =
        profile.snapshot()

    assert(
        snapshot.counters[
            "context.scope_members.cross_refresh_reuse_miss"
        ]
            and snapshot.counters[
                "context.scope_members.cross_refresh_reuse_miss"
            ].total == 1,
        "initial Scope Member discovery did not record a fresh-cache miss"
    )

    assert(
        snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_miss"
        ]
            and snapshot.counters[
                "context.scopes.range_scope_cross_refresh_reuse_miss"
            ].total == 1,
        "initial Range Scope discovery did not record a fresh-cache miss"
    )

    local expected = {
        "context.parser",
        "context.configure",
        "context.scopes",
        "context.setup",
        "context.scope_members",
        "context.scope_members_all",
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
        "context.registers.static",
        "context.registers.presentation",
        "context.registers_before",
        "context.registers_before.dynamic",
        "context.registers_before.static",
        "context.registers_before.presentation",
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
        "context.events",
        "context.heap",
        "context.warnings",
    }

    for _, name in ipairs(expected) do
        local phase =
            snapshot.phases[name]

        assert(
            type(phase) == "table"
                and phase.count == 1
                and type(
                    phase.average_ms
                ) == "number",
            "missing context profile phase: "
                .. tostring(name)
        )
    end

    print(
        "PASS ASM context profile: "
            .. "all nested context phases recorded"
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
        type(scope_nodes) == "table"
            and scope_nodes.total > 0
            and type(scope_checks) == "table"
            and scope_checks.total > 0,
        "shared scope-member discovery work counters missing"
    )

    assert(
        snapshot.counters[
            "context.scope_members_all.nodes_visited"
        ] == nil
            and snapshot.counters[
                "context.scope_members_all.spec_checks"
            ] == nil,
        "all-members view unexpectedly repeated scope-member discovery"
    )

    print(
        "PASS ASM context profile: "
            .. "shared scope-member discovery traverses once for current/all views"
    )

    local report =
        table.concat(
            profile.format_report(),
            "\n"
        )

    assert(
        report:find(
            "context%.registers:"
        )
            and report:find(
                "context%.registers%.dynamic%.process:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.parse:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.apply:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.apply%.match:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.apply%.build:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.apply%.build%.metadata%.source_build:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.apply%.build%.resolve_value:"
            )
            and report:find(
                "context%.registers%.dynamic%.process%.apply%.build%.alias_compose:"
            )
            and report:find(
                "context%.registers_before%.dynamic:"
            )
            and report:find(
                "context%.registers_before%.static:"
            )
            and report:find(
                "context%.registers_before%.presentation:"
            )
            and report:find(
                "context%.stack:"
            )
            and report:find(
                "context%.stack%.dynamic%.nodes:"
            )
            and report:find(
                "context%.stack%.dynamic%.timeline_lookup:"
            )
            and report:find(
                "context%.boundary%.nodes:"
            )
            and report:find(
                "context%.boundary%.read_context:"
            )
            and report:find(
                "context%.instruction_events%.nodes:"
            )
            and report:find(
                "context%.instruction_events%.parse:"
            )
            and report:find(
                "context%.source_memory%.collect%.evaluate:"
            )
            and report:find(
                "context%.source_memory%.collect%.evaluate%.register_replay:"
            )
            and report:find(
                "context%.source_memory%.collect%.evaluate%.timeline_lookup:"
            )
            and report:find(
                "context%.source_memory%.collect%.evaluate%.effective_address:"
            )
            and report:find(
                "context%.source_memory%.source_members:"
            )
            and report:find(
                "top=%["
            ),
        "nested context phases missing from report"
    )

    assert(
        snapshot.phases[
            "context.registers_before.dynamic.process"
        ] == nil,
        "Registers-before unexpectedly restored an independent replay phase"
    )

    assert(
        snapshot.phases[
            "context.source_memory.collect.evaluate.register_replay.parse"
        ] == nil
            and snapshot.phases[
                "context.source_memory.collect.evaluate.register_replay.apply"
            ] == nil,
        "Source Memory unexpectedly restored independent register reduction phases"
    )

    assert(
        snapshot.phases[
            "context.stack.dynamic.apply_register"
        ] == nil,
        "Stack unexpectedly restored local register-effect application"
    )

    assert(
        snapshot.counters[
            "context.stack.dynamic.timeline_hits"
        ]
            and snapshot.counters[
                "context.stack.dynamic.timeline_hits"
            ].total > 0,
        "Stack timeline-hit counter missing"
    )

    assert(
        snapshot.counters[
            "context.stack.dynamic.timeline_fallbacks"
        ] == nil,
        "Stack unexpectedly fell back from Register timeline coverage"
    )

    assert(
        snapshot.counters[
            "context.source_memory.collect.evaluate.timeline_hits"
        ]
            and snapshot.counters[
                "context.source_memory.collect.evaluate.timeline_hits"
            ].total > 0,
        "Source Memory timeline-hit counter missing"
    )

    assert(
        snapshot.counters[
            "context.source_memory.collect.evaluate.register_replay.processed_entries"
        ] == nil,
        "Source Memory unexpectedly replayed register history"
    )

    assert(
        snapshot.counters[
            "context.source_memory.collect.evaluate.timeline_fallbacks"
        ] == nil,
        "Source Memory unexpectedly fell back from timeline coverage"
    )

    print(
        "PASS ASM context profile: "
            .. "nested phases appear in report"
    )

    print(
        "PASS ASM context profile: "
            .. "Source Memory uses timeline lookup without replay reduction"
    )

    print(
        "PASS ASM context profile: "
            .. "Stack uses Register timeline without local register application"
    )

    print(
        "PASS ASM context profile: "
            .. "Registers-before reuses paired replay without process phase"
    )

    local cache_counters = {}

    local function cache_counter(
        name,
        delta
    )
        cache_counters[name] =
            (cache_counters[name] or 0)
            + (delta or 1)
    end

    local cache_opts = {
        reuse_unchanged_source = true,
        profile_prefix =
            "cache_probe",
        profile_counter =
            cache_counter,
    }

    local reused_discovery =
        scope_collector.discover(
            buffer,
            root,
            adapter,
            cache_opts
        )

    assert(
        cache_counters[
            "cache_probe.cross_refresh_reuse_applied"
        ] == 1
            and cache_counters[
                "cache_probe.nodes_visited"
            ] == nil
            and member_ids(
                scope_collector.select(
                    reused_discovery,
                    {}
                )
            ) == member_ids(
                context.all_scope_members
            ),
        "unchanged source did not reuse immutable Scope Member discovery"
    )

    print(
        "PASS ASM context profile: "
            .. "unchanged source reuses immutable Scope Member discovery"
    )

    local first_line =
        vim.api.nvim_buf_get_lines(
            buffer,
            0,
            1,
            false
        )[1]

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        1,
        false,
        {
            first_line .. " ",
        }
    )

    local edited_tree =
        parser:parse()[1]

    assert(
        edited_tree,
        "ASM parser yielded no tree after cache invalidation edit"
    )

    cache_counters = {}

    local edited_discovery =
        scope_collector.discover(
            buffer,
            edited_tree:root(),
            adapter,
            cache_opts
        )

    assert(
        cache_counters[
            "cache_probe.cross_refresh_reuse_miss"
        ] == 1
            and cache_counters[
                "cache_probe.nodes_visited"
            ] > 0
            and member_ids(
                scope_collector.select(
                    edited_discovery,
                    {}
                )
            ) == member_ids(
                context.all_scope_members
            ),
        "buffer edit did not invalidate Scope Member discovery"
    )

    print(
        "PASS ASM context profile: "
            .. "buffer edit invalidates persistent Scope Member discovery"
    )

    local original_scope_members =
        adapter.scope_members

    adapter.scope_members =
        vim.deepcopy(
            original_scope_members
        )

    cache_counters = {}

    local identity_discovery =
        scope_collector.discover(
            buffer,
            edited_tree:root(),
            adapter,
            cache_opts
        )

    adapter.scope_members =
        original_scope_members

    assert(
        cache_counters[
            "cache_probe.cross_refresh_reuse_miss"
        ] == 1
            and cache_counters[
                "cache_probe.nodes_visited"
            ] > 0
            and member_ids(
                scope_collector.select(
                    identity_discovery,
                    {}
                )
            ) == member_ids(
                context.all_scope_members
            ),
        "scope-member spec identity change did not invalidate discovery"
    )

    print(
        "PASS ASM context profile: "
            .. "scope-member spec identity invalidates persistent discovery"
    )

    local helper_one_line = nil
    local helper_two_line = nil

    for line_number, line in ipairs(
        source
    ) do
        if line == "helper_one:" then
            helper_one_line =
                line_number
        elseif line == "helper_two:" then
            helper_two_line =
                line_number
        end
    end

    assert(
        helper_one_line
            and helper_two_line,
        "ASM range-scope cache fixture labels changed"
    )

    local context_module =
        require("tracker_hud.context")
    local range_cache_config = {}

    local function profiled_context_at(
        line_number
    )
        vim.api.nvim_win_set_cursor(
            0,
            {
                line_number,
                0,
            }
        )

        profile.reset()

        local refresh_token =
            profile.begin_refresh(
                "CursorMoved",
                buffer,
                {
                    line_number,
                    0,
                }
            )

        assert(
            refresh_token,
            "range-scope cache probe could not start profile refresh"
        )

        local current_context =
            context_module
                .get_cursor_context(
                    buffer,
                    range_cache_config,
                    {
                        profile_token =
                            refresh_token,
                    }
                )

        profile.finish_refresh(
            refresh_token,
            {
                updated = true,
            }
        )

        return current_context,
            profile.snapshot()
    end

    local edited_range_context,
        edited_range_snapshot =
        profiled_context_at(
            helper_one_line + 1
        )

    assert(
        edited_range_snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_miss"
        ]
            and edited_range_snapshot.counters[
                "context.scopes.range_scope_cross_refresh_reuse_miss"
            ].total == 1
            and edited_range_snapshot.counters[
                "context.scopes.range_scope_nodes_visited"
            ]
            and edited_range_snapshot.counters[
                "context.scopes.range_scope_nodes_visited"
            ].total > 0
            and edited_range_context.member_scope
            and edited_range_context.member_scope
                .raw_label
                == "Label helper_one",
        "buffer edit did not invalidate Range Scope discovery"
    )

    print(
        "PASS ASM context profile: "
            .. "buffer edit invalidates persistent Range Scope discovery"
    )

    local reused_range_context,
        reused_range_snapshot =
        profiled_context_at(
            helper_two_line + 1
        )

    assert(
        reused_range_snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_applied"
        ]
            and reused_range_snapshot.counters[
                "context.scopes.range_scope_cross_refresh_reuse_applied"
            ].total == 1
            and reused_range_snapshot.counters[
                "context.scopes.range_scope_nodes_visited"
            ] == nil
            and reused_range_context.member_scope
            and reused_range_context.member_scope
                .raw_label
                == "Label helper_two",
        "unchanged source did not reuse Range Scope discovery with fresh cursor selection"
    )

    print(
        "PASS ASM context profile: "
            .. "unchanged source reuses immutable Range Scope discovery "
            .. "with fresh cursor selection"
    )

    local original_range_scopes =
        adapter.range_scopes

    adapter.range_scopes =
        vim.deepcopy(
            original_range_scopes
        )

    local identity_range_context,
        identity_range_snapshot =
        profiled_context_at(
            helper_one_line + 1
        )

    adapter.range_scopes =
        original_range_scopes

    assert(
        identity_range_snapshot.counters[
            "context.scopes.range_scope_cross_refresh_reuse_miss"
        ]
            and identity_range_snapshot.counters[
                "context.scopes.range_scope_cross_refresh_reuse_miss"
            ].total == 1
            and identity_range_snapshot.counters[
                "context.scopes.range_scope_nodes_visited"
            ]
            and identity_range_snapshot.counters[
                "context.scopes.range_scope_nodes_visited"
            ].total > 0
            and identity_range_context.member_scope
            and identity_range_context.member_scope
                .raw_label
                == "Label helper_one",
        "range-scope spec identity change did not invalidate discovery"
    )

    print(
        "PASS ASM context profile: "
            .. "range-scope spec identity invalidates persistent discovery"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "context-profile subphase smoke"
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM context-profile subphase smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
