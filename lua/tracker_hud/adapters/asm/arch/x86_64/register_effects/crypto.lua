-- lua/tracker_hud/adapters/asm_arch/x86_64/register_effects/crypto.lua
--
-- x86-64 crypto register effect specs.

return {

    -- AES / VAES / carry-less multiply / SHA / GFNI.
    
        {
            node_type = "instruction",
            mnemonic = "aesenc",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesenc_crypto",
                target_register = "rip",
                role = "performed aes encryption round by aesenc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesenclast",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesenclast_crypto",
                target_register = "rip",
                role = "performed final aes encryption round by aesenclast",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesdec",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesdec_crypto",
                target_register = "rip",
                role = "performed aes decryption round by aesdec",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesdeclast",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "aesdeclast_crypto",
                target_register = "rip",
                role = "performed final aes decryption round by aesdeclast",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesimc",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "aesimc_crypto",
                target_register = "rip",
                role = "generated inverse aes mix columns key by aesimc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aeskeygenassist",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "round_constant" },
            },
            effect = {
                kind = "register_write",
                name = "aeskeygenassist_crypto",
                target_register = "rip",
                role = "assisted aes key generation by aeskeygenassist",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesenc",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenc_crypto",
                target_register = "rip",
                role = "performed vector aes encryption round by vaesenc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesenclast",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenclast_crypto",
                target_register = "rip",
                role = "performed final vector aes encryption round by vaesenclast",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesdec",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdec_crypto",
                target_register = "rip",
                role = "performed vector aes decryption round by vaesdec",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesdeclast",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdeclast_crypto",
                target_register = "rip",
                role = "performed final vector aes decryption round by vaesdeclast",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pclmulqdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "pclmulqdq_crypto",
                target_register = "rip",
                role = "performed carry-less quadword multiply by pclmulqdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpclmulqdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "vpclmulqdq_crypto",
                target_register = "rip",
                role = "performed vector carry-less quadword multiply by vpclmulqdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1msg1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg1_crypto",
                target_register = "rip",
                role = "performed sha1 message schedule step by sha1msg1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1msg2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg2_crypto",
                target_register = "rip",
                role = "performed sha1 message schedule step by sha1msg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1nexte",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1nexte_crypto",
                target_register = "rip",
                role = "performed sha1 next-state step by sha1nexte",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1rnds4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "function" },
            },
            effect = {
                kind = "register_write",
                name = "sha1rnds4_crypto",
                target_register = "rip",
                role = "performed four sha1 rounds by sha1rnds4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha256msg1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg1_crypto",
                target_register = "rip",
                role = "performed sha256 message schedule step by sha256msg1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha256msg2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg2_crypto",
                target_register = "rip",
                role = "performed sha256 message schedule step by sha256msg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha256rnds2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256rnds2_crypto",
                target_register = "rip",
                role = "performed two sha256 rounds by sha256rnds2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "gf2p8mulb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8mulb_crypto",
                target_register = "rip",
                role = "multiplied packed bytes in gf2p8 by gf2p8mulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "gf2p8affineqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "matrix" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineqb_crypto",
                target_register = "rip",
                role = "applied gf2p8 affine transform by gf2p8affineqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "gf2p8affineinvqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "matrix" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineinvqb_crypto",
                target_register = "rip",
                role = "applied inverse gf2p8 affine transform by gf2p8affineinvqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgf2p8mulb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8mulb_crypto",
                target_register = "rip",
                role = "multiplied packed bytes in gf2p8 by vgf2p8mulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgf2p8affineqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineqb_crypto",
                target_register = "rip",
                role = "applied vector gf2p8 affine transform by vgf2p8affineqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgf2p8affineinvqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineinvqb_crypto",
                target_register = "rip",
                role = "applied inverse vector gf2p8 affine transform by vgf2p8affineinvqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesenc128kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesenc128kl_key_locker",
                target_register = "rip",
                role = "encrypted block using 128-bit key locker handle by aesenc128kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesdec128kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesdec128kl_key_locker",
                target_register = "rip",
                role = "decrypted block using 128-bit key locker handle by aesdec128kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesenc256kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesenc256kl_key_locker",
                target_register = "rip",
                role = "encrypted block using 256-bit key locker handle by aesenc256kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesdec256kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesdec256kl_key_locker",
                target_register = "rip",
                role = "decrypted block using 256-bit key locker handle by aesdec256kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesencwide128kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesencwide128kl_key_locker",
                target_register = "rip",
                role = "encrypted wide block using 128-bit key locker handle by aesencwide128kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesdecwide128kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesdecwide128kl_key_locker",
                target_register = "rip",
                role = "decrypted wide block using 128-bit key locker handle by aesdecwide128kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesencwide256kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesencwide256kl_key_locker",
                target_register = "rip",
                role = "encrypted wide block using 256-bit key locker handle by aesencwide256kl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "aesdecwide256kl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "key_handle" },
            },
            effect = {
                kind = "register_write",
                name = "aesdecwide256kl_key_locker",
                target_register = "rip",
                role = "decrypted wide block using 256-bit key locker handle by aesdecwide256kl",
            },
        }
,

    -- SM3 / SM4 crypto extensions.
    
        {
            node_type = "instruction",
            mnemonic = "vsm3msg1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsm3msg1_crypto",
                target_register = "rip",
                role = "performed sm3 message schedule step by vsm3msg1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsm3msg2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsm3msg2_crypto",
                target_register = "rip",
                role = "performed sm3 message schedule step by vsm3msg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsm3rnds2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "round_selector" },
            },
            effect = {
                kind = "register_write",
                name = "vsm3rnds2_crypto",
                target_register = "rip",
                role = "performed two sm3 rounds by vsm3rnds2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsm4key4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsm4key4_crypto",
                target_register = "rip",
                role = "performed four sm4 key schedule rounds by vsm4key4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsm4rnds4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsm4rnds4_crypto",
                target_register = "rip",
                role = "performed four sm4 encryption rounds by vsm4rnds4",
            },
        }
,

    -- Legacy push/pop all-register aliases.
    
        {
            node_type = "instruction",
            mnemonic = "pusha",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pusha_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all pusha",
                value_delta = -32,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pushad",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pushad_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all doubleword pushad",
                value_delta = -32,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pushal",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pushal_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all long pushal",
                value_delta = -32,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pushaw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pushaw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by legacy push-all word pushaw",
                value_delta = -16,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsha1",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xsha1_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware sha1 operation by xsha1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsha256",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xsha256_updates_crypto_state",
                target_register = "rip",
                role = "performed hardware sha256 operation by xsha256",
            },
        }
,

    -- Vector crypto / GFNI / SHA / permute leftover sweep.
        -- Phase-one model: vector-only effects are exposed as RIP-side activity until vector register files are modeled.
    
        -- GFNI / Galois-field vector operations.
    
        {
            node_type = "instruction",
            mnemonic = "gf2p8mulb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8mulb_vector_gfni",
                target_register = "rip",
                role = "performed Galois-field byte multiply by gf2p8mulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgf2p8mulb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8mulb_vector_gfni",
                target_register = "rip",
                role = "performed vector Galois-field byte multiply by vgf2p8mulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "gf2p8affineqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineqb_vector_gfni",
                target_register = "rip",
                role = "performed Galois-field affine transform by gf2p8affineqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgf2p8affineqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineqb_vector_gfni",
                target_register = "rip",
                role = "performed vector Galois-field affine transform by vgf2p8affineqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "gf2p8affineinvqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "gf2p8affineinvqb_vector_gfni",
                target_register = "rip",
                role = "performed inverse Galois-field affine transform by gf2p8affineinvqb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vgf2p8affineinvqb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vgf2p8affineinvqb_vector_gfni",
                target_register = "rip",
                role = "performed vector inverse Galois-field affine transform by vgf2p8affineinvqb",
            },
        }
,

    -- SHA scalar/vector crypto helpers.
    
        {
            node_type = "instruction",
            mnemonic = "sha1msg1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg1_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA1 message schedule part by sha1msg1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1msg2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1msg2_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA1 message schedule part by sha1msg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1nexte",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha1nexte_crypto_round_assist",
                target_register = "rip",
                role = "computed SHA1 next E round helper by sha1nexte",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha1rnds4",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "sha1rnds4_crypto_rounds",
                target_register = "rip",
                role = "computed four SHA1 rounds by sha1rnds4",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha256msg1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg1_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA256 message schedule part by sha256msg1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha256msg2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sha256msg2_crypto_message_schedule",
                target_register = "rip",
                role = "computed SHA256 message schedule part by sha256msg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sha256rnds2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "sha256rnds2_crypto_rounds",
                target_register = "rip",
                role = "computed two SHA256 rounds by sha256rnds2",
            },
        }
,

    -- VAES aliases / vector AES helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vaesenc",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenc_vector_crypto_round",
                target_register = "rip",
                role = "performed vector AES encryption round by vaesenc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesenclast",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesenclast_vector_crypto_round",
                target_register = "rip",
                role = "performed final vector AES encryption round by vaesenclast",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesdec",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdec_vector_crypto_round",
                target_register = "rip",
                role = "performed vector AES decryption round by vaesdec",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vaesdeclast",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "state" },
                { index = 3, role = "round_key" },
            },
            effect = {
                kind = "register_write",
                name = "vaesdeclast_vector_crypto_round",
                target_register = "rip",
                role = "performed final vector AES decryption round by vaesdeclast",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vpclmulqdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
                { index = 4, role = "immediate" },
            },
            effect = {
                kind = "register_write",
                name = "vpclmulqdq_vector_crypto_carryless_multiply",
                target_register = "rip",
                role = "performed vector carry-less multiply by vpclmulqdq",
            },
        }
,

    -- SHA512-style vector helpers / broad recognition.
    
        {
            node_type = "instruction",
            mnemonic = "vsha512msg1",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vsha512msg1_vector_crypto_message_schedule",
                target_register = "rip",
                role = "computed vector SHA512 message schedule part by vsha512msg1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsha512msg2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vsha512msg2_vector_crypto_message_schedule",
                target_register = "rip",
                role = "computed vector SHA512 message schedule part by vsha512msg2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vsha512rnds2",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vsha512rnds2_vector_crypto_rounds",
                target_register = "rip",
                role = "computed vector SHA512 rounds by vsha512rnds2",
            },
        }
,
}
