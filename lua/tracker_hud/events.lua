-- lua/tracker_hud/events.lua

-- Event collection entry point.
--
-- Events are meaningful instruction/runtime/API actions that are not always
-- direct register, stack, or heap state.
--
-- Examples:
--   - syscall boundary entered
--   - cpuid processor query
--   - memory fence / serialization instruction
--   - future runtime/API calls such as malloc/free/Instantiate/SpawnActor

local event_model = require("tracker_hud.event_model")

local M = {}

function M.collect(context)
    if type(context) ~= "table" then
        return {}
    end

    return event_model.normalize_events(context.events)
end

return M
