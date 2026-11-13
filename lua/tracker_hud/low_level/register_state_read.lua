-- lua/tracker_hud/low_level/register_state_read.lua
--
-- Architecture-neutral register-state read helpers.
--
-- This module owns lookup/projection policy only. It never mutates register
-- state and does not construct or apply register effects.

local core = require("tracker_hud.core")
local register_value_mask =
    require("tracker_hud.low_level.register_value_mask")

local M = {}


function M.get_static_spec(
    adapter,
    name
)
    if not core.is_table(adapter)
        or type(name) ~= "string"
    then
        return nil
    end

    local normalized =
        name:lower()

    for _, register_spec in ipairs(
        (
            adapter.registers
            and adapter.registers.static
        ) or {}
    ) do
        if type(register_spec) == "table"
            and type(
                register_spec.name
            ) == "string"
            and register_spec.name:lower()
                == normalized
        then
            return register_spec
        end
    end

    return nil
end


function M.get_fact(
    facts_by_register,
    register_name
)
    if not core.is_table(
        facts_by_register
    )
        or not core.is_non_empty_string(
            register_name
        )
    then
        return nil
    end

    return facts_by_register[
        register_name:lower()
    ]
end


function M.resolve_alias(
    adapter,
    register_name
)
    if not core.is_table(adapter)
        or not core.is_non_empty_string(
            register_name
        )
        or not core.is_table(
            adapter.register_alias_index
        )
    then
        return nil
    end

    return adapter.register_alias_index[
        register_name:lower()
    ]
end


function M.get_fact_for_read(
    facts_by_register,
    adapter,
    register_name
)
    local direct =
        M.get_fact(
            facts_by_register,
            register_name
        )

    if core.is_table(direct)
        and direct.value ~= nil
        and direct.resolved ~= false
    then
        return direct
    end

    local alias_resolution =
        M.resolve_alias(
            adapter,
            register_name
        )

    if not alias_resolution
        or not core.is_table(
            alias_resolution.alias
        )
        or not core.is_non_empty_string(
            alias_resolution.canonical
        )
    then
        return direct
    end

    local canonical_name =
        alias_resolution.canonical:lower()

    if canonical_name
        == tostring(
            register_name
        ):lower()
    then
        return direct
    end

    local canonical_fact =
        M.get_fact(
            facts_by_register,
            canonical_name
        )

    if not core.is_table(
        canonical_fact
    )
    then
        return direct
    end

    local projected =
        register_value_mask
            .read_alias_value(
                canonical_fact,
                alias_resolution.alias
            )

    if projected == nil then
        return direct
    end

    return {
        name =
            tostring(
                register_name
            ):lower(),
        value = projected,
        resolved = true,
        metadata =
            canonical_fact.metadata,
    }
end


function M.state_key(
    adapter,
    register_name
)
    local resolved =
        M.resolve_alias(
            adapter,
            register_name
        )

    if resolved
        and core.is_non_empty_string(
            resolved.canonical
        )
    then
        return resolved
            .canonical
            :lower()
    end

    return core.is_non_empty_string(
        register_name
    )
        and register_name:lower()
        or nil
end


function M.get_value_width(
    adapter,
    register_name
)
    local resolved =
        M.resolve_alias(
            adapter,
            register_name
        )

    if resolved
        and core.is_table(
            resolved.alias
        )
        and core.is_number(
            resolved.alias.bits
        )
    then
        return resolved.alias.bits
    end

    local static_spec =
        M.get_static_spec(
            adapter,
            register_name
        )

    if static_spec
        and core.is_number(
            static_spec.bits
        )
    then
        return static_spec.bits
    end

    return nil
end


function M.fact_is_resolved(fact)
    return core.is_table(fact)
        and fact.value ~= nil
        and fact.resolved ~= false
end


return M
