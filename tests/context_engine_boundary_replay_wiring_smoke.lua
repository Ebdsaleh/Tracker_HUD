-- tests/context_engine_boundary_replay_wiring_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_boundary_replay_wiring_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.context_engine"
] = nil

local register_pipeline =
    require(
        "tracker_hud.low_level.register_effect_pipeline"
    )

local boundary_pipeline =
    require(
        "tracker_hud.low_level.boundary_effect_pipeline"
    )

local original_new_replay_session =
    register_pipeline.new_replay_session

local original_boundary_collect =
    boundary_pipeline.collect

local replay_calls = 0
local boundary_calls = 0

local replay_sentinel = {
    collect_before = function()
        return {}
    end,
}

register_pipeline.new_replay_session =
    function(
        context,
        adapter,
        opts,
        deps
    )
        replay_calls =
            replay_calls + 1

        assert(
            context.marker
                == "context",
            "context was not forwarded to replay session"
        )

        assert(
            adapter.marker
                == "adapter",
            "adapter was not forwarded to replay session"
        )

        assert(
            opts.bufnr == 77
                and opts.root_node
                    == "root",
            "boundary options were not forwarded to replay session"
        )

        assert(
            type(deps)
                == "table"
                and type(
                    deps.parse_instruction
                ) == "function",
            "register replay parser dependency missing"
        )

        return replay_sentinel
    end

boundary_pipeline.collect =
    function(
        context,
        adapter,
        opts,
        deps
    )
        boundary_calls =
            boundary_calls + 1

        assert(
            type(deps)
                == "table"
                and type(
                    deps.create_register_replay_session
                ) == "function",
            "context engine did not supply boundary replay-session factory"
        )

        local session =
            deps.create_register_replay_session()

        assert(
            session
                == replay_sentinel,
            "boundary replay-session factory returned unexpected session"
        )

        return {
            {
                kind = "sentinel",
            },
        }
    end

local ok, err =
    pcall(
        function()
            local engine =
                require(
                    "tracker_hud.context_engine"
                )

            local result =
                engine.collect_boundary_effects(
                    {
                        marker =
                            "context",
                    },
                    {
                        marker =
                            "adapter",
                    },
                    {
                        bufnr = 77,
                        root_node =
                            "root",
                    }
                )

            assert(
                boundary_calls == 1,
                "context engine did not delegate boundary collection"
            )

            assert(
                replay_calls == 1,
                "boundary replay-session factory was not invoked exactly once"
            )

            assert(
                result[1]
                    and result[1].kind
                        == "sentinel",
                "boundary facade result changed"
            )
        end
    )

register_pipeline.new_replay_session =
    original_new_replay_session

boundary_pipeline.collect =
    original_boundary_collect

package.loaded[
    "tracker_hud.context_engine"
] = nil

assert(
    ok,
    tostring(err)
)

print(
    "PASS context engine boundary replay: "
        .. "session factory reaches boundary pipeline"
)

print(
    "PASS Tracker_HUD context-engine "
        .. "boundary replay-wiring smoke"
)
