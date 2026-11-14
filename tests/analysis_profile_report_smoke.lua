-- tests/analysis_profile_report_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/analysis_profile_report_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.analysis_profile"
] = nil

local profile =
    require(
        "tracker_hud.analysis_profile"
    )

local config =
    require(
        "tracker_hud.config"
    )

assert(
    config.defaults.analysis
        .profile.enabled == false
        and config.defaults.analysis
            .profile.max_samples
            == 256
        and config.defaults.analysis
            .profile.large_jump_lines
            == 50,
    "analysis-profile config defaults changed"
)
print("PASS analysis profile report: opt-in defaults preserved")

profile.configure({
    enabled = true,
    max_samples = 8,
    large_jump_lines = 50,
})

local token =
    profile.begin_refresh(
        "CursorMoved",
        9,
        { 12, 4 },
        0
    )

local phase =
    profile.begin_phase(
        token,
        "context",
        0
    )

profile.end_phase(
    token,
    "context",
    phase,
    2500000
)

phase =
    profile.begin_phase(
        token,
        "render",
        2500000
    )

profile.end_phase(
    token,
    "render",
    phase,
    4000000
)

profile.finish_refresh(
    token,
    {
        updated = true,
    },
    5000000
)

local report =
    table.concat(
        profile.format_report({
            recent = 2,
        }),
        "\n"
    )

assert(
    report:find(
        "Tracker_HUD profile: on, 1 refresh%(es%)"
    )
        and report:find(
            "Reasons: first_refresh=1"
        )
        and report:find(
            "context: n=1 avg=2%.500 ms max=2%.500 ms"
        )
        and report:find(
            "render: n=1 avg=1%.500 ms max=1%.500 ms"
        )
        and report:find(
            "#1 first_refresh line=12"
        ),
    "profile report formatting changed:\n"
        .. report
)
print("PASS analysis profile report: summary and recent sample rendered")

profile.reset()

local reset =
    profile.snapshot()

assert(
    reset.refresh_count == 0
        and #reset.samples == 0
        and next(reset.reasons) == nil
        and next(reset.phases) == nil,
    "profile reset changed"
)
print("PASS analysis profile report: reset clears samples and aggregates")

print("PASS Tracker_HUD analysis-profile report smoke")
