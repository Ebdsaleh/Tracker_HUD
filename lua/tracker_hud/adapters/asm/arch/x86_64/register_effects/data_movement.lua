-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/data_movement.lua
--
-- x86-64 data movement register effect specs.
--
-- Remaining legacy records not yet migrated into the categorized
-- Tree-sitter-first register-effect modules.

return {

    {
                node_type = "instruction",
                mnemonic = "xlatb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "xlatb_writes_rax",
                    target_register = "rax",
                    role = "loaded translated byte into al by xlatb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "outsb_updates_rsi",
                    target_register = "rsi",
                    role = "advanced by outsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "outsw_updates_rsi",
                    target_register = "rsi",
                    role = "advanced by outsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "outsd_updates_rsi",
                    target_register = "rsi",
                    role = "advanced by outsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "insb_updates_rdi",
                    target_register = "rdi",
                    role = "advanced by insb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "insw_updates_rdi",
                    target_register = "rdi",
                    role = "advanced by insw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "insd_updates_rdi",
                    target_register = "rdi",
                    role = "advanced by insd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsb_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by movsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsb_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by movsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsw_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by movsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsw_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by movsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsd_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by movsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsd_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by movsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsq_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by movsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "movsq_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by movsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stosb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "stosb_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by stosb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stosw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "stosw_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by stosw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stosd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "stosd_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by stosd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stosq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "stosq_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by stosq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsb_writes_rax",
                    target_register = "rax",
                    role = "loaded byte into al by lodsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsb_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by lodsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsw_writes_rax",
                    target_register = "rax",
                    role = "loaded word into ax by lodsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsw_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by lodsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsd_writes_rax",
                    target_register = "rax",
                    role = "loaded dword into eax by lodsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsd_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by lodsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsq_writes_rax",
                    target_register = "rax",
                    role = "loaded qword into rax by lodsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "lodsq_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by lodsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasb_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by scasb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scasb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasw_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by scasw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasw_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scasw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasd_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by scasd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasd_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scasd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasq_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by scasq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "scasq_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scasq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsb_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by cmpsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsb_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by cmpsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsb",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsb_updates_rflags",
                    target_register = "rflags",
                    role = "updated by cmpsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsw_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by cmpsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsw_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by cmpsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsw",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsw_updates_rflags",
                    target_register = "rflags",
                    role = "updated by cmpsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsd_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsd_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsd_updates_rflags",
                    target_register = "rflags",
                    role = "updated by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsq_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by cmpsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsq_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by cmpsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsq",
        
                operands = {},
        
                effect = {
                    kind = "register_write",
                    name = "cmpsq_updates_rflags",
                    target_register = "rflags",
                    role = "updated by cmpsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "movsw_advances_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by movsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "movsw_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by movsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "movsd_advances_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by movsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "movsd_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by movsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lodsw_writes_rax",
                    target_register = "rax",
                    role = "loaded word into ax by lodsw",
                    written_alias = "ax",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lodsw_advances_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by lodsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lodsd_writes_rax",
                    target_register = "rax",
                    role = "loaded doubleword into eax by lodsd",
                    written_alias = "eax",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lodsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lodsd_advances_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by lodsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stosw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "stosw_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by stosw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stosd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "stosd_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by stosd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "scasw_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by scasw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "scasw_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scasw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "scasd_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by scasd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scasd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "scasd_updates_rflags",
                    target_register = "rflags",
                    role = "updated by scasd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmpsw_advances_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by cmpsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmpsw_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by cmpsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmpsw_updates_rflags",
                    target_register = "rflags",
                    role = "updated by cmpsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmpsd_advances_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmpsd_advances_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmpsd_updates_rflags",
                    target_register = "rflags",
                    role = "updated by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "xlat",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "xlat_writes_rax",
                    target_register = "rax",
                    written_alias = "al",
                    role = "loaded translated byte into al by xlat",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movaps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movaps_simd_move",
                    target_register = "rip",
                    role = "moved aligned packed single-precision values by movaps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movups",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movups_simd_move",
                    target_register = "rip",
                    role = "moved unaligned packed single-precision values by movups",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movapd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movapd_simd_move",
                    target_register = "rip",
                    role = "moved aligned packed double-precision values by movapd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movupd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movupd_simd_move",
                    target_register = "rip",
                    role = "moved unaligned packed double-precision values by movupd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movdqa",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movdqa_simd_move",
                    target_register = "rip",
                    role = "moved aligned packed integer values by movdqa",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movdqu",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movdqu_simd_move",
                    target_register = "rip",
                    role = "moved unaligned packed integer values by movdqu",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntdq",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movntdq_simd_store",
                    target_register = "rip",
                    role = "stored packed integer values non-temporally by movntdq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntdqa",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movntdqa_simd_load",
                    target_register = "rip",
                    role = "loaded aligned packed integer values non-temporally by movntdqa",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movntps_simd_store",
                    target_register = "rip",
                    role = "stored packed single-precision values non-temporally by movntps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movntpd_simd_store",
                    target_register = "rip",
                    role = "stored packed double-precision values non-temporally by movntpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movss",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movss_scalar_simd_move",
                    target_register = "rip",
                    role = "moved scalar single-precision value by movss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movsd_scalar_simd_move",
                    target_register = "rip",
                    role = "moved scalar double-precision value by movsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpss",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                effect = {
                    kind = "register_write",
                    name = "cmpss_scalar_simd_compare",
                    target_register = "rip",
                    role = "compared scalar single-precision values by cmpss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" }, { index = 3, role = "predicate" } },
                effect = {
                    kind = "register_write",
                    name = "cmpsd_scalar_simd_compare",
                    target_register = "rip",
                    role = "compared scalar double-precision values by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movhlps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movhlps_simd_shuffle",
                    target_register = "rip",
                    role = "moved high packed single-precision lanes by movhlps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movlhps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movlhps_simd_shuffle",
                    target_register = "rip",
                    role = "moved low packed single-precision lanes by movlhps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movhps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movhps_simd_move",
                    target_register = "rip",
                    role = "moved high packed single-precision lanes by movhps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movlps",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movlps_simd_move",
                    target_register = "rip",
                    role = "moved low packed single-precision lanes by movlps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movhpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movhpd_simd_move",
                    target_register = "rip",
                    role = "moved high packed double-precision lane by movhpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movlpd",
                operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movlpd_simd_move",
                    target_register = "rip",
                    role = "moved low packed double-precision lane by movlpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movmskps",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movmskps_writes_gpr",
                    target_operand = 1,
                    role = "written with packed single-precision sign mask by movmskps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movmskpd",
                operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
                effect = {
                    kind = "register_write",
                    name = "movmskpd_writes_gpr",
                    target_operand = 1,
                    role = "written with packed double-precision sign mask by movmskpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movsldup",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movsldup_vector_duplicate",
                    target_register = "rip",
                    role = "duplicated low packed single-precision lanes by movsldup",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movshdup",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movshdup_vector_duplicate",
                    target_register = "rip",
                    role = "duplicated high packed single-precision lanes by movshdup",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movddup",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movddup_vector_duplicate",
                    target_register = "rip",
                    role = "duplicated low scalar double-precision lane by movddup",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insertps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "control" },
                },
                effect = {
                    kind = "register_write",
                    name = "insertps_vector_insert",
                    target_register = "rip",
                    role = "inserted single-precision lane by insertps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movd_mmx_sse_move",
                    target_register = "rip",
                    role = "moved doubleword between integer and multimedia state by movd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movq_mmx_sse_move",
                    target_register = "rip",
                    role = "moved quadword between integer and multimedia state by movq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movdq2q",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movdq2q_sse_mmx_bridge",
                    target_register = "rip",
                    role = "moved low quadword from xmm state to mmx state by movdq2q",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movq2dq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movq2dq_mmx_sse_bridge",
                    target_register = "rip",
                    role = "moved quadword from mmx state to xmm state by movq2dq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movntq_nontemporal_store",
                    target_register = "rip",
                    role = "stored mmx quadword non-temporally by movntq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movntsd_nontemporal_store",
                    target_register = "rip",
                    role = "stored scalar double-precision value non-temporally by movntsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movntss_nontemporal_store",
                    target_register = "rip",
                    role = "stored scalar single-precision value non-temporally by movntss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movs",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "movs_advances_rsi",
                    target_register = "rsi",
                    role = "advanced by unsuffixed string move movs",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movs",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "movs_advances_rdi",
                    target_register = "rdi",
                    role = "advanced by unsuffixed string move movs",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmps",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmps_advances_rsi",
                    target_register = "rsi",
                    role = "advanced by unsuffixed string compare cmps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmps",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmps_advances_rdi",
                    target_register = "rdi",
                    role = "advanced by unsuffixed string compare cmps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmps",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "cmps_updates_rflags",
                    target_register = "rflags",
                    role = "updated by unsuffixed string compare cmps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scas",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "scas_advances_rdi",
                    target_register = "rdi",
                    role = "advanced by unsuffixed string scan scas",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "scas",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "scas_updates_rflags",
                    target_register = "rflags",
                    role = "updated by unsuffixed string scan scas",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lods",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lods_writes_rax",
                    target_register = "rax",
                    role = "loaded by unsuffixed string load lods",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "lods",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "lods_advances_rsi",
                    target_register = "rsi",
                    role = "advanced by unsuffixed string load lods",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "stos",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "stos_advances_rdi",
                    target_register = "rdi",
                    role = "advanced by unsuffixed string store stos",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "ins",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "ins_advances_rdi",
                    target_register = "rdi",
                    role = "advanced by unsuffixed port input string ins",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outs",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "outs_advances_rsi",
                    target_register = "rsi",
                    role = "advanced by unsuffixed port output string outs",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insb",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "insb_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by byte input string insb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "insw_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by word input string insw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insl",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "insl_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by long input string insl",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "insq",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "insq_updates_rdi",
                    target_register = "rdi",
                    role = "advanced destination pointer by quadword input string insq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsb",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "outsb_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by byte output string outsb",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsw",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "outsw_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by word output string outsw",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsl",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "outsl_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by long output string outsl",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "outsq",
                operands = {},
                effect = {
                    kind = "register_write",
                    name = "outsq_updates_rsi",
                    target_register = "rsi",
                    role = "advanced source pointer by quadword output string outsq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpss",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "cmpss_scalar_fp_compare",
                    target_register = "rip",
                    role = "performed scalar single-precision compare by cmpss",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "cmpsd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                    { index = 3, role = "predicate" },
                },
                effect = {
                    kind = "register_write",
                    name = "cmpsd_scalar_fp_compare",
                    target_register = "rip",
                    role = "performed scalar double-precision compare by cmpsd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movaps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movaps_vector_move",
                    target_register = "rip",
                    role = "moved aligned packed single-precision value by movaps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movups",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movups_vector_move",
                    target_register = "rip",
                    role = "moved unaligned packed single-precision value by movups",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movapd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movapd_vector_move",
                    target_register = "rip",
                    role = "moved aligned packed double-precision value by movapd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movupd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movupd_vector_move",
                    target_register = "rip",
                    role = "moved unaligned packed double-precision value by movupd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movdqa",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movdqa_vector_move",
                    target_register = "rip",
                    role = "moved aligned packed integer value by movdqa",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movdqu",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movdqu_vector_move",
                    target_register = "rip",
                    role = "moved unaligned packed integer value by movdqu",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movntps_streaming_store",
                    target_register = "rip",
                    role = "performed non-temporal packed single-precision store by movntps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movntpd_streaming_store",
                    target_register = "rip",
                    role = "performed non-temporal packed double-precision store by movntpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movntdq",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movntdq_streaming_store",
                    target_register = "rip",
                    role = "performed non-temporal packed integer store by movntdq",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movhlps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movhlps_vector_lane_move",
                    target_register = "rip",
                    role = "moved high packed single-precision lanes to low lanes by movhlps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movlhps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movlhps_vector_lane_move",
                    target_register = "rip",
                    role = "moved low packed single-precision lanes to high lanes by movlhps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movlps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movlps_vector_low_move",
                    target_register = "rip",
                    role = "moved low packed single-precision lanes by movlps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movhps",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movhps_vector_high_move",
                    target_register = "rip",
                    role = "moved high packed single-precision lanes by movhps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movlpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movlpd_vector_low_move",
                    target_register = "rip",
                    role = "moved low packed double-precision lane by movlpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movhpd",
                operands = {
                    { index = 1, role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movhpd_vector_high_move",
                    target_register = "rip",
                    role = "moved high packed double-precision lane by movhpd",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movmskps",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movmskps_writes_destination",
                    target_operand = 1,
                    role = "written with packed single-precision sign mask by movmskps",
                },
            },

    {
                node_type = "instruction",
                mnemonic = "movmskpd",
                operands = {
                    { index = 1, kind = "register", role = "destination" },
                    { index = 2, role = "source" },
                },
                effect = {
                    kind = "register_write",
                    name = "movmskpd_writes_destination",
                    target_operand = 1,
                    role = "written with packed double-precision sign mask by movmskpd",
                },
            },

}

