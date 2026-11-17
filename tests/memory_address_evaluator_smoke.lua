-- tests/memory_address_evaluator_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_address_evaluator_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local evaluator =
    require("tracker_hud.low_level.memory_address_evaluator")

local adapter = {
    metadata = {
        bits = 64,
    },
}

local root_node = {}

local instruction = {
    source_line = 9,
    source_column = 7,
    source_start_line = 8,
    source_start_column = 3,
}

local address = {
    base = {
        name = "rax",
    },
    displacement = {
        value = "8",
    },
    address_size_bits = 64,
    address_size_status = "known",
}

local captured = nil

local result =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            collect_register_effects = function(
                context,
                seen_adapter,
                opts
            )
                captured = {
                    context = context,
                    adapter = seen_adapter,
                    opts = opts,
                }

                return {
                    {
                        name = "rax",
                        value = "4096",
                        resolved = true,
                        metadata = {
                            canonical_name =
                                "rax",
                        },
                    },
                }
            end,
        }
    )

assert(
    captured
        and captured.adapter == adapter
        and captured.context
        and captured.context.cursor
        and captured.context.cursor.line
            == 8
        and captured.context.cursor.column
            == 4
        and captured.opts
        and captured.opts.bufnr == 12
        and captured.opts.root_node
            == root_node
        and captured.opts.limit_position
        and captured.opts.limit_position.line
            == 8
        and captured.opts.limit_position.column
            == 3,
    "pre-instruction register replay position changed"
)
print("PASS memory address evaluator: pre-instruction replay limit preserved")

assert(
    result.status == "known"
        and result.value == "4104"
        and result.bits == 64
        and result.components
        and result.components.base
        and result.components.base.value
            == "4096"
        and result.components.displacement
            == "8",
    "register-based effective address changed"
)
print("PASS memory address evaluator: register arithmetic preserved")

local partial =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            collect_register_effects = function()
                return {
                    {
                        name = "rax",
                        resolved = false,
                        metadata = {
                            partial_value =
                                "known-low-bits",
                        },
                    },
                }
            end,
        }
    )

assert(
    partial.status == "unknown"
        and partial.reason
            == "base register unresolved"
        and partial.details
        and partial.details.metadata
        and partial.details.metadata.status
            == "partial",
    "partial register certainty must fail closed"
)
print("PASS memory address evaluator: partial register state fails closed")

local unavailable =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {}
    )

assert(
    unavailable.status == "unknown"
        and unavailable.reason
            == "register collection unavailable",
    "missing register collector must fail closed"
)
print("PASS memory address evaluator: invalid dependencies fail closed")


local timeline_calls = 0
local replay_calls = 0
local timeline_counters = {}

local timeline_result =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            register_timeline = {
                snapshot_before =
                    function(
                        _self,
                        position
                    )
                        timeline_calls =
                            timeline_calls + 1

                        assert(
                            position.line == 8
                                and position.column == 3,
                            "memory timeline lookup position changed"
                        )

                        return {
                            {
                                name = "rax",
                                value = "4096",
                                resolved = true,
                            },
                        }
                    end,
            },

            collect_register_effects_before =
                function()
                    replay_calls =
                        replay_calls + 1
                    error(
                        "timeline hit unexpectedly used replay fallback"
                    )
                end,

            profile_prefix =
                "memory.timeline_test",
            profile_counter =
                function(name, delta)
                    timeline_counters[name] =
                        (timeline_counters[name] or 0)
                        + delta
                end,
        }
    )

assert(
    timeline_calls == 1
        and replay_calls == 0
        and timeline_result.status == "known"
        and timeline_result.value == "4104"
        and timeline_counters[
            "memory.timeline_test.timeline_hits"
        ] == 1,
    "memory timeline hit changed effective-address semantics"
)

print(
    "PASS memory address evaluator: "
        .. "timeline hit replaces pre-instruction replay"
)

local timeline_misses = 0
local fallback_calls = 0
local fallback_counters = {}

local fallback_result =
    evaluator.evaluate(
        12,
        root_node,
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            register_timeline = {
                snapshot_before =
                    function()
                        timeline_misses =
                            timeline_misses + 1
                        return nil
                    end,
            },

            collect_register_effects_before =
                function(position)
                    fallback_calls =
                        fallback_calls + 1

                    assert(
                        position.line == 8
                            and position.column == 3,
                        "memory timeline fallback position changed"
                    )

                    return {
                        {
                            name = "rax",
                            value = "4096",
                            resolved = true,
                        },
                    }
                end,

            profile_prefix =
                "memory.timeline_fallback_test",
            profile_counter =
                function(name, delta)
                    fallback_counters[name] =
                        (fallback_counters[name] or 0)
                        + delta
                end,
        }
    )

assert(
    timeline_misses == 1
        and fallback_calls == 1
        and fallback_result.status == "known"
        and fallback_result.value == "4104"
        and fallback_counters[
            "memory.timeline_fallback_test.timeline_fallbacks"
        ] == 1,
    "memory timeline miss did not preserve replay fallback"
)

print(
    "PASS memory address evaluator: "
        .. "timeline miss falls back to pre-instruction replay"
)


print("PASS Tracker_HUD memory-address evaluator smoke")
