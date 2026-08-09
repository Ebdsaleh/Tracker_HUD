-- lua/tracker_hud/adapters/asm/instruction_utils.lua
--
-- ASM instruction parsing helpers.
--
-- This module is intentionally small. It does not emulate instructions.
-- It only converts Tree-sitter instruction nodes into simple instruction facts.

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

    -- treesitter_utils.get_node_text() expects:
    --   get_node_text(node, bufnr)
    return normalize_text(treesitter_utils.get_node_text(node, bufnr))
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


local function node_has_ancestor_type_until_instruction(node, wanted_type)
    if not node or type(wanted_type) ~= "string" then
        return false
    end

    local parent = node:parent()

    while parent do
        if parent:type() == wanted_type then
            return true
        end

        if parent:type() == "instruction" then
            break
        end

        parent = parent:parent()
    end

    return false
end


local function is_register_node(node)
    if not node then
        return false
    end

    if node:type() == "reg" then
        return true
    end

    if node_has_ancestor_type_until_instruction(node, "reg") then
        return true
    end

    if node_has_descendant_type(node, "reg") then
        return true
    end

    return false
end



local function classify_operand(bufnr, node)
    local text = node_text(bufnr, node)

    if not text then
        return nil
    end

    local node_type = node:type()
    local kind = "unknown"

    if node_type == "int" then
        kind = "integer"
    elseif is_register_node(node) then
        kind = "register"
    elseif node_type == "ident" or node_type == "word" then
        kind = "symbol"
    end

    local start_row, start_column, end_row, end_column = node:range()

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


local function append_operand(operands, seen, bufnr, node)
    local operand = classify_operand(bufnr, node)

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


function M.parse_instruction(bufnr, instruction_node)
    if not instruction_node or instruction_node:type() ~= "instruction" then
        return nil
    end

    local mnemonic = nil
    local operands = {}
    local seen_operands = {}

    for child in instruction_node:iter_children() do
        local child_type = child:type()

        if child_type == "word" and not mnemonic then
            mnemonic = node_text(bufnr, child)
        elseif child_type == "reg" or child_type == "ident" or child_type == "int" then
            append_operand(operands, seen_operands, bufnr, child)
        end
    end

    mnemonic = mnemonic and mnemonic:lower() or nil

    if not mnemonic then
        return nil
    end

    local start_row, start_column, end_row, end_column = instruction_node:range()

    return {
        mnemonic = mnemonic,
        operands = operands,

        source_line = instruction_node:start() + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }
end


return M

