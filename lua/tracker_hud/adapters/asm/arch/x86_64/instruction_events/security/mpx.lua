-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/mpx.lua
--
-- x86-64 instruction events: security / mpx.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["bndcl"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndcl",
                    },
                },
            },

            kind = "security_event",
            category = "mpx_bounds",
            name = "bndcl",
            role = "checks an address against a lower bound",

            operands = {
                { index = 1, role = "bounds", },
                { index = 2, role = "address", },
            },

            event = {
                name = "bndcl_checks_lower_bound",
                display_name = "bndcl",
                role = "checks an address against a lower bound",
            },

            effect = {
                kind = "bounds_check",
                name = "bndcl_checks_lower_bound",
                role = "checks an address against a lower bound",
            },
        },
    },

    ["bndcu"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndcu",
                    },
                },
            },

            kind = "security_event",
            category = "mpx_bounds",
            name = "bndcu",
            role = "checks an address against an upper bound",

            operands = {
                { index = 1, role = "bounds", },
                { index = 2, role = "address", },
            },

            event = {
                name = "bndcu_checks_upper_bound",
                display_name = "bndcu",
                role = "checks an address against an upper bound",
            },

            effect = {
                kind = "bounds_check",
                name = "bndcu_checks_upper_bound",
                role = "checks an address against an upper bound",
            },
        },
    },

    ["bndcn"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndcn",
                    },
                },
            },

            kind = "security_event",
            category = "mpx_bounds",
            name = "bndcn",
            role = "checks an address against a complemented upper bound",

            operands = {
                { index = 1, role = "bounds", },
                { index = 2, role = "address", },
            },

            event = {
                name = "bndcn_checks_complemented_upper_bound",
                display_name = "bndcn",
                role = "checks an address against a complemented upper bound",
            },

            effect = {
                kind = "bounds_check",
                name = "bndcn_checks_complemented_upper_bound",
                role = "checks an address against a complemented upper bound",
            },
        },
    },

    ["bndstx"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "bndstx",
                    },
                },
            },

            kind = "security_event",
            category = "mpx_bounds",
            name = "bndstx",
            role = "stores bounds state using address translation",

            operands = {
                { index = 1, role = "address", },
                { index = 2, role = "bounds_source", },
            },

            event = {
                name = "bndstx_stores_bounds_state",
                display_name = "bndstx",
                role = "stores bounds state using address translation",
            },

            effect = {
                kind = "bounds_state_store",
                name = "bndstx_stores_bounds_state",
                role = "stores bounds state using address translation",
            },
        },
    },
}

