-- tests/adapter_availability_resolution_smoke.lua
--
-- Pure semantic availability resolver over adapter-owned ordered target
-- dimensions. This checkpoint does not filter real adapter declarations.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local availability =
        require("tracker_hud.adapters.availability")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local standard =
        cpp.target_dimensions.standard

    local function expect(
        declaration,
        selected,
        expected,
        label
    )
        local available, err =
            availability.is_available(
                declaration,
                {
                    language = "cpp",
                    descriptor = standard,
                    selected = selected,
                }
            )

        assert(
            err == nil,
            label
                .. " returned error: "
                .. tostring(err)
        )

        assert(
            available == expected,
            label
                .. " expected "
                .. tostring(expected)
                .. " got "
                .. tostring(available)
        )
    end

    expect(
        nil,
        "cpp98",
        true,
        "nil availability"
    )

    local since_cpp11 = {
        language = "cpp",
        since = "cpp11",
    }

    expect(
        since_cpp11,
        "cpp98",
        false,
        "since lower miss"
    )
    expect(
        since_cpp11,
        "cpp11",
        true,
        "since inclusive boundary"
    )
    expect(
        since_cpp11,
        "cpp17",
        true,
        "since later standard"
    )
    expect(
        since_cpp11,
        " C++20 ",
        true,
        "since selected alias"
    )

    local until_cpp17 = {
        language = "cpp",
        ["until"] = "cpp17",
    }

    expect(
        until_cpp17,
        "cpp03",
        true,
        "until earlier standard"
    )
    expect(
        until_cpp17,
        "cpp17",
        true,
        "until inclusive boundary"
    )
    expect(
        until_cpp17,
        "cpp20",
        false,
        "until later miss"
    )

    local bounded = {
        language = "cpp",
        since = "cpp11",
        ["until"] = "cpp17",
    }

    expect(
        bounded,
        "cpp03",
        false,
        "bounded below"
    )
    expect(
        bounded,
        "cpp11",
        true,
        "bounded lower boundary"
    )
    expect(
        bounded,
        "cpp17",
        true,
        "bounded upper boundary"
    )
    expect(
        bounded,
        "cpp20",
        false,
        "bounded above"
    )

    local explicit = {
        language = "cpp",
        standards = {
            "cpp98",
            "c++03",
        },
    }

    expect(
        explicit,
        "cpp98",
        true,
        "explicit first"
    )
    expect(
        explicit,
        "cpp03",
        true,
        "explicit alias declaration"
    )
    expect(
        explicit,
        "cpp11",
        false,
        "explicit exclusion"
    )

    print(
        "PASS availability resolver handles inclusive ranges + explicit standards"
    )

    local mismatch, mismatch_err =
        availability.is_available(
            since_cpp11,
            {
                language = "c",
                descriptor = standard,
                selected = "cpp17",
            }
        )

    assert(
        mismatch == false
            and mismatch_err == nil,
        "language mismatch must be unavailable without fabricating an error"
    )

    local synthetic = {
        default = "v2",
        supported = {
            "v1",
            "v2",
            "v3",
        },
        aliases = {
            latest = "v3",
        },
    }

    local synthetic_available,
        synthetic_err =
        availability.is_available(
            {
                language = "demo",
                since = "v2",
            },
            {
                language = "demo",
                descriptor = synthetic,
                selected = "latest",
            }
        )

    assert(
        synthetic_available == true
            and synthetic_err == nil,
        "availability resolver hard-coded C++ vocabulary"
    )

    print(
        "PASS availability resolver is language/vocabulary neutral"
    )

    local reversed,
        reversed_err =
        availability.is_available(
            {
                language = "cpp",
                since = "cpp20",
                ["until"] = "cpp17",
            },
            {
                language = "cpp",
                descriptor = standard,
                selected = "cpp17",
            }
        )

    assert(
        reversed == false
            and tostring(
                reversed_err
            ):find(
                "range",
                1,
                true
            ),
        "reversed availability range must fail closed"
    )

    local bad_boundary,
        bad_boundary_err =
        availability.is_available(
            {
                language = "cpp",
                since = "cpp26",
            },
            {
                language = "cpp",
                descriptor = standard,
                selected = "cpp17",
            }
        )

    assert(
        bad_boundary == false
            and bad_boundary_err ~= nil,
        "unsupported availability boundary must fail closed"
    )

    local bad_selected,
        bad_selected_err =
        availability.is_available(
            since_cpp11,
            {
                language = "cpp",
                descriptor = standard,
                selected = "cpp26",
            }
        )

    assert(
        bad_selected == false
            and bad_selected_err ~= nil,
        "unsupported selected target must fail closed"
    )

    print(
        "PASS availability resolver fails closed on invalid ranges/targets"
    )
    print(
        "PASS Tracker_HUD semantic availability resolution smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD semantic availability resolution smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
