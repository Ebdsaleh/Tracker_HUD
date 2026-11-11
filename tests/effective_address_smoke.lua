-- tests/effective_address_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/effective_address_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local evaluator = require("tracker_hud.low_level.effective_address")

local function component(name, role, value)
    return {
        name = name,
        role = role,
        value = value,
    }
end

local address = {
    base = component("rbp", "base_register"),
    index = component("rcx", "index_register"),
    scale = component(nil, "scale", "4"),
    displacement = component(nil, "displacement", "-8"),
    metadata = {
        ambiguous = {},
    },
}

local values = {
    rbp = "4096",
    rcx = "3",
}

local result = evaluator.evaluate(address, {
    bits = 64,
    resolve_register = function(name)
        return values[name], {
            source = "test",
        }
    end,
})

assert(result.status == "known"
    and result.value == "4100"
    and result.bits == 64
    and result.wrapped == false
    and result.components.base.value == "4096"
    and result.components.index.value == "3"
    and result.components.scale == "4"
    and result.components.displacement == "-8"
    and result.components.exact == "4100",
    "effective address must evaluate exact base + index*scale + displacement")
print("PASS effective address: exact base/index/scale/displacement evaluation")

local wide = evaluator.evaluate({
    base = component("rax", "base_register"),
    displacement = component(nil, "displacement", "4"),
    metadata = { ambiguous = {} },
}, {
    resolve_register = function()
        return "18446744073709551615"
    end,
})
assert(wide.status == "known"
    and wide.value == "18446744073709551619"
    and wide.wrapped == false,
    "unbounded evaluation must preserve exact wide arithmetic")
print("PASS effective address: exact wide arithmetic remains lossless")

local wrapped = evaluator.evaluate({
    base = component("rax", "base_register"),
    displacement = component(nil, "displacement", "1"),
    metadata = { ambiguous = {} },
}, {
    bits = 64,
    resolve_register = function()
        return "18446744073709551615"
    end,
})
assert(wrapped.status == "known"
    and wrapped.value == "0"
    and wrapped.wrapped == true
    and wrapped.components.exact == "18446744073709551616",
    "64-bit effective address must wrap only when requested")
print("PASS effective address: target-width wrapping is explicit")

local unresolved = evaluator.evaluate(address, {
    bits = 64,
    resolve_register = function(name)
        if name == "rbp" then
            return "4096"
        end
        return nil, { status = "unknown" }
    end,
})
assert(unresolved.status == "unknown"
    and unresolved.reason == "index register unresolved"
    and unresolved.details.register == "rcx",
    "unresolved required register must fail closed")
print("PASS effective address: unresolved register fails closed")

local symbolic = evaluator.evaluate({
    symbol = {
        name = "msg",
    },
    address_mode = "default",
    metadata = { ambiguous = {} },
}, {
    bits = 64,
})
assert(symbolic.status == "unknown"
    and symbolic.reason == "symbol address unresolved"
    and symbolic.details.symbol == "msg",
    "symbolic address must remain unresolved without symbol-address model")
print("PASS effective address: symbolic address remains unresolved")

local relative_numeric = evaluator.evaluate({
    address_mode = "relative",
    displacement = component(nil, "displacement", "16"),
    metadata = { ambiguous = {} },
}, {
    bits = 64,
})
assert(relative_numeric.status == "unknown"
    and relative_numeric.reason == "relative address basis unresolved",
    "relative numeric address must not become absolute without instruction basis")
print("PASS effective address: relative numeric basis remains unresolved")

local ambiguous = evaluator.evaluate({
    base = component("rax", "base_register"),
    metadata = {
        ambiguous = {
            base = true,
        },
    },
}, {
    resolve_register = function()
        return "1"
    end,
})
assert(ambiguous.status == "unknown"
    and ambiguous.reason == "address structure ambiguous"
    and ambiguous.details.fields[1] == "base",
    "ambiguous address structure must fail closed")
print("PASS effective address: ambiguous structure fails closed")

local invalid_scale = evaluator.evaluate({
    scale = component(nil, "scale", "4"),
    metadata = { ambiguous = {} },
}, {})
assert(invalid_scale.status == "unknown"
    and invalid_scale.reason == "scale has no index register",
    "scale without index must fail closed")
print("PASS effective address: scale without index is rejected")

local displacement_only = evaluator.evaluate({
    displacement = component(nil, "displacement", "4660"),
    metadata = { ambiguous = {} },
}, {
    bits = 64,
})
assert(displacement_only.status == "known"
    and displacement_only.value == "4660",
    "absolute numeric address must evaluate without registers")
print("PASS effective address: displacement-only address evaluates")

print("PASS Tracker_HUD effective-address smoke")
