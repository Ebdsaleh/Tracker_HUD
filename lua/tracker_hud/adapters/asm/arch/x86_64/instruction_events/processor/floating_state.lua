-- lua/tracker_hud/adapters/asm/arch/x86_64/instruction_events/processor/floating_state.lua
--
-- x86-64 instruction events: processor / floating state.
--
-- Tree-sitter-first, mnemonic-indexed event specifications.
--
-- Tree-sitter identifies the instruction and mnemonic syntax first.
-- x86-64 / Tracker_HUD event semantics are layered onto that syntax.

return {
    ["fxsave"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fxsave",
                    },
                },
            },

            kind = "processor_state_event",
            category = "fpu_simd_state",
            name = "fxsave",
            role = "saves x87 FPU, MMX, and SSE state",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "fxsave_saves_fpu_simd_state",
                display_name = "fxsave",
                role = "saves x87 FPU, MMX, and SSE state",
            },

            effect = {
                kind = "processor_state_save",
                name = "fxsave_saves_fpu_simd_state",
                role = "saves x87 FPU, MMX, and SSE state",
            },
        },
    },

    ["fxsave64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fxsave64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "fpu_simd_state",
            name = "fxsave64",
            role = "saves x87 FPU, MMX, and SSE state in 64-bit mode",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "fxsave64_saves_fpu_simd_state",
                display_name = "fxsave64",
                role = "saves x87 FPU, MMX, and SSE state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_save",
                name = "fxsave64_saves_fpu_simd_state",
                role = "saves x87 FPU, MMX, and SSE state in 64-bit mode",
            },
        },
    },

    ["fxrstor"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fxrstor",
                    },
                },
            },

            kind = "processor_state_event",
            category = "fpu_simd_state",
            name = "fxrstor",
            role = "restores x87 FPU, MMX, and SSE state",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "fxrstor_restores_fpu_simd_state",
                display_name = "fxrstor",
                role = "restores x87 FPU, MMX, and SSE state",
            },

            effect = {
                kind = "processor_state_restore",
                name = "fxrstor_restores_fpu_simd_state",
                role = "restores x87 FPU, MMX, and SSE state",
            },
        },
    },

    ["fxrstor64"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fxrstor64",
                    },
                },
            },

            kind = "processor_state_event",
            category = "fpu_simd_state",
            name = "fxrstor64",
            role = "restores x87 FPU, MMX, and SSE state in 64-bit mode",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "fxrstor64_restores_fpu_simd_state",
                display_name = "fxrstor64",
                role = "restores x87 FPU, MMX, and SSE state in 64-bit mode",
            },

            effect = {
                kind = "processor_state_restore",
                name = "fxrstor64_restores_fpu_simd_state",
                role = "restores x87 FPU, MMX, and SSE state in 64-bit mode",
            },
        },
    },

    ["ldmxcsr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "ldmxcsr",
                    },
                },
            },

            kind = "processor_state_event",
            category = "mxcsr_state",
            name = "ldmxcsr",
            role = "loads MXCSR control and status state",

            operands = {
                { index = 1, role = "source", },
            },

            event = {
                name = "ldmxcsr_loads_mxcsr",
                display_name = "ldmxcsr",
                role = "loads MXCSR control and status state",
            },

            effect = {
                kind = "mxcsr_state_load",
                name = "ldmxcsr_loads_mxcsr",
                role = "loads MXCSR control and status state",
            },
        },
    },

    ["stmxcsr"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "stmxcsr",
                    },
                },
            },

            kind = "processor_state_event",
            category = "mxcsr_state",
            name = "stmxcsr",
            role = "stores MXCSR control and status state",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "stmxcsr_stores_mxcsr",
                display_name = "stmxcsr",
                role = "stores MXCSR control and status state",
            },

            effect = {
                kind = "mxcsr_state_store",
                name = "stmxcsr_stores_mxcsr",
                role = "stores MXCSR control and status state",
            },
        },
    },

    ["emms"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "emms",
                    },
                },
            },

            kind = "processor_state_event",
            category = "mmx_state",
            name = "emms",
            role = "clears MMX state",

            operands = {
            },

            event = {
                name = "emms_clears_mmx_state",
                display_name = "emms",
                role = "clears MMX state",
            },

            effect = {
                kind = "mmx_state_clear",
                name = "emms_clears_mmx_state",
                role = "clears MMX state",
            },
        },
    },

    ["femms"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "femms",
                    },
                },
            },

            kind = "processor_state_event",
            category = "mmx_state",
            name = "femms",
            role = "clears MMX state using fast EMMS",

            operands = {
            },

            event = {
                name = "femms_clears_mmx_state",
                display_name = "femms",
                role = "clears MMX state using fast EMMS",
            },

            effect = {
                kind = "mmx_state_clear",
                name = "femms_clears_mmx_state",
                role = "clears MMX state using fast EMMS",
            },
        },
    },

    ["fninit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fninit",
                    },
                },
            },

            kind = "processor_state_event",
            category = "x87_state",
            name = "fninit",
            role = "initializes x87 FPU state without checking pending exceptions",

            operands = {
            },

            event = {
                name = "fninit_initializes_fpu_state",
                display_name = "fninit",
                role = "initializes x87 FPU state without checking pending exceptions",
            },

            effect = {
                kind = "x87_state_init",
                name = "fninit_initializes_fpu_state",
                role = "initializes x87 FPU state without checking pending exceptions",
            },
        },
    },

    ["finit"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "finit",
                    },
                },
            },

            kind = "processor_state_event",
            category = "x87_state",
            name = "finit",
            role = "initializes x87 FPU state",

            operands = {
            },

            event = {
                name = "finit_initializes_fpu_state",
                display_name = "finit",
                role = "initializes x87 FPU state",
            },

            effect = {
                kind = "x87_state_init",
                name = "finit_initializes_fpu_state",
                role = "initializes x87 FPU state",
            },
        },
    },

    ["fnclex"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fnclex",
                    },
                },
            },

            kind = "processor_state_event",
            category = "x87_state",
            name = "fnclex",
            role = "clears x87 FPU exception flags without checking pending exceptions",

            operands = {
            },

            event = {
                name = "fnclex_clears_fpu_exceptions",
                display_name = "fnclex",
                role = "clears x87 FPU exception flags without checking pending exceptions",
            },

            effect = {
                kind = "x87_exception_clear",
                name = "fnclex_clears_fpu_exceptions",
                role = "clears x87 FPU exception flags without checking pending exceptions",
            },
        },
    },

    ["fclex"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fclex",
                    },
                },
            },

            kind = "processor_state_event",
            category = "x87_state",
            name = "fclex",
            role = "clears x87 FPU exception flags",

            operands = {
            },

            event = {
                name = "fclex_clears_fpu_exceptions",
                display_name = "fclex",
                role = "clears x87 FPU exception flags",
            },

            effect = {
                kind = "x87_exception_clear",
                name = "fclex_clears_fpu_exceptions",
                role = "clears x87 FPU exception flags",
            },
        },
    },

    ["fnstsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fnstsw",
                    },
                },
            },

            kind = "processor_state_event",
            category = "x87_state",
            name = "fnstsw",
            role = "stores x87 FPU status word without checking pending exceptions",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "fnstsw_stores_status_word",
                display_name = "fnstsw",
                role = "stores x87 FPU status word without checking pending exceptions",
            },

            effect = {
                kind = "x87_status_store",
                name = "fnstsw_stores_status_word",
                role = "stores x87 FPU status word without checking pending exceptions",
            },
        },
    },

    ["fstsw"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "fstsw",
                    },
                },
            },

            kind = "processor_state_event",
            category = "x87_state",
            name = "fstsw",
            role = "stores x87 FPU status word",

            operands = {
                { index = 1, role = "destination", },
            },

            event = {
                name = "fstsw_stores_status_word",
                display_name = "fstsw",
                role = "stores x87 FPU status word",
            },

            effect = {
                kind = "x87_status_store",
                name = "fstsw_stores_status_word",
                role = "stores x87 FPU status word",
            },
        },
    },
}

