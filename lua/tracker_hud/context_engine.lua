-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local low_level_inference = require("tracker_hud.low_level.inference")
local integer_value = require("tracker_hud.low_level.integer_value")
local integer_operand = require("tracker_hud.low_level.integer_operand")
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
local instruction_event_index = require("tracker_hud.low_level.instruction_event_index")
local boundary_effect_index = require("tracker_hud.low_level.boundary_effect_index")
local stack_effect_index = require("tracker_hud.low_level.stack_effect_index")
local boundary_effect_collection = require("tracker_hud.low_level.boundary_effect_collection")
local stack_effect_collection = require("tracker_hud.low_level.stack_effect_collection")
local instruction_event_collection = require("tracker_hud.low_level.instruction_event_collection")
local effect_match = require("tracker_hud.low_level.effect_match")
local instruction_source = require("tracker_hud.low_level.instruction_source")
local instruction_parser_dispatch = require("tracker_hud.low_level.instruction_parser_dispatch")
local syntax_spec = require("tracker_hud.syntax_spec")
local context_primitives = require("tracker_hud.constructs.context_primitives")
local scope_members = require("tracker_hud.scope_members")
local register_infer = require("tracker_hud.low_level.register_infer")
local register_value_mask = require("tracker_hud.low_level.register_value_mask")
local stack_infer = require("tracker_hud.low_level.stack_infer")
local boundary_infer = require("tracker_hud.low_level.boundary_infer")
local control_infer = require("tracker_hud.low_level.control_infer")

local M = {}



local get_syntax =
    syntax_spec.get

local get_syntax_node_type =
    syntax_spec.get_node_type

local get_syntax_field =
    syntax_spec.get_field

local get_syntax_field_text =
    syntax_spec.get_field_text

local get_syntax_tokens =
    syntax_spec.get_tokens

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


function M.get_first_line_text(node, bufnr)
    local ok, node_text = pcall(vim.treesitter.get_node_text, node, bufnr)

    if not ok or not node_text then
        return nil
    end

    return node_text:match("([^\n]+)")
end


function M.build_signature(node, bufnr, spec)
    if not core.is_table(spec) or not core.is_table(spec.signature) then
        return nil
    end

    if spec.signature.strategy ~= "first_line" then
        return nil
    end

    return M.get_first_line_text(node, bufnr)

end


function M.extract_name_from_signature(signature, spec)
    if type(signature) ~= "string" then
        return nil
    end
    
    if not core.is_table(spec) or not core.is_table(spec.signature) then
        return nil
    end

    local signature_spec = spec.signature

    if type(signature_spec.local_name_pattern) == "string" then
        local name = signature:match(signature_spec.local_name_pattern)

        if name then
            return name
        end
    end

    if type(signature_spec.name_pattern) == "string" then
        return signature:match(signature_spec.name_pattern)
    end

    return nil
end


function M.extract_name_from_syntax(
    node,
    bufnr,
    spec
)
    if not node or not core.is_table(spec) then
        return nil
    end

    local name_field =
        get_syntax_field(
            spec,
            "name"
        )

    if not name_field then
        return nil
    end

    local name_node =
        require("tracker_hud.treesitter_utils")
            .get_child_by_field_name(
                node,
                name_field
            )

    if not name_node then
        return nil
    end

    return require("tracker_hud.treesitter_utils")
        .get_node_text(
            name_node,
            bufnr
        )
end


function M.build_construct(opts)
    opts = opts or {}

    local contract = require("tracker_hud.constructs.contract")

    return contract.new_construct({
        construct = opts.construct,
        scope = opts.scope,
        member = opts.member,
        value = opts.value,

        node_type = opts.node_type,
        name = opts.name,
        signature = opts.signature,
        range = opts.range,
        metadata = opts.metadata or {},
    })
end


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


function M.format_branch_display_label(start_line, base_label, alternative_label, alternative_line, grouped)
    if grouped then
        return "([" .. start_line .. "] "
            .. base_label
            .. " : "
            .. alternative_label
            .. " ["
            .. alternative_line
            .. "])"
    end
    
    return "[" .. start_line .. "] "
        .. base_label
        .. " : "
        .. alternative_label
        .. " ["
        .. alternative_line
        .. "]"
end



function M.node_matches_branch_alternative(node, spec)
    if not node or not core.is_table(spec) then
        return false
    end

    local branch_spec = spec.branch or {}
    local alternatives = branch_spec.alternatives or {}
    local node_type = node:type()

    for _, alternative_spec in ipairs(alternatives) do
        if core.is_table(alternative_spec) then
            local alternative_node_type =
                get_syntax_node_type(
                    alternative_spec
                )

            if core.is_non_empty_string(
                alternative_node_type
            ) and node_type == alternative_node_type
            then
                return true
            end

            --
            -- Temporary compatibility for pre-syntax adapters.
            --
            if type(alternative_spec.node_match)
                == "string"
                and node_type:match(
                    alternative_spec.node_match
                )
            then
                return true
            end
        end
    end

    return false
end


function M.get_node_alternatives(node, spec)
    local alternatives = {}

    if not node then
        return alternatives
    end

    local alternative_field =
        get_syntax_field(
            spec,
            "alternative"
        )
        or "alternative"

    local ok, field_nodes = pcall(function()
        return node:field(
            alternative_field
        )
    end)

    if ok and field_nodes then
        for _, alternative in ipairs(field_nodes) do
            table.insert(alternatives, alternative)
        end
    end

    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)

        if M.node_matches_branch_alternative(child, spec) then
            table.insert(alternatives, child)
        end
    end

    return alternatives
end


function M.get_branch_alternative_label(alternative_node, spec)
    if not alternative_node or not core.is_table(spec) then
        return nil
    end

    local branch_spec = spec.branch or {}
    local alternatives = branch_spec.alternatives or {}
    local alternative_type = alternative_node:type()

    for _, alternative_spec in ipairs(alternatives) do
        if core.is_table(alternative_spec)
            and type(alternative_spec.label) == "string"
        then
            local alternative_node_type =
                get_syntax_node_type(
                    alternative_spec
                )

            if core.is_non_empty_string(
                alternative_node_type
            ) and alternative_type
                == alternative_node_type
            then
                return alternative_spec.label
            end

            --
            -- Temporary compatibility for pre-syntax adapters.
            --
            if type(alternative_spec.node_match)
                == "string"
                and alternative_type:match(
                    alternative_spec.node_match
                )
            then
                return alternative_spec.label
            end
        end
    end

    return nil
end


function M.build_branch_display_label(node, spec)
    local start_line = M.get_first_node_line(node)
    local construct_spec = spec.construct or {}
    local base_label = construct_spec.label or "Branch"

    if not start_line then
        return base_label
    end

    local cursor = M.get_cursor_position()
    local alternatives = M.get_node_alternatives(node, spec)
    local branch_spec = spec.branch or {}
    local grouped = branch_spec.grouped == true

    for _, alternative in ipairs(alternatives) do
        if M.position_in_node(cursor.row, cursor.col, alternative) then
            local alternative_line = M.get_first_node_line(alternative) or start_line
            local label = M.get_branch_alternative_label(alternative, spec) or "Alternative"

            return M.format_branch_display_label(
                start_line,
                base_label,
                label,
                alternative_line,
                grouped
            )
        end
    end

    return "[" .. start_line .. "] " .. base_label
end


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


function M.match_node(adapter, node)
    if not core.is_table(adapter) or not core.is_table(adapter.construct_specs) then
        return false
    end

    local node_type = M.get_node_type(node)

    if not node_type then
        return false
    end

    return adapter.construct_specs[node_type] ~= nil
end



function M.parse_node(adapter, node, bufnr)
    if not core.is_table(adapter) then
        return nil, "adapter must be a table"
    end

    if not core.is_table(adapter.construct_specs) then
        return nil, "adapter.construct_specs must be a table"
    end

    local node_type = M.get_node_type(node)

    local spec, spec_err = M.get_construct_spec(
        adapter.construct_specs,
        node_type
    )

    if not spec then
        return nil, spec_err
    end

    local range = M.get_node_range(node)

    if not range then
        return nil, "could not get node range"
    end

    local construct_spec = spec.construct or {}

    local signature = nil
    local name = nil

    if core.is_table(spec.signature) then
        signature = M.build_signature(
            node,
            bufnr,
            spec
        )
    end

    --
    -- Tree-sitter fields are authoritative for syntax identity.
    -- Text-pattern parsing is only a fallback when the grammar does not
    -- expose the requested field on this construct.
    --
    name = M.extract_name_from_syntax(
        node,
        bufnr,
        spec
    )

    if not name and signature then
        name = M.extract_name_from_signature(
            signature,
            spec
        )
    end

    local label = construct_spec.label
        or "<unknown>"

    local display_label = nil

    if core.is_table(spec.branch) then
        display_label = M.build_branch_display_label(
            node,
            spec
        )

        label = display_label
    end

    local resolved_construct =
        vim.deepcopy(construct_spec)

    resolved_construct.label = label

    return M.build_construct({
        construct = resolved_construct,

        scope = spec.scope,
        member = spec.member,
        value = spec.value,

        node_type = node_type,
        name = name,
        signature = signature,
        range = range,

        metadata = {
            adapter = adapter.name,
            display_label = display_label,
        },
    })
end


function M.get_construct_spec(construct_specs, node_type)
    if not core.is_table(construct_specs) then
        return nil, "construct_specs must be table"
    end

    if type(node_type) ~= "string" or node_type == "" then
        return nil, "node_type must be a non-empty string"
    end

    local spec = construct_specs[node_type]

    if not spec then
        return nil, nil
    end

    local ok, err =
        M.validate_construct_spec(
            spec,
            node_type
        )

    if not ok then
        return nil, err
    end

    return spec, nil

end


function M.validate_construct_spec(
    spec,
    expected_node_type
)
    if not core.is_table(spec) then
        return false, "construct spec must be a table"
    end

    local syntax = get_syntax(spec)

    if spec.syntax ~= nil
        and not core.is_table(spec.syntax)
    then
        return false,
            "construct spec syntax must be a table when provided"
    end

    if core.is_table(spec.syntax) then
        if not core.is_non_empty_string(
            syntax.node_type
        ) then
            return false,
                "construct spec syntax.node_type must be a non-empty Tree-sitter node type"
        end

        if core.is_non_empty_string(
            expected_node_type
        ) and syntax.node_type
            ~= expected_node_type
        then
            return false,
                "construct spec syntax.node_type '"
                .. tostring(syntax.node_type)
                .. "' does not match construct_specs key '"
                .. tostring(expected_node_type)
                .. "'"
        end

        if syntax.fields ~= nil
            and not core.is_table(
                syntax.fields
            )
        then
            return false,
                "construct spec syntax.fields must be a table when provided"
        end

        if syntax.children ~= nil
            and not core.is_table(
                syntax.children
            )
        then
            return false,
                "construct spec syntax.children must be a table when provided"
        end

        if syntax.tokens ~= nil
            and not core.is_table(
                syntax.tokens
            )
        then
            return false,
                "construct spec syntax.tokens must be a table when provided"
        end

        if syntax.exclusions ~= nil
            and not core.is_table(
                syntax.exclusions
            )
        then
            return false,
                "construct spec syntax.exclusions must be a table when provided"
        end
    end

    local contract = require("tracker_hud.constructs.contract")

    local ok, err = contract.validate_construct_spec(spec.construct)

    if not ok then
        return false, err
    end

    ok, err = contract.validate_scope_spec(spec.scope)

    if not ok then
        return false, err
    end

    ok, err = contract.validate_member_spec(spec.member)

    if not ok then
        return false, err
    end

    ok, err = contract.validate_value_spec(spec.value)

    if not ok then
        return false, err
    end

    if spec.markers ~= nil then
        if not core.is_table(spec.markers) then
            return false, "construct spec markers must be a table when provided"
        end

        local required = spec.markers.required or {}
        local optional = spec.markers.optional or {}

        if not core.is_table(required) then
            return false, "construct spec markers.required must be a table"
        end

        if not core.is_table(optional) then
            return false, "construct spec markers.optional must be a table"
        end

        local tokens =
            get_syntax_tokens(spec)

        if tokens == nil then
            return false,
                "construct spec markers require syntax.tokens"
        end

        for _, marker_name in ipairs(required) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "required marker names must be non-empty strings"
            end

            if tokens[marker_name] == nil then
                return false,
                    "required marker '"
                    .. marker_name
                    .. "' is missing from syntax.tokens"
            end
        end

        for _, marker_name in ipairs(optional) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "optional marker names must be non-empty strings"
            end

            if tokens[marker_name] == nil then
                return false,
                    "optional marker '"
                    .. marker_name
                    .. "' is missing from syntax.tokens"
            end
        end

        if spec.markers.total_required ~= nil
            and spec.markers.total_required ~= #required
        then
            return false, "markers.total_required does not match number of required markers"
        end
    end

    return true, nil
end


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


local function get_static_register_spec(adapter, name)
    if not core.is_table(adapter) or type(name) ~= "string" then
        return nil
    end

    local normalized = name:lower()

    for _, register_spec in ipairs((adapter.registers and adapter.registers.static) or {}) do
        if type(register_spec) == "table"
            and type(register_spec.name) == "string"
            and register_spec.name:lower() == normalized
        then
            return register_spec
        end
    end

    return nil
end


local function get_register_fact_from_map(facts_by_register, register_name)
    if not core.is_table(facts_by_register)
        or not core.is_non_empty_string(register_name)
    then
        return nil
    end

    return facts_by_register[register_name:lower()]
end

local function resolve_register_alias(adapter, register_name)
    if not core.is_table(adapter)
        or not core.is_non_empty_string(register_name)
        or not core.is_table(adapter.register_alias_index)
    then
        return nil
    end

    return adapter.register_alias_index[register_name:lower()]
end


local function get_register_fact_for_read(
    facts_by_register,
    adapter,
    register_name
)
    local direct = get_register_fact_from_map(
        facts_by_register,
        register_name
    )

    if core.is_table(direct)
        and direct.value ~= nil
        and direct.resolved ~= false
    then
        return direct
    end

    local alias_resolution = resolve_register_alias(
        adapter,
        register_name
    )

    if not alias_resolution
        or not core.is_table(alias_resolution.alias)
        or not core.is_non_empty_string(alias_resolution.canonical)
    then
        return direct
    end

    local canonical_name = alias_resolution.canonical:lower()

    if canonical_name == tostring(register_name):lower() then
        return direct
    end

    local canonical_fact = get_register_fact_from_map(
        facts_by_register,
        canonical_name
    )

    if not core.is_table(canonical_fact) then
        return direct
    end

    local projected = register_value_mask.read_alias_value(
        canonical_fact,
        alias_resolution.alias
    )

    if projected == nil then
        return direct
    end

    return {
        name = tostring(register_name):lower(),
        value = projected,
        resolved = true,
        metadata = canonical_fact.metadata,
    }
end

local function register_state_key(adapter, register_name)
    local resolved = resolve_register_alias(adapter, register_name)
    if resolved and core.is_non_empty_string(resolved.canonical) then
        return resolved.canonical:lower()
    end

    return core.is_non_empty_string(register_name)
        and register_name:lower()
        or nil
end


local function get_register_value_width(adapter, register_name)
    local resolved = resolve_register_alias(adapter, register_name)

    if resolved
        and core.is_table(resolved.alias)
        and core.is_number(resolved.alias.bits)
    then
        return resolved.alias.bits
    end

    local static_spec = get_static_register_spec(adapter, register_name)

    if static_spec and core.is_number(static_spec.bits) then
        return static_spec.bits
    end

    return nil
end


local function apply_register_value_width_policy(
    adapter,
    target_register,
    effect,
    value,
    resolved
)
    local policy = core.is_table(effect)
        and effect.value_width_policy
        or nil

    if policy == nil then
        return value, resolved, nil
    end

    local metadata = {
        value_width_policy = policy,
        pre_width_write_value = value,
    }

    if resolved == false or value == nil then
        return value, resolved, metadata
    end

    if policy ~= "wrap_unsigned_target" then
        metadata.value_width_error = "unsupported policy"
        return nil, false, metadata
    end

    local bits = get_register_value_width(
        adapter,
        target_register
    )

    metadata.value_width_bits = bits

    if not bits then
        metadata.value_width_error = "target width unavailable"
        return nil, false, metadata
    end

    local wrapped = integer_value.wrap_unsigned(
        value,
        bits
    )

    if wrapped == nil then
        metadata.value_width_error = "value is not an exact integer"
        return nil, false, metadata
    end

    local normalized = integer_value.normalize(value)
    metadata.value_wrapped = normalized ~= wrapped

    return wrapped, true, metadata
end



local function parse_numeric_value(value)
    return integer_value.normalize(value)
end


local function build_integer_operand_metadata(metadata)
    if not core.is_table(metadata) then
        return nil
    end

    return {
        source_integer_interpretation = metadata.interpretation,
        source_integer_bits = metadata.bits,
        source_integer_bits_source = metadata.bits_source,
        source_integer_max_bits = metadata.max_bits,
        source_integer_min_bits = metadata.min_bits,
        source_integer_raw_value = metadata.raw_value,
        source_integer_value = metadata.value,
        source_integer_error = metadata.error,
    }
end


local function interpret_integer_operand_value(
    adapter,
    target_register,
    value,
    policy
)
    if not core.is_table(policy) then
        local normalized = parse_numeric_value(value)

        return normalized,
            normalized ~= nil,
            nil
    end

    local interpreted, metadata = integer_operand.interpret(
        value,
        policy,
        {
            target_bits = get_register_value_width(
                adapter,
                target_register
            ),
        }
    )

    return interpreted,
        interpreted ~= nil,
        build_integer_operand_metadata(metadata)
end

local function parse_numeric_number(value)
    return integer_value.to_safe_number(value)
end


local function register_fact_is_resolved(fact)
    return core.is_table(fact)
        and fact.value ~= nil
        and fact.resolved ~= false
end


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


local function resolve_register_effect_value(
    facts_by_register,
    instruction,
    effect,
    instruction_state,
    adapter,
    target_register
)
    local value = effect.value
    local resolved = value ~= nil

    if effect.value_from_stack_top == true
        or effect.value_from_stack == "top"
    then
        local stack_value = core.is_table(instruction_state)
            and instruction_state.stack_pop
            or nil

        if core.is_table(stack_value) then
            return stack_value.value, stack_value.resolved ~= false
        end

        return nil, false
    end

    if core.is_non_empty_string(effect.value_from_register) then
        local source_fact = get_register_fact_for_read(
            facts_by_register,
            adapter,
            effect.value_from_register
        )

        if register_fact_is_resolved(source_fact) then
            return source_fact.value, true
        end

        return effect.value_from_register, false
    end

    if tonumber(effect.value_from_register_operand) then
        local source_operand = instruction.operands[tonumber(effect.value_from_register_operand)]

        if source_operand and core.is_non_empty_string(source_operand.text) then
            local source_fact = get_register_fact_for_read(
                facts_by_register,
                adapter,
                source_operand.text
            )

            if register_fact_is_resolved(source_fact) then
                return source_fact.value, true
            end

            return source_operand.text, false
        end
    end

    if tonumber(effect.value_delta_operand) or effect.value_delta ~= nil then
        local target_operand = nil
        local target_register = effect.target_register

        if tonumber(effect.target_operand) then
            target_operand = instruction.operands[tonumber(effect.target_operand)]

            if target_operand then
                target_register = target_operand.text
            end
        end

        local target_fact = target_register
            and get_register_fact_for_read(
                facts_by_register,
                adapter,
                target_register
            )

        if not register_fact_is_resolved(target_fact) then
            return nil, false
        end

        local current_value = parse_numeric_value(target_fact.value)

        if not current_value then
            return nil, false
        end

        local total_delta = "0"
        local has_delta = false

        if effect.value_delta ~= nil then
            local fixed_delta = parse_numeric_value(effect.value_delta)

            if not fixed_delta then
                return nil, false
            end

            total_delta = integer_value.add(total_delta, fixed_delta)
            has_delta = total_delta ~= nil
        end

        local source_integer_metadata = nil

        if tonumber(effect.value_delta_operand) then
            local delta_operand = instruction.operands[tonumber(effect.value_delta_operand)]

            if delta_operand and delta_operand.text ~= nil then
                local operand_delta
                local operand_resolved

                operand_delta,
                    operand_resolved,
                    source_integer_metadata =
                    interpret_integer_operand_value(
                        adapter,
                        target_register,
                        delta_operand.text,
                        effect.value_delta_operand_interpretation
                    )

                if not operand_resolved or not operand_delta then
                    return nil, false, source_integer_metadata
                end

                total_delta = integer_value.add(total_delta, operand_delta)
                has_delta = total_delta ~= nil
            elseif effect.value_delta == nil then
                return nil, false
            end
        end

        if not has_delta or not total_delta then
            return nil, false
        end

        local sign = tonumber(effect.value_delta_sign) or 1

        if sign == -1 then
            total_delta = integer_value.negate(total_delta)
        elseif sign ~= 1 then
            return nil, false
        end

        local result = integer_value.add(current_value, total_delta)

        return result,
            result ~= nil,
            source_integer_metadata
    end

    if value == nil and tonumber(effect.value_operand) then
        local value_operand = instruction.operands[tonumber(effect.value_operand)]
            if value_operand then
                value = value_operand.text

                if value_operand.kind == "register" then
                    local source_fact = get_register_fact_for_read(
                        facts_by_register,
                        adapter,
                        value_operand.text
                    )

                    resolved = register_fact_is_resolved(source_fact)

                    if resolved then
                        value = source_fact.value
                    end
                elseif value_operand.kind == "integer" then
                    local source_integer_metadata

                    value,
                        resolved,
                        source_integer_metadata =
                        interpret_integer_operand_value(
                            adapter,
                            target_register,
                            value_operand.text,
                            effect.value_operand_interpretation
                        )

                    return value,
                        resolved,
                        source_integer_metadata
                else
                    resolved = value ~= nil
                end
            end

        end

    return value, resolved
end


local function make_register_fact(
    facts_by_register,
    family_state,
    adapter,
    instruction,
    effect_spec,
    instruction_state
)

    if not core.is_table(facts_by_register)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or not core.is_table(effect_spec.effect)
    then
        return nil
    end

    local effect = effect_spec.effect
    local target_index = tonumber(effect.target_operand)
    local target_operand = nil
    local target_register = effect.target_register

    if target_index then
        target_operand = instruction.operands and instruction.operands[target_index]

        if not core.is_table(target_operand)
            or not core.is_non_empty_string(target_operand.text)
            then
                return nil
            end

        target_register = target_operand.text
    end

    if not core.is_non_empty_string(target_register) then
        return nil
    end

    local write_value, write_resolved, source_integer_metadata =
        resolve_register_effect_value(
            facts_by_register,
            instruction,
            effect,
            instruction_state,
            adapter,
            target_register
        )

    local width_metadata
    write_value, write_resolved, width_metadata =
        apply_register_value_width_policy(
            adapter,
            target_register,
            effect,
            write_value,
            write_resolved
        )

    local value = write_value
    local resolved = write_resolved

    local alias_resolution = resolve_register_alias(adapter, target_register)
    local canonical_name = alias_resolution
        and alias_resolution.canonical
        or target_register:lower()

    local reduced_state = nil
    if alias_resolution
        and core.is_table(alias_resolution.family)
        and alias_resolution.family.bits == 64
        and core.is_table(alias_resolution.alias)
        and alias_resolution.alias.bits < 64
    then
        reduced_state = register_value_mask.apply_alias_write(
            family_state and family_state[canonical_name],
            alias_resolution.alias,
            write_value,
            write_resolved
        )

        if reduced_state then
            value = reduced_state.value
            resolved = reduced_state.resolved
        end
    end

    local static_spec = get_static_register_spec(adapter, canonical_name)
        or get_static_register_spec(adapter, target_register)
        or {}
    local metadata = {
        adapter = adapter.name,
        architecture = adapter.architecture,
        variant = adapter.active_variant_name,
        mnemonic = instruction.mnemonic,
        effect = effect.name,

        -- Semantic origin of the effect target. This is deliberately
        -- presentation-neutral: consumers can distinguish an explicitly
        -- named operand write from an architectural/implicit register
        -- effect without reverse-engineering the instruction text.
        effect_target_origin = target_index
            and "operand"
            or "implicit_register",

        canonical_name = canonical_name,
        write_value = write_value,
        write_resolved = write_resolved ~= false,

        value_width_policy = width_metadata
            and width_metadata.value_width_policy
            or nil,
        value_width_bits = width_metadata
            and width_metadata.value_width_bits
            or nil,
        pre_width_write_value = width_metadata
            and width_metadata.pre_width_write_value
            or nil,
        value_wrapped = width_metadata
            and width_metadata.value_wrapped,
        value_width_error = width_metadata
            and width_metadata.value_width_error
            or nil,
    }

    if reduced_state and reduced_state.partial_value then
        metadata.partial_value = reduced_state.partial_value
    end

    register_source_metadata.merge(
        metadata,
        source_integer_metadata
    )

    register_source_metadata.merge(
        metadata,
        register_source_metadata.build(
            effect_spec,
            instruction,
            effect,
            instruction_state
        )
    )

    return {
        name = target_register:lower(),
        kind = static_spec.kind or "unknown",
        value = value,
        resolved = resolved ~= false,
        role = effect.role or static_spec.role,
        source = "instruction",

        source_line = target_operand
            and target_operand.source_line
            or instruction.source_line,

        source_column = target_operand
            and target_operand.source_column
            or instruction.source_column
            or 0,

        source_start_line = target_operand
            and target_operand.source_start_line
            or instruction.source_start_line
            or instruction.source_line,

        source_start_column = target_operand
            and target_operand.source_start_column
            or instruction.source_start_column
            or instruction.source_column
            or 0,

        source_end_line = target_operand
            and target_operand.source_end_line
            or instruction.source_end_line
            or instruction.source_line,

        source_end_column = target_operand
            and target_operand.source_end_column
            or instruction.source_end_column
            or instruction.source_column
            or 0,

        metadata = metadata,
    }

end


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
        local state_key = register_state_key(adapter, fact.name)
            or fact.name

        latest_state_facts[state_key] = fact
        family_state[state_key] = fact

        -- Keep source-operand lookup behaviour separate from canonical reduced
        -- state. Invalidate sibling spellings first so a later source read
        -- can never observe a stale AL/AH/AX/EAX value after another alias
        -- changed the same physical family.
        local alias_resolution = resolve_register_alias(adapter, fact.name)
        local family = alias_resolution and alias_resolution.family or nil

        if core.is_table(family) and core.is_table(family.aliases) then
            for alias_name, _ in pairs(family.aliases) do
                facts_by_register[tostring(alias_name):lower()] = nil
            end
        end

        local write_resolved = fact.metadata
            and fact.metadata.write_resolved

        facts_by_register[fact.name] = {
            name = fact.name,
            value = fact.metadata and fact.metadata.write_value or fact.value,
            resolved = write_resolved ~= nil
                and write_resolved
                or fact.resolved,
            metadata = fact.metadata,
        }

        -- Publish the reduced canonical family state as well. A partial
        -- canonical fact remains unresolved as a whole register, but its
        -- explicit certainty mask lets later alias reads project any slice
        -- that is fully known.
        if state_key ~= fact.name then
            facts_by_register[state_key] = {
                name = state_key,
                value = fact.resolved ~= false
                    and fact.value
                    or nil,
                resolved = fact.resolved ~= false,
                metadata = fact.metadata,
            }
        end
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

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local limit_position = low_level_inference.normalize_position(
        opts.limit_position
            or opts.stop_before
            or opts.before_position
    )

    local effect_index =
        get_register_effect_index(adapter)

    local nodes =
        collect_register_effect_nodes(
            context,
            root_node,
            effect_index,
            opts
        )

    local facts_by_register = {}
    local family_state = {}
    local latest_state_facts = {}
    local low_level_state = low_level_inference.new_state()

    for _, entry in ipairs(nodes) do
        local node_type = entry.node:type()
        local node_bucket = effect_index.by_node_type[node_type]

        if node_bucket then
            local representative_effect_spec = node_bucket.__first

            local instruction = collect_instruction_operands(
                adapter,
                entry.node,
                bufnr,
                representative_effect_spec
            )

            local mnemonic = instruction
                and normalize_mnemonic(instruction.mnemonic)

            local effect_specs = mnemonic and node_bucket[mnemonic] or nil

            local instruction_state = prepare_register_instruction_inference_state(
                low_level_state,
                facts_by_register,
                instruction,
                effect_specs,
                adapter
            )

            for _, effect_spec in ipairs(effect_specs or {}) do
                apply_register_effect(
                    facts_by_register,
                    family_state,
                    latest_state_facts,
                    adapter,
                    instruction,
                    effect_spec,
                    instruction_state
                )
            end
        end
    end

    return register_infer.to_fact_list(latest_state_facts)
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


local function boundary_instruction_matches(instruction, effect_spec)
    if not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return false
    end

    local expected_mnemonic =
        get_boundary_effect_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return false
    end

    return true
end


local function make_boundary_effect_fact(
    context,
    adapter,
    instruction,
    effect_spec,
    phase_contexts
)
    return boundary_infer.make_effect_fact(
        context,
        adapter,
        instruction,
        effect_spec,
        phase_contexts
    )
end


local function collect_registers_before_instruction(
    context,
    adapter,
    opts,
    instruction
)
    if not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(opts)
        or not core.is_table(instruction)
    then
        return context
    end

    local limit_position = low_level_inference.normalize_position({
        line = instruction.source_start_line
            or instruction.source_line,
        column = instruction.source_start_column
            or instruction.source_column
            or 0,
    })

    if not limit_position then
        return context
    end

    local registers_before = M.collect_register_effects(
        context,
        adapter,
        {
            bufnr = opts.bufnr,
            root_node = opts.root_node,
            limit_position = limit_position,
        }
    )

    return low_level_inference.with_section_facts(
        context,
        "registers",
        registers_before
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
    if not core.is_table(facts)
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if not boundary_instruction_matches(instruction, effect_spec) then
        return
    end

    local fact = make_boundary_effect_fact(
        context,
        adapter,
        instruction,
        effect_spec,
        phase_contexts
    )

    if fact then
        table.insert(facts, fact)
    end
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


local function make_instruction_event_fact(context, adapter, instruction, event_spec)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return nil
    end

    return {
        kind = event_spec.kind or "instruction_event",
        category = event_spec.category or "instruction",
        name = event_spec.name
            or get_instruction_event_mnemonic(event_spec)
            or "instruction_event",
        role = event_spec.role,

        source = "instruction",
        source_line = instruction.source_line,
        source_column = instruction.source_column or 0,

        source_start_line = instruction.source_line,
        source_start_column = instruction.source_column or 0,
        source_end_line = instruction.source_line,
        source_end_column = instruction.source_end_column or instruction.source_column or 0,

        metadata = vim.tbl_extend(
            "force",
            {
                adapter = adapter.name,
                architecture = adapter.architecture,
                variant = adapter.active_variant_name,
                mnemonic = instruction.mnemonic,
                event = event_spec.name
                    or get_instruction_event_mnemonic(event_spec),
                operands = instruction.operands or {},
                operand_specs = event_spec.operands or {},
            },
            control_infer.make_event_metadata(
                context,
                event_spec
            )
        ),
    }
end


local function apply_instruction_event(facts, context, adapter, instruction, event_spec)
    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return
    end

    if not instruction_event_matches(instruction, event_spec) then
        return
    end

    local fact = make_instruction_event_fact(context, adapter, instruction, event_spec)

    if fact then
        table.insert(facts, fact)
    end
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


local function stack_operand_value_matches(operand, operand_spec)
    if type(operand_spec.value) ~= "string" then
        return true
    end

    if not core.is_table(operand) or not core.is_non_empty_string(operand.text) then
        return false
    end

    return operand.text:lower() == operand_spec.value:lower()
end

local function stack_operand_matches_spec(adapter, operand, operand_spec)
    if not core.is_table(operand) or not core.is_table(operand_spec) then
        return false
    end

    if type(operand_spec.kind) == "string"
        and operand.kind ~= operand_spec.kind
    then
        -- ASM registers can sometimes appear as symbol-like words depending
        -- on the exact instruction shape. Treat known architecture registers
        -- as registers for stack-effect matching.
        if operand_spec.kind == "register"
            and core.is_non_empty_string(operand.text)
            and get_static_register_spec(adapter, operand.text)
        then
            return true
        end

        return false
    end

    return true
end


local function stack_operands_match_effect(adapter, instruction, effect_spec)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return false
    end

    for _, operand_spec in ipairs(effect_spec.operands or {}) do
        local index = tonumber(operand_spec.index)

        if not index then
            return false
        end

        local operand = instruction.operands and instruction.operands[index]

        if not stack_operand_matches_spec(adapter, operand, operand_spec) then
            return false
        end

        if not stack_operand_value_matches(operand, operand_spec) then
            return false
        end
    end

    return true
end


local function make_stack_fact(adapter, instruction, effect_spec, instruction_state)
    return stack_infer.make_effect_fact(
        adapter,
        instruction,
        effect_spec,
        instruction_state
    )
end


local function apply_stack_effect(facts, adapter, instruction, effect_spec, instruction_state)
    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    local expected_mnemonic =
        get_stack_effect_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return
    end

    if not stack_operands_match_effect(adapter, instruction, effect_spec) then
        return
    end

    if not condition_matches(instruction, effect_spec.condition) then
        return
    end

    local fact = make_stack_fact(adapter, instruction, effect_spec, instruction_state)

    if fact then
        table.insert(facts, fact)
    end
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
