-- tests/memory_address_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/memory_address_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local memory_address = require("tracker_hud.low_level.memory_address")

local normalized = assert(memory_address.normalize({
    kind = "memory",
    container_kind = "memory",
    address_kind = "address_expression",
    address_text = "rbp + rax*4 - 0x10",
    address_start_column = 10,
    address_end_column = 30,
    source_line = 7,
    address_mode = "default",
    address_size = {
        status = "known",
        bits = 32,
        source = "register_width",
        details = {
            registers = {
                {
                    register = "rbp",
                    register_bits = 32,
                    address_bits = 32,
                },
            },
        },
    },
    size = {
        prefix = "qword",
        bits = 64,
        label = "quadword",
    },
    components = {
        {
            text = "rbp",
            kind = "register",
            role = "frame pointer base",
            structural_role = "base_register",
            source_line = 7,
            source_start_line = 7,
            source_start_column = 10,
            source_end_line = 7,
            source_end_column = 13,
        },
        {
            text = "rax",
            kind = "register",
            role = "index_register",
            structural_role = "index_register",
            source_line = 7,
            source_start_line = 7,
            source_start_column = 16,
            source_end_line = 7,
            source_end_column = 19,
        },
        {
            text = "4",
            kind = "integer",
            role = "scale",
            structural_role = "scale",
            source_line = 7,
            source_start_line = 7,
            source_start_column = 20,
            source_end_line = 7,
            source_end_column = 21,
        },
        {
            text = "-0x10",
            kind = "integer",
            role = "displacement",
            structural_role = "displacement",
            source_line = 7,
            source_start_line = 7,
            source_start_column = 24,
            source_end_line = 7,
            source_end_column = 29,
        },
    },
}))

assert(normalized.version == 1
    and normalized.address_mode == "default"
    and normalized.memory_size_bits == 64
    and normalized.address_size_status == "known"
    and normalized.address_size_bits == 32
    and normalized.address_size_source == "register_width",
    "normalized memory header/address-size separation changed")
assert(normalized.base
    and normalized.base.name == "rbp"
    and normalized.base.role == "base_register"
    and normalized.base.display_role == "frame pointer base"
    and normalized.base.identity_known == true
    and normalized.base.value_status == "not_evaluated"
    and normalized.base.resolved == nil,
    "base register must separate structural identity from runtime value")
assert(normalized.index and normalized.index.name == "rax",
    "index register missing")
assert(normalized.scale
    and normalized.scale.value == "4"
    and normalized.scale.resolved == true,
    "scale must be exact")
assert(normalized.displacement
    and normalized.displacement.value == "-16"
    and normalized.displacement.resolved == true,
    "negative hexadecimal displacement must normalize exactly")
assert(normalized.metadata.effective_address == "unknown"
    and normalized.metadata.runtime_address == "unknown",
    "normalized address model must not invent runtime addresses")
print("PASS memory address: structural base/index/scale/displacement normalization")
print("PASS memory address: data width stays separate from address width")

local relative = assert(memory_address.normalize({
    address_text = "rel msg",
    address_mode = "relative",
    address_mode_token = "rel",
    components = {
        {
            text = "msg",
            kind = "symbol",
            role = "symbol",
            structural_role = "symbol",
        },
    },
}))

assert(relative.address_mode == "relative"
    and relative.address_mode_token == "rel"
    and relative.symbol
    and relative.symbol.name == "msg"
    and relative.symbol.identity_known == true
    and relative.symbol.value_status == "not_evaluated"
    and relative.symbol.resolved == nil,
    "relative symbol identity must not claim a runtime address")
print("PASS memory address: address mode and symbol stay separate")

local ambiguous = assert(memory_address.normalize({
    components = {
        { text = "rax", kind = "register", structural_role = "base_register" },
        { text = "rbx", kind = "register", structural_role = "base_register" },
    },
}))
assert(ambiguous.base and ambiguous.base.name == "rax"
    and ambiguous.metadata.ambiguous.base == true,
    "ambiguous structural fields must be marked rather than overwritten")
print("PASS memory address: ambiguous fields fail closed without data loss")

print("PASS Tracker_HUD normalized memory address smoke")
