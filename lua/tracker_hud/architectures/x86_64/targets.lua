-- lua/tracker_hud/architectures/x86_64/targets.lua
--
-- Language-independent target overlays for x86-64.
--
-- The CPU profile owns hardware facts in registers.lua. This module describes
-- platform/ABI conventions that sit on top of that hardware. Source-language
-- adapters may consume these facts, but must not redefine them.

local M = {}

M.platforms = {
    linux = {
        abi = "linux_syscall",
        function_abi = "sysv_amd64",
        status = "supported",
    },

    windows = {
        abi = "windows_x64",
        status = "declared",
    },

    darwin = {
        abi = "darwin_x86_64",
        function_abi = "sysv_amd64",
        status = "declared",
    },
}

M.default_platform = "linux"

M.platform_aliases = {
    linux = "linux",

    windows = "windows",
    win64 = "windows",

    darwin = "darwin",
    macos = "darwin",
    mac = "darwin",
}

M.calling_conventions = {
    sysv_amd64 = {
        kind = "function_call",
        platforms = {
            "linux",
            "darwin",
        },
        status = "described",
    },

    linux_syscall = {
        kind = "syscall",
        platform = "linux",

        number_register = "rax",
        return_register = "rax",

        argument_registers = {
            "rdi",
            "rsi",
            "rdx",
            "r10",
            "r8",
            "r9",
        },

        clobbers = {
            "rcx",
            "r11",
        },
    },

    windows_x64 = {
        kind = "function_call",
        platform = "windows",
        status = "declared",
    },

    darwin_x86_64 = {
        kind = "syscall",
        platform = "darwin",
        status = "declared",
    },
}

-- Static register-role overlays are target conventions, not CPU structure.
-- These preserve the established Linux/Darwin HUD wording while keeping the
-- hardware register profile language- and ABI-neutral.
M.register_roles = {
    sysv_amd64 = {
        rax = { role = "accumulator / return value", usage = "return_value" },
        rbx = { role = "callee-saved general register", usage = "callee_saved" },
        rcx = { role = "counter / argument register", usage = "argument" },
        rdx = { role = "data / argument register", usage = "argument" },
        rsi = { role = "source index / argument register", usage = "argument" },
        rdi = { role = "destination index / argument register", usage = "argument" },
        rbp = { role = "frame/base pointer", usage = "callee_saved" },
        r8  = { role = "argument / general register", usage = "argument" },
        r9  = { role = "argument / general register", usage = "argument" },
        r10 = { role = "temporary general register", usage = "caller_saved" },
        r11 = { role = "temporary general register", usage = "caller_saved" },
        r12 = { role = "callee-saved general register", usage = "callee_saved" },
        r13 = { role = "callee-saved general register", usage = "callee_saved" },
        r14 = { role = "callee-saved general register", usage = "callee_saved" },
        r15 = { role = "callee-saved general register", usage = "callee_saved" },
    },
}

return M
