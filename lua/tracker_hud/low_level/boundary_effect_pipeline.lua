-- lua/tracker_hud/low_level/boundary_effect_pipeline.lua
--
-- Boundary-effect pipeline coordination.
--
-- This module owns the architecture-neutral wiring from adapter boundary rules
-- through indexed source traversal, parsing, pre-boundary register context,
-- semantic fact application, and final collection. Register reduction and the
-- adapter instruction parser remain injected cross-cutting services.

local core = require("tracker_hud.core")
local boundary_effect_apply =
    require("tracker_hud.low_level.boundary_effect_apply")
local boundary_effect_collection =
    require("tracker_hud.low_level.boundary_effect_collection")
local boundary_effect_index =
    require("tracker_hud.low_level.boundary_effect_index")
local boundary_register_context =
    require("tracker_hud.low_level.boundary_register_context")
local instruction_source =
    require("tracker_hud.low_level.instruction_source")
local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")

local M = {}


function M.collect(
    context,
    adapter,
    opts,
    deps
)
    opts = opts or {}
    deps = deps or {}

    if not opts.bufnr
        or not opts.root_node
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.boundary_effects
        )
        or type(deps.parse_instruction)
            ~= "function"
        or type(
            deps.collect_register_effects
        ) ~= "function"
    then
        return {}
    end

    local effect_index =
        boundary_effect_index.get(
            adapter,
            rule_syntax.index_options()
        )

    return boundary_effect_collection.collect({
        context = context,
        effect_index = effect_index,

        collect_nodes = function(
            node_type
        )
            return instruction_source
                .collect_nodes_by_type(
                    opts.root_node,
                    node_type
                )
        end,

        parse_instruction = function(
            node,
            representative_effect_spec
        )
            return deps.parse_instruction(
                node,
                representative_effect_spec
            )
        end,

        normalize_mnemonic =
            rule_syntax.normalize_mnemonic,

        collect_read_context = function(
            instruction
        )
            return boundary_register_context.collect(
                context,
                adapter,
                opts,
                instruction,
                {
                    collect_register_effects =
                        deps.collect_register_effects,
                }
            )
        end,

        apply_effect = function(
            facts,
            instruction,
            effect_spec,
            phase_contexts
        )
            boundary_effect_apply.apply(
                facts,
                context,
                adapter,
                instruction,
                effect_spec,
                phase_contexts,
                {
                    get_mnemonic =
                        rule_syntax.get_mnemonic,
                    normalize_mnemonic =
                        rule_syntax
                            .normalize_mnemonic,
                }
            )
        end,
    })
end


return M
