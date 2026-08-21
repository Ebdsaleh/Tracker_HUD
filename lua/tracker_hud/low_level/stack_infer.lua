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

    if effect.kind == "stack_push" then
        return tonumber(
            effect.stack_push_operand
                or effect.push_operand
                or effect.value_to_stack_operand
                or effect.value_operand
        )
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
            effect.kind == "stack_pop"
            or effect.value_from_stack_top == true
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
    if not core.is_table(state) then
        return nil
    end

    state.stack = core.is_table(state.stack) and state.stack or {}

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
            and not instruction_state.stack_pop_checked
        then
            instruction_state.stack_pop_checked = true
            instruction_state.stack_pop = M.pop(state)
            instruction_state.stack_pop_missing = instruction_state.stack_pop == nil
        end
    end

    return instruction_state
end


local function get_source_operand(instruction, effect)
    if not core.is_table(instruction) or not core.is_table(effect) then
        return nil
    end

    local index = tonumber(effect.value_operand)
        or tonumber(effect.source_operand)
        or tonumber(effect.target_operand)
        or 1

    return instruction.operands and instruction.operands[index] or nil
end


local function get_destination_operand(instruction, effect)
    if not core.is_table(instruction) or not core.is_table(effect) then
        return nil
    end

    local index = tonumber(effect.destination_operand)
        or tonumber(effect.target_operand)

    if not index and effect.kind == "stack_pop" then
        index = tonumber(effect.value_operand) or 1
    end

    return index and instruction.operands and instruction.operands[index] or nil
end


local function operand_register_name(operand)
    if not core.is_table(operand)
        or operand.kind ~= "register"
        or not core.is_non_empty_string(operand.text)
    then
        return nil
    end

    return operand.text
end


local function get_stack_value_from_instruction_state(instruction_state)
    if not core.is_table(instruction_state) then
        return nil
    end

    return instruction_state.stack_pop or instruction_state.stack_push
end


function M.make_effect_fact(adapter, instruction, effect_spec, instruction_state)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return nil
    end

    local effect = get_effect(effect_spec)

    if not core.is_table(effect) then
        return nil
    end

    local source_operand = get_source_operand(instruction, effect)
    local destination_operand = get_destination_operand(instruction, effect)
    local stack_value = get_stack_value_from_instruction_state(instruction_state)
    local reads_stack_top = effect_reads_stack_top(effect)
    local value = nil
    local resolved = false
    local size = effect.size

    if core.is_table(stack_value) and stack_value.value ~= nil then
        value = stack_value.value
        resolved = stack_value.resolved ~= false
    elseif reads_stack_top then
        -- A pop/read-from-stack-top without a known tracked stack value should
        -- remain unresolved. Do not treat the destination operand as the value.
        value = nil
        resolved = false
    elseif tonumber(effect.value_operand) then
        source_operand = instruction.operands[tonumber(effect.value_operand)]

        if source_operand then
            value = source_operand.text
            resolved = value ~= nil
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
    local destination_register = operand_register_name(destination_operand)

    if destination_register then
        name = tostring(name) .. " " .. tostring(destination_register)
    end

    if value ~= nil then
        name = tostring(name) .. " = " .. tostring(value)
    elseif reads_stack_top then
        name = tostring(name) .. " = <unknown>"
    elseif size ~= nil then
        name = tostring(name) .. " " .. tostring(size)
    end

    return {
        name = name,
        kind = effect.kind or "stack_effect",
        value = value,
        resolved = resolved,
        destination_register = destination_register,
        destination = destination_operand and destination_operand.text or nil,
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
            value_resolved = resolved,
            value_source_kind = core.is_table(stack_value)
                and stack_value.source_kind
                or (source_operand and source_operand.kind),
            value_source_text = core.is_table(stack_value)
                and stack_value.source_text
                or (source_operand and source_operand.text),
            destination_register = destination_register,
            destination_text = destination_operand and destination_operand.text or nil,
            destination_kind = destination_operand and destination_operand.kind or nil,
            reads_stack_top = reads_stack_top,
            stack_read_resolved = (not reads_stack_top) or resolved,
            stack_read_missing = reads_stack_top and not core.is_table(stack_value),
        },
    }
end


return M
