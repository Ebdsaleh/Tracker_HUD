-- tests/register_effect_processing_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local processing =
    require("tracker_hud.low_level.register_effect_processing")

local first_effect = {
    id = "mov-write",
}

local second_effect = {
    id = "mov-metadata",
}

local inc_effect = {
    id = "inc-write",
}

local effect_index = {
    by_node_type = {
        instruction = {
            __first = first_effect,

            mov = {
                first_effect,
                second_effect,
            },

            inc = {
                inc_effect,
            },
        },
    },
}

local function fake_node(
    mnemonic
)
    return {
        mnemonic = mnemonic,

        type = function()
            return "instruction"
        end,
    }
end

local nodes = {
    {
        node = fake_node("mov"),
    },
    {
        node = fake_node("inc"),
    },
}

local calls = {}
local low_level_state_seen = nil
local second_prepare_saw_first_fact =
    false

local result =
    processing.process({
        nodes = nodes,
        effect_index = effect_index,

        parse_instruction = function(
            node,
            representative
        )
            calls[#calls + 1] =
                "parse:"
                .. node.mnemonic

            assert(
                representative
                    == first_effect,
                "representative rule selection changed"
            )

            return {
                mnemonic =
                    node.mnemonic,
            }
        end,

        normalize_mnemonic = function(
            mnemonic
        )
            return mnemonic
                and mnemonic:lower()
                or nil
        end,

        new_low_level_state = function()
            local state = {
                instruction_count = 0,
            }

            low_level_state_seen =
                state

            return state
        end,

        prepare_instruction_state =
            function(
                low_level_state,
                facts_by_register,
                instruction,
                effect_specs
            )
                low_level_state
                    .instruction_count =
                    low_level_state
                        .instruction_count
                    + 1

                calls[#calls + 1] =
                    "prepare:"
                    .. instruction.mnemonic

                if instruction.mnemonic
                    == "inc"
                then
                    second_prepare_saw_first_fact =
                        facts_by_register
                            .rax
                            ~= nil
                end

                return {
                    sequence =
                        low_level_state
                            .instruction_count,
                    effect_count =
                        #(effect_specs or {}),
                }
            end,

        apply_effect = function(
            facts_by_register,
            family_state,
            latest_state_facts,
            instruction,
            effect_spec,
            instruction_state
        )
            calls[#calls + 1] =
                "apply:"
                .. instruction.mnemonic
                .. ":"
                .. effect_spec.id

            if effect_spec
                == first_effect
            then
                facts_by_register.rax = {
                    value = "41",
                }

                family_state.rax = {
                    value = "41",
                }

                latest_state_facts.rax = {
                    name = "rax",
                    value = "41",
                    sequence =
                        instruction_state
                            .sequence,
                }
            elseif effect_spec
                == inc_effect
            then
                assert(
                    family_state.rax
                        ~= nil,
                    "family state did not carry between instructions"
                )

                latest_state_facts.rax = {
                    name = "rax",
                    value = "42",
                    sequence =
                        instruction_state
                            .sequence,
                }
            end
        end,

        to_fact_list = function(
            latest_state_facts
        )
            calls[#calls + 1] =
                "finalize"

            return {
                latest_state_facts.rax,
            }
        end,
    })

assert(
    low_level_state_seen
        and low_level_state_seen
            .instruction_count
            == 2,
    "low-level state must carry across instructions"
)

assert(
    second_prepare_saw_first_fact,
    "facts_by_register must carry into later instruction preparation"
)

assert(
    result
        and #result == 1
        and result[1].name
            == "rax"
        and result[1].value
            == "42"
        and result[1].sequence
            == 2,
    "latest fact reduction/finalization changed"
)
print("PASS register effect processing: carried state and finalization preserved")

local expected_calls = {
    "parse:mov",
    "prepare:mov",
    "apply:mov:mov-write",
    "apply:mov:mov-metadata",
    "parse:inc",
    "prepare:inc",
    "apply:inc:inc-write",
    "finalize",
}

assert(
    table.concat(calls, "|")
        == table.concat(
            expected_calls,
            "|"
        ),
    "processing callback order changed: "
        .. table.concat(calls, "|")
)
print("PASS register effect processing: parse prepare apply ordering preserved")

local incomplete =
    processing.process({
        nodes = nodes,
        effect_index = effect_index,
    })

assert(
    type(incomplete) == "table"
        and #incomplete == 0,
    "incomplete processing dependencies must fail closed"
)
print("PASS register effect processing: incomplete dependencies fail closed")

print("PASS Tracker_HUD register-effect processing smoke")
