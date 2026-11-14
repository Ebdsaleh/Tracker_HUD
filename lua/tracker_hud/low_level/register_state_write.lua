-- lua/tracker_hud/low_level/register_state_write.lua
--
-- Register-state publication.
--
-- This module publishes an already-built register fact into the mutable
-- register/family/latest-state maps. It does not match effects or construct
-- facts.

local core = require("tracker_hud.core")
local register_state_read =
    require("tracker_hud.low_level.register_state_read")

local M = {}


function M.publish(
    facts_by_register,
    family_state,
    latest_state_facts,
    adapter,
    fact
)
    if not core.is_table(
        facts_by_register
    )
        or not core.is_table(
            family_state
        )
        or not core.is_table(
            latest_state_facts
        )
        or not core.is_table(adapter)
        or not core.is_table(fact)
        or not core.is_non_empty_string(
            fact.name
        )
    then
        return
    end

    local state_key =
        register_state_read.state_key(
            adapter,
            fact.name
        )
        or fact.name

    latest_state_facts[state_key] =
        fact

    family_state[state_key] =
        fact

    -- Source-operand lookup is separate from canonical reduced state.
    -- Invalidate sibling spellings first so later source reads cannot observe
    -- stale AL/AH/AX/EAX values after another alias changed the same family.
    local alias_resolution =
        register_state_read.resolve_alias(
            adapter,
            fact.name
        )

    local family =
        alias_resolution
        and alias_resolution.family
        or nil

    if core.is_table(family)
        and core.is_table(
            family.aliases
        )
    then
        for alias_name, _ in pairs(
            family.aliases
        ) do
            facts_by_register[
                tostring(
                    alias_name
                ):lower()
            ] = nil
        end
    end

    local write_resolved =
        fact.metadata
        and fact.metadata.write_resolved

    facts_by_register[fact.name] = {
        name = fact.name,

        value =
            fact.metadata
            and fact.metadata.write_value
            or fact.value,

        resolved =
            write_resolved ~= nil
            and write_resolved
            or fact.resolved,

        metadata = fact.metadata,
    }

    -- Publish the reduced canonical family state as well. A partial canonical
    -- fact remains unresolved as a whole register, but its certainty metadata
    -- allows later alias reads to project fully-known slices.
    if state_key ~= fact.name then
        facts_by_register[state_key] = {
            name = state_key,

            value =
                fact.resolved ~= false
                and fact.value
                or nil,

            resolved =
                fact.resolved ~= false,

            metadata = fact.metadata,
        }
    end
end


return M
