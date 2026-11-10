-- tests/integer_operand_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/integer_operand_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local operand = require("tracker_hud.low_level.integer_operand")

local value, metadata = operand.interpret("0x1234", { kind = "exact" })
assert(value == "4660"
    and metadata.interpretation == "exact"
    and metadata.raw_value == "4660"
    and metadata.value == "4660"
    and metadata.error == nil,
    "exact integer operand interpretation failed")
print("PASS integer operand: exact source interpretation")

value, metadata = operand.interpret(
    "0xFF",
    {
        kind = "signed_bits",
        bits = 8,
    }
)
assert(value == "-1"
    and metadata.bits == 8
    and metadata.bits_source == "fixed"
    and metadata.raw_value == "255"
    and metadata.value == "-1",
    "fixed signed-bit reinterpretation failed")
print("PASS integer operand: fixed signed-bit interpretation")

local min8 = select(1, operand.interpret(
    "0x80",
    {
        kind = "signed_bits",
        bits = 8,
    }
))
local max8 = select(1, operand.interpret(
    "0x7F",
    {
        kind = "signed_bits",
        bits = 8,
    }
))
local negative = select(1, operand.interpret(
    "-1",
    {
        kind = "signed_bits",
        bits = 8,
    }
))
assert(min8 == "-128"
    and max8 == "127"
    and negative == "-1",
    "signed-bit boundary interpretation failed")
print("PASS integer operand: signed-bit boundaries remain exact")

value, metadata = operand.interpret(
    "0xFFFFFFFF",
    {
        kind = "signed_bits",
        bits_from = "target",
        max_bits = 32,
    },
    {
        target_bits = 64,
    }
)
assert(value == "-1"
    and metadata.bits == 32
    and metadata.bits_source == "target_capped"
    and metadata.max_bits == 32,
    "target-derived capped source width failed")
print("PASS integer operand: target-derived width can be capped")

value, metadata = operand.interpret(
    "0xFFFF",
    {
        kind = "signed_bits",
        bits_from = "target",
        max_bits = 32,
    },
    {
        target_bits = 16,
    }
)
assert(value == "-1"
    and metadata.bits == 16
    and metadata.bits_source == "target",
    "target-derived sub-32-bit source width failed")
print("PASS integer operand: target-derived width preserves smaller targets")

value, metadata = operand.interpret(
    "255",
    {
        kind = "unsigned_bits",
        bits = 8,
    }
)
assert(value == "255"
    and metadata.value == "255"
    and metadata.error == nil,
    "unsigned fixed-width interpretation failed")

local invalid_unsigned, invalid_unsigned_meta = operand.interpret(
    "-1",
    {
        kind = "unsigned_bits",
        bits = 8,
    }
)
assert(invalid_unsigned == nil
    and invalid_unsigned_meta.error == "value does not fit source width",
    "unsigned interpretation must reject negative values")
print("PASS integer operand: unsigned source interpretation is range checked")

local overflow, overflow_meta = operand.interpret(
    "0x100000000",
    {
        kind = "signed_bits",
        bits_from = "target",
        max_bits = 32,
    },
    {
        target_bits = 64,
    }
)
assert(overflow == nil
    and overflow_meta.bits == 32
    and overflow_meta.error == "value does not fit source width",
    "out-of-range source bit pattern must fail closed")
print("PASS integer operand: out-of-range source width fails closed")

local missing_width, missing_width_meta = operand.interpret(
    "1",
    {
        kind = "signed_bits",
        bits_from = "target",
    },
    {}
)
assert(missing_width == nil
    and missing_width_meta.error == "source width unavailable",
    "missing target-derived width must fail closed")

local unsupported, unsupported_meta = operand.interpret(
    "1",
    {
        kind = "mystery",
        bits = 8,
    }
)
assert(unsupported == nil
    and unsupported_meta.error == "unsupported integer interpretation",
    "unknown interpretation must fail closed")
print("PASS integer operand: missing and unknown policies fail closed")

local ambiguous, ambiguous_meta = operand.interpret(
    "1",
    {
        kind = "signed_bits",
        bits = 8,
        bits_from = "target",
    },
    {
        target_bits = 64,
    }
)
assert(ambiguous == nil
    and ambiguous_meta.error == "source width policy is ambiguous",
    "runtime must reject ambiguous fixed/derived width policy")

local bad_max, bad_max_meta = operand.interpret(
    "1",
    {
        kind = "signed_bits",
        bits = 8,
        max_bits = 0,
    }
)
assert(bad_max == nil
    and bad_max_meta.error == "invalid maximum source width",
    "runtime must reject invalid maximum source width")

local inverted, inverted_meta = operand.interpret(
    "1",
    {
        kind = "signed_bits",
        bits = 8,
        min_bits = 16,
        max_bits = 8,
    }
)
assert(inverted == nil
    and inverted_meta.error == "minimum source width exceeds maximum",
    "runtime must reject inverted source-width bounds")

local exact_with_width, exact_with_width_meta = operand.interpret(
    "1",
    {
        kind = "exact",
        bits = 8,
    }
)
assert(exact_with_width == nil
    and exact_with_width_meta.error
        == "exact interpretation does not use source width",
    "runtime must reject meaningless width on exact interpretation")
print("PASS integer operand: malformed policies fail closed at runtime")

print("PASS Tracker_HUD integer operand interpretation smoke")
