-- lua/tracker_hud/adapters/asm_arch/x86_64/register_effects/arithmetic.lua
--
-- x86-64 arithmetic register effect specs.

return {

    -- 'neg reg' arithmetically negates the destination register.
        {
            node_type = "instruction",
            mnemonic = "neg",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "neg_register",
                target_operand = 1,
                role = "arithmetically negated by neg",
            },
        }
,

    -- 'mul reg' implicitly writes rax.
        {
            node_type = "instruction",
            mnemonic = "mul",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "multiplier",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "mul_writes_rax",
                target_register = "rax",
                role = "written by unsigned multiply",
            },
        }
,

    -- 'mul reg' implicitly writes rdx.
        {
            node_type = "instruction",
            mnemonic = "mul",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "multiplier",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "mul_writes_rdx",
                target_register = "rdx",
                role = "written by unsigned multiply high result",
            },
        }
,

    -- 'imul reg' implicitly writes rax.
        {
            node_type = "instruction",
            mnemonic = "imul",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "multiplier",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "imul_writes_rax",
                target_register = "rax",
                role = "written by signed multiply",
            },
        }
,

    -- 'imul reg' implicitly writes rdx.
        {
            node_type = "instruction",
            mnemonic = "imul",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "multiplier",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "imul_writes_rdx",
                target_register = "rdx",
                role = "written by signed multiply high result",
            },
        }
,

    -- 'div reg' implicitly writes quotient to rax.
        {
            node_type = "instruction",
            mnemonic = "div",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "divisor",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "div_writes_rax",
                target_register = "rax",
                role = "written with unsigned division quotient",
            },
        }
,

    -- 'div reg' implicitly writes remainder to rdx.
        {
            node_type = "instruction",
            mnemonic = "div",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "divisor",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "div_writes_rdx",
                target_register = "rdx",
                role = "written with unsigned division remainder",
            },
        }
,

    -- 'idiv reg' implicitly writes quotient to rax.
        {
            node_type = "instruction",
            mnemonic = "idiv",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "divisor",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "idiv_writes_rax",
                target_register = "rax",
                role = "written with signed division quotient",
            },
        }
,

    -- 'idiv reg' implicitly writes remainder to rdx.
        {
            node_type = "instruction",
            mnemonic = "idiv",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "divisor",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "idiv_writes_rdx",
                target_register = "rdx",
                role = "written with signed division remainder",
            },
        }
,

    -- 'add' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "add",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "add_updates_rflags",
                target_register = "rflags",
                role = "updated by add",
            },
        }
,

    -- 'sub' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "sub",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "sub_updates_rflags",
                target_register = "rflags",
                role = "updated by sub",
            },
        }
,

    -- 'inc' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "inc",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "inc_updates_rflags",
                target_register = "rflags",
                role = "updated by inc",
            },
        }
,

    -- 'dec' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "dec",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "dec_updates_rflags",
                target_register = "rflags",
                role = "updated by dec",
            },
        }
,

    -- 'neg' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "neg",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "neg_updates_rflags",
                target_register = "rflags",
                role = "updated by neg",
            },
        }
,

    -- 'adc reg, reg' adds with carry into the destination register.
        {
            node_type = "instruction",
            mnemonic = "adc",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source_register" },
            },
    
            effect = {
                kind = "register_write",
                name = "adc_register_register",
                target_operand = 1,
                role = "added with carry from register",
            },
        }
,

    -- 'adc reg, imm' adds an immediate with carry into the destination register.
        {
            node_type = "instruction",
            mnemonic = "adc",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "integer", role = "source_value" },
            },
    
            effect = {
                kind = "register_write",
                name = "adc_register_immediate",
                target_operand = 1,
                role = "added with carry from immediate",
            },
        }
,

    -- 'adc' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "adc",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "adc_updates_rflags",
                target_register = "rflags",
                role = "updated by adc",
            },
        }
,

    -- 'sbb reg, reg' subtracts with borrow from the destination register.
        {
            node_type = "instruction",
            mnemonic = "sbb",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source_register" },
            },
    
            effect = {
                kind = "register_write",
                name = "sbb_register_register",
                target_operand = 1,
                role = "subtracted with borrow from register",
            },
        }
,

    -- 'sbb reg, imm' subtracts an immediate with borrow from the destination register.
        {
            node_type = "instruction",
            mnemonic = "sbb",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "integer", role = "source_value" },
            },
    
            effect = {
                kind = "register_write",
                name = "sbb_register_immediate",
                target_operand = 1,
                role = "subtracted with borrow from immediate",
            },
        }
,

    -- 'sbb' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "sbb",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "sbb_updates_rflags",
                target_register = "rflags",
                role = "updated by sbb",
            },
        }
,

    -- 'xadd dest, src' exchanges and adds, mutating the destination.
        {
            node_type = "instruction",
            mnemonic = "xadd",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "xadd_mutates_destination",
                target_operand = 1,
                role = "exchanged and added by xadd",
            },
        }
,

    -- 'xadd dest, src' exchanges and adds, also writing the source register.
        {
            node_type = "instruction",
            mnemonic = "xadd",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "xadd_writes_source",
                target_operand = 2,
                role = "received original destination by xadd",
            },
        }
,

    -- 'cmpxchg dest, src' conditionally writes the destination.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg_conditional_destination",
                target_operand = 1,
                role = "conditionally exchanged by cmpxchg",
            },
        }
,

    -- 'cmpxchg dest, src' can update rax/eax/ax/al on comparison failure.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg",
    
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg_updates_accumulator",
                target_register = "rax",
                role = "conditionally updated by cmpxchg comparison",
            },
        }
,

    -- 'cmpxchg' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg",
    
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpxchg",
            },
        }
,

    -- 'cmpxchg8b' uses eax/edx as comparison input/output.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg8b",
    
            operands = {
                { index = 1, role = "memory" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg8b_updates_rax",
                target_register = "rax",
                role = "updated by cmpxchg8b comparison",
            },
        }
,

    -- 'cmpxchg8b' uses edx as comparison input/output.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg8b",
    
            operands = {
                { index = 1, role = "memory" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg8b_updates_rdx",
                target_register = "rdx",
                role = "updated by cmpxchg8b comparison",
            },
        }
,

    -- 'cmpxchg8b' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg8b",
    
            operands = {
                { index = 1, role = "memory" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg8b_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpxchg8b",
            },
        }
,

    -- 'cmpxchg16b' uses rax as comparison input/output.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg16b",
    
            operands = {
                { index = 1, role = "memory" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg16b_updates_rax",
                target_register = "rax",
                role = "updated by cmpxchg16b comparison",
            },
        }
,

    -- 'cmpxchg16b' uses rdx as comparison input/output.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg16b",
    
            operands = {
                { index = 1, role = "memory" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg16b_updates_rdx",
                target_register = "rdx",
                role = "updated by cmpxchg16b comparison",
            },
        }
,

    -- 'cmpxchg16b' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmpxchg16b",
    
            operands = {
                { index = 1, role = "memory" },
            },
    
            effect = {
                kind = "register_write",
                name = "cmpxchg16b_updates_rflags",
                target_register = "rflags",
                role = "updated by cmpxchg16b",
            },
        }
,

    -- 'imul reg, source' writes the signed multiply result to the destination register.
        {
            node_type = "instruction",
            mnemonic = "imul",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "imul_two_operand_writes_destination",
                target_operand = 1,
                role = "written with signed multiply result by imul",
            },
        }
,

    -- 'imul reg, source, imm' writes the signed multiply result to the destination register.
        {
            node_type = "instruction",
            mnemonic = "imul",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
                { index = 3, role = "multiplier" },
            },
            effect = {
                kind = "register_write",
                name = "imul_three_operand_writes_destination",
                target_operand = 1,
                role = "written with signed multiply result by imul",
            },
        }
,

    -- 'imul' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "imul",
            operands = {
                { index = 1, role = "destination_or_source" },
            },
            effect = {
                kind = "register_write",
                name = "imul_updates_rflags",
                target_register = "rflags",
                role = "updated by imul",
            },
        }
,

    -- 'adcx reg, source' adds with carry and writes destination.
        {
            node_type = "instruction",
            mnemonic = "adcx",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcx_writes_destination",
                target_operand = 1,
                role = "added with carry by adcx",
            },
        }
,

    -- 'adcx' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "adcx",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcx_updates_rflags",
                target_register = "rflags",
                role = "updated by adcx",
            },
        }
,

    -- 'adox reg, source' adds with overflow and writes destination.
        {
            node_type = "instruction",
            mnemonic = "adox",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adox_writes_destination",
                target_operand = 1,
                role = "added with overflow by adox",
            },
        }
,

    -- 'adox' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "adox",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adox_updates_rflags",
                target_register = "rflags",
                role = "updated by adox",
            },
        }
,

    -- 'mulx reg, reg, source' writes low-result destination.
        {
            node_type = "instruction",
            mnemonic = "mulx",
            operands = {
                { index = 1, kind = "register", role = "low_destination" },
                { index = 2, kind = "register", role = "high_destination" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulx_writes_low_destination",
                target_operand = 1,
                role = "written with unsigned multiply low result by mulx",
            },
        }
,

    -- 'mulx reg, reg, source' writes high-result destination.
        {
            node_type = "instruction",
            mnemonic = "mulx",
            operands = {
                { index = 1, kind = "register", role = "low_destination" },
                { index = 2, kind = "register", role = "high_destination" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulx_writes_high_destination",
                target_operand = 2,
                role = "written with unsigned multiply high result by mulx",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addps_simd_arithmetic",
                target_register = "rip",
                role = "added packed single-precision values by addps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addpd_simd_arithmetic",
                target_register = "rip",
                role = "added packed double-precision values by addpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "added scalar single-precision values by addss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "addsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "added scalar double-precision values by addsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subps_simd_arithmetic",
                target_register = "rip",
                role = "subtracted packed single-precision values by subps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subpd_simd_arithmetic",
                target_register = "rip",
                role = "subtracted packed double-precision values by subpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "subtracted scalar single-precision values by subss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "subsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "subtracted scalar double-precision values by subsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulps_simd_arithmetic",
                target_register = "rip",
                role = "multiplied packed single-precision values by mulps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulpd_simd_arithmetic",
                target_register = "rip",
                role = "multiplied packed double-precision values by mulpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "multiplied scalar single-precision values by mulss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "mulsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "multiplied scalar double-precision values by mulsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divps_simd_arithmetic",
                target_register = "rip",
                role = "divided packed single-precision values by divps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divpd_simd_arithmetic",
                target_register = "rip",
                role = "divided packed double-precision values by divpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divss_scalar_simd_arithmetic",
                target_register = "rip",
                role = "divided scalar single-precision values by divss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "divsd_scalar_simd_arithmetic",
                target_register = "rip",
                role = "divided scalar double-precision values by divsd",
            },
        }
,

    -- SSE / SSE2 / SSE3 / SSSE3 / SSE4 legacy SIMD utility visibility effects.
        -- Phase-one model: no vector register file yet, so most vector-only effects are exposed as RIP-side activity.
    
        -- SSE3 floating horizontal / add-sub helpers.
    
        {
            node_type = "instruction",
            mnemonic = "addsubps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addsubps_vector_arithmetic",
                target_register = "rip",
                role = "alternating added and subtracted packed single-precision values by addsubps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addsubpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addsubpd_vector_arithmetic",
                target_register = "rip",
                role = "alternating added and subtracted packed double-precision values by addsubpd",
            },
        }
,

    -- Arithmetic / logical suffix aliases.
        -- These improve recognition of GAS/objdump-style width-explicit mnemonics.
    
        -- ADD suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "addb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addb_writes_destination",
                target_operand = 1,
                role = "added byte source by addb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte add addb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addw_writes_destination",
                target_operand = 1,
                role = "added word source by addw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addw_updates_rflags",
                target_register = "rflags",
                role = "updated by word add addw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addl_writes_destination",
                target_operand = 1,
                role = "added long source by addl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addl_updates_rflags",
                target_register = "rflags",
                role = "updated by long add addl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addq_writes_destination",
                target_operand = 1,
                role = "added quadword source by addq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword add addq",
            },
        }
,

    -- SUB suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "subb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subb_writes_destination",
                target_operand = 1,
                role = "subtracted byte source by subb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte subtract subb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subw_writes_destination",
                target_operand = 1,
                role = "subtracted word source by subw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subw_updates_rflags",
                target_register = "rflags",
                role = "updated by word subtract subw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subl_writes_destination",
                target_operand = 1,
                role = "subtracted long source by subl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subl_updates_rflags",
                target_register = "rflags",
                role = "updated by long subtract subl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subq_writes_destination",
                target_operand = 1,
                role = "subtracted quadword source by subq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword subtract subq",
            },
        }
,

    -- Carry arithmetic / unary / shift / rotate suffix aliases.
        -- These improve recognition of GAS/objdump-style width-explicit mnemonics.
    
        -- ADC suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "adcb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcb_writes_destination",
                target_operand = 1,
                role = "added byte source with carry by adcb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte add with carry adcb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcw_writes_destination",
                target_operand = 1,
                role = "added word source with carry by adcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcw_updates_rflags",
                target_register = "rflags",
                role = "updated by word add with carry adcw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcl_writes_destination",
                target_operand = 1,
                role = "added long source with carry by adcl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcl_updates_rflags",
                target_register = "rflags",
                role = "updated by long add with carry adcl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcq_writes_destination",
                target_operand = 1,
                role = "added quadword source with carry by adcq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "adcq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "adcq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword add with carry adcq",
            },
        }
,

    -- SBB suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "sbbb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbb_writes_destination",
                target_operand = 1,
                role = "subtracted byte source with borrow by sbbb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte subtract with borrow sbbb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbw_writes_destination",
                target_operand = 1,
                role = "subtracted word source with borrow by sbbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbw_updates_rflags",
                target_register = "rflags",
                role = "updated by word subtract with borrow sbbw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbl_writes_destination",
                target_operand = 1,
                role = "subtracted long source with borrow by sbbl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbl_updates_rflags",
                target_register = "rflags",
                role = "updated by long subtract with borrow sbbl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbq_writes_destination",
                target_operand = 1,
                role = "subtracted quadword source with borrow by sbbq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sbbq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "sbbq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword subtract with borrow sbbq",
            },
        }
,

    -- IMUL suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "imulb",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "imulb_writes_rax",
                target_register = "rax",
                role = "written with byte signed multiply result by imulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imulb",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "imulb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte signed multiply imulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imulw",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "imulw_writes_rax",
                target_register = "rax",
                role = "written with word signed multiply result low by imulw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imulw",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "imulw_writes_rdx",
                target_register = "rdx",
                role = "written with word signed multiply result high by imulw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imull",
            operands = {
                { index = 1, kind = "register", role = "destination_or_source" },
            },
            effect = {
                kind = "register_write",
                name = "imull_writes_operand_or_rax",
                target_operand = 1,
                role = "written by long signed multiply imull",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imull",
            operands = {
                { index = 1, role = "destination_or_source" },
            },
            effect = {
                kind = "register_write",
                name = "imull_updates_rflags",
                target_register = "rflags",
                role = "updated by long signed multiply imull",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imulq",
            operands = {
                { index = 1, kind = "register", role = "destination_or_source" },
            },
            effect = {
                kind = "register_write",
                name = "imulq_writes_operand_or_rax",
                target_operand = 1,
                role = "written by quadword signed multiply imulq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "imulq",
            operands = {
                { index = 1, role = "destination_or_source" },
            },
            effect = {
                kind = "register_write",
                name = "imulq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword signed multiply imulq",
            },
        }
,

    -- MUL / DIV / IDIV suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "mulb",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulb_writes_rax",
                target_register = "rax",
                role = "written with byte unsigned multiply result by mulb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulq_writes_rax",
                target_register = "rax",
                role = "written with quadword unsigned multiply result low by mulq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulq_writes_rdx",
                target_register = "rdx",
                role = "written with quadword unsigned multiply result high by mulq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divb",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divb_writes_rax",
                target_register = "rax",
                role = "written with byte unsigned divide quotient/remainder by divb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divq_writes_rax",
                target_register = "rax",
                role = "written with quadword unsigned divide quotient by divq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divq_writes_rdx",
                target_register = "rdx",
                role = "written with quadword unsigned divide remainder by divq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "idivb",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "idivb_writes_rax",
                target_register = "rax",
                role = "written with byte signed divide quotient/remainder by idivb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "idivq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "idivq_writes_rax",
                target_register = "rax",
                role = "written with quadword signed divide quotient by idivq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "idivq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "idivq_writes_rdx",
                target_register = "rdx",
                role = "written with quadword signed divide remainder by idivq",
            },
        }
,

    -- CMPXCHG / XADD suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "cmpxchgb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgb_writes_destination",
                target_operand = 1,
                role = "conditionally written by byte compare-exchange cmpxchgb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgb_updates_rax",
                target_register = "rax",
                role = "updated by byte compare-exchange cmpxchgb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgb",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgb_updates_rflags",
                target_register = "rflags",
                role = "updated by byte compare-exchange cmpxchgb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgw_writes_destination",
                target_operand = 1,
                role = "conditionally written by word compare-exchange cmpxchgw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgl_writes_destination",
                target_operand = 1,
                role = "conditionally written by long compare-exchange cmpxchgl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgq_writes_destination",
                target_operand = 1,
                role = "conditionally written by quadword compare-exchange cmpxchgq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgq_updates_rax",
                target_register = "rax",
                role = "updated by quadword compare-exchange cmpxchgq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cmpxchgq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "cmpxchgq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword compare-exchange cmpxchgq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddb_writes_destination",
                target_operand = 1,
                role = "written by byte exchange-add xaddb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddb",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddb_writes_source",
                target_operand = 2,
                role = "written with original byte destination by xaddb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddq_writes_destination",
                target_operand = 1,
                role = "written by quadword exchange-add xaddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddq_writes_source",
                target_operand = 2,
                role = "written with original quadword destination by xaddq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword exchange-add xaddq",
            },
        }
,

    -- XADD word/long completion.
    
        {
            node_type = "instruction",
            mnemonic = "xaddw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddw_writes_destination",
                target_operand = 1,
                role = "written by word exchange-add xaddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddw_writes_source",
                target_operand = 2,
                role = "written with original word destination by xaddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddw_updates_rflags",
                target_register = "rflags",
                role = "updated by word exchange-add xaddw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddl_writes_destination",
                target_operand = 1,
                role = "written by long exchange-add xaddl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, kind = "register", role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddl_writes_source",
                target_operand = 2,
                role = "written with original long destination by xaddl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xaddl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xaddl_updates_rflags",
                target_register = "rflags",
                role = "updated by long exchange-add xaddl",
            },
        }
,

    -- BMI arithmetic/shift suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "mulxl",
            operands = {
                { index = 1, kind = "register", role = "low_destination" },
                { index = 2, kind = "register", role = "high_destination" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulxl_writes_low_destination",
                target_operand = 1,
                role = "written with long unsigned multiply low result by mulxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulxl",
            operands = {
                { index = 1, kind = "register", role = "low_destination" },
                { index = 2, kind = "register", role = "high_destination" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulxl_writes_high_destination",
                target_operand = 2,
                role = "written with long unsigned multiply high result by mulxl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulxq",
            operands = {
                { index = 1, kind = "register", role = "low_destination" },
                { index = 2, kind = "register", role = "high_destination" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulxq_writes_low_destination",
                target_operand = 1,
                role = "written with quadword unsigned multiply low result by mulxq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulxq",
            operands = {
                { index = 1, kind = "register", role = "low_destination" },
                { index = 2, kind = "register", role = "high_destination" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulxq_writes_high_destination",
                target_operand = 2,
                role = "written with quadword unsigned multiply high result by mulxq",
            },
        }
,

    -- Scalar floating-point / SSE arithmetic and compare cleanup.
        -- Phase-one model: vector/scalar FP register effects are exposed as RIP-side activity until XMM/YMM/ZMM state is modeled.
    
        -- Scalar single/double arithmetic.
    
        {
            node_type = "instruction",
            mnemonic = "addss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addss_scalar_fp_add",
                target_register = "rip",
                role = "performed scalar single-precision add by addss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addsd_scalar_fp_add",
                target_register = "rip",
                role = "performed scalar double-precision add by addsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subss_scalar_fp_subtract",
                target_register = "rip",
                role = "performed scalar single-precision subtract by subss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subsd_scalar_fp_subtract",
                target_register = "rip",
                role = "performed scalar double-precision subtract by subsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulss_scalar_fp_multiply",
                target_register = "rip",
                role = "performed scalar single-precision multiply by mulss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulsd_scalar_fp_multiply",
                target_register = "rip",
                role = "performed scalar double-precision multiply by mulsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divss",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divss_scalar_fp_divide",
                target_register = "rip",
                role = "performed scalar single-precision divide by divss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divsd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divsd_scalar_fp_divide",
                target_register = "rip",
                role = "performed scalar double-precision divide by divsd",
            },
        }
,

    -- Packed single/double arithmetic.
    
        {
            node_type = "instruction",
            mnemonic = "addps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addps_packed_fp_add",
                target_register = "rip",
                role = "performed packed single-precision add by addps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "addpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "addpd_packed_fp_add",
                target_register = "rip",
                role = "performed packed double-precision add by addpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subps_packed_fp_subtract",
                target_register = "rip",
                role = "performed packed single-precision subtract by subps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "subpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "subpd_packed_fp_subtract",
                target_register = "rip",
                role = "performed packed double-precision subtract by subpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulps_packed_fp_multiply",
                target_register = "rip",
                role = "performed packed single-precision multiply by mulps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mulpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "mulpd_packed_fp_multiply",
                target_register = "rip",
                role = "performed packed double-precision multiply by mulpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divps_packed_fp_divide",
                target_register = "rip",
                role = "performed packed single-precision divide by divps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "divpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "divpd_packed_fp_divide",
                target_register = "rip",
                role = "performed packed double-precision divide by divpd",
            },
        }
,

    -- sub reg, reg
        {
            node_type = "instruction",
            mnemonic = "sub",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "register",
                    role = "source",
                },
            },
    
            condition = {
                operands_equal = { 1, 2 },
            },
    
            effect = {
                kind = "register_write",
                name = "sub_register_self_zero",
                target_operand = 1,
                value = "0",
                role = "zeroed by sub",
            },
        }
,

    -- 'cmp' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "cmp",
    
            operands = {
                {
                    index = 1,
                    role = "left",
                },
                {
                    index = 2,
                    role = "right",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "cmp_updates_rflags",
                target_register = "rflags",
                role = "updated by cmp",
            },
        }
,

    -- 'add'
        {
            node_type = "instruction",
            mnemonic = "add",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "increment_value",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "add_register_immediate",
                target_operand = 1,
                value_delta_operand = 2,
                role = "increased by immediate",
            },
        }
,

    -- 'sub'
        {
            node_type = "instruction",
            mnemonic = "sub",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
                {
                    index = 2,
                    kind = "integer",
                    role = "decrement_value",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "sub_register_immediate",
                target_operand = 1,
                value_delta_operand = 2,
                value_delta_sign = -1,
                role = "decreased by immediate",
            },
        }
,

    -- 'inc'
        {
            node_type = "instruction",
            mnemonic = "inc",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "inc_register",
                target_operand = 1,
                value_delta = 1,
                role = "incremented",
            },
        }
,

    -- 'dec'
        {
            node_type = "instruction",
            mnemonic = "dec",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "dec_register",
                target_operand = 1,
                value_delta = -1,
                role = "decremented",
            },
        }
,
}
