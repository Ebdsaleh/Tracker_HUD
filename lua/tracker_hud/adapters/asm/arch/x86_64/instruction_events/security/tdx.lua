-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/tdx.lua
--
-- x86-64 instruction events: security / tdx.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["seamcall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "seamcall",
                    },
                },
            },

            kind = "security_event",
            category = "tdx_seam",
            name = "seamcall",
            role = "calls into SEAM secure module code",

            operands = {
            },

            event = {
                name = "seamcall_calls_seam_module",
                display_name = "seamcall",
                role = "calls into SEAM secure module code",
            },

            effect = {
                kind = "security_module_call",
                name = "seamcall_calls_seam_module",
                role = "calls into SEAM secure module code",
            },
        },
    },

    ["seamret"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "seamret",
                    },
                },
            },

            kind = "security_event",
            category = "tdx_seam",
            name = "seamret",
            role = "returns from SEAM secure module code",

            operands = {
            },

            event = {
                name = "seamret_returns_from_seam_module",
                display_name = "seamret",
                role = "returns from SEAM secure module code",
            },

            effect = {
                kind = "security_module_return",
                name = "seamret_returns_from_seam_module",
                role = "returns from SEAM secure module code",
            },
        },
    },

    ["tdcall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "tdcall",
                    },
                },
            },

            kind = "security_event",
            category = "tdx",
            name = "tdcall",
            role = "calls into the trusted domain module",

            operands = {
            },

            event = {
                name = "tdcall_calls_trusted_domain_module",
                display_name = "tdcall",
                role = "calls into the trusted domain module",
            },

            effect = {
                kind = "trusted_domain_call",
                name = "tdcall_calls_trusted_domain_module",
                role = "calls into the trusted domain module",
            },
        },
    },

    ["seamops"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "seamops",
                    },
                },
            },

            kind = "security_event",
            category = "tdx_seam",
            name = "seamops",
            role = "performs a SEAM platform operation",

            operands = {
            },

            event = {
                name = "seamops_performs_seam_operation",
                display_name = "seamops",
                role = "performs a SEAM platform operation",
            },

            effect = {
                kind = "security_module_operation",
                name = "seamops_performs_seam_operation",
                role = "performs a SEAM platform operation",
            },
        },
    },
}

