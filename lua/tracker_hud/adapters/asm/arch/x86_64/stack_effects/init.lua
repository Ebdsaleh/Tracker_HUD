-- lua/tracker_hud/adapters/asm/arch/x86_64/stack_effects/init.lua
--
-- x86-64 stack-effect aggregator.
--
-- Every stack-effect rule is categorized, Tree-sitter-first, and
-- mnemonic-indexed.

local M = {}


local function merge_indexed_rules(rules)
    if type(rules) ~= "table" then
        return
    end

    for mnemonic, effect_specs in pairs(rules) do
        if type(mnemonic) == "string"
            and type(effect_specs) == "table"
        then
            M[mnemonic] = M[mnemonic] or {}

            for _, effect_spec in ipairs(effect_specs) do
                table.insert(M[mnemonic], effect_spec)
            end
        end
    end
end


merge_indexed_rules(require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects.data"
))

merge_indexed_rules(require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects.allocation"
))

merge_indexed_rules(require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects.control"
))

merge_indexed_rules(require(
    "tracker_hud.adapters.asm.arch.x86_64.stack_effects.frames"
))


return M
