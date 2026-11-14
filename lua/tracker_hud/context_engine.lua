-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local low_level_inference = require("tracker_hud.low_level.inference")
local memory_address_evaluator = require("tracker_hud.low_level.memory_address_evaluator")
local memory_source_discovery = require("tracker_hud.low_level.memory_source_discovery")
local register_source_discovery = require("tracker_hud.low_level.register_source_discovery")
local register_effect_pipeline = require("tracker_hud.low_level.register_effect_pipeline")
local line_summary = require("tracker_hud.low_level.line_summary")
local stack_effect_index = require("tracker_hud.low_level.stack_effect_index")
local boundary_effect_pipeline = require("tracker_hud.low_level.boundary_effect_pipeline")
local instruction_event_pipeline = require("tracker_hud.low_level.instruction_event_pipeline")
local stack_effect_apply = require("tracker_hud.low_level.stack_effect_apply")
local stack_effect_collection = require("tracker_hud.low_level.stack_effect_collection")
local instruction_source = require("tracker_hud.low_level.instruction_source")
local instruction_parser_dispatch = require("tracker_hud.low_level.instruction_parser_dispatch")
local rule_syntax = require("tracker_hud.low_level.rule_syntax")
local context_primitives = require("tracker_hud.constructs.context_primitives")
local branch_presentation = require("tracker_hud.constructs.branch_presentation")
local construct_spec_validation = require("tracker_hud.constructs.spec_validation")
local construct_source_identity = require("tracker_hud.constructs.source_identity")
local construct_parser = require("tracker_hud.constructs.parser")
local register_infer = require("tracker_hud.low_level.register_infer")
local register_value_policy = require("tracker_hud.low_level.register_value_policy")
local stack_infer = require("tracker_hud.low_level.stack_infer")

local M = {}



local get_rule_mnemonic =
    rule_syntax.get_mnemonic

local normalize_mnemonic =
    rule_syntax.normalize_mnemonic

local rule_index_options =
    rule_syntax.index_options()


local get_register_effect_index =
    register_effect_pipeline.get_index

local apply_register_effect =
    register_effect_pipeline.apply_effect


local parse_instruction_with_adapter =
    instruction_parser_dispatch.parse


M.make_global_context =
    context_primitives.make_global_context

M.make_unavailable_context =
    context_primitives.make_unavailable_context


M.get_first_line_text =
    construct_source_identity.get_first_line_text

M.build_signature =
    construct_source_identity.build_signature

M.extract_name_from_signature =
    construct_source_identity.extract_name_from_signature

M.extract_name_from_syntax =
    construct_source_identity.extract_name_from_syntax

M.build_construct =
    construct_source_identity.build_construct


M.get_cursor_position =
    context_primitives.get_cursor_position

M.get_cursor_location =
    context_primitives.get_cursor_location


function M.resolve_line_summary_options(config)
    return line_summary.resolve_options(config)
end


function M.classify_instruction_cursor_position(
    instruction_start_column,
    instruction_end_column,
    source_column
)
    return line_summary.classify_instruction_position(
        instruction_start_column,
        instruction_end_column,
        source_column
    )
end


function M.line_summary_allows_position(
    config,
    position
)
    return line_summary.allows_position(
        config,
        position
    )
end


function M.get_compiled_line_instruction_range(
    compiled_line
)
    return line_summary.get_compiled_line_instruction_range(
        compiled_line
    )
end


function M.classify_compiled_line_cursor_position(
    compiled_line,
    source_column
)
    return line_summary.classify_compiled_line_position(
        compiled_line,
        source_column
    )
end


function M.line_summary_allows_compiled_line_position(
    config,
    compiled_line,
    source_column
)
    return line_summary.allows_compiled_line_position(
        config,
        compiled_line,
        source_column
    )
end


M.format_branch_display_label =
    branch_presentation.format_display_label

M.node_matches_branch_alternative =
    branch_presentation.node_matches_alternative

M.get_node_alternatives =
    branch_presentation.get_node_alternatives

M.get_branch_alternative_label =
    branch_presentation.get_alternative_label

M.build_branch_display_label =
    branch_presentation.build_display_label


M.position_in_node =
    context_primitives.position_in_node

M.get_node_type =
    context_primitives.get_node_type

M.get_first_node_line =
    context_primitives.get_first_node_line

M.build_scope_entry_from_construct =
    context_primitives.build_scope_entry_from_construct

M.build_context_from_scopes =
    context_primitives.build_context_from_scopes

M.get_node_range =
    context_primitives.get_node_range


M.match_node =
    construct_parser.match_node

M.parse_node =
    construct_parser.parse_node


M.get_construct_spec =
    construct_spec_validation.get

M.validate_construct_spec =
    construct_spec_validation.validate


local function instruction_source_options()
    return {
        parse_with_adapter =
            parse_instruction_with_adapter,
        get_node_text =
            ts_utils.get_node_text,
    }
end


local function collect_instruction_operands(
    adapter,
    node,
    bufnr,
    effect_spec
)
    return instruction_source.collect_instruction(
        adapter,
        node,
        bufnr,
        effect_spec,
        instruction_source_options()
    )
end


local function collect_nodes_by_type(
    node,
    node_type,
    result
)
    return instruction_source.collect_nodes_by_type(
        node,
        node_type,
        result
    )
end


local parse_numeric_value =
    register_value_policy.parse_numeric_value

local parse_numeric_number =
    register_value_policy.parse_numeric_number


function M.collect_register_effects(
    context,
    adapter,
    opts
)
    opts = opts or {}

    return register_effect_pipeline.collect(
        context,
        adapter,
        opts,
        {
            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    opts.bufnr,
                    representative_effect_spec
                )
            end,
        }
    )
end


-- Source-time address evaluation is shared by memory and register discovery.-- Source-time address evaluation is shared by memory and register discovery.


local function evaluate_memory_address_before_instruction(
    bufnr,
    root_node,
    adapter,
    instruction,
    address,
    machine_addresses,
    instruction_relative_policy
)
    return memory_address_evaluator.evaluate(
        bufnr,
        root_node,
        adapter,
        instruction,
        address,
        machine_addresses,
        instruction_relative_policy,
        {
            collect_register_effects =
                M.collect_register_effects,
        }
    )
end


local function collect_memory_source_operands_where(
    bufnr,
    root_node,
    adapter,
    line_predicate,
    opts
)
    return memory_source_discovery.collect(
        bufnr,
        root_node,
        adapter,
        line_predicate,
        opts,
        {
            get_register_effect_index =
                get_register_effect_index,

            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    bufnr,
                    representative_effect_spec
                )
            end,

            evaluate_address = function(
                instruction,
                address,
                machine_addresses,
                instruction_relative_policy
            )
                return evaluate_memory_address_before_instruction(
                    bufnr,
                    root_node,
                    adapter,
                    instruction,
                    address,
                    machine_addresses,
                    instruction_relative_policy
                )
            end,
        }
    )
end


function M.discover_memory_source_operands(
    bufnr,
    root_node,
    adapter,
    line_number,
    opts
)
    if not core.is_number(line_number) then
        return {}
    end

    local exact_line = math.floor(line_number)

    return collect_memory_source_operands_where(
        bufnr,
        root_node,
        adapter,
        function(source_line)
            return source_line == exact_line
        end,
        opts
    )
end


function M.collect_memory_source_operands(
    bufnr,
    root_node,
    adapter,
    cursor_line,
    opts
)
    if not core.is_number(cursor_line) then
        return {}
    end

    local visible_line = math.floor(cursor_line)

    return collect_memory_source_operands_where(
        bufnr,
        root_node,
        adapter,
        function(source_line)
            return source_line <= visible_line
        end,
        opts
    )
end


function M.discover_register_source_occurrences(
    bufnr,
    root_node,
    adapter,
    line_number,
    opts
)
    return register_source_discovery.collect(
        bufnr,
        root_node,
        adapter,
        line_number,
        opts,
        {
            get_register_effect_index =
                get_register_effect_index,

            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    bufnr,
                    representative_effect_spec
                )
            end,

            evaluate_address = function(
                instruction,
                address,
                machine_addresses,
                instruction_relative_policy
            )
                return evaluate_memory_address_before_instruction(
                    bufnr,
                    root_node,
                    adapter,
                    instruction,
                    address,
                    machine_addresses,
                    instruction_relative_policy
                )
            end,
        }
    )
end


function M.collect_boundary_effects(
    context,
    adapter,
    opts
)
    opts = opts or {}

    return boundary_effect_pipeline.collect(
        context,
        adapter,
        opts,
        {
            parse_instruction = function(
                node,
                representative_effect_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    opts.bufnr,
                    representative_effect_spec
                )
            end,

            collect_register_effects =
                M.collect_register_effects,
        }
    )
end


function M.collect_instruction_events(
    context,
    adapter,
    opts
)
    opts = opts or {}

    return instruction_event_pipeline.collect(
        context,
        adapter,
        opts,
        {
            parse_instruction = function(
                node,
                representative_event_spec
            )
                return collect_instruction_operands(
                    adapter,
                    node,
                    opts.bufnr,
                    representative_event_spec
                )
            end,
        }
    )
end


local function get_stack_effect_index(adapter)
    return stack_effect_index.get(
        adapter,
        rule_index_options
    )
end


local function apply_stack_effect(
    facts,
    adapter,
    instruction,
    effect_spec,
    instruction_state
)
    return stack_effect_apply.apply(
        facts,
        adapter,
        instruction,
        effect_spec,
        instruction_state,
        {
            get_mnemonic =
                get_rule_mnemonic,
            normalize_mnemonic =
                normalize_mnemonic,
        }
    )
end


local function collect_stack_effects_with_module(
    context,
    adapter,
    opts,
    stack_index,
    register_index
)
    opts = opts or {}

    local carried_family_state = {}
    local carried_latest_state_facts = {}

    return stack_effect_collection.collect({
        context = context,
        stack_effect_index = stack_index,
        register_effect_index = register_index,

        collect_nodes = function(node_type)
            return collect_nodes_by_type(
                opts.root_node,
                node_type
            )
        end,

        parse_instruction = function(
            node,
            representative_effect_spec
        )
            return collect_instruction_operands(
                adapter,
                node,
                opts.bufnr,
                representative_effect_spec
            )
        end,

        normalize_mnemonic =
            normalize_mnemonic,

        new_state =
            low_level_inference.new_state,

        prepare_stack_state = function(
            low_level_state,
            facts_by_register,
            instruction,
            stack_effect_specs
        )
            return stack_infer.prepare_instruction_state(
                low_level_state,
                instruction,
                stack_effect_specs,
                {
                    parse_numeric_value =
                        parse_numeric_value,
                    parse_numeric_number =
                        parse_numeric_number,
                    resolve_operand_value = function(
                        operand
                    )
                        return register_infer.resolve_operand_value(
                            facts_by_register,
                            instruction,
                            operand,
                            {
                                parse_numeric_value =
                                    parse_numeric_value,
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
            apply_stack_effect(
                facts,
                adapter,
                instruction,
                effect_spec,
                instruction_state
            )
        end,

        apply_register_effect = function(
            facts_by_register,
            instruction,
            effect_spec,
            instruction_state
        )
            apply_register_effect(
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


function M.collect_stack_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.stack_effects
        )
    then
        return {}
    end

    return collect_stack_effects_with_module(
        context,
        adapter,
        opts,
        get_stack_effect_index(adapter),
        get_register_effect_index(adapter)
    )
end

return M
