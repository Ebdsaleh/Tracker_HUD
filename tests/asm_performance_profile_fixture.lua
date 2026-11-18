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
        "context.scope_members.nodes_visited",
        "context.scope_members.spec_checks",
        "context.scope_members.members_emitted",
        "context.scope_members_all.nodes_visited",
        "context.scope_members_all.spec_checks",
        "context.scope_members_all.members_emitted",
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

    local current_scope_nodes =
        snapshot.counters[
            "context.scope_members.nodes_visited"
        ]

    local all_scope_nodes =
        snapshot.counters[
            "context.scope_members_all.nodes_visited"
        ]

    local current_scope_checks =
        snapshot.counters[
            "context.scope_members.spec_checks"
        ]

    local all_scope_checks =
        snapshot.counters[
            "context.scope_members_all.spec_checks"
        ]

    assert(
        current_scope_nodes.total
            == all_scope_nodes.total,
        "scope-member current/all collections no longer traverse the same tree volume"
    )

    assert(
        current_scope_checks.total
            == all_scope_checks.total,
        "scope-member current/all collections no longer execute the same spec-check volume"
    )

    print(
        "[Tracker_HUD] Scope-member duplicate traversal: "
            .. tostring(
                current_scope_nodes.total
            )
            .. " nodes + "
            .. tostring(
                current_scope_checks.total
            )
            .. " spec checks repeated by current/all collections"
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
