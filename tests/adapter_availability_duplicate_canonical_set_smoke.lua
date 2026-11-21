-- tests/adapter_availability_duplicate_canonical_set_smoke.lua
--
-- Explicit semantic availability sets must be unique by resolved canonical
-- target, not merely by literal spelling. Registration rejects duplicate
-- literal values, but runtime callers may bypass registration and provide
-- duplicate or alias-equivalent values. Availability must fail closed.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local availability =
        require("tracker_hud.adapters.availability")
    local compatibility =
        require("tracker_hud.adapters.compatibility")

    local descriptor = {
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
            edition = descriptor,
        },
        active_targets = {
            edition = "v2",
        },
    }

    local function pure(values)
        return availability.is_available(
            {
                language = "demo",
                standards = values,
            },
            {
                language = "demo",
                descriptor = descriptor,
                selected = "v2",
            }
        )
    end

    local function wrapped(values)
        return compatibility.is_available(
            adapter,
            {
                language = "demo",
                dimension = "edition",
                values = values,
            }
        )
    end

    local valid_sets = {
        {
            values = {
                "v1",
                "v2",
                "latest",
            },
            expected = true,
            label = "distinct set containing selected target",
        },
        {
            values = {
                "v1",
                "latest",
            },
            expected = false,
            label = "distinct set excluding selected target",
        },
    }

    for _, case in ipairs(valid_sets) do
        local present, err = pure(
            case.values
        )
        assert(
            present == case.expected
                and err == nil,
            "pure resolver changed "
                .. case.label
                .. ": "
                .. tostring(err)
        )

        local wrapped_present,
            wrapped_err = wrapped(
                case.values
            )
        assert(
            wrapped_present == case.expected
                and wrapped_err == nil,
            "framework changed "
                .. case.label
                .. ": "
                .. tostring(wrapped_err)
        )
    end

    print(
        "PASS explicit sets preserve distinct canonical membership and exclusion"
    )

    local duplicates = {
        {
            label = "repeated matching literal",
            values = {
                "v2",
                "v2",
            },
        },
        {
            label = "repeated nonmatching literal",
            values = {
                "v1",
                "v1",
            },
        },
        {
            label = "alias-equivalent nonmatching values",
            values = {
                "v3",
                "latest",
            },
        },
        {
            label = "alias-equivalent values after a match",
            values = {
                "v2",
                "v3",
                "latest",
            },
        },
    }

    for _, case in ipairs(duplicates) do
        local present, err = pure(
            case.values
        )
        assert(
            present == false
                and type(err) == "string"
                and #err > 0,
            "pure resolver accepted "
                .. case.label
                .. ": available="
                .. tostring(present)
                .. " error="
                .. tostring(err)
        )

        local wrapped_present,
            wrapped_err = wrapped(
                case.values
            )
        assert(
            wrapped_present == false
                and type(wrapped_err)
                    == "string"
                and #wrapped_err > 0,
            "framework accepted "
                .. case.label
                .. ": available="
                .. tostring(wrapped_present)
                .. " error="
                .. tostring(wrapped_err)
        )
    end

    print(
        "PASS resolver and framework reject duplicate canonical targets"
    )

    assert(
        adapter.active_targets.edition == "v2"
            and descriptor.supported[3] == "v3"
            and descriptor.aliases.latest == "v3",
        "duplicate-set checks mutated adapter-owned target metadata"
    )

    print(
        "PASS duplicate-set validation preserves target descriptors"
    )
    print(
        "PASS Tracker_HUD canonical availability-set uniqueness smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD canonical availability-set uniqueness smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
