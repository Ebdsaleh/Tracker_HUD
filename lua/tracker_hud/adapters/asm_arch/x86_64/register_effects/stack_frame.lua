-- lua/tracker_hud/adapters/asm_arch/x86_64/register_effects/stack_frame.lua
--
-- x86-64 stack frame register effect specs.

return {

    -- 'pushfq' pushes rflags onto the stack and decreases rsp.
        {
            node_type = "instruction",
            mnemonic = "pushfq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "pushfq_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by pushfq",
            },
        }
,

    -- 'popfq' pops rflags from the stack and increases rsp.
        {
            node_type = "instruction",
            mnemonic = "popfq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "popfq_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by popfq",
            },
        }
,

    -- 'popfq' restores rflags from the stack.
        {
            node_type = "instruction",
            mnemonic = "popfq",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "popfq_updates_rflags",
                target_register = "rflags",
                role = "restored from stack by popfq",
            },
        }
,

    -- 'pushf' pushes flags onto the stack and decreases rsp.
        {
            node_type = "instruction",
            mnemonic = "pushf",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "pushf_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by pushf",
            },
        }
,

    -- 'popf' pops flags from the stack and increases rsp.
        {
            node_type = "instruction",
            mnemonic = "popf",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "popf_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by popf",
            },
        }
,

    -- 'popf' restores rflags from the stack.
        {
            node_type = "instruction",
            mnemonic = "popf",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "popf_updates_rflags",
                target_register = "rflags",
                role = "restored from stack by popf",
            },
        }
,

    -- 'popcnt reg, value' writes the population count to the destination register.
        {
            node_type = "instruction",
            mnemonic = "popcnt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcnt_writes_destination",
                target_operand = 1,
                role = "written with population count by popcnt",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popcnt",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcnt_updates_rflags",
                target_register = "rflags",
                role = "updated by popcnt",
            },
        }
,

    -- Frame/control-transfer helpers.
        {
            node_type = "instruction",
            mnemonic = "enter",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enter_updates_rsp",
                target_register = "rsp",
                role = "changed by stack frame entry enter",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enter",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enter_updates_rbp",
                target_register = "rbp",
                role = "established frame base by enter",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leave",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leave_updates_rsp",
                target_register = "rsp",
                role = "restored stack pointer by leave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leave",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leave_updates_rbp",
                target_register = "rbp",
                role = "restored frame base by leave",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popa",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popa_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all popa",
                value_delta = 32,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popad",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popad_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all doubleword popad",
                value_delta = 32,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popal",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popal_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all long popal",
                value_delta = 32,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popaw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popaw_increases_rsp",
                target_register = "rsp",
                role = "increased by legacy pop-all word popaw",
                value_delta = 16,
            },
        }
,

    -- Legacy flags aliases.
    
        {
            node_type = "instruction",
            mnemonic = "pushfd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pushfd_decreases_rsp",
                target_register = "rsp",
                role = "decreased by push flags doubleword pushfd",
                value_delta = -4,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pushfw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "pushfw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by push flags word pushfw",
                value_delta = -2,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popfd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popfd_increases_rsp",
                target_register = "rsp",
                role = "increased by pop flags doubleword popfd",
                value_delta = 4,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popfd",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popfd_updates_rflags",
                target_register = "rflags",
                role = "restored by pop flags doubleword popfd",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popfw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popfw_increases_rsp",
                target_register = "rsp",
                role = "increased by pop flags word popfw",
                value_delta = 2,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popfw",
            operands = {},
            effect = {
                kind = "register_write",
                name = "popfw_updates_rflags",
                target_register = "rflags",
                role = "restored by pop flags word popfw",
            },
        }
,

    -- Push aliases.
    
        {
            node_type = "instruction",
            mnemonic = "pushq",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pushq_decreases_rsp",
                target_register = "rsp",
                role = "decreased by quadword push pushq",
                value_delta = -8,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pushl",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pushl_decreases_rsp",
                target_register = "rsp",
                role = "decreased by long push pushl",
                value_delta = -4,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "pushw",
            operands = {
                { index = 1, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "pushw_decreases_rsp",
                target_register = "rsp",
                role = "decreased by word push pushw",
                value_delta = -2,
            },
        }
,

    -- Pop aliases.
    
        {
            node_type = "instruction",
            mnemonic = "popq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popq_writes_destination",
                target_operand = 1,
                role = "written by quadword pop popq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popq",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popq_increases_rsp",
                target_register = "rsp",
                role = "increased by quadword pop popq",
                value_delta = 8,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popl_writes_destination",
                target_operand = 1,
                role = "written by long pop popl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popl",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popl_increases_rsp",
                target_register = "rsp",
                role = "increased by long pop popl",
                value_delta = 4,
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popw_writes_destination",
                target_operand = 1,
                role = "written by word pop popw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popw",
            operands = {
                { index = 1, role = "destination" },
            },
            effect = {
                kind = "register_write",
                name = "popw_increases_rsp",
                target_register = "rsp",
                role = "increased by word pop popw",
                value_delta = 2,
            },
        }
,

    -- Leave aliases.
    
        {
            node_type = "instruction",
            mnemonic = "leaveq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leaveq_restores_rsp",
                target_register = "rsp",
                role = "restored from frame pointer by leaveq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leaveq",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leaveq_restores_rbp",
                target_register = "rbp",
                role = "restored by frame teardown leaveq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leavel",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leavel_restores_rsp",
                target_register = "rsp",
                role = "restored from frame pointer by leavel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leavel",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leavel_restores_rbp",
                target_register = "rbp",
                role = "restored by frame teardown leavel",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leavew",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leavew_restores_rsp",
                target_register = "rsp",
                role = "restored from frame pointer by leavew",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "leavew",
            operands = {},
            effect = {
                kind = "register_write",
                name = "leavew_restores_rbp",
                target_register = "rbp",
                role = "restored by frame teardown leavew",
            },
        }
,

    -- Enter aliases.
    
        {
            node_type = "instruction",
            mnemonic = "enterq",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterq_updates_rsp",
                target_register = "rsp",
                role = "updated by quadword stack frame setup enterq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enterq",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterq_updates_rbp",
                target_register = "rbp",
                role = "updated by quadword stack frame setup enterq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enterl",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterl_updates_rsp",
                target_register = "rsp",
                role = "updated by long stack frame setup enterl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enterl",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterl_updates_rbp",
                target_register = "rbp",
                role = "updated by long stack frame setup enterl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enterw",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterw_updates_rsp",
                target_register = "rsp",
                role = "updated by word stack frame setup enterw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "enterw",
            operands = {
                { index = 1, role = "frame_size" },
                { index = 2, role = "nesting_level" },
            },
            effect = {
                kind = "register_write",
                name = "enterw_updates_rbp",
                target_register = "rbp",
                role = "updated by word stack frame setup enterw",
            },
        }
,

    -- POPCNT suffix aliases.
    
        {
            node_type = "instruction",
            mnemonic = "popcntw",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntw_writes_destination",
                target_operand = 1,
                role = "written with word population count by popcntw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popcntw",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntw_updates_rflags",
                target_register = "rflags",
                role = "updated by word population count popcntw",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popcntl",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntl_writes_destination",
                target_operand = 1,
                role = "written with long population count by popcntl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popcntl",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntl_updates_rflags",
                target_register = "rflags",
                role = "updated by long population count popcntl",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popcntq",
            operands = {
                { index = 1, kind = "register", role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntq_writes_destination",
                target_operand = 1,
                role = "written with quadword population count by popcntq",
            },
        }
,

    {
            node_type = "instruction",
            mnemonic = "popcntq",
            operands = {
                { index = 1, role = "destination" },
                { index = 2, role = "source" },
            },
            effect = {
                kind = "register_write",
                name = "popcntq_updates_rflags",
                target_register = "rflags",
                role = "updated by quadword population count popcntq",
            },
        }
,

    -- 'pop reg' writes an unknown stack value into the destination register.
        {
            node_type = "instruction",
            mnemonic = "pop",
    
            operands = {
                {
                    index = 1,
                    kind = "register",
                    role = "destination",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "pop_register_unknown",
                target_operand = 1,
                role = "loaded from stack by pop",
            },
        }
,

    -- 'push' decreases rsp.
        {
            node_type = "instruction",
            mnemonic = "push",
            operands = {
                {
                    index = 1,
                    role = "pushed_value",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "push_updates_rsp",
                target_register = "rsp",
                value_delta = -8,
                role = "decreased by push",
            },
        }
,

    -- 'pop' increases rsp.
        {
            node_type = "instruction",
            mnemonic = "pop",
    
            operands = {
                {
                    index = 1,
                    role = "destination",
                },
            },
    
            effect = {
                kind = "register_write",
                name = "pop_updates_rsp",
                target_register = "rsp",
                value_delta = 8,
                role = "increased by pop",
            },
        }
,

    -- 'leave' restores rsp from rbp.
        {
            node_type = "instruction",
            mnemonic = "leave",
            
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "leave_restores_rsp",
                target_register = "rsp",
                value_from_register = "rbp",
                role = "restored stack pointer from  frame base by leave",
            },
        }
,

    -- 'leave' pops the previous frame pointer into rbp.
        {
            node_type = "instruction",
            mnemonic = "leave",
    
            operands = {},
    
            effect = {
                kind = "register_write",
                name = "leave_restores_rbp",
                target_register = "rbp",
                role = "loaded previous frame base from stack by leave",
            },
        }
,
}
