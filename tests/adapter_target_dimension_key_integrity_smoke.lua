-- tests/adapter_target_dimension_key_integrity_smoke.lua
--
-- Target-dimension names are adapter-owned keys consumed literally by
-- config.targets and the shared source-directive scanner. Whitespace-padded
-- declaration keys are unreachable through the intended directive spelling.
-- Reject those declarations before registration without restricting the
-- ecosystem's choice of names (standard, version, dialect, etc.).

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local function descriptor()
        return {
            default = "v1",
            supported = { "v1", "v2" },
            aliases = { latest = "v2" },
        }
    end

    local function probe_with_key(name)
        local candidate = vim.deepcopy(cpp)
        candidate.target_dimensions = {
            [name] = descriptor(),
        }
        return candidate
    end

    -- Names belong to their adapters, not to a universal fixed enum.
    for _, name in ipairs({
        "standard",
        "version",
        "dialect",
        "implementation",
    }) do
        local candidate = probe_with_key(name)
        local ok, err = contract.validate_adapter(candidate)

        assert(
            ok == true and err == nil,
            "valid adapter-owned dimension "
                .. name
                .. " rejected: "
                .. tostring(err)
        )
    end

    local original_ok, original_err =
        contract.validate_adapter(
            vim.deepcopy(cpp)
        )

    assert(
        original_ok == true
            and original_err == nil,
        "built-in C++ adapter was rejected: "
            .. tostring(original_err)
    )

    print(
        "PASS adapter-owned dimension keys remain language-neutral and valid"
    )

    local invalid = {
        {
            label = "leading whitespace",
            key = " standard",
        },
        {
            label = "trailing whitespace",
            key = "standard ",
        },
        {
            label = "whitespace-only key",
            key = "   ",
        },
        {
            label = "tab-prefixed key",
            key = "\tstandard",
        },
        {
            label = "newline-suffixed key",
            key = "standard\n",
        },
        {
            label = "empty key",
            key = "",
        },
        {
            label = "numeric key",
            key = 12,
        },
        {
            label = "boolean key",
            key = true,
        },
    }

    for _, case in ipairs(invalid) do
        local candidate =
            probe_with_key(case.key)

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
            "registration accepted malformed dimension key "
                .. case.label
                .. ": "
                .. tostring(err)
        )
    end

    assert(
        cpp.target_dimensions.standard.default
            == "cpp17"
            and cpp.target_dimensions.standard.supported[5]
                == "cpp17",
        "dimension key integrity tests mutated C++ adapter metadata"
    )

    print(
        "PASS malformed target dimension names fail closed before registration"
    )
    print(
        "PASS dimension-name validation preserves original adapter ownership"
    )
    print(
        "PASS Tracker_HUD target dimension key integrity smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD target dimension key integrity smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
