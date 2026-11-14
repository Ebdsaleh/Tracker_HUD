-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local low_level_inference = require("tracker_hud.low_level.inference")
local memory_access = require("tracker_hud.low_level.memory_access")
local effective_address = require("tracker_hud.low_level.effective_address")
local relative_address = require("tracker_hud.low_level.relative_address")
local memory_source_evidence = require("tracker_hud.low_level.memory_source_evidence")
local memory_source_collection = require("tracker_hud.low_level.memory_source_collection")
local operand_metadata = require("tracker_hud.low_level.operand_metadata")
local register_source_occurrence = require("tracker_hud.low_level.register_source_occurrence")
local register_source_collection = require("tracker_hud.low_level.register_source_collection")
local register_effect_index = require("tracker_hud.low_level.register_effect_index")
local register_source_metadata = require("tracker_hud.low_level.register_source_metadata")
local line_summary = require("tracker_hud.low_level.line_summary")
local register_effect_collection = require("tracker_hud.low_level.register_effect_collection")
local register_effect_processing = require("tracker_hud.low_level.register_effect_processing")
local instruction_event_index = require("tracker_hud.low_level.instruction_event_index")
local boundary_effect_index = require("tracker_hud.low_level.boundary_effect_index")
local stack_effect_index = require("tracker_hud.low_level.stack_effect_index")
local boundary_effect_collection = require("tracker_hud.low_level.boundary_effect_collection")
local boundary_effect_apply = require("tracker_hud.low_level.boundary_effect_apply")\nlocal boundary_register_context = require("tracker_hud.low_level.boundary_register_context")
local stack_effect_apply = require("tracker_hud.low_level.stack_effect_apply")\nlocal stack_effect_collection = require("tracker_hud.low_level.stack_effect_collection")
local instruction_event_collection = require("tracker_hud.low_level.instruction_event_collection")
local instruction_event_fact = require("tracker_hud.low_level.instruction_event_fact")
local effect_match = require("tracker_hud.low_level.effect_match")
local instruction_source = require("tracker_hud.low_level.instruction_source")
local instruction_parser_dispatch = require("tracker_hud.low_level.instruction_parser_dispatch")
local syntax_spec = require("tracker_hud.syntax_spec")
local context_primitives = require("tracker_hud.constructs.context_primitives")
local branch_presentation = require("tracker_hud.constructs.branch_presentation")
local construct_spec_validation = require("tracker_hud.constructs.spec_validation")
local construct_source_identity = require("tracker_hud.constructs.source_identity")
local construct_parser = require("tracker_hud.constructs.parser")
local scope_members = require("tracker_hud.scope_members")
local register_infer = require("tracker_hud.low_level.register_infer")
local register_state_read = require("tracker_hud.low_level.register_state_read")
local register_state_write = require("tracker_hud.low_level.register_state_write")
local register_value_policy = require("tracker_hud.low_level.register_value_policy")
local register_fact_builder = require("tracker_hud.low_level.register_fact_builder")
local stack_infer = require("tracker_hud.low_level.stack_infer")
local stack_effect_match = require("tracker_hud.low_level.stack_effect_match")

local M = {}



local get_syntax_node_type =
    syntax_spec.get_node_type

local get_syntax_field =
    syntax_spec.get_field

local get_syntax_field_text =
    syntax_spec.get_field_text

local normalize_mnemonic =
    syntax_spec.normalize_mnemonic


local function get_register_effect_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(effect_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(effect_spec, "kind")
        or effect_spec.mnemonic
        or fallback_mnemonic
    )
end


local function get_register_effect_index(adapter)
    return register_effect_index.get(
        adapter,
        {
            get_node_type = function(effect_spec)
                if not core.is_table(effect_spec) then
                    return nil
                end

                return get_syntax_node_type(
                    effect_spec
                )
                    or effect_spec.node_type
            end,
            get_mnemonic =
                get_register_effect_mnemonic,
        }
    )
end


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


local operands_match_effect =
    effect_match.operands_match_effect

local condition_matches =
    effect_match.condition_matches


local get_static_register_spec =
    register_state_read.get_static_spec

local get_register_fact_from_map =
    register_state_read.get_fact

local get_register_fact_for_read =
    register_state_read.get_fact_for_read

local get_register_value_width =
    register_state_read.get_value_width


local apply_register_value_width_policy =
    register_value_policy.apply_width_policy

local parse_numeric_value =
    register_value_policy.parse_numeric_value

local parse_numeric_number =
    register_value_policy.parse_numeric_number


local register_fact_is_resolved =
    register_state_read.fact_is_resolved


local function prepare_register_instruction_inference_state(
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
            parse_numeric_value = parse_numeric_value,
            parse_numeric_number = parse_numeric_number,
            resolve_operand_value = function(operand)
                return register_infer.resolve_operand_value(
                    facts_by_register,
                    instruction,
                    operand,
                    {
                        parse_numeric_value = parse_numeric_value,
                        resolve_register_fact = function(
                            register_facts,
                            register_name
                        )
                            return get_register_fact_for_read(
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


local make_register_fact =
    register_fact_builder.build


local function apply_register_effect(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    instruction,
    effect_spec,
    instruction_state
)
    if not core.is_table(facts_by_register)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    local expected_mnemonic =
        get_register_effect_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return
    end

    if not operands_match_effect(instruction, effect_spec) then
        return
    end

    if not condition_matches(instruction, effect_spec.condition) then
        return
    end

    local fact = make_register_fact(
        facts_by_register,
        family_state,
        adapter,
        instruction,
        effect_spec,
        instruction_state
    )

    if fact then
        register_state_write.publish(
            facts_by_register,
            family_state,
            latest_state_facts,
            adapter,
            fact
        )
    end
end


local function collect_register_effect_nodes(
    context,
    root_node,
    effect_index,
    opts
)
    opts = opts or {}

    return register_effect_collection.collect({
        context = context,
        config = opts.config,
        node_types = effect_index
            and effect_index.node_types
            or {},
        limit_position = opts.limit_position,
        stop_before = opts.stop_before,
        before_position = opts.before_position,

        collect_nodes = function(node_type)
            return collect_nodes_by_type(
                root_node,
                node_type
            )
        end,

        normalize_position =
            low_level_inference.normalize_position,
        position_is_before =
            low_level_inference.position_is_before,
        classify_position =
            M.classify_instruction_cursor_position,
        allows_position =
            M.line_summary_allows_position,
    })
end


function M.collect_register_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(adapter.register_effects)
    then
        return {}
    end

    local effect_index =
        get_register_effect_index(adapter)

    local nodes =
        collect_register_effect_nodes(
            context,
            root_node,
            effect_index,
            opts
        )

    return register_effect_processing.process({
        nodes = nodes,
        effect_index = effect_index,

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

        normalize_mnemonic =
            normalize_mnemonic,

        new_low_level_state =
            low_level_inference.new_state,

        prepare_instruction_state = function(
            low_level_state,
            facts_by_register,
            instruction,
            effect_specs
        )
            return prepare_register_instruction_inference_state(
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
            return apply_register_effect(
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


--
-- Discover source occurrences for explicit Registers inspection.
--
-- Register state remains line-based, while Inspect selection is occurrence-based.
-- This function does not mutate register state and does not render HUD nodes.
-- It describes which presentation register rows are addressed by the exact
-- Tree-sitter mnemonic/operand occurrences on one source line.
--

local function get_register_operand_occurrence_role(
    effect_specs,
    operand_index
)
    for _, effect_spec in ipairs(effect_specs or {}) do
        for _, operand_spec in ipairs(effect_spec.operands or {}) do
            if tonumber(operand_spec.index) == operand_index then
                local role = register_source_occurrence.normalize_role(
                    operand_spec.role
                )

                if role then
                    return role
                end
            end
        end
    end

    return nil
end


local function get_matching_register_effect_specs(
    effect_index,
    adapter,
    instruction_node,
    bufnr
)
    return register_effect_index.match_node(
        effect_index,
        instruction_node,
        {
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
            operands_match =
                operands_match_effect,
            condition_match =
                condition_matches,
        }
    )
end


local function build_source_written_role(instruction, operand)
    local kind_label = operand_metadata.kind_label(
        core.is_table(operand) and operand.kind or nil
    ) or "source"

    local mnemonic = instruction and instruction.mnemonic or nil

    if kind_label == "memory" then
        return "loaded from memory"
            .. (mnemonic and " by " .. mnemonic or "")
    end

    return "written from "
        .. kind_label
        .. (mnemonic and " by " .. mnemonic or "")
end


local function get_memory_operand_role(
    effect_specs,
    operand_index
)
    local role = nil

    for _, effect_spec in ipairs(effect_specs or {}) do
        local operand_spec =
            register_source_metadata.get_effect_operand_spec(
                effect_spec,
                operand_index
            )

        if core.is_table(operand_spec)
            and core.is_non_empty_string(operand_spec.role)
        then
            role = role or operand_spec.role
        end
    end

    return role
end


local function register_fact_map_from_list(facts)
    local result = {}

    for _, fact in ipairs(facts or {}) do
        if core.is_table(fact)
            and core.is_non_empty_string(fact.name)
        then
            result[fact.name:lower()] = fact

            local canonical = fact.metadata
                and fact.metadata.canonical_name

            if core.is_non_empty_string(canonical) then
                result[canonical:lower()] = fact
            end
        end
    end

    return result
end


local function evaluate_memory_address_before_instruction(
    bufnr,
    root_node,
    adapter,
    instruction,
    address,
    machine_addresses,
    instruction_relative_policy
)
    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(address)
    then
        return {
            status = "unknown",
            value = nil,
            reason = "evaluation context unavailable",
        }
    end

    local line = instruction.source_start_line
        or instruction.source_line
    local column = instruction.source_start_column
        or instruction.source_column
        or 0

    if not core.is_number(line) then
        return {
            status = "unknown",
            value = nil,
            reason = "instruction position unavailable",
        }
    end

    if relative_address.requires_next_instruction(
        address,
        {
            instruction_relative_policy =
                instruction_relative_policy,
        }
    )
    then
        return relative_address.evaluate(
            address,
            machine_addresses,
            {
                bits = adapter.metadata
                    and adapter.metadata.bits
                    or nil,
                instruction_relative_policy =
                    instruction_relative_policy,
            }
        )
    end

    local facts = M.collect_register_effects(
        {
            cursor = {
                line = line,
                column = column + 1,
            },
        },
        adapter,
        {
            bufnr = bufnr,
            root_node = root_node,
            limit_position = {
                line = line,
                column = column,
            },
        }
    )

    local facts_by_register = register_fact_map_from_list(
        facts
    )

    local bits = adapter.metadata
        and adapter.metadata.bits
        or nil

    return effective_address.evaluate(address, {
        bits = bits,
        resolve_register = function(register_name)
            local fact = get_register_fact_for_read(
                facts_by_register,
                adapter,
                register_name
            )

            if not register_fact_is_resolved(fact) then
                local partial = fact
                    and fact.metadata
                    and fact.metadata.partial_value
                    or nil

                return nil, {
                    status = partial and "partial" or "unknown",
                    fact_name = fact and fact.name or nil,
                    partial_value = partial,
                }
            end

            return fact.value, {
                status = "known",
                fact_name = fact.name,
            }
        end,
    })
end


local function collect_memory_source_operands_where(
    bufnr,
    root_node,
    adapter,
    line_predicate,
    opts
)
    opts = opts or {}

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or type(line_predicate) ~= "function"
    then
        return {}
    end

    local instruction_spec =
        core.is_table(adapter.construct_specs)
        and adapter.construct_specs.instruction
        or nil
    local syntax =
        core.is_table(instruction_spec)
        and instruction_spec.syntax
        or nil
    local instruction_node_type =
        core.is_table(syntax)
        and core.is_non_empty_string(
            syntax.node_type
        )
        and syntax.node_type
        or "instruction"

    local effect_index =
        core.is_table(adapter.register_effects)
        and get_register_effect_index(adapter)
        or nil

    local source_members = scope_members.collect(
        bufnr,
        root_node,
        adapter
    )

    return memory_source_collection.collect({
        nodes = collect_nodes_by_type(
            root_node,
            instruction_node_type
        ),
        adapter = adapter,
        source_members = source_members,
        line_predicate = line_predicate,
        machine_address_providers =
            opts.machine_address_providers,

        parse_instruction = function(node)
            return collect_instruction_operands(
                adapter,
                node,
                bufnr,
                nil
            )
        end,

        match_effects = function(
            node,
            instruction
        )
            local matching_specs = {}

            if not instruction
                or not effect_index
            then
                return matching_specs
            end

            local node_bucket =
                effect_index.by_node_type[
                    node:type()
                ]

            local mnemonic =
                normalize_mnemonic(
                    instruction.mnemonic
                )

            local candidates =
                node_bucket
                and mnemonic
                and node_bucket[mnemonic]
                or nil

            for _, effect_spec in ipairs(
                candidates or {}
            ) do
                if operands_match_effect(
                    instruction,
                    effect_spec
                )
                    and condition_matches(
                        instruction,
                        effect_spec.condition
                    )
                then
                    table.insert(
                        matching_specs,
                        effect_spec
                    )
                end
            end

            return matching_specs
        end,

        evaluate_address = function(
            instruction,
            address,
            machine_addresses,
            instruction_relative_policy
        )
            return
                evaluate_memory_address_before_instruction(
                    bufnr,
                    root_node,
                    adapter,
                    instruction,
                    address,
                    machine_addresses,
                    instruction_relative_policy
                )
        end,

        get_operand_role =
            get_memory_operand_role,

        resolve_access = function(
            instruction,
            operand_index,
            operand
        )
            return memory_access.resolve(
                adapter
                    and adapter.memory_accesses,
                instruction.mnemonic,
                operand_index,
                operand
            )
        end,
    })
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
    opts = opts or {}

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(adapter.register_effects)
        or not core.is_number(line_number)
    then
        return {}
    end

    local effect_index =
        get_register_effect_index(adapter)

    local source_members =
        scope_members.collect(
            bufnr,
            root_node,
            adapter
        )

    return register_source_collection.collect({
        adapter = adapter,
        line_number = line_number,
        node_types = effect_index.node_types,
        source_members = source_members,
        machine_address_providers =
            opts.machine_address_providers,

        collect_nodes = function(node_type)
            return collect_nodes_by_type(
                root_node,
                node_type
            )
        end,

        parse_and_match = function(node)
            return get_matching_register_effect_specs(
                effect_index,
                adapter,
                node,
                bufnr
            )
        end,

        evaluate_address = function(
            instruction,
            address,
            machine_addresses,
            instruction_relative_policy
        )
            return
                evaluate_memory_address_before_instruction(
                    bufnr,
                    root_node,
                    adapter,
                    instruction,
                    address,
                    machine_addresses,
                    instruction_relative_policy
                )
        end,
    })
end


local function get_boundary_effect_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(effect_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(effect_spec, "kind")
        or effect_spec.mnemonic
        or fallback_mnemonic
    )
end


local function get_boundary_effect_index(adapter)
    return boundary_effect_index.get(
        adapter,
        {
            get_node_type = function(effect_spec)
                if not core.is_table(effect_spec) then
                    return nil
                end

                return get_syntax_node_type(
                    effect_spec
                )
                    or effect_spec.node_type
            end,
            get_mnemonic =
                get_boundary_effect_mnemonic,
        }
    )
end


-- Boundary read/write/not-preserved inference lives in
-- tracker_hud.low_level.boundary_infer. Context engine keeps only syntax/node
-- selection and adapter matching concerns here.


local function collect_registers_before_instruction(
    context,
    adapter,
    opts,
    instruction
)
    return boundary_register_context.collect(
        context,
        adapter,
        opts,
        instruction,
        {
            collect_register_effects =
                M.collect_register_effects,
        }
    )
end


local function apply_boundary_effect(
    facts,
    context,
    adapter,
    instruction,
    effect_spec,
    phase_contexts
)
    return boundary_effect_apply.apply(
        facts,
        context,
        adapter,
        instruction,
        effect_spec,
        phase_contexts,
        {
            get_mnemonic =
                get_boundary_effect_mnemonic,
            normalize_mnemonic =
                normalize_mnemonic,
        }
    )
end


local function collect_boundary_effects_with_module(
    context,
    adapter,
    opts,
    effect_index
)
    opts = opts or {}

    return boundary_effect_collection.collect({
        context = context,
        effect_index = effect_index,

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

        collect_read_context = function(
            instruction
        )
            return collect_registers_before_instruction(
                context,
                adapter,
                opts,
                instruction
            )
        end,

        apply_effect = function(
            facts,
            instruction,
            effect_spec,
            phase_contexts
        )
            apply_boundary_effect(
                facts,
                context,
                adapter,
                instruction,
                effect_spec,
                phase_contexts
            )
        end,
    })
end


function M.collect_boundary_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.boundary_effects
        )
    then
        return {}
    end

    return collect_boundary_effects_with_module(
        context,
        adapter,
        opts,
        get_boundary_effect_index(adapter)
    )
end


local function get_instruction_event_mnemonic(
    event_spec,
    fallback_mnemonic
)
    if not core.is_table(event_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(event_spec, "kind")
        or event_spec.mnemonic
        or fallback_mnemonic
    )
end


local function get_instruction_event_index(adapter)
    return instruction_event_index.get(
        adapter,
        {
            get_node_type = function(event_spec)
                if not core.is_table(event_spec) then
                    return nil
                end

                return get_syntax_node_type(
                    event_spec
                )
                    or event_spec.node_type
            end,
            get_mnemonic =
                get_instruction_event_mnemonic,
        }
    )
end


local function instruction_event_matches(
    instruction,
    event_spec
)
    return instruction_event_index.matches(
        instruction,
        event_spec,
        {
            get_mnemonic =
                get_instruction_event_mnemonic,
        }
    )
end


local function apply_instruction_event(
    facts,
    context,
    adapter,
    instruction,
    event_spec
)
    return instruction_event_fact.apply(
        facts,
        context,
        adapter,
        instruction,
        event_spec,
        {
            matches =
                instruction_event_matches,
            get_mnemonic =
                get_instruction_event_mnemonic,
        }
    )
end


local function collect_instruction_events_with_module(
    context,
    adapter,
    opts,
    event_index
)
    opts = opts or {}

    return instruction_event_collection.collect({
        context = context,
        event_index = event_index,

        collect_nodes = function(node_type)
            return collect_nodes_by_type(
                opts.root_node,
                node_type
            )
        end,

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

        normalize_mnemonic =
            normalize_mnemonic,

        apply_event = function(
            facts,
            instruction,
            event_spec
        )
            apply_instruction_event(
                facts,
                context,
                adapter,
                instruction,
                event_spec
            )
        end,
    })
end


function M.collect_instruction_events(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.instruction_events
        )
    then
        return {}
    end

    return collect_instruction_events_with_module(
        context,
        adapter,
        opts,
        get_instruction_event_index(adapter)
    )
end


local function get_stack_effect_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(effect_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(effect_spec, "kind")
        or effect_spec.mnemonic
        or fallback_mnemonic
    )
end


local function get_stack_effect_index(adapter)
    return stack_effect_index.get(
        adapter,
        {
            get_node_type = function(effect_spec)
                if not core.is_table(effect_spec) then
                    return nil
                end

                return get_syntax_node_type(
                    effect_spec
                )
                    or effect_spec.node_type
            end,
            get_mnemonic =
                get_stack_effect_mnemonic,
        }
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
                get_stack_effect_mnemonic,
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
