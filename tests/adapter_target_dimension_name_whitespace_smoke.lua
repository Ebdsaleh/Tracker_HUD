-- tests/adapter_target_dimension_name_whitespace_smoke.lua
--
-- User-supplied target requests are trimmed and case-folded. Descriptor-owned
-- canonical names and alias keys must therefore not contain boundary
-- whitespace; otherwise they can be registered but cannot be requested.
-- Internal spaces remain valid, meaningful names.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local target_dimensions =
        require("tracker_hud.adapters.target_dimensions")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local function descriptor(supported, aliases, default)
        return {
            default = default or "v1",
            supported = supported or {
                "v1",
                "v2",
                "v3",
            },
            aliases = aliases or {
                latest = "v3",
            },
        }
    end

    local good = descriptor(
        { "v1", "wide mode", "v3" },
        {
            ["legacy mode"] = "v1",
            latest = "wide mode",
        },
        "wide mode"
    )

    local valid_adapter = vim.deepcopy(cpp)
    valid_adapter.target_dimensions.edition =
        vim.deepcopy(good)

    local valid, valid_err =
        contract.validate_adapter(valid_adapter)

    assert(
        valid == true and valid_err == nil,
        "valid names with internal spaces were rejected: "
            .. tostring(valid_err)
    )

    local default_value, default_err =
        target_dimensions.resolve_value(good, nil)

    assert(
        default_value == "wide mode"
            and default_err == nil,
        "valid internal-space default changed"
    )

    for _, case in ipairs({
        {
            requested = " WIDE MODE ",
            canonical = "wide mode",
        },
        {
            requested = " LEGACY MODE ",
            canonical = "v1",
        },
        {
            requested = "LATEST",
            canonical = "wide mode",
        },
    }) do
        local value, err =
            target_dimensions.resolve_value(
                good,
                case.requested
            )

        assert(
            value == case.canonical
                and err == nil,
            "valid internal-space target failed: "
                .. tostring(case.requested)
                .. " => "
                .. tostring(value)
                .. " / "
                .. tostring(err)
        )
    end

    print(
        "PASS meaningful internal spaces and normalized user requests remain supported"
    )

    local invalid = {
        {
            label = "leading canonical whitespace",
            value = descriptor({
                "v1", " v2", "v3",
            }),
        },
        {
            label = "trailing canonical whitespace",
            value = descriptor({
                "v1", "v2 ", "v3",
            }),
        },
        {
            label = "whitespace-only canonical name",
            value = descriptor({
                "v1", "   ", "v3",
            }),
        },
        {
            label = "padded alias key",
            value = descriptor(nil, {
                [" latest "] = "v3",
            }),
        },
        {
            label = "whitespace-only alias key",
            value = descriptor(nil, {
                ["  "] = "v3",
            }),
        },
        {
            label = "aliases collide after request trimming",
            value = descriptor(nil, {
                latest = "v3",
                [" latest "] = "v2",
            }),
        },
        {
            label = "default exactly names padded canonical",
            value = descriptor(
                { "v1", " v2 ", "v3" },
                nil,
                " v2 "
            ),
        },
    }

    for _, case in ipairs(invalid) do
        local bad = case.value
        local candidate = vim.deepcopy(cpp)
        candidate.target_dimensions.edition =
            vim.deepcopy(bad)

        local registered, registration_err =
            contract.validate_adapter(candidate)

        assert(
            registered == false
                and type(registration_err) == "string"
                and registration_err:find(
                    "target_dimensions",
                    1,
                    true
                ),
            "registration accepted "
                .. case.label
                .. ": "
                .. tostring(registration_err)
        )

        -- Every invalid descriptor must reject even the valid canonical,
        -- its default, and any unrelated alias. Never partly activate it.
        local value, resolve_err =
            target_dimensions.resolve_value(bad, "v1")

        assert(
            value == nil
                and type(resolve_err) == "string"
                and #resolve_err > 0,
            "direct resolution accepted "
                .. case.label
                .. " for v1: "
                .. tostring(value)
                .. " / "
                .. tostring(resolve_err)
        )

        local default_result, default_error =
            target_dimensions.resolve_value(bad, nil)

        assert(
            default_result == nil
                and type(default_error) == "string"
                and #default_error > 0,
            "default resolution accepted "
                .. case.label
        )
    end

    assert(
        good.supported[2] == "wide mode"
            and good.aliases["legacy mode"] == "v1"
            and cpp.target_dimensions.edition == nil,
        "target name validation mutated adapter-owned metadata"
    )

    print(
        "PASS boundary-whitespace canonical names and aliases fail closed"
    )
    print(
        "PASS invalid target names cannot activate unrelated defaults or requests"
    )
    print(
        "PASS Tracker_HUD target name whitespace smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD target name whitespace smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
