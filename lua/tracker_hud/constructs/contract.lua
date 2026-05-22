-- lua/tracker_hud/constructs/contract.lua

local M = {}

M.kinds = {
    callable = true,
    branch = true,
    loop = true,
    block = true,
    module = true,
    type = true,
    variable = true,
    assignment = true,

}


local function is_number(value)
    return type(value) == "number"
end

local function is_string(value)
    return type(value) == "string"
end

local function is_table(value)
    return type(value) == "table"
end


function M.is_valid_kind(kind)
    return is_string(kind) and M.kinds[kind] == true
end

function M.validate_range(range)
    if not is_table(range) then
        return false
    end

    return is_number(range.start_line)
        and is_number(range.end_line)
        and range.start_line <= range.end_line
end


function M.validate_construct(construct)
    if not is_table(construct) then
        return false, "construct must be a table"
    end
    
    if not M.is_valid_kind(construct.kind) then
        return false, "construct.kind is invalid or missing"
    end

    if not is_string(construct.label) then
        return false, "construct.label must be a string"
    end

    if not is_string(construct.node_type) then
        return false, "construct.node_type must be a string"
    end

    if not M.validate_range(construct.range) then
        return false, "construct.range is invalid"
    end

    if construct.signature ~= nil and not is_string(construct.signature) then
        return false, "construct.signature must be a string when provided"
    end

    if construct.name ~= nil and not is_string(construct.name) then
        return false, "construct.name must be a string when provided"
    end

    return true, nil
end


function M.new_construct(opts)
    opts = opts or {}

    local construct = {
        kind = opts.kind,
        label = opts.label,
        node_type = opts.node_type,
        name = opts.name,
        signature = opts.signature,
        range = opts.range,
        creates_scope = opts.creates_scope == true,
        metadata = opts.metadata or {},
    }

    local ok, err = M.validate_construct(construct)

    if not ok then
        return nil, err
    end

    return construct, nil
end


return M
