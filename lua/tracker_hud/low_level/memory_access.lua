-- lua/tracker_hud/low_level/memory_access.lua
--
-- Architecture-neutral memory access-intent resolution.
--
-- This module classifies what source syntax says an instruction intends to do
-- with a normalized memory operand. It does not claim that the instruction
-- executed, that an effective address is known, or that memory contents are
-- known.

local M = {}

M.valid_kinds = {
    read = true,
    write = true,
    read_write = true,
    address_only = true,
    unknown = true,
}

local function normalize_mnemonic(value)
    if type(value) ~= "string" or value == "" then
        return nil
    end

    return value:lower()
end

function M.is_valid(access)
    return type(access) == "string"
        and M.valid_kinds[access] == true
end

function M.resolve(rules, mnemonic, operand_index, operand)
    local normalized_mnemonic = normalize_mnemonic(mnemonic)

    local metadata = {
        declared = false,
        ambiguous = false,
        mnemonic = normalized_mnemonic,
        operand_index = operand_index,
        rule_count = 0,
    }

    if type(rules) ~= "table"
        or not normalized_mnemonic
        or type(operand_index) ~= "number"
    then
        return "unknown", metadata
    end

    local candidates = rules[normalized_mnemonic]

    if type(candidates) ~= "table" then
        return "unknown", metadata
    end

    local access = nil

    for _, rule in ipairs(candidates) do
        if type(rule) == "table"
            and rule.operand_index == operand_index
            and (
                rule.operand_kind == nil
                or (
                    type(operand) == "table"
                    and operand.kind == rule.operand_kind
                )
            )
        then
            metadata.rule_count = metadata.rule_count + 1

            if M.is_valid(rule.access) then
                metadata.declared = true

                if access == nil then
                    access = rule.access
                elseif access ~= rule.access then
                    metadata.ambiguous = true
                end
            end
        end
    end

    if metadata.ambiguous then
        return "unknown", metadata
    end

    return access or "unknown", metadata
end

return M
