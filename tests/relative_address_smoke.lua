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

assert(resolved.value == "4294971392"
    and resolved.bits == 64,
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

local instruction_relative_policy = {
    bases = {
        rip = {
            basis = "next_instruction",
            result_width = "address_size",
        },
    },
}

local rip_address = {
    address_mode = "default",
    address_size_status = "known",
    address_size_bits = 64,
    base = {
        name = "rip",
    },
    displacement = {
        text = "16",
        value = "16",
    },
    metadata = {
        ambiguous = {},
    },
}

assert(evaluator.requires_next_instruction(
        rip_address,
        {
            instruction_relative_policy =
                instruction_relative_policy,
        }
    ) == true,
    "adapter-declared RIP base must request next-instruction evidence")
print("PASS relative address: adapter policy requests RIP basis evidence")

local rip = evaluator.evaluate(
    rip_address,
    {
        next_instruction = {
            status = "known",
            value = "0x100000107",
            bits = 64,
        },
    },
    {
        bits = 64,
        instruction_relative_policy =
            instruction_relative_policy,
    }
)

assert(rip.status == "known"
    and rip.value == "4294967575"
    and rip.bits == 64
    and rip.wrapped == false
    and rip.components.base.name == "rip"
    and rip.components.basis.value == "4294967559"
    and rip.components.source_displacement == "16"
    and rip.components.relative_delta == "16"
    and rip.components.exact_target == "4294967575",
    "RIP-relative target must use proven next-instruction basis")
print("PASS relative address: RIP + displacement resolves exactly")

local a32_rip = evaluator.evaluate({
    address_mode = "default",
    address_size_status = "known",
    address_size_bits = 32,
    base = {
        name = "rip",
    },
    displacement = {
        text = "16",
        value = "16",
    },
    metadata = {
        ambiguous = {},
    },
}, {
    next_instruction = {
        status = "known",
        value = "0x100000020",
        bits = 64,
    },
}, {
    bits = 64,
    instruction_relative_policy =
        instruction_relative_policy,
})

assert(a32_rip.status == "known"
    and a32_rip.value == "48"
    and a32_rip.bits == 32
    and a32_rip.wrapped == true
    and a32_rip.components.base.name == "rip"
    and a32_rip.components.basis.value == "4294967328"
    and a32_rip.components.source_displacement == "16"
    and a32_rip.components.exact_target == "4294967344",
    "A32 RIP-relative target must truncate and zero-extend the computed address")
print("PASS relative address: A32 RIP result obeys 32-bit address size")

local rip_symbol = evaluator.evaluate({
    address_mode = "default",
    address_size_status = "known",
    address_size_bits = 64,
    base = {
        name = "rip",
    },
    symbol = {
        name = "msg",
    },
    displacement = {
        text = "8",
        value = "8",
    },
    metadata = {
        ambiguous = {},
    },
}, {
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
}, {
    bits = 64,
    instruction_relative_policy =
        instruction_relative_policy,
})

assert(rip_symbol.status == "known"
    and rip_symbol.value == "4294971400"
    and rip_symbol.bits == 64
    and rip_symbol.wrapped == false
    and rip_symbol.components.symbol.name == "msg"
    and rip_symbol.components.symbol.value == "4294971392"
    and rip_symbol.components.symbol.mode == "target"
    and rip_symbol.components.source_displacement == "8"
    and rip_symbol.components.relative_delta == "3841"
    and rip_symbol.components.exact_target == "4294971400",
    "RIP-relative symbol must use provider symbol address as target evidence")
print("PASS relative address: RIP symbol + addend resolves from target evidence")

local a32_rip_symbol = evaluator.evaluate({
    address_mode = "default",
    address_size_status = "known",
    address_size_bits = 32,
    base = {
        name = "rip",
    },
    symbol = {
        name = "msg",
    },
    displacement = {
        text = "8",
        value = "8",
    },
    metadata = {
        ambiguous = {},
    },
}, {
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
}, {
    bits = 64,
    instruction_relative_policy =
        instruction_relative_policy,
})

assert(a32_rip_symbol.status == "known"
    and a32_rip_symbol.value == "4104"
    and a32_rip_symbol.bits == 32
    and a32_rip_symbol.wrapped == true
    and a32_rip_symbol.components.symbol.value == "4294971392"
    and a32_rip_symbol.components.relative_delta == "3841"
    and a32_rip_symbol.components.exact_target == "4294971400",
    "A32 RIP-relative symbol must preserve 64-bit evidence before 32-bit result truncation")
print("PASS relative address: A32 RIP symbol target truncates after exact arithmetic")

local rip_symbol_missing = evaluator.evaluate({
    address_mode = "default",
    address_size_status = "known",
    address_size_bits = 64,
    base = {
        name = "rip",
    },
    symbol = {
        name = "msg",
    },
    metadata = {
        ambiguous = {},
    },
}, {
    next_instruction = {
        status = "known",
        value = "0x100000107",
        bits = 64,
    },
    symbol = {
        status = "unknown",
        reason = "symbol absent from map",
    },
}, {
    bits = 64,
    instruction_relative_policy =
        instruction_relative_policy,
})

assert(rip_symbol_missing.status == "unknown"
    and rip_symbol_missing.reason
        == "symbol machine address unresolved",
    "RIP-relative symbol must fail closed without provider symbol evidence")
print("PASS relative address: RIP symbol without machine target fails closed")

local rip_without_provider = evaluator.evaluate(
    rip_address,
    nil,
    {
        bits = 64,
        instruction_relative_policy =
            instruction_relative_policy,
    }
)

assert(rip_without_provider.status == "unknown"
    and rip_without_provider.reason
        == "relative address basis unresolved",
    "RIP-relative source must fail closed without machine-address evidence")
print("PASS relative address: RIP without provider fails closed")

print("PASS Tracker_HUD relative-address smoke")
