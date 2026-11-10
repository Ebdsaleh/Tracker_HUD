-- lua/tracker_hud/facts/contract.lua
--
-- Language-neutral cursor-time semantic facts (v1).
-- No Neovim/adapter/rendering dependency: presentation never owns truth.
-- This is an opt-in shape; legacy section facts remain unchanged.

local M = {}

local supported_kinds = {
    register = true,
    memory = true,
    stack = true,
    heap = true,
    event = true,
    warning = true,
}

local value_states = {
    known = true,
    unknown = true,
    partial = true,
    conditional = true,
}

local function nonempty(value)
    return type(value) == "string" and value ~= ""
end

local function hex_literal(value)
    if type(value) ~= "string" then return false end
    local digits = value:match("^0[xX](%x+)$")
    return digits ~= nil and #digits <= 16
end

local function padded_hex_digits(value)
    if not hex_literal(value) then return nil end
    local digits = value:sub(3):upper()
    return string.rep("0", 16 - #digits) .. digits
end

local function nibble_within_mask(value_digit, mask_digit)
    local value = tonumber(value_digit, 16)
    local mask = tonumber(mask_digit, 16)
    if value == nil or mask == nil then return false end

    for _ = 1, 4 do
        local value_bit = value % 2
        local mask_bit = mask % 2
        if value_bit == 1 and mask_bit == 0 then
            return false
        end
        value = math.floor(value / 2)
        mask = math.floor(mask / 2)
    end

    return true
end

local function valid_partial_mask_value(mask_text, value_text)
    local mask = padded_hex_digits(mask_text)
    local value = padded_hex_digits(value_text)
    if not mask or not value then
        return false, "partial known mask/value must be exact <=64-bit hex literals"
    end

    if mask:match("^0+$") then
        return false, "partial known mask must contain at least one known bit"
    end
    if mask:match("^F+$") then
        return false, "all-known mask must use known value status"
    end

    for index = 1, 16 do
        if not nibble_within_mask(
            value:sub(index, index),
            mask:sub(index, index)
        ) then
            return false, "partial known value sets bits outside known mask"
        end
    end

    return true
end

local function position(pos)
    if type(pos) ~= "table"
        or type(pos.line) ~= "number"
        or pos.line < 1
        or pos.line % 1 ~= 0
    then
        return nil
    end

    local column = pos.column
    if column == nil then column = pos.start_column end
    if column == nil then column = 0 end

    if type(column) ~= "number"
        or column < 0
        or column % 1 ~= 0
    then
        return nil
    end

    return { line = pos.line, column = column }
end

local function copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, item in pairs(value) do
        result[copy(key)] = copy(item)
    end
    return result
end

function M.new(spec)
    if type(spec) ~= "table" then
        return nil, "fact must be a table"
    end
    if not nonempty(spec.id) then
        return nil, "fact id is required"
    end
    if not supported_kinds[spec.kind] then
        return nil, "unsupported fact kind"
    end
    if type(spec.subject) ~= "table"
        or not nonempty(spec.subject.name)
    then
        return nil, "fact subject name is required"
    end

    local source = type(spec.source) == "table" and spec.source or {}
    local discovery = position(source)
    if not discovery then
        return nil, "fact source position must be a valid line/column"
    end

    local value = type(spec.value) == "table" and spec.value or {}
    local status = value.status
    if not value_states[status] then
        return nil, "fact value status must be explicit"
    end
    if status == "known"
        and value.data == nil
        and value.is_nil ~= true
    then
        return nil, "known nil requires is_nil=true"
    end
    if value.is_nil == true
        and (status ~= "known" or value.data ~= nil)
    then
        return nil, "is_nil applies only to a known nil value"
    end

    local has_known_mask = value.known_mask ~= nil
    local has_known_value = value.known_value ~= nil

    if has_known_mask ~= has_known_value then
        return nil, "partial known mask/value must be supplied together"
    end

    if has_known_mask then
        if status ~= "partial" then
            return nil, "known mask/value applies only to partial values"
        end
        local valid_partial, partial_err = valid_partial_mask_value(
            value.known_mask,
            value.known_value
        )
        if not valid_partial then
            return nil, partial_err
        end
    end

    if type(source.end_column) == "number"
        and source.end_column < discovery.column
    then
        return nil, "source end column precedes start column"
    end

    local through = discovery
    if spec.known_through ~= nil then
        through = position(spec.known_through)
        if not through then
            return nil, "invalid known-through position"
        end
    end
    if through.line < discovery.line
        or (through.line == discovery.line
            and through.column < discovery.column)
    then
        return nil, "known-through position precedes discovery"
    end

    local fact = {
        version = 1,
        id = spec.id,
        kind = spec.kind,
        subject = copy(spec.subject),
        source = copy(source),
        effect = copy(spec.effect or {}),
        value = copy(value),
        provenance = copy(spec.provenance or {}),
        known_through = through,
        metadata = copy(spec.metadata or {}),
    }
    fact.source.line = discovery.line
    fact.source.start_column = discovery.column

    return fact
end

-- Cursor position is source-buffer-local, 1-based row and 0-based column.
-- A previously cached fact is invisible before the user reaches its source.
function M.visible_at(fact, cursor)
    if type(fact) ~= "table" then return false end
    local start = position(fact.source)
    local current = position(cursor)
    if not start or not current then return false end
    if current.line ~= start.line then
        return current.line > start.line
    end
    return current.column >= start.column
end

function M.is_known(fact)
    return type(fact) == "table"
        and type(fact.value) == "table"
        and fact.value.status == "known"
end

return M
