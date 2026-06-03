-- lua/tracker_hud/adapters/asm_arch/x86_64.lua
--
-- x86-64 architecture facts for the ASM adapter.
--
-- Public architecture name uses "x86-64" to match common tooling such as
-- asm-lsp. Lua module name uses x86_64 because hyphens are awkward in module
-- paths.

local M = {}

M.name = "x86-64"
M.aliases = {
    "x86-64",
    "x86_64",
    "amd64",
    "x64",
}

M.registers = {
    static = {
        -- General purpose registers
        { name = "rax", kind = "general", role = "accumulator / return value" },
        { name = "rbx", kind = "general", role = "callee-saved general register" },
        { name = "rcx", kind = "general", role = "counter / argument register" },
        { name = "rdx", kind = "general", role = "data / argument register" },
        { name = "rsi", kind = "general", role = "source index / argument register" },
        { name = "rdi", kind = "general", role = "destination index / argument register" },
        { name = "r8", kind = "general", role = "argument / general register" },
        { name = "r9", kind = "general", role = "argument / general register" },
        { name = "r10", kind = "general", role = "temporary general register" },
        { name = "r11", kind = "general", role = "temporary general register" },
        { name = "r12", kind = "general", role = "callee-saved general register" },
        { name = "r13", kind = "general", role = "callee-saved general register" },
        { name = "r14", kind = "general", role = "callee-saved general register" },
        { name = "r15", kind = "general", role = "callee-saved general register" },

        -- Special registers
        { name = "rsp", kind = "stack_pointer", role = "stack pointer" },
        { name = "rbp", kind = "base_pointer", role = "frame/base pointer" },
        { name = "rip", kind = "instruction_pointer", role = "instruction pointer" },
        { name = "rflags", kind = "flags", role = "status/control flags" },
    },
}

M.stack = {
    static = {
        {
            name = "current frame",
            kind = "frame",
            role = "active stack frame",
            source = "architecture",
        },
        {
            name = "return address",
            kind = "return_address",
            role = "call return target stored on stack",
            source = "architecture",
        },
        {
            name = "stack pointer",
            kind = "stack_pointer",
            role = "top of stack tracked by rsp",
            source = "architecture",
        },
        {
            name = "base pointer",
            kind = "base_pointer",
            role = "frame base tracked by rbp when frame pointers are used",
            source = "architecture",
        },
    },
}

return M
