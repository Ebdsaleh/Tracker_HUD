-- lua/tracker_hud/low_level/stack_infer.lua
--
-- Generic stack inference helpers.
--
-- The adapter/spec layer declares which effects push values onto the stack or
-- read from the stack top. This module keeps the tiny stack-value state needed
-- by later register/stack display code.

local core = require("tracker_hud.core")
local inference = require("tracker_hud.low_level.inference")

local M = {}


local function get_effect(effect_spec)
    if not core.is_table(effect_spec) then
        return nil
    end

    if core.is_table(effect_spec.effect) then
        return effect_spec.effect
    end

    return effect_spec
end


local function get_stack_push_operand_index(effect)
    if not core.is_table(effect) then
        return nil
    end

    return tonumber(
        effect.stack_push_operand
            or effect.push_operand
            or effect.value_to_stack_operand
    )
end


local function effect_reads_stack_top(effect)
    return core.is_table(effect)
        and (
            effect.value_from_stack_top == true
            or effect.value_from_stack == "top"
        )
end


function M.push(state, value_fact)
    if not core.is_table(state) then
        return nil
    end

    state.stack = core.is_table(state.stack) and state.stack or {}

    local fact = core.is_table(value_fact)
        and value_fact
        or inference.new_value_fact({
            value = value_fact,
            resolved = value_fact ~= nil,
        })

    table.insert(state.stack, fact)

    return fact
end


function M.peek(state)
    if not core.is_table(state) or not core.is_table(state.stack) then
        return nil
    end

    return state.stack[#state.stack]
end


function M.pop(state)
    if not core.is_table(state) or not core.is_table(state.stack) then
        return nil
    end

    return table.remove(state.stack)
end


function M.prepare_instruction_state(state, instruction, effect_specs, opts)
    opts = opts or {}

    local instruction_state = {}

    if not core.is_table(state)
        or not core.is_table(instruction)
        or not core.is_table(effect_specs)
    then
        return instruction_state
    end

    for _, effect_spec in ipairs(effect_specs) do
        local effect = get_effect(effect_spec)

        local push_operand_index = get_stack_push_operand_index(effect)

        if push_operand_index and not instruction_state.stack_push then
            local operand = instruction.operands
                and instruction.operands[push_operand_index]
                or nil

            local value_fact = nil

            if type(opts.resolve_operand_value) == "function" then
                value_fact = opts.resolve_operand_value(operand)
            else
                value_fact = inference.new_value_fact({
                    value = operand and operand.text,
                    resolved = operand and operand.text ~= nil,
                    source = "instruction",
                    source_kind = operand and operand.kind or "unknown",
                    source_text = operand and operand.text or "<unknown>",
                })
            end

            instruction_state.stack_push = M.push(state, value_fact)
        end

        if effect_reads_stack_top(effect)
            and not instruction_state.stack_pop
        then
            instruction_state.stack_pop = M.pop(state)
        end
    end

    return instruction_state
end


return M
