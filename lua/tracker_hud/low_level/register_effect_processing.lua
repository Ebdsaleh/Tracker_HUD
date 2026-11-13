-- lua/tracker_hud/low_level/register_effect_processing.lua
--
-- Register-effect processing orchestration.
--
-- This module owns temporary state containers and the ordered processing loop
-- over already-collected instruction nodes. Register semantics remain in the
-- injected callbacks.

local M = {}


function M.process(opts)
    opts = opts or {}

    if type(opts.effect_index) ~= "table"
        or type(opts.effect_index.by_node_type)
            ~= "table"
        or type(opts.parse_instruction)
            ~= "function"
        or type(opts.normalize_mnemonic)
            ~= "function"
        or type(opts.new_low_level_state)
            ~= "function"
        or type(opts.prepare_instruction_state)
            ~= "function"
        or type(opts.apply_effect)
            ~= "function"
        or type(opts.to_fact_list)
            ~= "function"
    then
        return {}
    end

    local facts_by_register = {}
    local family_state = {}
    local latest_state_facts = {}

    local low_level_state =
        opts.new_low_level_state()

    for _, entry in ipairs(
        opts.nodes or {}
    ) do
        local node =
            entry and entry.node
            or nil

        if node then
            local node_type =
                node:type()

            local node_bucket =
                opts.effect_index
                    .by_node_type[
                        node_type
                    ]

            if node_bucket then
                local representative_effect_spec =
                    node_bucket.__first

                local instruction =
                    opts.parse_instruction(
                        node,
                        representative_effect_spec
                    )

                local mnemonic =
                    instruction
                    and opts.normalize_mnemonic(
                        instruction.mnemonic
                    )
                    or nil

                local effect_specs =
                    mnemonic
                    and node_bucket[mnemonic]
                    or nil

                local instruction_state =
                    opts.prepare_instruction_state(
                        low_level_state,
                        facts_by_register,
                        instruction,
                        effect_specs
                    )

                for _, effect_spec in ipairs(
                    effect_specs or {}
                ) do
                    opts.apply_effect(
                        facts_by_register,
                        family_state,
                        latest_state_facts,
                        instruction,
                        effect_spec,
                        instruction_state
                    )
                end
            end
        end
    end

    return opts.to_fact_list(
        latest_state_facts
    )
end


return M
