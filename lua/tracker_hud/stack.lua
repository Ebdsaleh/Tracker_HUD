-- lua/tracker_hud/stack.lua
--
-- Stack discovery / collection.
--
-- Stack v1 establishes the analyzer boundary for future stack tracking.
-- It currently returns no stack facts unless a future adapter/analyzer
-- provides them.

local core = require("tracker_hud.core")
local stack_model = require("tracker_hud.stack_model")

local M = {}


local function collect_adapter_stack_entries(entries, seen, context, adapter)
    if not core.is_table(adapter) or not core.is_table(adapter.stack) then
        return
    end

    local static_entries = adapter.stack.static or {}

    for _, entry_spec in ipairs(static_entries) do
        if core.is_table(entry_spec) then
            stack_model.add(entries, seen, {
                name = entry_spec.name,
                kind = entry_spec.kind,
                value = entry_spec.value,
                offset = entry_spec.offset,
                size = entry_spec.size,
                role = entry_spec.role,
                source = "adapter",
                metadata = {
                    adapter = adapter.name,
                    context = context,
                },
            })
        end
    end
end


function M.collect(context, adapter, opts)
    local entries = {}
    local seen = {}

    opts = opts or {}

    if opts.enabled == false then
        return entries
    end

    collect_adapter_stack_entries(entries, seen, context, adapter)

    table.sort(entries, function(left, right)
        return tostring(left.name or "") < tostring(right.name or "")
    end)

    return entries
end


return M
