-- lua/tracker_hud/adapters/asm_instruction_utils.lua
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


local function is_register_node(node)
    if not node then
        return false
    end

    local node_type = node:type()

    if node_type == "reg" then
        return true
    end

    local parent = node:parent()

    while parent do
        if parent:type() == "reg" then
            return true
        end

        if parent:type() == "instruction" then
            break
        end

        parent = parent:parent()
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

    return {
        text = text,
        kind = kind,
        node_type = node_type,
    }
end


local function append_operand(operands, seen, bufnr, node)
    local operand = classify_operand(bufnr, node)

    if not operand then
        return
    end

    local key = table.concat({
        operand.text,
        operand.kind,
        operand.node_type,
        tostring(node:start()),
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

    return {
        mnemonic = mnemonic,
        operands = operands,
        source_line = instruction_node:start() + 1,
    }
end


return M
