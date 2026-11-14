-- lua/tracker_hud/low_level/instruction_event_pipeline.lua
--
-- Instruction-event pipeline coordination.
--
-- This module owns the architecture-neutral wiring from adapter event rules
-- through indexing, source traversal, parsing, matching, fact construction and
-- stable collection. The adapter instruction parser remains injected.

local core = require("tracker_hud.core")
local instruction_event_collection =
    require("tracker_hud.low_level.instruction_event_collection")
local instruction_event_fact =
    require("tracker_hud.low_level.instruction_event_fact")
local instruction_event_index =
    require("tracker_hud.low_level.instruction_event_index")
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
            adapter.instruction_events
        )
        or type(deps.parse_instruction)
            ~= "function"
    then
        return {}
    end

    local event_index =
        instruction_event_index.get(
            adapter,
            rule_syntax.index_options()
        )

    return instruction_event_collection.collect({
        context = context,
        event_index = event_index,

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
            representative_event_spec
        )
            return deps.parse_instruction(
                node,
                representative_event_spec
            )
        end,

        normalize_mnemonic =
            rule_syntax.normalize_mnemonic,

        apply_event = function(
            facts,
            instruction,
            event_spec
        )
            instruction_event_fact.apply(
                facts,
                context,
                adapter,
                instruction,
                event_spec,
                {
                    matches = function(
                        candidate_instruction,
                        candidate_spec
                    )
                        return instruction_event_index
                            .matches(
                                candidate_instruction,
                                candidate_spec,
                                {
                                    get_mnemonic =
                                        rule_syntax
                                            .get_mnemonic,
                                }
                            )
                    end,
                    get_mnemonic =
                        rule_syntax.get_mnemonic,
                }
            )
        end,
    })
end


return M
