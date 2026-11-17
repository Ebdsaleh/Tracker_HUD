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

    local snapshot =
        profile.snapshot()

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
        "context.stack.dynamic.apply_register",
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
                "context%.stack%.dynamic%.apply_register:"
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
            .. "Registers-before reuses paired replay without process phase"
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
