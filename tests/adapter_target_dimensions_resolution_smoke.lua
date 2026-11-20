-- tests/adapter_target_dimensions_resolution_smoke.lua
--
-- Pure target-dimension value resolution.
--
-- This checkpoint does not yet wire source directives, C++ standards,
-- configured-adapter cache identity, or semantic availability filtering.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local target_dimensions =
        require(
            "tracker_hud.adapters.target_dimensions"
        )

    local standard = {
        default = "cpp17",
        supported = {
            "cpp98",
            "cpp03",
            "cpp11",
            "cpp14",
            "cpp17",
            "cpp20",
            "cpp23",
        },
        aliases = {
            ["c++17"] = "cpp17",
            ["17"] = "cpp17",
        },
    }

    local function expect(
        requested,
        expected,
        label
    )
        local resolved, err =
            target_dimensions.resolve_value(
                standard,
                requested
            )

        assert(
            resolved == expected,
            label
                .. " resolved to "
                .. tostring(resolved)
                .. " instead of "
                .. tostring(expected)
                .. ": "
                .. tostring(err)
        )
    end

    expect(
        nil,
        "cpp17",
        "default"
    )

    expect(
        "cpp98",
        "cpp98",
        "canonical value"
    )

    expect(
        " CPP17 ",
        "cpp17",
        "canonical case/whitespace normalization"
    )

    expect(
        " C++17 ",
        "cpp17",
        "alias case/whitespace normalization"
    )

    expect(
        "17",
        "cpp17",
        "numeric-looking alias"
    )

    print(
        "PASS target dimension resolution normalizes defaults/canonical values/aliases"
    )

    local version = {
        default = "v1",
        supported = {
            "v1",
            "v2",
        },
        aliases = {
            latest = "v2",
        },
    }

    local version_resolved,
        version_err =
        target_dimensions.resolve_value(
            version,
            "LATEST"
        )

    assert(
        version_resolved == "v2",
        "adapter-owned version dimension did not use generic resolver: "
            .. tostring(version_err)
    )

    print(
        "PASS target dimension resolver is vocabulary-neutral"
    )

    local unsupported,
        unsupported_err =
        target_dimensions.resolve_value(
            standard,
            "cpp26"
        )

    assert(
        unsupported == nil
            and tostring(
                unsupported_err
            ):find(
                "cpp26",
                1,
                true
            )
            and tostring(
                unsupported_err
            ):find(
                "unsupported",
                1,
                true
            ),
        "unsupported dimension value did not fail closed: "
            .. tostring(unsupported)
            .. " / "
            .. tostring(unsupported_err)
    )

    local blank,
        blank_err =
        target_dimensions.resolve_value(
            standard,
            "   "
        )

    assert(
        blank == nil
            and tostring(
                blank_err
            ):find(
                "non-empty",
                1,
                true
            ),
        "blank requested dimension value did not fail closed: "
            .. tostring(blank)
            .. " / "
            .. tostring(blank_err)
    )

    print(
        "PASS target dimension resolver rejects unsupported/blank requested values"
    )
    print(
        "PASS Tracker_HUD target-dimension value resolution smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD target-dimension value resolution smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
