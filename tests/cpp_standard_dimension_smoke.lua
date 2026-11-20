-- tests/cpp_standard_dimension_smoke.lua
--
-- C++ owns an explicit language-standard target dimension.
--
-- This checkpoint declares adapter metadata only. It does not yet scan a
-- standard= directive, filter semantic rules, or alter configured cache
-- identity.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local target_dimensions =
        require(
            "tracker_hud.adapters.target_dimensions"
        )
    local c =
        require("tracker_hud.adapters.c.adapter")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    assert(
        c.target_dimensions == nil
            or c.target_dimensions.standard == nil,
        "C adapter must not inherit the C++ standard dimension"
    )

    assert(
        type(cpp.target_dimensions) == "table",
        "C++ adapter must declare target_dimensions"
    )

    local standard =
        cpp.target_dimensions.standard

    assert(
        type(standard) == "table",
        "C++ adapter must declare target_dimensions.standard"
    )

    assert(
        standard.default == "cpp17",
        "C++ standard default must remain cpp17"
    )

    local expected = {
        "cpp98",
        "cpp03",
        "cpp11",
        "cpp14",
        "cpp17",
        "cpp20",
        "cpp23",
    }

    assert(
        #standard.supported == #expected,
        "C++ supported standard count changed"
    )

    for index, value in ipairs(expected) do
        assert(
            standard.supported[index] == value,
            "C++ supported standard order changed at "
                .. tostring(index)
        )
    end

    local resolved_default,
        resolve_err =
        target_dimensions.resolve_value(
            standard,
            nil
        )

    assert(
        resolved_default == "cpp17",
        "C++ default standard did not resolve canonically: "
            .. tostring(resolve_err)
    )

    local alias_cases = {
        ["c++98"] = "cpp98",
        ["c++03"] = "cpp03",
        ["c++11"] = "cpp11",
        ["c++14"] = "cpp14",
        ["c++17"] = "cpp17",
        ["c++20"] = "cpp20",
        ["c++23"] = "cpp23",
        ["98"] = "cpp98",
        ["03"] = "cpp03",
        ["11"] = "cpp11",
        ["14"] = "cpp14",
        ["17"] = "cpp17",
        ["20"] = "cpp20",
        ["23"] = "cpp23",
    }

    for requested, expected_value in pairs(
        alias_cases
    ) do
        local resolved, err =
            target_dimensions.resolve_value(
                standard,
                requested
            )

        assert(
            resolved == expected_value,
            "C++ standard alias "
                .. requested
                .. " resolved to "
                .. tostring(resolved)
                .. " instead of "
                .. expected_value
                .. ": "
                .. tostring(err)
        )
    end

    local valid, validation_err =
        contract.validate_adapter(cpp)

    assert(
        valid,
        "C++ standard declaration violates Adapter Contract: "
            .. tostring(validation_err)
    )

    print(
        "PASS C++ owns standard target dimension; C remains isolated"
    )
    print(
        "PASS C++ standard default cpp17 + supported/alias metadata"
    )
    print(
        "PASS Tracker_HUD C++ standard-dimension metadata smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD C++ standard-dimension metadata smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
