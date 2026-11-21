-- tests/adapter_target_dimension_normalized_uniqueness_smoke.lua
--
-- Target values and aliases are resolved case-insensitively by the shared
-- adapter framework. Ambiguous case-folded names must be rejected at
-- registration and when unvalidated descriptors reach the pure resolver.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local target_dimensions =
        require("tracker_hud.adapters.target_dimensions")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local good = {
        default = "v2",
        supported = {
            "v1",
            "v2",
            "v3",
        },
        aliases = {
            latest = "v3",
            legacy = "v1",
        },
    }

    local candidate = vim.deepcopy(cpp)
    candidate.target_dimensions.edition =
        vim.deepcopy(good)

    local registered, register_err =
        contract.validate_adapter(candidate)

    assert(
        registered and register_err == nil,
        "valid adapter-owned edition was rejected: "
            .. tostring(register_err)
    )

    for _, lookup in ipairs({
        {
            requested = " V2 ",
            expected = "v2",
        },
        {
            requested = "LATEST",
            expected = "v3",
        },
        {
            requested = "legacy",
            expected = "v1",
        },
    }) do
        local value, err =
            target_dimensions.resolve_value(
                good,
                lookup.requested
            )

        assert(
            value == lookup.expected
                and err == nil,
            "valid case-insensitive resolution changed: "
                .. tostring(lookup.requested)
                .. " => "
                .. tostring(value)
                .. " / "
                .. tostring(err)
        )
    end

    print(
        "PASS valid adapter-owned canonical and alias names resolve case-insensitively"
    )

    local invalid = {
        {
            label = "canonical values differing only by case",
            descriptor = {
                default = "v1",
                supported = {
                    "v1",
                    "V1",
                    "v2",
                },
            },
        },
        {
            label = "alias shadows a canonical value",
            descriptor = {
                default = "v2",
                supported = {
                    "v1",
                    "v2",
                },
                aliases = {
                    V2 = "v1",
                },
            },
        },
        {
            label = "aliases differing only by case",
            descriptor = {
                default = "v2",
                supported = {
                    "v1",
                    "v2",
                },
                aliases = {
                    Latest = "v1",
                    latest = "v2",
                },
            },
        },
    }

    for _, case in ipairs(invalid) do
        local probe = vim.deepcopy(cpp)
        probe.target_dimensions.edition =
            vim.deepcopy(case.descriptor)

        local ok, err =
            contract.validate_adapter(probe)

        assert(
            ok == false
                and tostring(err):find(
                    "target_dimensions",
                    1,
                    true
                ),
            "registration accepted "
                .. case.label
                .. ": "
                .. tostring(err)
        )

        local value, resolve_err =
            target_dimensions.resolve_value(
                case.descriptor,
                "v2"
            )

        assert(
            value == nil
                and type(resolve_err) == "string"
                and #resolve_err > 0,
            "pure resolver accepted "
                .. case.label
                .. ": "
                .. tostring(value)
                .. " / "
                .. tostring(resolve_err)
        )
    end

    assert(
        good.default == "v2"
            and good.aliases.latest == "v3"
            and cpp.target_dimensions.edition == nil,
        "normalized collision checks mutated adapter-owned metadata"
    )

    print(
        "PASS registration and pure resolution reject ambiguous normalized target names"
    )
    print(
        "PASS target-dimension collision checks preserve adapter ownership"
    )
    print(
        "PASS Tracker_HUD normalized target-name uniqueness smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD normalized target-name uniqueness smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
