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

    if type(source.end_column) == "number"
        and source.end_column < discovery.column
    then
        return nil, "source end column precedes start column"
    end

    local through = spec.known_through and position(spec.known_through)
        or discovery
    if not through then
        return nil, "invalid known-through position"
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
