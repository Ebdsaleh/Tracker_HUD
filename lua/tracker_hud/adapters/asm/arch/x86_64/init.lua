-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/init.lua
--
-- x86-64 instruction-event module aggregator.
--
-- Categorized Tree-sitter-first modules use mnemonic-indexed tables.
-- Remaining legacy modules continue to expose flat arrays during migration.
-- Both representations are preserved here so context_engine can consume them
-- without flattening the fast indexed representation.

local M = {}


local function append_legacy_events(events)
    for _, event in ipairs(events or {}) do
        table.insert(M, event)
    end
end


local function merge_indexed_events(events)
    if type(events) ~= "table" then
        return
    end

    for mnemonic, rules in pairs(events) do
        if type(mnemonic) == "string"
            and type(rules) == "table"
        then
            M[mnemonic] = M[mnemonic] or {}

            for _, rule in ipairs(rules) do
                table.insert(M[mnemonic], rule)
            end
        end
    end
end


local categorized_modules = {
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.memory.ordering",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.memory.cache_control",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.memory.prefetch",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.memory.tlb",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.identification",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.serialization",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.timing",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.entropy",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.wait_hint",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.descriptor_state",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.extended_state",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.floating_state",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.protection_state",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor.profiling",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.control.interrupts",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.control.exceptions",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.control.system_calls",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.control.transactional",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.sgx",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.tdx",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.cet",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.mpx",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.key_locker",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.trusted_execution",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.platform_security",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security.user_interrupts",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.virtualization.vmx",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.virtualization.svm",
}


for _, module_name in ipairs(categorized_modules) do
    merge_indexed_events(require(module_name))
end


-- Temporary migration compatibility.
-- cache.lua has been fully migrated and therefore is no longer loaded here.
local legacy_modules = {
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.virtualization",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security",
}


for _, module_name in ipairs(legacy_modules) do
    append_legacy_events(require(module_name))
end


return M

