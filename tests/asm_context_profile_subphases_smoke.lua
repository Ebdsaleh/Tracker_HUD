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
        "context.registers_before",
        "context.stack",
        "context.boundary",
        "context.instruction_events",
        "context.source_memory",
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
                "context%.stack:"
            )
            and report:find(
                "top=%["
            ),
        "nested context phases missing from report"
    )

    print(
        "PASS ASM context profile: "
            .. "nested phases appear in report"
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
