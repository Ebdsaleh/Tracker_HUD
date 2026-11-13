-- tests/context_engine_construct_parser_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_construct_parser_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local engine =
    require("tracker_hud.context_engine")

local parser =
    require("tracker_hud.constructs.parser")

assert(
    engine.match_node
        == parser.match_node
        and engine.parse_node
            == parser.parse_node,
    "context_engine construct parser public delegates changed"
)
print("PASS context engine construct parser: public delegates preserved")

print("PASS Tracker_HUD context-engine construct-parser smoke")
