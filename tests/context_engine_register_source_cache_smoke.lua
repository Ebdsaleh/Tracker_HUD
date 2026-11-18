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

local stack_pipeline =
    require(
        "tracker_hud.low_level.stack_effect_pipeline"
    )

local instruction_event_pipeline =
    require(
        "tracker_hud.low_level.instruction_event_pipeline"
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

local original_stack_collect =
    stack_pipeline.collect

local original_instruction_event_collect =
    instruction_event_pipeline.collect

local original_collect_instruction =
    instruction_source.collect_instruction

local prepare_calls = 0
local collect_calls = 0
local replay_calls = 0
local paired_replay_queries = 0
local paired_timeline_capture_calls = 0
local persistent_timeline_before_queries = 0
local persistent_timeline_visible_queries = 0
local parse_calls = 0

local parse_node = {}
local parse_spec = {}
local parse_spec_other = {}

local parsed_instruction = {
    mnemonic = "mov",
    operands = {},
}

local parsed_instruction_other = {
    mnemonic = "other",
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
                and (
                    effect_spec
                        == parse_spec
                    or effect_spec
                        == parse_spec_other
                ),
            "unexpected parser-cache test key"
        )

        parse_calls =
            parse_calls + 1

        return effect_spec
                == parse_spec_other
            and parsed_instruction_other
            or parsed_instruction
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

local timeline_sentinel = {
    snapshot_before = function()
        persistent_timeline_before_queries =
            persistent_timeline_before_queries + 1
        return {
            {
                name = "rax",
                value = "timeline-before",
            },
        }
    end,

    snapshot_visible = function()
        persistent_timeline_visible_queries =
            persistent_timeline_visible_queries + 1
        return {
            {
                name = "rax",
                value = "timeline-visible",
            },
        }
    end,

    stats = function()
        return {
            processed_count = 10,
            captured_count = 10,
            source_node_count = 10,
        }
    end,
}

local replay_sentinel = {
    collect_before = function()
        return {}
    end,

    get_timeline = function()
        return timeline_sentinel
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
        seen_opts,
        deps
    )
        assert(
            seen_opts.register_timeline
                == timeline_sentinel,
            "boundary did not receive paired Register timeline"
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
        seen_opts,
        deps
    )
        assert(
            seen_opts.register_timeline
                == timeline_sentinel,
            "Source Memory did not receive paired Register timeline"
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

stack_pipeline.collect =
    function(
        _context,
        adapter,
        _opts,
        deps
    )
        local instruction =
            deps.parse_instruction(
                parse_node,
                parse_spec_other
            )

        if adapter.instruction_parser
            and adapter
                .instruction_parser
                .cache_identity
                == "node"
        then
            assert(
                instruction
                    == parsed_instruction,
                "node-stable Stack parser did not reuse cached instruction"
            )
        else
            assert(
                instruction
                    == parsed_instruction_other,
                "spec-sensitive Stack parser cache collapsed distinct specs"
            )
        end

        return {}
    end

instruction_event_pipeline.collect =
    function(
        _context,
        adapter,
        _opts,
        deps
    )
        local instruction =
            deps.parse_instruction(
                parse_node,
                parse_spec_other
            )

        if adapter.instruction_parser
            and adapter
                .instruction_parser
                .cache_identity
                == "node"
        then
            assert(
                instruction
                    == parsed_instruction,
                "node-stable Event parser did not reuse cached instruction"
            )
        else
            assert(
                instruction
                    == parsed_instruction_other,
                "spec-sensitive Event parser cache collapsed distinct specs"
            )
        end

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
                instruction_parser = {
                    cache_identity = "node",
                },
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
                paired_visible,
                paired_timeline =
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
                    and paired_timeline
                        == timeline_sentinel
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
                    register_timeline =
                        paired_timeline,
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
                    register_timeline =
                        paired_timeline,
                }
            )

            engine.collect_stack_effects(
                context,
                adapter,
                {
                    bufnr = 77,
                    root_node = "root",
                    register_source_cache =
                        cache,
                }
            )

            engine.collect_instruction_events(
                context,
                adapter,
                {
                    bufnr = 77,
                    root_node = "root",
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

            print(
                "PASS context register source cache: "
                    .. "paired Register timeline threads into Boundary"
            )

            print(
                "PASS context register source cache: "
                    .. "paired Register timeline threads into Source Memory"
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

            local spec_sensitive_start =
                parse_calls

            local spec_sensitive_adapter = {
                name = "probe",
                marker = "spec-sensitive",
                instruction_parser = {
                    cache_identity =
                        "node_and_spec",
                },
            }

            local spec_sensitive_cache = {}

            engine.collect_register_effects(
                context,
                spec_sensitive_adapter,
                {
                    bufnr = 88,
                    root_node = "spec-root",
                    register_source_cache =
                        spec_sensitive_cache,
                }
            )

            engine.collect_stack_effects(
                context,
                spec_sensitive_adapter,
                {
                    bufnr = 88,
                    root_node = "spec-root",
                    register_source_cache =
                        spec_sensitive_cache,
                }
            )

            assert(
                parse_calls
                    == spec_sensitive_start + 2,
                "spec-sensitive parser cache incorrectly collapsed node identity across specs"
            )

            print(
                "PASS context register source cache: "
                    .. "spec-sensitive parsers remain keyed by node + spec"
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

            local reuse_counters = {}
            local reuse_replay_start =
                replay_calls

            engine.collect_register_effect_pair(
                context,
                stable_adapter,
                {
                    bufnr = real_buffer,
                    root_node = "timeline-root-a",
                    register_source_cache = {},
                    before_position = {
                        line = 10,
                        column = 0,
                    },
                    config = {
                        marker = "config",
                    },
                    profile_counter =
                        function(name, delta)
                            reuse_counters[name] =
                                (reuse_counters[name] or 0)
                                + delta
                        end,
                }
            )

            local reuse_replay_after_first =
                replay_calls

            local reused_before,
                reused_visible,
                reused_timeline =
                engine.collect_register_effect_pair(
                context,
                stable_adapter,
                {
                    bufnr = real_buffer,
                    root_node = "timeline-root-b",
                    register_source_cache = {},
                    before_position = {
                        line = 10,
                        column = 0,
                    },
                    config = {
                        marker = "config",
                    },
                    profile_counter =
                        function(name, delta)
                            reuse_counters[name] =
                                (reuse_counters[name] or 0)
                                + delta
                        end,
                }
            )

            assert(
                reuse_counters[
                    "context.registers.dynamic.process.cross_refresh_timeline_reuse_possible"
                ] == 1
                    and reuse_counters[
                        "context.registers.dynamic.process.cross_refresh_timeline_reuse_applied"
                    ] == 1
                    and reuse_counters[
                        "context.registers.dynamic.process.cross_refresh_timeline_reuse_miss"
                    ] == 1
                    and reuse_replay_after_first
                        == reuse_replay_start + 1
                    and replay_calls
                        == reuse_replay_after_first
                    and reused_timeline
                        == timeline_sentinel
                    and reused_before[1].value
                        == "timeline-before"
                    and reused_visible[1].value
                        == "timeline-visible"
                    and persistent_timeline_before_queries
                        >= 1
                    and persistent_timeline_visible_queries
                        >= 1,
                "cross-refresh Register timeline production reuse changed"
            )

            print(
                "PASS context register source cache: "
                    .. "unchanged source reuses read-only timeline without a new replay session"
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

stack_pipeline.collect =
    original_stack_collect

instruction_event_pipeline.collect =
    original_instruction_event_collect

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
