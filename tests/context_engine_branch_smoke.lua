-- tests/context_engine_branch_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_branch_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local engine =
    require("tracker_hud.context_engine")

local branch =
    require("tracker_hud.constructs.branch_presentation")

assert(
    engine.format_branch_display_label
        == branch.format_display_label
        and engine.node_matches_branch_alternative
            == branch.node_matches_alternative
        and engine.get_node_alternatives
            == branch.get_node_alternatives
        and engine.get_branch_alternative_label
            == branch.get_alternative_label
        and engine.build_branch_display_label
            == branch.build_display_label,
    "context_engine branch public delegates changed"
)
print("PASS context engine branch: public delegates preserved")

print("PASS Tracker_HUD context-engine branch smoke")
