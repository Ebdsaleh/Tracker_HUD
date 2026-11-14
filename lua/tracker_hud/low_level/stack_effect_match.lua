-- lua/tracker_hud/low_level/stack_effect_match.lua
--
-- Stack-effect operand matching.
--
-- Stack rules retain one deliberate ASM compatibility exception: a
-- symbol-like operand that names a known architecture register may satisfy a
-- register operand spec. Generic effect matching does not own this rule.

local core = require("tracker_hud.core")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")

local M = {}


function M.operand_value_matches(
    operand,
    operand_spec
)
    if type(operand_spec.value)
        ~= "string"
    then
        return true
    end

    if not core.is_table(operand)
        or not core.is_non_empty_string(
            operand.text
        )
    then
        return false
    end

    return operand.text:lower()
        == operand_spec.value:lower()
end


function M.operand_matches_spec(
    adapter,
    operand,
    operand_spec
)
    if not core.is_table(operand)
        or not core.is_table(
            operand_spec
        )
    then
        return false
    end

    if type(operand_spec.kind)
            == "string"
        and operand.kind
            ~= operand_spec.kind
    then
        -- ASM registers can sometimes appear as symbol-like words depending
        -- on the exact instruction shape. Treat known architecture registers
        -- as registers for stack-effect matching.
        if operand_spec.kind
                == "register"
            and core.is_non_empty_string(
                operand.text
            )
            and register_state_read
                .get_static_spec(
                    adapter,
                    operand.text
                )
        then
            return true
        end

        return false
    end

    return true
end


function M.operands_match_effect(
    adapter,
    instruction,
    effect_spec
)
    if not core.is_table(adapter)
        or not core.is_table(
            instruction
        )
        or not core.is_table(
            effect_spec
        )
    then
        return false
    end

    for _, operand_spec in ipairs(
        effect_spec.operands or {}
    ) do
        local index =
            tonumber(
                operand_spec.index
            )

        if not index then
            return false
        end

        local operand =
            instruction.operands
            and instruction.operands[
                index
            ]

        if not M.operand_matches_spec(
            adapter,
            operand,
            operand_spec
        )
        then
            return false
        end

        if not M.operand_value_matches(
            operand,
            operand_spec
        )
        then
            return false
        end
    end

    return true
end


return M
