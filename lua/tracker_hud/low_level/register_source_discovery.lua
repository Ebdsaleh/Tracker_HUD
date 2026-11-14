-- lua/tracker_hud/low_level/register_source_discovery.lua
--
-- Register source-occurrence discovery setup for Inspect.
--
-- This module owns the architecture-neutral setup around
-- register_source_collection: effect index selection, source-member snapshot,
-- source node traversal, parse/match dispatch, and the bridge to source-time
-- address evaluation. Occurrence construction remains in the collection and
-- occurrence modules.

local core = require("tracker_hud.core")
local instruction_source =
    require("tracker_hud.low_level.instruction_source")
local register_effect_selection =
    require("tracker_hud.low_level.register_effect_selection")
local register_source_collection =
    require("tracker_hud.low_level.register_source_collection")
local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")
local scope_members =
    require("tracker_hud.scope_members")

local M = {}


function M.collect(
    bufnr,
    root_node,
    adapter,
    line_number,
    opts,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.register_effects
        )
        or not core.is_number(
            line_number
        )
        or type(
            deps.get_register_effect_index
        ) ~= "function"
        or type(deps.parse_instruction)
            ~= "function"
        or type(deps.evaluate_address)
            ~= "function"
    then
        return {}
    end

    local effect_index =
        deps.get_register_effect_index(
            adapter
        )

    if not core.is_table(effect_index) then
        return {}
    end

    local source_members =
        scope_members.collect(
            bufnr,
            root_node,
            adapter
        )

    return register_source_collection.collect({
        adapter = adapter,
        line_number = line_number,
        node_types =
            effect_index.node_types
            or {},
        source_members = source_members,
        machine_address_providers =
            opts.machine_address_providers,

        collect_nodes = function(
            node_type
        )
            return instruction_source
                .collect_nodes_by_type(
                    root_node,
                    node_type
                )
        end,

        parse_and_match = function(node)
            return register_effect_selection
                .match_node(
                    effect_index,
                    node,
                    {
                        parse_instruction =
                            function(
                                seen_node,
                                representative
                            )
                                return deps
                                    .parse_instruction(
                                        seen_node,
                                        representative
                                    )
                            end,
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
    })
end


return M
