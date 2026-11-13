-- tests/context_engine_construct_identity_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/context_engine_construct_identity_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local engine =
    require("tracker_hud.context_engine")

local identity =
    require("tracker_hud.constructs.source_identity")

assert(
    engine.get_first_line_text
        == identity.get_first_line_text
        and engine.build_signature
            == identity.build_signature
        and engine.extract_name_from_signature
            == identity.extract_name_from_signature
        and engine.extract_name_from_syntax
            == identity.extract_name_from_syntax
        and engine.build_construct
            == identity.build_construct,
    "context_engine construct source-identity public delegates changed"
)
print("PASS context engine construct identity: public delegates preserved")

print("PASS Tracker_HUD context-engine construct-identity smoke")
