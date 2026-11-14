-- tests/context_engine_register_source_cache_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_register_source_cache_smoke.lua" -c "qa!"

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

local memory_discovery =
    require(
        "tracker_hud.low_level.memory_source_discovery"
    )

local original_prepare_source =
    register_pipeline.prepare_source

local original_collect =
    register_pipeline.collect

local original_new_replay_session =
    register_pipeline.new_replay_session

local original_boundary_collect =
    boundary_pipeline.collect

local original_memory_collect =
    memory_discovery.collect

local prepare_calls = 0
local collect_calls = 0
local replay_calls = 0

local prepared_sentinel = nil

register_pipeline.prepare_source =
    function(
        adapter,
        opts
    )
        prepare_calls =
            prepare_calls + 1

        prepared_sentinel = {
            adapter = adapter,
            root_node =
                opts.root_node,
            effect_index = {},
            nodes = {},
        }

        return prepared_sentinel
    end

register_pipeline.collect =
    function(
        _context,
        _adapter,
        opts
    )
        collect_calls =
            collect_calls + 1

        assert(
            opts.prepared_source
                == prepared_sentinel,
            "register collector did not receive shared prepared source"
        )

        return {}
    end

local replay_sentinel = {
    collect_before = function()
        return {}
    end,
}

register_pipeline.new_replay_session =
    function(
        _context,
        _adapter,
        opts
    )
        replay_calls =
            replay_calls + 1

        assert(
            opts.prepared_source
                == prepared_sentinel,
            "replay consumer did not receive shared prepared source"
        )

        return replay_sentinel
    end

boundary_pipeline.collect =
    function(
        _context,
        _adapter,
        _opts,
        deps
    )
        local session =
            deps
                .create_register_replay_session()

        assert(
            session == replay_sentinel,
            "boundary did not receive shared-source replay session"
        )

        return {}
    end

memory_discovery.collect =
    function()
        return {}
    end

local ok, err =
    pcall(
        function()
            local engine =
                require(
                    "tracker_hud.context_engine"
                )

            local cache = {}

            local adapter = {
                name = "asm",
                marker = "adapter",
            }

            local context = {
                cursor = {
                    line = 10,
                    column = 1,
                },
            }

            local common = {
                bufnr = 77,
                root_node = "root",
                register_source_cache =
                    cache,
            }

            engine.collect_register_effects(
                context,
                adapter,
                common
            )

            engine.collect_register_effects(
                context,
                adapter,
                {
                    bufnr = 77,
                    root_node = "root",
                    register_source_cache =
                        cache,
                    limit_position = {
                        line = 10,
                        column = 0,
                    },
                }
            )

            engine.collect_boundary_effects(
                context,
                adapter,
                {
                    bufnr = 77,
                    root_node = "root",
                    register_source_cache =
                        cache,
                }
            )

            engine.collect_memory_source_operands(
                77,
                "root",
                adapter,
                10,
                {
                    register_source_cache =
                        cache,
                }
            )

            assert(
                prepare_calls == 1,
                "shared refresh cache rebuilt prepared source"
            )

            assert(
                collect_calls == 2,
                "register consumers did not execute expected independent reductions"
            )

            assert(
                replay_calls == 2,
                "boundary/source-memory did not create independent replay sessions"
            )

            print(
                "PASS context register source cache: "
                    .. "one immutable index serves four consumers"
            )

            assert(
                cache.prepared_source
                    == prepared_sentinel,
                "refresh cache did not retain prepared source identity"
            )

            print(
                "PASS context register source cache: "
                    .. "mutable replay state remains consumer-local"
            )
        end
    )

register_pipeline.prepare_source =
    original_prepare_source

register_pipeline.collect =
    original_collect

register_pipeline.new_replay_session =
    original_new_replay_session

boundary_pipeline.collect =
    original_boundary_collect

memory_discovery.collect =
    original_memory_collect

package.loaded[
    "tracker_hud.context_engine"
] = nil

assert(
    ok,
    tostring(err)
)

print(
    "PASS Tracker_HUD context-engine "
        .. "register-source cache smoke"
)
