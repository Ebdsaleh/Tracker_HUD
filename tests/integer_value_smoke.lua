-- tests/integer_value_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/integer_value_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local integer = require("tracker_hud.low_level.integer_value")

assert(integer.normalize("0") == "0"
    and integer.normalize("+00042") == "42"
    and integer.normalize("-00042") == "-42",
    "decimal normalization failed")
print("PASS exact integer: canonical decimal signs and zeroes")

assert(integer.normalize("0x123456789ABCDEF0")
        == "1311768467463790320"
    and integer.normalize("0xFFFFFFFFFFFFFFFF")
        == "18446744073709551615",
    "wide hexadecimal conversion lost precision")
print("PASS exact integer: 64-bit hexadecimal literals remain exact")

assert(integer.normalize(
        "0b1111111111111111111111111111111111111111111111111111111111111111"
    ) == "18446744073709551615",
    "wide binary conversion lost precision")
print("PASS exact integer: 64-bit binary literals remain exact")

assert(integer.add("18446744073709551614", "1")
        == "18446744073709551615"
    and integer.add("1311768467463790320", "1")
        == "1311768467463790321"
    and integer.add("1311768467463790321", "-16")
        == "1311768467463790305"
    and integer.add("-9223372036854775808", "1")
        == "-9223372036854775807",
    "exact signed addition failed")
print("PASS exact integer: signed addition does not use Lua float precision")

assert(integer.negate("18446744073709551615")
        == "-18446744073709551615"
    and integer.negate("-7") == "7"
    and integer.negate("0") == "0",
    "exact negate failed")
print("PASS exact integer: exact negation")

assert(integer.to_safe_number("9007199254740991") == 9007199254740991
    and integer.to_safe_number("9007199254740992") == nil
    and integer.to_safe_number("-9007199254740992") == nil,
    "safe-number boundary must reject imprecise Lua-number conversion")
print("PASS exact integer: safe-number boundary is explicit")

assert(integer.normalize("1.5") == nil
    and integer.normalize("0xGG") == nil
    and integer.normalize("0b102") == nil
    and integer.normalize(9007199254740992) == nil,
    "invalid or unsafe numeric inputs must not become resolved integers")
print("PASS exact integer: invalid and unsafe numeric inputs stay unresolved")

print("PASS Tracker_HUD exact integer value smoke")
