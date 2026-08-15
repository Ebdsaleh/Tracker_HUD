-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/virtualization/svm.lua
--
-- x86-64 instruction events: virtualization / svm.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["vmload"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmload",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmload",
            role = "loads virtual machine control state",

            operands = {
                { index = 1, role = "source", },
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
    },

    ["vmsave"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmsave",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmsave",
            role = "saves virtual machine control state",

            operands = {
                { index = 1, role = "destination", },
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
    },

    ["vmmcall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmmcall",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmmcall",
            role = "performs a virtual machine monitor call",

            operands = {
            },

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
    },

    ["vmrun"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "vmrun",
                    },
                },
            },

            kind = "virtualization_event",
            category = "virtualization",
            name = "vmrun",
            role = "runs a virtual machine",

            operands = {
                { index = 1, role = "source", },
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
    },
}

