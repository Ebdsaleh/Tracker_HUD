-- tests/adapter_target_dimension_cache_identity_smoke.lua
--
-- Semantic target dimensions must participate in configured-adapter cache
-- identity. Mutating a reused config table must not preserve stale semantic
-- state when the source buffer itself has not changed.
--
-- This checkpoint tests invalidation only. It does not yet filter semantic
-- declarations by selected standard.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry =
        require("tracker_hud.adapters.registry")
    local cpp =
        require("tracker_hud.adapters.cpp.init")

    registry.clear()

    assert(
        registry.register(cpp),
        "C++ adapter registration failed"
    )

    local bufnr =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.api.nvim_buf_set_lines(
        bufnr,
        0,
        -1,
        false,
        {
            "int value = 0;",
        }
    )

    vim.bo[bufnr].filetype = "cpp"

    local config = {
        targets = {
            standard = "cpp17",
        },
    }

    local ok, err =
        registry.configure_adapter_for_buffer(
            "cpp",
            bufnr,
            config
        )

    assert(
        ok,
        "initial C++ configure failed: "
            .. tostring(err)
    )

    assert(
        cpp.active_targets.standard
            == "cpp17",
        "initial C++ standard was not cpp17"
    )

    -- Reuse the exact same config table and unchanged source buffer. Only the
    -- semantic coordinate changes. A cache keyed solely by config-table
    -- identity will incorrectly skip reconfiguration here.
    config.targets.standard = "cpp20"

    ok, err =
        registry.configure_adapter_for_buffer(
            "cpp",
            bufnr,
            config
        )

    assert(
        ok,
        "mutated C++ standard configure failed: "
            .. tostring(err)
    )

    assert(
        cpp.active_targets.standard
            == "cpp20",
        "configured-adapter cache reused stale cpp17 state after cpp20 selection"
    )

    -- Prove backward selection invalidates as well as forward selection.
    config.targets.standard = "cpp98"

    ok, err =
        registry.configure_adapter_for_buffer(
            "cpp",
            bufnr,
            config
        )

    assert(
        ok,
        "backward C++ standard configure failed: "
            .. tostring(err)
    )

    assert(
        cpp.active_targets.standard
            == "cpp98",
        "configured-adapter cache reused newer standard state after cpp98 selection"
    )

    -- Alias spelling changes should still converge on the same canonical
    -- semantic coordinate.
    config.targets.standard = " C++17 "

    ok, err =
        registry.configure_adapter_for_buffer(
            "cpp",
            bufnr,
            config
        )

    assert(
        ok,
        "C++ standard alias configure failed: "
            .. tostring(err)
    )

    assert(
        cpp.active_targets.standard
            == "cpp17",
        "semantic cache identity did not normalize C++ standard alias"
    )

    vim.api.nvim_buf_delete(
        bufnr,
        { force = true }
    )

    print(
        "PASS configured-adapter cache invalidates on semantic dimension change"
    )
    print(
        "PASS C++ standard cache identity regresses/advances with canonical selection"
    )
    print(
        "PASS Tracker_HUD target-dimension cache identity smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD target-dimension cache identity smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
