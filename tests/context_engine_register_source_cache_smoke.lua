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

local instruction_source =
    require(
        "tracker_hud.low_level.instruction_source"
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

local original_collect_instruction =
    instruction_source.collect_instruction

local prepare_calls = 0
local collect_calls = 0
local replay_calls = 0
local paired_replay_queries = 0
local paired_timeline_capture_calls = 0
local parse_calls = 0

local parse_node = {}
local parse_spec = {}
local parsed_instruction = {
    mnemonic = "mov",
    operands = {},
}

local prepared_sentinel = nil

instruction_source.collect_instruction =
    function(
        _adapter,
        node,
        _bufnr,
        effect_spec
    )
        assert(
            node == parse_node
                and effect_spec
                    == parse_spec,
            "unexpected parser-cache test key"
        )

        parse_calls =
            parse_calls + 1

        return parsed_instruction
    end

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
        opts,
        deps
    )
        collect_calls =
            collect_calls + 1

        assert(
            opts.prepared_source
                and opts.prepared_source.nodes
                    == prepared_sentinel.nodes
                and opts.prepared_source.effect_index
                    == prepared_sentinel.effect_index,
            "register collector did not receive shared prepared source"
        )

        assert(
            deps.parse_instruction(
                parse_node,
                parse_spec
            ) == parsed_instruction,
            "register collector parser result changed"
        )

        return {}
    end

local replay_sentinel = {
    collect_before = function()
        return {}
    end,

    collect_before_and_visible =
        function(
            _self,
            before_position,
            visible_context,
            visible_opts
        )
            paired_replay_queries =
                paired_replay_queries + 1

            assert(
                before_position.line == 10
                    and before_position.column == 0
                    and visible_context.cursor.line == 10
                    and visible_opts.config.marker == "config",
                "paired register replay query inputs changed"
            )

            return {
                {
                    name = "rax",
                    value = "before",
                },
            }, {
                {
                    name = "rax",
                    value = "visible",
                },
            }
        end,
}

register_pipeline.new_replay_session =
    function(
        _context,
        _adapter,
        opts,
        deps
    )
        replay_calls =
            replay_calls + 1

        if opts.profile_prefix
            == "context.registers.dynamic.process"
        then
            assert(
                opts.capture_timeline == true,
                "paired Register replay did not enable timeline capture"
            )

            paired_timeline_capture_calls =
                paired_timeline_capture_calls + 1
        end

        assert(
            opts.prepared_source
                and opts.prepared_source.nodes
                    == prepared_sentinel.nodes
                and opts.prepared_source.effect_index
                    == prepared_sentinel.effect_index,
            "replay consumer did not receive shared prepared source"
        )

        assert(
            deps.parse_instruction(
                parse_node,
                parse_spec
            ) == parsed_instruction,
            "replay parser result changed"
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
        assert(
            deps.parse_instruction(
                parse_node,
                parse_spec
            ) == parsed_instruction,
            "boundary parser result changed"
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
    function(
        _bufnr,
        _root_node,
        _adapter,
        _line_predicate,
        _opts,
        deps
    )
        assert(
            deps.parse_instruction(
                parse_node,
                parse_spec
            ) == parsed_instruction,
            "memory discovery parser result changed"
        )

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

            local paired_before,
                paired_visible =
                engine.collect_register_effect_pair(
                    context,
                    adapter,
                    {
                        bufnr = 77,
                        root_node = "root",
                        register_source_cache =
                            cache,
                        before_position = {
                            line = 10,
                            column = 0,
                        },
                        config = {
                            marker = "config",
                        },
                    }
                )

            assert(
                paired_before[1].value == "before"
                    and paired_visible[1].value == "visible"
                    and paired_replay_queries == 1,
                "context engine paired register replay changed"
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
                replay_calls == 3,
                "paired/boundary/source-memory replay-session ownership changed"
            )

            assert(
                paired_timeline_capture_calls == 1,
                "paired Register replay timeline capture ownership changed"
            )

            print(
                "PASS context register source cache: "
                    .. "paired replay alone enables timeline capture"
            )

            assert(
                parse_calls == 1,
                "refresh-local instruction parse cache did not serve all consumers"
            )

            print(
                "PASS context register source cache: "
                    .. "one parsed instruction serves refresh-local consumers"
            )

            print(
                "PASS context register source cache: "
                    .. "one immutable index serves paired and independent consumers"
            )

            print(
                "PASS context register source cache: "
                    .. "paired before/visible register state uses one replay session"
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


            local real_buffer =
                vim.api.nvim_create_buf(
                    false,
                    true
                )

            vim.api.nvim_buf_set_lines(
                real_buffer,
                0,
                -1,
                false,
                {
                    "mov rax, 1",
                }
            )

            local stable_adapter = {
                name = "asm",
                validation_stable_components = {
                    register_effects = true,
                },
                register_effects = {},
            }

            local persistent_start =
                prepare_calls

            local first_refresh_cache = {}

            engine.collect_register_effects(
                context,
                stable_adapter,
                {
                    bufnr = real_buffer,
                    root_node = "root-a",
                    register_source_cache =
                        first_refresh_cache,
                }
            )

            local first_prepared =
                first_refresh_cache
                    .prepared_source

            local second_refresh_cache = {}

            engine.collect_register_effects(
                context,
                stable_adapter,
                {
                    bufnr = real_buffer,
                    root_node = "root-b",
                    register_source_cache =
                        second_refresh_cache,
                }
            )

            assert(
                prepare_calls
                    == persistent_start + 1,
                "unchanged stable buffer rebuilt prepared source across refreshes"
            )

            assert(
                second_refresh_cache
                    .prepared_source
                    ~= first_prepared
                    and second_refresh_cache
                        .prepared_source
                        .nodes
                        == first_prepared.nodes
                    and second_refresh_cache
                        .prepared_source
                        .effect_index
                        == first_prepared.effect_index
                    and second_refresh_cache
                        .prepared_source
                        .root_node
                        == "root-b"
                    and second_refresh_cache
                        .prepared_source
                        .source_root_node
                        == "root-a",
                "persistent prepared source did not rebind root while preserving immutable source data"
            )

            print(
                "PASS context register source cache: "
                    .. "stable unchanged buffer reuses prepared source across refreshes"
            )

            vim.api.nvim_buf_set_lines(
                real_buffer,
                0,
                -1,
                false,
                {
                    "mov rax, 2",
                }
            )

            engine.collect_register_effects(
                context,
                stable_adapter,
                {
                    bufnr = real_buffer,
                    root_node = "root-c",
                    register_source_cache = {},
                }
            )

            assert(
                prepare_calls
                    == persistent_start + 2,
                "changedtick did not invalidate persistent prepared source"
            )

            print(
                "PASS context register source cache: "
                    .. "buffer edit invalidates persistent prepared source"
            )

            stable_adapter.register_effects = {}

            engine.collect_register_effects(
                context,
                stable_adapter,
                {
                    bufnr = real_buffer,
                    root_node = "root-d",
                    register_source_cache = {},
                }
            )

            assert(
                prepare_calls
                    == persistent_start + 3,
                "register-effect identity change did not invalidate persistent prepared source"
            )

            print(
                "PASS context register source cache: "
                    .. "register-effect identity change invalidates persistent source"
            )

            vim.api.nvim_buf_delete(
                real_buffer,
                {
                    force = true,
                }
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

instruction_source.collect_instruction =
    original_collect_instruction

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
