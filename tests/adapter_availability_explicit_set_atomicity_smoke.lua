-- tests/adapter_availability_explicit_set_atomicity_smoke.lua
--
-- A matched explicit target must not bypass validation of the remainder
-- of its declaration. Both the pure resolver and the adapter-framework
-- wrapper must fail closed on malformed/unknown trailing values.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local availability =
        require("tracker_hud.adapters.availability")
    local compatibility =
        require("tracker_hud.adapters.compatibility")

    local dimension = {
        default = "v2",
        supported = {
            "v1",
            "v2",
            "v3",
        },
        aliases = {
            latest = "v3",
        },
    }

    local adapter = {
        name = "demo",
        target_dimensions = {
            edition = dimension,
        },
        active_targets = {
            edition = "v2",
        },
    }

    local function resolve_explicit(
        standards
    )
        return availability.is_available(
            {
                language = "demo",
                standards = standards,
            },
            {
                language = "demo",
                descriptor = dimension,
                selected = "v2",
            }
        )
    end

    local valid, valid_err =
        resolve_explicit({
            "v1",
            "v2",
            "latest",
        })

    assert(
        valid == true and valid_err == nil,
        "valid explicit target set did not match selected target"
    )

    local absent, absent_err =
        resolve_explicit({
            "v1",
            "latest",
        })

    assert(
        absent == false and absent_err == nil,
        "valid explicit target set fabricated selected membership"
    )

    print(
        "PASS explicit-set resolver preserves valid membership and exclusion"
    )

    local invalid_sets = {
        {
            label = "unknown trailing value",
            values = {
                "v2",
                "never-supported",
            },
        },
        {
            label = "blank trailing value",
            values = {
                "v2",
                "  ",
            },
        },
    }

    for _, case in ipairs(
        invalid_sets
    ) do
        local available, err =
            resolve_explicit(
                case.values
            )

        assert(
            available == false
                and type(err) == "string"
                and #err > 0,
            "pure resolver accepted "
                .. case.label
                .. " after an early match: "
                .. tostring(err)
        )

        local wrapped, wrapped_err =
            compatibility.is_available(
                adapter,
                {
                    language = "demo",
                    dimension = "edition",
                    values = case.values,
                }
            )

        assert(
            wrapped == false
                and type(wrapped_err)
                    == "string"
                and #wrapped_err > 0,
            "framework wrapper accepted "
                .. case.label
                .. " after an early match: "
                .. tostring(wrapped_err)
        )
    end

    print(
        "PASS resolver and framework reject malformed trailing values after a match"
    )

    local wrapped_valid, wrapped_err =
        compatibility.is_available(
            adapter,
            {
                language = "demo",
                dimension = "edition",
                values = {
                    "v1",
                    "v2",
                },
            }
        )

    assert(
        wrapped_valid == true
            and wrapped_err == nil,
        "framework rejected valid generic explicit availability: "
            .. tostring(wrapped_err)
    )

    assert(
        adapter.active_targets.edition
            == "v2"
            and dimension.supported[2]
                == "v2",
        "explicit-set evaluation mutated adapter target configuration"
    )

    print(
        "PASS generic explicit availability preserves adapter-owned targets"
    )
    print(
        "PASS Tracker_HUD explicit availability atomicity smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD explicit availability atomicity smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
