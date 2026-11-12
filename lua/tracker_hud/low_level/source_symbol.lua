-- lua/tracker_hud/low_level/source_symbol.lua
--
-- Architecture-neutral source-symbol identity resolution.
--
-- This module resolves a parsed symbol name to a source declaration/member.
-- It does not assign machine addresses, linker addresses, or runtime values.

local M = {}

local function copy_member(member, reference_line)
    return {
        status = "known",
        name = member.name,
        kind = member.kind,
        member_id = member.id,

        source_line = member.source_start_line or member.line,
        source_start_column = member.source_start_column,
        source_end_line = member.source_end_line,
        source_end_column = member.source_end_column,

        forward_reference = type(reference_line) == "number"
            and type(member.line) == "number"
            and member.line > reference_line
            or false,

        machine_address_status = "unknown",
        machine_address = nil,
        machine_address_reason = "machine address unavailable",
    }
end

local function kind_allowed(kind, allowed_kinds)
    if allowed_kinds == nil then
        return true
    end

    if type(allowed_kinds) ~= "table" then
        return false
    end

    if allowed_kinds[kind] == true then
        return true
    end

    for _, candidate in ipairs(allowed_kinds) do
        if candidate == kind then
            return true
        end
    end

    return false
end

local function names_match(left, right, case_sensitive)
    if type(left) ~= "string" or type(right) ~= "string" then
        return false
    end

    if case_sensitive == false then
        return left:lower() == right:lower()
    end

    return left == right
end

function M.resolve(members, name, opts)
    opts = opts or {}

    if type(name) ~= "string" or name == "" then
        return {
            status = "unknown",
            name = name,
            reason = "symbol name unavailable",
            machine_address_status = "unknown",
            machine_address_reason = "machine address unavailable",
        }
    end

    local reference_line = opts.reference_line
    local matches = {}

    for _, member in ipairs(members or {}) do
        if type(member) == "table"
            and names_match(
                member.name,
                name,
                opts.case_sensitive
            )
            and kind_allowed(
                member.kind,
                opts.member_kinds
            )
        then
            local member_line = member.source_start_line
                or member.line

            if opts.allow_forward == true
                or type(reference_line) ~= "number"
                or type(member_line) ~= "number"
                or member_line <= reference_line
            then
                matches[#matches + 1] = member
            end
        end
    end

    if #matches == 0 then
        return {
            status = "unknown",
            name = name,
            reason = "source symbol declaration not found",
            machine_address_status = "unknown",
            machine_address_reason = "machine address unavailable",
        }
    end

    if #matches > 1 then
        local candidates = {}

        for _, member in ipairs(matches) do
            candidates[#candidates + 1] = {
                member_id = member.id,
                kind = member.kind,
                source_line = member.source_start_line or member.line,
                source_start_column = member.source_start_column,
            }
        end

        return {
            status = "unknown",
            name = name,
            reason = "source symbol declaration ambiguous",
            candidates = candidates,
            machine_address_status = "unknown",
            machine_address_reason = "machine address unavailable",
        }
    end

    return copy_member(
        matches[1],
        reference_line
    )
end

return M
