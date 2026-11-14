-- tests/memory_address_replay_session_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_address_replay_session_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local evaluator =
    require(
        "tracker_hud.low_level.memory_address_evaluator"
    )

local adapter = {
    metadata = {
        bits = 64,
    },
}

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

local replay_position = nil
local fallback_calls = 0

local result =
    evaluator.evaluate(
        12,
        {},
        adapter,
        instruction,
        address,
        nil,
        nil,
        {
            collect_register_effects_before =
                function(position)
                    replay_position = {
                        line = position.line,
                        column =
                            position.column,
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

            collect_register_effects =
                function()
                    fallback_calls =
                        fallback_calls + 1

                    return {}
                end,
        }
    )

assert(
    replay_position
        and replay_position.line
            == 8
        and replay_position.column
            == 3,
    "incremental memory replay position changed"
)

assert(
    fallback_calls == 0,
    "incremental memory replay unexpectedly used full collector"
)

print(
    "PASS memory address replay: "
        .. "incremental pre-instruction callback preferred"
)

assert(
    result.status == "known"
        and result.value
            == "4104"
        and result.components
        and result.components.base
        and result.components.base.value
            == "4096",
    "incremental memory replay changed effective address"
)

print(
    "PASS memory address replay: "
        .. "effective-address semantics preserved"
)

print(
    "PASS Tracker_HUD memory-address "
        .. "replay-session smoke"
)
