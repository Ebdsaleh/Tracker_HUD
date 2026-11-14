-- tests/register_effect_replay_session_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_replay_session_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local processing =
    require(
        "tracker_hud.low_level.register_effect_processing"
    )

local effect = {
    id = "write",
}

local effect_index = {
    by_node_type = {
        instruction = {
            __first = effect,
            mov = {
                effect,
            },
        },
    },
}

local function fake_node(
    id,
    value
)
    return {
        id = id,
        value = value,
        type = function()
            return "instruction"
        end,
    }
end

local nodes = {
    {
        node = fake_node(
            "first",
            "41"
        ),
        line = 2,
        column = 0,
    },
    {
        node = fake_node(
            "second",
            "42"
        ),
        line = 3,
        column = 0,
    },
}

local session =
    processing.new_session({
        nodes = nodes,
        effect_index =
            effect_index,

        parse_instruction = function(
            node
        )
            return {
                mnemonic = "mov",
                value = node.value,
            }
        end,

        normalize_mnemonic = function(
            value
        )
            return value
                and value:lower()
                or nil
        end,

        new_low_level_state =
            function()
                return {}
            end,

        prepare_instruction_state =
            function(
                _state,
                _facts,
                instruction
            )
                return {
                    value =
                        instruction.value,
                }
            end,

        apply_effect = function(
            facts_by_register,
            family_state,
            latest_state_facts,
            _instruction,
            _effect_spec,
            instruction_state
        )
            local fact = {
                name = "rax",
                value =
                    instruction_state.value,
            }

            facts_by_register.rax =
                fact
            family_state.rax =
                fact
            latest_state_facts.rax =
                fact
        end,

        to_fact_list =
            function(latest)
                return {
                    latest.rax,
                }
            end,
    })

assert(
    session,
    "incremental processing session was not created"
)

local first_advance =
    processing.advance_while(
        session,
        function(entry)
            return entry.line < 3
        end
    )

local first =
    processing.snapshot(
        session
    )

assert(
    first_advance == 1
        and session.processed_count
            == 1
        and first[1]
        and first[1].value
            == "41",
    "first incremental snapshot changed"
)
print("PASS register replay session: first prefix reduced once")

local no_advance =
    processing.advance_while(
        session,
        function(entry)
            return entry.line < 3
        end
    )

assert(
    no_advance == 0
        and session.processed_count
            == 1,
    "same prefix must not replay processed nodes"
)
print("PASS register replay session: repeated prefix does not replay")

local second_advance =
    processing.advance_all(
        session
    )

local second =
    processing.snapshot(
        session
    )

assert(
    second_advance == 1
        and session.processed_count
            == 2
        and second[1]
        and second[1].value
            == "42",
    "second incremental snapshot changed"
)
print("PASS register replay session: later prefix advances state")

local full =
    processing.process({
        nodes = nodes,
        effect_index =
            effect_index,

        parse_instruction = function(
            node
        )
            return {
                mnemonic = "mov",
                value = node.value,
            }
        end,

        normalize_mnemonic = function(
            value
        )
            return value
                and value:lower()
                or nil
        end,

        new_low_level_state =
            function()
                return {}
            end,

        prepare_instruction_state =
            function(
                _state,
                _facts,
                instruction
            )
                return {
                    value =
                        instruction.value,
                }
            end,

        apply_effect = function(
            facts_by_register,
            family_state,
            latest_state_facts,
            _instruction,
            _effect_spec,
            instruction_state
        )
            local fact = {
                name = "rax",
                value =
                    instruction_state.value,
            }

            facts_by_register.rax =
                fact
            family_state.rax =
                fact
            latest_state_facts.rax =
                fact
        end,

        to_fact_list =
            function(latest)
                return {
                    latest.rax,
                }
            end,
    })

assert(
    full[1]
        and full[1].value
            == second[1].value,
    "session final state diverged from full processing"
)
print("PASS register replay session: final state matches full processing")

print("PASS Tracker_HUD register-effect replay-session smoke")
