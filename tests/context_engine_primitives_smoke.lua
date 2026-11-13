-- tests/context_engine_primitives_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_primitives_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local engine =
    require("tracker_hud.context_engine")

local primitives =
    require("tracker_hud.constructs.context_primitives")

assert(
    engine.make_global_context
        == primitives.make_global_context
        and engine.make_unavailable_context
            == primitives.make_unavailable_context
        and engine.get_cursor_position
            == primitives.get_cursor_position
        and engine.get_cursor_location
            == primitives.get_cursor_location,
    "context_engine cursor/context public delegates changed"
)
print("PASS context engine primitives: cursor/context delegates preserved")

assert(
    engine.position_in_node
        == primitives.position_in_node
        and engine.get_node_type
            == primitives.get_node_type
        and engine.get_first_node_line
            == primitives.get_first_node_line
        and engine.get_node_range
            == primitives.get_node_range,
    "context_engine node public delegates changed"
)
print("PASS context engine primitives: node delegates preserved")

assert(
    engine.build_scope_entry_from_construct
        == primitives.build_scope_entry_from_construct
        and engine.build_context_from_scopes
            == primitives.build_context_from_scopes,
    "context_engine scope public delegates changed"
)
print("PASS context engine primitives: scope delegates preserved")

print("PASS Tracker_HUD context-engine primitives smoke")
