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

local detailed =
    profile.begin_refresh(
        "CursorMoved",
        9,
        { 13, 4 },
        6000000
    )

profile.begin_phase(
    detailed,
    "context.registers",
    6000000
)
profile.end_phase(
    detailed,
    "context.registers",
    6000000,
    9000000
)

profile.begin_phase(
    detailed,
    "context.stack",
    6000000
)
profile.end_phase(
    detailed,
    "context.stack",
    6000000,
    7000000
)

profile.finish_refresh(
    detailed,
    {
        updated = true,
    },
    10000000
)

for index = 3, 12 do
    local sample =
        profile.begin_refresh(
            "CursorMoved",
            9,
            { 10 + index, 4 },
            index * 10000000
        )

    profile.finish_refresh(
        sample,
        {
            updated = true,
        },
        index * 10000000
            + 1000000
    )
end

local detailed_report =
    table.concat(
        profile.format_report(),
        "\n"
    )

assert(
    detailed_report:find(
        "#1 first_refresh line=12"
    )
        and detailed_report:find(
            "#12 cursor_step"
        ),
    "default report must retain at least 12 recent baseline samples:\n"
        .. detailed_report
)

assert(
    detailed_report:find(
        "top=%[context%.registers=3%.000 context%.stack=1%.000%]"
    ),
    "nested phase ranking changed:\n"
        .. detailed_report
)

print(
    "PASS analysis profile report: "
        .. "full baseline history and nested ranking preserved"
)

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
