-- lua/tracker_hud/low_level/memory_source_discovery.lua
--
-- Source-memory discovery setup.
--
-- This module owns the architecture-neutral wiring needed to feed the existing
-- memory_source_collection: instruction-node selection, source-member snapshot,
-- register-effect role selection, memory access policy, and the bridge to
-- source-time address evaluation. Fact construction remains in the collection
-- and fact modules.

local core = require("tracker_hud.core")
local instruction_source =
    require("tracker_hud.low_level.instruction_source")
local memory_access =
    require("tracker_hud.low_level.memory_access")
local memory_source_collection =
    require("tracker_hud.low_level.memory_source_collection")
local register_effect_selection =
    require("tracker_hud.low_level.register_effect_selection")
local register_source_metadata =
    require("tracker_hud.low_level.register_source_metadata")
local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")
local scope_members =
    require("tracker_hud.scope_members")

local M = {}


local function instruction_node_type(
    adapter
)
    local instruction_spec =
        core.is_table(adapter)
        and core.is_table(
            adapter.construct_specs
        )
        and adapter.construct_specs
            .instruction
        or nil

    local syntax =
        core.is_table(instruction_spec)
        and instruction_spec.syntax
        or nil

    return core.is_table(syntax)
        and core.is_non_empty_string(
            syntax.node_type
        )
        and syntax.node_type
        or "instruction"
end


local function get_operand_role(
    effect_specs,
    operand_index
)
    local role = nil

    for _, effect_spec in ipairs(
        effect_specs or {}
    ) do
        local operand_spec =
            register_source_metadata
                .get_effect_operand_spec(
                    effect_spec,
                    operand_index
                )

        if core.is_table(operand_spec)
            and core.is_non_empty_string(
                operand_spec.role
            )
        then
            role =
                role
                or operand_spec.role
        end
    end

    return role
end


function M.collect(
    bufnr,
    root_node,
    adapter,
    line_predicate,
    opts,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or type(line_predicate)
            ~= "function"
        or type(deps.parse_instruction)
            ~= "function"
        or type(deps.evaluate_address)
            ~= "function"
    then
        return {}
    end

    local effect_index = nil

    if core.is_table(
        adapter.register_effects
    ) then
        if type(
            deps.get_register_effect_index
        ) ~= "function"
        then
            return {}
        end

        effect_index =
            deps.get_register_effect_index(
                adapter
            )
    end

    local source_members =
        scope_members.collect(
            bufnr,
            root_node,
            adapter
        )

    return memory_source_collection.collect({
        nodes =
            instruction_source
                .collect_nodes_by_type(
                    root_node,
                    instruction_node_type(
                        adapter
                    )
                ),
        adapter = adapter,
        source_members = source_members,
        line_predicate = line_predicate,
        machine_address_providers =
            opts.machine_address_providers,

        parse_instruction = function(node)
            return deps.parse_instruction(
                node,
                nil
            )
        end,

        match_effects = function(
            node,
            instruction
        )
            if not effect_index then
                return {}
            end

            return register_effect_selection
                .match_instruction(
                    effect_index,
                    node,
                    instruction,
                    {
                        normalize_mnemonic =
                            rule_syntax
                                .normalize_mnemonic,
                    }
                )
        end,

        evaluate_address = function(
            instruction,
            address,
            machine_addresses,
            instruction_relative_policy
        )
            return deps.evaluate_address(
                instruction,
                address,
                machine_addresses,
                instruction_relative_policy
            )
        end,

        get_operand_role =
            get_operand_role,

        resolve_access = function(
            instruction,
            operand_index,
            operand
        )
            return memory_access.resolve(
                adapter.memory_accesses,
                instruction.mnemonic,
                operand_index,
                operand
            )
        end,
    })
end


return M
