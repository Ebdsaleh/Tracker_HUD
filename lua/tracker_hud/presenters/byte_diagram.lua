-- lua/tracker_hud/presenters/byte_diagram.lua
--
-- Terminal-first 64-bit register value diagram. This is a projection of
-- normalized facts, NOT a CPU emulator, memory view, or new source parser.
-- Conversion is performed using decimal strings/individual bytes, not
-- floating-point or bitwise shifts of 64-bit numbers.

local M = {}

local BYTE_COUNT = 8
local HEX_DIGITS = "0123456789ABCDEF"

local function stripped_decimal(value)
    local v = value:gsub("^0+", "")
    return v == "" and "0" or v
end

local function decimal_to_bytes(digits, count)
    digits = stripped_decimal(digits)
    -- 8-byte decimal values have at most 20 digits. A cheap upper bound
    -- keeps untrusted/accidental giant numeric strings out of hot UI work.
    if #digits > count * 3 then
        return nil, "value exceeds the register width"
    end

    local result = {}
    for output_index = count, 1, -1 do
        local remainder = 0
        local quotient = {}
        for i = 1, #digits do
            local decimal_digit = tonumber(digits:sub(i, i))
            local current = remainder * 10 + decimal_digit
            local q = math.floor(current / 256)
            remainder = current % 256

            if #quotient > 0 or q ~= 0 then
                quotient[#quotient + 1] = tostring(q)
            end
        end

        result[output_index] = remainder
        digits = #quotient > 0 and table.concat(quotient) or "0"
    end

    if digits ~= "0" then
        return nil, "value exceeds the register width"
    end

    return result
end

local function hex_to_bytes(text, count)
    local digits = text:sub(3):upper():gsub("^0+", "")
    if digits == "" then digits = "0" end
    if #digits > count * 2 then
        return nil, "value exceeds the register width"
    end

    digits = string.rep("0", count * 2 - #digits) .. digits
    local result = {}
    for i = 1, count do
        result[i] = tonumber(digits:sub(i * 2 - 1, i * 2), 16)
    end
    return result
end

local function signed_magnitude_fits(bytes)
    if bytes[1] < 128 then return true end
    if bytes[1] > 128 then return false end
    for i = 2, #bytes do
        if bytes[i] ~= 0 then return false end
    end
    return true
end

local function twos_complement(bytes)
    local carry = 1
    for i = #bytes, 1, -1 do
        local n = (255 - bytes[i]) + carry
        if n == 256 then
            bytes[i] = 0
            carry = 1
        else
            bytes[i] = n
            carry = 0
        end
    end
end

-- Returns high-significance byte first, no dependence on CPU endianness.
-- This converter intentionally handles only 64-bit scalar register cells.
function M.bytes_for(value)
    local text
    if type(value) == "number" then
        -- Lua numbers may be IEEE-754 doubles. Do not accept a value that
        -- might already have lost low bits. Use a string for wide values.
        if value ~= value or value == math.huge or value == -math.huge
            or value ~= math.floor(value)
            or math.abs(value) >= 9007199254740992
        then
            return nil, "numeric input is not a safe exact integer"
        end
        text = string.format("%.0f", value)
    elseif type(value) == "string" then
        text = value
    else
        return nil, "value is not an integer"
    end

    local negative = text:sub(1, 1) == "-"
    if negative then text = text:sub(2) end

    local bytes, err
    if text:match("^%d+$") then
        bytes, err = decimal_to_bytes(text, BYTE_COUNT)
    elseif text:match("^0[xX]%x+$") then
        bytes, err = hex_to_bytes(text, BYTE_COUNT)
    else
        return nil, "value is not an integer literal"
    end
    if not bytes then return nil, err end

    if negative then
        if not signed_magnitude_fits(bytes) then
            return nil, "negative value is outside signed 64-bit range"
        end
        twos_complement(bytes)
    end

    return bytes
end

local function byte_to_hex(n)
    return HEX_DIGITS:sub(math.floor(n / 16) + 1, math.floor(n / 16) + 1)
        .. HEX_DIGITS:sub(n % 16 + 1, n % 16 + 1)
end

function M.cells(bytes)
    local tokens = {}
    for i = 1, BYTE_COUNT do
        local b = type(bytes) == "table" and bytes[i] or nil
        if type(b) == "number" and b >= 0 and b <= 255
            and b == math.floor(b)
        then
            tokens[#tokens + 1] = "[" .. byte_to_hex(b) .. "]"
        else
            tokens[#tokens + 1] = "[??]"
        end
    end
    return table.concat(tokens)
end

local function hex_value(bytes)
    local items = {}
    for _, b in ipairs(bytes) do
        items[#items + 1] = byte_to_hex(b)
    end
    return "0x" .. table.concat(items)
end

-- Fact shape is defined by tracker_hud.facts.contract; it must contain
-- an architecture-provided width to draw a faithful register bank.
function M.lines(fact)
    local lines = {
        "Byte diagram (source inference, not live CPU state):",
    }
    if type(fact) ~= "table"
        or fact.kind ~= "register"
        or type(fact.subject) ~= "table"
    then
        lines[#lines + 1] = "  No register fact at this cursor position."
        return lines
    end

    local name = tostring(fact.subject.name or "register"):upper()
    local width = fact.subject.width_bits

    if width ~= 64 then
        lines[#lines + 1] = "  " .. name
            .. ": no verified 64-bit scalar register width."
        lines[#lines + 1] = "  No bytes drawn; see the technical sections."
        return lines
    end

    local value = type(fact.value) == "table" and fact.value or {}
    local bytes, reason

    if value.status == "known" then
        bytes, reason = M.bytes_for(value.data)
    else
        reason = "value status: " .. tostring(value.status or "unknown")
    end

    lines[#lines + 1] = "  " .. name .. "  (64 bits = 8 bytes)"
    lines[#lines + 1] = "  MSB                                 LSB"
    lines[#lines + 1] = "  " .. M.cells(bytes)

    if bytes then
        lines[#lines + 1] = "  Bits: " .. hex_value(bytes)
        lines[#lines + 1] = "  Source-inferred value, not execution proof."
    else
        lines[#lines + 1] = "  ?? = unknown byte (" .. tostring(reason) .. ")"
    end

    lines[#lines + 1] =
        "  Left to right: high to low significance, NOT memory order."
    return lines
end

return M
