-- tests/asm_context_configure_profile_smoke.lua
-- nvim --headless -c "luafile tests/asm_context_configure_profile_smoke.lua" -c "qa!"

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

    local registry =
        require(
            "tracker_hud.adapters.registry"
        )

    local adapter =
        require(
            "tracker_hud.adapters.asm.init"
        )

    registry.clear()

    assert(
        registry.register(adapter)
    )

    local profile =
        require(
            "tracker_hud.analysis_profile"
        )

    profile.configure({
        enabled = true,
        max_samples = 8,
        large_jump_lines = 50,
    })

    local config = {}

    local first =
        profile.begin_refresh(
            "CursorMoved",
            buffer,
            { 103, 0 }
        )

    local first_context =
        require("tracker_hud.context")
            .get_cursor_context(
                buffer,
                config,
                {
                    profile_token = first,
                }
            )

    assert(
        type(first_context) == "table"
            and type(first_context.registers)
                == "table",
        "initial profiled context collection failed"
    )

    profile.finish_refresh(
        first,
        {
            updated = true,
        }
    )

    local first_targets =
        adapter.active_targets

    local second =
        profile.begin_refresh(
            "CursorMoved",
            buffer,
            { 103, 0 }
        )

    local second_context =
        require("tracker_hud.context")
            .get_cursor_context(
                buffer,
                config,
                {
                    profile_token = second,
                }
            )

    assert(
        type(second_context) == "table"
            and type(second_context.registers)
                == "table",
        "cached profiled context collection failed"
    )

    profile.finish_refresh(
        second,
        {
            updated = true,
        }
    )

    assert(
        adapter.active_targets
            == first_targets,
        "stable context refresh did not reuse configured ASM target state"
    )

    local snapshot =
        profile.snapshot()

    local always = {
        "context.configure",
        "context.configure.lookup",
        "context.configure.changedtick",
        "context.configure.cache_check",
    }

    for _, name in ipairs(always) do
        local phase =
            snapshot.phases[name]

        assert(
            type(phase) == "table"
                and phase.count == 2,
            "configure profile phase should run twice: "
                .. tostring(name)
        )
    end

    local misses_only = {
        "context.configure.adapter",
        "context.configure.validate",
        "context.configure.remember",
    }

    for _, name in ipairs(misses_only) do
        local phase =
            snapshot.phases[name]

        assert(
            type(phase) == "table"
                and phase.count == 1,
            "cache-miss-only configure phase should run once: "
                .. tostring(name)
        )
    end

    assert(
        second.phases[
            "context.configure.adapter"
        ] == nil
            and second.phases[
                "context.configure.validate"
            ] == nil
            and second.phases[
                "context.configure.remember"
            ] == nil,
        "cache-hit refresh performed miss-only configuration work"
    )

    print(
        "PASS ASM configure profile: "
            .. "lookup/changedtick/cache check recorded on every refresh"
    )

    print(
        "PASS ASM configure profile: "
            .. "adapter/validation/remember run only on cache miss"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "configure-profile instrumentation smoke"
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM configure-profile instrumentation smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
