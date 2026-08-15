-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/init.lua
--
-- x86-64 instruction-event module aggregator.
--
-- The categorized modules are the destination for the Tree-sitter-first
-- migration. Legacy modules remain loaded during migration so behavior is
-- unchanged while entries are moved in small, testable batches.

local M = {}


local function append_events(events)
    for _, event in ipairs(events or {}) do
        table.insert(M, event)
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
    append_events(require(module_name))
end


-- Temporary migration compatibility.
-- Remove a legacy module from this list only after every entry in that module
-- has been moved into the categorized Tree-sitter-first files.
local legacy_modules = {
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.processor",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.cache",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.virtualization",
    "tracker_hud.adapters.asm.arch.x86_64.instruction_events.security",
}


for _, module_name in ipairs(legacy_modules) do
    append_events(require(module_name))
end


return M
