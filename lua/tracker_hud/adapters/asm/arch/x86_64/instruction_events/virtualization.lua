-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/virtualization.lua
--
-- x86-64 instruction event specs: virtualization.
--
-- These events model VMX/SVM virtualization boundary/control actions.
-- They replace fake RIP register-effect visibility entries.

return {

    -- vmcall
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmcall",
        role = "performs a virtual machine call",

        node_type = "instruction",
        mnemonic = "vmcall",

        operands = {},

        event = {
            name = "vmcall_virtual_machine_call",
            display_name = "vmcall",
            role = "performs a virtual machine call",
        },

        effect = {
            kind = "virtualization_call",
            name = "vmcall_virtual_machine_call",
            role = "performs a virtual machine call",
        },
    },

    -- vmlaunch
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmlaunch",
        role = "launches a virtual machine",

        node_type = "instruction",
        mnemonic = "vmlaunch",

        operands = {},

        event = {
            name = "vmlaunch_launches_vm",
            display_name = "vmlaunch",
            role = "launches a virtual machine",
        },

        effect = {
            kind = "virtualization_entry",
            name = "vmlaunch_launches_vm",
            role = "launches a virtual machine",
        },
    },

    -- vmresume
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmresume",
        role = "resumes a virtual machine",

        node_type = "instruction",
        mnemonic = "vmresume",

        operands = {},

        event = {
            name = "vmresume_resumes_vm",
            display_name = "vmresume",
            role = "resumes a virtual machine",
        },

        effect = {
            kind = "virtualization_entry",
            name = "vmresume_resumes_vm",
            role = "resumes a virtual machine",
        },
    },

    -- vmxoff
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmxoff",
        role = "leaves VMX operation",

        node_type = "instruction",
        mnemonic = "vmxoff",

        operands = {},

        event = {
            name = "vmxoff_leaves_vmx_operation",
            display_name = "vmxoff",
            role = "leaves VMX operation",
        },

        effect = {
            kind = "virtualization_state_exit",
            name = "vmxoff_leaves_vmx_operation",
            role = "leaves VMX operation",
        },
    },

    -- vmxon
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmxon",
        role = "enters VMX operation",

        node_type = "instruction",
        mnemonic = "vmxon",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "vmxon_enters_vmx_operation",
            display_name = "vmxon",
            role = "enters VMX operation",
        },

        effect = {
            kind = "virtualization_state_enter",
            name = "vmxon_enters_vmx_operation",
            role = "enters VMX operation",
        },
    },

    -- vmptrst
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmptrst",
        role = "stores the current VMCS pointer",

        node_type = "instruction",
        mnemonic = "vmptrst",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "vmptrst_stores_vmcs_pointer",
            display_name = "vmptrst",
            role = "stores the current VMCS pointer",
        },

        effect = {
            kind = "virtualization_state_store",
            name = "vmptrst_stores_vmcs_pointer",
            role = "stores the current VMCS pointer",
        },
    },

    -- vmload
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmload",
        role = "loads virtual machine control state",

        node_type = "instruction",
        mnemonic = "vmload",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "vmload_loads_vm_control_state",
            display_name = "vmload",
            role = "loads virtual machine control state",
        },

        effect = {
            kind = "virtualization_state_load",
            name = "vmload_loads_vm_control_state",
            role = "loads virtual machine control state",
        },
    },

    -- vmsave
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmsave",
        role = "saves virtual machine control state",

        node_type = "instruction",
        mnemonic = "vmsave",

        operands = {
            { index = 1, role = "destination" },
        },

        event = {
            name = "vmsave_saves_vm_control_state",
            display_name = "vmsave",
            role = "saves virtual machine control state",
        },

        effect = {
            kind = "virtualization_state_save",
            name = "vmsave_saves_vm_control_state",
            role = "saves virtual machine control state",
        },
    },

    -- vmmcall
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmmcall",
        role = "performs a virtual machine monitor call",

        node_type = "instruction",
        mnemonic = "vmmcall",

        operands = {},

        event = {
            name = "vmmcall_virtual_machine_monitor_call",
            display_name = "vmmcall",
            role = "performs a virtual machine monitor call",
        },

        effect = {
            kind = "virtualization_call",
            name = "vmmcall_virtual_machine_monitor_call",
            role = "performs a virtual machine monitor call",
        },
    },

    -- vmrun
    {
        kind = "virtualization_event",
        category = "virtualization",
        name = "vmrun",
        role = "runs a virtual machine",

        node_type = "instruction",
        mnemonic = "vmrun",

        operands = {
            { index = 1, role = "source" },
        },

        event = {
            name = "vmrun_runs_virtual_machine",
            display_name = "vmrun",
            role = "runs a virtual machine",
        },

        effect = {
            kind = "virtualization_entry",
            name = "vmrun_runs_virtual_machine",
            role = "runs a virtual machine",
        },
    },
}
