-- tests/adapter_generic_availability_contract_smoke.lua
--
-- Adapter Contract v1: dimension-aware semantic availability metadata.
--
-- The shared compatibility engine already understands adapter-defined
-- dimensions and explicit "values". The registration validator must accept
-- those declarations and reject malformed combinations without changing
-- the legacy "standards" contract or adapter-owned vocabulary.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")
    local c =
        require("tracker_hud.adapters.c.adapter")

    local original =
        cpp.construct_specs
            .lambda_expression.availability
    local original_since = original.since
    local original_dimension = original.dimension

    local function validate(declaration)
        local probe = vim.deepcopy(cpp)

        probe.construct_specs
            .lambda_expression.availability =
            declaration

        return contract.validate_adapter(probe)
    end

    local valid_cases = {
        {
            label = "generic explicit values",
            declaration = {
                language = "cpp",
                dimension = "standard",
                values = {
                    "cpp11",
                    "cpp17",
                },
            },
        },
        {
            label = "generic range",
            declaration = {
                language = "cpp",
                dimension = "standard",
                since = "cpp11",
                ["until"] = "cpp20",
            },
        },
        {
            label = "legacy explicit standards",
            declaration = {
                language = "cpp",
                standards = {
                    "cpp98",
                    "cpp03",
                },
            },
        },
        {
            label = "legacy range without dimension",
            declaration = {
                language = "cpp",
                since = "cpp11",
            },
        },
    }

    for _, case in ipairs(valid_cases) do
        local ok, err = validate(
            case.declaration
        )
        assert(
            ok,
            "valid "
                .. case.label
                .. " availability was rejected: "
                .. tostring(err)
        )
    end

    print(
        "PASS generic availability contract accepts dimension/values and legacy forms"
    )

    local invalid_cases = {
        {
            label = "blank dimension",
            declaration = {
                language = "cpp",
                dimension = "  ",
                since = "cpp11",
            },
        },
        {
            label = "non-string dimension",
            declaration = {
                language = "cpp",
                dimension = 17,
                since = "cpp11",
            },
        },
        {
            label = "values without explicit dimension",
            declaration = {
                language = "cpp",
                values = {
                    "cpp11",
                },
            },
        },
        {
            label = "values not a list",
            declaration = {
                language = "cpp",
                dimension = "standard",
                values = "cpp11",
            },
        },
        {
            label = "values empty",
            declaration = {
                language = "cpp",
                dimension = "standard",
                values = {},
            },
        },
        {
            label = "values duplicate",
            declaration = {
                language = "cpp",
                dimension = "standard",
                values = {
                    "cpp11",
                    "cpp11",
                },
            },
        },
        {
            label = "values blank entry",
            declaration = {
                language = "cpp",
                dimension = "standard",
                values = {
                    "cpp11",
                    " ",
                },
            },
        },
        {
            label = "values and since",
            declaration = {
                language = "cpp",
                dimension = "standard",
                since = "cpp11",
                values = {
                    "cpp17",
                },
            },
        },
        {
            label = "values and until",
            declaration = {
                language = "cpp",
                dimension = "standard",
                ["until"] = "cpp17",
                values = {
                    "cpp11",
                },
            },
        },
        {
            label = "values and legacy standards",
            declaration = {
                language = "cpp",
                dimension = "standard",
                values = {
                    "cpp11",
                },
                standards = {
                    "cpp98",
                },
            },
        },
    }

    for _, case in ipairs(invalid_cases) do
        local ok, err = validate(
            case.declaration
        )
        assert(
            not ok
                and tostring(err):find(
                    "availability",
                    1,
                    true
                ),
            "invalid "
                .. case.label
                .. " availability was accepted: "
                .. tostring(err)
        )
    end

    print(
        "PASS generic availability contract rejects malformed dimensions and ambiguous value sets"
    )

    local cpp_ok, cpp_err =
        contract.validate_adapter(cpp)
    local c_ok, c_err =
        contract.validate_adapter(c)

    assert(
        cpp_ok and c_ok,
        "real C/C++ adapters no longer validate: "
            .. tostring(cpp_err)
            .. " / "
            .. tostring(c_err)
    )

    assert(
        cpp.construct_specs
            .lambda_expression.availability
                == original
            and original.since
                == original_since
            and original.dimension
                == original_dimension,
        "contract validation mutated real C++ availability metadata"
    )

    print(
        "PASS real C/C++ declarations and identities remain unchanged"
    )
    print(
        "PASS Tracker_HUD generic availability contract smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD generic availability contract smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
