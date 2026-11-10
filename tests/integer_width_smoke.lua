-- tests/integer_width_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/integer_width_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local integer = require("tracker_hud.low_level.integer_value")

assert(integer.fits_unsigned("0", 8)
    and integer.fits_unsigned("255", 8)
    and not integer.fits_unsigned("256", 8)
    and not integer.fits_unsigned("-1", 8),
    "unsigned width fit checks are incorrect")
print("PASS integer width: unsigned fit boundaries")

assert(integer.fits_signed("-128", 8)
    and integer.fits_signed("127", 8)
    and not integer.fits_signed("-129", 8)
    and not integer.fits_signed("128", 8),
    "signed width fit checks are incorrect")
print("PASS integer width: signed fit boundaries")

assert(integer.normalize_unsigned("255", 8) == "255"
    and integer.normalize_unsigned("256", 8) == nil
    and integer.normalize_unsigned("-1", 8) == nil,
    "unsigned width normalization must reject out-of-range values")
print("PASS integer width: unsigned normalization is range checked")

assert(integer.wrap_unsigned("256", 8) == "0"
    and integer.wrap_unsigned("257", 8) == "1"
    and integer.wrap_unsigned("-1", 8) == "255"
    and integer.wrap_unsigned("-257", 8) == "255",
    "8-bit modular wrapping is incorrect")
print("PASS integer width: 8-bit positive and negative wrapping")

assert(integer.wrap_unsigned("65536", 16) == "0"
    and integer.wrap_unsigned("65537", 16) == "1"
    and integer.wrap_unsigned("-1", 16) == "65535",
    "16-bit modular wrapping is incorrect")
print("PASS integer width: 16-bit wrapping")

assert(integer.wrap_unsigned("18446744073709551616", 64) == "0"
    and integer.wrap_unsigned("18446744073709551617", 64) == "1"
    and integer.wrap_unsigned("-1", 64) == "18446744073709551615",
    "64-bit modular wrapping must remain exact above Lua number precision")
print("PASS integer width: 64-bit wrapping remains exact")

assert(integer.reinterpret_signed("255", 8) == "-1"
    and integer.reinterpret_signed("128", 8) == "-128"
    and integer.reinterpret_signed("127", 8) == "127"
    and integer.reinterpret_signed("-128", 8) == "-128"
    and integer.reinterpret_signed("256", 8) == nil
    and integer.reinterpret_signed("-129", 8) == nil,
    "signed bit-pattern reinterpretation boundaries are incorrect")
print("PASS integer width: signed bit-pattern reinterpretation")

assert(integer.reinterpret_signed(
        "18446744073709551615",
        64
    ) == "-1"
    and integer.reinterpret_signed(
        "9223372036854775808",
        64
    ) == "-9223372036854775808",
    "64-bit signed reinterpretation must remain exact")
print("PASS integer width: 64-bit signed reinterpretation remains exact")

local huge = "134078079299425970995740249982058461274793658205923933"
    .. "77723561443721764030073546976801874298166903427690031"
    .. "858186486050853753882811946569946433649006084096"
assert(integer.wrap_unsigned(huge, 512) == "0",
    "2^512 must wrap to zero at 512 bits")
print("PASS integer width: generic widths are not capped at machine 64-bit")

assert(integer.wrap_unsigned("1", 0) == nil
    and integer.wrap_unsigned("1", -1) == nil
    and integer.wrap_unsigned("1", 1.5) == nil,
    "invalid bit widths must fail closed")
print("PASS integer width: invalid widths fail closed")

print("PASS Tracker_HUD exact integer width smoke")
