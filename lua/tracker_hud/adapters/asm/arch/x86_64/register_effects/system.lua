-- lua/tracker_hud/adapters/asm/arch/x86_64/register_effects/system.lua
--
-- x86-64 system register effect specs.

return {

    -- 'cpuid' writes processor information into rax.
        {
            node_type = "instruction",
            mnemonic = "cpuid",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rax",
                target_register = "rax",
                role = "written by cpuid",
            },
        }
,

    -- 'cpuid' writes processor information into rbx.
        {
            node_type = "instruction",
            mnemonic = "cpuid",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rbx",
                target_register = "rbx",
                role = "written by cpuid",
            },
        }
,

    -- 'cpuid' writes processor information into rcx.
        {
            node_type = "instruction",
            mnemonic = "cpuid",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rcx",
                target_register = "rcx",
                role = "written by cpuid",
            },
        }
,

    -- 'cpuid' writes processor information into rdx.
        {
            node_type = "instruction",
            mnemonic = "cpuid",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rdx",
                target_register = "rdx",
                role = "written by cpuid",
            },
        }
,

    -- 'cld' clears the direction flag.
        {
            node_type = "instruction",
            mnemonic = "cld",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cld_updates_rflags",
                target_register = "rflags",
                role = "direction flag cleared by cld",
            },
        }
,

    -- 'std' sets the direction flag.
        {
            node_type = "instruction",
            mnemonic = "std",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "std_updates_rflags",
                target_register = "rflags",
                role = "direction flag set by std",
            },
        }
,

    -- 'rdtsc' writes the low timestamp bits to eax/rax.
        {
            node_type = "instruction",
            mnemonic = "rdtsc",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "rdtsc_writes_rax",
                target_register = "rax",
                role = "written with timestamp low result by rdtsc",
            },
        }
,

    -- 'rdtsc' writes the high timestamp bits to edx/rdx.
        {
            node_type = "instruction",
            mnemonic = "rdtsc",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "rdtsc_writes_rdx",
                target_register = "rdx",
                role = "written with timestamp high result by rdtsc",
            },
        }
,

    -- 'rdtscp' writes the low timestamp bits to eax/rax.
        {
            node_type = "instruction",
            mnemonic = "rdtscp",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "rdtscp_writes_rax",
                target_register = "rax",
                role = "written with timestamp low result by rdtscp",
            },
        }
,

    -- 'rdtscp' writes the high timestamp bits to edx/rdx.
        {
            node_type = "instruction",
            mnemonic = "rdtscp",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "rdtscp_writes_rdx",
                target_register = "rdx",
                role = "written with timestamp high result by rdtscp",
            },
        }
,

    -- 'rdtscp' writes the processor id/result metadata to ecx/rcx.
        {
            node_type = "instruction",
            mnemonic = "rdtscp",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "rdtscp_writes_rcx",
                target_register = "rcx",
                role = "written with processor id by rdtscp",
            },
        }
,

    -- 'rdrand reg' writes a hardware random value to the destination.
        {
            node_type = "instruction",
            mnemonic = "rdrand",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "rdrand_register",
                target_operand = 1,
                role = "written with hardware random value by rdrand",
            },
        }
,

    -- 'rdrand' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "rdrand",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "rdrand_updates_rflags",
                target_register = "rflags",
                role = "updated by rdrand",
            },
        }
,

    -- 'rdseed reg' writes a hardware seed value to the destination.
        {
            node_type = "instruction",
            mnemonic = "rdseed",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "rdseed_register",
                target_operand = 1,
                role = "written with hardware seed value by rdseed",
            },
        }
,

    -- 'rdseed' updates rflags.
        {
            node_type = "instruction",
            mnemonic = "rdseed",
    
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
    
            effect = {
                kind = "register_write",
                name = "rdseed_updates_rflags",
                target_register = "rflags",
                role = "updated by rdseed",
            },
        }
,

    -- 'nop' intentionally performs no operation.
        {
            node_type = "instruction",
            mnemonic = "nop",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "nop_no_operation",
                target_register = "rip",
                role = "advanced by nop",
            },
        }
,

    -- 'int imm' transfers control to a software interrupt handler.
        {
            node_type = "instruction",
            mnemonic = "int",
    
            operands = {
                {
                    index = 1,
                    role = "interrupt_vector",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "int_updates_rip",
                target_register = "rip",
                role = "software interrupt transfer by int",
            },
        }
,

    -- 'int3' transfers control to the breakpoint interrupt handler.
        {
            node_type = "instruction",
            mnemonic = "int3",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "int3_updates_rip",
                target_register = "rip",
                role = "breakpoint interrupt by int3",
            },
        }
,

    -- 'into' transfers control on overflow.
        {
            node_type = "instruction",
            mnemonic = "into",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "into_updates_rip",
                target_register = "rip",
                role = "overflow interrupt by into",
            },
        }
,

    -- 'iret' returns from an interrupt.
        {
            node_type = "instruction",
            mnemonic = "iret",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "iret_updates_rip",
                target_register = "rip",
                role = "returned from interrupt by iret",
            },
        }
,

    -- 'iretq' returns from a 64-bit interrupt.
        {
            node_type = "instruction",
            mnemonic = "iretq",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "iretq_updates_rip",
                target_register = "rip",
                role = "returned from interrupt by iretq",
            },
        }
,

    -- 'sysenter' enters a fast system-call handler.
        {
            node_type = "instruction",
            mnemonic = "sysenter",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "sysenter_updates_rip",
                target_register = "rip",
                role = "entered system call by sysenter",
            },
        }
,

    -- 'sysexit' returns from a fast system-call handler.
        {
            node_type = "instruction",
            mnemonic = "sysexit",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "sysexit_updates_rip",
                target_register = "rip",
                role = "returned from system call by sysexit",
            },
        }
,

    -- 'sysret' returns from a system call.
        {
            node_type = "instruction",
            mnemonic = "sysret",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "sysret_updates_rip",
                target_register = "rip",
                role = "returned from system call by sysret",
            },
        }
,

    -- 'sysretq' returns from a 64-bit system call.
        {
            node_type = "instruction",
            mnemonic = "sysretq",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "sysretq_updates_rip",
                target_register = "rip",
                role = "returned from system call by sysretq",
            },
        }
,

    -- 'ud2' raises an invalid-instruction exception.
        {
            node_type = "instruction",
            mnemonic = "ud2",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "ud2_updates_rip",
                target_register = "rip",
                role = "invalid instruction trap by ud2",
            },
        }
,

    -- 'hlt' halts the processor until an external event.
        {
            node_type = "instruction",
            mnemonic = "hlt",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "hlt_updates_rip",
                target_register = "rip",
                role = "halted by hlt",
            },
        }
,

    -- 'pause' is a spin-wait hint.
        {
            node_type = "instruction",
            mnemonic = "pause",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "pause_updates_rip",
                target_register = "rip",
                role = "spin-wait hint by pause",
            },
        }
,

    -- 'wait' waits for the floating-point unit.
        {
            node_type = "instruction",
            mnemonic = "wait",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "wait_updates_rip",
                target_register = "rip",
                role = "waited for floating-point unit by wait",
            },
        }
,

    -- 'fwait' waits for the floating-point unit.
        {
            node_type = "instruction",
            mnemonic = "fwait",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "fwait_updates_rip",
                target_register = "rip",
                role = "waited for floating-point unit by fwait",
            },
        }
,

    -- 'cli' clears the interrupt flag.
        {
            node_type = "instruction",
            mnemonic = "cli",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cli_updates_rflags",
                target_register = "rflags",
                role = "interrupt flag cleared by cli",
            },
        }
,

    -- 'sti' sets the interrupt flag.
        {
            node_type = "instruction",
            mnemonic = "sti",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "sti_updates_rflags",
                target_register = "rflags",
                role = "interrupt flag set by sti",
            },
        }
,

    -- 'cld' clears the direction flag.
        {
            node_type = "instruction",
            mnemonic = "cld",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "cld_updates_rflags",
                target_register = "rflags",
                role = "direction flag cleared by cld",
            },
        }
,

    -- 'std' sets the direction flag.
        {
            node_type = "instruction",
            mnemonic = "std",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "std_updates_rflags",
                target_register = "rflags",
                role = "direction flag set by std",
            },
        }
,

    -- 'clac' clears the alignment-check/access-control flag.
        {
            node_type = "instruction",
            mnemonic = "clac",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "clac_updates_rflags",
                target_register = "rflags",
                role = "access-control flag cleared by clac",
            },
        }
,

    -- 'stac' sets the alignment-check/access-control flag.
        {
            node_type = "instruction",
            mnemonic = "stac",
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "stac_updates_rflags",
                target_register = "rflags",
                role = "access-control flag set by stac",
            },
        }
,

    -- Model/control read instructions that write general-purpose result registers.
        {
            node_type = "instruction",
            mnemonic = "rdmsr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdmsr_writes_rax",
                target_register = "rax",
                role = "written with model-specific register low bits by rdmsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdmsr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdmsr_writes_rdx",
                target_register = "rdx",
                role = "written with model-specific register high bits by rdmsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpmc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpmc_writes_rax",
                target_register = "rax",
                role = "written with performance counter low bits by rdpmc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpmc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpmc_writes_rdx",
                target_register = "rdx",
                role = "written with performance counter high bits by rdpmc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xgetbv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xgetbv_writes_rax",
                target_register = "rax",
                role = "written with extended control register low bits by xgetbv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xgetbv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xgetbv_writes_rdx",
                target_register = "rdx",
                role = "written with extended control register high bits by xgetbv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpkru",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpkru_writes_rax",
                target_register = "rax",
                role = "written with protection-key rights by rdpkru",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpkru",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpkru_writes_rdx",
                target_register = "rdx",
                role = "cleared high result by rdpkru",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "iretw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "iretw_updates_rip",
                target_register = "rip",
                role = "returned from interrupt by iretw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "iretd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "iretd_updates_rip",
                target_register = "rip",
                role = "returned from interrupt by iretd",
            },
        }
,

    -- 'xbegin target' conditionally transfers control and may write rax on abort.
        {
            node_type = "instruction",
            mnemonic = "xbegin",
            operands = {
                { index = 1, role = "abort_target" },
            },
            effect = {
                kind = "register_write",
                name = "xbegin_updates_rip",
                target_register = "rip",
                role = "transactional branch started by xbegin",
            },
        }
,

    -- 'xbegin' may write abort status to eax/rax.
        {
            node_type = "instruction",
            mnemonic = "xbegin",
            operands = {
                { index = 1, role = "abort_target" },
            },
            effect = {
                kind = "register_write",
                name = "xbegin_may_write_rax",
                target_register = "rax",
                written_alias = "eax",
                role = "may receive transaction abort status by xbegin",
            },
        }
,

    -- 'xend' ends a transactional region.
        {
            node_type = "instruction",
            mnemonic = "xend",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xend_updates_rip",
                target_register = "rip",
                role = "ended transactional region by xend",
            },
        }
,

    -- 'xtest' updates flags according to transactional state.
        {
            node_type = "instruction",
            mnemonic = "xtest",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xtest_updates_rflags",
                target_register = "rflags",
                role = "updated by transactional state test xtest",
            },
        }
,

    -- 'xabort imm' aborts a transactional region and transfers control.
        {
            node_type = "instruction",
            mnemonic = "xabort",
            operands = {
                { index = 1, role = "abort_code" },
            },
            effect = {
                kind = "register_write",
                name = "xabort_updates_rip",
                target_register = "rip",
                role = "transaction aborted by xabort",
            },
        }
,

    -- Memory ordering fences.
        {
            node_type = "instruction",
            mnemonic = "lfence",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lfence_orders_memory",
                target_register = "rip",
                role = "passed load fence by lfence",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sfence",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sfence_orders_memory",
                target_register = "rip",
                role = "passed store fence by sfence",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mfence",
            operands = {},
            effect = {
                kind = "register_write",
                name = "mfence_orders_memory",
                target_register = "rip",
                role = "passed memory fence by mfence",
            },
        }
,

    -- Cache-line maintenance instructions.
        {
            node_type = "instruction",
            mnemonic = "clflush",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "clflush_touches_cache",
                target_register = "rip",
                role = "flushed cache line by clflush",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clflushopt",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "clflushopt_touches_cache",
                target_register = "rip",
                role = "flushed cache line by clflushopt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clwb",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "clwb_touches_cache",
                target_register = "rip",
                role = "wrote back cache line by clwb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetcht0",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "prefetcht0_touches_memory",
                target_register = "rip",
                role = "prefetched memory into t0 cache by prefetcht0",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetcht1",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "prefetcht1_touches_memory",
                target_register = "rip",
                role = "prefetched memory into t1 cache by prefetcht1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetcht2",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "prefetcht2_touches_memory",
                target_register = "rip",
                role = "prefetched memory into t2 cache by prefetcht2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetchnta",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "prefetchnta_touches_memory",
                target_register = "rip",
                role = "prefetched non-temporal memory by prefetchnta",
            },
        }
,

    -- Monitor / wait hints.
        {
            node_type = "instruction",
            mnemonic = "monitor",
            operands = {},
            effect = {
                kind = "register_write",
                name = "monitor_uses_address_registers",
                target_register = "rip",
                role = "armed monitored address by monitor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mwait",
            operands = {},
            effect = {
                kind = "register_write",
                name = "mwait_waits_for_monitor",
                target_register = "rip",
                role = "waited for monitored event by mwait",
            },
        }
,

    -- TLB/cache/system-memory maintenance.
        {
            node_type = "instruction",
            mnemonic = "invlpg",
            operands = {
                { index = 1, role = "memory_operand" },
            },
            effect = {
                kind = "register_write",
                name = "invlpg_invalidates_translation",
                target_register = "rip",
                role = "invalidated page translation by invlpg",
            },
        }
,

    -- Descriptor table reads / selector reads.
        {
            node_type = "instruction",
            mnemonic = "sldt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sldt_writes_destination",
                target_operand = 1,
                role = "written with local descriptor table selector by sldt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "str",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "str_writes_destination",
                target_operand = 1,
                role = "written with task register selector by str",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "smsw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "smsw_writes_destination",
                target_operand = 1,
                role = "written with machine status word by smsw",
            },
        }
,

    -- Memory destination forms are represented as visible RIP-side effects for now.
        {
            node_type = "instruction",
            mnemonic = "sgdt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sgdt_stores_descriptor_table",
                target_register = "rip",
                role = "stored global descriptor table register by sgdt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sidt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sidt_stores_descriptor_table",
                target_register = "rip",
                role = "stored interrupt descriptor table register by sidt",
            },
        }
,

    -- Segment/base helpers.
        {
            node_type = "instruction",
            mnemonic = "rdfsbase",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdfsbase_writes_destination",
                target_operand = 1,
                role = "written with fs base by rdfsbase",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdgsbase",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdgsbase_writes_destination",
                target_operand = 1,
                role = "written with gs base by rdgsbase",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrfsbase",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "wrfsbase_updates_system_state",
                target_register = "rip",
                role = "wrote fs base by wrfsbase",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrgsbase",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "wrgsbase_updates_system_state",
                target_register = "rip",
                role = "wrote gs base by wrgsbase",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "swapgs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "swapgs_updates_system_state",
                target_register = "rip",
                role = "swapped gs base by swapgs",
            },
        }
,

    -- Model/control writes.
        {
            node_type = "instruction",
            mnemonic = "wrmsr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "wrmsr_updates_system_state",
                target_register = "rip",
                role = "wrote model-specific register by wrmsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsetbv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xsetbv_updates_system_state",
                target_register = "rip",
                role = "wrote extended control register by xsetbv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrpkru",
            operands = {},
            effect = {
                kind = "register_write",
                name = "wrpkru_updates_system_state",
                target_register = "rip",
                role = "wrote protection-key rights by wrpkru",
            },
        }
,

    -- Descriptor / control table writers.
        {
            node_type = "instruction",
            mnemonic = "lgdt",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lgdt_updates_system_state",
                target_register = "rip",
                role = "loaded global descriptor table register by lgdt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lidt",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lidt_updates_system_state",
                target_register = "rip",
                role = "loaded interrupt descriptor table register by lidt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lldt",
            operands = {
                { index = 1, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "lldt_updates_system_state",
                target_register = "rip",
                role = "loaded local descriptor table register by lldt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ltr",
            operands = {
                { index = 1, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "ltr_updates_system_state",
                target_register = "rip",
                role = "loaded task register by ltr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lmsw",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lmsw_updates_system_state",
                target_register = "rip",
                role = "loaded machine status word by lmsw",
            },
        }
,

    -- Invalidation / serialization / privilege-state helpers.
        {
            node_type = "instruction",
            mnemonic = "invd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "invd_invalidates_cache",
                target_register = "rip",
                role = "invalidated internal caches by invd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wbinvd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "wbinvd_writes_back_cache",
                target_register = "rip",
                role = "wrote back and invalidated caches by wbinvd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "serialize",
            operands = {},
            effect = {
                kind = "register_write",
                name = "serialize_serializes_execution",
                target_register = "rip",
                role = "serialized instruction execution by serialize",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cpuid",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cpuid_serializes_execution",
                target_register = "rip",
                role = "serialized instruction execution by cpuid",
            },
        }
,

    -- VMX/SVM virtualization instructions. Modeled as system-state/RFLAGS visibility.
        {
            node_type = "instruction",
            mnemonic = "vmcall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vmcall_updates_rip",
                target_register = "rip",
                role = "virtual machine call by vmcall",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmlaunch",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vmlaunch_updates_rip",
                target_register = "rip",
                role = "launched virtual machine by vmlaunch",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmresume",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vmresume_updates_rip",
                target_register = "rip",
                role = "resumed virtual machine by vmresume",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmxoff",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vmxoff_updates_system_state",
                target_register = "rip",
                role = "left vmx operation by vmxoff",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmxon",
            operands = {
                { index = 1, role = "vmxon_region" },
            },
            effect = {
                kind = "register_write",
                name = "vmxon_updates_system_state",
                target_register = "rip",
                role = "entered vmx operation by vmxon",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmclear",
            operands = {
                { index = 1, role = "vmcs_region" },
            },
            effect = {
                kind = "register_write",
                name = "vmclear_updates_rflags",
                target_register = "rflags",
                role = "updated by vmclear",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmptrld",
            operands = {
                { index = 1, role = "vmcs_region" },
            },
            effect = {
                kind = "register_write",
                name = "vmptrld_updates_rflags",
                target_register = "rflags",
                role = "updated by vmptrld",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmptrst",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "vmptrst_updates_system_state",
                target_register = "rip",
                role = "stored current vmcs pointer by vmptrst",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmread",
            operands = {
                { index = 1, role = "field" },
                { index = 2, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "vmread_writes_destination",
                target_operand = 2,
                role = "written with vmcs field by vmread",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmread",
            operands = {
                { index = 1, role = "field" },
                { index = 2, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "vmread_updates_rflags",
                target_register = "rflags",
                role = "updated by vmread",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmwrite",
            operands = {
                { index = 1, role = "source" },
                { index = 2, role = "field" },
            },
            effect = {
                kind = "register_write",
                name = "vmwrite_updates_rflags",
                target_register = "rflags",
                role = "updated by vmwrite",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "invept",
            operands = {
                { index = 1, role = "type" },
                { index = 2, role = "descriptor" },
            },
            effect = {
                kind = "register_write",
                name = "invept_updates_rflags",
                target_register = "rflags",
                role = "updated by invept",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "invvpid",
            operands = {
                { index = 1, role = "type" },
                { index = 2, role = "descriptor" },
            },
            effect = {
                kind = "register_write",
                name = "invvpid_updates_rflags",
                target_register = "rflags",
                role = "updated by invvpid",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "skinit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "skinit_updates_system_state",
                target_register = "rip",
                role = "secure initialization by skinit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "stgi",
            operands = {},
            effect = {
                kind = "register_write",
                name = "stgi_updates_system_state",
                target_register = "rflags",
                role = "global interrupt flag set by stgi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clgi",
            operands = {},
            effect = {
                kind = "register_write",
                name = "clgi_updates_system_state",
                target_register = "rflags",
                role = "global interrupt flag cleared by clgi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmload",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmload_updates_system_state",
                target_register = "rip",
                role = "loaded virtual machine control state by vmload",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "vmsave_updates_system_state",
                target_register = "rip",
                role = "saved virtual machine control state by vmsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmmcall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "vmmcall_updates_rip",
                target_register = "rip",
                role = "virtual machine monitor call by vmmcall",
            },
        }
,

    -- XSAVE / XRSTOR / FPU/SIMD state management.
        {
            node_type = "instruction",
            mnemonic = "fxsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fxsave_stores_processor_state",
                target_register = "rip",
                role = "saved fpu and simd state by fxsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxsave64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fxsave64_stores_processor_state",
                target_register = "rip",
                role = "saved 64-bit fpu and simd state by fxsave64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxrstor",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fxrstor_restores_processor_state",
                target_register = "rip",
                role = "restored fpu and simd state by fxrstor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxrstor64",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fxrstor64_restores_processor_state",
                target_register = "rip",
                role = "restored 64-bit fpu and simd state by fxrstor64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsave_stores_processor_state",
                target_register = "rip",
                role = "saved extended processor state by xsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsave64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsave64_stores_processor_state",
                target_register = "rip",
                role = "saved 64-bit extended processor state by xsave64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaveopt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaveopt_stores_processor_state",
                target_register = "rip",
                role = "optimally saved extended processor state by xsaveopt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaveopt64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaveopt64_stores_processor_state",
                target_register = "rip",
                role = "optimally saved 64-bit extended processor state by xsaveopt64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsavec",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsavec_stores_processor_state",
                target_register = "rip",
                role = "compacted saved extended processor state by xsavec",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsavec64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsavec64_stores_processor_state",
                target_register = "rip",
                role = "compacted saved 64-bit extended processor state by xsavec64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaves",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaves_stores_processor_state",
                target_register = "rip",
                role = "supervisor saved extended processor state by xsaves",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaves64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaves64_stores_processor_state",
                target_register = "rip",
                role = "supervisor saved 64-bit extended processor state by xsaves64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstor",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstor_restores_processor_state",
                target_register = "rip",
                role = "restored extended processor state by xrstor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstor64",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstor64_restores_processor_state",
                target_register = "rip",
                role = "restored 64-bit extended processor state by xrstor64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstors",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstors_restores_processor_state",
                target_register = "rip",
                role = "restored supervisor extended processor state by xrstors",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstors64",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstors64_restores_processor_state",
                target_register = "rip",
                role = "restored supervisor 64-bit extended processor state by xrstors64",
            },
        }
,

    -- MXCSR / x87 control-state helpers.
        {
            node_type = "instruction",
            mnemonic = "stmxcsr",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "stmxcsr_stores_control_state",
                target_register = "rip",
                role = "stored mxcsr by stmxcsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ldmxcsr",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "ldmxcsr_loads_control_state",
                target_register = "rip",
                role = "loaded mxcsr by ldmxcsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fstsw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstsw_stores_status_word",
                target_register = "rip",
                role = "stored x87 status word by fstsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnstsw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstsw_stores_status_word",
                target_register = "rip",
                role = "stored x87 status word by fnstsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fstsw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstsw_writes_register",
                target_operand = 1,
                role = "written with x87 status word by fstsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnstsw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstsw_writes_register",
                target_operand = 1,
                role = "written with x87 status word by fnstsw",
            },
        }
,

    -- x87 environment save/restore/init/clear.
        {
            node_type = "instruction",
            mnemonic = "finit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "finit_initializes_fpu",
                target_register = "rip",
                role = "initialized x87 fpu by finit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fninit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fninit_initializes_fpu",
                target_register = "rip",
                role = "initialized x87 fpu by fninit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fclex",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fclex_clears_exceptions",
                target_register = "rip",
                role = "cleared x87 exceptions by fclex",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnclex",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fnclex_clears_exceptions",
                target_register = "rip",
                role = "cleared x87 exceptions by fnclex",
            },
        }
,

    -- MMX state bridge.
        {
            node_type = "instruction",
            mnemonic = "emms",
            operands = {},
            effect = {
                kind = "register_write",
                name = "emms_updates_mmx_state",
                target_register = "rip",
                role = "emptied mmx state by emms",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "femms",
            operands = {},
            effect = {
                kind = "register_write",
                name = "femms_updates_mmx_state",
                target_register = "rip",
                role = "fast-emptied mmx state by femms",
            },
        }
,

    -- AVX / AVX2 visibility effects.
        -- Phase-one model: no vector register file yet, so most vector effects are exposed as RIP-side activity.
    
        {
            node_type = "instruction",
            mnemonic = "vmovaps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovaps_vector_move",
                target_register = "rip",
                role = "moved aligned packed single-precision values by vmovaps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovups",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovups_vector_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision values by vmovups",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovapd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovapd_vector_move",
                target_register = "rip",
                role = "moved aligned packed double-precision values by vmovapd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovupd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovupd_vector_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision values by vmovupd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqa",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqa_vector_move",
                target_register = "rip",
                role = "moved aligned packed integer values by vmovdqa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu_vector_move",
                target_register = "rip",
                role = "moved unaligned packed integer values by vmovdqu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqa32",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqa32_vector_move",
                target_register = "rip",
                role = "moved aligned packed doubleword integers by vmovdqa32",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqa64",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqa64_vector_move",
                target_register = "rip",
                role = "moved aligned packed quadword integers by vmovdqa64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu8",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu8_vector_move",
                target_register = "rip",
                role = "moved unaligned packed byte integers by vmovdqu8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu16",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu16_vector_move",
                target_register = "rip",
                role = "moved unaligned packed word integers by vmovdqu16",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu32",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu32_vector_move",
                target_register = "rip",
                role = "moved unaligned packed doubleword integers by vmovdqu32",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu64",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovdqu64_vector_move",
                target_register = "rip",
                role = "moved unaligned packed quadword integers by vmovdqu64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovss_scalar_vector_move",
                target_register = "rip",
                role = "moved scalar single-precision value by vmovss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovsd_scalar_vector_move",
                target_register = "rip",
                role = "moved scalar double-precision value by vmovsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntdq",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntdq_vector_store",
                target_register = "rip",
                role = "stored packed integer values non-temporally by vmovntdq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntdqa",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntdqa_vector_load",
                target_register = "rip",
                role = "loaded aligned packed integer values non-temporally by vmovntdqa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntps_vector_store",
                target_register = "rip",
                role = "stored packed single-precision values non-temporally by vmovntps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovntpd_vector_store",
                target_register = "rip",
                role = "stored packed double-precision values non-temporally by vmovntpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmulps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulps_vector_arithmetic",
                target_register = "rip",
                role = "multiplied packed single-precision values by vmulps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmulpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulpd_vector_arithmetic",
                target_register = "rip",
                role = "multiplied packed double-precision values by vmulpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmulss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulss_scalar_vector_arithmetic",
                target_register = "rip",
                role = "multiplied scalar single-precision values by vmulss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmulsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmulsd_scalar_vector_arithmetic",
                target_register = "rip",
                role = "multiplied scalar double-precision values by vmulsd",
            },
        }
,

    -- AVX min/max.
        {
            node_type = "instruction",
            mnemonic = "vmaxps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxps_vector_select",
                target_register = "rip",
                role = "selected packed single-precision maximum values by vmaxps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaxpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxpd_vector_select",
                target_register = "rip",
                role = "selected packed double-precision maximum values by vmaxpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaxss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxss_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar single-precision maximum value by vmaxss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaxsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vmaxsd_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar double-precision maximum value by vmaxsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vminps",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminps_vector_select",
                target_register = "rip",
                role = "selected packed single-precision minimum values by vminps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vminpd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminpd_vector_select",
                target_register = "rip",
                role = "selected packed double-precision minimum values by vminpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vminss",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminss_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar single-precision minimum value by vminss",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vminsd",
            operands = { { index = 1, role = "destination" }, { index = 2, role = "left" }, { index = 3, role = "right" } },
            effect = {
                kind = "register_write",
                name = "vminsd_scalar_vector_select",
                target_register = "rip",
                role = "selected scalar double-precision minimum value by vminsd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovmskps",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovmskps_writes_gpr",
                target_operand = 1,
                role = "written with packed single-precision sign mask by vmovmskps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovmskpd",
            operands = { { index = 1, kind = "register", role = "destination" }, { index = 2, role = "source" } },
            effect = {
                kind = "register_write",
                name = "vmovmskpd_writes_gpr",
                target_operand = 1,
                role = "written with packed double-precision sign mask by vmovmskpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaskmovps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmaskmovps_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed single-precision values by vmaskmovps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaskmovpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "mask" },
                { index = 3, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmaskmovpd_vector_mask_move",
                target_register = "rip",
                role = "masked moved packed double-precision values by vmaskmovpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmulph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vmulph_vector_fp16_arithmetic",
                target_register = "rip",
                role = "multiplied packed half-precision values by vmulph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmulsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vmulsh_scalar_fp16_arithmetic",
                target_register = "rip",
                role = "multiplied scalar half-precision values by vmulsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaxph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vmaxph_vector_fp16_select",
                target_register = "rip",
                role = "selected packed half-precision maximum values by vmaxph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmaxsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vmaxsh_scalar_fp16_select",
                target_register = "rip",
                role = "selected scalar half-precision maximum value by vmaxsh",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vminph",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vminph_vector_fp16_select",
                target_register = "rip",
                role = "selected packed half-precision minimum values by vminph",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vminsh",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "left" },
                { index = 3, role = "right" },
            },
            effect = {
                kind = "register_write",
                name = "vminsh_scalar_fp16_select",
                target_register = "rip",
                role = "selected scalar half-precision minimum value by vminsh",
            },
        }
,

    -- CET shadow-stack helpers.
    
        {
            node_type = "instruction",
            mnemonic = "rdsspd",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdsspd_writes_gpr",
                target_operand = 1,
                role = "written with 32-bit shadow stack pointer by rdsspd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdsspq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdsspq_writes_gpr",
                target_operand = 1,
                role = "written with 64-bit shadow stack pointer by rdsspq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrssd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "wrssd_updates_shadow_stack",
                target_register = "rip",
                role = "wrote 32-bit shadow stack memory by wrssd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrssq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "wrssq_updates_shadow_stack",
                target_register = "rip",
                role = "wrote 64-bit shadow stack memory by wrssq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrussd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "wrussd_updates_shadow_stack",
                target_register = "rip",
                role = "wrote 32-bit user shadow stack memory by wrussd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrussq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "wrussq_updates_shadow_stack",
                target_register = "rip",
                role = "wrote 64-bit user shadow stack memory by wrussq",
            },
        }
,

    -- User interrupt / low-latency interrupt helpers.
    
        {
            node_type = "instruction",
            mnemonic = "senduipi",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "senduipi_updates_user_interrupt_state",
                target_register = "rip",
                role = "sent user interprocessor interrupt by senduipi",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "uiret",
            operands = {},
            effect = {
                kind = "register_write",
                name = "uiret_updates_rip",
                target_register = "rip",
                role = "returned from user interrupt by uiret",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "monitorx",
            operands = {},
            effect = {
                kind = "register_write",
                name = "monitorx_updates_monitor_state",
                target_register = "rip",
                role = "armed extended monitor address by monitorx",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mwaitx",
            operands = {},
            effect = {
                kind = "register_write",
                name = "mwaitx_updates_wait_state",
                target_register = "rip",
                role = "entered extended monitor wait state by mwaitx",
            },
        }
,

    -- TSX load tracking.
    
        {
            node_type = "instruction",
            mnemonic = "xsusldtrk",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xsusldtrk_updates_transaction_state",
                target_register = "rip",
                role = "suspended transactional load tracking by xsusldtrk",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xresldtrk",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xresldtrk_updates_transaction_state",
                target_register = "rip",
                role = "resumed transactional load tracking by xresldtrk",
            },
        }
,

    -- AMD / x86_64 virtualization and platform helpers.
    
        {
            node_type = "instruction",
            mnemonic = "vmrun",
            operands = {
                { index = 1, role = "vmcb_address" },
            },
            effect = {
                kind = "register_write",
                name = "vmrun_updates_rip",
                target_register = "rip",
                role = "entered virtual machine by vmrun",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "invlpga",
            operands = {
                { index = 1, role = "address" },
                { index = 2, role = "asid" },
            },
            effect = {
                kind = "register_write",
                name = "invlpga_updates_translation_state",
                target_register = "rip",
                role = "invalidated guest TLB entry by invlpga",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpru",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpru_writes_rax",
                target_register = "rax",
                role = "written with processor register value low by rdpru",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpru",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpru_writes_rdx",
                target_register = "rdx",
                role = "written with processor register value high by rdpru",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "seamcall",
            operands = {},
            effect = {
                kind = "register_write",
                name = "seamcall_updates_rip",
                target_register = "rip",
                role = "called seam module by seamcall",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "seamret",
            operands = {},
            effect = {
                kind = "register_write",
                name = "seamret_updates_rip",
                target_register = "rip",
                role = "returned from seam module by seamret",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "seamops",
            operands = {},
            effect = {
                kind = "register_write",
                name = "seamops_updates_platform_state",
                target_register = "rip",
                role = "performed seam operation by seamops",
            },
        }
,

    -- Interrupt return aliases.
    
        {
            node_type = "instruction",
            mnemonic = "iretw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "iretw_updates_rip",
                target_register = "rip",
                role = "returned from word interrupt by iretw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "iretd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "iretd_updates_rip",
                target_register = "rip",
                role = "returned from doubleword interrupt by iretd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "iretq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "iretq_updates_rip",
                target_register = "rip",
                role = "returned from quadword interrupt by iretq",
            },
        }
,

    -- SGX / GETSEC / WAITPKG / platform-security / system-extension visibility effects.
        -- Phase-one model: most privileged/platform state is exposed as RIP-side activity.
    
        -- Intel SGX enclave instructions.
    
        {
            node_type = "instruction",
            mnemonic = "encls",
            operands = {},
            effect = {
                kind = "register_write",
                name = "encls_updates_enclave_state",
                target_register = "rip",
                role = "entered privileged sgx enclave instruction path by encls",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enclu",
            operands = {},
            effect = {
                kind = "register_write",
                name = "enclu_updates_enclave_state",
                target_register = "rip",
                role = "entered user sgx enclave instruction path by enclu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enclv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "enclv_updates_enclave_state",
                target_register = "rip",
                role = "entered virtualized sgx enclave instruction path by enclv",
            },
        }
,

    -- Intel GETSEC / measured launch helpers.
    
        {
            node_type = "instruction",
            mnemonic = "getsec",
            operands = {},
            effect = {
                kind = "register_write",
                name = "getsec_updates_security_state",
                target_register = "rip",
                role = "entered measured security operation by getsec",
            },
        }
,

    -- WAITPKG / timed wait helpers.
    
        {
            node_type = "instruction",
            mnemonic = "umonitor",
            operands = {
                { index = 1, role = "address" },
            },
            effect = {
                kind = "register_write",
                name = "umonitor_updates_wait_state",
                target_register = "rip",
                role = "armed user-mode monitor address by umonitor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "umwait",
            operands = {
                { index = 1, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "umwait_updates_wait_state",
                target_register = "rip",
                role = "entered user-mode wait state by umwait",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "tpause",
            operands = {
                { index = 1, role = "control" },
            },
            effect = {
                kind = "register_write",
                name = "tpause_updates_wait_state",
                target_register = "rip",
                role = "entered timed pause state by tpause",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpid",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdpid_writes_destination",
                target_operand = 1,
                role = "written with processor id by rdpid",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "invpcid",
            operands = {
                { index = 1, role = "descriptor" },
                { index = 2, role = "type" },
            },
            effect = {
                kind = "register_write",
                name = "invpcid_updates_translation_state",
                target_register = "rip",
                role = "invalidated process-context translations by invpcid",
            },
        }
,

    -- Platform configuration / entropy / firmware-ish helpers.
    
        {
            node_type = "instruction",
            mnemonic = "pconfig",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pconfig_updates_platform_state",
                target_register = "rip",
                role = "configured platform feature state by pconfig",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdrand",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdrand_updates_rflags",
                target_register = "rflags",
                role = "updated by hardware random value generation rdrand",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdseed",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdseed_updates_rflags",
                target_register = "rflags",
                role = "updated by hardware seed generation rdseed",
            },
        }
,

    -- Checkpoint 4.66 — AVX/VEX move, broadcast, extract, insert, and zeroing leftovers.
        -- VEX/AVX vector effects are exposed as RIP-side activity unless they write a GPR destination.
    
        {
            node_type = "instruction",
            mnemonic = "vmovaps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovaps_vector_move",
                target_register = "rip",
                role = "moved aligned packed single-precision value by vmovaps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovups",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovups_vector_move",
                target_register = "rip",
                role = "moved unaligned packed single-precision value by vmovups",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovapd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovapd_vector_move",
                target_register = "rip",
                role = "moved aligned packed double-precision value by vmovapd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovupd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovupd_vector_move",
                target_register = "rip",
                role = "moved unaligned packed double-precision value by vmovupd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqa",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqa_vector_move",
                target_register = "rip",
                role = "moved aligned packed integer value by vmovdqa",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu_vector_move",
                target_register = "rip",
                role = "moved unaligned packed integer value by vmovdqu",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqa32",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqa32_vector_move",
                target_register = "rip",
                role = "moved aligned packed doubleword integer value by vmovdqa32",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqa64",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqa64_vector_move",
                target_register = "rip",
                role = "moved aligned packed quadword integer value by vmovdqa64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu8",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu8_vector_move",
                target_register = "rip",
                role = "moved unaligned packed byte integer value by vmovdqu8",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu16",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu16_vector_move",
                target_register = "rip",
                role = "moved unaligned packed word integer value by vmovdqu16",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu32",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu32_vector_move",
                target_register = "rip",
                role = "moved unaligned packed doubleword integer value by vmovdqu32",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovdqu64",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovdqu64_vector_move",
                target_register = "rip",
                role = "moved unaligned packed quadword integer value by vmovdqu64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntps",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovntps_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed single-precision store by vmovntps",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntpd",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovntpd_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed double-precision store by vmovntpd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "vmovntdq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "vmovntdq_streaming_store",
                target_register = "rip",
                role = "performed non-temporal packed integer store by vmovntdq",
            },
        }
,

    -- Checkpoint 4.67 — Final system / serialization / privilege / descriptor leftover sweep.
        -- Phase-one model: system/control effects are exposed through RIP or the obvious architectural register.
    
        {
            node_type = "instruction",
            mnemonic = "cpuid",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rax",
                target_register = "rax",
                role = "written with processor identification leaf result by cpuid",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cpuid",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rbx",
                target_register = "rbx",
                role = "written with processor identification leaf result by cpuid",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cpuid",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rcx",
                target_register = "rcx",
                role = "written with processor identification leaf result by cpuid",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "cpuid",
            operands = {},
            effect = {
                kind = "register_write",
                name = "cpuid_writes_rdx",
                target_register = "rdx",
                role = "written with processor identification leaf result by cpuid",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "serialize",
            operands = {},
            effect = {
                kind = "register_write",
                name = "serialize_serializes_execution",
                target_register = "rip",
                role = "serialized instruction execution by serialize",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lfence",
            operands = {},
            effect = {
                kind = "register_write",
                name = "lfence_orders_loads",
                target_register = "rip",
                role = "ordered load operations by lfence",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sfence",
            operands = {},
            effect = {
                kind = "register_write",
                name = "sfence_orders_stores",
                target_register = "rip",
                role = "ordered store operations by sfence",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "mfence",
            operands = {},
            effect = {
                kind = "register_write",
                name = "mfence_orders_memory",
                target_register = "rip",
                role = "ordered memory operations by mfence",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clflush",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "clflush_flushes_cache_line",
                target_register = "rip",
                role = "flushed cache line by clflush",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clflushopt",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "clflushopt_flushes_cache_line",
                target_register = "rip",
                role = "flushed cache line with optimized ordering by clflushopt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "clwb",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "clwb_writes_back_cache_line",
                target_register = "rip",
                role = "wrote back cache line by clwb",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "invd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "invd_invalidates_cache",
                target_register = "rip",
                role = "invalidated internal caches by invd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wbinvd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "wbinvd_writes_back_and_invalidates_cache",
                target_register = "rip",
                role = "wrote back and invalidated caches by wbinvd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetchnta",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "prefetchnta_prefetches_memory",
                target_register = "rip",
                role = "prefetched memory with non-temporal locality by prefetchnta",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetcht0",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "prefetcht0_prefetches_memory",
                target_register = "rip",
                role = "prefetched memory into all cache levels by prefetcht0",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetcht1",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "prefetcht1_prefetches_memory",
                target_register = "rip",
                role = "prefetched memory with temporal locality hint T1 by prefetcht1",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "prefetcht2",
            operands = {
                { index = 1, role = "memory" },
            },
            effect = {
                kind = "register_write",
                name = "prefetcht2_prefetches_memory",
                target_register = "rip",
                role = "prefetched memory with temporal locality hint T2 by prefetcht2",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lgdt",
            operands = {
                { index = 1, role = "descriptor_table" },
            },
            effect = {
                kind = "register_write",
                name = "lgdt_loads_gdtr",
                target_register = "rip",
                role = "loaded global descriptor table register by lgdt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sgdt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sgdt_stores_gdtr",
                target_register = "rip",
                role = "stored global descriptor table register by sgdt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lidt",
            operands = {
                { index = 1, role = "descriptor_table" },
            },
            effect = {
                kind = "register_write",
                name = "lidt_loads_idtr",
                target_register = "rip",
                role = "loaded interrupt descriptor table register by lidt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sidt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sidt_stores_idtr",
                target_register = "rip",
                role = "stored interrupt descriptor table register by sidt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lldt",
            operands = {
                { index = 1, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "lldt_loads_ldtr",
                target_register = "rip",
                role = "loaded local descriptor table register by lldt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "sldt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "sldt_stores_ldtr",
                target_register = "rip",
                role = "stored local descriptor table register by sldt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ltr",
            operands = {
                { index = 1, role = "selector" },
            },
            effect = {
                kind = "register_write",
                name = "ltr_loads_task_register",
                target_register = "rip",
                role = "loaded task register by ltr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "str",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "str_stores_task_register",
                target_register = "rip",
                role = "stored task register by str",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "smsw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "smsw_stores_machine_status",
                target_register = "rip",
                role = "stored machine status word by smsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "lmsw",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "lmsw_loads_machine_status",
                target_register = "rip",
                role = "loaded machine status word by lmsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "swapgs",
            operands = {},
            effect = {
                kind = "register_write",
                name = "swapgs_swaps_gs_base",
                target_register = "rip",
                role = "swapped GS base with kernel GS base by swapgs",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "wrmsr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "wrmsr_writes_model_specific_register",
                target_register = "rip",
                role = "wrote model-specific register by wrmsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdmsr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdmsr_writes_rax",
                target_register = "rax",
                role = "written with model-specific register low value by rdmsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdmsr",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdmsr_writes_rdx",
                target_register = "rdx",
                role = "written with model-specific register high value by rdmsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpmc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpmc_writes_rax",
                target_register = "rax",
                role = "written with performance counter low value by rdpmc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdpmc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdpmc_writes_rdx",
                target_register = "rdx",
                role = "written with performance counter high value by rdpmc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdtsc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdtsc_writes_rax",
                target_register = "rax",
                role = "written with timestamp counter low value by rdtsc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdtsc",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdtsc_writes_rdx",
                target_register = "rdx",
                role = "written with timestamp counter high value by rdtsc",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdtscp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdtscp_writes_rax",
                target_register = "rax",
                role = "written with timestamp counter low value by rdtscp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdtscp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdtscp_writes_rdx",
                target_register = "rdx",
                role = "written with timestamp counter high value by rdtscp",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdtscp",
            operands = {},
            effect = {
                kind = "register_write",
                name = "rdtscp_writes_rcx",
                target_register = "rcx",
                role = "written with auxiliary timestamp value by rdtscp",
            },
        }
,

    -- Checkpoint 4.68 — Final SIMD state/control, random/platform, and oddball visibility leftovers.
    
        {
            node_type = "instruction",
            mnemonic = "rdrand",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdrand_writes_destination",
                target_operand = 1,
                role = "written with random value by rdrand",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdrand",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdrand_updates_rflags",
                target_register = "rflags",
                role = "updated with random-value availability status by rdrand",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdseed",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdseed_writes_destination",
                target_operand = 1,
                role = "written with random seed value by rdseed",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "rdseed",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "rdseed_updates_rflags",
                target_register = "rflags",
                role = "updated with random-seed availability status by rdseed",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xgetbv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xgetbv_writes_rax",
                target_register = "rax",
                role = "written with extended control register low value by xgetbv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xgetbv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xgetbv_writes_rdx",
                target_register = "rdx",
                role = "written with extended control register high value by xgetbv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsetbv",
            operands = {},
            effect = {
                kind = "register_write",
                name = "xsetbv_writes_extended_control_register",
                target_register = "rip",
                role = "wrote extended control register by xsetbv",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsave_saves_extended_state",
                target_register = "rip",
                role = "saved extended processor state by xsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsave64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsave64_saves_extended_state",
                target_register = "rip",
                role = "saved extended processor state by xsave64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaveopt",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaveopt_saves_extended_state",
                target_register = "rip",
                role = "saved optimized extended processor state by xsaveopt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaveopt64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaveopt64_saves_extended_state",
                target_register = "rip",
                role = "saved optimized extended processor state by xsaveopt64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsavec",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsavec_saves_compacted_extended_state",
                target_register = "rip",
                role = "saved compacted extended processor state by xsavec",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsavec64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsavec64_saves_compacted_extended_state",
                target_register = "rip",
                role = "saved compacted extended processor state by xsavec64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaves",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaves_saves_supervisor_extended_state",
                target_register = "rip",
                role = "saved supervisor extended processor state by xsaves",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xsaves64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "xsaves64_saves_supervisor_extended_state",
                target_register = "rip",
                role = "saved supervisor extended processor state by xsaves64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstor",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstor_restores_extended_state",
                target_register = "rip",
                role = "restored extended processor state by xrstor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstor64",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstor64_restores_extended_state",
                target_register = "rip",
                role = "restored extended processor state by xrstor64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstors",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstors_restores_supervisor_extended_state",
                target_register = "rip",
                role = "restored supervisor extended processor state by xrstors",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "xrstors64",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "xrstors64_restores_supervisor_extended_state",
                target_register = "rip",
                role = "restored supervisor extended processor state by xrstors64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "ldmxcsr",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "ldmxcsr_loads_mxcsr",
                target_register = "rip",
                role = "loaded MXCSR control/status register by ldmxcsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "stmxcsr",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "stmxcsr_stores_mxcsr",
                target_register = "rip",
                role = "stored MXCSR control/status register by stmxcsr",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxsave",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fxsave_saves_fpu_state",
                target_register = "rip",
                role = "saved x87 FPU/MMX/SSE state by fxsave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxsave64",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fxsave64_saves_fpu_state",
                target_register = "rip",
                role = "saved x87 FPU/MMX/SSE state by fxsave64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxrstor",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fxrstor_restores_fpu_state",
                target_register = "rip",
                role = "restored x87 FPU/MMX/SSE state by fxrstor",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fxrstor64",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "fxrstor64_restores_fpu_state",
                target_register = "rip",
                role = "restored x87 FPU/MMX/SSE state by fxrstor64",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "emms",
            operands = {},
            effect = {
                kind = "register_write",
                name = "emms_clears_mmx_state",
                target_register = "rip",
                role = "cleared MMX state by emms",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "femms",
            operands = {},
            effect = {
                kind = "register_write",
                name = "femms_clears_mmx_state",
                target_register = "rip",
                role = "cleared MMX state by femms",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fninit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fninit_initializes_fpu",
                target_register = "rip",
                role = "initialized x87 FPU state by fninit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "finit",
            operands = {},
            effect = {
                kind = "register_write",
                name = "finit_initializes_fpu",
                target_register = "rip",
                role = "initialized x87 FPU state by finit",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnclex",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fnclex_clears_fpu_exceptions",
                target_register = "rip",
                role = "cleared x87 FPU exceptions by fnclex",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fclex",
            operands = {},
            effect = {
                kind = "register_write",
                name = "fclex_clears_fpu_exceptions",
                target_register = "rip",
                role = "cleared x87 FPU exceptions by fclex",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fnstsw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fnstsw_stores_fpu_status",
                target_register = "rip",
                role = "stored x87 FPU status word by fnstsw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "fstsw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "fstsw_stores_fpu_status",
                target_register = "rip",
                role = "stored x87 FPU status word by fstsw",
            },
        }
,

    -- Linux x86-64 'syscall' clobbers rcx.
        {
            node_type = "instruction",
            mnemonic = "syscall",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "syscall_clobber_rcx",
                target_register = "rcx",
                role = "clobbered by Linux syscall",
                platform = "linux",
                abi = "linux_syscall",
            },
        }
,

    -- Linux x86-64 'syscall' clobbers r11.
        {
            node_type = "instruction",
            mnemonic = "syscall",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "syscall_clobber_r11",
                target_register = "r11",
                role = "clobbered by Linux syscall",
                platform = "linux",
                abi = "linux_syscall",
            },
        }
,

    -- Linux x86-64 'syscall' writes its return value to rax.
        {
            node_type = "instruction",
            mnemonic = "syscall",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "syscall_return_rax",
                target_register = "rax",
                role = "receives Linux syscall return value",
                platform = "linux",
                abi = "linux_syscall",
            },
        }
,
}
