-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/virtualization/vmx.lua
--
-- x86-64 instruction events: virtualization / vmx.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["vmcall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmcall",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmcall",
            role = "performs a virtual machine call",

            operands = {
            },

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
    },

    ["vmlaunch"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmlaunch",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmlaunch",
            role = "launches a virtual machine",

            operands = {
            },

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
    },

    ["vmresume"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmresume",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmresume",
            role = "resumes a virtual machine",

            operands = {
            },

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
    },

    ["vmxoff"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmxoff",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmxoff",
            role = "leaves VMX operation",

            operands = {
            },

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
    },

    ["vmxon"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmxon",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmxon",
            role = "enters VMX operation",

            operands = {
                { index = 1, role = "source", },
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
    },

    ["vmptrst"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmptrst",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmptrst",
            role = "stores the current VMCS pointer",

            operands = {
                { index = 1, role = "destination", },
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
    },
}

