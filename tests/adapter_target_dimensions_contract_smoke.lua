-- tests/adapter_target_dimensions_contract_smoke.lua
--
-- Adapter-owned target-dimension declaration contract.
--
-- This checkpoint defines declaration shape only. It does not yet resolve
-- source directives, choose C++ standards, filter semantic specs, or mutate
-- configured-adapter cache identity.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local function probe()
        return vim.deepcopy(cpp)
    end

    local valid = probe()
    valid.target_dimensions = {
        standard = {
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
        },
        dialect = {
            default = "iso",
            supported = {
                "iso",
                "msvc71",
            },
            aliases = {
                ["msvc-7.1"] = "msvc71",
            },
        },
    }

    local valid_ok, valid_err =
        contract.validate_adapter(valid)

    assert(
        valid_ok,
        "valid target_dimensions rejected: "
            .. tostring(valid_err)
    )

    local adapter_owned_name = probe()
    adapter_owned_name.target_dimensions = {
        version = {
            default = "v1",
            supported = { "v1", "v2" },
        },
    }

    local name_ok, name_err =
        contract.validate_adapter(
            adapter_owned_name
        )

    assert(
        name_ok,
        "adapter-owned dimension name rejected: "
            .. tostring(name_err)
    )

    print(
        "PASS target dimensions accept adapter-owned names and canonical defaults"
    )

    local function expect_invalid(
        label,
        mutate,
        expected_fragment
    )
        local candidate = vim.deepcopy(valid)
        mutate(candidate)

        local ok, err =
            contract.validate_adapter(candidate)

        assert(
            not ok,
            label .. " unexpectedly passed"
        )

        assert(
            tostring(err):find(
                expected_fragment,
                1,
                true
            ),
            label
                .. " error did not mention "
                .. expected_fragment
                .. ": "
                .. tostring(err)
        )
    end

    expect_invalid(
        "non-table target dimensions",
        function(candidate)
            candidate.target_dimensions =
                "cpp17"
        end,
        "target_dimensions"
    )

    expect_invalid(
        "empty target dimension name",
        function(candidate)
            candidate.target_dimensions[""] =
                candidate.target_dimensions.standard
            candidate.target_dimensions.standard =
                nil
        end,
        "target_dimensions"
    )

    expect_invalid(
        "non-table dimension descriptor",
        function(candidate)
            candidate.target_dimensions.standard =
                "cpp17"
        end,
        "target_dimensions.standard"
    )

    expect_invalid(
        "missing default",
        function(candidate)
            candidate.target_dimensions.standard.default =
                nil
        end,
        "target_dimensions.standard.default"
    )

    expect_invalid(
        "missing supported values",
        function(candidate)
            candidate.target_dimensions.standard.supported =
                nil
        end,
        "target_dimensions.standard.supported"
    )

    expect_invalid(
        "duplicate supported value",
        function(candidate)
            table.insert(
                candidate.target_dimensions.standard.supported,
                "cpp17"
            )
        end,
        "target_dimensions.standard.supported"
    )

    expect_invalid(
        "unsupported default",
        function(candidate)
            candidate.target_dimensions.standard.default =
                "cpp26"
        end,
        "target_dimensions.standard.default"
    )

    expect_invalid(
        "non-table aliases",
        function(candidate)
            candidate.target_dimensions.standard.aliases =
                "cpp17"
        end,
        "target_dimensions.standard.aliases"
    )

    expect_invalid(
        "empty alias name",
        function(candidate)
            candidate.target_dimensions.standard.aliases[""] =
                "cpp17"
        end,
        "target_dimensions.standard.aliases"
    )

    expect_invalid(
        "unsupported alias target",
        function(candidate)
            candidate.target_dimensions.standard.aliases["future"] =
                "cpp26"
        end,
        "target_dimensions.standard.aliases"
    )

    print(
        "PASS target dimension contract rejects malformed/default/alias declarations"
    )
    print(
        "PASS Tracker_HUD adapter target-dimension declaration contract smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD adapter target-dimension declaration contract smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
