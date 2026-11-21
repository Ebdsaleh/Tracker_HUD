-- tests/adapter_target_dimension_supported_list_shape_smoke.lua
--
-- A target descriptor's ordered supported values must be a dense list.
-- Extra named, zero-indexed, and sparse entries are ignored by ipairs()
-- and must not be silently accepted by registration or direct resolution.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local target_dimensions =
        require("tracker_hud.adapters.target_dimensions")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local function descriptor(values, default)
        return {
            default = default or "v2",
            supported = values,
            aliases = {
                current = default or "v2",
            },
        }
    end

    local good =
        descriptor({ "v1", "v2", "v3" })

    local valid_probe = vim.deepcopy(cpp)
    valid_probe.target_dimensions.edition =
        vim.deepcopy(good)

    local valid_registration, valid_err =
        contract.validate_adapter(valid_probe)

    assert(
        valid_registration == true
            and valid_err == nil,
        "registration rejected a valid dense supported list: "
            .. tostring(valid_err)
    )

    for _, requested in ipairs({
        "v2",
        "CURRENT",
    }) do
        local resolved, err =
            target_dimensions.resolve_value(
                good,
                requested
            )

        assert(
            resolved == "v2"
                and err == nil,
            "valid dense target resolution changed: "
                .. tostring(requested)
                .. " / "
                .. tostring(resolved)
                .. " / "
                .. tostring(err)
        )
    end

    local selected, selected_err =
        target_dimensions.resolve_value(
            good,
            nil
        )

    assert(
        selected == "v2"
            and selected_err == nil,
        "valid dense default target no longer resolves"
    )

    print(
        "PASS dense supported target lists retain registration, defaults, and aliases"
    )

    local invalid = {
        {
            label = "hidden named supported value",
            supported = {
                "v1",
                "v2",
                hidden = "v3",
            },
            default = "v2",
            request = "v2",
        },
        {
            label = "zero-indexed supported value",
            supported = {
                [0] = "v3",
                [1] = "v1",
                [2] = "v2",
            },
            default = "v2",
            request = "v2",
        },
        {
            label = "sparse supported value",
            supported = {
                [1] = "v1",
                [3] = "v3",
            },
            default = "v1",
            request = "v1",
        },
        {
            label = "fractional supported key",
            supported = {
                [1] = "v1",
                [2] = "v2",
                [2.5] = "v3",
            },
            default = "v2",
            request = "v2",
        },
    }

    for _, case in ipairs(invalid) do
        local dimension =
            descriptor(
                case.supported,
                case.default
            )

        local candidate = vim.deepcopy(cpp)
        candidate.target_dimensions.edition =
            vim.deepcopy(dimension)

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

        local resolved, resolve_err =
            target_dimensions.resolve_value(
                dimension,
                case.request
            )

        assert(
            resolved == nil
                and type(resolve_err) == "string"
                and #resolve_err > 0,
            "direct resolver accepted "
                .. case.label
                .. ": "
                .. tostring(resolved)
                .. " / "
                .. tostring(resolve_err)
        )
    end

    assert(
        good.supported[1] == "v1"
            and good.supported[3] == "v3"
            and good.aliases.current == "v2"
            and cpp.target_dimensions.edition == nil,
        "supported-list validation mutated adapter-owned metadata"
    )

    print(
        "PASS registration and direct resolution reject malformed supported-list shapes"
    )
    print(
        "PASS supported-list shape validation preserves adapter-owned metadata"
    )
    print(
        "PASS Tracker_HUD supported target-list shape smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD supported target-list shape smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
