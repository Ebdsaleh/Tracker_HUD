-- tests/cpp_standard_directive_resolution_smoke.lua
--
-- C++ standard target selection through the existing strict source/config
-- target-directive path.
--
-- This checkpoint resolves one declared semantic dimension only. It does not
-- filter C++ semantic specs or change configured-adapter cache identity.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry =
        require("tracker_hud.adapters.registry")
    local c =
        require("tracker_hud.adapters.c.init")
    local cpp =
        require("tracker_hud.adapters.cpp.init")

    registry.clear()
    assert(
        registry.register(c),
        "C adapter registration failed"
    )
    assert(
        registry.register(cpp),
        "C++ adapter registration failed"
    )

    local function buffer(ft, lines)
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
            lines
        )

        vim.bo[bufnr].filetype = ft

        return bufnr
    end

    local function configured(
        ft,
        lines,
        config
    )
        local bufnr =
            buffer(ft, lines)

        local ok, err =
            registry.configure_adapter_for_buffer(
                ft,
                bufnr,
                config or {}
            )

        assert(
            ok,
            ft
                .. " configure failed: "
                .. tostring(err)
        )

        local targets =
            vim.deepcopy(
                registry.get_adapter(ft)
                    .active_targets
            )

        vim.api.nvim_buf_delete(
            bufnr,
            { force = true }
        )

        return targets
    end

    assert(
        cpp.target_directives.standard
            == "standard",
        "C++ adapter must advertise standard source directive"
    )

    assert(
        c.target_directives.standard == nil,
        "C adapter must not advertise C++ standard source directive"
    )

    local defaults =
        configured(
            "cpp",
            {
                "// ordinary C++ source",
                "int value = 0;",
            }
        )

    assert(
        defaults.standard == "cpp17",
        "C++ no-directive default must resolve to cpp17"
    )

    assert(
        defaults.syntax == "cpp",
        "C++ standard selection must not alter parser syntax identity"
    )

    assert(
        #defaults.diagnostics == 0,
        "C++ default standard emitted diagnostics"
    )

    local config_alias =
        configured(
            "cpp",
            {
                "int value = 0;",
            },
            {
                targets = {
                    standard = " C++20 ",
                },
            }
        )

    assert(
        config_alias.standard == "cpp20",
        "C++ config standard alias did not normalize"
    )

    local source_override =
        configured(
            "cpp",
            {
                "// standard=98;",
                "int value = 0;",
            },
            {
                targets = {
                    standard = "cpp20",
                },
            }
        )

    assert(
        source_override.standard == "cpp98",
        "C++ source standard must override config and normalize alias"
    )

    assert(
        #source_override.diagnostics == 0,
        "valid C++ standard source directive warned"
    )

    local unsupported =
        configured(
            "cpp",
            {
                "// standard=cpp26;",
                "int value = 0;",
            }
        )

    assert(
        unsupported.standard == "cpp17",
        "unsupported C++ standard must not become active"
    )

    assert(
        #unsupported.diagnostics == 1
            and unsupported.diagnostics[1].key
                == "standard"
            and unsupported.diagnostics[1].value
                == "cpp26"
            and unsupported.diagnostics[1].line
                == 1
            and tostring(
                unsupported.diagnostics[1]
                    .message
            ):find(
                "unsupported",
                1,
                true
            ),
        "unsupported C++ standard needs source diagnostic"
    )

    local malformed =
        configured(
            "cpp",
            {
                "// standard =cpp20;",
                "int value = 0;",
            }
        )

    assert(
        malformed.standard == "cpp17",
        "malformed C++ standard directive must not set target"
    )

    assert(
        #malformed.diagnostics >= 1
            and malformed.diagnostics[1].key
                == "standard",
        "malformed C++ standard directive needs strict scanner diagnostic"
    )

    local c_isolated =
        configured(
            "c",
            {
                "// standard=cpp20;",
                "int value = 0;",
            },
            {
                targets = {
                    standard = "cpp20",
                },
            }
        )

    assert(
        c_isolated.standard == nil,
        "C adapter must ignore C++ standard source/config selector"
    )

    assert(
        c.target_directives.standard == nil,
        "configuring C++ standard selector contaminated C adapter"
    )

    print(
        "PASS C++ standard resolution: cpp17 default + config/source precedence"
    )
    print(
        "PASS C++ standard aliases + unsupported/malformed diagnostics"
    )
    print(
        "PASS C++ standard directive remains isolated from C and parser syntax"
    )
    print(
        "PASS Tracker_HUD C++ standard directive resolution smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ standard directive resolution smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
