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

Use the committed repeatable fixture:

~~~
samples/asm/x86_64/performance_baseline.asm
~~~

It is intentionally 150+ lines and contains stable profile markers:

- PROFILE MARKER A: line 34
- PROFILE MARKER B: line 67
- PROFILE MARKER C: line 103

The A -> C movement is therefore a >=50-line jump under the default profiler
threshold.

1. Open the fixture normally with Tracker_HUD active.

2. Reset and enable capture:

~~~vim
:HudProfile reset
:HudProfile on
~~~

3. Move to marker A:

~~~vim
:34
~~~

This is the first captured refresh after reset.

4. Move down exactly one line:

~~~vim
:+1
~~~

5. Jump to marker C:

~~~vim
:103
~~~

This must classify as a large cursor jump.

6. Make one harmless edit near the start of the file and undo it. For example:

~~~vim
:2s/Synthetic/SyntheticX/
u
~~~

7. Change the platform directive and undo it:

~~~vim
:14s/platform=linux/platform=windows/
u
~~~

The directive edit intentionally exercises adapter target reconfiguration.

8. Display the report:

~~~vim
:HudProfile
~~~

9. Copy the complete report into the relay acceptance output.

10. Disable capture after copying the report:

~~~vim
:HudProfile off
~~~

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

## Context subphase measurement refinement

The first ERIDU run proved that outer `context` analysis dominates average
refresh cost, but the original report only retained eight recent samples and did
not identify which context collector owns that cost.

The refined profiler now:

- retains 16 recent samples by default, enough for the standard run;
- records parser/configuration/scope setup separately;
- records visible and all-scope member collection separately;
- records the normal register reduction separately;
- records the pre-current-line register reduction separately;
- records stack, boundary and instruction-event reductions separately;
- records source-memory, events, heap and warnings separately;
- prints the four most expensive nested phases for each recent sample.

Repeat the same exact interactive sequence in this document after the refined
code gate passes.

The next architecture decision should be based on the nested timings, not only
the outer `context` total.
