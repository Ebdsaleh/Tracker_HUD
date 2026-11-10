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
        status = "supported",
    },

    windows = {
        abi = "windows_x64",
        status = "declared",
    },

    darwin = {
        abi = "darwin_x86_64",
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

return M
