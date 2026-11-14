# Tracker_HUD ERIDU performance baseline

**Purpose:** measure current refresh costs before adding incremental checkpoints
or moving more architecture/ABI effect ownership.

This is an observational baseline. Do not interpret it as a benchmark of Neovim
itself, and do not turn wall-clock values into pass/fail CI thresholds.

## Instrumented phases

Tracker_HUD records:

- `context`: source/context analysis through `context.get_cursor_context`;
- `state`: publication through `state.update_source`;
- `render`: HUD panel rendering;
- `hex`: source hexadecimal-width refresh;
- `total`: complete tracked refresh.

Refresh reasons are classified as:

- `first_refresh`
- `buffer_enter`
- `cursor_step`
- `cursor_move`
- `cursor_large_jump`
- `cursor_same_line`
- `edit`
- `manual`

The default large-jump threshold is 50 source lines.

Profiling is **off by default**.

## Commands

Using the default namespace:

~~~vim
:HudProfile on
:HudProfile off
:HudProfile reset
:HudProfile
:HudProfile show
~~~

The report includes aggregate averages/maxima plus recent individual samples.

## Repeatable ERIDU scenario

Use the same representative ASM sample for each comparison.

1. Reset and enable capture:

~~~vim
:HudProfile reset
:HudProfile on
~~~

2. Force a first refresh by reopening the source buffer or re-entering its
   window.

3. Move down exactly one source line.

4. Make a large cursor jump of at least 50 lines.

5. Edit a line near the beginning of the file, then undo it.

6. Change a target/source directive that causes adapter target configuration to
   be reconsidered, then undo it.

7. Display the report:

~~~vim
:HudProfile
~~~

8. Copy the report into the relay acceptance output.

## Interpretation

The initial question is not "is Tracker_HUD fast?" It is:

- which phase dominates each interaction;
- how much work repeats for one-line cursor movement;
- whether a large jump scales differently;
- whether edits near the beginning cause disproportionate replay;
- whether target-directive changes are materially more expensive;
- whether render/hex work is significant compared with source/context analysis.

Only after these measurements should an incremental checkpoint design be chosen.

If `context` dominates repeated cursor movement, checkpoint/replay work is
justified. If rendering dominates, caching source-state alone will not solve the
observed cost.

## Safety

Profiling must not change:

- ON/PAST cursor visibility;
- parser selection;
- adapter target configuration;
- register/stack/boundary/event inference;
- source-time address certainty;
- HUD section contents.

Leave profiling off during normal use unless measurements are needed.
