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


local function profile_begin(
    opts,
    suffix
)
    if type(opts) ~= "table"
        or type(opts.profile_begin) ~= "function"
    then
        return nil
    end

    return opts.profile_begin(
        (opts.profile_prefix
            or "context.instruction_events")
            .. "."
            .. suffix
    )
end


local function profile_end(
    opts,
    suffix,
    started
)
    if type(opts) ~= "table"
        or type(opts.profile_end) ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        (opts.profile_prefix
            or "context.instruction_events")
            .. "."
            .. suffix,
        started
    )
end


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

    local phase =
        profile_begin(
            opts,
            "index"
        )

    local event_index =
        instruction_event_index.get(
            adapter,
            rule_syntax.index_options()
        )

    profile_end(
        opts,
        "index",
        phase
    )

    phase =
        profile_begin(
            opts,
            "collect"
        )

    local result =
        instruction_event_collection.collect({
        context = context,
        event_index = event_index,

        collect_nodes = function(
            node_type
        )
            local started =
                profile_begin(
                    opts,
                    "nodes"
                )

            local nodes =
                instruction_source
                    .collect_nodes_by_type(
                        opts.root_node,
                        node_type
                    )

            profile_end(
                opts,
                "nodes",
                started
            )

            return nodes
        end,

        parse_instruction = function(
            node,
            representative_event_spec
        )
            local started =
                profile_begin(
                    opts,
                    "parse"
                )

            local instruction =
                deps.parse_instruction(
                    node,
                    representative_event_spec
                )

            profile_end(
                opts,
                "parse",
                started
            )

            return instruction
        end,

        normalize_mnemonic =
            rule_syntax.normalize_mnemonic,

        apply_event = function(
            facts,
            instruction,
            event_spec
        )
            local started =
                profile_begin(
                    opts,
                    "apply"
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

            profile_end(
                opts,
                "apply",
                started
            )
        end,
    })

    profile_end(
        opts,
        "collect",
        phase
    )

    return result
end


return M
