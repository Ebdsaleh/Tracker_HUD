-- lua/tracker_hud/warnings.lua
--
-- Warning collection entry point for Tracker HUD.
--
-- Low-level state warnings are inferred from already-collected context facts by
-- tracker_hud.low_level.warning_infer. Tree-sitter/parser errors remain here
-- because they are editor/source diagnostics rather than low-level state facts.

local core = require("tracker_hud.core")
local warning_infer = require("tracker_hud.low_level.warning_infer")
local treesitter_errors = require("tracker_hud.treesitter_errors")

local M = {}


local function append_warnings(target, source)
    if not core.is_table(target) or not core.is_table(source) then
        return
    end

    for _, warning in ipairs(source) do
        table.insert(target, warning)
    end
end


function M.collect(context, adapter, opts)
    opts = opts or {}

    local warnings = warning_infer.collect(context, adapter)

    append_warnings(
        warnings,
        treesitter_errors.collect(opts.bufnr, opts.root_node, {
            cursor_line = context
                and context.cursor
                and context.cursor.line,

            scope_start_line = context and context.start_line,
            scope_end_line = context and context.end_line,

            filetype = opts.filetype,
            comments = core.is_table(adapter) and adapter.comments or nil,
        })
    )

    return warnings
end

return M
