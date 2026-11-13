-- tests/context_engine_construct_validation_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_construct_validation_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local engine =
    require("tracker_hud.context_engine")

local validation =
    require("tracker_hud.constructs.spec_validation")

assert(
    engine.get_construct_spec
        == validation.get
        and engine.validate_construct_spec
            == validation.validate,
    "context_engine construct-validation public delegates changed"
)
print("PASS context engine construct validation: public delegates preserved")

print("PASS Tracker_HUD context-engine construct-validation smoke")
