-- lua/tracker_hud/low_level/instruction_source.lua
--
-- Generic instruction-source traversal and fallback parsing.
--
-- Adapter-specific instruction parsers retain first refusal. This module owns
-- only the language-neutral fallback path and recursive node collection used
-- by low-level source inference.

local core = require("tracker_hud.core")

local M = {}


function M.normalize_text(text)
    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("^%s+", "")
        :gsub("%s+$", "")

    if text == "" then
        return nil
    end

    return text
end


local function node_text(
    node,
    bufnr,
    opts
)
    if not node
        or type(opts.get_node_text)
            ~= "function"
    then
        return nil
    end

    return M.normalize_text(
        opts.get_node_text(
            node,
            bufnr
        )
    )
end


function M.node_has_descendant_type(
    node,
    wanted_type
)
    if not node
        or type(wanted_type) ~= "string"
    then
        return false
    end

    for child in node:iter_children() do
        if child:type() == wanted_type then
            return true
        end

        if M.node_has_descendant_type(
            child,
            wanted_type
        ) then
            return true
        end
    end

    return false
end


function M.node_has_ancestor_type_until(
    node,
    wanted_type,
    stop_type
)
    if not node
        or type(wanted_type) ~= "string"
    then
        return false
    end

    local parent = node:parent()

    while parent do
        if parent:type() == wanted_type then
            return true
        end

        if stop_type
            and parent:type() == stop_type
        then
            break
        end

        parent = parent:parent()
    end

    return false
end


function M.infer_operand_kind(
    node,
    effect_spec
)
    if not node then
        return "unknown"
    end

    local node_type = node:type()
    local instruction_node_type =
        effect_spec.node_type
        or "instruction"

    if node_type == "int" then
        return "integer"
    end

    if node_type == "reg"
        or M.node_has_ancestor_type_until(
            node,
            "reg",
            instruction_node_type
        )
        or M.node_has_descendant_type(
            node,
            "reg"
        )
    then
        return "register"
    end

    if node_type == "ident"
        or node_type == "word"
    then
        return "symbol"
    end

    return "unknown"
end


function M.build_operand(
    node,
    bufnr,
    effect_spec,
    opts
)
    opts = opts or {}

    local text = node_text(
        node,
        bufnr,
        opts
    )

    if not text then
        return nil
    end

    local start_row,
        start_column,
        end_row,
        end_column =
        node:range()

    return {
        text = text,
        kind = M.infer_operand_kind(
            node,
            effect_spec
        ),
        node_type = node:type(),

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line =
            start_row + 1,
        source_start_column =
            start_column,
        source_end_line =
            end_row + 1,
        source_end_column =
            end_column,
    }
end


function M.collect_instruction(
    adapter,
    node,
    bufnr,
    effect_spec,
    opts
)
    opts = opts or {}

    if type(
        opts.parse_with_adapter
    ) == "function"
    then
        local adapter_instruction =
            opts.parse_with_adapter(
                adapter,
                bufnr,
                node,
                effect_spec
            )

        if adapter_instruction then
            return adapter_instruction
        end
    end

    if not node
        or type(opts.get_node_text)
            ~= "function"
    then
        return nil
    end

    local operands = {}
    local mnemonic = nil
    local mnemonic_seen = false

    for child in node:iter_children() do
        local child_type =
            child:type()

        if child_type == "word"
            and not mnemonic_seen
        then
            mnemonic = node_text(
                child,
                bufnr,
                opts
            )
            mnemonic_seen = true
        elseif child_type == "reg"
            or child_type == "ident"
            or child_type == "int"
            or child_type == "word"
        then
            local operand =
                M.build_operand(
                    child,
                    bufnr,
                    effect_spec,
                    opts
                )

            if operand then
                table.insert(
                    operands,
                    operand
                )
            end
        end
    end

    return {
        mnemonic = mnemonic
            and mnemonic:lower()
            or nil,
        operands = operands,
        source_line =
            node:start() + 1,
    }
end


function M.collect_nodes_by_type(
    node,
    node_type,
    result
)
    result = result or {}

    if not node
        or type(node_type) ~= "string"
        or node_type == ""
    then
        return result
    end

    if node:type() == node_type then
        table.insert(
            result,
            node
        )
    end

    for child in node:iter_children() do
        M.collect_nodes_by_type(
            child,
            node_type,
            result
        )
    end

    return result
end


return M
