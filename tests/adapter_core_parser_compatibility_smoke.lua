-- tests/adapter_core_parser_compatibility_smoke.lua
--
-- Parser-facing core compatibility enforcement.
--
-- Tree-sitter/node recognition may exist while the selected semantic target
-- makes the adapter declaration unavailable. Shared parser matching/parsing
-- must honor the same compatibility engine as construct lookup.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local context_engine =
        require("tracker_hud.context_engine")

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
            future_node = {
                construct = {
                    kind = "declaration",
                    label = "Future",
                },
                syntax = {
                    node_type = "future_node",
                },
                availability = {
                    language = "demo",
                    dimension = "edition",
                    since = "v2",
                },
            },
        },
    }

    local node = {
        type = function()
            return "future_node"
        end,
        range = function()
            return 0, 0, 0, 1
        end,
    }

    assert(
        context_engine.match_node(
            adapter,
            node
        ) == false,
        "parser match activated unavailable semantic declaration"
    )

    local parsed_v1, err_v1 =
        context_engine.parse_node(
            adapter,
            node,
            0
        )

    assert(
        parsed_v1 == nil
            and err_v1 == nil,
        "parser produced unavailable semantic construct: "
            .. tostring(err_v1)
    )

    print(
        "PASS core parser matching/parsing hides unavailable adapter semantics"
    )

    adapter.active_targets.edition = "v2"

    assert(
        context_engine.match_node(
            adapter,
            node
        ) == true,
        "parser match rejected declaration at inclusive compatibility boundary"
    )

    local parsed_v2, err_v2 =
        context_engine.parse_node(
            adapter,
            node,
            0
        )

    assert(
        parsed_v2 ~= nil
            and err_v2 == nil
            and parsed_v2.node_type
                == "future_node"
            and parsed_v2.construct.kind
                == "declaration",
        "parser did not activate compatible semantic construct: "
            .. tostring(err_v2)
    )

    adapter.active_targets.edition =
        "latest"

    local parsed_v3, err_v3 =
        context_engine.parse_node(
            adapter,
            node,
            0
        )

    assert(
        parsed_v3 ~= nil
            and err_v3 == nil,
        "parser did not canonicalize active target alias: "
            .. tostring(err_v3)
    )

    print(
        "PASS core parser compatibility follows adapter-owned active target"
    )

    assert(
        adapter.construct_specs
            .future_node
            .availability
            .since == "v2",
        "parser compatibility mutated adapter declaration"
    )

    print(
        "PASS core parser compatibility preserves declaration identity"
    )
    print(
        "PASS Tracker_HUD core parser compatibility smoke"
    )
end

local ok, err = pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Tracker_HUD core parser compatibility smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
