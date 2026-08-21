-- lua/tracker_hud/low_level/stack_infer.lua
--
-- Generic stack inference helpers.
--
-- The adapter/spec layer declares which effects push values onto the stack,
-- read from the stack top, or adjust stack depth. This module keeps only the
-- tiny value/depth state needed by later register/stack display code.
--
-- This is not a simulator. It is a cheap state reducer for declared low-level
-- facts: push-like facts, pop-like facts, return-address facts, and relative
-- stack-depth facts.

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


local function get_metadata(state)
    if not core.is_table(state) then
        return nil
    end

    state.metadata = core.is_table(state.metadata) and state.metadata or {}
    state.metadata.stack = core.is_table(state.metadata.stack)
        and state.metadata.stack
        or {}

    local metadata = state.metadata.stack

    if not core.is_number(metadata.depth_bytes) then
        metadata.depth_bytes = 0
    end

    if not core.is_number(metadata.sequence) then
        metadata.sequence = 0
    end

    return metadata
end


local function next_sequence(state)
    local metadata = get_metadata(state)

    if not metadata then
        return nil
    end

    metadata.sequence = metadata.sequence + 1

    return metadata.sequence
end


local function parse_number(value, opts)
    if type(value) == "number" then
        return value
    end

    if value == nil then
        return nil
    end

    opts = opts or {}

    if type(opts.parse_numeric_value) == "function" then
        local parsed = opts.parse_numeric_value(value)

        if parsed ~= nil then
            return parsed
        end
    end

    return tonumber(value)
end


local function signed(value)
    if not core.is_number(value) then
        return nil
    end

    if value > 0 then
        return "+" .. tostring(value)
    end

    return tostring(value)
end


local function effect_size_value(effect, instruction, opts)
    if not core.is_table(effect) then
        return nil
    end

    local size = effect.size

    if tonumber(effect.size_operand)
        and core.is_table(instruction)
        and core.is_table(instruction.operands)
    then
        local operand = instruction.operands[tonumber(effect.size_operand)]

        if operand then
            size = parse_number(operand.text, opts) or operand.text
        end
    end

    return size
end


local function effect_delta_value(effect, instruction, opts)
    if not core.is_table(effect) then
        return nil
    end

    local explicit_delta = parse_number(effect.offset_delta, opts)

    if explicit_delta ~= nil then
        return explicit_delta
    end

    local size = parse_number(effect_size_value(effect, instruction, opts), opts)

    if size == nil then
        return nil
    end

    if effect.kind == "stack_allocate" then
        return -math.abs(size)
    end

    if effect.kind == "stack_deallocate" then
        return math.abs(size)
    end

    if effect.kind == "stack_push" or effect.kind == "stack_call" then
        return -math.abs(size)
    end

    if effect.kind == "stack_pop" or effect.kind == "stack_return" then
        return math.abs(size)
    end

    return nil
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


local function effect_has_synthetic_push_value(effect)
    return core.is_table(effect)
        and effect.stack_push_value ~= nil
end


local function effect_pushes_stack_value(effect)
    return get_stack_push_operand_index(effect) ~= nil
        or effect_has_synthetic_push_value(effect)
        or (core.is_table(effect)
            and (effect.kind == "stack_push" or effect.kind == "stack_call"))
end


local function effect_reads_stack_top(effect)
    return core.is_table(effect)
        and (
            effect.kind == "stack_pop"
            or effect.kind == "stack_return"
            or effect.stack_reads_top == true
            or effect.value_from_stack_top == true
            or effect.value_from_stack == "top"
        )
end


local function effect_only_adjusts_depth(effect)
    return core.is_table(effect)
        and not effect_pushes_stack_value(effect)
        and not effect_reads_stack_top(effect)
        and (
            effect.offset_delta ~= nil
            or effect.kind == "stack_allocate"
            or effect.kind == "stack_deallocate"
        )
end


local function make_unknown_value_fact(instruction, effect)
    return inference.new_value_fact({
        value = nil,
        resolved = false,
        source = "instruction",
        source_kind = effect and effect.stack_push_source_kind or "unknown",
        source_text = effect and effect.stack_push_source_text or "<unknown>",
        metadata = {
            mnemonic = instruction and instruction.mnemonic,
        },
    })
end


local function make_synthetic_value_fact(instruction, effect)
    return inference.new_value_fact({
        value = effect.stack_push_value,
        resolved = effect.stack_push_value ~= nil,
        source = "instruction",
        source_kind = effect.stack_push_source_kind or "synthetic",
        source_name = effect.stack_push_source_name,
        source_text = effect.stack_push_source_text
            or effect.stack_push_source_name
            or tostring(effect.stack_push_value),
        source_line = instruction and instruction.source_line,
        source_column = instruction and instruction.source_column or 0,
        source_start_line = instruction and instruction.source_start_line,
        source_start_column = instruction and instruction.source_start_column or 0,
        source_end_line = instruction and instruction.source_end_line,
        source_end_column = instruction and instruction.source_end_column or 0,
        metadata = {
            mnemonic = instruction and instruction.mnemonic,
            synthetic_stack_value = true,
        },
    })
end


function M.current_depth(state)
    local metadata = get_metadata(state)

    return metadata and metadata.depth_bytes or 0
end


function M.push(state, value_fact, opts)
    if not core.is_table(state) then
        return nil
    end

    opts = opts or {}

    state.stack = core.is_table(state.stack) and state.stack or {}

    local metadata = get_metadata(state)
    local before = metadata and metadata.depth_bytes or 0
    local delta = parse_number(opts.offset_delta)

    if delta == nil and core.is_number(opts.size) then
        delta = -math.abs(opts.size)
    end

    local fact = core.is_table(value_fact)
        and value_fact
        or inference.new_value_fact({
            value = value_fact,
            resolved = value_fact ~= nil,
        })

    if core.is_number(delta) and metadata then
        metadata.depth_bytes = metadata.depth_bytes + delta
    end

    local after = metadata and metadata.depth_bytes or before

    fact.stack_sequence = next_sequence(state)
    fact.stack_depth_before = before
    fact.stack_depth_after = after
    fact.stack_depth_delta = delta
    fact.stack_depth_label = signed(after)
    fact.stack_slot = #state.stack + 1

    table.insert(state.stack, fact)

    return fact
end


function M.peek(state)
    if not core.is_table(state) or not core.is_table(state.stack) then
        return nil
    end

    return state.stack[#state.stack]
end


function M.pop(state, opts)
    if not core.is_table(state) then
        return nil, {}
    end

    opts = opts or {}

    state.stack = core.is_table(state.stack) and state.stack or {}

    local metadata = get_metadata(state)
    local before = metadata and metadata.depth_bytes or 0
    local value_fact = table.remove(state.stack)
    local delta = parse_number(opts.offset_delta)

    if delta == nil and core.is_number(opts.size) then
        delta = math.abs(opts.size)
    end

    if core.is_number(delta) and metadata then
        metadata.depth_bytes = metadata.depth_bytes + delta
    end

    local after = metadata and metadata.depth_bytes or before

    local read_state = {
        stack_depth_before = before,
        stack_depth_after = after,
        stack_depth_delta = delta,
        stack_depth_label = signed(after),
        stack_read_missing = value_fact == nil,
    }

    if core.is_table(value_fact) then
        value_fact.stack_read_sequence = next_sequence(state)
        value_fact.stack_read_depth_before = before
        value_fact.stack_read_depth_after = after
        value_fact.stack_read_depth_delta = delta
    end

    return value_fact, read_state
end


function M.adjust_depth(state, effect, instruction, opts)
    if not core.is_table(state) or not core.is_table(effect) then
        return nil
    end

    opts = opts or {}

    local metadata = get_metadata(state)
    local before = metadata and metadata.depth_bytes or 0
    local delta = effect_delta_value(effect, instruction, opts)

    if core.is_number(delta) and metadata then
        metadata.depth_bytes = metadata.depth_bytes + delta
    end

    return {
        stack_depth_before = before,
        stack_depth_after = metadata and metadata.depth_bytes or before,
        stack_depth_delta = delta,
        stack_depth_label = signed(metadata and metadata.depth_bytes or before),
        size = effect_size_value(effect, instruction, opts),
    }
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

    instruction_state.stack_depth_before = M.current_depth(state)

    for _, effect_spec in ipairs(effect_specs) do
        local effect = get_effect(effect_spec)

        if core.is_table(effect) then
            local size = effect_size_value(effect, instruction, opts)
            local numeric_size = parse_number(size, opts)
            local delta = effect_delta_value(effect, instruction, opts)
            local push_operand_index = get_stack_push_operand_index(effect)

            if effect_pushes_stack_value(effect)
                and not instruction_state.stack_push
            then
                local value_fact = nil

                if effect_has_synthetic_push_value(effect) then
                    value_fact = make_synthetic_value_fact(instruction, effect)
                elseif push_operand_index then
                    local operand = instruction.operands
                        and instruction.operands[push_operand_index]
                        or nil

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
                else
                    value_fact = make_unknown_value_fact(instruction, effect)
                end

                instruction_state.stack_push = M.push(state, value_fact, {
                    size = numeric_size,
                    offset_delta = delta,
                })

                instruction_state.stack_depth_after = M.current_depth(state)
                instruction_state.stack_depth_delta = delta
                instruction_state.stack_push_operand_index = push_operand_index
            end

            if effect_reads_stack_top(effect)
                and not instruction_state.stack_pop_checked
            then
                instruction_state.stack_pop_checked = true

                local stack_value, read_state = M.pop(state, {
                    size = numeric_size,
                    offset_delta = delta,
                })

                instruction_state.stack_pop = stack_value
                instruction_state.stack_pop_missing = stack_value == nil
                instruction_state.stack_depth_after = read_state.stack_depth_after
                instruction_state.stack_depth_delta = read_state.stack_depth_delta
                instruction_state.stack_read_state = read_state
            end

            if effect_only_adjusts_depth(effect)
                and not instruction_state.stack_adjust
            then
                instruction_state.stack_adjust = M.adjust_depth(
                    state,
                    effect,
                    instruction,
                    opts
                )

                instruction_state.stack_depth_after =
                    instruction_state.stack_adjust.stack_depth_after
                instruction_state.stack_depth_delta =
                    instruction_state.stack_adjust.stack_depth_delta
            end
        end
    end

    if instruction_state.stack_depth_after == nil then
        instruction_state.stack_depth_after = M.current_depth(state)
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

    if not index and effect_reads_stack_top(effect) then
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


local function get_read_state_from_instruction_state(instruction_state)
    if not core.is_table(instruction_state) then
        return nil
    end

    return instruction_state.stack_read_state
        or instruction_state.stack_adjust
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
    local read_state = get_read_state_from_instruction_state(instruction_state)
    local reads_stack_top = effect_reads_stack_top(effect)
    local value = nil
    local resolved = false
    local size = effect_size_value(effect, instruction, {
        parse_numeric_value = tonumber,
    })

    if core.is_table(stack_value) and stack_value.value ~= nil then
        value = stack_value.value
        resolved = stack_value.resolved ~= false
    elseif reads_stack_top then
        -- A pop/read-from-stack-top without a known tracked stack value should
        -- remain unresolved. Do not treat the destination operand as the value.
        value = nil
        resolved = false
    elseif effect_has_synthetic_push_value(effect) then
        value = effect.stack_push_value
        resolved = value ~= nil
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
            source_operand = source_operand or size_operand
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
        or effect.destination_register

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

    local depth_before = instruction_state and instruction_state.stack_depth_before
    local depth_after = instruction_state and instruction_state.stack_depth_after
    local depth_delta = instruction_state and instruction_state.stack_depth_delta

    if core.is_table(stack_value) then
        depth_before = stack_value.stack_depth_before
            or stack_value.stack_read_depth_before
            or depth_before
        depth_after = stack_value.stack_depth_after
            or stack_value.stack_read_depth_after
            or depth_after
        depth_delta = stack_value.stack_depth_delta
            or stack_value.stack_read_depth_delta
            or depth_delta
    elseif core.is_table(read_state) then
        depth_before = read_state.stack_depth_before or depth_before
        depth_after = read_state.stack_depth_after or depth_after
        depth_delta = read_state.stack_depth_delta or depth_delta
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

        stack_depth_before = depth_before,
        stack_depth_after = depth_after,
        stack_depth_delta = depth_delta,
        stack_depth_label = signed(depth_after),

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
                or effect.stack_push_source_kind
                or (source_operand and source_operand.kind),
            value_source_text = core.is_table(stack_value)
                and stack_value.source_text
                or effect.stack_push_source_text
                or (source_operand and source_operand.text),
            destination_register = destination_register,
            destination_text = destination_operand and destination_operand.text or nil,
            destination_kind = destination_operand and destination_operand.kind or nil,
            reads_stack_top = reads_stack_top,
            stack_read_resolved = (not reads_stack_top) or resolved,
            stack_read_missing = reads_stack_top and not core.is_table(stack_value),
            stack_depth_before = depth_before,
            stack_depth_after = depth_after,
            stack_depth_delta = depth_delta,
            stack_depth_label = signed(depth_after),
        },
    }
end


return M
