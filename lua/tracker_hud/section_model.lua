-- lua/tracker_hud/section_model.lua
--
-- Generic section record construction helpers.
--
-- Concrete section models extend this baseline with their own fields,
-- normalization, semantics, and labeling.

local core = require("tracker_hud.core")

local M = {}


function M.new(opts, default_id_prefix)
    opts = opts or {}

    local name = opts.name

    if not core.is_non_empty_string(name) then
        return nil
    end

    local prefix = opts.id_prefix or default_id_prefix or "section"

    return {
        id = opts.id or (prefix .. ":" .. name),
        name = name,
        kind = opts.kind or "unknown",
        value = opts.value,
        role = opts.role,
        source = opts.source,

        source_line = opts.source_line,
        source_column = opts.source_column or 0,
        source_start_line = opts.source_start_line or opts.source_line,
        source_start_column = opts.source_start_column or opts.source_column or 0,
        source_end_line = opts.source_end_line or opts.source_line,
        source_end_column = opts.source_end_column or opts.source_column or 0,

        metadata = opts.metadata or {},
    }
end


function M.add(entries, seen, entry)
    if not core.is_table(entries) or not core.is_table(entry) then
        return nil
    end

    seen = seen or {}

    if seen[entry.id] then
        return nil
    end

    seen[entry.id] = true

    table.insert(entries, entry)

    return entry
end


return M
