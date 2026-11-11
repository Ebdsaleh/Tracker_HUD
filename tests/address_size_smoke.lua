-- tests/address_size_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/address_size_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local address_size = require("tracker_hud.low_level.address_size")

local policy = {
    default_bits = 64,
    allowed_bits = { 32, 64 },
    register_width_map = {
        [32] = 32,
        [64] = 64,
    },
    prefixes = {
        a32 = 32,
        a64 = 64,
    },
}

local function register(name, role)
    return {
        text = name,
        kind = "register",
        structural_role = role,
    }
end

local widths = {
    rax = 64,
    rcx = 64,
    eax = 32,
    ecx = 32,
    ax = 16,
}

local function resolve(name)
    return widths[name]
end

local result = address_size.resolve(policy, {}, resolve)
assert(result.status == "known"
    and result.bits == 64
    and result.source == "default",
    "register-free address must use declared default width")
print("PASS address size: register-free address uses default width")

result = address_size.resolve(policy, {
    register("rax", "base_register"),
    register("rcx", "index_register"),
}, resolve)
assert(result.status == "known"
    and result.bits == 64
    and result.source == "register_width"
    and #result.details.registers == 2,
    "64-bit address registers must resolve 64-bit address size")
print("PASS address size: 64-bit register addressing")

result = address_size.resolve(policy, {
    register("eax", "base_register"),
    register("ecx", "index_register"),
}, resolve)
assert(result.status == "known"
    and result.bits == 32
    and result.source == "register_width",
    "32-bit address registers must resolve 32-bit address size")
print("PASS address size: 32-bit register addressing")

result = address_size.resolve(
    policy,
    {},
    resolve,
    {
        explicit_bits = 32,
        explicit_prefix = "a32",
    }
)
assert(result.status == "known"
    and result.bits == 32
    and result.source == "explicit_prefix"
    and result.details.prefix == "a32",
    "explicit A32 must select 32-bit address size")
print("PASS address size: explicit prefix selects address width")

result = address_size.resolve(
    policy,
    {
        register("rax", "base_register"),
    },
    resolve,
    {
        explicit_bits = 32,
        explicit_prefix = "a32",
    }
)
assert(result.status == "unknown"
    and result.reason == "address-size prefix conflicts with registers",
    "explicit address size must conflict with incompatible register width")
print("PASS address size: explicit prefix/register conflict fails closed")

result = address_size.resolve(
    policy,
    {},
    resolve,
    {
        explicit_error = "conflicting explicit address-size prefixes",
        explicit_prefixes = { "a32", "a64" },
    }
)
assert(result.status == "unknown"
    and result.reason == "conflicting explicit address-size prefixes",
    "conflicting source prefixes must fail closed")
print("PASS address size: conflicting explicit prefixes fail closed")

result = address_size.resolve(policy, {
    register("rax", "base_register"),
    register("ecx", "index_register"),
}, resolve)
assert(result.status == "unknown"
    and result.reason == "mixed address register widths",
    "mixed 32/64-bit address registers must fail closed")
print("PASS address size: mixed register widths fail closed")

result = address_size.resolve(policy, {
    register("ax", "base_register"),
}, resolve)
assert(result.status == "unknown"
    and result.reason == "unsupported address register width"
    and result.details.register_bits == 16,
    "unsupported address-register width must fail closed")
print("PASS address size: unsupported register width fails closed")

result = address_size.resolve(policy, {
    register("mystery", "base_register"),
}, resolve)
assert(result.status == "unknown"
    and result.reason == "address register width unavailable",
    "unknown register width must fail closed")
print("PASS address size: unknown register width fails closed")

print("PASS Tracker_HUD address-size smoke")
