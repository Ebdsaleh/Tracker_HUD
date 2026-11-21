-- tests/adapter_compatibility_mixed_explicit_sets_smoke.lua
--
-- Generic adapter compatibility must not silently discard conflicting
-- modern values / transitional standards availability declarations.
-- Contract validation already rejects this shape; direct runtime calls
-- must fail closed as well, without changing adapter-owned vocabulary.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local compatibility =
        require("tracker_hud.adapters.compatibility")

    local adapter = {
        name = "demo",
        target_dimensions = {
            edition = {
                default = "v2",
                supported = {
                    "v1",
                    "v2",
                    "v3",
                },
                aliases = {
                    latest = "v3",
                },
            },
        },
        active_targets = {
            edition = "v2",
        },
    }

    local function decide(declaration)
        return compatibility.is_available(
            adapter,
            declaration
        )
    end

    local modern, modern_err =
        decide({
            language = "demo",
            dimension = "edition",
            values = {
                "v2",
            },
        })

    assert(
        modern == true
            and modern_err == nil,
        "modern explicit values failed without ambiguous fields: "
            .. tostring(modern_err)
    )

    local legacy, legacy_err =
        decide({
            language = "demo",
            dimension = "edition",
            standards = {
                "v2",
            },
        })

    assert(
        legacy == true
            and legacy_err == nil,
        "legacy explicit standards failed without ambiguous fields: "
            .. tostring(legacy_err)
    )

    print(
        "PASS modern values and legacy standards remain independently supported"
    )

    local mixed_cases = {
        {
            label = "matching modern values over conflicting legacy standards",
            declaration = {
                language = "demo",
                dimension = "edition",
                values = {
                    "v2",
                },
                standards = {
                    "v1",
                },
            },
        },
        {
            label = "matching legacy standards over conflicting modern values",
            declaration = {
                language = "demo",
                dimension = "edition",
                values = {
                    "v1",
                },
                standards = {
                    "v2",
                },
            },
        },
        {
            label = "duplicate equivalent modern and legacy sets",
            declaration = {
                language = "demo",
                dimension = "edition",
                values = {
                    "v2",
                },
                standards = {
                    "v2",
                },
            },
        },
    }

    for _, case in ipairs(mixed_cases) do
        local available, err =
            decide(case.declaration)

        assert(
            available == false
                and type(err) == "string"
                and err:find(
                    "availability",
                    1,
                    true
                ),
            "runtime compatibility silently accepted "
                .. case.label
                .. ": available="
                .. tostring(available)
                .. " error="
                .. tostring(err)
        )
    end

    print(
        "PASS compatibility rejects conflicting or duplicate explicit-set forms"
    )

    local range, range_err =
        decide({
            language = "demo",
            dimension = "edition",
            since = "v2",
            ["until"] = "latest",
        })

    assert(
        range == true
            and range_err == nil,
        "unrelated generic range compatibility regressed: "
            .. tostring(range_err)
    )

    assert(
        adapter.active_targets.edition
            == "v2"
            and adapter.target_dimensions
                .edition.supported[2]
                == "v2",
        "runtime compatibility mutated adapter target metadata"
    )

    print(
        "PASS unrelated generic ranges and target identity stay unchanged"
    )
    print(
        "PASS Tracker_HUD mixed explicit-set compatibility smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD mixed explicit-set compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
