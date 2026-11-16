-- tests/analysis_profile_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/analysis_profile_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.analysis_profile"
] = nil

local profile =
    require(
        "tracker_hud.analysis_profile"
    )

profile.configure({
    enabled = true,
    max_samples = 3,
    large_jump_lines = 10,
})

local function record(
    event,
    line,
    started,
    context_end,
    finished
)
    local token =
        profile.begin_refresh(
            event,
            7,
            { line, 0 },
            started
        )

    local phase =
        profile.begin_phase(
            token,
            "context",
            started
        )

    profile.end_phase(
        token,
        "context",
        phase,
        context_end
    )

    profile.finish_refresh(
        token,
        {
            updated = true,
        },
        finished
    )

    return token
end

local first =
    record(
        "BufWinEnter",
        1,
        0,
        1000000,
        4000000
    )

assert(
    first.reason
        == "first_refresh"
        and first.total_ms == 4,
    "first refresh classification/timing changed"
)
print("PASS analysis profile: first refresh classified and timed")

local step =
    record(
        "CursorMoved",
        2,
        10000000,
        12000000,
        15000000
    )

assert(
    step.reason
        == "cursor_step"
        and step.line_delta == 1
        and step.phases.context
            == 2,
    "cursor-step classification/timing changed"
)
print("PASS analysis profile: cursor step classified")

local jump =
    record(
        "CursorMoved",
        30,
        20000000,
        23000000,
        26000000
    )

assert(
    jump.reason
        == "cursor_large_jump"
        and jump.line_delta == 28,
    "large-jump classification changed"
)
print("PASS analysis profile: large jump classified")

local edit =
    record(
        "TextChanged",
        30,
        30000000,
        31000000,
        34000000
    )

assert(
    edit.reason == "edit",
    "edit classification changed"
)
print("PASS analysis profile: edit classified")

local snapshot =
    profile.snapshot()

assert(
    snapshot.refresh_count == 4
        and snapshot.reasons
            .first_refresh == 1
        and snapshot.reasons
            .cursor_step == 1
        and snapshot.reasons
            .cursor_large_jump == 1
        and snapshot.reasons
            .edit == 1,
    "profile reason aggregation changed"
)

assert(
    #snapshot.samples == 3
        and snapshot.samples[1]
            .reason
            == "cursor_step",
    "profile sample cap changed"
)

assert(
    snapshot.phases.context.count
            == 4
        and snapshot.phases.context
            .average_ms
            == 1.75
        and snapshot.phases.total
            .max_ms
            == 6,
    "profile phase aggregation changed"
)
print("PASS analysis profile: aggregation and sample cap preserved")

local repeated =
    profile.begin_refresh(
        "CursorMoved",
        99,
        { 1, 0 },
        40000000
    )

local repeated_one =
    profile.begin_phase(
        repeated,
        "loop_work",
        40000000
    )

profile.end_phase(
    repeated,
    "loop_work",
    repeated_one,
    41000000
)

local repeated_two =
    profile.begin_phase(
        repeated,
        "loop_work",
        42000000
    )

profile.end_phase(
    repeated,
    "loop_work",
    repeated_two,
    44000000
)

profile.finish_refresh(
    repeated,
    {
        updated = true,
    },
    45000000
)

assert(
    repeated.phases.loop_work
        == 3
        and profile.snapshot()
            .phases.loop_work
            .average_ms == 3,
    "repeated phase timings did not accumulate within one refresh"
)
print("PASS analysis profile: repeated phase timings accumulate")

profile.set_enabled(false)

assert(
    profile.begin_refresh(
        "CursorMoved",
        7,
        { 31, 0 },
        50000000
    ) == nil,
    "disabled profiling must not allocate a refresh token"
)
print("PASS analysis profile: disabled path is inert")

print("PASS Tracker_HUD analysis-profile smoke")