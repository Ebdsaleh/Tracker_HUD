-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/memory/tlb.lua
--
-- x86-64 instruction events: memory / tlb.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Each entry starts with the exact Tree-sitter syntax identity used to select
-- the instruction. Event/effect data then describes what that syntax means to
-- x86-64 and Tracker_HUD.

return {

    ["invlpg"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "invlpg",
                    },
                },
            },

            kind = "processor_state_event",
            category = "tlb_invalidation",
            name = "invlpg",
            role = "invalidates a TLB entry for a memory page",

            operands = {
                { index = 1, role = "memory_operand" },
            },

            event = {
                name = "invlpg_invalidates_page_tlb_entry",
                display_name = "invlpg",
                role = "invalidates a TLB entry for a memory page",
            },

            effect = {
                kind = "tlb_invalidation",
                name = "invlpg_invalidates_page_tlb_entry",
                role = "invalidates a TLB entry for a memory page",
            },
        },
    },

    ["invlpga"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "invlpga",
                    },
                },
            },

            kind = "processor_state_event",
            category = "tlb_invalidation",
            name = "invlpga",
            role = "invalidates a TLB entry for an address space",

            operands = {},

            event = {
                name = "invlpga_invalidates_address_space_tlb_entry",
                display_name = "invlpga",
                role = "invalidates a TLB entry for an address space",
            },

            effect = {
                kind = "tlb_invalidation",
                name = "invlpga_invalidates_address_space_tlb_entry",
                role = "invalidates a TLB entry for an address space",
            },
        },
    },

    ["invpcid"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "invpcid",
                    },
                },
            },

            kind = "processor_state_event",
            category = "tlb_invalidation",
            name = "invpcid",
            role = "invalidates cached translations by process-context identifier",

            operands = {
                { index = 1, role = "invalidation_type" },
                { index = 2, role = "descriptor" },
            },

            event = {
                name = "invpcid_invalidates_context_translations",
                display_name = "invpcid",
                role = "invalidates cached translations by process-context identifier",
            },

            effect = {
                kind = "tlb_invalidation",
                name = "invpcid_invalidates_context_translations",
                role = "invalidates cached translations by process-context identifier",
            },
        },
    },
}

