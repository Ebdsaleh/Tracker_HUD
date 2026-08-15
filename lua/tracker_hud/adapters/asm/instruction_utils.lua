-- lua/tracker_hud/adapters/asm/instruction_utils.lua
--
-- ASM instruction parsing helpers.
--
-- Tree-sitter owns syntax discovery.
-- The active adapter tells this module which Tree-sitter fields/children are
-- relevant and how those nodes should be interpreted as ASM operands.
--
-- This module does not emulate instructions.

local treesitter_utils = require("tracker_hud.treesitter_utils")

local M = {}


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


local function node_text(bufnr, node)
    if not node then
        return nil
    end

    return normalize_text(
        treesitter_utils.get_node_text(
            node,
            bufnr
        )
    )
end


local function get_construct_spec(adapter, node_type)
    if type(adapter) ~= "table"
        or type(adapter.construct_specs) ~= "table"
        or type(node_type) ~= "string"
        or node_type == ""
    then
        return nil
    end

    local spec = adapter.construct_specs[node_type]

    if type(spec) ~= "table" then
        return nil
    end

    return spec
end


local function get_syntax(spec)
    if type(spec) ~= "table"
        or type(spec.syntax) ~= "table"
    then
        return {}
    end

    return spec.syntax
end


local function get_syntax_field(spec, key)
    local syntax = get_syntax(spec)
    local fields = syntax.fields

    if type(fields) ~= "table" then
        return nil
    end

    local field_name = fields[key]

    if type(field_name) == "string"
        and field_name ~= ""
    then
        return field_name
    end

    if type(field_name) == "table"
        and type(field_name.field) == "string"
        and field_name.field ~= ""
    then
        return field_name.field
    end

    return nil
end


local function get_syntax_child_spec(spec, key)
    local syntax = get_syntax(spec)
    local children = syntax.children

    if type(children) ~= "table" then
        return nil
    end

    local child_spec = children[key]

    if type(child_spec) ~= "table" then
        return nil
    end

    return child_spec
end


local function list_contains(values, wanted)
    if type(values) ~= "table"
        or type(wanted) ~= "string"
    then
        return false
    end

    for _, value in ipairs(values) do
        if value == wanted then
            return true
        end
    end

    return false
end


local function node_matches_child_spec(node, child_spec)
    if not node or type(child_spec) ~= "table" then
        return false
    end

    local node_type = node:type()

    if type(child_spec.node_type) == "string"
        and child_spec.node_type == node_type
    then
        return true
    end

    return list_contains(
        child_spec.node_types,
        node_type
    )
end


local function node_has_descendant_type(node, wanted_type)
    if not node
        or type(wanted_type) ~= "string"
        or wanted_type == ""
    then
        return false
    end

    for child in node:iter_children() do
        if child:type() == wanted_type then
            return true
        end

        if node_has_descendant_type(
            child,
            wanted_type
        ) then
            return true
        end
    end

    return false
end


local function get_operand_kind_from_adapter(node, adapter)
    if not node then
        return nil
    end

    local spec = get_construct_spec(
        adapter,
        node:type()
    )

    if type(spec) ~= "table"
        or type(spec.operand) ~= "table"
    then
        return nil
    end

    local operand_spec = spec.operand
    local overrides = operand_spec.descendant_overrides

    if type(overrides) == "table" then
        for descendant_node_type, kind in pairs(overrides) do
            if type(descendant_node_type) == "string"
                and descendant_node_type ~= ""
                and type(kind) == "string"
                and kind ~= ""
                and node_has_descendant_type(
                    node,
                    descendant_node_type
                )
            then
                return kind
            end
        end
    end

    if type(operand_spec.kind) == "string"
        and operand_spec.kind ~= ""
    then
        return operand_spec.kind
    end

    return nil
end


local function classify_operand(bufnr, node, adapter)
    local text = node_text(bufnr, node)

    if not text then
        return nil
    end

    local node_type = node:type()
    local kind = get_operand_kind_from_adapter(
        node,
        adapter
    )

    -- Compatibility for older ASM adapters that do not yet declare operand
    -- semantics inside construct_specs.
    if not kind then
        if node_type == "int" then
            kind = "integer"
        elseif node_type == "reg"
            or node_has_descendant_type(node, "reg")
        then
            kind = "register"
        elseif node_type == "ident"
            or node_type == "word"
        then
            kind = "symbol"
        else
            kind = "unknown"
        end
    end

    local start_row, start_column, end_row, end_column =
        node:range()

    return {
        text = text,
        kind = kind,
        node_type = node_type,

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }
end


local function append_operand(
    operands,
    seen,
    bufnr,
    node,
    adapter
)
    local operand = classify_operand(
        bufnr,
        node,
        adapter
    )

    if not operand then
        return
    end

    local start_row, start_column = node:start()

    local key = table.concat({
        operand.text,
        operand.kind,
        operand.node_type,
        tostring(start_row),
        tostring(start_column),
    }, "|")

    if seen[key] then
        return
    end

    seen[key] = true

    table.insert(operands, operand)
end


local function get_mnemonic_node(
    instruction_node,
    instruction_spec
)
    local kind_field =
        get_syntax_field(
            instruction_spec,
            "kind"
        )

    if kind_field then
        local field_node =
            treesitter_utils.get_child_by_field_name(
                instruction_node,
                kind_field
            )

        if field_node then
            return field_node
        end
    end

    local kind_child =
        get_syntax_child_spec(
            instruction_spec,
            "kind"
        )

    if type(kind_child) == "table" then
        for child in instruction_node:iter_children() do
            if node_matches_child_spec(
                child,
                kind_child
            ) then
                return child
            end
        end
    end

    -- Compatibility for older ASM adapters.
    for child in instruction_node:iter_children() do
        if child:type() == "word" then
            return child
        end
    end

    return nil
end


local function collect_declared_operands(
    instruction_node,
    instruction_spec,
    bufnr,
    adapter
)
    local operands = {}
    local seen = {}

    local operand_child =
        get_syntax_child_spec(
            instruction_spec,
            "operands"
        )

    if type(operand_child) ~= "table" then
        return nil
    end

    for child in instruction_node:iter_children() do
        if node_matches_child_spec(
            child,
            operand_child
        ) then
            append_operand(
                operands,
                seen,
                bufnr,
                child,
                adapter
            )
        end
    end

    return operands
end


local function collect_legacy_operands(
    instruction_node,
    bufnr,
    adapter,
    mnemonic_node
)
    local operands = {}
    local seen = {}
    local mnemonic_seen = false

    for child in instruction_node:iter_children() do
        local child_type = child:type()

        if child_type == "word"
            and not mnemonic_seen
        then
            mnemonic_seen = true
        elseif child_type == "reg"
            or child_type == "ident"
            or child_type == "int"
            or child_type == "word"
        then
            append_operand(
                operands,
                seen,
                bufnr,
                child,
                adapter
            )
        end
    end

    return operands
end


function M.parse_instruction(
    bufnr,
    instruction_node,
    _effect_spec,
    adapter
)
    if not instruction_node then
        return nil
    end

    local instruction_spec = get_construct_spec(
        adapter,
        instruction_node:type()
    )

    local syntax = get_syntax(instruction_spec)
    local expected_node_type = syntax.node_type
        or "instruction"

    if instruction_node:type() ~= expected_node_type then
        return nil
    end

    local mnemonic_node = get_mnemonic_node(
        instruction_node,
        instruction_spec
    )

    local mnemonic = node_text(
        bufnr,
        mnemonic_node
    )

    if not mnemonic then
        return nil
    end

    local mnemonic_range = nil

    if mnemonic_node then
        local start_row,
            start_column,
            end_row,
            end_column = mnemonic_node:range()

        mnemonic_range = {
            source_line = start_row + 1,
            source_column = start_column,

            source_start_line = start_row + 1,
            source_start_column = start_column,

            source_end_line = end_row + 1,
            source_end_column = end_column,
        }
    end

    local operands = collect_declared_operands(
        instruction_node,
        instruction_spec,
        bufnr,
        adapter
    )

    if operands == nil then
        operands = collect_legacy_operands(
            instruction_node,
            bufnr,
            adapter,
            mnemonic_node
        )
    end

    local start_row,
        start_column,
        end_row,
        end_column = instruction_node:range()

    return {
        mnemonic = mnemonic:lower(),
        mnemonic_range = mnemonic_range,

        operands = operands,

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }
end


return M

