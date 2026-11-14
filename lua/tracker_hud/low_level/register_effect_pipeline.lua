-- lua/tracker_hud/low_level/register_effect_pipeline.lua
--
-- Register-effect pipeline coordination.
--
-- This module owns architecture-neutral register-effect indexing, visibility
-- collection, instruction-state preparation, effect application and reduction.
-- Adapter instruction parsing remains injected so parsing ownership stays with
-- the adapter/outer source bridge.

local core = require("tracker_hud.core")
local inference =
    require("tracker_hud.low_level.inference")
local instruction_source =
    require("tracker_hud.low_level.instruction_source")
local line_summary =
    require("tracker_hud.low_level.line_summary")
local register_effect_apply =
    require("tracker_hud.low_level.register_effect_apply")
local register_effect_collection =
    require("tracker_hud.low_level.register_effect_collection")
local register_effect_index =
    require("tracker_hud.low_level.register_effect_index")
local register_effect_processing =
    require("tracker_hud.low_level.register_effect_processing")
local register_infer =
    require("tracker_hud.low_level.register_infer")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")
local register_value_policy =
    require("tracker_hud.low_level.register_value_policy")
local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")
local stack_infer =
    require("tracker_hud.low_level.stack_infer")

local M = {}


function M.get_index(adapter)
    return register_effect_index.get(
        adapter,
        rule_syntax.index_options()
    )
end


function M.prepare_instruction_state(
    low_level_state,
    facts_by_register,
    instruction,
    effect_specs,
    adapter
)
    return stack_infer.prepare_instruction_state(
        low_level_state,
        instruction,
        effect_specs,
        {
            parse_numeric_value =
                register_value_policy
                    .parse_numeric_value,
            parse_numeric_number =
                register_value_policy
                    .parse_numeric_number,

            resolve_operand_value = function(
                operand
            )
                return register_infer
                    .resolve_operand_value(
                        facts_by_register,
                        instruction,
                        operand,
                        {
                            parse_numeric_value =
                                register_value_policy
                                    .parse_numeric_value,

                            resolve_register_fact =
                                function(
                                    register_facts,
                                    register_name
                                )
                                    return register_state_read
                                        .get_fact_for_read(
                                            register_facts,
                                            adapter,
                                            register_name
                                        )
                                end,
                        }
                    )
            end,
        }
    )
end


function M.apply_effect(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    instruction,
    effect_spec,
    instruction_state
)
    return register_effect_apply.apply(
        facts_by_register,
        family_state,
        latest_state_facts,
        adapter,
        instruction,
        effect_spec,
        instruction_state,
        {
            get_mnemonic =
                rule_syntax.get_mnemonic,
            normalize_mnemonic =
                rule_syntax.normalize_mnemonic,
        }
    )
end


local function collect_nodes(
    context,
    opts,
    effect_index
)
    return register_effect_collection.collect({
        context = context,
        config = opts.config,
        node_types =
            effect_index.node_types
            or {},
        limit_position =
            opts.limit_position,
        stop_before =
            opts.stop_before,
        before_position =
            opts.before_position,

        collect_nodes = function(
            node_type
        )
            return instruction_source
                .collect_nodes_by_type(
                    opts.root_node,
                    node_type
                )
        end,

        normalize_position =
            inference.normalize_position,
        position_is_before =
            inference.position_is_before,
        classify_position =
            line_summary
                .classify_instruction_position,
        allows_position =
            line_summary.allows_position,
    })
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
            adapter.register_effects
        )
        or type(deps.parse_instruction)
            ~= "function"
    then
        return {}
    end

    local effect_index =
        M.get_index(adapter)

    local nodes =
        collect_nodes(
            context,
            opts,
            effect_index
        )

    return register_effect_processing.process({
        nodes = nodes,
        effect_index = effect_index,

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

        new_low_level_state =
            inference.new_state,

        prepare_instruction_state = function(
            low_level_state,
            facts_by_register,
            instruction,
            effect_specs
        )
            return M.prepare_instruction_state(
                low_level_state,
                facts_by_register,
                instruction,
                effect_specs,
                adapter
            )
        end,

        apply_effect = function(
            facts_by_register,
            family_state,
            latest_state_facts,
            instruction,
            effect_spec,
            instruction_state
        )
            return M.apply_effect(
                facts_by_register,
                family_state,
                latest_state_facts,
                adapter,
                instruction,
                effect_spec,
                instruction_state
            )
        end,

        to_fact_list =
            register_infer.to_fact_list,
    })
end


return M
