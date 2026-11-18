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


local function profile_name(
    opts,
    suffix
)
    local prefix =
        opts
        and opts.profile_prefix
        or "context.source_memory"

    return prefix
        .. "."
        .. suffix
end


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
        profile_name(
            opts,
            suffix
        )
    )
end


local function profile_counter(
    opts,
    suffix,
    delta
)
    if type(opts) ~= "table"
        or type(opts.profile_counter)
            ~= "function"
    then
        return nil
    end

    return opts.profile_counter(
        profile_name(
            opts,
            suffix
        ),
        delta
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
        profile_name(
            opts,
            suffix
        ),
        started
    )
end


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


local function get_supplied_instruction_nodes(
    opts,
    adapter
)
    local wanted_type =
        instruction_node_type(
            adapter
        )

    if not core.is_table(
        opts.instruction_nodes
    )
        or not core.is_table(
            opts.instruction_node_types
        )
        or opts.instruction_node_types[
            wanted_type
        ] ~= true
    then
        return nil
    end

    local result = {}

    for _, entry in ipairs(
        opts.instruction_nodes
    ) do
        local node =
            core.is_table(entry)
            and entry.node
            or nil

        node = node or entry

        if node
            and node:type()
                == wanted_type
        then
            result[#result + 1] =
                node
        end
    end

    return result
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
    local phase =
        profile_begin(
            opts,
            "effect_index"
        )

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

    profile_end(
        opts,
        "effect_index",
        phase
    )

    phase =
        profile_begin(
            opts,
            "source_members"
        )

    local source_members =
        core.is_table(
            opts.source_members
        )
        and opts.source_members
        or scope_members.collect(
            bufnr,
            root_node,
            adapter
        )

    profile_end(
        opts,
        "source_members",
        phase
    )

    phase =
        profile_begin(
            opts,
            "nodes"
        )

    local nodes =
        get_supplied_instruction_nodes(
            opts,
            adapter
        )

    if nodes == nil then
        profile_counter(
            opts,
            "nodes.prepared_fallbacks",
            1
        )

        nodes =
            instruction_source
                .collect_nodes_by_type(
                    root_node,
                    instruction_node_type(
                        adapter
                    )
                )
    else
        profile_counter(
            opts,
            "nodes.prepared_hits",
            1
        )
    end

    profile_counter(
        opts,
        "nodes.lookup_attempts",
        1
    )

    profile_end(
        opts,
        "nodes",
        phase
    )

    phase =
        profile_begin(
            opts,
            "collect"
        )

    local result =
        memory_source_collection.collect({
        nodes = nodes,
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

        profile_prefix =
            profile_name(
                opts,
                "collect"
            ),
        profile_begin =
            opts.profile_begin,
        profile_end =
            opts.profile_end,
    })

    profile_end(
        opts,
        "collect",
        phase
    )

    return result
end


return M
