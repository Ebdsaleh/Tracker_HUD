-- tests/adapter_availability_contract_smoke.lua
--
-- Structural contract for semantic availability metadata.
--
-- This checkpoint validates and preserves declarations only. It does not
-- decide whether a construct is available for the active target standard.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract =
        require("tracker_hud.adapters.contract")
    local construct_schema =
        require(
            "tracker_hud.adapters.construct_schema"
        )
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

    local built =
        construct_schema.rule(
            "lambda_expression",
            "function",
            {
                language_term = "lambda",
                availability = {
                    language = "cpp",
                    since = "cpp11",
                },
            }
        )

    assert(
        type(built.availability)
            == "table"
            and built.availability.language
                == "cpp"
            and built.availability.since
                == "cpp11",
        "construct authoring helper discarded availability metadata"
    )

    local valid_shapes = {
        {
            language = "cpp",
            since = "cpp11",
        },
        {
            language = "cpp",
            since = "cpp98",
            until = "cpp17",
        },
        {
            language = "cpp",
            until = "cpp03",
        },
        {
            language = "cpp",
            standards = {
                "cpp98",
                "cpp03",
            },
        },
    }

    for index, availability in ipairs(
        valid_shapes
    ) do
        local probe =
            vim.deepcopy(cpp)

        probe.construct_specs
            .lambda_expression
            .availability =
            availability

        local valid, err =
            contract.validate_adapter(
                probe
            )

        assert(
            valid,
            "valid availability shape "
                .. tostring(index)
                .. " rejected: "
                .. tostring(err)
        )
    end

    print(
        "PASS availability contract accepts since/until/explicit-standard forms"
    )

    local invalid_shapes = {
        {
            label = "non-table availability",
            value = "cpp11",
        },
        {
            label = "missing language",
            value = {
                since = "cpp11",
            },
        },
        {
            label = "blank language",
            value = {
                language = "   ",
                since = "cpp11",
            },
        },
        {
            label = "no range or explicit standards",
            value = {
                language = "cpp",
            },
        },
        {
            label = "blank since",
            value = {
                language = "cpp",
                since = "",
            },
        },
        {
            label = "blank until",
            value = {
                language = "cpp",
                until = "",
            },
        },
        {
            label = "standards not table",
            value = {
                language = "cpp",
                standards = "cpp11",
            },
        },
        {
            label = "empty standards",
            value = {
                language = "cpp",
                standards = {},
            },
        },
        {
            label = "duplicate standards",
            value = {
                language = "cpp",
                standards = {
                    "cpp98",
                    "cpp98",
                },
            },
        },
        {
            label = "blank explicit standard",
            value = {
                language = "cpp",
                standards = {
                    "cpp98",
                    "",
                },
            },
        },
        {
            label = "explicit standards mixed with since",
            value = {
                language = "cpp",
                since = "cpp11",
                standards = {
                    "cpp11",
                },
            },
        },
        {
            label = "explicit standards mixed with until",
            value = {
                language = "cpp",
                until = "cpp17",
                standards = {
                    "cpp11",
                },
            },
        },
    }

    for _, invalid in ipairs(
        invalid_shapes
    ) do
        local probe =
            vim.deepcopy(cpp)

        probe.construct_specs
            .lambda_expression
            .availability =
            invalid.value

        local valid, err =
            contract.validate_adapter(
                probe
            )

        assert(
            not valid
                and tostring(err):find(
                    "availability",
                    1,
                    true
                ),
            invalid.label
                .. " was accepted: "
                .. tostring(err)
        )
    end

    print(
        "PASS availability contract rejects malformed/ambiguous declarations"
    )

    local untouched =
        vim.deepcopy(cpp)

    local valid, err =
        contract.validate_adapter(
            untouched
        )

    assert(
        valid,
        "availability must remain optional: "
            .. tostring(err)
    )

    print(
        "PASS availability metadata remains optional and structural only"
    )
    print(
        "PASS Tracker_HUD semantic availability declaration contract smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD semantic availability declaration contract smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
