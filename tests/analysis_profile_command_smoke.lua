-- tests/analysis_profile_command_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/analysis_profile_command_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.analysis_profile"
] = nil
package.loaded[
    "tracker_hud"
] = nil

local profile =
    require(
        "tracker_hud.analysis_profile"
    )

local tracker =
    require("tracker_hud")

local old_notify =
    vim.notify

vim.notify = function()
end

tracker.setup({
    keymaps = {
        enabled = false,
    },
    analysis = {
        profile = {
            enabled = false,
            max_samples = 16,
            large_jump_lines = 5,
        },
    },
})

assert(
    vim.fn.exists(":HudProfile")
        == 2,
    "HudProfile command was not registered"
)
print("PASS analysis profile command: command registered")

vim.cmd("HudProfile on")

assert(
    profile.is_enabled()
        == true,
    "HudProfile on did not enable capture"
)
print("PASS analysis profile command: on enables capture")

local token =
    profile.begin_refresh(
        "CursorMoved",
        4,
        { 1, 0 },
        0
    )

profile.finish_refresh(
    token,
    {
        updated = true,
    },
    1000000
)

assert(
    profile.snapshot()
        .refresh_count == 1,
    "profile command smoke could not seed sample"
)

vim.cmd("HudProfile reset")

assert(
    profile.snapshot()
        .refresh_count == 0,
    "HudProfile reset did not clear samples"
)
print("PASS analysis profile command: reset clears samples")

vim.cmd("HudProfile off")

assert(
    profile.is_enabled()
        == false,
    "HudProfile off did not disable capture"
)
print("PASS analysis profile command: off disables capture")

vim.cmd("HudProfile show")

vim.notify = old_notify

print("PASS analysis profile command: show executes")
print("PASS Tracker_HUD analysis-profile command smoke")
