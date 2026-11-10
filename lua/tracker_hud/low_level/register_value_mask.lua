-- lua/tracker_hud/low_level/register_value_mask.lua
--
-- Architecture-neutral byte-aligned register certainty composition.
-- Architecture profiles provide alias bits/offset/write_mode; this module
-- combines that truth with the previous reduced canonical register state.
--
-- It deliberately uses byte arithmetic and exact strings rather than Lua
-- integer-width assumptions.

local integer_value = require("tracker_hud.low_level.integer_value")

local M = {}

local BYTE_COUNT = 8
local HEX = "0123456789ABCDEF"

local function stripped_decimal(value)
    local v = value:gsub("^0+", "")
    return v == "" and "0" or v
end

local function decimal_to_bytes(digits)
    digits = stripped_decimal(digits)
    if #digits > 24 then return nil end

    local result = {}
    for output_index = BYTE_COUNT, 1, -1 do
        local remainder = 0
        local quotient = {}

        for index = 1, #digits do
            local digit = tonumber(digits:sub(index, index))
            if digit == nil then return nil end
            local current = remainder * 10 + digit
            local q = math.floor(current / 256)
            remainder = current % 256

            if #quotient > 0 or q ~= 0 then
                quotient[#quotient + 1] = tostring(q)
            end
        end

        result[output_index] = remainder
        digits = #quotient > 0 and table.concat(quotient) or "0"
    end

    return digits == "0" and result or nil
end

local function twos_complement(bytes)
    local carry = 1
    for index = BYTE_COUNT, 1, -1 do
        local next_value = (255 - bytes[index]) + carry
        if next_value == 256 then
            bytes[index] = 0
            carry = 1
        else
            bytes[index] = next_value
            carry = 0
        end
    end
end

function M.bytes_for_integer(value)
    local text = integer_value.normalize(value)
    if not text then
        return nil
    end

    local negative = text:sub(1, 1) == "-"
    if negative then
        text = text:sub(2)
    end

    local bytes = decimal_to_bytes(text)
    if not bytes then
        return nil
    end

    if negative then
        if bytes[1] > 128 then
            return nil
        end

        if bytes[1] == 128 then
            for index = 2, BYTE_COUNT do
                if bytes[index] ~= 0 then
                    return nil
                end
            end
        end

        twos_complement(bytes)
    end

    return bytes
end

local function byte_hex(value)
    return HEX:sub(math.floor(value / 16) + 1, math.floor(value / 16) + 1)
        .. HEX:sub(value % 16 + 1, value % 16 + 1)
end

function M.hex_for_bytes(bytes)
    if type(bytes) ~= "table" or #bytes ~= BYTE_COUNT then return nil end
    local out = {}
    for index = 1, BYTE_COUNT do
        local byte = bytes[index]
        if type(byte) ~= "number" or byte < 0 or byte > 255
            or byte ~= math.floor(byte)
        then
            return nil
        end
        out[#out + 1] = byte_hex(byte)
    end
    return "0x" .. table.concat(out)
end

local function blank_bytes(fill)
    local result = {}
    for index = 1, BYTE_COUNT do result[index] = fill or 0 end
    return result
end

local function copy_bytes(bytes)
    local result = {}
    for index = 1, BYTE_COUNT do result[index] = bytes[index] or 0 end
    return result
end

local function all_equal(bytes, wanted)
    for index = 1, BYTE_COUNT do
        if bytes[index] ~= wanted then return false end
    end
    return true
end

local function value_within_mask(value_bytes, mask_bytes)
    for index = 1, BYTE_COUNT do
        local value = value_bytes[index]
        local mask = mask_bytes[index]
        for _ = 1, 8 do
            if value % 2 == 1 and mask % 2 == 0 then return false end
            value = math.floor(value / 2)
            mask = math.floor(mask / 2)
        end
    end
    return true
end

local function previous_certainty(fact)
    if type(fact) ~= "table" then
        return blank_bytes(0), blank_bytes(0)
    end

    local metadata = type(fact.metadata) == "table" and fact.metadata or {}
    local partial = type(metadata.partial_value) == "table"
        and metadata.partial_value or nil

    if partial then
        local mask = M.bytes_for_integer(partial.known_mask or "")
        local value = M.bytes_for_integer(partial.known_value or "")
        if mask and value and value_within_mask(value, mask) then
            return mask, value
        end
    end

    if fact.resolved ~= false and fact.value ~= nil then
        local value = M.bytes_for_integer(fact.value)
        if value then
            return blank_bytes(255), value
        end
    end

    return blank_bytes(0), blank_bytes(0)
end

local function alias_byte_window(alias)
    if type(alias) ~= "table"
        or type(alias.bits) ~= "number"
        or type(alias.offset) ~= "number"
        or alias.bits <= 0
        or alias.offset < 0
        or alias.bits % 8 ~= 0
        or alias.offset % 8 ~= 0
        or alias.offset + alias.bits > 64
    then
        return nil
    end

    local byte_count = alias.bits / 8
    local low_byte = alias.offset / 8
    local last_index = BYTE_COUNT - low_byte
    local first_index = last_index - byte_count + 1

    return first_index, last_index, byte_count
end

local function source_bytes_for_alias(value, alias)
    local bytes = M.bytes_for_integer(value)
    local first_index, last_index, byte_count = alias_byte_window(alias)
    if not bytes or not first_index then return nil end

    local outside_count = BYTE_COUNT - byte_count
    local low_start = outside_count + 1

    local high_zero = true
    local high_ff = true
    for index = 1, outside_count do
        if bytes[index] ~= 0 then high_zero = false end
        if bytes[index] ~= 255 then high_ff = false end
    end

    if outside_count > 0
        and not high_zero
        and not (high_ff and bytes[low_start] >= 128)
    then
        return nil
    end

    local result = {}
    for index = low_start, BYTE_COUNT do
        result[#result + 1] = bytes[index]
    end

    return result, first_index, last_index
end

local function classify(mask, value)
    if all_equal(mask, 0) then
        return {
            value = nil,
            resolved = false,
            partial_value = nil,
            status = "unknown",
        }
    end

    if all_equal(mask, 255) then
        return {
            value = M.hex_for_bytes(value),
            resolved = true,
            partial_value = nil,
            status = "known",
        }
    end

    return {
        value = nil,
        resolved = false,
        partial_value = {
            known_mask = M.hex_for_bytes(mask),
            known_value = M.hex_for_bytes(value),
        },
        status = "partial",
    }
end

-- Compose one architectural alias write into the previous canonical state.
-- write_resolved says whether write_value is proven; unknown writes still
-- invalidate the overwritten slice and can introduce architectural constants
-- such as the zeroed upper half of a 32-bit x86-64 write.
function M.apply_alias_write(previous_fact, alias, write_value, write_resolved)
    local first_index, last_index = alias_byte_window(alias)
    if not first_index then return nil end

    local mode = alias.write_mode
    if mode ~= "partial" and mode ~= "zero_extend_64" then
        return nil
    end

    local mask, value = previous_certainty(previous_fact)
    mask = copy_bytes(mask)
    value = copy_bytes(value)

    for index = first_index, last_index do
        mask[index] = 0
        value[index] = 0
    end

    local source_bytes
    if write_resolved ~= false and write_value ~= nil then
        source_bytes = source_bytes_for_alias(write_value, alias)
    end

    if source_bytes then
        for offset = 0, #source_bytes - 1 do
            local index = first_index + offset
            mask[index] = 255
            value[index] = source_bytes[offset + 1]
        end
    end

    if mode == "zero_extend_64" then
        for index = 1, first_index - 1 do
            mask[index] = 255
            value[index] = 0
        end
    end

    return classify(mask, value)
end

return M
