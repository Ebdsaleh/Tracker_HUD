-- lua/tracker_hud/low_level/integer_value.lua
--
-- Exact, architecture-neutral integer parsing and small arithmetic.
--
-- Values are normalized to canonical signed decimal strings. Source literals
-- may be decimal, hexadecimal (0x) or binary (0b). No wide value is routed
-- through Lua's floating-point number representation.

local M = {}

local MAX_SAFE_DECIMAL = "9007199254740991"

local function strip_zeroes(value)
    local stripped = tostring(value):gsub("^0+", "")
    return stripped == "" and "0" or stripped
end

local function compare_abs(left, right)
    left = strip_zeroes(left)
    right = strip_zeroes(right)

    if #left ~= #right then
        return #left < #right and -1 or 1
    end

    if left == right then
        return 0
    end

    return left < right and -1 or 1
end

local function add_abs(left, right)
    local out = {}
    local carry = 0
    local li = #left
    local ri = #right

    while li > 0 or ri > 0 or carry > 0 do
        local l = li > 0 and tonumber(left:sub(li, li)) or 0
        local r = ri > 0 and tonumber(right:sub(ri, ri)) or 0
        local sum = l + r + carry

        table.insert(out, 1, tostring(sum % 10))
        carry = math.floor(sum / 10)
        li = li - 1
        ri = ri - 1
    end

    return strip_zeroes(table.concat(out))
end

local function sub_abs(left, right)
    -- Requires left >= right.
    local out = {}
    local borrow = 0
    local li = #left
    local ri = #right

    while li > 0 do
        local l = tonumber(left:sub(li, li)) - borrow
        local r = ri > 0 and tonumber(right:sub(ri, ri)) or 0

        if l < r then
            l = l + 10
            borrow = 1
        else
            borrow = 0
        end

        table.insert(out, 1, tostring(l - r))
        li = li - 1
        ri = ri - 1
    end

    return strip_zeroes(table.concat(out))
end

local function mul_small(value, multiplier)
    local out = {}
    local carry = 0

    for index = #value, 1, -1 do
        local digit = tonumber(value:sub(index, index))
        local product = digit * multiplier + carry

        table.insert(out, 1, tostring(product % 10))
        carry = math.floor(product / 10)
    end

    while carry > 0 do
        table.insert(out, 1, tostring(carry % 10))
        carry = math.floor(carry / 10)
    end

    return strip_zeroes(table.concat(out))
end

local function digit_value(ch)
    if ch:match("%d") then
        return tonumber(ch)
    end

    local upper = ch:upper()
    local byte = upper:byte()
    if byte and byte >= string.byte("A") and byte <= string.byte("F") then
        return byte - string.byte("A") + 10
    end

    return nil
end

local function base_to_decimal(digits, base)
    local result = "0"

    for index = 1, #digits do
        local digit = digit_value(digits:sub(index, index))
        if digit == nil or digit >= base then
            return nil
        end

        result = mul_small(result, base)
        result = add_abs(result, tostring(digit))
    end

    return strip_zeroes(result)
end

local function split_sign(value)
    local sign = 1
    local text = value

    if text:sub(1, 1) == "-" then
        sign = -1
        text = text:sub(2)
    elseif text:sub(1, 1) == "+" then
        text = text:sub(2)
    end

    return sign, text
end

local function signed_decimal(sign, magnitude)
    magnitude = strip_zeroes(magnitude)
    if magnitude == "0" then
        return "0"
    end

    return sign < 0 and ("-" .. magnitude) or magnitude
end

function M.normalize(value)
    if value == nil then
        return nil
    end

    if type(value) == "number" then
        if value ~= value
            or value == math.huge
            or value == -math.huge
            or value ~= math.floor(value)
            or math.abs(value) > 9007199254740991
        then
            return nil
        end

        return string.format("%.0f", value)
    end

    if type(value) ~= "string" then
        return nil
    end

    local text = value:gsub("^%s+", ""):gsub("%s+$", "")
    if text == "" then
        return nil
    end

    local sign
    sign, text = split_sign(text)
    if text == "" then
        return nil
    end

    local magnitude

    if text:match("^%d+$") then
        magnitude = strip_zeroes(text)
    else
        local hex = text:match("^0[xX]([0-9a-fA-F]+)$")
        local binary = text:match("^0[bB]([01]+)$")

        if hex then
            magnitude = base_to_decimal(hex, 16)
        elseif binary then
            magnitude = base_to_decimal(binary, 2)
        end
    end

    if not magnitude then
        return nil
    end

    return signed_decimal(sign, magnitude)
end

function M.negate(value)
    local normalized = M.normalize(value)
    if not normalized then
        return nil
    end

    if normalized == "0" then
        return "0"
    end

    if normalized:sub(1, 1) == "-" then
        return normalized:sub(2)
    end

    return "-" .. normalized
end

function M.add(left, right)
    left = M.normalize(left)
    right = M.normalize(right)

    if not left or not right then
        return nil
    end

    local left_sign, left_abs = split_sign(left)
    local right_sign, right_abs = split_sign(right)

    left_abs = strip_zeroes(left_abs)
    right_abs = strip_zeroes(right_abs)

    if left_sign == right_sign then
        return signed_decimal(
            left_sign,
            add_abs(left_abs, right_abs)
        )
    end

    local cmp = compare_abs(left_abs, right_abs)

    if cmp == 0 then
        return "0"
    end

    if cmp > 0 then
        return signed_decimal(
            left_sign,
            sub_abs(left_abs, right_abs)
        )
    end

    return signed_decimal(
        right_sign,
        sub_abs(right_abs, left_abs)
    )
end

function M.to_safe_number(value)
    local normalized = M.normalize(value)
    if not normalized then
        return nil
    end

    local sign, magnitude = split_sign(normalized)
    magnitude = strip_zeroes(magnitude)

    if compare_abs(magnitude, MAX_SAFE_DECIMAL) > 0 then
        return nil
    end

    local number = tonumber(magnitude)
    if not number then
        return nil
    end

    return sign < 0 and -number or number
end

function M.is_exact_integer(value)
    return M.normalize(value) ~= nil
end

return M
