-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/security/key_locker.lua
--
-- x86-64 instruction events: security / key locker.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["loadiwkey"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "loadiwkey",
                    },
                },
            },

            kind = "security_event",
            category = "key_locker",
            name = "loadiwkey",
            role = "loads the internal wrapping key",

            operands = {
                { index = 1, role = "control", },
                { index = 2, role = "key_source", },
            },

            event = {
                name = "loadiwkey_loads_internal_wrapping_key",
                display_name = "loadiwkey",
                role = "loads the internal wrapping key",
            },

            effect = {
                kind = "key_locker_state_update",
                name = "loadiwkey_loads_internal_wrapping_key",
                role = "loads the internal wrapping key",
            },
        },
    },

    ["encodekey128"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "encodekey128",
                    },
                },
            },

            kind = "security_event",
            category = "key_locker",
            name = "encodekey128",
            role = "encodes a 128-bit AES key handle",

            operands = {
                { index = 1, role = "destination", },
                { index = 2, role = "source", },
            },

            event = {
                name = "encodekey128_encodes_key_handle",
                display_name = "encodekey128",
                role = "encodes a 128-bit AES key handle",
            },

            effect = {
                kind = "key_locker_key_encode",
                name = "encodekey128_encodes_key_handle",
                role = "encodes a 128-bit AES key handle",
            },
        },
    },

    ["encodekey256"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "encodekey256",
                    },
                },
            },

            kind = "security_event",
            category = "key_locker",
            name = "encodekey256",
            role = "encodes a 256-bit AES key handle",

            operands = {
                { index = 1, role = "destination", },
                { index = 2, role = "source", },
            },

            event = {
                name = "encodekey256_encodes_key_handle",
                display_name = "encodekey256",
                role = "encodes a 256-bit AES key handle",
            },

            effect = {
                kind = "key_locker_key_encode",
                name = "encodekey256_encodes_key_handle",
                role = "encodes a 256-bit AES key handle",
            },
        },
    },
}

