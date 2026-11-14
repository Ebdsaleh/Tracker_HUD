-- lua/tracker_hud/low_level/instruction_event_fact.lua
--
-- Instruction-event fact construction and application.
--
-- Syntax/mnemonic matching remains outside this module and is injected by the
-- caller. This module owns only fact assembly, control metadata, and append
-- semantics for an already-selected instruction/event pair.

local core = require("tracker_hud.core")
local control_infer =
    require("tracker_hud.low_level.control_infer")

local M = {}


function M.build(
    context,
    adapter,
    instruction,
    event_spec,
    opts
)
    opts = opts or {}

    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return nil
    end

    local get_mnemonic =
        type(opts.get_mnemonic) == "function"
        and opts.get_mnemonic
        or function()
            return nil
        end

    local event_name =
        event_spec.name
        or get_mnemonic(event_spec)
        or "instruction_event"

    return {
        kind =
            event_spec.kind
            or "instruction_event",

        category =
            event_spec.category
            or "instruction",

        name = event_name,

        role = event_spec.role,

        source = "instruction",

        source_line =
            instruction.source_line,

        source_column =
            instruction.source_column
            or 0,

        source_start_line =
            instruction.source_line,

        source_start_column =
            instruction.source_column
            or 0,

        source_end_line =
            instruction.source_line,

        source_end_column =
            instruction.source_end_column
            or instruction.source_column
            or 0,

        metadata = vim.tbl_extend(
            "force",
            {
                adapter = adapter.name,
                architecture =
                    adapter.architecture,
                variant =
                    adapter.active_variant_name,
                mnemonic =
                    instruction.mnemonic,
                event =
                    event_spec.name
                    or get_mnemonic(
                        event_spec
                    ),
                operands =
                    instruction.operands
                    or {},
                operand_specs =
                    event_spec.operands
                    or {},
            },
            control_infer
                .make_event_metadata(
                    context,
                    event_spec
                )
        ),
    }
end


function M.apply(
    facts,
    context,
    adapter,
    instruction,
    event_spec,
    opts
)
    opts = opts or {}

    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return
    end

    if type(opts.matches)
            ~= "function"
        or not opts.matches(
            instruction,
            event_spec
        )
    then
        return
    end

    local fact =
        M.build(
            context,
            adapter,
            instruction,
            event_spec,
            opts
        )

    if fact then
        table.insert(facts, fact)
    end
end


return M
