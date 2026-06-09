-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")

local M = {}


function M.make_global_context()
    return {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        scope_members = {},
        cursor = M.get_cursor_location(),
    }
end


function M.make_unavailable_context(message, filetype)
    return {
        label = message,
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        scope_members = {},
        cursor = M.get_cursor_location(),
        unavailable = true,
        filetype = filetype,
    }
end


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


function M.get_cursor_position()
    local cursor = vim.api.nvim_win_get_cursor(0)

    return {
        row = cursor[1] - 1,
        col = cursor[2],
    }
end


function M.get_cursor_location()
    local cursor = vim.api.nvim_win_get_cursor(0)

    return {
        line = cursor[1],
        column = cursor[2] + 1, 
    }
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
        if core.is_table(alternative_spec)
            and type(alternative_spec.node_match) == "string"
            and node_type:match(alternative_spec.node_match)
        then
            return true
        end
    end

    return false
end


function M.get_node_alternatives(node, spec)
    local alternatives = {}

    if not node then
        return alternatives
    end

    local ok, field_nodes = pcall(function()
        return node:field("alternative")
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
            and type(alternative_spec.node_match) == "string"
            and type(alternative_spec.label) == "string"
            and alternative_type:match(alternative_spec.node_match)
        then
            return alternative_spec.label
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


function M.position_in_node(row, col, node)
    if not node then
        return false
    end

    local start_row, start_col, end_row, end_col = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return false
    end

    if row < start_row or row > end_row then
        return false
    end

    if row == start_row and core.is_number(start_col) and col < start_col then
        return false
    end

    if row == end_row and core.is_number(end_col) and col > end_col then
        return false
    end

    return true
end


function M.get_node_type(node)
    if not node then
        return nil
    end

    return node:type()
end



function M.get_first_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()


    if not core.is_number(start_row) then
        return nil
    end

    return start_row + 1
end


function M.build_scope_entry_from_construct(construct)
    if not core.is_table(construct) or not core.is_table(construct.range) then
        return nil
    end

    local construct_spec = construct.construct or {}
    local line_number = construct.range.start_line
    local label = construct.signature or construct_spec.label
    local display_label = nil

    if construct.metadata then
        display_label = construct.metadata.display_label
    end

    display_label = display_label or "[" .. line_number .. "] " .. tostring(label or "<unknown>")

    return {
        label = display_label,
        raw_label = label,
        node_type = construct.node_type,
        kind = construct_spec.kind,
        scope = construct.scope,
        value = construct.value,
        start_line = construct.range.start_line,
        end_line = construct.range.end_line,
        construct = construct,
    }
end


function M.build_context_from_scopes(scopes, config)
    local context = M.make_global_context()

    if not core.is_table(scopes) or #scopes == 0 then
        return context
    end

    local path = {}

    -- Scopes are collected innermost -> outermost.
    -- Reverse them so HUD reads outermost -> innermost.
    for i = #scopes, 1, -1 do
        table.insert(path, scopes[i].label)
    end
    
    local innermost = scopes[1]
    local separator = (config and config.separator) or " -> "


    context.label = "Scope: " .. table.concat(path, separator)
    context.node_type = innermost.node_type
    context.start_line = innermost.start_line
    context.end_line = innermost.end_line
    context.depth = #scopes
    context.path = path
    context.scopes = scopes
    context.scope_members = {}

    return context
end


function M.get_node_range(node)
    if not node then
        return nil
    end
    
    local start_row, _, end_row, _ = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return nil
    end
    
    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
end


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
    local spec, spec_err = M.get_construct_spec(adapter.construct_specs, node_type)

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

    if construct_spec.kind == "callable" then
        signature = M.build_signature(node, bufnr, spec)
        name = M.extract_name_from_signature(signature, spec)
    end

    local label = construct_spec.label or "<unknown>"
    local display_label = nil

    if construct_spec.kind == "branch" and spec.branch then
        display_label = M.build_branch_display_label(node, spec)
        label = display_label
    end

    return M.build_construct({
        construct = {
            kind = construct_spec.kind,
            label = label,
        },

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

    local ok, err = M.validate_construct_spec(spec)

    if not ok then
        return nil, err
    end

    return spec, nil

end


function M.validate_construct_spec(spec)
    if not core.is_table(spec) then
        return false, "construct spec must be a table"
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

    if spec.tokens ~= nil and not core.is_table(spec.tokens) then
        return false, "construct spec tokens must be a table when provided"
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

        if spec.tokens == nil then
            return false, "construct spec markers require a tokens table"
        end

        for _, marker_name in ipairs(required) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "required marker names must be non-empty strings"
            end

            if spec.tokens[marker_name] == nil then
                return false, "required marker '" .. marker_name .. "' is missing from tokens"
            end
        end

        for _, marker_name in ipairs(optional) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "optional marker names must be non-empty strings"
            end

            if spec.tokens[marker_name] == nil then
                return false, "optional marker '" .. marker_name .. "' is missing from tokens"
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


local function normalize_text(text)
    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("^%s+", ""):gsub("%s+$", "")

    if text == "" then
        return nil
    end

    return text
end


local function node_text(node, bufnr)
    if not node then
        return nil
    end

    return normalize_text(ts_utils.get_node_text(node, bufnr))
end


local function node_has_descendant_type(node, wanted_type)
    if not node or type(wanted_type) ~= "string" then
        return false
    end

    for child in node:iter_children() do
        if child:type() == wanted_type then
            return true
        end

        if node_has_descendant_type(child, wanted_type) then
            return true
        end
    end

    return false
end


local function node_has_ancestor_type_until(node, wanted_type, stop_type)
    if not node or type(wanted_type) ~= "string" then
        return false
    end

    local parent = node:parent()

    while parent do
        if parent:type() == wanted_type then
            return true
        end

        if stop_type and parent:type() == stop_type then
            break
        end

        parent = parent:parent()
    end

    return false
end


local function infer_operand_kind(node, effect_spec)
    if not node then
        return "unknown"
    end

    local node_type = node:type()
    local instruction_node_type = effect_spec.node_type or "instruction"

    if node_type == "int" then
        return "integer"
    end

    if node_type == "reg"
        or node_has_ancestor_type_until(node, "reg", instruction_node_type)
        or node_has_descendant_type(node, "reg")
    then
        return "register"
    end

    if node_type == "ident" or node_type == "word" then
        return "symbol"
    end

    return "unknown"
end


local function build_operand(node, bufnr, effect_spec)
    local text = node_text(node, bufnr)

    if not text then
        return nil
    end

    local start_row, start_column, end_row, end_column = node:range()

    return {
        text = text,
        kind = infer_operand_kind(node, effect_spec),
        node_type = node:type(),

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }
end


local function collect_instruction_operands(node, bufnr, effect_spec)
    local operands = {}
    local mnemonic = nil
    local mnemonic_seen = false

    for child in node:iter_children() do
        local child_type = child:type()

        if child_type == "word" and not mnemonic_seen then
            mnemonic = node_text(child, bufnr)
            mnemonic_seen = true
        elseif child_type == "reg"
            or child_type == "ident"
            or child_type == "int"
            or child_type == "word"
        then
            local operand = build_operand(child, bufnr, effect_spec)

            if operand then
                table.insert(operands, operand)
            end
        end
    end

    return {
        mnemonic = mnemonic and mnemonic:lower() or nil,
        operands = operands,
        source_line = node:start() + 1,
    }
end


local function collect_nodes_by_type(node, node_type, result)
    result = result or {}

    if not node or type(node_type) ~= "string" or node_type == "" then
        return result
    end

    if node:type() == node_type then
        table.insert(result, node)
    end

    for child in node:iter_children() do
        collect_nodes_by_type(child, node_type, result)
    end

    return result
end


local function operand_matches_spec(operand, operand_spec)
    if type(operand) ~= "table" or type(operand_spec) ~= "table" then
        return false
    end

    if type(operand_spec.kind) == "string"
        and operand.kind ~= operand_spec.kind
    then
        return false
    end

    return true
end


local function operands_match_effect(instruction, effect_spec)
    if type(instruction) ~= "table" or type(effect_spec) ~= "table" then
        return false
    end

    for _, operand_spec in ipairs(effect_spec.operands or {}) do
        local index = tonumber(operand_spec.index)

        if not index then
            return false
        end

        local operand = instruction.operands and instruction.operands[index]

        if not operand_matches_spec(operand, operand_spec) then
            return false
        end
    end

    return true
end


local function condition_matches(instruction, condition_spec)
    if type(condition_spec) ~= "table" then
        return true
    end

    local operands_equal = condition_spec.operands_equal

    if type(operands_equal) == "table" then
        local left_index = tonumber(operands_equal[1])
        local right_index = tonumber(operands_equal[2])

        if not left_index or not right_index then
            return false
        end

        local left = instruction.operands and instruction.operands[left_index]
        local right = instruction.operands and instruction.operands[right_index]

        if not left or not right then
            return false
        end

        if tostring(left.text or ""):lower() ~= tostring(right.text or ""):lower() then
            return false
        end
    end

    return true
end


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


local function make_register_fact(adapter, instruction, effect_spec)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or not core.is_table(effect_spec.effect)
    then
        return nil
    end

    local effect = effect_spec.effect
    local target_index = tonumber(effect.target_operand)

    if not target_index then
        return nil
    end

    local target_operand = instruction.operands and instruction.operands[target_index]

    if not core.is_table(target_operand)
        or not core.is_non_empty_string(target_operand.text)
    then
        return nil
    end

    local value = effect.value

    if value == nil and tonumber(effect.value_operand) then
        local value_operand = instruction.operands[tonumber(effect.value_operand)]

        if value_operand then
            value = value_operand.text
        end
    end

    local static_spec = get_static_register_spec(adapter, target_operand.text) or {}

    return {
        name = target_operand.text:lower(),
        kind = static_spec.kind or "unknown",
        value = value,
        role = effect.role or static_spec.role,
        source = "instruction",

        source_line = target_operand.source_line,
        source_column = target_operand.source_column,

        source_start_line = target_operand.source_start_line,
        source_start_column = target_operand.source_start_column,
        source_end_line = target_operand.source_end_line,
        source_end_column = target_operand.source_end_column,

        metadata = {
            adapter = adapter.name,
            architecture = adapter.architecture,
            variant = adapter.active_variant_name,
            mnemonic = instruction.mnemonic,
            effect = effect.name,
        },
    }
end


local function apply_register_effect(facts_by_register, adapter, instruction, effect_spec)
    if not core.is_table(facts_by_register)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if instruction.mnemonic ~= effect_spec.mnemonic then
        return
    end

    if not operands_match_effect(instruction, effect_spec) then
        return
    end

    if not condition_matches(instruction, effect_spec.condition) then
        return
    end

    local fact = make_register_fact(adapter, instruction, effect_spec)

    if fact then
        facts_by_register[fact.name] = fact
    end
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

    local facts_by_register = {}

    for _, effect_spec in ipairs(adapter.register_effects) do
        if core.is_table(effect_spec)
            and core.is_non_empty_string(effect_spec.node_type)
            and core.is_non_empty_string(effect_spec.mnemonic)
        then
            local nodes = collect_nodes_by_type(root_node, effect_spec.node_type)

            for _, node in ipairs(nodes) do
                local node_line = node:start() + 1

                if not cursor_line or node_line <= cursor_line then
                    local instruction = collect_instruction_operands(
                        node,
                        bufnr,
                        effect_spec
                    )

                    apply_register_effect(
                        facts_by_register,
                        adapter,
                        instruction,
                        effect_spec
                    )
                end
            end
        end
    end

    local facts = {}

    for _, fact in pairs(facts_by_register) do
        table.insert(facts, fact)
    end

    return facts
end


local function operand_value_matches(operand, operand_spec)
    if type(operand_spec.value) ~= "string" then
        return true
    end

    if not core.is_table(operand) or not core.is_non_empty_string(operand.text) then
        return false
    end

    return operand.text:lower() == operand_spec.value:lower()
end


local function stack_operands_match_effect(instruction, effect_spec)
    if not core.is_table(instruction) or not core.is_table(effect_spec) then
        return false
    end

    for _, operand_spec in ipairs(effect_spec.operands or {}) do
        local index = tonumber(operand_spec.index)

        if not index then
            return false
        end

        local operand = instruction.operands and instruction.operands[index]

        if not operand_matches_spec(operand, operand_spec) then
            return false
        end

        if not operand_value_matches(operand, operand_spec) then
            return false
        end
    end

    return true
end


local function make_stack_fact(adapter, instruction, effect_spec)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or not core.is_table(effect_spec.effect)
    then
        return nil
    end

    local effect = effect_spec.effect
    local value = nil
    local size = effect.size
    local source_operand = nil

    if tonumber(effect.value_operand) then
        source_operand = instruction.operands[tonumber(effect.value_operand)]

        if source_operand then
            value = source_operand.text
        end
    end

    if tonumber(effect.size_operand) then
        local size_operand = instruction.operands[tonumber(effect.size_operand)]

        if size_operand then
            size = tonumber(size_operand.text) or size_operand.text
            source_operand = size_operand
        end
    end

    source_operand = source_operand or instruction.operands[1]

    local source_line = instruction.source_line
    local source_column = 0
    local source_start_line = instruction.source_line
    local source_start_column = 0
    local source_end_line = instruction.source_line
    local source_end_column = 0

    if source_operand then
        source_line = source_operand.source_line
        source_column = source_operand.source_column or 0
        source_start_line = source_operand.source_start_line
        source_start_column = source_operand.source_start_column or 0
        source_end_line = source_operand.source_end_line
        source_end_column = source_operand.source_end_column or source_column
    end

    local name = effect.name or effect.kind or instruction.mnemonic or "stack_effect"

    if value ~= nil then
        name = tostring(name) .. " " .. tostring(value)
    elseif size ~= nil then
        name = tostring(name) .. " " .. tostring(size)
    end

    return {
        name = name,
        kind = effect.kind or "stack_effect",
        value = value,
        offset = effect.offset,
        offset_delta = effect.offset_delta,
        size = size,
        role = effect.role,
        source = "instruction",

        source_line = source_line,
        source_column = source_column,

        source_start_line = source_start_line,
        source_start_column = source_start_column,
        source_end_line = source_end_line,
        source_end_column = source_end_column,

        metadata = {
            adapter = adapter.name,
            architecture = adapter.architecture,
            variant = adapter.active_variant_name,
            mnemonic = instruction.mnemonic,
            effect = effect.name,
        },
    }
end


local function apply_stack_effect(facts, adapter, instruction, effect_spec)
    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if instruction.mnemonic ~= effect_spec.mnemonic then
        return
    end

    if not stack_operands_match_effect(instruction, effect_spec) then
        return
    end

    if not condition_matches(instruction, effect_spec.condition) then
        return
    end

    local fact = make_stack_fact(adapter, instruction, effect_spec)

    if fact then
        table.insert(facts, fact)
    end
end


function M.collect_stack_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(adapter.stack_effects)
    then
        return {}
    end

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local facts = {}

    for _, effect_spec in ipairs(adapter.stack_effects) do
        if core.is_table(effect_spec)
            and core.is_non_empty_string(effect_spec.node_type)
            and core.is_non_empty_string(effect_spec.mnemonic)
        then
            local nodes = collect_nodes_by_type(root_node, effect_spec.node_type)

            for _, node in ipairs(nodes) do
                local node_line = node:start() + 1

                if not cursor_line or node_line <= cursor_line then
                    local instruction = collect_instruction_operands(
                        node,
                        bufnr,
                        effect_spec
                    )

                    apply_stack_effect(
                        facts,
                        adapter,
                        instruction,
                        effect_spec
                    )
                end
            end
        end
    end

    return facts
end


return M
