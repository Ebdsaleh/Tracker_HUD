-- lua/tracker_hud/adapters/asm/arch/x86_64/boundary_effects/system_calls.lua
--
-- x86-64 system-call boundary effects.
--
-- Tree-sitter-first, mnemonic-indexed boundary-effect specs.

return {
    ["syscall"] = {
        {
            syntax = {
                node_type = "instruction",

                fields = {
                    kind = {
                        field = "kind",
                        node_type = "word",
                        text = "syscall",
                    },
                },
            },

            kind = "syscall",
            category = "system",
            platform = "linux",
            abi = "linux_syscall",

            reads = {
                number_register = "rax",
                argument_registers = {
                    "rdi",
                    "rsi",
                    "rdx",
                    "r10",
                    "r8",
                    "r9",
                },
            },

            writes = {
                return_register = "rax",
            },

            not_preserved = {
                registers = {
                    "rcx",
                    "r11",
                },
            },

            known_effects = {
                ["0"] = {
                    name = "read",
                    category = "io",
                    required_arguments = { 1, 2, 3 },
                    argument_names = {
                        [1] = "fd",
                        [2] = "buf",
                        [3] = "count",
                    },
                },

                ["1"] = {
                    name = "write",
                    category = "io",
                    required_arguments = { 1, 2, 3 },
                    argument_names = {
                        [1] = "fd",
                        [2] = "buf",
                        [3] = "count",
                    },
                },

                ["9"] = {
                    name = "mmap",
                    category = "heap",
                    produces = {
                        kind = "memory_region",
                        result_register = "rax",
                    },

                    required_arguments = { 1, 2, 3, 4, 5, 6 },
                    argument_names = {
                        [1] = "addr",
                        [2] = "length",
                        [3] = "prot",
                        [4] = "flags",
                        [5] = "fd",
                        [6] = "offset",
                    },
                },

                ["11"] = {
                    name = "munmap",
                    category = "heap",
                    consumes = {
                        pointer_register = "rdi",
                        size_register = "rsi",
                    },

                    required_arguments = { 1, 2 },
                    argument_names = {
                        [1] = "addr",
                        [2] = "length",
                    },
                },

                ["12"] = {
                    name = "brk",
                    category = "heap",
                    required_arguments = { 1 },
                    argument_names = {
                        [1] = "addr",
                    },
                },

                ["60"] = {
                    name = "exit",
                    category = "process",
                    required_arguments = { 1 },
                    argument_names = {
                        [1] = "status",
                    },
                },
            },
        },
    },
}

