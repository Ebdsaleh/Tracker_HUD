-- Tracker_HUD Lua adapter validation sample.
--
-- Expected parser-backed behavior:
-- - function declarations and calls map to constructs;
-- - locals, parameters, loop variables, assignments, returns, and table
--   fields appear as Scope Members;
-- - branch/loop/table scopes come from real Tree-sitter syntax.

local START_VALUE = 2

local function update(value)
    local total = value

    for index = 1, 3 do
        total = total + index
    end

    local record = {
        name = "tracker",
        count = total,
    }

    if total > 0 then
        return record.name
    end

    return nil
end

local result = update(START_VALUE)
