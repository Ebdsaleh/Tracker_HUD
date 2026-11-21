-- tests/adapter_availability_dense_list_shape_smoke.lua
--
-- Explicit availability sets must be dense numeric lists. Lua's ipairs()
-- silently ignores named and zero-indexed entries; malformed metadata must
-- fail closed at both adapter registration and runtime resolution.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local availability =
        require("tracker_hud.adapters.availability")
    local compatibility =
        require("tracker_hud.adapters.compatibility")
    local contract =
        require("tracker_hud.adapters.contract")
    local cpp =
        require("tracker_hud.adapters.cpp.adapter")

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

    local valid, valid_err = pure({
        "v1",
        "v2",
    })
    local wrapped_valid, wrapped_err = wrapped({
        "v1",
        "v2",
    })
    assert(
        valid == true
            and valid_err == nil
            and wrapped_valid == true
            and wrapped_err == nil,
        "valid dense explicit availability list regressed"
    )
    print("PASS dense explicit lists preserve valid semantics")

    local malformed = {
        {
            label = "named trailing entry",
            make = function()
                return {
                    "v2",
                    concealed = "v1",
                }
            end,
        },
        {
            label = "zero-indexed entry",
            make = function()
                return {
                    [1] = "v2",
                    [0] = "v1",
                }
            end,
        },
    }

    local function require_rejected(
        available,
        err,
        label
    )
        assert(
            available == false
                and type(err) == "string"
                and #err > 0,
            label
                .. " was silently accepted: "
                .. tostring(available)
                .. " / "
                .. tostring(err)
        )
    end

    for _, case in ipairs(malformed) do
        local values = case.make()
        local present, err = pure(values)
        require_rejected(
            present,
            err,
            "pure resolver: " .. case.label
        )

        local framework_present,
            framework_err = wrapped(values)
        require_rejected(
            framework_present,
            framework_err,
            "compatibility wrapper: " .. case.label
        )

        for _, field in ipairs({
            "values",
            "standards",
        }) do
            local probe = vim.deepcopy(cpp)
            local metadata = {
                language = "cpp",
                dimension = "standard",
            }
            metadata[field] = case.make()
            probe.construct_specs
                .lambda_expression
                .availability = metadata

            local registration_ok,
                registration_err =
                contract.validate_adapter(probe)

            assert(
                registration_ok == false
                    and tostring(registration_err):find(
                        "availability",
                        1,
                        true
                    ),
                "registration accepted "
                    .. case.label
                    .. " in "
                    .. field
                    .. ": "
                    .. tostring(registration_err)
            )
        end
    end

    print(
        "PASS runtime and registration reject hidden non-list entries"
    )

    assert(
        adapter.active_targets.edition == "v2"
            and descriptor.supported[2] == "v2"
            and descriptor.aliases.latest == "v3",
        "dense-list validation mutated adapter-owned metadata"
    )

    print("PASS dense-list checks preserve adapter-owned targets")
    print("PASS Tracker_HUD dense availability-list shape smoke")
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD dense availability-list shape smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
