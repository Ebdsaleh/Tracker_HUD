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


local function profile_begin(
    opts,
    suffix
)
    if type(opts) ~= "table"
        or type(opts.profile_begin)
            ~= "function"
    then
        return nil
    end

    return opts.profile_begin(
        (opts.profile_prefix
            or "context.boundary")
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
        or type(opts.profile_end)
            ~= "function"
    then
        return nil
    end

    return opts.profile_end(
        (opts.profile_prefix
            or "context.boundary")
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

    local phase =
        profile_begin(
            opts,
            "index"
        )

    local effect_index =
        boundary_effect_index.get(
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
            "replay_session"
        )

    local register_replay_session =
        type(
            deps.create_register_replay_session
        ) == "function"
        and deps.create_register_replay_session()
        or nil

    profile_end(
        opts,
        "replay_session",
        phase
    )

    phase =
        profile_begin(
            opts,
            "collect"
        )

    local result =
        boundary_effect_collection.collect({
        context = context,
        effect_index = effect_index,

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
                    .get_prepared_nodes_by_type(
                        opts.prepared_register_source,
                        node_type
                    )

            if nodes == nil then
                nodes =
                    instruction_source
                        .collect_nodes_by_type(
                            opts.root_node,
                            node_type
                        )
            end

            profile_end(
                opts,
                "nodes",
                started
            )

            return nodes
        end,

        parse_instruction = function(
            node,
            representative_effect_spec
        )
            local started =
                profile_begin(
                    opts,
                    "parse"
                )

            local instruction =
                deps.parse_instruction(
                    node,
                    representative_effect_spec
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

        collect_read_context = function(
            instruction
        )
            local started =
                profile_begin(
                    opts,
                    "read_context"
                )

            local read_context =
                boundary_register_context.collect(
                    context,
                    adapter,
                    opts,
                    instruction,
                    {
                        collect_register_effects =
                            deps.collect_register_effects,

                        collect_register_effects_before =
                            register_replay_session
                            and function(
                                limit_position
                            )
                                return register_replay_session
                                    :collect_before(
                                        limit_position
                                    )
                            end
                            or nil,
                    }
                )

            profile_end(
                opts,
                "read_context",
                started
            )

            return read_context
        end,

        apply_effect = function(
            facts,
            instruction,
            effect_spec,
            phase_contexts
        )
            local started =
                profile_begin(
                    opts,
                    "apply"
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
