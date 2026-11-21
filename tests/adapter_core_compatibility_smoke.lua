-- tests/adapter_core_compatibility_smoke.lua
--
-- Core/framework compatibility application.
--
-- Adapter vocabulary stays adapter-owned. Shared Tracker_HUD lookup decides
-- whether a semantic declaration is active for the selected target dimension.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local compatibility =
        require("tracker_hud.adapters.compatibility")
    local construct_utils =
        require("tracker_hud.construct_utils")

    local always = {
        kind = "declaration",
        language_term = "always",
    }

    local future = {
        kind = "declaration",
        language_term = "future",
        availability = {
            language = "demo",
            dimension = "edition",
            since = "v2",
        },
    }

    local bounded = {
        kind = "declaration",
        language_term = "bounded",
        availability = {
            language = "demo",
            dimension = "edition",
            since = "v1",
            ["until"] = "v2",
        },
    }

    local discontinuous = {
        kind = "declaration",
        language_term = "discontinuous",
        availability = {
            language = "demo",
            dimension = "edition",
            values = {
                "v1",
                "latest",
            },
        },
    }

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
            edition = "v1",
        },
        construct_specs = {
            always = always,
            future = future,
            bounded = bounded,
            discontinuous =
                discontinuous,
        },
    }

    local node = {}

    local function get(name)
        return construct_utils
            .get_construct_spec(
                node,
                adapter,
                name
            )
    end

    assert(
        get("always") == always,
        "core lookup hid declaration without availability metadata"
    )

    assert(
        get("future") == nil,
        "core lookup activated future declaration below since boundary"
    )

    assert(
        get("bounded") == bounded,
        "core lookup rejected inclusive bounded declaration"
    )

    assert(
        get("discontinuous")
            == discontinuous,
        "core lookup rejected explicit v1 availability"
    )

    adapter.active_targets.edition = "v2"

    assert(
        get("future") == future,
        "core lookup did not activate declaration at inclusive since boundary"
    )

    assert(
        get("bounded") == bounded,
        "core lookup rejected inclusive until boundary"
    )

    assert(
        get("discontinuous") == nil,
        "core lookup activated declaration outside explicit target set"
    )

    adapter.active_targets.edition =
        "latest"

    assert(
        get("future") == future,
        "core lookup did not canonicalize selected target alias"
    )

    assert(
        get("bounded") == nil,
        "core lookup kept declaration above until boundary"
    )

    assert(
        get("discontinuous")
            == discontinuous,
        "core lookup did not canonicalize explicit target alias"
    )

    print(
        "PASS core construct lookup applies adapter-owned compatibility metadata"
    )

    local direct, err =
        compatibility.is_available(
            adapter,
            {
                language = "demo",
                dimension = "edition",
                since = "v2",
            }
        )

    assert(
        direct == true
            and err == nil,
        "generic compatibility helper failed selected adapter dimension: "
            .. tostring(err)
    )

    local mismatch,
        mismatch_err =
        compatibility.is_available(
            adapter,
            {
                language = "other",
                dimension = "edition",
                since = "v1",
            }
        )

    assert(
        mismatch == false
            and mismatch_err == nil,
        "language mismatch should be unavailable without fabricated error"
    )

    local missing_dimension,
        missing_dimension_err =
        compatibility.is_available(
            adapter,
            {
                language = "demo",
                dimension = "missing",
                since = "v1",
            }
        )

    assert(
        missing_dimension == false
            and missing_dimension_err
                ~= nil,
        "unknown compatibility dimension must fail closed"
    )

    print(
        "PASS core compatibility is dimension-driven and vocabulary-neutral"
    )

    assert(
        adapter.construct_specs.future
            == future
            and adapter.construct_specs
                .bounded
                == bounded
            and adapter.construct_specs
                .discontinuous
                == discontinuous,
        "core compatibility mutated adapter semantic declarations"
    )

    print(
        "PASS core compatibility preserves adapter declarations"
    )
    print(
        "PASS Tracker_HUD core adapter compatibility smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD core adapter compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
