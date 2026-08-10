-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/control_flow.lua
--
-- x86-64 control flow register effect specs.

return {

    -- 'loop' decrements rcx.
        {
            node_type = "instruction",
            mnemonic = "loop",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "loop_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loop",
            },
        }
,

    -- 'loope' decrements rcx.
        {
            node_type = "instruction",
            mnemonic = "loope",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "loope_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loope",
            },
        }
,

    -- 'loopz' decrements rcx.
        {
            node_type = "instruction",
            mnemonic = "loopz",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "loopz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopz",
            },
        }
,

    -- 'loopne' decrements rcx.
        {
            node_type = "instruction",
            mnemonic = "loopne",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "loopne_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopne",
            },
        }
,

    -- 'loopnz' decrements rcx.
        {
            node_type = "instruction",
            mnemonic = "loopnz",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "loopnz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopnz",
            },
        }
,

    -- 'call target' changes rip.
        {
            node_type = "instruction",
            mnemonic = "call",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "call_updates_rip",
                target_register = "rip",
                role = "changed by call",
            },
        }
,

    -- 'ret' changes rip.
        {
            node_type = "instruction",
            mnemonic = "ret",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "ret_updates_rip",
                target_register = "rip",
                role = "restored from return address by ret",
            },
        }
,

    -- 'jmp target' changes rip.
        {
            node_type = "instruction",
            mnemonic = "jmp",
    
            operands = {
                { index = 1, role = "target" },
            },
    
            effect = {
                kind = "register_write",
                name = "jmp_updates_rip",
                target_register = "rip",
                role = "changed by jmp",
            },
        }
,

    -- Conditional jump effects.
        {
            node_type = "instruction",
            mnemonic = "ja",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "ja_updates_rip",
                target_register = "rip",
                role = "conditional jump above by ja",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jae",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jae_updates_rip",
                target_register = "rip",
                role = "conditional jump above-or-equal by jae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jb",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jb_updates_rip",
                target_register = "rip",
                role = "conditional jump below by jb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jbe",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jbe_updates_rip",
                target_register = "rip",
                role = "conditional jump below-or-equal by jbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jc",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jc_updates_rip",
                target_register = "rip",
                role = "conditional jump on carry by jc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnc",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnc_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-carry by jnc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "je",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "je_updates_rip",
                target_register = "rip",
                role = "conditional jump equal by je",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jne",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jne_updates_rip",
                target_register = "rip",
                role = "conditional jump not-equal by jne",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jz",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jz_updates_rip",
                target_register = "rip",
                role = "conditional jump zero by jz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnz",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnz_updates_rip",
                target_register = "rip",
                role = "conditional jump not-zero by jnz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jg",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jg_updates_rip",
                target_register = "rip",
                role = "conditional jump greater-than by jg",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jge",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jge_updates_rip",
                target_register = "rip",
                role = "conditional jump greater-or-equal by jge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jl",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jl_updates_rip",
                target_register = "rip",
                role = "conditional jump less-than by jl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jle",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jle_updates_rip",
                target_register = "rip",
                role = "conditional jump less-or-equal by jle",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jo",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jo_updates_rip",
                target_register = "rip",
                role = "conditional jump on overflow by jo",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jno",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jno_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-overflow by jno",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "js",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "js_updates_rip",
                target_register = "rip",
                role = "conditional jump on sign by js",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jns",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jns_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-sign by jns",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jp",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jp_updates_rip",
                target_register = "rip",
                role = "conditional jump on parity by jp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnp",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnp_updates_rip",
                target_register = "rip",
                role = "conditional jump on not-parity by jnp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jcxz",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if cx is zero by jcxz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jecxz",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jecxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if ecx is zero by jecxz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jrcxz",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jrcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if rcx is zero by jrcxz",
            },
        }
,

    -- Conditional jump alias effects.
        {
            node_type = "instruction",
            mnemonic = "jna",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jna_updates_rip",
                target_register = "rip",
                role = "conditional jump not-above by jna",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnae",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnae_updates_rip",
                target_register = "rip",
                role = "conditional jump not-above-or-equal by jnae",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnb",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnb_updates_rip",
                target_register = "rip",
                role = "conditional jump not-below by jnb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnbe",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnbe_updates_rip",
                target_register = "rip",
                role = "conditional jump not-below-or-equal by jnbe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnge",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnge_updates_rip",
                target_register = "rip",
                role = "conditional jump not-greater-or-equal by jnge",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jng",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jng_updates_rip",
                target_register = "rip",
                role = "conditional jump not-greater by jng",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnl",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnl_updates_rip",
                target_register = "rip",
                role = "conditional jump not-less by jnl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnle",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jnle_updates_rip",
                target_register = "rip",
                role = "conditional jump not-less-or-equal by jnle",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jpe",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jpe_updates_rip",
                target_register = "rip",
                role = "conditional jump parity-even by jpe",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jpo",
            operands = { { index = 1, role = "jump_target" } },
            effect = {
                kind = "register_write",
                name = "jpo_updates_rip",
                target_register = "rip",
                role = "conditional jump parity-odd by jpo",
            },
        }
,

    -- 'loope target' decrements rcx and conditionally branches.
        {
            node_type = "instruction",
            mnemonic = "loope",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loope_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loope",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "loope",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loope_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loope",
            },
        }
,

    -- 'loopz target' is an alias form of loope.
        {
            node_type = "instruction",
            mnemonic = "loopz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "loopz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopz_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loopz",
            },
        }
,

    -- 'loopne target' decrements rcx and conditionally branches.
        {
            node_type = "instruction",
            mnemonic = "loopne",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopne_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopne",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "loopne",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopne_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loopne",
            },
        }
,

    -- 'loopnz target' is an alias form of loopne.
        {
            node_type = "instruction",
            mnemonic = "loopnz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopnz_decrements_rcx",
                target_register = "rcx",
                value_delta = -1,
                role = "decremented by loopnz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "loopnz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "loopnz_updates_rip",
                target_register = "rip",
                role = "conditional loop branch by loopnz",
            },
        }
,

    -- 'jrcxz target' conditionally branches when rcx is zero.
        {
            node_type = "instruction",
            mnemonic = "jrcxz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "jrcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if rcx zero by jrcxz",
            },
        }
,

    -- 'jecxz target' conditionally branches when ecx is zero.
        {
            node_type = "instruction",
            mnemonic = "jecxz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "jecxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if ecx zero by jecxz",
            },
        }
,

    -- 'jcxz target' conditionally branches when cx is zero.
        {
            node_type = "instruction",
            mnemonic = "jcxz",
            operands = {
                { index = 1, role = "jump_target" },
            },
            effect = {
                kind = "register_write",
                name = "jcxz_updates_rip",
                target_register = "rip",
                role = "conditional jump if cx zero by jcxz",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retf",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_updates_rip",
                target_register = "rip",
                role = "far return changed instruction pointer by retf",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retf",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_updates_rsp",
                target_register = "rsp",
                role = "far return adjusted stack pointer by retf",
            },
        }
,

    -- Far calls/jumps. Modeled as RIP-visible control transfers.
        {
            node_type = "instruction",
            mnemonic = "callf",
            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "callf_updates_rip",
                target_register = "rip",
                role = "far call changed instruction pointer by callf",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "callf",
            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "callf_updates_rsp",
                target_register = "rsp",
                role = "far call adjusted stack pointer by callf",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jmpf",
            operands = {
                { index = 1, role = "far_target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpf_updates_rip",
                target_register = "rip",
                role = "far jump changed instruction pointer by jmpf",
            },
        }
,

    -- Near/far return aliases.
    
        {
            node_type = "instruction",
            mnemonic = "retn",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retn_updates_rip",
                target_register = "rip",
                role = "returned near by retn",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retn",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retn_increases_rsp",
                target_register = "rsp",
                role = "increased by near return retn",
                value_delta = 8,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retf",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_updates_rip",
                target_register = "rip",
                role = "returned far by retf",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retf",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retf_increases_rsp",
                target_register = "rsp",
                role = "increased by far return retf",
                value_delta = 16,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retfq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retfq_updates_rip",
                target_register = "rip",
                role = "returned far quadword by retfq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retfq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retfq_increases_rsp",
                target_register = "rsp",
                role = "increased by far quadword return retfq",
                value_delta = 16,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retfw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retfw_updates_rip",
                target_register = "rip",
                role = "returned far word by retfw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retfw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retfw_increases_rsp",
                target_register = "rsp",
                role = "increased by far word return retfw",
                value_delta = 4,
            },
        }
,

    -- Scalar suffix aliases / disassembler compatibility / data movement cleanup.
        -- These help recognize common GAS/objdump-style spellings and legacy width-explicit aliases.
    
        -- Call aliases.
    
        {
            node_type = "instruction",
            mnemonic = "callq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callq_updates_rip",
                target_register = "rip",
                role = "called quadword target by callq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "callq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callq_decreases_rsp",
                target_register = "rsp",
                role = "decreased by quadword call return-address push callq",
                value_delta = -8,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "calll",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "calll_updates_rip",
                target_register = "rip",
                role = "called long target by calll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "calll",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "calll_decreases_rsp",
                target_register = "rsp",
                role = "decreased by long call return-address push calll",
                value_delta = -4,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "callw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callw_updates_rip",
                target_register = "rip",
                role = "called word target by callw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "callw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "callw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by word call return-address push callw",
                value_delta = -2,
            },
        }
,

    -- Jump aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jmpq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpq_updates_rip",
                target_register = "rip",
                role = "jumped to quadword target by jmpq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jmpl",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpl_updates_rip",
                target_register = "rip",
                role = "jumped to long target by jmpl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jmpw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jmpw_updates_rip",
                target_register = "rip",
                role = "jumped to word target by jmpw",
            },
        }
,

    -- Return aliases.
    
        {
            node_type = "instruction",
            mnemonic = "retq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retq_updates_rip",
                target_register = "rip",
                role = "returned quadword by retq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retq_increases_rsp",
                target_register = "rsp",
                role = "increased by quadword return retq",
                value_delta = 8,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retl_updates_rip",
                target_register = "rip",
                role = "returned long by retl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retl",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retl_increases_rsp",
                target_register = "rsp",
                role = "increased by long return retl",
                value_delta = 4,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retw_updates_rip",
                target_register = "rip",
                role = "returned word by retw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "retw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "retw_increases_rsp",
                target_register = "rsp",
                role = "increased by word return retw",
                value_delta = 2,
            },
        }
,

    -- Conditional jump suffix / alias completion.
        -- These improve recognition of GAS/objdump-style condition aliases and width-explicit jump spellings.
    
        -- Equality / zero aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jeq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if equal by jeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jel",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if equal by jel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jew",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if equal by jew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jzq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jzq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if zero by jzq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jzl",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jzl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if zero by jzl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jzw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jzw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if zero by jzw",
            },
        }
,

    -- Not-equal / not-zero aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jneq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jneq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not equal by jneq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnel",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not equal by jnel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnew",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not equal by jnew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnzq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnzq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not zero by jnzq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnzl",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnzl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not zero by jnzl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnzw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnzw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not zero by jnzw",
            },
        }
,

    -- Signed greater / greater-or-equal aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jgq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater by jgq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jgl",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater by jgl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jgw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater by jgw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jgeq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater-or-equal by jgeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jgel",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater-or-equal by jgel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jgew",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jgew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed greater-or-equal by jgew",
            },
        }
,

    -- Signed less / less-or-equal aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jlq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less by jlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jll",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jll_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less by jll",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jlw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less by jlw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jleq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jleq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less-or-equal by jleq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jlel",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less-or-equal by jlel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jlew",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jlew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if signed less-or-equal by jlew",
            },
        }
,

    -- Unsigned above / above-or-equal aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jaq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above by jaq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jal",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jal_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above by jal",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jaw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above by jaw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jaeq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above-or-equal by jaeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jael",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jael_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above-or-equal by jael",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jaew",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jaew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned above-or-equal by jaew",
            },
        }
,

    -- Unsigned below / below-or-equal / carry aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jbq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below by jbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jbl",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbl_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below by jbl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jbw",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbw_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below by jbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jbeq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below-or-equal by jbeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jbel",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbel_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below-or-equal by jbel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jbew",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jbew_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if unsigned below-or-equal by jbew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jcq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jcq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if carry by jcq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jncq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jncq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not carry by jncq",
            },
        }
,

    -- Sign / overflow / parity aliases.
    
        {
            node_type = "instruction",
            mnemonic = "jsq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jsq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if sign by jsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnsq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnsq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not sign by jnsq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "joq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "joq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if overflow by joq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnoq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnoq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not overflow by jnoq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jpq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jpq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if parity by jpq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnpq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnpq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not parity by jnpq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jpeq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jpeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if parity even by jpeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jpoq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jpoq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if parity odd by jpoq",
            },
        }
,

    -- Negated signed aliases sometimes seen in assembler/disassembler output.
    
        {
            node_type = "instruction",
            mnemonic = "jngq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jngq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed greater by jngq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jngeq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jngeq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed greater-or-equal by jngeq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnlq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnlq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed less by jnlq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "jnleq",
            operands = {
                { index = 1, role = "target" },
            },
            effect = {
                kind = "register_write",
                name = "jnleq_updates_rip",
                target_register = "rip",
                role = "conditionally jumped if not signed less-or-equal by jnleq",
            },
        }
,

    -- 'call' decreases rsp.
        {
            node_type = "instruction",
            mnemonic = "call",
    
            operands = {
                {
                    index = 1,
                    role = "call_target",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "call_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by call",
            },
        }
,

    -- 'ret' increase rsp.
        {
            node_type = "instruction",
            mnemonic = "ret",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "ret_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by ret",
            },
        }
,
}
