-- tests/adapter_target_dimension_default_integrity_smoke.lua
--
-- A descriptor's default is metadata, not a user-requested token.
-- Registration requires the exact spelling of one supported canonical value.
-- Direct resolution must fail closed on any invalid default, including when
-- the caller requests a different, otherwise valid canonical name or alias.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local targets =
        require("tracker_hud.adapters.target_dimensions")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local function descriptor(default)
        return {
            default = default,
            supported = { "v1", "v2", "v3" },
            aliases = {
                latest = "v3",
            },
        }
    end

    local good = descriptor("v2")
    local valid_probe = vim.deepcopy(cpp)
    valid_probe.target_dimensions.edition =
        vim.deepcopy(good)

    local registered, register_err =
        contract.validate_adapter(valid_probe)

    assert(
        registered == true
            and register_err == nil,
        "valid canonical default rejected: "
            .. tostring(register_err)
    )

    for _, case in ipairs({
        { requested = nil, canonical = "v2" },
        { requested = " V1 ", canonical = "v1" },
        { requested = "LATEST", canonical = "v3" },
    }) do
        local value, err =
            targets.resolve_value(good, case.requested)

        assert(
            value == case.canonical
                and err == nil,
            "valid descriptor changed: "
                .. tostring(case.requested)
                .. " => "
                .. tostring(value)
                .. " / "
                .. tostring(err)
        )
    end

    print(
        "PASS exact canonical defaults preserve normalized user requests and aliases"
    )

    local invalid = {
        {
            label = "case-folded default",
            value = "V2",
        },
        {
            label = "padded default",
            value = " v2 ",
        },
        {
            label = "alias name used as default",
            value = "latest",
        },
        {
            label = "unsupported default",
            value = "v9",
        },
        {
            label = "non-string default",
            value = 2,
        },
        {
            label = "whitespace-only default",
            value = "  ",
        },
    }

    for _, case in ipairs(invalid) do
        local bad = descriptor(case.value)
        local candidate = vim.deepcopy(cpp)
        candidate.target_dimensions.edition =
            vim.deepcopy(bad)

        local ok, err =
            contract.validate_adapter(candidate)

        assert(
            ok == false
                and type(err) == "string"
                and err:find(
                    "target_dimensions",
                    1,
                    true
                ),
            "registration accepted "
                .. case.label
                .. ": "
                .. tostring(err)
        )

        local default_value, default_err =
            targets.resolve_value(bad, nil)

        assert(
            default_value == nil
                and type(default_err) == "string"
                and #default_err > 0,
            "direct default resolution accepted "
                .. case.label
                .. ": "
                .. tostring(default_value)
        )

        -- Even an explicit valid request must not bypass a malformed default.
        for _, requested in ipairs({
            "v1",
            "LATEST",
        }) do
            local value, resolve_err =
                targets.resolve_value(bad, requested)

            assert(
                value == nil
                    and type(resolve_err) == "string"
                    and #resolve_err > 0,
                "explicit resolution bypassed "
                    .. case.label
                    .. " with "
                    .. requested
                    .. ": "
                    .. tostring(value)
                    .. " / "
                    .. tostring(resolve_err)
            )
        end
    end

    assert(
        good.default == "v2"
            and good.supported[2] == "v2"
            and good.aliases.latest == "v3"
            and cpp.target_dimensions.edition == nil,
        "default-integrity test mutated adapter-owned metadata"
    )

    print(
        "PASS invalid declared defaults fail closed for default, canonical, and alias requests"
    )
    print(
        "PASS default integrity preserves adapter-owned metadata"
    )
    print(
        "PASS Tracker_HUD target default-integrity smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD target default-integrity smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
