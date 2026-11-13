-- tests/relative_address_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/relative_address_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local evaluator = require("tracker_hud.low_level.relative_address")

local function relative_symbol(name, displacement)
    return {
        address_mode = "relative",
        address_size_status = "known",
        address_size_bits = 32,
        symbol = {
            name = name,
        },
        displacement = displacement and {
            text = tostring(displacement),
            value = tostring(displacement),
        } or nil,
        metadata = {
            ambiguous = {},
        },
    }
end

local evidence = {
    next_instruction = {
        status = "known",
        value = "0x100000107",
        bits = 64,
    },
    symbol = {
        status = "known",
        value = "0x100001000",
        bits = 64,
    },
}

local resolved = evaluator.evaluate(
    relative_symbol("msg"),
    evidence,
    {
        bits = 64,
    }
)

assert(resolved.status == "known"
    and resolved.value == "4294971392"
    and resolved.bits == 64
    and resolved.wrapped == false
    and resolved.components.basis.value == "4294967559"
    and resolved.components.symbol.value == "4294971392"
    and resolved.components.source_displacement == "0"
    and resolved.components.relative_delta == "3833"
    and resolved.components.exact_target == "4294971392",
    "REL symbol must resolve from proven next-instruction and symbol addresses")
print("PASS relative address: proven REL symbol target resolves exactly")

assert(resolved.value ~= "4096"
    and resolved.value > "4294967295",
    "A32 source structure must not truncate the 64-bit machine target")
print("PASS relative address: A32 source width stays separate from machine width")

local displaced = evaluator.evaluate(
    relative_symbol("msg", 8),
    evidence,
    {
        bits = 64,
    }
)

assert(displaced.status == "known"
    and displaced.value == "4294971400"
    and displaced.components.source_displacement == "8"
    and displaced.components.relative_delta == "3841",
    "REL symbol plus exact source displacement must preserve exact arithmetic")
print("PASS relative address: symbol displacement contributes to target")

local missing_basis = evaluator.evaluate(
    relative_symbol("msg"),
    {
        next_instruction = {
            status = "unknown",
            reason = "listing omitted next address",
        },
        symbol = evidence.symbol,
    },
    {
        bits = 64,
    }
)

assert(missing_basis.status == "unknown"
    and missing_basis.reason
        == "next-instruction machine address unresolved",
    "REL target must fail closed without a proven next-instruction basis")
print("PASS relative address: missing next-instruction basis fails closed")

local missing_symbol = evaluator.evaluate(
    relative_symbol("msg"),
    {
        next_instruction = evidence.next_instruction,
        symbol = {
            status = "unknown",
            reason = "symbol absent from map",
        },
    },
    {
        bits = 64,
    }
)

assert(missing_symbol.status == "unknown"
    and missing_symbol.reason
        == "symbol machine address unresolved",
    "REL target must fail closed without a proven symbol address")
print("PASS relative address: missing symbol machine address fails closed")

local width_mismatch = evaluator.evaluate(
    relative_symbol("msg"),
    {
        next_instruction = {
            status = "known",
            value = "0x1000",
            bits = 64,
        },
        symbol = {
            status = "known",
            value = "0x2000",
            bits = 32,
        },
    },
    {
        bits = 64,
    }
)

assert(width_mismatch.status == "unknown"
    and width_mismatch.reason
        == "machine address width mismatch",
    "conflicting machine-address widths must fail closed")
print("PASS relative address: machine width mismatch fails closed")

local numeric_only = evaluator.evaluate({
    address_mode = "relative",
    address_size_status = "known",
    address_size_bits = 64,
    displacement = {
        text = "16",
        value = "16",
    },
    metadata = {
        ambiguous = {},
    },
}, {
    next_instruction = evidence.next_instruction,
}, {
    bits = 64,
})

assert(numeric_only.status == "unknown"
    and numeric_only.reason == "relative symbol unavailable",
    "numeric REL syntax must remain unresolved until its semantics are modeled explicitly")
print("PASS relative address: numeric REL stays unresolved")

local non_relative = evaluator.evaluate({
    address_mode = "absolute",
    symbol = {
        name = "msg",
    },
    metadata = {
        ambiguous = {},
    },
}, evidence, {
    bits = 64,
})

assert(non_relative.status == "unknown"
    and non_relative.reason == "address is not explicit relative",
    "relative evaluator must not consume non-relative addresses")
print("PASS relative address: non-relative address stays outside this evaluator")

print("PASS Tracker_HUD relative-address smoke")
