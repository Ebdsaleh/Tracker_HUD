-- lua/tracker_hud/low_level/boundary_infer.lua
--
-- Generic boundary inference helpers.
--
-- Boundaries include syscall/call/API-like transitions. This module consumes
-- adapter-declared boundary contracts and resolves their reads, writes,
-- not-preserved facts, and known boundary variants from the provided state.

local core = require("tracker_hud.core")
local register_infer = require("tracker_hud.low_level.register_infer")

local M = {}


local function index_required_arguments(known_effect)
    local result = {}

    if not core.is_table(known_effect)
        or not core.is_table(known_effect.required_arguments)
    then
        return result
    end

    for _, argument_index in ipairs(known_effect.required_arguments) do
        local numeric_index = tonumber(argument_index)

        if numeric_index then
            result[numeric_index] = true
        end
    end

    return result
end


local function get_argument_name(known_effect, index)
    if not core.is_table(known_effect)
        or not core.is_table(known_effect.argument_names)
    then
        return nil
    end

    return known_effect.argument_names[tonumber(index)]
end


local function build_reads(context, effect_spec, known_effect)
    local reads = {}
    local read_spec = effect_spec.reads or {}
    local required_arguments = index_required_arguments(known_effect)

    if core.is_non_empty_string(read_spec.number_register) then
        table.insert(reads, {
            role = "number",
            register = read_spec.number_register,
            value = register_infer.get_value_from_context(
                context,
                read_spec.number_register
            ),
            resolved = register_infer.get_resolved_from_context(
                context,
                read_spec.number_register
            ),
            required = true,
        })
    end

    for index, register_name in ipairs(read_spec.argument_registers or {}) do
        table.insert(reads, {
            role = "argument",
            index = index,
            argument_name = get_argument_name(known_effect, index),
            register = register_name,
            value = register_infer.get_value_from_context(
                context,
                register_name
            ),
            resolved = register_infer.get_resolved_from_context(
                context,
                register_name
            ),
            required = required_arguments[index] == true,
        })
    end

    return reads
end


local function build_writes(context, effect_spec, known_effect)
    local writes = {}
    local write_spec = effect_spec.writes or {}

    if core.is_table(known_effect)
        and (known_effect.returns == false
            or known_effect.no_return == true
            or known_effect.does_not_return == true
            or known_effect.terminates == true
            or type(known_effect.terminates) == "string")
    then
        return writes
    end

    if core.is_non_empty_string(write_spec.return_register) then
        table.insert(writes, {
            role = "return",
            register = write_spec.return_register,
            value = register_infer.get_value_from_context(
                context,
                write_spec.return_register
            ),
        })
    end

    return writes
end


local function build_not_preserved(context, effect_spec)
    local results = {}
    local spec = effect_spec.not_preserved or {}

    local registers = spec.registers
        or effect_spec.not_preserved_registers
        or {}

    for _, register_name in ipairs(registers) do
        if core.is_non_empty_string(register_name) then
            table.insert(results, {
                role = "not_preserved",
                register = register_name,
                previous_value = register_infer.get_value_from_context(
                    context,
                    register_name
                ),
                previous_resolved = register_infer.get_resolved_from_context(
                    context,
                    register_name
                ),
            })
        end
    end

    return results
end

local function get_effect_key(context, effect_spec)
    local read_spec = effect_spec.reads or {}
    local number_register = read_spec.number_register

    if not core.is_non_empty_string(number_register) then
        return nil
    end

    local value = register_infer.get_value_from_context(
        context,
        number_register
    )

    if value == nil then
        return nil
    end

    return tostring(value)
end


function M.resolve_known_effect(context, effect_spec)
    local key = get_effect_key(context, effect_spec)

    if not key then
        return nil, nil
    end

    local known_effects = effect_spec.known_effects or {}

    return known_effects[key], key
end


function M.make_effect_fact(context, adapter, instruction, effect_spec, phase_contexts)
    if not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return nil
    end

    phase_contexts = phase_contexts or {}

    local read_context = core.is_table(phase_contexts.read_context)
        and phase_contexts.read_context
        or context

    local write_context = core.is_table(phase_contexts.write_context)
        and phase_contexts.write_context
        or context

    local known_effect, effect_key = M.resolve_known_effect(
        read_context,
        effect_spec
    )

    local name = effect_spec.kind or "boundary_effect"
    local category = effect_spec.category or "unknown"

    if core.is_table(known_effect) then
        name = known_effect.name or name
        category = known_effect.category or category
    end

    return {
        kind = effect_spec.kind or "boundary_effect",
        category = category,
        name = name,
        effect_key = effect_key,
        known_effect = known_effect,

        reads = build_reads(read_context, effect_spec, known_effect),
        writes = build_writes(write_context, effect_spec, known_effect),
        not_preserved = build_not_preserved(read_context, effect_spec),

        source = "instruction",
        source_line = instruction.source_line,
        source_column = 0,

        source_start_line = instruction.source_line,
        source_start_column = 0,
        source_end_line = instruction.source_line,
        source_end_column = 0,

        metadata = {
            adapter = adapter.name,
            architecture = adapter.architecture,
            variant = adapter.active_variant_name,
            mnemonic = instruction.mnemonic,
            boundary_reads_state = "before_instruction",
            boundary_writes_state = "after_instruction",
        },
    }
end


return M
