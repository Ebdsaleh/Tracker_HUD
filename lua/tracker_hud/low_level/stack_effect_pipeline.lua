-- lua/tracker_hud/low_level/stack_effect_pipeline.lua
--
-- Stack-effect pipeline coordination.
--
-- This module owns the mixed stack/register source traversal needed for stack
-- inference, including stack state preparation and carried register state.
-- Register semantics themselves remain owned by register_effect_pipeline.

local core = require("tracker_hud.core")
local inference =
    require("tracker_hud.low_level.inference")
local instruction_source =
    require("tracker_hud.low_level.instruction_source")
local register_effect_pipeline =
    require("tracker_hud.low_level.register_effect_pipeline")
local register_infer =
    require("tracker_hud.low_level.register_infer")
local register_value_policy =
    require("tracker_hud.low_level.register_value_policy")
local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")
local stack_effect_apply =
    require("tracker_hud.low_level.stack_effect_apply")
local stack_effect_collection =
    require("tracker_hud.low_level.stack_effect_collection")
local stack_effect_index =
    require("tracker_hud.low_level.stack_effect_index")
local stack_infer =
    require("tracker_hud.low_level.stack_infer")

local M = {}


local function get_stack_index(adapter)
    return stack_effect_index.get(
        adapter,
        rule_syntax.index_options()
    )
end


function M.collect(
    context,
    adapter,
    opts,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not opts.bufnr
        or not opts.root_node
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.stack_effects
        )
        or type(deps.parse_instruction)
            ~= "function"
    then
        return {}
    end

    local carried_family_state = {}
    local carried_latest_state_facts = {}

    return stack_effect_collection.collect({
        context = context,
        stack_effect_index =
            get_stack_index(adapter),
        register_effect_index =
            register_effect_pipeline
                .get_index(adapter),

        collect_nodes = function(
            node_type
        )
            return instruction_source
                .collect_nodes_by_type(
                    opts.root_node,
                    node_type
                )
        end,

        parse_instruction = function(
            node,
            representative_effect_spec
        )
            return deps.parse_instruction(
                node,
                representative_effect_spec
            )
        end,

        normalize_mnemonic =
            rule_syntax.normalize_mnemonic,

        new_state =
            inference.new_state,

        prepare_stack_state = function(
            low_level_state,
            facts_by_register,
            instruction,
            stack_effect_specs
        )
            return stack_infer
                .prepare_instruction_state(
                    low_level_state,
                    instruction,
                    stack_effect_specs,
                    {
                        parse_numeric_value =
                            register_value_policy
                                .parse_numeric_value,
                        parse_numeric_number =
                            register_value_policy
                                .parse_numeric_number,

                        resolve_operand_value =
                            function(operand)
                                return register_infer
                                    .resolve_operand_value(
                                        facts_by_register,
                                        instruction,
                                        operand,
                                        {
                                            parse_numeric_value =
                                                register_value_policy
                                                    .parse_numeric_value,
                                        }
                                    )
                            end,
                    }
                )
        end,

        apply_stack_effect = function(
            facts,
            instruction,
            effect_spec,
            instruction_state
        )
            stack_effect_apply.apply(
                facts,
                adapter,
                instruction,
                effect_spec,
                instruction_state,
                {
                    get_mnemonic =
                        rule_syntax.get_mnemonic,
                    normalize_mnemonic =
                        rule_syntax
                            .normalize_mnemonic,
                }
            )
        end,

        apply_register_effect = function(
            facts_by_register,
            instruction,
            effect_spec,
            instruction_state
        )
            register_effect_pipeline
                .apply_effect(
                    facts_by_register,
                    carried_family_state,
                    carried_latest_state_facts,
                    adapter,
                    instruction,
                    effect_spec,
                    instruction_state
                )
        end,
    })
end


return M
