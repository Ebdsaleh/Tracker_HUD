-- lua/tracker_hud/low_level/rule_syntax.lua
--
-- Shared syntax access for low-level effect/event rules.
--
-- Register, boundary, stack, and instruction-event indexes all consume the
-- same Tree-sitter-first rule shape. This module owns that common read-only
-- node-type/mnemonic policy without owning any index or semantic matcher.

local core = require("tracker_hud.core")
local syntax_spec = require("tracker_hud.syntax_spec")

local M = {}


M.normalize_mnemonic =
    syntax_spec.normalize_mnemonic


function M.get_node_type(rule_spec)
    if not core.is_table(rule_spec) then
        return nil
    end

    return syntax_spec.get_node_type(
        rule_spec
    )
        or rule_spec.node_type
end


function M.get_mnemonic(
    rule_spec,
    fallback_mnemonic
)
    if not core.is_table(rule_spec) then
        return M.normalize_mnemonic(
            fallback_mnemonic
        )
    end

    return M.normalize_mnemonic(
        syntax_spec.get_field_text(
            rule_spec,
            "kind"
        )
        or rule_spec.mnemonic
        or fallback_mnemonic
    )
end


function M.index_options()
    return {
        get_node_type =
            M.get_node_type,
        get_mnemonic =
            M.get_mnemonic,
    }
end


return M
