# Shared architecture profiles — incremental migration handoff

**Date:** 2026-11-09  
**Repository:** `Ebdsaleh/Tracker_HUD`  
**Branch policy:** use `main` for this work; do not create additional branches.  
**Acceptance host:** ERIDU, Windows / Neovim (actual Tree-sitter parser versions on ERIDU).  

## Why

Tracker_HUD began as an ASM cursor-time state/effect inspector, but its
intended design is now a language-independent **cursor-time source-state
inspector**, using language adapters and reusable machine architecture
profiles. Avoid implementing a separate monolithic CPU model in each
language adapter.

Fast feedback and preserving correctness are equal design requirements.
A large source-code file on a 32-GB machine can still be slow when AST
traversals and state replay happen on every cursor update. Separating
modules alone is not a benchmark or proof of better runtime performance.

## Existing architecture at the start of this migration

- ASM `adapters/asm/adapter.lua` selects the x86-64 variant. Its
  `apply_variant` copied `registers`, `register_families`,
  `register_effects`, `stack_effects`, `boundary_effects`,
  `instruction_events`, etc., to the normal adapter interface.
- `adapters/asm/arch/x86_64/adapter.lua` held the static register tables
  alongside architecture metadata, presentation, ISA/ABI definitions
  and references to several categories of effect rules.
- `sections/low_level/registers.lua` and
  `sections/low_level/register_model.lua` already implement generic
  Registers collection/presentation. `low_level/inference.lua` already
  provides language-neutral fact/state primitives.
- `context_engine.lua` already caches the mnemonic-indexed
  register-effect rule index. **Do not remove this existing index.**
- In `context_engine.collect_register_effects`, every collection
  gathers matching syntax nodes up through the cursor, sorts them
  and reduces register effects from scratch. This is a plausible
  hot path when moving a cursor in large ASM files, not yet benchmarked.
- `register_model.resolve_alias` searched every register family to
  find an alias. This is an unnecessary repeated lookup for a static
  hardware description.
- `context.lua` invokes distinct collectors for scope members,
  registers, stack, boundary effects and instruction events. Several
  may traverse overlapping syntax. Don't assume they are redundant
  without profiling.
- `analysis_cache.lua` and `:HudCacheLimit` already exist, but
  the documented 200-line default is **not proof** that all ASM
  effect collectors use incremental analysis.

## Tranche 1 — implemented, pushed to main (ERIDU acceptance pending)

### Files

1. **New** `lua/tracker_hud/architectures/x86_64/registers.lua`
   - Contains verbatim migrated `M.register_families` and
     `M.registers` data from the existing ASM x86-64 variant.
   - Preserves all 50 original static register rows, register roles,
     aliases, widths, offsets, write modes and ordering.
   - Builds `M.register_alias_index` once from these same tables.
   - No ASM parser, Tree-sitter, UI, or source-state inference dependency.
2. **New** `lua/tracker_hud/architectures/registry.lua`
   - Lazy resolution of `x86-64`, `x86_64`, `amd64`, `x64`.
   - Unknown architectures return `nil`; no host-target guessing.
   - Currently exposes **register profile facts**, not full ISA
     or compiler state.
3. **Changed** `lua/tracker_hud/adapters/asm/arch/x86_64/adapter.lua`
   - Removes the two duplicated static register tables.
   - Resolves the shared architecture profile and keeps the
     original public `M.register_families`, `M.registers` fields.
   - Exposes the new optional `M.register_alias_index`.
   - All instruction, boundary, stack, scope and warning rules
     remain in their previous locations.
4. **Changed** `lua/tracker_hud/adapters/asm/adapter.lua`
   - Propagates `register_alias_index` through `apply_variant`,
     clearing the field on profiles without that index.
5. **Changed** `lua/tracker_hud/sections/low_level/register_model.lua`
   - Uses `adapter.register_alias_index` for O(1) name lookup
     when available.
   - Retains legacy family scan for any adapter without an index.
6. **New** `tests/architecture_registry_smoke.lua`
   - Independent lazy-load/registry checks.
   - Verifies ASM variant/master adapter still share source tables.
   - Compares every indexed alias result with the legacy scan,
     including aliases, bit sizes, offsets and write modes.
   - Verifies `eax` zero extension, `ah` high-byte partial writes,
     case-insensitivity, unknown names, row count and row order.
7. **New** `tests/architecture_alias_benchmark.lua`
   - Optional, non-gating lookup microbenchmark that runs indexed
     lookups against the previous family-scan fallback.
   - Reports times on ERIDU; it is **not** a full HUD benchmark
     and has no unstable wall-clock acceptance threshold.

### Explicitly unchanged

- ASM's full instruction-effect specification and mnemonic matching.
- ASM's source directive parsing / platform / ABI selection.
- Cursor-time `ON IT or PAST IT` visibility, including position-specific
  instruction operand behaviour.
- Stack/Heap/Events/Warnings inference.
- HUD section ordering, colours, Inspect selection and expansion.
- C, C++, Python and Lua parsing/analysis semantics.
- No speculative C/C++ register assignments from source code.

**Important design debt:** Some static register descriptions currently
include role wording inherited from ABI concerns. Preserve that wording
during this first no-semantic-change extraction. Separate ISA truth
from ABI-specific calling conventions in a later independently tested
tranche, so a Win64 target is not told that Linux syscall roles are
universally true.

## Required ERIDU verification

From a clean working tree at the repository root:

```bat
git status --short
git pull --ff-only
git log -6 --oneline
nvim --headless -u NONE -c "luafile tests/architecture_registry_smoke.lua"
nvim --headless -u NONE -c "luafile tests/architecture_alias_benchmark.lua"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
```

For ASM visual and effect acceptance, inspect:

```bat
nvim samples/asm/x86_64/memory_operand_validation.asm
```

Then inspect an existing x86-64 sample with `mov eax`, high-byte
register aliases, calls/returns and a syscall. Confirm register
values/alias labels, flags and stack/boundary effects remain unchanged.
If a sample path differs in the working tree, use the actual file
under `samples/asm` rather than inventing a substitute.

The C/C++ directive and memory-observation tests remain separate,
previously unverified acceptance gates:

```bat
nvim --headless -u NONE -c "luafile tests/c_cpp_source_directives_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_memory_observation_smoke.lua"
```

**At handoff time:** GitHub files were updated and source structure
inspected; this environment cannot run ERIDU's Neovim suite. Do not
report the new tranche green until ERIDU returns its output.

## Architectural target (not yet implemented)

```text
             Tracker_HUD core / shared state + HUD
                          |
       +------------------+----------------------+
       |                                         |
 Language/source adapter                 Architecture profile
 ASM, C, C++, Python, Lua                x86-64, future SH-4, etc.
 Tree-sitter -> source facts             register banks, aliases, ISA
       |                                         |
       +------------------+----------------------+
                          |
                  ABI / platform profile
                 calling convention, effects
                          |
              shared incremental state engine
                          |
               existing seven HUD sections
```

Source adapters describe the source language's syntax. Architecture
profiles describe the target hardware. ABI/platform profiles describe
calling conventions and operating-system boundaries. The inference
engine combines those with cursor-visible source facts. For high-level
languages, without compiler output, don't infer physical register
allocation or live pointer addresses from source alone.

## Proposed drip-feed sequence

- **Tranche 1** (this change): shared register facts, alias index,
  compatibility parity test. No ISA or cursor-state rewrite.
- **Tranche 2** (next after green): instrument actual costs
  (initial load, first HUD refresh, cursor up/down, large cursor jump,
  edit near the start, and restart after target directive changes).
  Capture times and cache hit/replay counts, not just memory use.
- **Tranche 3**: move ISA/register/stack/boundary effect table ownership
  behind an architecture/ABI interface without changing which rules
  are matched. Preserve existing mnemonic-index caching and tests.
  Evaluate lazy loading only if measurements support it.
- **Tranche 4**: incremental source-state checkpoints with strict
  invalidation on edits, buffer identity, changed target directives,
  changed parsers and mode/ABI changes. Retain exact cursor-position
  semantics and avoid displaying undiscovered facts.
- **Tranche 5**: allow C/C++ to use architectural truths without
  implying compiled register allocation; expand memory ownership
  inference only when static proof and warnings can be trusted.
- **Future**: additional architecture profiles and performance
  budgets based on ERIDU measurements.

## Regression rules

1. Never delete, comment out or weaken a failing test to get green.
2. Continue on `main` only; no surprise branches.
3. Preserve all ASM inference depth. Architecture extraction is not
   permission to trim instruction coverage.
4. Unknown or unresolved must remain distinct from known zero, nil,
   or false. Do not invent register values or claim proven memory leaks
   from simple source observations.
5. A cached fact must remain hidden until the source cursor reaches
   its declaration/occurrence (ON IT OR PAST IT).
6. Profile/ABI state must be safely isolated by target/buffer; do not
   let a configuration in one file corrupt another.
7. Each small tranche needs source checks, relevant Neovim smoke tests
   and a new handoff entry *before* the next migration.

## Previous acceptance state

- ERIDU previously reported C parser discovery: 15 source members;
  C++ parser discovery: 28, with ON/PAST source visibility.
- Visual section colour design accepted by user, including garnet
  Registers, gold Stack, copper Heap and theme-linked titles.
- The new architecture smoke is pending ERIDU execution. The
  C/C++ memory-observation and source-directive tests have not been
  conclusively accepted in the available handoff.


## ERIDU validation and ASM focus report (2026-11-09)

The user ran tranche-one acceptance on ERIDU:
- Architecture smoke PASS: 164 aliases, 50 static rows, indexed/legacy
  parity. This was interrupted to exit headless Neovim; the PASS was
  printed, but the process exit wasn't clean due to missing `-c "qa!"`.
- Optional alias benchmark (80,000 lookups/path):
  legacy scan 19.403 ms, indexed 2.142 ms (~9.06x on this
  microbenchmark only). Do not extrapolate to HUD redraw.
- Adapter contract smoke PASS (Lua, Python, C, C++, section order).
- Visual-language smoke PASS; user accepts inactive colours and
  selection visuals.
- C/C++ parser smoke PASS (C 15, C++ 28 facts and ON/PAST visibility).
- Git fast-forward to `9e672f5` worked; automatic pack cleanup
  reported unlink errors on Windows, probably file locks. Do not
  manually delete Git pack files.

**Outstanding ASM observation:** In
`samples/asm/x86_64/memory_operand_validation.asm`, user screenshots
show Registers missing the expected `*` source focus when the cursor
moves across `mov rax, [rbp + rax*4 - 8]`, though register data for
`rbp` and `rsi` still appears. This is *not* explained by the
`asm-lsp.toml` warning: it is an LSP configuration message separate
from Tracker_HUD's Tree-sitter analysis. The alias parity smoke proves
static data survived, not per-column focus selection.

Pre- and post-refactor comparisons confirm the register definitions
were copied verbatim and the ASM architecture variant's surrounding
instruction/stack sections were unchanged. Neither disproves nor
confirms a cursor-selection regression.

**New focused diagnostic**
`tests/asm_register_focus_regression.lua` was added to `main`. It
loads the actual ASM Tree-sitter parser and reports the source occurrence
ranges and state IDs on `mov rbp, rsp`, `mov rax, [rbp + rax*4 - 8]`,
`mov [rsp + 8], rax` and `lea rsi, [rel msg]`. It asserts that the
expected register target IDs exist. If it passes while the interactive
HUD doesn't highlight the selected register, inspect the HUD
selection/refresh chain next; if it fails, repair source occurrence
discovery. No production register-effect changes made for this issue.

```bat
git status --short
git pull --ff-only
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_registry_smoke.lua" -c "qa!"
```

**Gate:** Do not proceed with the second architecture migration
tranche until this issue is explained and either resolved or
demonstrably pre-existing. Do not change branches or trim ASM analysis.


## ASM memory-operand source inspection — narrower expected behaviour (2026-11-09)

The user's independent desktop `test.asm` screenshots confirm ordinary
register displays still function for examples such as `mov rax, 60`,
`xor rdi, rdi` and `syscall` on the version that was tested.
That does **not** mean the more complex memory-operand fixture must
be interpreted the same way, nor does it prove the shared-register
refactor introduced the missing source focus.

The new parser-backed test on ERIDU initially failed at:
`missing source occurrence register:rax on line 27` for
`mov rax, [rbp + rax*4 - 8]`. This establishes a gap in the
*source-occurrence* path on the validation fixture.

**Intended nuance:** Source-token discovery is different from inferred
runtime register value. On that line, the first `rax` is the
destination, `rbp` the base register, and the second `rax` the
index register. Identifying all three does not mean the loaded
memory value is known or that each address component is written.

**Bounded code change committed on `main`:**
`context_engine.discover_register_source_occurrences` no longer
requires an instruction to match a semantic register-effect rule before
attempting operand and memory-component source discovery. Semantic
effect matching still owns inferred register writes and roles, and
mnemonic-level semantic targets are **not** populated with all source
registers simply because the matcher lacks a rule.

The regression test was tightened to assert distinct occurrences
for destination `rax`, base `rbp` and index `rax` on the
same instruction. It now iterates fixture cases deterministically.
These changes have **not** been accepted on ERIDU; do not claim green.

```bat
git status --short
git pull --ff-only
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_registry_smoke.lua" -c "qa!"
```

After a green result, manually inspect each token of the memory
expression and compare cursor focus and unknown/known values with
the original desktop sample. If the parser-backed test fails,
trace the parser's operand/component extraction. If the test passes
but the HUD misbehaves, inspect the selection/refresh pipeline.

**Do not migrate another architecture subsystem until this behaviour
is explained.** Preserve existing ASM depth and avoid treating a
register's syntactic presence as proof of its runtime value.


## Accessibility, interchangeable presentations and structured facts (2026-11-09)

### Permanent product objective — not just an ASM inspector

**Tracker_HUD is a cursor-time source, state and effect explorer for any
supported language and target, designed as an accessibility-first
learning tool as well as an advanced development aid.** The ultimate
audience includes first-time programmers (including children roughly
age 10+), people with cognitive/learning disabilities, overwhelmed
developers, and expert low-level programmers. Avoid assuming one reading
level or one preferred density.

The deep ASM analysis is an **asset**, not dead weight to trim. In the
first pass the UI renders this detail as text; later presentations
may show registers with byte/bit cells, arrows, pictures, animations and
other intuitive teaching metaphors. All visualisations must be faithful
to real architectural widths and known/unknown values.

Example `mov rax, 60`: a future 64-bit visual register can show the
known value 0x000000000000003C in eight byte cells, rather than implying
that the number 60 occupies a single byte at an arbitrary location.
A learning view may explain “the instruction writes 60 to RAX”.
A technical view retains aliases, source roles and confidence.

### Two orthogonal axes of presentation

1. **Meaning/detail preset** (new, future-facing): standard/expert
   source facts, learning explanation, eventually visual diagrams. A
   person must be able to switch **at runtime** without reopening files,
   changing cursor, changing Inspect section, losing expansion
   selections, or re-analysing/replaying the code solely to switch view.
   Use an explicit, namespace-aware command and an optional keymap.
   There must be an obvious route back to the existing text HUD.
2. **Terminal/colour encoding** (already implemented):
   `:HudVisualMode auto|rich|tagged|markers|plain` and terminal-aware
   semantic highlights. **Do not overload/redefine this command** as
   a teaching/detail-mode selector.

The existing `Inspect: <section>` cycles the target sections; it is
**not** a presentation-mode selector. All these controls must be
independent. Avoid forcing images, animations, colours, colour-only
meaning or dense charts on users. Respect reduced-motion/low-colour
capabilities when graphical modes eventually exist.

### Normalized semantic fact contract (v1 proposal)

Language adapters continue reporting source facts. Architecture/ABI
profiles supply machine truths. An inference engine emits normalized
facts with unambiguous fields. A presenter consumes *snapshots*, not
live mutable inference tables. Suggested minimal v1:

```lua
{
  id = "stable-fact-identity",
  kind = "register", -- memory | event | warning | stack | heap later
  subject = { kind = "register", name = "rax", architecture = "x86-64" },
  source = { buffer = 9, line = 12, start_column = 4, end_column = 7 },
  effect = { operation = "write", role = "destination" },
  value = { status = "known", data = 60 }, -- or status="unknown"
  provenance = { kind = "inferred", rule = "mov-immediate" },
}
```

Contract obligations:

- Distinguish `known`, `unknown`, `partial`, and
  `conditional` / uncertain. `false`, `0`, and valid `nil`
  language values must not be mistaken for missing data.
- Do not invent CPU runtime values, heap addresses or control-flow
  outcomes when source alone cannot establish them.
- Include source position, cursor-known-through position, evidence
  and provenance; **ON the declaration/effect or PAST it** means
  eligible for discovery. Future cached data must not leak.
- Register/flag architecture descriptions must not be confused with
  ABI overlays (Linux syscall vs Win64 etc.).
- Any view must consume the same fact identity; the display may
  differ but not the underlying truth or certainty.
- Normalize incrementally; adapt one section without forcing
  all existing adapters or renderers to switch immediately.
- Presentation conversion must be cheap and must not invoke the
  parser or semantic inference on its own.

### Safe implementation sequence (after handoff update)

**A. Fact contract foundation:** add an isolated, pure Lua normalized
fact module with validation, value certainty and source discovery gates;
build regression coverage for unknown vs zero, ON/PAST and no leaks.
No immediate replacement of existing ASM rules or HUD renderer.

**B. Runtime presentation control:** introduce distinct, namespace-aware
`:HudPresentation` / cycle interface with a backwards-compatible
`standard` mode and first accessible `learning` text view.
Switching changes rendering of an existing context immediately;
the source cursor and Inspect state stay intact. Preserve current
existing colours, controls and default output. Never expose an
unimplemented graphical renderer as if functional.

**C. First fact consumer:** translate a bounded register example into
a normalized fact and readable instructional wording; verify that
unknown memory loads never claim a numeric result. Keep the richer
underlying details available in standard/expert mode.

**D. Future:** multiple display surfaces (byte-cells, animation,
graphical) with the same facts, interaction commands, semantic colours,
terminal fallback, user theme overrides, screen-reader-friendly
text equivalents, reduced-motion and per-user complexity settings.

### Gates and reminders

- Existing **ASM memory-token source-occurrence regression** is still
  awaiting ERIDU verification on latest `main`. Do not assert it
  passed, and do not change ASM inference as part of the UI work.
- C/C++ parser and visual smoke tests have passed on ERIDU. Preserve
  their contracts and all existing adapter-specific sections.
- Keep `main / dev / test` branch policy; no new branches.
- Small commits and a fresh handoff after each batch.
- New UI/presentation tests must prove switching and switching back
  retain source position, Inspect selection and existing output.


## Tranche: structured facts + live learning presentation (2026-11-09)

**Handoff-first policy fulfilled:** this objective was recorded in
commit `02a6fba` before the implementation work began.

### Added on main (ERIDU execution pending)

- `lua/tracker_hud/facts/contract.lua` — pure Lua language-neutral fact
  schema for register/memory/stack/heap/event/warning kinds; explicit
  known/unknown/partial/conditional values; exact source-column ON/PAST
  discovery; detached copies of inputs. Known zero and false are not
  mistaken for unknown; known `nil` is explicit `is_nil=true`.
- `lua/tracker_hud/presentation_mode.lua` — independent
  `standard` / `learning` / `cycle` reading presets. Does not change
  current Inspect section or `:HudVisualMode` colour/tag mode.
- `lua/tracker_hud/presenters/learning.lua` — first text-only
  educational lens, using a normalized register fact snapshot.
  Selected source-state facts can show one short explanation; unknown
  and symbolic values are explicitly not presented as confirmed
  numeric values. Static architectural definitions are not mistaken
  for newly inferred source effects.
- `lua/tracker_hud/config.lua` — default `presentation.mode =
  "standard"`; optional `keymaps.cycle_presentation_mode` mapping
  disabled by default to avoid user-keymap conflicts.
- `lua/tracker_hud/init.lua` — namespaced `:HudPresentation`
  command supports `standard`, `learning`, `cycle`, and no-args
  status. Toggles trigger `hud.update_panel()` with cached context;
  they do not run `context.get_cursor_context()` just to switch
  explanation mode.
- `lua/tracker_hud/hud.lua` — learning-only educational lines appear
  above normal sections. `standard` follows the old output branch.
- `lua/tracker_hud/sections/low_level/registers.lua` and
  `register_model.lua` — additive preservation of the inference
  `resolved` flag through existing section records, without changing
  the legacy register label or effect rules.
- `tests/normalized_fact_contract_smoke.lua` and
  `tests/presentation_modes_smoke.lua` — new tests for source
  discovery, certainty, configuration isolation, namespace cleanup,
  cached-context redraw and preservation of Inspect and expanded
  sections.
- `docs/semantic_fact_contract.md`, `docs/visual_language.md`,
  `README.md` — public API, facts and accessibility roadmap.

**Important source-column nuance:** the ASM/Tree-sitter token record
stores a zero-based column, but
`context_engine.get_cursor_location().column` is one-based. The
learning presenter converts *only the cursor*; a regression checks
that the fact becomes visible on the first character, not one earlier.

### ERIDU acceptance checklist (pending, not claimed green)

```bat
git status --short
git pull --ff-only
git log -1 --oneline
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manual Neovim source:

```bat
nvim samples/asm/x86_64/memory_operand_validation.asm
```

With the sample open, toggle `:HudPresentation learning` and
`:HudPresentation standard` or `:HudPresentation cycle`. Confirm
the familiar text HUD returns, Inspect stays selected, expanded
sections stay expanded, source cursor stays put, and learning text
does not claim to know a value for a symbolic/unresolved memory load.

`standard` is the default. Only the first text `learning` lens
is implemented; **do not claim that GIF/PNG/graphical/animated
register diagrams exist yet.** The existing `:HudVisualMode` mode
controls remain fully separate.

**Open regression from prior tranche:** memory-component ASM focus
on `mov rax, [rbp + rax*4 - 8]` must be tested independently;
this accessibility tranche intentionally does not alter the
ASM instruction-effect tables. Avoid further architectural
migration until ERIDU returns its tests.

**Performance qualification:** using an already collected context
for presentation switching avoids invoking the parser for the
switch itself. It does **not** prove a full HUD render is fast,
nor does it fix potential per-cursor AST replay costs. Profile
those separately in the next permitted performance tranche.


### Follow-up correctness fixes in the same pending tranche

- The learning presenter was audited against
  `instruction_utils.lua`: Tree-sitter-derived source token columns are
  **zero-based**; `context_engine.get_cursor_location().column` is
  **one-based**. Only the cursor is converted. A smoke test pins the
  exact first-character transition.
- Malformed `known_through` metadata now produces a constructor
  error rather than silently defaulting to the discovery position.
- The learning presenter provides a short everyday explanation for
  `source` and `destination` roles while leaving detailed role data
  visible in the existing Registers tree.

**No new ASM inference changes in this batch.**
All listed smoke tests remain **unverified on ERIDU** until the
user sends the actual Windows Neovim output; neither static review
nor a GitHub commit is evidence of a passing Neovim parser.


## ERIDU acceptance results & next drip-feed batch (2026-11-09)

### Confirmed at `1479142` on ERIDU (Windows / Neovim)

The user supplied the actual console output and seven screenshots:

- `normalized_fact_contract_smoke.lua` **PASS** (certainty, exact
  ON/PAST, independent copies).
- `presentation_modes_smoke.lua` **PASS** (learning/standard toggles,
  cached rendering request, Inspect/expansion preservation, namespace).
- `adapter_contract_smoke.lua` **PASS** (Lua, Python, C, C++, ASM).
- `section_inspect_colors_smoke.lua` **PASS** (section identity,
  statusline, selected and unselected hues).
- `c_cpp_parser_smoke.lua` **PASS** (parser-backed C/C++ discovery).
- `asm_register_focus_regression.lua` **PASS** (7 target checks,
  including RAX/RBP index/base memory-component occurrences).

The screenshots show `:HudPresentation learning` and `standard`
switching at `mov rax, 60` while preserving existing detailed
Registers data. Learning correctly reports unknown `RAX` at
`cpuid` rather than fabricating its post-execution value. The
root Events and Register sections remain switchable, and source
cursor stays where the user placed it. These observations **do
not yet measure full cursor latency**.

**Local workspace caution:** before pulling the user had untracked
files named `cls`, `git`, `main`, `n`, `nvim` and
`value@22(depth`. They are not part of these commits; do not
delete or `git clean` them automatically.

### Next tranche: terminal-safe 64-bit register byte diagram

Build a **third, explicit presentation mode** `diagram` rather than
changing how `standard` or `learning` work. The new presenter
consumes the same normalized register facts and architecture-defined
widths; it must never call the parser, infer new register values,
mutate Inspect state, or render a known value beyond its actual
numeric precision. The first surface is ASCII byte cells (not
PNG/GIF or animation); graphics will come later from the same
fact data. Clear high-byte/low-byte annotations and a truthful
unknown/partial state are required. `cycle` should include
`standard`, `learning`, `diagram`; original default remains
`standard`. Keep ASCII plain-mode compatibility.

Acceptance before claiming green: exact 64-bit conversion of
`60`, `0`, `0xFFFFFFFFFFFFFFFF`, maximum-width decimals and
negative signed numbers without Lua floating point corruption;
unknown/symbolic/conditional facts use visibly unknown bytes;
missing/non-64-bit register architecture facts show an honest
fallback rather than inventing a register width. Test the
new command and verify it preserves source cursor, Inspect
and expansion states. No ASM instruction semantics changes.


## Implementation: ASCII 64-bit register byte diagram (2026-11-09)

**Status: pushed on `main`, pending next ERIDU smoke/manual acceptance.**

The first follow-up presentation after the accepted fact-v1 tranche is
now implemented. It is deliberately **pure text**, not an image/GIF;
it proves the data-to-view separation for future graphical renderers.

### Code and behaviour

- `lua/tracker_hud/presenters/byte_diagram.lua` renders an 8-byte
  value bank for one source-visible register whose architectural
  `metadata.family.bits` establishes width **exactly 64 bits**.
  Bytes are shown MSB on the left and LSB on the right with a
  plain-language glossary. This is significance order, **not**
  CPU memory order. A register fact without verified 64-bit width
  produces an explicit fallback rather than assuming a width.
- Exact integer conversion uses byte-wise division of decimal digit
  strings, or direct hex-pair parsing, never JavaScript/Lua bitshifts
  on 64-bit doubles. Supports signed 64-bit down to
  `-9223372036854775808`, unsigned up to
  `18446744073709551615`, and exact hex strings. Lua numeric
  inputs at/above 2^53 are rejected to prevent silent rounding;
  the same values supplied as decimal strings are accepted.
  Out-of-range/symbolic/fractional values are not rendered as
  known bit patterns.
- `lua/tracker_hud/presenters/learning.lua` now exposes
  `select_fact(context)` so both learning text and diagram use
  **the same ON/PAST cursor-visible register record**, and passes
  architecture-owned `width_bits` into normalized fact subjects.
  Static CPU register listings cannot masquerade as source effects.
- `lua/tracker_hud/presentation_mode.lua` now supports
  `standard`, `learning`, `diagram`, `cycle`, with cycle order
  **standard -> learning -> diagram -> standard**.
- `lua/tracker_hud/hud.lua` displays an ASCII diagram above the
  still-navigable technical sections **only in diagram mode**.
  Standard remains the original default. ASCII bytes have a
  readable semantic foreground in normal and plain terminal modes.
  `lua/tracker_hud/init.lua` updates the command usage text.
- `tests/byte_diagram_smoke.lua` checks exact byte projections,
  64-bit bounds, non-exact numeric rejection, unknown/partial
  states, verified width from the actual x86-64 profile, and
  ON/PAST source discovery.
- `tests/presentation_modes_smoke.lua` now checks the three-mode
  cycle, explicit `:HudPresentation diagram`, and preservation
  of Inspect, visual theme, source position, and expanded sections.

The other ASM effects, architecture tables, target directives,
C/C++ adapters, and core Inspect selection were **not changed**.

### Expected manual preview

On `test.asm` at `mov rax, 60` in diagram mode:

```text
Byte diagram (source inference, not live CPU state):
  RAX  (64 bits = 8 bytes)
  MSB                                 LSB
  [00][00][00][00][00][00][00][3C]
  Bits: 0x000000000000003C
  Source-inferred value, not execution proof.
  MSB = highest-value byte; LSB = lowest-value byte.
  Left to right: high to low significance, NOT memory order.
```

At `cpuid`, when a value is not established from source, all
eight byte cells must show `[??]`, **not** zero. The full technical
Registers tree must remain below the diagram. At a position with no
register discovery, the text should explain why no diagram is
available; it should not speculate about CPU state.

### Exact acceptance commands (ERIDU)

```bat
git status --short
git pull --ff-only
git log -1 --oneline
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manually use `:HudPresentation diagram`,
`:HudPresentation learning`, `:HudPresentation standard`,
`:HudPresentation cycle` and `:HudVisualMode plain` in
`nvim test.asm`. Switching must not lose cursor/Inspect/expansion
state. No new default keyboard mappings.

No UI image renderer or 8/16/32-bit alias overlay is provided yet.
No end-to-end latency improvement has been measured by this work;
do not mistake the cheap diagram projection for reduced ASM
source-analysis work. Future tranches can implement byte-accurate
alias overlays, partial-known masks and animated/graphical views,
and separately profile cursor-state/AST/cache work.

**Workspace caution:** Earlier ERIDU `git status --short`
showed six untracked root filenames (`cls`, `git`, `main`,
`n`, `nvim`, `value@22(depth`). Leave them untouched pending
user inspection; do not call `git clean` or silently delete them.


## ERIDU acceptance: ASCII 64-bit byte diagram (2026-11-09)

**Accepted on ERIDU at `cbfd95a`.**

The user supplied the missing headless smoke result and a live Neovim
screenshot from `test.asm`:

- `tests/byte_diagram_smoke.lua` PASS:
  exact integers/precision guards, 64-bit high-to-low projection,
  unknown/partial/width fallback, and ON/PAST discovery.
- The live diagram at `mov rax, 60` shows
  `[00][00][00][00][00][00][00][3C]` and
  `0x000000000000003C`.
- The detailed Registers tree remains visible below the diagram and
  still reports the source-immediate relationship.
- This closes the byte-diagram acceptance gate. It is evidence for the
  presentation surface only; it is not a latency benchmark or live CPU
  execution proof.

### Next bounded tranche: x86-64 alias/subregister map

Extend the existing diagram using architecture facts already carried by
the register record. Do **not** change ASM instruction semantics.

For a verified 64-bit scalar family, display which byte cells are
covered by each architectural alias. For the RAX family this means
`RAX/EAX/AX/AH/AL`, including the high-byte placement of `AH`.
Mark the actual alias spelling observed in source and explain the
existing write-mode truth:

- full-width writes replace the whole 64-bit family;
- 32-bit `EAX`-class writes use `zero_extend_64`, clearing the
  upper 32 bits;
- 16-bit/8-bit partial writes replace only their covered bits.

The map is a presentation of architecture metadata, not a new register
inference rule. Unknown register *values* may still show a structural
alias map because alias widths/offsets are architectural facts.

**Explicitly deferred:** partial-known bit/value masks. Do not invent
known bytes for a partial value merely because the alias coverage is
known. Add partial-known representation in a later separately tested
tranche.

Acceptance must cover byte placement, `AH` offset, source-alias focus,
write-mode wording, family isolation (for example R8 has no high-byte
alias), and preservation of the existing byte-value diagram.


## Implementation: x86-64 alias/subregister byte map (2026-11-09)

**Status: pushed on `main`, pending ERIDU acceptance.**

This tranche extends only the `diagram` presentation. It does not
change ASM parsing, register-effect inference, target selection, or the
technical Registers section.

### Changes

- `presenters/learning.lua` now copies two architecture-owned items
  into the detached normalized fact snapshot:
  - `metadata.register_family` — the verified register family;
  - `metadata.source_alias` — the actual alias spelling attached to
    the source-side register record.
  The fact contract deep-copies this data, so the presenter does not
  retain or mutate the live adapter tables.
- `presenters/byte_diagram.lua` renders a byte-aligned alias map for
  verified 64-bit scalar families. The map is still high-significance
  byte first, matching the value row.
- For RAX the expected structural map is RAX/EAX/AX/AH/AL. In
  particular AH covers bits 15..8 and AL covers bits 7..0.
- The source alias is marked with `>`. This marks the architectural
  alias involved in the source effect; it does **not** assert that the
  occurrence is necessarily a write.
- Write-mode text is deliberately conditional architecture wording:
  “if EAX is written...” / “if AH is written...”. This avoids turning
  an alias definition into a false claim about a read occurrence.
- Unknown values remain eight `[??]` cells. The structural alias map
  can still be shown because alias widths/offsets are architecture
  truths independent of whether the runtime/source value is known.
- R8-family rows are sourced from the R8 architecture family and do
  not acquire legacy AH/AL aliases.

### New regression

`tests/register_alias_diagram_smoke.lua` checks:

1. RAX/EAX/AX/AH/AL byte placement;
2. the AH 15..8 high-byte offset;
3. source-alias focus for RAX, EAX and AH;
4. full, zero-extend-64 and partial write-rule wording;
5. R8 family isolation;
6. unknown values remain unknown while architecture shape stays visible.

Partial-known bit/value masks remain intentionally deferred. No current
code derives known sub-bytes from a `partial` value.

### ERIDU acceptance commands

From the repository root:

```bat
git status --short
git pull --ff-only
git log -8 --oneline
nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manual acceptance in `nvim test.asm`:

- On `mov rax, 60`, `:HudPresentation diagram` should still show
  the accepted value row and then an alias map with `> RAX`.
- If convenient, add or inspect temporary source examples using
  `eax`, `ax`, `ah`, and `al`; the `>` marker should follow
  the alias actually involved in the source record.
- The AH row must cover the second-lowest byte only.
- Switching back to `standard` or `learning` must preserve the
  existing cursor/Inspect/expansion behaviour.

Do not claim this tranche green until ERIDU returns the new smoke output.
The earlier six untracked root filenames remain user-owned workspace
state; do not run `git clean`.


## ERIDU acceptance: x86-64 alias/subregister diagram (2026-11-10)

**Accepted on ERIDU at `9390e9b`.**

The user returned both the complete smoke output and live Neovim screenshots.

Confirmed green:

- `register_alias_diagram_smoke.lua`: RAX/EAX/AX/AH/AL placement,
  EAX zero extension wording, AH partial-write wording, family isolation,
  and unknown-value honesty.
- Existing `byte_diagram_smoke.lua`, `presentation_modes_smoke.lua`,
  `normalized_fact_contract_smoke.lua`, and
  `asm_register_focus_regression.lua` all remain green.
- Live `test.asm` screenshots confirm the alias map renders under the
  byte diagram and the detailed technical Registers tree remains intact.

### User-directed next behaviour: persistent diagram state

The current diagram is still primarily a **source-occurrence lens**:
it chooses the register fact associated with the current source effect.
The technical Registers section, by contrast, already contains the
reduced register state accumulated through the cursor position.

The next bounded tranche must expose that already-computed persistent
state visually without creating a second state engine.

Implementation target:

1. Keep the existing detailed/current-effect byte diagram and alias map.
2. Add a compact **persistent register-state bank** built only from the
   current `context.registers` snapshot.
3. A register changed on an earlier line remains visible at later cursor
   positions until the existing inference engine changes or invalidates it.
4. The bank must not replay source, parse instructions, or invent values.
5. Untouched static architecture rows must not masquerade as discovered
   state.
6. Known, unknown and partial values remain distinct.
7. Colour/highlight of affected bytes/registers is explicitly deferred to
   the following presentation-only tranche. First prove persistence and
   state parity in plain text.

Example intent after:

```asm
mov rax, 60
xor rdi, rdi
```

At the second line, the compact persistent state view should be able to
show both the carried `RAX = 60` state and the newly established
`RDI = 0` state, while the detailed current-effect panel may still
focus on RDI.

This is a visualization of the same cursor-time reduced state already
shown in Registers, not live CPU execution.


## Implementation: persistent register-state bank (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

This tranche implements the persistence requested after the accepted alias
diagram. It deliberately reuses the already-reduced Registers snapshot instead
of adding a second state/replay engine.

### Behaviour

- The accepted current-effect byte diagram and alias map remain unchanged.
- Diagram mode now appends a compact
  **`Persistent register state (through cursor)`** bank.
- `presenters/learning.state_facts(context)` converts only dynamic register
  records that already have source positions in `context.registers`.
  Architecture-only static rows are excluded.
- `presenters/register_state_bank.lua` renders those detached normalized
  facts as compact 64-bit byte rows.
- A prior state remains visible after the cursor moves past its source line,
  exactly because the underlying Registers reducer still carries that state.
- `>` marks a register whose latest reduced-state change occurred on the
  current line. This is plain-text scaffolding only; semantic colour/highlight
  remains deliberately deferred.
- Unknown/partial values display unknown bytes; the presenter does not recover
  or guess an earlier known value after the inference engine has invalidated it.

Example:

```asm
mov rax, 60
xor rdi, rdi
```

At the second instruction the persistent bank should include both:

```text
  RAX  [00][00][00][00][00][00][00][3C]  known   @ line 9
> RDI  [00][00][00][00][00][00][00][00]  known   @ line 10
```

If a later instruction changes RAX to unknown, only RAX changes to `[??]`;
RDI remains carried until its own state changes.

### Regression

New `tests/persistent_register_diagram_smoke.lua` pins:

1. prior RAX=60 state surviving the later RDI=0 update;
2. static untouched RBX not appearing as discovered state;
3. later unknown RAX replacing only RAX, while RDI persists;
4. both states surviving onto a later non-effect line;
5. current-line marker disappearing when neither latest change is on the
   cursor line.

### ERIDU acceptance

```bat
git status --short
git pull --ff-only
git log -8 --oneline
nvim --headless -u NONE -c "luafile tests/persistent_register_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manual check in `nvim test.asm`:

- at `mov rax, 60`, the persistent bank contains RAX=60;
- at `xor rdi, rdi`, the bank contains both carried RAX=60 and current RDI=0;
- at `syscall`, any existing inference update to RAX is reflected honestly
  while RDI remains carried;
- on a later instruction/non-effect position, reduced states still remain
  visible according to the technical Registers section.

Do not start colourisation until this state-parity tranche is green on ERIDU.
The intended next presentation-only batch is semantic highlighting of current
affected register/alias/byte regions while retained state stays visually quieter.


## ERIDU acceptance: persistent register-state diagram (2026-11-10)

**Accepted on ERIDU at `a585a08`.**

The user returned complete smoke output plus live Neovim screenshots.

Confirmed green:

- `persistent_register_diagram_smoke.lua`: carried RAX state survives the
  RDI update, later unknown state replaces only its own register, and reduced
  state survives onto later non-effect lines.
- Existing alias-diagram, byte-diagram, presentation-mode,
  normalized-fact, and ASM source-occurrence regressions remain green.
- Live `test.asm` screenshots show:
  - line 9: persistent RAX=60;
  - line 10: carried RAX=60 plus current RDI=0;
  - line 11 `syscall`: RAX/RCX/R11 become unknown according to the existing
    reducer while RDI=0 remains carried.

This confirms the diagram is now projecting the same cursor-time reduced state
as the technical Registers section rather than maintaining a second state model.

### Next bounded tranche: semantic diagram highlighting

The user requested colourisation after persistence was proven.

This tranche is presentation-only:

1. Keep textual `>` markers so colour is never the sole meaning carrier.
2. In the detailed current-effect byte row, highlight only the bytes covered by
   the current source alias (for example all eight for RAX, low four for EAX,
   the second-lowest byte for AH).
3. In the alias map, highlight the current source alias label and its covered
   cells; keep other aliases visually quieter.
4. In the persistent state bank, make current-line changed rows prominent and
   carried rows visually historical/quieter.
5. Unknown current state should use the existing unresolved semantic colour,
   not a success/known colour.
6. Use existing Tracker_HUD semantic styles/relevance and namespace-aware
   highlight infrastructure. Do not hard-code ANSI escapes or bypass
   `hud_text` spans.
7. `:HudVisualMode plain` must remain meaningful through `>` markers and
   text even when semantic colour is disabled.

Do not change register inference, replay, architecture facts, or persistence
semantics in this tranche.

**Workspace caution:** ERIDU now also shows an untracked root file named
`register` in addition to the previously observed user-owned files. Leave all
untracked root artifacts untouched; do not run `git clean`.


## Implementation: semantic diagram highlighting (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

This tranche changes presentation only. Register reduction, persistence,
architecture facts and ASM instruction semantics are unchanged.

### Detailed current-effect diagram

`presenters/byte_diagram.lua` now has `rich_lines(fact)` in addition to
the existing plain `lines(fact)` API.

The text is identical; semantic `hud_text` spans are layered on top:

- current register identity: `register + current`;
- current source alias: `register_alias + current`;
- bytes covered by the current alias: `affected + current` when known;
- covered unknown bytes: `unresolved + current`;
- non-current alias labels: `register_alias + historical`;
- current write-rule text: `affected + current`.

Alias byte coverage comes directly from the existing architecture
`bits` + `offset` data. Examples:

- RAX highlights all 8 byte cells;
- EAX highlights only the low 4 cells;
- AH highlights exactly the bits 15..8 cell;
- AL highlights exactly the bits 7..0 cell.

No byte is considered known merely because its alias coverage is known.

### Persistent state bank

`presenters/register_state_bank.lua` now has `rich_lines(facts, cursor_line)`.

- current-line register name + known bytes use `affected + current`;
- current unknown/partial bytes use `unresolved + current`;
- carried register identity uses `register + historical`;
- carried known byte cells use `immediate + historical`;
- carried unknown cells use `unresolved + historical`;
- source line numbers inherit matching current/historical relevance.

The literal `>` current marker remains in the text.

### HUD integration

`hud.lua` accepts structured overlay lines directly. Diagram mode uses the
new rich renderers; learning/plain string renderers remain compatible.

`:HudVisualMode plain` still disables semantic colour. The same text and
`>` markers remain, so colour is not the only carrier of meaning.

### Regression

New `tests/diagram_highlight_smoke.lua` checks:

1. RAX highlights all eight current value cells;
2. current RAX alias row highlights all eight covered cells;
3. non-current aliases use historical relevance;
4. AH highlights exactly one cell at bits 15..8;
5. unknown current bytes use unresolved rather than affected semantics;
6. current persistent RDI row is prominent while carried RAX is historical;
7. rich semantic spans do not change the plain text output.

### ERIDU acceptance commands

```bat
git status --short
git pull --ff-only
git log -8 --oneline
nvim --headless -u NONE -c "luafile tests/diagram_highlight_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/persistent_register_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manual acceptance in `nvim test.asm`:

- `mov rax, 60`: all eight current RAX cells should be emphasized;
- `xor rdi, rdi`: RDI current-effect cells/current persistent row should be
  prominent while carried RAX is quieter;
- `syscall`: unknown current RAX/RCX/R11 state should use unresolved
  highlighting rather than looking like known values;
- if a temporary AH example is used, only the bits 15..8 cell should receive
  current affected emphasis;
- `:HudVisualMode plain` must remain readable and preserve all markers/text.

Do not proceed to partial-known bit masks until this presentation-only colour
tranche is green.


## ERIDU acceptance: semantic diagram highlighting (2026-11-10)

**Accepted on ERIDU at `a163e1a`.**

The user returned complete regression output and live Neovim screenshots.

Confirmed green:

- `diagram_highlight_smoke.lua`: current RAX alias/all covered bytes,
  AH bits 15..8 only, unresolved colouring for unknown current bytes,
  current-vs-carried persistent styling, and rich/plain text parity.
- Existing persistent-state, alias-map, byte-diagram, presentation-mode,
  section/Inspect colour, and ASM source-occurrence regressions remain green.
- Live screenshots confirm current known state is emphasized in green/sage,
  current unknown state uses unresolved red/pink, and carried state remains
  visible but visually quieter.

The cursor-column screenshots also confirm ON/PAST gating remains intact:
before the source token the detailed diagram does not expose the future fact;
on/past the token it appears.

### Next semantic tranche: explicit partial-known value masks

Repository tracing confirms the current register reducer stores only a whole
`value` plus binary `resolved`. There is no existing hidden known-bit mask.
Therefore the next work must introduce an explicit representation before any
x86 alias write is allowed to claim partially known state.

Bounded first half:

1. Extend normalized value facts so `status = "partial"` may carry exact
   `known_mask` + `known_value` 64-bit hexadecimal literals.
2. Require the pair together; reject them on non-partial statuses.
3. Teach byte diagrams/state-bank rows to render fully known bytes from the
   mask, unknown bytes as `[??]`, and non-byte-complete knowledge as
   `[~?]`.
4. Print the exact known mask and known-bit value so sub-byte knowledge is
   never hidden by the compact cells.
5. Existing symbolic `partial` facts without masks remain all unknown.
6. Do **not** yet change x86 register reduction in this half.

Only after this representation is green should a following tranche make proven
AL/AH/AX/EAX write rules produce masks. This keeps representation correctness
separate from new inference semantics.


## Implementation: explicit partial-known value-mask contract (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

This is intentionally the representation half only. It does **not** yet make
x86 AL/AH/AX/EAX writes produce partial masks.

### Normalized fact contract

A value with `status = "partial"` may now carry:

```lua
known_mask = "0x..."
known_value = "0x..."
```

Both are exact hexadecimal literals of at most 64 bits.

The contract enforces:

- mask and value must be supplied together;
- only `partial` status may carry them;
- the mask must contain at least one known bit;
- an all-ones 64-bit mask is rejected because that is a fully `known` value;
- `known_value` may not set any bit that `known_mask` marks unknown.

Legacy symbolic partial facts without a mask remain valid and remain completely
unknown in the byte projection.

### Normalization bridge

`presenters/learning.lua` preserves an explicit producer payload from:

```lua
record.metadata.partial_value = {
    known_mask = "...",
    known_value = "...",
}
```

into the detached normalized value fact.

A producer may therefore expose partial certainty later without presenters
reaching back into adapter/inference state.

### Byte diagram

`presenters/byte_diagram.lua` now supports three compact byte states:

- `[3C]` — all 8 bits of this byte are proven;
- `[??]` — no bit of this byte is proven;
- `[~?]` — some, but not all, bits of this byte are proven.

For any masked partial value the diagram also prints exact bit truth:

```text
Known mask: 0x000000000000FF00
Known bits: 0x0000000000003C00
```

This means the compact cell never has to pretend an arbitrary sub-byte mask is
a whole known byte.

Example:

```text
[??][??][??][??][??][??][3C][??]
Known mask: 0x000000000000FF00
Known bits: 0x0000000000003C00
```

For a nibble-only proof such as mask `0xF0`, the corresponding byte is
`[~?]` and the exact mask/value lines retain the real bit information.

### Persistent state bank

The persistent register bank now uses the same value-cell projection, so a
future partially-known reduced register state can persist through the cursor
without collapsing to either wholly known or wholly unknown.

### New regression

`tests/partial_value_mask_smoke.lua` checks:

1. a fully known byte inside an otherwise unknown 64-bit value renders exactly;
2. neighbouring unknown bytes remain unknown;
3. arbitrary sub-byte knowledge renders `[~?]` rather than a fabricated hex byte;
4. exact known mask/value lines are retained;
5. symbolic partial facts without masks remain all unknown;
6. the normalized register snapshot preserves explicit partial certainty;
7. the persistent state bank renders the mixed-known state.

`tests/normalized_fact_contract_smoke.lua` now also rejects:

- missing mask/value partner;
- masks attached to fully-known status;
- zero-known masks;
- all-known masks labelled partial;
- known-value bits outside the mask.

### ERIDU acceptance

```bat
git status --short
git pull --ff-only
git log -10 --oneline
nvim --headless -u NONE -c "luafile tests/partial_value_mask_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/diagram_highlight_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/persistent_register_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

No live source example is expected to produce `[~?]` or a mixed byte row yet:
that producer is deliberately the **next** tranche after this representation
passes.

### Next tranche after green

Make x86-64 alias writes produce proven partial certainty from architecture
rules, starting with byte-aligned scalar aliases:

- AL -> low 8-bit mask;
- AH -> bits 15..8 mask;
- AX -> low 16-bit mask;
- EAX-class writes -> zero-extend semantics, which can often yield a fully
  known 64-bit value when the 32-bit source value is known.

This must be implemented in the reducer/architecture semantic boundary, not
reverse-engineered by the presenter.


## ERIDU acceptance: partial-known value-mask representation (2026-11-10)

**Accepted on ERIDU at `922c5fd`.**

The user returned the full regression output and live Neovim screenshots.

Confirmed green:

- `partial_value_mask_smoke.lua`: exact known byte inside a partial 64-bit
  value, sub-byte honesty, symbolic-partial fallback, normalized persistence.
- `normalized_fact_contract_smoke.lua`: explicit partial-mask invariants.
- Existing diagram highlight, persistent state, alias map, byte diagram,
  presentation mode, and ASM source-occurrence regressions all remain green.
- The user confirmed the live HUD remains stable in diagram mode while moving
  through syscall/cpuid and Inspect views.

The representation is therefore accepted. It is now valid for the reducer to
produce explicit partial certainty; presenters no longer need to guess.

## Implementation: x86-64 scalar alias write certainty (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

This tranche connects real x86-64 GPR alias writes to the accepted partial-mask
representation.

### Exact certainty composer

New module:

`lua/tracker_hud/low_level/register_value_mask.lua`

It is architecture-neutral. The x86 profile supplies:

- alias width;
- bit offset;
- `write_mode`.

The composer owns byte-exact certainty merging without Lua bit-width
assumptions.

Supported write modes in this tranche:

- `partial` — preserve prior proven bits outside the alias and replace only
  the covered slice;
- `zero_extend_64` — replace the low 32-bit slice and prove the upper
  32 bits are zero.

Important behaviours:

- `AH = 0x3C` into unknown RAX ->
  mask `0x000000000000FF00`, value `0x0000000000003C00`;
- known RAX followed by AH/AL/AX writes preserves all known surrounding bytes;
- known EAX write fully determines RAX because x86-64 clears the upper dword;
- unknown AH write invalidates only bits 15..8;
- unknown EAX write still proves upper 32 bits zero;
- out-of-width alias sources are not silently truncated into false certainty.

### Canonical family reduction

`context_engine.lua` now keeps two concepts separate:

1. source-spelling operand lookup;
2. latest reduced architectural family state.

The latest state uses the canonical family key (for example `rax`) while the
fact itself retains the source alias spelling (for example `ah`).

This prevents RAX/EAX/AX/AH/AL from appearing as independent physical state in
the final reduced register collection.

Sibling alias lookup entries are invalidated when another spelling changes the
same family so stale source data cannot survive an overwrite. When the whole
canonical family becomes known, the canonical spelling is republished as a
resolved source lookup.

### Byte-granular partial styling

The accepted partial-mask renderer now exposes per-byte certainty states:

- known;
- unknown;
- partial.

Current and persistent highlighting follows those states rather than colouring
every byte as unresolved merely because the whole 64-bit register is partial.

For example, initial `mov ah, 0x3C` may render:

```text
[??][??][??][??][??][??][3C][??]
```

The `3C` cell is known/affected while the surrounding cells remain unresolved.

### New regressions

`tests/register_value_mask_smoke.lua` is parser-independent and pins the exact
composer semantics.

`tests/x86_alias_write_state_smoke.lua` is parser-backed and exercises real
ASM source through `context_engine.collect_register_effects`.

It covers:

1. AH into unknown RAX;
2. AH preserving prior known family state;
3. AL and AX slice replacement;
4. EAX zero-extension to full RAX;
5. unknown AH invalidating only its byte;
6. unknown EAX still proving upper 32 zero;
7. one latest reduced state per canonical RAX family.

A new manual sample is also available:

`samples/asm/x86_64/alias_write_validation.asm`

### Parser numeric boundary deliberately unchanged

The existing source immediate resolver still converts numeric literals through
Lua numeric values before this composer receives them. This tranche does not
silently broaden into that separate precision issue.

Therefore the parser-backed regression uses a small exact seed. The pure
composer regression separately proves exact 64-bit hexadecimal composition.

### ERIDU acceptance commands

```bat
git status --short
git pull --ff-only
git log -14 --oneline
nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/partial_value_mask_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/diagram_highlight_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/persistent_register_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

### Manual acceptance

Open:

```bat
nvim samples\asm\x86_64\alias_write_validation.asm
```

Then:

```vim
:HudPresentation diagram
```

Expected milestones:

- first `mov ah, 0x3C`: only AH byte known inside otherwise unknown RAX;
- full RAX write: all bytes known;
- later AH/AL/AX immediate writes: surrounding bytes preserved;
- EAX immediate write: upper 32 bits visibly zero;
- `mov ah, bl` with unknown BL: only AH byte becomes unknown;
- `mov eax, ebx` with unknown EBX: high four bytes remain known zero while
  low four become unknown.

Do not begin the separate wide-immediate parser precision fix until this
alias-state reducer tranche is green.


## Follow-up: diagram persistence before current effect (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

ERIDU exposed an important presentation-state gap after the scalar alias reducer
landed.

When the cursor was on an instruction mnemonic such as:

```asm
mov rax, 0x12345678
```

the technical Registers tree still contained the correct reduced RAX state, but
the diagram overlay could temporarily show:

```text
No register fact at this cursor position.
No source-established 64-bit register state yet.
```

The reason was not lost inference. The latest reduced RAX record belonged to the
current line, but its destination source column was still to the right of the
cursor. The diagram correctly rejected that not-yet-visible effect, but the
previous RAX snapshot had already been replaced in the reduced collection.

### Fix

Context construction now retains a second register snapshot:

```text
context.registers_before_current_line
```

It is reduced strictly before column zero of the current source line.

The diagram presenter now distinguishes:

1. the normal current reduced collection;
2. the state that reached the start of the current line.

If a current-line register effect exists but is not yet visible at the cursor,
the diagram falls back to the prior state for the **same canonical register
family**.

The pending instruction is **not** applied early.

### Carried-state wording

The large byte diagram marks fallback state explicitly:

```text
Carried state: the current source effect has not been reached yet.
Latest proven change is from line N.
```

Carried state uses historical styling rather than current-effect emphasis.

Once the cursor reaches the destination operand, the current instruction's fact
replaces the carried state normally.

### Persistent bank

`learning.state_facts()` now also falls back per canonical register name when
the current-line latest record exists but is not yet source-visible.

This prevents the persistent bank from blinking a register row out while moving
across the mnemonic/whitespace preceding a destination operand.

### Regressions corrected from the previous gate

ERIDU also exposed two test-fixture mistakes:

1. `x86_alias_write_state_smoke.lua` still contained the old large parser
   seed while its assertion expected the new small exact seed.
2. `partial_value_mask_smoke.lua` counted the separate `partial` status
   highlight as though it were an eighth unresolved byte.

Both tests have been corrected without weakening their semantic assertions.

### New parser-backed regression

`tests/diagram_mnemonic_persistence_smoke.lua`

The test verifies:

- line 2 establishes partial RAX through AH;
- cursor on line 3 `mov` mnemonic does not expose line 3's write;
- the large diagram carries line 2's exact RAX mask/value;
- the persistent bank also carries line 2 RAX;
- moving to line 3's destination register replaces carried state with the
  current full write.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -13 --oneline

nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/partial_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/diagram_mnemonic_persistence_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/diagram_highlight_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/persistent_register_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_alias_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/byte_diagram_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manual validation remains:

```bat
nvim samples\asm\x86_64\alias_write_validation.asm
```

With `:HudPresentation diagram`, move between the mnemonic and destination
operand of each later `mov`. The diagram should now remain visually continuous
instead of appearing to forget prior register state.


## Tranche 2: shared x86-64 target / ABI overlays (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

After the register-profile extraction, the x86-64 ASM variant still owned a
second category of non-language truth:

- platform declarations;
- platform aliases;
- the default target platform;
- ABI / calling-convention descriptions.

That ownership was wrong for the long-term adapter model. NASM, GAS, C, C++,
Rust, disassembly and future source adapters may all target the same x86-64
Linux/Windows/Darwin conventions.

### New shared target module

`lua/tracker_hud/architectures/x86_64/targets.lua`

This module now owns the existing target overlays:

- Linux -> `linux_syscall` (supported);
- Windows -> `windows_x64` (declared);
- Darwin -> `darwin_x86_64` (declared);
- aliases such as `win64`, `macos`, and `mac`;
- the Linux syscall number/return/argument/clobber register contract.

The module has no ASM, Tree-sitter, Neovim UI or inference dependency.

### Composite architecture profile

`lua/tracker_hud/architectures/x86_64/init.lua`

The architecture registry now resolves one composite x86-64 profile exposing:

- hardware metadata;
- register families;
- static register descriptions;
- the alias index;
- platform overlays;
- ABI / calling-convention overlays.

`architectures/registry.lua` now resolves:

```text
tracker_hud.architectures.x86_64
```

instead of returning the register module directly.

Existing register-table identity is deliberately retained.

### ASM becomes a consumer

`adapters/asm/arch/x86_64/adapter.lua` no longer defines x86-64 platform and
ABI tables.

It references the shared architecture profile for:

- `metadata`;
- `platforms`;
- `default_platform`;
- `platform_aliases`;
- `calling_conventions`;
- `register_families`;
- `registers`;
- `register_alias_index`.

ASM still owns syntax, construct descriptions, instruction effects, stack
effects, instruction events and ASM presentation.

### New regression

`tests/architecture_target_overlay_smoke.lua`

The smoke test pins four invariants:

1. loading the shared x86-64 profile must not load ASM;
2. Linux/Windows/Darwin target declarations stay unchanged;
3. the Linux syscall register contract stays unchanged;
4. the ASM variant consumes the shared platform/ABI tables by identity.

### Architectural boundary after tranche 2

The intended ownership is now clearer:

```text
architectures/x86_64/registers.lua
    hardware register structure

architectures/x86_64/targets.lua
    platform / ABI overlays

architectures/x86_64/init.lua
    composite language-independent target profile

adapters/asm/arch/x86_64/adapter.lua
    ASM syntax + instruction/effect description
```

The next likely migration is ABI-dependent **register roles**. The current
register profile still contains historical labels such as `argument register`,
`return value`, and `callee-saved`, which mix hardware identity with ABI
usage. That should be separated only after this target-overlay boundary is
accepted.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -10 --oneline

nvim --headless -u NONE -c "luafile tests/architecture_registry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_target_overlay_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
```


## Tranche 3: separate hardware register roles from function-ABI roles (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

The shared x86-64 register profile still contained historical role strings that
mixed CPU identity with calling-convention usage. Examples included:

- `rax = accumulator / return value`;
- `rdi = destination index / argument register`;
- `rbx = callee-saved general register`;
- `r10 = temporary general register`.

Those descriptions are useful to a programmer, but they do not all belong to
the CPU architecture itself.

### Hardware profile is now ABI-neutral

`architectures/x86_64/registers.lua` now keeps architecture-only roles such as:

```text
rax -> accumulator
rbx -> general register
rcx -> counter
rdx -> data
rsi -> source index
rdi -> destination index
rbp -> base pointer
rsp -> stack pointer
r8..r15 -> general register
```

Alias width/offset/write-mode semantics are unchanged.

### Function ABI is distinct from syscall ABI

The Linux target now declares:

```text
abi          = linux_syscall
function_abi = sysv_amd64
```

This is intentional.

`linux_syscall` describes the `syscall` boundary:

```text
number : rax
return : rax
args   : rdi rsi rdx r10 r8 r9
clobber: rcx r11
```

`sysv_amd64` describes ordinary function-call register usage:

```text
return       : rax
arguments    : rdi rsi rdx rcx r8 r9
callee-saved : rbx rbp r12 r13 r14 r15
caller/temp  : r10 r11
```

Darwin currently points its function ABI at the same SysV role profile.
Windows points at `windows_x64`, but no Windows register-role overlay is
claimed yet.

### Shared structured role overlay

`architectures/x86_64/targets.lua` now exposes:

```text
register_roles.sysv_amd64
```

Each entry carries a display role plus structured usage metadata. SysV argument
registers also carry their ordinal argument index.

### Generic composition

`sections/low_level/registers.lua` now composes static register roles through
the active target's `function_abi`.

This logic is generic and does not know about ASM or x86-64. It consumes the
adapter/profile fields:

- `active_targets.platform`;
- `platforms[platform].function_abi`;
- `register_roles[function_abi]`.

Dynamic inference roles such as `written by mov` remain authoritative and are
not replaced by static target roles.

Collected register metadata now retains both layers:

- `architecture_role`;
- `target_role`;
- `target_role_profile`;
- `target_role_spec`.

### No Linux UI regression intended

For the supported Linux target, the composed static role text deliberately
matches the established HUD wording. The ownership changed; the user-facing
wording did not.

Targets without a role overlay fall back to architecture truth instead of
silently inheriting another ABI.

### New regression

`tests/architecture_register_roles_smoke.lua` pins:

1. ABI-neutral hardware register roles;
2. SysV role ownership in the target profile;
3. SysV argument ordering;
4. shared-table identity through the ASM variant and master adapter;
5. preservation of established Linux static register wording;
6. metadata containing both hardware and target-role layers;
7. fallback to hardware truth when a target has no role overlay.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/architecture_registry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_target_overlay_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_register_roles_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
```


## Foundational inference tranche: exact integer transport and arithmetic (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

After the architecture/ABI ownership cleanup, source integer values still had
one foundational precision leak.

ASM operands remained source text initially, but register inference converted
integer immediates through Lua `tonumber()` and then `tostring()`. Values
above Lua's exact integer range could therefore be rounded or rendered in
scientific notation before reaching the exact register mask machinery.

### New architecture-neutral exact integer module

Created:

```text
lua/tracker_hud/low_level/integer_value.lua
```

It provides exact string-based integer operations without routing wide values
through floating point.

Supported source forms:

```text
decimal
+decimal
-decimal
0xHEX
+0xHEX
-0xHEX
0bBINARY
+0bBINARY
-0bBINARY
```

Normalized values are canonical signed decimal strings.

Examples:

```text
0x123456789ABCDEF0
    -> 1311768467463790320

0xFFFFFFFFFFFFFFFF
    -> 18446744073709551615
```

The module also provides exact signed addition/negation and an explicit
`to_safe_number()` boundary for subsystems that genuinely require a Lua
number.

### Register inference no longer round-trips through Lua numbers

`context_engine.lua` now uses exact normalized strings for:

- immediate register writes;
- current register values used by delta effects;
- fixed deltas;
- immediate delta operands;
- INC/DEC style arithmetic;
- ADD/SUB immediate state reduction.

For example:

```asm
mov rax, 0x123456789ABCDEF0
inc rax
sub rax, 0x10
```

reduces exactly as:

```text
1311768467463790320
1311768467463790321
1311768467463790305
```

No intermediate Lua floating-point conversion is used.

### Register operand resolution

`low_level/register_infer.lua` now uses the exact integer parser as its
fallback instead of `tonumber()`.

This means the exact contract is available even to callers that do not inject
the context engine's parser callback.

### Register byte/mask conversion

`low_level/register_value_mask.lua` now shares the same exact integer parser.

The certainty composer still performs byte arithmetic, but parsing decimal,
hexadecimal and binary source values is centralized.

Partial known masks/values are also routed through that exact conversion path.

### Stack depth remains deliberately numeric

Stack depth is a small relative offset model and still uses Lua numbers.

`stack_infer.lua` now explicitly converts integer strings through
`integer_value.to_safe_number()`.

Therefore:

- ordinary offsets such as 8/16/32 remain unchanged;
- unsafe values above 2^53 are rejected for stack-depth arithmetic;
- they are never silently rounded.

This does not prevent a wide pushed **value** from remaining exact; it only
protects the numeric stack-depth counter.

### Width overflow is NOT part of this tranche

This tranche establishes exact transport and exact signed arithmetic.

It does **not** yet claim architecture-width wrapping.

For example, generic exact arithmetic may represent:

```text
18446744073709551615 + 1
= 18446744073709551616
```

A later width-aware reducer must decide, from the target register family and
instruction semantics, whether an operation wraps, traps, saturates, becomes
unknown, or has some other architecture-specific behavior.

Keeping these steps separate avoids baking x86 overflow rules into the generic
integer layer.

### New tests

`tests/integer_value_smoke.lua` covers:

- canonical decimal parsing;
- exact 64-bit hexadecimal conversion;
- exact 64-bit binary conversion;
- signed addition above 2^53;
- exact negation;
- explicit Lua-safe-number boundary;
- invalid/unsafe numeric input rejection;
- safe stack-depth offsets;
- rejection of unsafe stack-depth numeric conversion.

`tests/wide_integer_inference_smoke.lua` is parser-backed and covers:

- wide x86-64 MOV immediate above 2^53;
- exact INC above 2^53;
- exact SUB immediate delta above 2^53;
- UINT64_MAX decimal immediate;
- exact round-trip from reduced register value to 64-bit bytes.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/integer_value_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/wide_integer_inference_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_register_roles_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
```

### Next foundational step after green

Add explicit bit-width semantics above the exact integer layer.

The target/register family must supply the width; the generic reducer may then
provide operations such as width validation and modular wrapping without
assuming x86-64 globally.

Only after that should wide arithmetic effects claim machine-width results.


## Foundational inference tranche: target-width integer semantics (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

The preceding exact-integer tranche removed Lua-number precision loss but
deliberately left one semantic question unanswered:

```text
18446744073709551615 + 1
```

The generic exact integer layer can represent the mathematical result exactly:

```text
18446744073709551616
```

but an architectural register may require a different result.

For x86 integer destination arithmetic, the destination width supplies the
modulus.

This tranche adds that width boundary without making x86 behavior a global
assumption.

### Generic exact width primitives

`lua/tracker_hud/low_level/integer_value.lua` now provides:

```text
fits_unsigned(value, bits)
fits_signed(value, bits)
normalize_unsigned(value, bits)
wrap_unsigned(value, bits)
```

All operations remain string exact.

Examples:

```text
wrap_unsigned(256, 8)
-> 0

wrap_unsigned(-1, 8)
-> 255

wrap_unsigned(18446744073709551616, 64)
-> 0

wrap_unsigned(-1, 64)
-> 18446744073709551615
```

The implementation is not limited to 64-bit machine widths. The regression
suite includes an exact `2^512 -> 0` wrap at 512 bits.

### Width remains architecture-owned

The generic reducer does not infer register width from names.

It obtains the target alias from the architecture-owned register alias index and
uses:

```text
alias.bits
```

Therefore:

```text
rax -> 64
eax -> 32
ax  -> 16
al  -> 8
```

come from the shared x86 architecture profile, not from the ASM adapter or UI.

### Explicit effect policy

Width behavior is opt-in.

The generic context reducer recognizes:

```lua
value_width_policy = "wrap_unsigned_target"
```

Only effects that declare this policy receive modulo-target-width reduction.

Unknown width policies fail closed instead of guessing.

The reducer also records semantic metadata:

```text
value_width_policy
value_width_bits
pre_width_write_value
value_wrapped
value_width_error
```

The `value_wrapped` field preserves a real boolean `false`; absence and false
are not collapsed.

### x86 declarations

All currently value-reduced x86 integer arithmetic delta effects declare
`wrap_unsigned_target`:

```text
add_register_immediate
sub_register_immediate
inc_register
dec_register

incb_writes_destination
incw_writes_destination
incl_writes_destination
incq_writes_destination

decb_writes_destination
decw_writes_destination
decl_writes_destination
decq_writes_destination
```

No MOV/data-movement rule receives arithmetic wrapping.

### Alias composition remains downstream

Width normalization is applied to the value written to the architectural target
**before** the existing alias composer.

That preserves established x86-64 alias behavior.

Examples:

```text
INC RAX at UINT64_MAX
    mathematical result = 18446744073709551616
    target width = 64
    written value = 0

INC EAX at UINT32_MAX
    mathematical result = 4294967296
    target width = 32
    written value = 0
    alias rule then zero-extends EAX into RAX

INC AX at UINT16_MAX
    written AX = 0
    surrounding RAX bits are preserved

INC AL at UINT8_MAX
    written AL = 0
    surrounding RAX bits are preserved
```

Negative underflow uses the same exact modulo rule:

```text
0 - 1 at 8 bits
-> 255
```

### Deliberate boundary: immediate encoding semantics

This tranche does **not** claim to model x86 immediate encoding/sign extension.

Destination-width arithmetic and immediate interpretation are separate concerns.

For example, an instruction whose encoded immediate is sign-extended must
eventually declare that source-operand rule explicitly. The width reducer only
receives the already interpreted arithmetic value and applies destination-width
semantics.

Do not add implicit x86 imm8/imm32 sign-extension rules to
`integer_value.lua`.

### New tests

`tests/integer_width_smoke.lua`

Covers:

- unsigned fit boundaries;
- signed fit boundaries;
- range-checked unsigned normalization;
- positive and negative 8-bit wrapping;
- 16-bit wrapping;
- exact 64-bit wrapping above Lua precision;
- exact 512-bit wrapping;
- invalid width rejection.

`tests/x86_width_policy_contract_smoke.lua`

Covers:

- every currently reduced x86 arithmetic delta declares
  `wrap_unsigned_target`;
- exactly 12 such effects currently exist;
- no non-delta arithmetic effect declares wrapping.

`tests/x86_width_wrap_state_smoke.lua`

Parser-backed coverage includes:

- MOV stays outside arithmetic policy;
- UINT64_MAX INC wraps to zero;
- zero DEC wraps to UINT64_MAX;
- ADD immediate overflow wraps at 64 bits;
- SUB immediate underflow wraps at 64 bits;
- EAX wraps at 32 bits and then zero-extends;
- AX wraps at 16 bits;
- AL wraps at 8 bits;
- AL underflow wraps to 0xFF.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/integer_value_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/integer_width_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/x86_width_policy_contract_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/wide_integer_inference_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_width_wrap_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_register_roles_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
```

### Next foundational work after green

The strongest next architectural target is **operand interpretation and
structural memory semantics**.

Two related pieces now stand out:

1. declare source-immediate extension semantics separately from destination
   width behavior;
2. continue replacing memory-expression strings with structural facts:
   base/index/scale/displacement/symbol/address mode.

The exact integer and target-width layers should remain reusable by both.


## Foundational inference tranche: source immediate interpretation (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

The target-width tranche established the final arithmetic destination boundary:

```text
exact mathematical result
    -> declared destination-width policy
    -> architectural alias composition
```

One semantic layer was still missing before that boundary:

```text
what exact integer does the source immediate represent?
```

That question is not the same as destination wrapping.

For x86-64 integer ADD/SUB forms, a 64-bit destination does not carry an
arbitrary 64-bit immediate. The architectural immediate is capped at 32 bits
and is interpreted as a signed value before the destination arithmetic is
performed.

This tranche makes source interpretation explicit and reusable.

### Exact signed bit-pattern interpretation

`lua/tracker_hud/low_level/integer_value.lua` now provides:

```text
reinterpret_signed(value, bits)
```

The operation is exact and string-based.

Examples:

```text
reinterpret_signed(255, 8)
-> -1

reinterpret_signed(128, 8)
-> -128

reinterpret_signed(127, 8)
-> 127

reinterpret_signed(18446744073709551615, 64)
-> -1
```

Values that cannot fit either the signed or raw unsigned bit-pattern range of
the declared width fail closed.

Examples:

```text
reinterpret_signed(256, 8)
-> nil

reinterpret_signed(-129, 8)
-> nil
```

### Architecture-neutral operand policy module

Created:

```text
lua/tracker_hud/low_level/integer_operand.lua
```

This layer interprets an already exact integer according to declarative source
semantics.

Supported interpretation kinds:

```text
exact
signed_bits
unsigned_bits
```

Widths may be:

```text
fixed
target-derived
target-derived with max/min bounds
```

For example:

```lua
{
    kind = "signed_bits",
    bits_from = "target",
    max_bits = 32,
}
```

means:

```text
use target width as source width,
but never interpret more than 32 source bits
```

Thus:

```text
target 64 -> source bits 32
target 32 -> source bits 32
target 16 -> source bits 16
target  8 -> source bits  8
```

The module is architecture-neutral. It does not know what RAX/EAX/AX/AL are.

### Runtime policy validation

The low-level interpreter itself fails closed on malformed policies.

Rejected examples include:

- both `bits` and `bits_from`;
- neither width source for signed/unsigned policies;
- invalid `max_bits` / `min_bits`;
- `min_bits > max_bits`;
- unsupported width derivation;
- width fields attached to `kind = "exact"`;
- unsupported interpretation kinds.

Correctness therefore does not depend solely on adapter registration.

### Context-engine integration

`context_engine.lua` now supports two optional effect declarations:

```text
value_operand_interpretation
value_delta_operand_interpretation
```

The source interpretation occurs before destination-width reduction.

The semantic pipeline is now:

```text
source text
    -> exact integer normalization
    -> declared source integer interpretation
    -> exact mathematical instruction effect
    -> declared destination-width policy
    -> architectural alias composition
    -> canonical register state
```

Existing effects that declare no interpretation policy retain their previous
behavior.

### Source interpretation metadata

Register facts now preserve:

```text
source_integer_interpretation
source_integer_bits
source_integer_bits_source
source_integer_max_bits
source_integer_min_bits
source_integer_raw_value
source_integer_value
source_integer_error
```

This keeps source spelling/bit-pattern truth separate from the interpreted
mathematical value.

Example:

```text
source:
0xFFFFFFFF

raw exact integer:
4294967295

interpretation:
signed_bits

source bits:
32

interpreted mathematical value:
-1
```

### x86 ADD/SUB declaration

Only the two currently reduced register-immediate arithmetic effects opt in:

```text
add_register_immediate
sub_register_immediate
```

Each declares:

```lua
value_delta_operand_interpretation = {
    kind = "signed_bits",
    bits_from = "target",
    max_bits = 32,
}
```

The existing destination declaration remains:

```lua
value_width_policy = "wrap_unsigned_target"
```

The two policies serve different purposes.

### Result examples

```asm
mov rax, 0
add rax, 0xFFFFFFFF
```

reduces as:

```text
raw source             = 4294967295
source bits            = 32
interpreted source     = -1
mathematical result    = -1
destination bits       = 64
final RAX              = 18446744073709551615
```

For subtraction:

```asm
mov rax, 0
sub rax, 0xFFFFFFFF
```

becomes:

```text
interpreted source     = -1
0 - (-1)               = 1
final RAX              = 1
```

Signed boundary examples:

```text
0x80000000 -> -2147483648
0x7FFFFFFF ->  2147483647
```

### Smaller aliases

The same declaration derives source width from the architecture-owned alias:

```text
EAX -> 32 source bits
AX  -> 16 source bits
AL  ->  8 source bits
```

The destination-width and alias-composition layers then run normally.

### Fail-closed encodability boundary

For the declared RAX ADD/SUB source policy:

```text
0x100000000
```

does not fit the 32-bit source field.

Tracker_HUD therefore produces an unresolved write fact with:

```text
source_integer_error = "value does not fit source width"
```

It does not truncate the source to 32 bits.

### MOV remains separate

`mov_register_immediate` intentionally has no source interpretation policy in
this tranche.

Data movement has different encoding choices and must not inherit arithmetic
immediate semantics merely because both instructions contain integer operands.

### Shared Adapter Contract validation

`lua/tracker_hud/adapters/contract.lua` now validates semantic declarations.

Supported destination policy:

```text
wrap_unsigned_target
```

Supported integer interpretations:

```text
exact
signed_bits
unsigned_bits
```

The contract validates:

- policy names;
- fixed widths;
- target-derived widths;
- min/max width bounds;
- required source operand references;
- required destination target references.

Existing effects with no such declarations remain valid under Adapter Contract
v1.

### New tests

`tests/integer_operand_smoke.lua`

Covers:

- exact interpretation;
- fixed signed-bit interpretation;
- signed boundaries;
- target-derived/capped width;
- smaller target widths;
- unsigned interpretation;
- out-of-range rejection;
- missing/unknown policy rejection;
- malformed runtime policy rejection.

`tests/x86_immediate_policy_contract_smoke.lua`

Covers:

- exactly ADD/SUB declare the x86 arithmetic immediate policy;
- the policy shape is signed/target-derived/capped-32;
- MOV remains outside arithmetic interpretation.

`tests/x86_immediate_interpretation_smoke.lua`

Parser-backed coverage includes:

- RAX ADD of `0xFFFFFFFF`;
- RAX SUB of `0xFFFFFFFF`;
- signed imm32 lower/upper boundaries;
- EAX/AX/AL derived source widths;
- out-of-range imm32 failure.

`tests/effect_semantic_contract_smoke.lua`

Covers:

- current ASM semantic declarations validate;
- unknown interpretation kind rejection;
- invalid source width rejection;
- interpretation without source operand rejection;
- unknown destination-width policy rejection;
- width policy without a target rejection;
- valid exact value-operand policy acceptance.

`tests/integer_width_smoke.lua` additionally pins the underlying signed
bit-pattern primitive directly, including exact 64-bit cases.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -14 --oneline

nvim --headless -u NONE -c "luafile tests/integer_value_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/integer_width_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/integer_operand_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/x86_width_policy_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/x86_immediate_policy_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/effect_semantic_contract_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/wide_integer_inference_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_width_wrap_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/architecture_register_roles_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
```

### Next foundational tranche after green

Proceed to **structural memory operands**.

The parser already exposes memory-oriented metadata in several places, but the
long-term semantic model should make these first-class normalized fields:

```text
base register
index register
scale
displacement
symbol
address mode
segment / architecture extension when required
```

The exact integer and source-interpretation layers from the preceding tranches
should be reused for displacement values rather than reparsing memory text in
presentation code.


## Integration repair: canonical-to-alias register reads (2026-11-10)

**Status: pushed on `main`, pending ERIDU acceptance.**

The first ERIDU run of the source-immediate tranche proved that:

- the configured x86 ADD/SUB source policy survived adapter configuration;
- RAX ADD/SUB signed imm32 interpretation worked;
- the signed imm32 boundaries worked;
- the failure began only when the arithmetic destination was a subregister.

The failing sequence was structurally equivalent to:

```asm
mov rax, 0
add eax, 0xFFFFFFFF
```

### Root cause

Register-write reduction already tracked one canonical family state, but
register reads still primarily looked up the literal source spelling.

After a full `RAX` write, the reducer had a proven `rax` fact but no separate
`eax` fact. Arithmetic on `EAX` therefore failed to obtain its previous
value even though bits 31..0 were fully known.

This was an alias-read defect, not an immediate-interpretation defect.

### New canonical-to-alias projection

`low_level/register_value_mask.lua` now exposes:

```text
read_alias_value(canonical_fact, alias_spec)
```

It uses the existing certainty-mask model.

A read succeeds only when every bit/byte of the requested alias slice is proven.

Examples from a known canonical value:

```text
RAX = 0x0011223344556677

EAX -> 0x44556677
AX  -> 0x6677
AH  -> 0x66
AL  -> 0x77
```

The returned value is an exact canonical decimal integer string.

### Partial canonical state

Partial canonical facts are now retained in the register-read map as unresolved
whole-register facts with their certainty metadata intact.

That does NOT make the whole register resolved.

It allows a later alias read to ask whether its own slice is fully proven.

Example:

```text
known mask = 0xFFFFFFFFFFFF00FF
```

means:

- AL can still be read exactly;
- AH cannot;
- AX cannot.

This preserves the distinction between partial certainty and fabricated whole-register certainty.

### Generic register-read callback

`low_level/register_infer.lua` now accepts an optional
`resolve_register_fact` callback.

The context engine supplies an architecture-aware implementation that:

1. tries the exact alias spelling;
2. resolves the architecture-owned alias family;
3. falls back to canonical family state;
4. projects the requested alias only if its slice is proven.

This path is reused for:

- arithmetic target reads;
- implicit register sources;
- register source operands;
- generic value operands;
- stack operand resolution.

The stack preparation helper was also corrected to carry the active adapter
into this callback.

### New tests

`tests/register_value_mask_smoke.lua` now pins:

- exact EAX/AX/AH/AL projection from known RAX;
- projection from partial canonical certainty;
- refusal to resolve aliases whose slice includes unknown bits.

New parser-backed regression:

`tests/x86_alias_read_state_smoke.lua`

It covers:

- full RAX -> ADD EAX;
- full RAX -> ADD AX;
- full RAX -> ADD AH;
- full RAX -> ADD AL;
- partial canonical RAX -> ADD AL when AL remains fully proven.

The source-immediate regression now also reports EAX/AX/AL fields separately if
another integration mismatch remains.

### Targeted ERIDU repair gate

```bat
git pull --ff-only

nvim --headless -u NONE -c "luafile tests/register_value_mask_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
```

If these are green, rerun the broader source-immediate acceptance gate before
starting structural-memory work.


## Stability follow-up: alias-read repeatability gate (2026-11-10)

**Status: pushed on `main`, pending ERIDU repeatability acceptance.**

ERIDU produced one transient result after pulling the canonical-to-alias repair:

```text
FAIL x86 canonical-to-alias read smoke:
EAX arithmetic must read low 32 bits from known canonical RAX
```

Running the exact same command again immediately, with no code change, passed the
entire test:

```text
PASS x86 alias read: EAX projects known canonical low dword
PASS x86 alias read: AX projects known canonical low word
PASS x86 alias read: AH projects known canonical high byte
PASS x86 alias read: AL projects known canonical low byte
PASS x86 alias read: partial canonical certainty feeds proven alias reads
PASS Tracker_HUD x86 canonical-to-alias read smoke
```

The source-immediate and alias-write regressions also passed in that same ERIDU
session.

The parser itself does not depend on the arbitrary register-effect representative
rule: `instruction_utils.parse_instruction()` ignores the effect-spec argument
and parses from the adapter's instruction construct specification.

To guard against reducer/cache mutation within one process,
`tests/x86_alias_read_state_smoke.lua` now repeats the canonical RAX -> EAX
collection 32 times and requires the exact same reduced state every time.

New expected line:

```text
PASS x86 alias read: repeated collection is deterministic
```

For this stability gate, run the parser-backed smoke once with normal Neovim and
once with `-u NONE`. The latter avoids user-init/plugin startup contamination
while still using the installed Tree-sitter parser if it is available on the
standard site runtime.

```bat
git pull --ff-only

nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"
```

If `-u NONE` cannot see the installed ASM parser, that is an environment
limitation rather than a semantic failure; the normal-config repeatability line
is still the required product gate.


## Accepted stability gate: canonical alias reads (2026-11-11)

**Accepted on ERIDU at `f51c19f`.**

The canonical-to-alias repair passed in both normal Neovim and `-u NONE`.

Confirmed:

```text
PASS x86 alias read: EAX projects known canonical low dword
PASS x86 alias read: repeated collection is deterministic
PASS x86 alias read: AX projects known canonical low word
PASS x86 alias read: AH projects known canonical high byte
PASS x86 alias read: AL projects known canonical low byte
PASS x86 alias read: partial canonical certainty feeds proven alias reads
PASS Tracker_HUD x86 canonical-to-alias read smoke
```

The full source-immediate interpretation smoke also passed through RAX/EAX/AX/AL
and the out-of-range imm32 fail-closed case.

The alias-read stability concern is therefore closed.

## Foundational memory tranche: normalized structural operands (2026-11-11)

**Status: pushed on `main`, pending ERIDU acceptance.**

ASM memory expressions previously exposed useful token components to source-focus
logic, but their primary semantic representation was still the raw source
string plus presentation-oriented component labels.

This tranche introduces one normalized, architecture-neutral memory-address
shape.

### New normalized address model

Created:

`lua/tracker_hud/low_level/memory_address.lua`

The version-1 normalized shape exposes:

```text
base
index
scale
displacement
symbol
address_mode
memory_size_bits
terms
source
```

alongside:

```text
kind
container_kind
address_kind
address_text
memory_size_prefix
memory_size_label
```

The model deliberately records:

```text
effective_address = unknown
runtime_address   = unknown
```

Source structure is not execution proof.

### Structural role vs display role

Existing x86 presentation overrides remain useful:

```text
rbp -> frame pointer base
rsp -> stack pointer base
rip -> instruction pointer relative base
```

Those display roles no longer replace the semantic role.

Memory components now retain both:

```text
structural_role
role / display_role
```

For example:

```text
rbp

structural_role = base_register
display_role    = frame pointer base
```

Existing HUD wording can remain unchanged while inference gets a stable role ID.

### Structural identity is not runtime value

For register and symbol components, the normalized model knows identity only.

Examples:

```text
base.name = rbp
base.identity_known = true
base.value_status = not_evaluated

symbol.name = msg
symbol.identity_known = true
symbol.value_status = not_evaluated
```

They do not claim a resolved runtime value/address.

Only exact integer components such as scale/displacement carry numeric
resolution in this tranche.

### Exact displacement parsing

Scale/displacement values reuse the exact integer foundation.

Examples:

```text
4       -> 4
-0x10   -> -16
0b1000  -> 8
```

Memory parsing now recognizes binary integer tokens as well as decimal/hex.

### Declarative address modes

The generic ASM memory parser can now consume adapter-declared address-mode
tokens.

The x86-64 profile currently declares NASM-style:

```text
rel -> relative
abs -> absolute
```

Therefore:

```asm
[rel msg]
```

normalizes as:

```text
address_mode       = relative
address_mode_token = rel
symbol.name        = msg
```

rather than treating `rel msg` as one symbol string.

Likewise:

```asm
[abs 0x1234]
```

keeps:

```text
address_mode = absolute
displacement = 4660
```

### Parser integration

`adapters/asm/instruction_utils.lua` now attaches:

```text
operand.memory.normalized
```

for parsed memory operands.

The existing raw memory fields/components remain available for compatibility.

### First-class context source facts

`context_engine.lua` now exposes:

```text
discover_memory_source_operands(...)
collect_memory_source_operands(...)
```

The discovery path is syntax-first. It scans instruction syntax directly and
does not require complete register-effect coverage merely to expose a memory
operand.

Effect rules, when available, may enrich the source fact with operand-role
metadata.

A memory source fact contains:

```text
kind     = memory_operand
category = memory
source   = asm_source_memory
address  = normalized address structure
```

and exact source ranges.

### ON/PAST context lifecycle

For ASM, normal context construction now attaches:

```text
context.source_memory_operands
```

containing only operands ON or BEFORE the cursor source line.

Future memory syntax must not leak backward.

These source operands remain separate from Heap/Events. Seeing an address
expression does not prove an access executed, an allocation happened, or a
runtime address exists.

### Existing Inspect metadata reuses the same structure

The existing source-occurrence path now exposes:

```text
memory_address_structured
memory_address_mode
memory_base_register
memory_index_register
memory_scale
memory_displacement
memory_symbol
```

from the same normalized address object.

Memory component metadata now uses the stable structural ID for:

```text
address_role_id
```

while retaining the old presentation-specific role in:

```text
address_display_role_id
```

This avoids a parallel parser/model for Inspect.

### Ambiguity

If multiple components compete for a singular convenience field such as
`base`, the first parsed component is retained, all terms remain preserved,
and:

```text
metadata.ambiguous.base = true
```

is set.

The normalizer does not silently overwrite conflicting structure.

### Adapter Contract protection

`adapters/contract.lua` now validates memory declarations when an adapter
provides them.

Checked fields include:

- memory kind/container/address-kind strings;
- open/close brackets;
- address modes;
- size-prefix bit widths/labels;
- component-role declarations;
- register-role overrides.

Adapters that declare no memory semantics remain unaffected.

### New regressions

`tests/memory_address_smoke.lua`

Pins:

- structural base/index/scale/displacement;
- exact negative hexadecimal displacement;
- memory size;
- structural vs display roles;
- identity vs runtime-value certainty;
- relative mode + symbol separation;
- ambiguity handling;
- no invented runtime address.

`tests/asm_memory_structure_smoke.lua`

Parser-backed coverage includes:

- `qword [rbp + rcx*4 - 0x10]`;
- `[rsp + 8]`;
- `[rel msg]`;
- `[abs 0x1234]`;
- binary displacement;
- first-class context discovery;
- normalized Inspect metadata;
- structural/display component-role separation;
- ON/PAST context visibility;
- separation from runtime Events.

`tests/memory_adapter_contract_smoke.lua`

Pins rejection of malformed:

- address modes;
- size widths;
- brackets;
- component roles;
- register-role overrides.

### Deliberate boundary: no effective-address evaluation yet

This tranche does NOT compute:

```text
base_value + index_value * scale + displacement
```

even if some register values are currently known.

It also does not yet claim load/store execution or runtime memory contents.

The foundation is:

```text
trustworthy structural address representation first
```

before adding memory-access or effective-address semantics.

### ERIDU gate

```bat
git status --short
git pull --ff-only
git log -15 --oneline

nvim --headless -u NONE -c "luafile tests/memory_address_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_adapter_contract_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
```

### Next foundational step after green

Keep memory semantics layered.

The next likely tranche should describe **memory access intent** separately from
address structure:

```text
read
write
read_write
address_only
unknown
```

That will allow MOV/LEA/atomic/string instructions to state what they do with a
normalized address without pretending memory contents are already modeled.

Only after access intent is reliable should effective-address calculation reuse
known register state and exact displacement arithmetic.


## Test-harness repair: force parser regressions onto the working tree (2026-11-11)

**Status: pushed on `main`, pending ERIDU confirmation.**

The first ERIDU run of the structural-memory tranche produced an impossible state
for the committed parser implementation:

```text
operand.memory existed
operand.memory.normalized was nil
```

At the same time, the older source-focus regression still printed:

```text
memory_component:rel msg
```

instead of separating:

```text
address_mode = relative
symbol = msg
```

Static review confirmed:

- the repository contains only one
  `lua/tracker_hud/adapters/asm/instruction_utils.lua`;
- its committed `analyze_memory_operand()` always assigns
  `memory.normalized = memory_address.normalize(memory)` before returning;
- the default ASM variant is x86-64;
- the x86 variant entry point is the exact adapter module containing the new
  memory declarations.

Therefore a current-repository parser cannot return a memory table lacking
`normalized`.

The remaining credible cause is normal Neovim startup preloading an installed or
plugin-manager copy of Tracker_HUD before the regression script prepends the
working repository to `runtimepath`.

Lua `require()` consults `package.loaded` first, so changing runtimepath after
the module has already been loaded does not replace that cached module.

### Working-tree isolation helper

Created:

```text
tests/test_runtime.lua
```

Parser-backed source-tree regressions now call:

```lua
dofile("tests/test_runtime.lua").use_working_tree()
```

before requiring Tracker_HUD modules.

The helper:

1. prepends the current repository to Neovim runtimepath;
2. removes every cached `tracker_hud` / `tracker_hud.*` module from
   `package.loaded`;
3. allows subsequent `require()` calls to load the freshly pulled working tree.

Applied to:

```text
tests/asm_memory_structure_smoke.lua
tests/asm_register_focus_regression.lua
tests/x86_alias_read_state_smoke.lua
tests/x86_alias_write_state_smoke.lua
tests/x86_immediate_interpretation_smoke.lua
tests/x86_width_wrap_state_smoke.lua
```

### Isolation regression

Created:

```text
tests/test_runtime_smoke.lua
```

The test deliberately installs a fake stale module into:

```lua
package.loaded["tracker_hud.low_level.memory_address"]
```

then runs the helper and requires the module again.

Expected:

```text
PASS test runtime: preloaded Tracker_HUD module is evicted
PASS test runtime: repository implementation reloads from working tree
PASS Tracker_HUD test runtime isolation smoke
```

### Targeted ERIDU gate

```bat
git pull --ff-only

nvim --headless -u NONE -c "luafile tests/test_runtime_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

If the normalized-memory regression still fails after this isolation, treat it
as a real parser defect and inspect the now-current module path/state.

Do not weaken structural-memory assertions.


## Structural-memory parser repair: size prefix outside ptr node (2026-11-11)

ERIDU confirmed the working-tree runtime isolation fix.

After isolation:

- `rel msg` correctly became symbol `msg`;
- `operand.memory.normalized` existed;
- the remaining failure was the first structured-memory assertion.

Static parser review showed the most likely boundary: Tree-sitter's `ptr` node can begin
at the opening bracket, leaving NASM size qualifiers such as `qword` immediately
to the left of the pointer node instead of inside `operand.text`.

The parser previously only called:

```lua
parse_memory_prefix(operand_text, memory_spec)
```

which cannot see a qualifier that is outside the ptr node.

The parser now falls back to the source buffer when no size was found inside the
node. It inspects only the text immediately before the ptr node within the current
comma-separated operand segment and accepts the final word only if it is a declared
memory size prefix.

Example:

```asm
mov rax, qword [rbp + rcx*4 - 0x10]
```

can now recover:

```text
memory_size_prefix = qword
memory_size_bits   = 64
```

without changing the structural address parser.

The parser-backed regression now reports the line-2 fields separately:

```text
line 2 memory size
line 2 base register
line 2 index register
line 2 scale
line 2 displacement
```

so any remaining defect identifies the exact structural field.

Targeted ERIDU gate:

```bat
git pull --ff-only

nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```


## Accepted structural-memory gate after Neovim sync (2026-11-11)

The normalized structural-memory tranche is accepted green on ERIDU.

The user identified that the first size-prefix failure happened before their local
Neovim/plugin copy had been synchronized with the freshly pulled repository.
After synchronizing Neovim and rerunning, the parser-backed structural-memory
regression passed repeatedly:

~~~
PASS ASM memory structure: base/index/scale/displacement + qword size
PASS ASM memory structure: context exposes normalized source memory operand
PASS ASM memory structure: stack-relative base/displacement
PASS ASM memory structure: REL mode separated from symbol
PASS ASM memory structure: ABS mode + exact hexadecimal displacement
PASS ASM memory structure: binary displacement stays exact
PASS ASM memory structure: Inspect metadata reuses normalized address
PASS ASM memory structure: context obeys ON/PAST visibility
PASS ASM memory structure: source operands stay separate from runtime events
PASS Tracker_HUD ASM normalized memory structure smoke
~~~

The source-focus regression also remained green and showed the new structural
REL behavior:

~~~
memory_component:msg
~~~

instead of treating rel msg as one symbol token.

The structural-address representation is therefore the accepted foundation for
the next semantic layer.

## Foundational memory tranche: access intent (2026-11-11)

**Status: pushed on main, pending ERIDU acceptance.**

Address structure and memory access behavior are now modeled as separate concerns.

A normalized address answers:

~~~
where does the source expression point structurally?
~~~

Access intent answers:

~~~
what does this instruction intend to do with that memory operand?
~~~

Neither question implies that the instruction executed.

### Normalized vocabulary

Created:

~~~
lua/tracker_hud/low_level/memory_access.lua
~~~

Supported access kinds:

~~~
read
write
read_write
address_only
unknown
~~~

The resolver is architecture-neutral and consumes adapter-owned declaration
tables.

If no declaration matches, the result is unknown.

If direct callers provide conflicting rules, the resolver also fails closed to
unknown and marks the result ambiguous.

### x86-64 declarations

Created:

~~~
lua/tracker_hud/adapters/asm/arch/x86_64/memory_accesses.lua
~~~

The first deliberately small declaration set is:

~~~
MOV operand 1 memory -> write
MOV operand 2 memory -> read
LEA operand 2 memory -> address_only
~~~

Examples:

~~~
mov rax, [rbp + 8]
-> read

mov [rsp + 8], rax
-> write

lea rsi, [rel msg]
-> address_only
~~~

Instructions not yet declared remain unknown.

This is intentional. A read-modify-write instruction should eventually declare
read_write explicitly rather than being guessed from its mnemonic.

### Variant ownership

The x86 variant owns its memory-access table.

The master ASM adapter now forwards memory_accesses from the active architecture
variant alongside register, stack, boundary, and event semantics.

Memory access behavior is therefore instruction/architecture semantics, not
hardware-register truth and not presentation logic.

### Source memory facts

context_engine.lua now attaches access intent directly to first-class source
memory operands:

~~~
fact.access
metadata.access_intent
metadata.access_declared
metadata.access_ambiguous
metadata.access_rule_count
metadata.execution_status
~~~

Source observations always record:

~~~
execution_status = not_observed
~~~

This preserves the distinction:

~~~
source says this is a read
!=
the read definitely executed
~~~

### Inspect reuse

Existing source/Inspect memory metadata now resolves the same adapter declaration
and exposes:

~~~
memory_access_intent
memory_access_declared
memory_access_ambiguous
memory_access_rule_count
memory_execution_status
~~~

Thus context facts and focused source components consume one access model.

### Adapter Contract validation

adapters/contract.lua now validates optional adapter.memory_accesses.

For each mnemonic, rules must be a non-empty array.

Each rule must declare:

~~~
operand_index
access
~~~

and may declare:

~~~
operand_kind
~~~

The contract rejects:

- non-positive or fractional operand indexes;
- unknown access kinds;
- empty operand kinds;
- duplicate rules for the same mnemonic/operand index.

Duplicate rules are rejected because true read-modify-write behavior should be
declared as one explicit read_write rule.

### New regressions

tests/memory_access_smoke.lua pins:

- read intent;
- write intent;
- address-only intent;
- read-write vocabulary;
- undeclared fallback to unknown;
- conflicting direct rules fail closed;
- normalized access vocabulary.

tests/asm_memory_access_smoke.lua provides parser-backed x86 coverage for:

- MOV memory source -> read;
- MOV memory destination -> write;
- LEA memory operand -> address_only;
- undeclared INC memory operand -> unknown;
- unknown intent preserves normalized structure;
- Inspect metadata reuses address-only intent;
- context ON/PAST lifecycle preserves access intent;
- execution remains not_observed.

tests/memory_adapter_contract_smoke.lua now additionally pins rejection of:

- invalid access kind;
- duplicate access rule;
- invalid access operand index.

### Deliberate boundary

This tranche still does NOT infer:

~~~
effective runtime address
memory contents
successful memory access
instruction execution
~~~

It only adds source-level intended access semantics to the already-normalized
address structure.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/memory_access_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_adapter_contract_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_access_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
~~~

### Next foundational step after green

The next memory layer should be effective-address evaluation from proven state.

It should reuse:

~~~
normalized base/index/scale/displacement
canonical register-state certainty
exact integer arithmetic
target-width semantics
~~~

and return a certainty-aware address result.

Do not evaluate an address unless every required numeric component is proven.

Symbols such as rel msg need a separate symbol-address model before they can
become numeric effective addresses.

Even a known effective address must remain distinct from proof that a memory
access executed or that memory contents are known.


## Accepted memory access-intent gate (2026-11-11)

The memory access-intent tranche is accepted green on ERIDU.

Confirmed:

~~~
PASS memory access: declared read intent resolves
PASS memory access: declared write intent resolves
PASS memory access: address-only intent remains distinct
PASS memory access: read_write intent remains distinct
PASS memory access: undeclared intent fails closed
PASS memory access: conflicting rules fail closed
PASS memory access: normalized access vocabulary
PASS Tracker_HUD memory access-intent smoke
~~~

Parser-backed x86 coverage also passed:

~~~
PASS ASM memory access: MOV source memory is read
PASS ASM memory access: MOV destination memory is write
PASS ASM memory access: LEA is address_only
PASS ASM memory access: Inspect reuses address-only intent
PASS ASM memory access: undeclared instruction stays unknown
PASS ASM memory access: context preserves ON/PAST access intent
PASS Tracker_HUD ASM memory access-intent smoke
~~~

The structural-memory, register-focus, alias-read, Adapter Contract, and
normalized-fact regressions remained green.

## Foundational memory tranche: effective-address evaluation (2026-11-11)

**Status: pushed on main, pending ERIDU acceptance.**

The previous memory layers now separate three distinct facts:

~~~
address structure
access intent
execution status
~~~

This tranche adds a fourth:

~~~
source-derived effective-address value
~~~

only when every required numeric input is proven.

A known effective address still does not imply:

~~~
the instruction executed
memory was successfully accessed
memory contents are known
the pointer is valid
~~~

### Exact multiplication

Updated:

~~~
lua/tracker_hud/low_level/integer_value.lua
~~~

New operation:

~~~
multiply(left, right)
~~~

It preserves exact signed decimal-string arithmetic and never routes wide values
through Lua floating-point numbers.

Examples:

~~~
3 * 4
-> 12

-3 * 4
-> -12

18446744073709551615 * 4
-> 73786976294838206460
~~~

This is required for index*scale address terms.

### Architecture-neutral effective-address evaluator

Created:

~~~
lua/tracker_hud/low_level/effective_address.lua
~~~

The evaluator consumes:

~~~
normalized address structure
+
caller-supplied register resolver
+
optional target address width
~~~

It knows no x86 register names.

For a normalized address:

~~~
base         = rbp
index        = rcx
scale        = 4
displacement = -8
~~~

with:

~~~
rbp = 4096
rcx = 3
~~~

the exact source expression is:

~~~
4096 + 3*4 - 8
= 4100
~~~

### Certainty rules

The evaluator returns:

~~~
status = known
value
bits
wrapped
components
~~~

or:

~~~
status = unknown
reason
details
~~~

It fails closed when:

- a required base register is unresolved;
- a required index register is unresolved;
- scale/displacement cannot be normalized;
- scale exists without an index;
- the structural address is ambiguous;
- a symbol has no numeric address model;
- relative addressing requires an unavailable instruction-position basis;
- address-width wrapping cannot be performed.

### Relative addresses

Explicit relative address modes remain unresolved.

For example:

~~~
[rel msg]
~~~

does NOT become a guessed numeric address.

Likewise:

~~~
[rel 0x10]
~~~

does NOT become absolute address 16.

The current model does not yet have a numeric instruction-position / next-IP
basis, so the evaluator reports:

~~~
relative address basis unresolved
~~~

This is deliberate.

### Absolute numeric addresses

A displacement-only absolute numeric address can evaluate directly.

Example:

~~~
[abs 0x1234]
-> 4660
~~~

provided the architecture address width is known.

### Target-width wrapping

The evaluator can optionally apply the architecture address width after exact
mathematical evaluation.

Example for x86-64:

~~~
base = 18446744073709551615
displacement = 1

exact:
18446744073709551616

64-bit effective:
0

wrapped = true
~~~

### Active architecture metadata forwarding

The effective-address audit found that the mutable master ASM adapter did not
forward variant metadata.

Updated:

~~~
lua/tracker_hud/adapters/asm/adapter.lua
~~~

The active variant now forwards:

~~~
metadata
~~~

alongside its other architecture-owned tables.

For x86-64 this exposes:

~~~
metadata.architecture = x86-64
metadata.bits = 64
metadata.endian = little
~~~

Generic consumers therefore obtain address width from architecture truth rather
than hard-coded x86 logic.

### Pre-instruction state

Effective addresses are evaluated from register state strictly BEFORE the memory
instruction begins.

The context engine uses its existing source-position reducer boundary:

~~~
limit_position = instruction start
~~~

This matters for self-referential instructions.

Example:

~~~
mov rax, 0x2000
lea rax, [rax + 8]
~~~

The LEA address uses the old RAX:

~~~
base = 8192
effective = 8200
~~~

not any post-instruction destination state.

### Canonical register certainty reuse

The context engine converts the reduced register facts into a lookup map and
uses the existing alias-aware register read path.

Thus effective-address evaluation automatically inherits:

~~~
known canonical register state
partial certainty handling
canonical-to-alias projection
fail-closed unresolved reads
~~~

The first parser-backed effective-address tranche deliberately does not claim
32-bit address-size semantics from EAX/ESP forms yet. Address-size override
semantics should be modeled explicitly rather than silently inheriting 64 bits.

### Source memory facts

First-class memory source facts now carry:

~~~
effective_address = {
    status,
    value,
    bits,
    wrapped,
    components,
    reason/details when unknown
}
~~~

Metadata also exposes:

~~~
effective_address
effective_address_status
effective_address_value
effective_address_reason
effective_address_bits
effective_address_wrapped
~~~

The compatibility effective_address field contains the proven value when known,
otherwise "unknown".

Runtime execution remains:

~~~
runtime_address = unknown
execution_status = not_observed
~~~

### Inspect reuse

Register/source occurrence metadata now consumes the same evaluated result.

Inspect metadata exposes:

~~~
memory_effective_address
memory_effective_address_status
memory_effective_address_value
memory_effective_address_reason
memory_effective_address_bits
memory_effective_address_wrapped
~~~

So selecting base/index/symbol components reuses the same source-time evaluation
rather than reparsing or recomputing via presentation code.

### Context lifecycle

context.source_memory_operands preserves effective-address certainty for every
visible source operand at that operand's own source-time register state.

A later register write must not retroactively change an earlier address fact.

The first implementation uses the existing prefix reducer per memory instruction
for correctness and semantic reuse. If profiling later shows this is expensive
on large files, prefix-state snapshots can optimize it without changing the
effective-address contract.

### New regressions

tests/integer_value_smoke.lua now additionally pins exact wide multiplication.

tests/effective_address_smoke.lua covers:

- exact base + index*scale + displacement;
- exact wide unbounded arithmetic;
- explicit 64-bit wrapping;
- unresolved required register;
- unresolved symbol;
- unresolved relative numeric basis;
- ambiguous structure;
- scale-without-index rejection;
- displacement-only absolute evaluation.

tests/asm_effective_address_smoke.lua covers:

- active x86-64 architecture width forwarding;
- proven pre-instruction base/index/scale/displacement;
- Inspect reuse of known effective address;
- unresolved register fail-closed behavior;
- absolute numeric address;
- unresolved REL basis;
- Inspect reuse of unresolved REL reason;
- 64-bit wraparound;
- self-referential LEA using pre-instruction RAX;
- normal context preserving source-time address certainty.

### Deliberate boundaries

This tranche does NOT yet model:

~~~
32-bit address-size override semantics
RIP/next-instruction numeric source addresses
symbol/linker addresses
actual process memory
successful execution
memory contents
pointer validity
~~~

Those remain separate foundations.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -16 --oneline

nvim --headless -u NONE -c "luafile tests/integer_value_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_access_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/memory_adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
~~~

### Next foundational step after green

The strongest next step is explicit **address-size semantics**.

For x86-64, source forms using 64-bit and 32-bit address registers do not have
identical width behavior. The model should represent address-size separately
from operand size and architecture default width.

That layer should make forms such as EAX/ESP-based addressing precise before
expanding effective-address evaluation further.

After address-size semantics, a separate symbol/instruction-position model can
unlock RIP-relative and REL symbol evaluation without guessing.


## Accepted effective-address gate (2026-11-11)

The certainty-aware effective-address tranche is accepted green on ERIDU.

Confirmed:

~~~
PASS exact integer: canonical decimal signs and zeroes
PASS exact integer: 64-bit hexadecimal literals remain exact
PASS exact integer: 64-bit binary literals remain exact
PASS exact integer: signed addition does not use Lua float precision
PASS exact integer: exact negation
PASS exact integer: safe-number boundary is explicit
PASS exact integer: invalid and unsafe numeric inputs stay unresolved
PASS exact integer: stack depth keeps safe-number boundary
PASS integer value: exact wide multiplication
PASS Tracker_HUD exact integer value smoke
~~~

Pure effective-address evaluation passed:

~~~
PASS effective address: exact base/index/scale/displacement evaluation
PASS effective address: exact wide arithmetic remains lossless
PASS effective address: target-width wrapping is explicit
PASS effective address: unresolved register fails closed
PASS effective address: symbolic address remains unresolved
PASS effective address: relative numeric basis remains unresolved
PASS effective address: ambiguous structure fails closed
PASS effective address: scale without index is rejected
PASS effective address: displacement-only address evaluates
PASS Tracker_HUD effective-address smoke
~~~

Parser-backed x86 evaluation also passed:

~~~
PASS ASM effective address: active architecture width is available
PASS ASM effective address: proven pre-instruction state evaluates exactly
PASS ASM effective address: Inspect reuses evaluated address certainty
PASS ASM effective address: unknown register fails closed
PASS ASM effective address: absolute numeric address evaluates
PASS ASM effective address: symbolic REL address stays unresolved
PASS ASM effective address: Inspect preserves unresolved REL basis
PASS ASM effective address: 64-bit address wrap is explicit
PASS ASM effective address: self-referential LEA uses pre-instruction state
PASS ASM effective address: context preserves source-time address certainty
PASS Tracker_HUD ASM effective-address smoke
~~~

All memory-access, structural-memory, register-focus, alias-read, Adapter Contract,
and normalized-fact regressions remained green.

## Foundational memory tranche: explicit address-size semantics (2026-11-11)

**Status: pushed on main, pending ERIDU acceptance.**

The previous effective-address implementation correctly used architecture width
as an initial fallback, but x86-64 requires a more precise distinction:

~~~
architecture width
address size
operand size
memory data width
~~~

These are separate semantic axes.

In 64-bit mode, the default effective address size is 64 bits, while 32-bit
addressing is also valid via address-size override / 32-bit address-register
forms.

This tranche makes address size explicit in the normalized memory model.

### Architecture-neutral address-size resolver

Created:

~~~
lua/tracker_hud/low_level/address_size.lua
~~~

The resolver consumes:

~~~
adapter-owned address-size policy
parsed address components
register-width resolver
optional explicit source prefix
~~~

It knows no x86 register names.

Normalized result:

~~~
status
bits
source
reason
details
~~~

Known sources currently include:

~~~
default
register_width
explicit_prefix
~~~

### x86-64 address-size policy

The x86 memory declaration now owns:

~~~
address_size_policy = {
    default_bits = 64,
    allowed_bits = { 32, 64 },

    register_width_map = {
        [32] = 32,
        [64] = 64,
    },

    prefixes = {
        a32 = 32,
        a64 = 64,
    },
}
~~~

Therefore:

~~~
[rax + rcx*4]
-> address size 64

[eax + ecx*4]
-> address size 32

[abs 0x1234]
-> default address size 64
~~~

Mixed address-register widths fail closed:

~~~
[rax + ecx*4]
-> unknown
-> mixed address register widths
~~~

Unsupported address-register widths also fail closed:

~~~
[ax]
-> unknown
-> unsupported address register width
~~~

The long-mode policy deliberately allows only 32- and 64-bit address sizes.

### Data width remains independent

Memory data size is still represented by:

~~~
memory_size_bits
memory_size_prefix
memory_size_label
~~~

Address arithmetic size is now represented independently by:

~~~
address_size_bits
address_size_status
address_size_source
address_size_reason
address_size_details
~~~

Example:

~~~
qword [eax + ecx*8 + 0x20]

memory_size_bits  = 64
address_size_bits = 32
~~~

The instruction may access a 64-bit data value while computing the address in
32-bit address space.

### Parser integration

Updated:

~~~
lua/tracker_hud/adapters/asm/instruction_utils.lua
~~~

The parser resolves address size after structural memory components have been
identified.

Register widths are obtained from:

~~~
adapter.register_alias_index
~~~

with a static-register fallback when a register declares bits directly.

The resolved address-size object is attached before memory normalization.

### Explicit A32/A64 support

The generic address-size resolver supports explicit source prefixes.

The x86 policy declares:

~~~
A32 -> 32
A64 -> 64
~~~

The parser scans source context for adapter-declared address-size prefixes.

Consistent explicit prefix:

~~~
A32 + 32-bit address registers
-> known 32-bit address size
~~~

Conflicting explicit prefix/register width:

~~~
A32 + 64-bit address register
-> unknown
-> address-size prefix conflicts with registers
~~~

Conflicting explicit prefixes fail closed:

~~~
A32 + A64
-> unknown
-> conflicting explicit address-size prefixes
~~~

The pure resolver and Adapter Contract pin this behavior.

The first parser-backed ERIDU gate deliberately focuses on register-driven
32/64-bit addressing because the installed Tree-sitter grammar's exact prefix
node shape has not yet been independently probed. A dedicated grammar-probe
test can be added after this main tranche is accepted.

### Normalized memory model

Updated:

~~~
lua/tracker_hud/low_level/memory_address.lua
~~~

The normalized address now retains:

~~~
address_size_bits
address_size_status
address_size_source
address_size_reason
address_size_details
~~~

These fields are independent from memory data width.

### Effective-address width selection

Updated:

~~~
lua/tracker_hud/low_level/effective_address.lua
~~~

If normalized address-size certainty exists and is not known, effective-address
evaluation fails closed:

~~~
status = unknown
reason = address size unresolved
~~~

When address size is known, the evaluator uses:

~~~
address.address_size_bits
~~~

in preference to the architecture-width fallback.

Thus:

~~~
EAX address arithmetic
-> wraps at 2^32

RAX address arithmetic
-> wraps at 2^64
~~~

### Parser-backed exact 32-bit wrap case

The new x86 regression uses:

~~~
mov rax, 0x00000000FFFFFFF0
mov rcx, 2
mov rbx, qword [eax + ecx*8 + 0x20]
~~~

Source register projections:

~~~
eax = 4294967280
ecx = 2
~~~

Exact mathematical result:

~~~
4294967280 + 2*8 + 32
= 4294967328
~~~

32-bit address result:

~~~
32
~~~

while:

~~~
memory_size_bits = 64
address_size_bits = 32
~~~

The corresponding 64-bit register form:

~~~
qword [rax + rcx*8 + 0x20]
~~~

keeps:

~~~
effective_address = 4294967328
address_size_bits = 64
wrapped = false
~~~

### Inspect/source metadata

Inspect memory metadata now exposes:

~~~
memory_address_size_bits
memory_address_size_status
memory_address_size_source
memory_address_size_reason
~~~

First-class source memory facts expose:

~~~
metadata.address_size_bits
metadata.address_size_status
metadata.address_size_source
metadata.address_size_reason
~~~

The effective-address metadata continues to report its actual evaluation width:

~~~
memory_effective_address_bits
effective_address_bits
~~~

### Context lifecycle

The new x86 address-size regression pins that:

~~~
context.source_memory_operands
~~~

preserves each historical memory operand's own source-time address width.

A later 64-bit form must not retroactively change an earlier 32-bit form, and
vice versa.

### Adapter Contract protection

Memory declaration validation now protects:

~~~
address_size_policy.default_bits
address_size_policy.allowed_bits
address_size_policy.register_width_map
address_size_policy.prefixes
~~~

The contract rejects:

- non-positive or fractional widths;
- an empty allowed-width set;
- duplicate allowed widths;
- a default width outside allowed widths;
- register-width mappings to undeclared address widths;
- explicit prefixes mapped to undeclared address widths.

### New regressions

tests/address_size_smoke.lua pins:

- default address width;
- 64-bit register addressing;
- 32-bit register addressing;
- explicit address-size prefix;
- explicit prefix/register conflict;
- conflicting explicit prefixes;
- mixed 32/64-bit address registers;
- unsupported 16-bit address registers;
- unknown register width.

tests/x86_address_size_smoke.lua pins parser-backed x86 behavior:

- qword data width with 32-bit address width;
- exact EAX/ECX alias projection;
- 32-bit effective-address wrap;
- 64-bit register-address counterpart;
- mixed 32/64-bit fail-closed behavior;
- unsupported AX address form fail-closed behavior;
- register-free default 64-bit address size;
- Inspect reuse;
- context lifecycle.

tests/memory_address_smoke.lua now explicitly pins:

~~~
memory_size_bits = 64
address_size_bits = 32
~~~

as independent fields.

tests/effective_address_smoke.lua now pins:

- normalized address width overrides architecture fallback width;
- unresolved normalized address width fails closed.

tests/memory_adapter_contract_smoke.lua now pins malformed address-size policies
and prefixes.

### Deliberate boundaries

This tranche does NOT yet model:

~~~
numeric RIP / next-instruction position
linker or symbol addresses
EIP/RIP-relative target calculation
segment-base contribution
FS/GS base
actual instruction encoding bytes
runtime process memory
~~~

It also does not yet claim parser-backed A32/A64 prefix syntax until ERIDU's
installed Tree-sitter grammar shape has been probed separately.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -18 --oneline

nvim --headless -u NONE -c "luafile tests/address_size_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_address_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/effective_address_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_adapter_contract_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/x86_address_size_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_access_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
~~~

### Next foundational step after green

First, run a tiny parser-shape probe for explicit NASM A32/A64 instruction
prefixes and promote them into parser-backed regression coverage if the grammar
exposes the memory instruction cleanly.

After that, the next major memory foundation should be instruction-position and
symbol-address truth:

~~~
next RIP / instruction basis
RIP-relative addressing
REL symbols
known symbol/link addresses when available
~~~

That layer must remain separate from runtime memory contents and execution.


## Accepted address-size semantics gate (2026-11-12)

The explicit x86 address-size tranche is accepted green on ERIDU.

The first parser-backed run failed only because the user's local Neovim/plugin copy
had not yet been synchronized with the freshly pulled repository. After syncing,
the same test passed completely.

Confirmed pure address-size, normalized-memory, effective-address, and Adapter
Contract regressions:

~~~
PASS address size: register-free address uses default width
PASS address size: 64-bit register addressing
PASS address size: 32-bit register addressing
PASS address size: explicit prefix selects address width
PASS address size: explicit prefix/register conflict fails closed
PASS address size: conflicting explicit prefixes fail closed
PASS address size: mixed register widths fail closed
PASS address size: unsupported register width fails closed
PASS address size: unknown register width fails closed
PASS Tracker_HUD address-size smoke
~~~

Parser-backed x86 acceptance:

~~~
PASS x86 address size: qword data with 32-bit effective address
PASS x86 address size: 64-bit register addressing remains 64-bit
PASS x86 address size: mixed address register widths fail closed
PASS x86 address size: unsupported 16-bit address form fails closed
PASS x86 address size: register-free address uses 64-bit default
PASS x86 address size: Inspect reuses 32-bit address semantics
PASS x86 address size: context preserves source-time address widths
PASS Tracker_HUD x86 address-size smoke
~~~

All effective-address, memory-access, structural-memory, alias-read, Adapter
Contract, and normalized-fact regressions remained green.

## ASM parser probe: explicit A32/A64 source prefixes (2026-11-12)

**Status: pushed on main, pending ERIDU observation.**

Created:

~~~
tests/asm_address_prefix_probe.lua
~~~

This is intentionally a diagnostic parser-shape probe rather than a semantic
acceptance test.

Fixture:

~~~
bits 64
a32 mov rbx, [eax + 4]
a64 mov rbx, [rax + 4]
~~~

The probe prints:

- the complete Tree-sitter node tree with source ranges/text;
- every instruction node the installed grammar exposes;
- Tracker_HUD's parsed mnemonic/operand list;
- normalized memory address-size status/bits/source/reason;
- parsed base/displacement.

It deliberately does NOT assert a guessed Tree-sitter prefix node shape.

The only structural assertion is that at least one instruction node is present.

This output will determine whether the existing source-context prefix scanner is
already sufficient or whether the parser boundary needs adaptation for the
installed grammar.

## Foundational memory tranche: source-symbol identity (2026-11-12)

**Status: pushed on main, pending ERIDU acceptance.**

The previous memory model could parse:

~~~
[rel msg]
~~~

into:

~~~
address_mode = relative
symbol = msg
~~~

but it did not yet prove whether msg corresponded to a source declaration.

This tranche adds source declaration identity while keeping numeric machine
addresses unresolved.

### Architecture-neutral source-symbol resolver

Created:

~~~
lua/tracker_hud/low_level/source_symbol.lua
~~~

Inputs:

~~~
scope/source members
symbol name
resolution policy
reference source line
~~~

Outputs are either known source identity or unknown certainty.

Known identity includes:

~~~
status = known
name
kind
member_id
source_line
source_start_column
source_end_line
source_end_column
forward_reference
machine_address_status = unknown
machine_address = nil
machine_address_reason = machine address unavailable
~~~

The resolver does NOT assign:

- assembler offsets;
- linker addresses;
- load addresses;
- runtime addresses.

### Forward references are policy-controlled

Generic Tracker_HUD symbol resolution for many source languages prefers
definitions that appear before references.

That rule cannot be reused blindly for assembly because forward labels are legal.

The x86 ASM memory declaration therefore now owns:

~~~
symbol_resolution = {
    member_kinds = {
        "label",
    },
    allow_forward = true,
    case_sensitive = true,
}
~~~

Thus:

~~~
lea rsi, [rel msg]
...
msg:
~~~

can resolve msg to the later source label declaration without inventing a
machine address.

### Ambiguity remains fail-closed

If multiple allowed source declarations match the same symbol name, the resolver
returns:

~~~
status = unknown
reason = source symbol declaration ambiguous
candidates = ...
~~~

It never silently chooses one.

Missing source symbols remain:

~~~
status = unknown
reason = source symbol declaration not found
~~~

### Existing scope-member discovery is reused

The new layer reuses:

~~~
tracker_hud.scope_members
~~~

for label discovery.

It does NOT create a second Tree-sitter label walker.

The context engine collects the adapter's source members and passes them to the
generic source-symbol resolver.

### Memory source facts

First-class ASM source memory facts now expose:

~~~
symbol_identity
~~~

and metadata:

~~~
source_symbol_status
source_symbol_name
source_symbol_kind
source_symbol_member_id
source_symbol_line
source_symbol_start_column
source_symbol_end_line
source_symbol_end_column
source_symbol_forward_reference
source_symbol_reason

symbol_machine_address_status
symbol_machine_address
symbol_machine_address_reason
~~~

For a known source label, machine-address fields still remain unknown.

### Inspect/source occurrence reuse

Register/source occurrence discovery now resolves the same source-symbol identity
once per memory operand and attaches it to operand/component metadata.

Thus selecting:

~~~
msg
~~~

inside:

~~~
[rel msg]
~~~

can show the source declaration identity from the same model as the memory fact.

### Adapter Contract protection

Memory declaration validation now protects optional:

~~~
symbol_resolution
~~~

Required:

~~~
member_kinds = non-empty array
~~~

Optional booleans:

~~~
allow_forward
case_sensitive
~~~

The contract rejects:

- empty member-kind lists;
- empty kind names;
- duplicate member kinds;
- non-boolean forward-reference policy;
- non-boolean case-sensitivity policy.

### Pure regression

Created:

~~~
tests/source_symbol_smoke.lua
~~~

Pins:

- forward label identity;
- explicit forward-reference policy;
- duplicate declaration ambiguity;
- case-sensitive matching;
- opt-in case-insensitive matching;
- missing declaration behavior;
- machine address remaining unknown.

### Parser-backed regression

Created:

~~~
tests/asm_source_symbol_smoke.lua
~~~

Fixture:

~~~
bits 64
lea rsi, [rel msg]
lea rdi, [rel missing]
msg:
mov rax, rax
~~~

Pins:

- existing scope-member discovery exposes label msg;
- line 2 resolves msg as a known forward label;
- source declaration line is 4;
- machine address remains unknown;
- effective address remains unknown because the REL basis is unavailable;
- missing remains unresolved;
- Inspect reuses source-label identity;
- normal context preserves source-symbol certainty.

### Deliberate boundary

Source declaration identity is NOT machine-address truth.

Even after:

~~~
symbol_identity.status = known
symbol_identity.source_line = 4
~~~

Tracker_HUD must still report:

~~~
machine_address_status = unknown
effective_address = unknown
~~~

until a separate machine-address/instruction-position provider can prove the
numeric target.

### ERIDU gate

Pull first, then run:

~~~
git status --short
git pull --ff-only
git log -14 --oneline

nvim --headless -u NONE -c "luafile tests/source_symbol_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_adapter_contract_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_address_prefix_probe.lua" -c "qa!"

nvim --headless -c "luafile tests/x86_address_size_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
~~~

### Next foundational step after this gate

Use the A32/A64 probe output to adapt only the parser boundary if needed, then
promote explicit prefixes into parser-backed semantic regression coverage.

The next major foundation is a machine-address provider contract:

~~~
instruction machine address / next-IP basis
symbol machine address
provenance of those addresses
certainty / unknown reasons
~~~

That provider must be separate from source line numbers.

A source line number must never be treated as a machine code address.

Once known machine addresses exist, RIP-relative / REL effective-address
evaluation can consume them without guessing.

## Accepted source-symbol identity gate (2026-11-12)

The source-symbol identity tranche is accepted green on ERIDU after the local Neovim/plugin copy was synchronized with the freshly pulled repository.

Confirmed parser-backed results:

~~~
PASS ASM source symbol: label declaration discovered
PASS ASM source symbol: forward REL label identity resolves
PASS ASM source symbol: missing label fails closed
PASS ASM source symbol: Inspect reuses source-label identity
PASS ASM source symbol: context preserves source identity certainty
PASS Tracker_HUD ASM source-symbol identity smoke
~~~

The generic source-symbol and memory Adapter Contract tests also passed. Effective-address, address-size, and structural-memory regressions remained green.

## Observed ERIDU Tree-sitter shape for NASM A32/A64 (2026-11-12)

The diagnostic probe established the installed grammar's exact behavior.

For `a32 mov rbx, [eax + 4]`, Tree-sitter produces:

~~~
instruction
  word  a32
  ERROR
    ident mov
    ident rbx
    ,
  ptr [eax + 4]
~~~

A64 has the same shape. Before repair, Tracker_HUD therefore parsed the prefix as the mnemonic and lost the register operand trapped in ERROR, while address-size normalization itself was already correct (`32`/`64`, source `explicit_prefix`).

## ASM parser repair: recover semantic instruction after address-size prefix (2026-11-12)

**Status: pushed on main, pending ERIDU acceptance.**

Updated `lua/tracker_hud/adapters/asm/instruction_utils.lua`.

When the grammar-selected mnemonic is an adapter-declared address-size prefix, the parser now:

1. preserves the prefix as explicit instruction metadata;
2. inspects direct ERROR-node children;
3. uses the first adapter-recognized construct child as the semantic mnemonic;
4. recovers later adapter-recognized ERROR children as operands;
5. merges them with normally parsed operands;
6. sorts operands by source position.

For the observed ERIDU tree, this becomes semantic mnemonic `mov`, prefix metadata `a32`, and operands `rbx`, `[eax + 4]` in correct source order.

This matters because merely renaming A32 to MOV would leave memory as operand 1 and could invert MOV access intent.

Created `tests/asm_address_prefix_semantics_smoke.lua` covering:

~~~
a32 mov rbx, [eax + 4]
a64 mov [rax + 8], rbx
a32 lea rsi, [eax + 12]
~~~

It pins mnemonic recovery, prefix metadata, lost-register recovery, operand ordering, explicit address size, MOV read/write intent, and LEA address-only intent.

## Foundational machine-address provider contract (2026-11-12)

**Status: pushed on main, pending ERIDU acceptance.**

Created `lua/tracker_hud/low_level/machine_address.lua`.

This layer defines how future machine-address evidence is supplied and combined. Source locations, labels, and syntax may be provider query keys only; they never become addresses by themselves.

Supported query kinds:

~~~
instruction
next_instruction
symbol
~~~

A symbol query requires a name. There is intentionally no `source_line` machine-address query kind.

A provider is a runtime object with `id`, `kind`, and `resolve(query)`. A known result supplies an explicit exact address value plus optional width/provenance.

Machine addresses use the exact integer foundation. Unsafe Lua numeric values are rejected. Out-of-width provider values are rejected rather than wrapped.

Provider aggregation semantics:

~~~
no known provider -> unknown / machine address unavailable
agreeing known providers -> known with combined provenance
conflicting known providers -> unknown / machine address conflict
provider failure -> retained as evidence, does not erase independent known evidence
duplicate provider IDs -> fail closed
~~~

Critical invariant: a query containing `source_line = 4096` with no provider evidence remains unknown; source line 4096 never becomes machine address 4096.

Created `tests/machine_address_smoke.lua` pinning source-position safety, exact 64-bit values, provenance, corroboration, conflicts, provider failures, width rejection, unsafe-number rejection, duplicate IDs, invalid symbol queries, and rejection of a source-line pseudo-address query kind.

This provider layer is not yet wired into context, REL, or RIP-relative effective-address evaluation.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/machine_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_address_prefix_semantics_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_address_prefix_probe.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_address_size_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_access_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
~~~

### Next foundational step after green

Wire machine-address providers into memory-source evaluation as explicit optional evidence. REL/RIP-relative source facts should be able to query symbol and next-instruction addresses through the provider contract. Only proven provider results may enter relative-address arithmetic.

Preserve distinct states: source symbol identity known while machine address unknown; symbol machine address known while next-IP unknown; and both known. No source line or syntax position may fill a missing machine address.

## Accepted prefix-recovery + machine-address provider gate (2026-11-12)

The A32/A64 semantic recovery and pure machine-address provider contract are accepted green on ERIDU.

Confirmed:

~~~
PASS machine address: source location is not an address
PASS machine address: exact 64-bit provider value + provenance
PASS machine address: agreeing providers corroborate
PASS machine address: conflicting providers fail closed
PASS machine address: provider failure stays separate from known evidence
PASS machine address: out-of-width provider value is rejected
PASS machine address: unsafe numeric provider value is rejected
PASS machine address: duplicate provider IDs are rejected
PASS machine address: invalid symbol query fails closed
PASS machine address: source-line pseudo-address kind is rejected
PASS Tracker_HUD machine-address provider smoke
~~~

Parser-backed A32/A64 semantic recovery also passed:

~~~
PASS ASM address prefix: A32 recovers MOV + destination operand
PASS ASM address prefix: A64 preserves MOV operand order
PASS ASM address prefix: A32 recovers LEA semantics
PASS ASM address prefix: recovered MOV source is read
PASS ASM address prefix: recovered MOV destination is write
PASS ASM address prefix: recovered LEA is address_only
PASS Tracker_HUD ASM address-prefix semantics smoke
~~~

The diagnostic probe now reports semantic `mov` with both operands while retaining explicit 32/64-bit address-size metadata.

All source-symbol, address-size, memory-access, and effective-address regressions remained green.

## Foundational memory tranche: machine-address evidence plumbing (2026-11-12)

**Status: pushed on main, pending ERIDU acceptance.**

The provider contract is now threaded into ASM source-memory discovery as optional evidence.

Existing behavior is preserved when no providers are configured.

### Runtime provider entry point

`context.get_cursor_context(bufnr, config)` now accepts optional:

~~~
config.machine_address_providers
~~~

The ASM adapter ignores this unrelated config field during target configuration. Provider closures remain runtime evidence objects and are not copied into adapter architecture state.

Direct context-engine entry points also accept optional provider options:

~~~
discover_memory_source_operands(..., opts)
collect_memory_source_operands(..., opts)
discover_register_source_occurrences(..., opts)
~~~

where:

~~~
opts.machine_address_providers
~~~

is forwarded to the generic machine-address provider aggregator.

### Evidence queried per memory operand

When providers exist, source-memory discovery may query:

~~~
instruction
next_instruction
symbol
~~~

`next_instruction` is queried only for relative/RIP/EIP-based memory forms.

`symbol` is queried only when the normalized memory address contains a symbol.

### Machine-address width remains separate from memory address size

An audit caught an important distinction before acceptance:

~~~
A32 memory address size = 32 bits
x86-64 instruction/symbol machine-address domain = 64 bits
~~~

Provider evidence therefore uses the active architecture machine-address width (`adapter.metadata.bits`) in preference to the operand's `address_size_bits`.

This means an A32 operand may carry a provider-known 64-bit instruction or symbol address above `0xFFFFFFFF` without truncation or rejection.

The later relative-address arithmetic layer will decide how machine-address evidence combines with 32-bit effective-address semantics.

### First-class source-memory facts

When provider evidence exists, source-memory facts now carry:

~~~
machine_addresses = {
    instruction = <provider aggregate>,
    next_instruction = <provider aggregate when relevant>,
    symbol = <provider aggregate when relevant>,
}
~~~

Flattened metadata exposes status/value/reason/bits for:

~~~
instruction_machine_address
next_instruction_machine_address
symbol_machine_address
~~~

The nested evidence retains full provider provenance and conflict evidence.

### Source identity and machine address remain independent

A source label may be known while its machine address is unknown.

A machine-address provider may also know an external/linker symbol even when no source declaration exists in the current buffer.

Both cases are valid and pinned separately.

### Inspect reuse

Register/source occurrence metadata receives the same machine-address evidence as first-class memory facts.

Inspect does not perform a separate provider lookup model.

### Effective-address behavior deliberately unchanged

Even when provider evidence proves:

~~~
symbol machine address = known
next-instruction address = known
~~~

REL/RIP effective address still remains:

~~~
status = unknown
reason = relative address basis unresolved
~~~

in this tranche.

This is deliberate. Provider evidence plumbing is accepted independently before introducing relative-address arithmetic.

### New parser-backed regression

Created:

~~~
tests/asm_machine_address_evidence_smoke.lua
~~~

Fixture includes:

~~~
a32 lea rsi, [rel msg]
lea rdi, [rel external]
msg:
~~~

It pins:

- no-provider behavior remains unchanged;
- source label identity and provider machine addresses remain separate;
- A32 address size remains 32 while machine-address evidence remains 64-bit;
- provider addresses above 2^32 survive exactly;
- external symbols may be provider-known without a source declaration;
- Inspect reuses provider evidence;
- normal context forwards provider evidence;
- execution status remains `not_observed`;
- REL effective address is not resolved prematurely.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -10 --oneline

nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/machine_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_address_prefix_semantics_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_address_size_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
~~~

### Next foundational step after green

Add a separate relative-address evaluator that consumes machine-address evidence.

For a symbolic REL/RIP form, it should preserve at least:

~~~
symbol target address
next-instruction basis
exact relative displacement
final effective target
provider provenance
address-size / machine-width distinction
~~~

Missing or conflicting evidence must remain unknown.

No source line, source column, or syntax order may substitute for machine-address evidence.

## A32 + REL cross-feature repair (2026-11-12)

ERIDU exposed one failure in the new machine-address evidence smoke while all previously accepted regressions remained green.

Failure:

~~~
FAIL ASM machine-address evidence smoke:
no-provider path must preserve pre-provider REL behavior
~~~

The failing fixture combined:

~~~
a32 lea rsi, [rel msg]
~~~

This exercises two independent parser-recovery layers at once:

- address-size prefix recovery from Tree-sitter ERROR structure;
- relative-memory syntax normalization.

To make the memory parser robust at this boundary, `instruction_utils.lua` now recovers the bracketed source slice directly from the source buffer using the adapter-declared bracket syntax before normalizing address mode/components.

This remains parser/source work. Presentation code still does not reparse memory syntax.

The Tree-sitter node text remains the fallback if source recovery is unavailable.

New regression:

~~~
tests/asm_address_prefix_relative_smoke.lua
~~~

It pins:

- semantic A32 LEA recovery;
- REL mode/token preservation;
- symbol `msg` preservation;
- explicit 32-bit address size;
- forward source-symbol identity;
- no machine-address evidence without providers;
- effective address staying `relative address basis unresolved`.

The machine-address evidence smoke now reports each no-provider invariant separately instead of one compound assertion, so any remaining mismatch identifies the exact field.

Repair commits:

~~~
59e5663 fix(asm): recover bracketed memory syntax from source
7f712f2 test(asm): pin A32 REL source recovery
1662026 test(memory): isolate no-provider REL diagnostics
~~~

Targeted ERIDU rerun:

~~~
nvim --headless -c "luafile tests/asm_address_prefix_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_address_prefix_semantics_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
~~~

### Second-stage A32 + REL repair: missing memory operand

The first repair recovered bracket syntax only after a memory operand already existed.

ERIDU proved the malformed A32+REL Tree-sitter shape can omit the memory operand from `parsed.operands` entirely:

~~~
A32 REL semantic test failed before memory normalization
machine-address evidence fact count = 0
~~~

The instruction parser now has an adapter-driven fallback for prefixed instructions:

1. merge normal Tree-sitter operands and ERROR-recovered operands;
2. if no memory operand exists, locate the adapter-declared memory construct;
3. recover the physical bracketed source expression from the instruction line;
4. synthesize a memory operand with the declared memory node type/spec;
5. run it through the existing `analyze_memory_operand()` normalizer;
6. merge/sort it by source position.

No hard-coded x86 `ptr` node name is used.

The fallback runs only for address-prefixed instruction recovery and only when no memory operand is already present.

Additional commits:

~~~
873286a fix(asm): synthesize missing prefixed memory operand
a9f7c1b fix(asm): avoid duplicate recovered memory operands
bcdfa7d test(asm): isolate A32 REL parser diagnostics
~~~

### Definitive prefixed-instruction recovery strategy

ERIDU exposed a second Tree-sitter shape for `a32 lea rsi, [rel msg]`:

~~~
mnemonic = a32
prefixes = 0
operands = lea, rsi, msg
~~~

This shape contains no usable ERROR subtree and no usable memory operand, so ERROR-node recovery cannot be the primary strategy.

The parser now uses source reconstruction whenever the grammar-selected mnemonic itself is an adapter-declared address-size prefix.

Source reconstruction:

1. confirms the prefix through the adapter's `address_size_policy.prefixes`;
2. reads the physical instruction source span;
3. extracts the semantic mnemonic immediately after the prefix;
4. splits operand source text on top-level commas while respecting brackets, parentheses, braces, and quoted strings;
5. classifies register/integer/symbol operands through the adapter register index and normal token classifier;
6. classifies bracketed operands through the adapter-declared memory construct;
7. sends memory operands through the existing `analyze_memory_operand()` normalizer;
8. returns the reconstructed semantic instruction directly.

ERROR-node recovery remains only as a fallback if source reconstruction cannot be performed.

This makes A32/A64 recovery independent of whether Tree-sitter chooses:

~~~
word + ERROR + ptr
or
word + flattened reg/ident-like children
~~~

while keeping the prefix and memory grammar adapter-owned.

New commits:

~~~
396cf55 fix(asm): reconstruct prefixed instructions from source
a26ee48 fix(asm): keep source recovery helpers in local scope
~~~


## Accepted REL / RIP / Inspect machine-target campaign (2026-11-13)

ERIDU has accepted the complete source-memory machine-target campaign through
HUD Inspect presentation.

Confirmed green parser-backed behavior includes:

- explicit NASM `REL symbol` target resolution from provider evidence;
- A32 source address size remaining distinct from the 64-bit machine-address
  evidence domain;
- adapter-owned RIP-relative basis policy using the next instruction address;
- A32 RIP-relative final-address truncation after exact arithmetic;
- RIP-relative symbol + numeric addend composition;
- source-label identity remaining independent from linker/provider address
  evidence;
- external provider-known symbols remaining valid without a source declaration;
- Inspect reusing the same effective-target and provider evidence as source
  memory facts;
- provider-aware Inspect source-index invalidation, so an unchanged source line
  is recompiled when the configured provider set changes;
- visible Registers Inspect details separating effective-target certainty,
  symbol identity certainty, symbol machine-address certainty, address width /
  wrapping, and runtime observation;
- `execution_status = not_observed` remaining unchanged when a target becomes
  numerically known.

The acceptance gates remained green for address-size semantics, alias
read/write state, source-symbol resolution, effective-address evaluation,
machine-address provider validation, register source focus, and architecture
register roles.

No source line or source column is treated as a machine address.

## Context-engine split tranche 1 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

The validation coverage is now sufficient to begin the roadmap's refactor-only
split of `context_engine.lua`.

New module:

~~~
lua/tracker_hud/low_level/memory_source_evidence.lua
~~~

This module now owns the previously local evidence helpers for:

- adapter memory symbol-resolution policy;
- adapter instruction-relative memory policy;
- source-symbol identity resolution;
- optional instruction / next-instruction / symbol machine-address provider
  aggregation;
- flattened effective-address metadata;
- flattened source-symbol metadata;
- flattened machine-address metadata.

`context_engine.lua` still owns orchestration, Tree-sitter instruction
collection, register-state replay, effective-address register lookup, operand
role matching, and its existing public API.

This is intentionally a mechanical ownership extraction. There is no intended
semantic or HUD behavior change.

New pure regression:

~~~
tests/memory_source_evidence_smoke.lua
~~~

It pins source-symbol policy, instruction-relative policy, exact 64-bit provider
evidence, no-provider behavior, source identity keys carried into symbol
provider queries, and the flattened metadata contract.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -8 --oneline

nvim --headless -u NONE -c "luafile tests/memory_source_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
~~~

If this tranche is green, continue splitting `context_engine.lua` only in
small refactor-only slices with public APIs and semantic tests unchanged.


## Accepted context-engine split tranche 1 (2026-11-13)

ERIDU accepted the first refactor-only split green.

Confirmed:

- `tests/memory_source_evidence_smoke.lua` passes independently;
- Inspect provider-cache refresh remains green;
- RIP / A32 RIP / REL evaluation remains green;
- source-symbol identity remains green;
- machine-address evidence remains green;
- effective-address evaluation remains green;
- register source-occurrence focus remains green.

The extraction therefore changed ownership without changing the accepted
source-memory semantics.

## Context-engine split tranche 2 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/memory_source_fact.lua
~~~

This module owns normalized source-memory fact construction after the context
engine has already decided:

- which instruction/operand is visible;
- the semantic operand role;
- memory access intent;
- effective-address evaluation;
- source-symbol identity;
- machine-address evidence.

The stable fact shape is preserved, including:

- `kind = memory_operand`;
- source range and operand identity;
- normalized address structure;
- nested effective-address / symbol / machine evidence;
- access-intent metadata;
- address-size metadata;
- `runtime_address = unknown`;
- `execution_status = not_observed`;
- flattened certainty metadata supplied by
  `memory_source_evidence.lua`.

`context_engine.lua` still owns effect matching, memory-access rule
resolution, register-state replay and the public collection APIs.

The call site intentionally preserves the original evaluation order:
non-memory or unnormalized operands are rejected before memory-role/access
lookups are performed.

New pure regression:

~~~
tests/memory_source_fact_smoke.lua
~~~

It pins fact identity, role/access metadata, source range, nested evidence,
flattened certainty metadata, and exclusion of non-memory / unnormalized
operands.

### ERIDU gate

~~~
nvim --headless -u NONE -c "luafile tests/memory_source_fact_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
~~~

Do not take the next ownership slice until this one is accepted green.


## Accepted context-engine split tranche 2 (2026-11-13)

ERIDU accepted the second refactor-only split green.

Confirmed:

- `tests/memory_source_fact_smoke.lua` passes independently;
- `tests/memory_source_evidence_smoke.lua` remains green;
- Inspect target certainty/cache behavior remains green;
- RIP / A32 RIP / REL evaluation remains green;
- machine-address evidence and source-symbol identity remain green;
- effective-address evaluation remains green;
- register source-occurrence focus remains green.

The extracted source-memory fact constructor therefore preserves the accepted
fact shape and certainty semantics.

## Context-engine split tranche 3 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/memory_source_collection.lua
~~~

This module now owns source-memory collection mechanics:

- source-line filtering;
- duplicate Tree-sitter node-range suppression;
- per-operand evidence assembly through the already-extracted evidence module;
- normalized fact construction through `memory_source_fact.lua`;
- stable result ordering by source line, source column and operand index.

It deliberately does **not** own language/parser or instruction semantics.

`context_engine.lua` still injects callbacks for:

- instruction parsing;
- register-effect rule matching;
- pre-instruction effective-address evaluation / register replay;
- memory operand semantic role;
- memory access intent.

The public APIs remain unchanged:

~~~
discover_memory_source_operands(...)
collect_memory_source_operands(...)
~~~

The extraction preserves the original work ordering: a source line is filtered
and a duplicate node range is suppressed before parsing; only normalized memory
operands reach address evaluation, role lookup and access resolution.

New pure regression:

~~~
tests/memory_source_collection_smoke.lua
~~~

It pins:

- line filtering before parsing;
- duplicate node suppression before parsing;
- memory-only semantic callbacks;
- stable source ordering;
- preservation of injected semantic results;
- fail-closed behavior when required collector dependencies are absent.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -8 --oneline

nvim --headless -u NONE -c "luafile tests/memory_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_fact_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_machine_address_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_source_symbol_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
~~~

Do not take the fourth ownership slice until this gate is accepted green.


## Accepted context-engine split tranche 3 (2026-11-13)

ERIDU accepted the third refactor-only split green.

Confirmed:

- `tests/memory_source_collection_smoke.lua` passes independently;
- source-memory fact and evidence module regressions remain green;
- Inspect target certainty/cache behavior remains green;
- RIP / A32 RIP / REL evaluation remains green;
- machine-address evidence and source-symbol identity remain green;
- effective-address evaluation remains green;
- register source-occurrence focus remains green.

The extracted collection orchestration therefore preserves line filtering,
node-range deduplication, memory-only callback behavior, source ordering and
the injected semantic decisions supplied by `context_engine.lua`.

## Context-engine split tranche 4 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/operand_metadata.lua
~~~

This module owns descriptive source-operand metadata formatting that was
previously local to `context_engine.lua`:

- operand role labels;
- operand kind labels, including `integer -> immediate`;
- value-source labels;
- memory-size labels;
- normalized memory operand metadata;
- focused memory-component metadata.

This is descriptive metadata only. It does not parse source, evaluate an
address, match instruction semantics, infer a register value, or claim runtime
execution.

All previous context-engine call sites now use the shared module. No local
compatibility wrappers remain.

The stable memory metadata contract remains unchanged, including:

- containing operand text/kind;
- memory address text/kind;
- memory size prefix and bit width;
- normalized address mode and address-size certainty;
- base/index/scale/displacement/symbol fields;
- ordered component summaries;
- focused token kind;
- structural/display address roles;
- source-value labels.

New pure regression:

~~~
tests/operand_metadata_smoke.lua
~~~

It pins exact role/kind wording, memory-size formatting, normalized address
metadata, component-summary ordering, focused component metadata and
fail-closed behavior for invalid inputs.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -8 --oneline

nvim --headless -u NONE -c "luafile tests/operand_metadata_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_fact_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_evidence_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
~~~

Do not take the fifth ownership slice until this gate is accepted green.


## Accepted context-engine split tranche 4 (2026-11-13)

ERIDU accepted the fourth refactor-only split green.

Confirmed:

- `tests/operand_metadata_smoke.lua` passes every exact formatting/structure
  assertion;
- source-memory collection/fact/evidence regressions remain green;
- normalized ASM memory structure remains green;
- Inspect target certainty/cache behavior remains green;
- RIP / A32 RIP / REL evaluation remains green;
- effective-address evaluation remains green;
- register source-occurrence focus remains green.

The shared operand-metadata module therefore preserves the descriptive contract
used by register facts and Inspect without changing source/runtime semantics.

## Context-engine split tranche 5 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_source_occurrence.lua
~~~

This module now owns construction of the live Registers Inspect source
occurrences after `context_engine.lua` has already parsed an instruction and
matched its semantic effect specs:

- register-name canonicalization for occurrence target IDs;
- occurrence-role normalization;
- mnemonic occurrence construction;
- register/memory operand occurrence construction;
- memory-component occurrence construction;
- target-state IDs and per-target source/destination/address roles;
- source-memory access-intent metadata reuse.

It does **not** parse Tree-sitter nodes, match instruction effect rules, replay
register state, evaluate addresses, or render HUD rows.

`context_engine.lua` still owns:

- instruction parsing;
- semantic effect matching and conditions;
- source-line/node selection;
- pre-instruction register-state replay;
- effective-address evaluation;
- provider/source-symbol evidence attachment;
- public occurrence discovery API.

The existing live call path now delegates:

~~~
build mnemonic occurrence
build operand occurrence
build memory component occurrences
~~~

to the extracted module.

Two pre-existing local helpers in the old occurrence area are currently unused:
`get_register_operand_occurrence_role` and `build_source_written_role`.
They were deliberately **not** removed in this tranche so dead-code cleanup is
not mixed with behavior-preserving ownership extraction.

New pure regression:

~~~
tests/register_source_occurrence_smoke.lua
~~~

It pins:

- alias canonicalization, including `eax -> register:rax`;
- semantic role normalization;
- mnemonic operation targets;
- destination operand focus;
- source memory operand -> affected state targets;
- memory component own address-register target plus affected state targets;
- memory access intent remaining source-only / `not_observed`;
- syntax-only register focus surviving even when no semantic effect rule
  matches;
- invalid input fail-closed behavior.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -8 --oneline

nvim --headless -u NONE -c "luafile tests/register_source_occurrence_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/operand_metadata_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_fact_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
~~~

Do not take the sixth ownership slice until this gate is accepted green.


## Accepted context-engine split tranche 5 (2026-11-13)

ERIDU accepted the fifth refactor-only split green.

Confirmed:

- `tests/register_source_occurrence_smoke.lua` passes independently;
- shared operand metadata remains green;
- source-memory collection/fact regressions remain green;
- real parser-backed register source focus remains green;
- normalized memory structure remains green;
- Inspect target certainty/cache behavior remains green;
- RIP / A32 RIP / REL evaluation remains green;
- effective-address evaluation remains green.

The extracted occurrence builders therefore preserve canonical register target
IDs, semantic/source roles, syntax-only focus, memory-component address roles
and source-only memory execution semantics.

## Context-engine split tranche 6 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_source_collection.lua
~~~

This module now owns Registers Inspect source-occurrence collection mechanics:

- iterating adapter-declared instruction node types;
- source-line filtering before parsing;
- duplicate Tree-sitter node-range suppression before parsing;
- invoking the already-extracted occurrence builders;
- resolving source-symbol and optional machine-address evidence for normalized
  memory operands;
- attaching effective-address/source-symbol/machine-address certainty metadata
  to both whole memory operands and individual memory components;
- preserving syntax-only occurrences when semantic effect matching returns an
  empty set.

It deliberately does **not** own:

- Tree-sitter instruction parsing;
- semantic effect-rule matching;
- effect conditions;
- register-state replay;
- effective-address evaluation;
- public context-engine APIs.

Those remain injected by `context_engine.lua`.

The public API remains unchanged:

~~~
discover_register_source_occurrences(...)
~~~

New pure regression:

~~~
tests/register_source_collection_smoke.lua
~~~

It pins:

- line filtering before parsing;
- duplicate node-range suppression before parsing;
- normalized-memory-only address evaluation;
- occurrence ordering within parsed instructions;
- effective-address evidence attachment to memory operands and components;
- syntax-only register focus with no matching semantic effect rule;
- fail-closed behavior when collector dependencies are incomplete.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -8 --oneline

nvim --headless -u NONE -c "luafile tests/register_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_source_occurrence_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/operand_metadata_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/memory_source_collection_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
~~~

Do not take the seventh ownership slice until this gate is accepted green.


## Accepted context-engine split tranche 6 (2026-11-13)

ERIDU accepted the sixth refactor-only split green.

Confirmed:

- `tests/register_source_collection_smoke.lua` passes independently;
- register source-occurrence construction remains green;
- shared operand metadata remains green;
- source-memory collection remains green;
- real parser-backed register focus remains green;
- normalized memory structure remains green;
- Inspect target certainty/cache behavior remains green;
- RIP / A32 RIP / REL evaluation remains green;
- effective-address evaluation remains green.

The extracted register source collector therefore preserves line filtering,
node-range deduplication, normalized-memory evaluation boundaries, occurrence
ordering, memory certainty attachment and syntax-only focus.

## Context-engine split tranche 7 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_index.lua
~~~

This module owns register-effect rule indexing and candidate selection:

- weak-key caching keyed by the adapter's `register_effects` table;
- node-type indexing;
- normalized mnemonic buckets;
- support for both the current/legacy flat rule array and the newer
  mnemonic-indexed adapter format;
- preservation of the first representative rule used to guide instruction
  parsing;
- candidate selection after an instruction has been parsed;
- delegation to the existing operand matcher and condition matcher.

It deliberately does **not** own:

- adapter syntax interpretation;
- Tree-sitter instruction parsing;
- operand-match semantics;
- effect-condition semantics;
- register-state replay;
- register-effect application.

`context_engine.lua` still supplies those semantics through wiring callbacks.

The old context-local weak-key register-effect cache and index builder have
been removed. The context engine keeps only small wiring functions that provide
its existing syntax accessors/parser/match predicates to the extracted module.

New pure regression:

~~~
tests/register_effect_index_smoke.lua
~~~

It pins:

- legacy flat rule indexing;
- mnemonic-indexed rule indexing;
- mnemonic normalization;
- invalid-rule filtering;
- representative-rule preservation;
- adapter index cache identity;
- parse-once candidate matching;
- continued delegation of operand and condition predicates;
- fail-closed behavior for unknown node types, parse failures and incomplete
  dependencies.

### ERIDU gate

~~~
git status --short
git pull --ff-only
git log -8 --oneline

nvim --headless -u NONE -c "luafile tests/register_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_source_occurrence_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/operand_metadata_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
~~~

Do not take the eighth ownership slice until this gate is accepted green.


## Accepted context-engine split tranche 7 (2026-11-13)

ERIDU accepted the seventh refactor-only split green.

Confirmed:

- `tests/register_effect_index_smoke.lua` passes independently;
- register source collection and occurrence construction remain green;
- shared operand metadata remains green;
- real parser-backed register focus remains green;
- effective-address evaluation remains green;
- RIP / A32 RIP / REL evaluation remains green;
- Inspect target certainty/cache behavior remains green.

The extracted register-effect index therefore preserves both adapter rule
formats, cache identity, representative parser rules and delegated
operand/condition matching.

## Context-engine split tranche 8 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_source_metadata.lua
~~~

This module now owns descriptive source metadata attached to register-effect
facts:

- locating an operand spec by index;
- selecting the effect's source operand index;
- describing explicit source operands;
- describing stack-top sources;
- describing implicit register sources;
- reusing normalized memory operand metadata;
- merging non-nil source metadata into a target metadata table.

It deliberately does **not** own:

- instruction parsing;
- register value resolution;
- stack-state inference;
- effect application;
- canonical register-state reduction.

The context engine now delegates the live register-fact source metadata path to
this module. The previous local helper implementations have been removed.

New pure regression:

~~~
tests/register_source_metadata_smoke.lua
~~~

It pins source-index precedence, operand/stack/register source fields,
normalized memory metadata reuse, merge semantics and invalid-input
fail-closed behavior.


## Context-engine split tranche 9 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/line_summary.lua
~~~

This module owns the pure line-summary/cursor-position policy that was
previously implemented inside `context_engine.lua`:

- resolving line-summary visibility options;
- classifying a source column as before/inside/after an instruction;
- deciding whether a position is visible under the configured policy;
- deriving an instruction span from compiled source occurrences;
- classifying and filtering compiled-line positions.

The public `context_engine` API is unchanged. These existing functions remain
available and now delegate to the extracted module:

~~~
resolve_line_summary_options(...)
classify_instruction_cursor_position(...)
line_summary_allows_position(...)
get_compiled_line_instruction_range(...)
classify_compiled_line_cursor_position(...)
line_summary_allows_compiled_line_position(...)
~~~

The extraction is intentionally pure: it owns no Tree-sitter traversal,
instruction parsing, register-state inference or HUD rendering.

New pure regression:

~~~
tests/line_summary_smoke.lua
~~~

It pins:

- default visibility options;
- disabled and explicit visibility options;
- exact before/inside/after instruction boundaries;
- the rule that inside-instruction focus remains visible;
- compiled-line range aggregation;
- metadata instruction-range precedence over occurrence fallback ranges;
- compiled-line visibility policy;
- invalid-input fail-closed behavior.

## Ten-commit relay boundary (2026-11-13)

This relay intentionally stops after ten atomic commits on top of accepted
`e64347a`. The commits cover two refactor-only ownership slices:

1. tranche 8: register source-metadata construction;
2. tranche 9: line-summary/cursor-position policy.

No central register reducer or instruction semantic rule was moved in this
relay.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/register_source_metadata_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/line_summary_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_source_occurrence_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/operand_metadata_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 8 and 9 (2026-11-13)

ERIDU accepted both ownership slices green.

Confirmed:

- `tests/register_source_metadata_smoke.lua` passes independently;
- `tests/line_summary_smoke.lua` passes independently;
- register effect indexing/source collection/source occurrences remain green;
- normalized memory structure remains green;
- real parser-backed register focus remains green;
- effective-address evaluation remains green;
- RIP / A32 RIP / REL evaluation remains green;
- Inspect target certainty/cache behavior remains green.

## Context-engine split tranche 10 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_collection.lua
~~~

This module owns only register-effect instruction-node selection:

- iterating indexed instruction node types;
- source visibility filtering against cursor position;
- explicit `limit_position`, `stop_before`, and `before_position`
  precedence;
- one-based cursor column to zero-based Tree-sitter column conversion;
- line-summary before/inside/after policy reuse;
- duplicate node-range suppression;
- stable source-line/source-column ordering.

It deliberately does **not** parse instructions, select effect specs, prepare
instruction inference state, apply register effects, reduce alias families, or
emit register facts.

`context_engine.lua` still owns the complete register-state reducer and now
receives the same ordered node entries from this module.

New pure regression:

~~~
tests/register_effect_collection_smoke.lua
~~~

It pins node-type traversal, visibility, deduplication, source ordering,
cursor-column conversion, explicit limit precedence, the `stop_before` alias,
and incomplete-dependency fail-closed behavior.


## Accepted context-engine split tranches 10 and 11 (2026-11-13)

ERIDU accepted both ownership slices green after two narrow test corrections.

Confirmed:

- register-effect node collection preserves indexed-node traversal;
- cursor visibility, deduplication and source ordering remain correct;
- explicit limit-position and stop-before behavior remain correct;
- instruction-event indexing preserves both adapter rule formats and cache identity;
- parser-backed ASM call/ret instruction events still flow through
  `context_engine.collect_instruction_events()`;
- register focus, normalized memory structure, effective-address evaluation,
  RIP / A32 RIP / REL handling, Inspect target certainty and adapter contracts
  remained green in the wider gate.

The production implementation required no corrective change; the two RED checks
were caused by over-constrained test expectations and were corrected in
`ea8d1c6` and `785dd47`.


## Context-engine split tranche 12 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/boundary_effect_index.lua
~~~

This module owns only boundary-effect rule indexing:

- weak-key caching keyed by the adapter's `boundary_effects` table;
- node-type indexing;
- normalized mnemonic buckets;
- support for legacy flat and mnemonic-indexed adapter data;
- preservation of the first representative rule used to guide parsing.

`context_engine.lua` still owns boundary mnemonic interpretation, instruction
parsing, boundary read/write/not-preserved inference, phase-context assembly,
effect matching and boundary fact construction.

New pure regression:

~~~
tests/boundary_effect_index_smoke.lua
~~~

## Context-engine split tranche 13 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/stack_effect_index.lua
~~~

This module owns only stack-effect rule indexing:

- weak-key caching keyed by the adapter's `stack_effects` table;
- node-type indexing;
- normalized mnemonic buckets;
- support for legacy flat and mnemonic-indexed adapter data;
- preservation of the first representative rule used to guide parsing.

`context_engine.lua` still owns stack mnemonic interpretation, stack operand
matching, instruction-state preparation, stack inference, register-state
interaction and stack fact construction.

New pure regression:

~~~
tests/stack_effect_index_smoke.lua
~~~

## Ten-commit relay boundary after tranches 12 and 13

This relay stops after exactly ten atomic commits on top of accepted
`785dd47`. No central register reducer, stack reducer or boundary inference
semantics moved in this relay.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/boundary_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_effect_index_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 12 and 13 (2026-11-13)

ERIDU accepted both extracted index perimeters green.

Confirmed:

- boundary-effect indexing preserves flat/keyed rules, representative rules and cache identity;
- stack-effect indexing preserves flat/keyed rules, representative rules and cache identity;
- register-effect collection/indexing remain green;
- instruction-event indexing and parser-backed call/ret event collection remain green;
- register focus, normalized memory structure, effective-address evaluation,
  RIP / A32 RIP / REL handling, Inspect target certainty and adapter contracts
  remain green.

The central boundary inference, stack inference and register reducers remain
unchanged.


## Context-engine split tranche 14 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/boundary_effect_collection.lua
~~~

This module owns boundary-effect collection orchestration only:

- indexed node-type traversal;
- cursor-line visibility filtering;
- duplicate Tree-sitter range suppression;
- stable source ordering;
- representative-rule parsing dispatch;
- mnemonic bucket selection;
- read-context callback sequencing;
- phase-context assembly for read/write phases;
- effect-application callback dispatch.

It does **not** own instruction parsing, register collection, boundary matching,
boundary inference, or fact construction.

New pure regression:

~~~
tests/boundary_effect_collection_smoke.lua
~~~

## Context-engine split tranche 15 (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/stack_effect_collection.lua
~~~

This module owns stack-effect collection orchestration only:

- ordered union of stack-effect and register-effect instruction node types;
- duplicate range suppression across both indexes;
- cursor-line visibility filtering;
- stable source ordering;
- stack-first representative-rule precedence;
- stack-state preparation callback sequencing;
- stack-effect dispatch;
- carried register-state callback dispatch.

It deliberately does **not** own stack inference, operand matching, value
resolution, register semantics, or fact construction.

The existing stack-path register-update callback shape is preserved exactly in
this refactor. Any semantic correction to that legacy-looking call belongs in
a separate, explicitly tested change.

New pure regression:

~~~
tests/stack_effect_collection_smoke.lua
~~~

## Ten-commit relay boundary after tranches 14 and 15

This relay stops after exactly ten atomic commits on top of accepted
`e51dc62`.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/boundary_effect_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_effect_collection_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/boundary_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_effect_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_effect_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_index_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 14 and 15 (2026-11-13)

ERIDU accepted both collection-orchestration slices green.

Confirmed:

- boundary-effect collection preserves indexed traversal, visibility,
  deduplication, source ordering, read-context sequencing, effect dispatch and
  phase contexts;
- stack-effect collection preserves stack/register union traversal,
  cross-index deduplication, source ordering, carried-state sequencing and
  stack dispatch;
- the extracted boundary/stack indexes remain green;
- register-effect and instruction-event indexing/collection remain green;
- parser-backed register focus, normalized memory structure, effective-address
  evaluation, RIP / A32 RIP / REL handling, Inspect target certainty and
  adapter contracts remain green.

The next tranche adds dedicated parser-backed boundary/stack fixtures before
changing any stack/register interaction semantics.


## Stack carried-register semantic correction (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

Dedicated parser-backed coverage now distinguishes three layers:

- `tests/asm_boundary_effects_smoke.lua` pins register-state resolution before
  a syscall boundary;
- `tests/asm_stack_effects_smoke.lua` pins baseline push/pop stack tracking;
- `tests/asm_stack_register_carry_smoke.lua` pins register-state carry into a
  later stack push.

The stack collection adapter previously called `apply_register_effect()` with
the legacy five-argument shape. The current reducer requires:

~~~
facts_by_register
family_state
latest_state_facts
adapter
instruction
effect_spec
instruction_state
~~~

The shifted call therefore left `effect_spec` nil and the reducer failed
closed, preventing earlier register writes from feeding later stack-value
resolution.

The correction keeps persistent carried `family_state` and
`latest_state_facts` tables for the stack scan and invokes the existing
register reducer with its full signature. The register reducer itself is
unchanged.


## Accepted stack semantic fixes and instruction-event collection (2026-11-13)

ERIDU accepted the parser-backed boundary/stack integration gate and both
stack semantic corrections green.

Confirmed:

- known syscall boundary reads resolve from pre-instruction register state;
- push/pop stack tracking preserves values and depth transitions;
- carried register state now reaches later stack pushes;
- pop facts now report the pop/read depth transition rather than the original
  push transition;
- instruction-event collection preserves indexed traversal, deduplication,
  dispatch and final fact ordering;
- the wider register focus, effective-address, instruction-relative, Inspect
  and adapter-contract regressions remain green.

Accepted baseline: `4343f62`.


## Context-engine split tranche 16 — generic effect matching (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/effect_match.lua
~~~

This module owns only architecture-neutral effect matching:

- operand text/value normalization;
- matching alternate operand values;
- operand kind checks;
- effect operand-list matching;
- simple operand-equality conditions.

The ASM stack matcher remains separate because it has an architecture-aware
compatibility rule for register-shaped operands that may arrive symbol-like.

New regressions:

~~~
tests/effect_match_smoke.lua
tests/asm_effect_match_smoke.lua
~~~

The parser-backed test proves a real x86-64 `mov rax, 42` still selects the
register/immediate effect through `context_engine.collect_register_effects()`.

## Context-engine split tranche 17 — instruction source fallback (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/instruction_source.lua
~~~

This module owns language-neutral instruction-source infrastructure:

- source-text normalization;
- fallback operand-kind inference;
- ancestor/descendant register-shape detection;
- fallback operand construction with source ranges;
- fallback mnemonic/operand reconstruction;
- recursive node collection by Tree-sitter node type.

Adapter-specific instruction parsing still receives first refusal through the
context adapter. The public low-level collection APIs remain unchanged.

New pure regression:

~~~
tests/instruction_source_smoke.lua
~~~

## Ten-commit relay boundary after tranches 16 and 17

This relay stops after exactly ten commits on top of accepted `4343f62`.
No central register fact construction, alias reduction, partial-mask logic or
register-effect state application moved in this relay.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/effect_match_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effect_match_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_source_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 16 and 17 (2026-11-13)

ERIDU accepted the generic effect-matching and instruction-source fallback
tranches green.

Confirmed:

- generic operand normalization, value alternatives, kind matching, effect
  operand matching and equality conditions preserve their contracts;
- real x86-64 `mov rax, 42` still selects the register/immediate rule through
  `context_engine.collect_register_effects()`;
- instruction fallback parsing preserves mnemonic/operand reconstruction,
  operand kinds, source ranges and recursive Tree-sitter traversal;
- adapter-specific instruction parsing still has first refusal;
- stack push/pop, carried-register stack inference, pop-depth precedence,
  syscall boundary inference, instruction events, register focus, memory
  structure, effective addresses, instruction-relative addressing, Inspect and
  adapter contracts remain green.

Accepted baseline: `e52dcc4`.


## Context-engine split tranche 18 — adapter syntax-spec access (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/syntax_spec.lua
~~~

This module owns read-only access to adapter syntax declarations:

- syntax table lookup;
- Tree-sitter node type lookup;
- syntax field lookup for string and structured field declarations;
- syntax field text/value lookup;
- syntax-token lookup, including the temporary legacy token fallback;
- mnemonic normalization.

`context_engine.lua` now aliases these helpers from the module. Construct,
register, boundary, instruction-event and stack rule consumers keep their
existing call sites and behavior.

New regressions:

~~~
tests/syntax_spec_smoke.lua
tests/asm_syntax_spec_smoke.lua
~~~

The ASM test validates the accessor contract against bundled x86-64 mov, push
and syscall rules.

## Context-engine split tranche 19 — adapter instruction-parser dispatch (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/instruction_parser_dispatch.lua
~~~

This module owns only adapter-declared instruction-parser loading and dispatch:

- parser configuration validation;
- safe module loading;
- default `parse_instruction` function selection;
- custom parser function-name selection;
- exact forwarding of `bufnr`, source node, effect spec and adapter.

Parser semantics remain in the adapter parser module. Fallback source parsing
remains in `low_level/instruction_source.lua`.

New regressions:

~~~
tests/instruction_parser_dispatch_smoke.lua
tests/asm_instruction_parser_dispatch_smoke.lua
~~~

The parser-backed ASM test proves the real instruction parser still produces
`mov rax, 42` with register/integer operand semantics.

## Ten-commit relay boundary after tranches 18 and 19

This relay stops after exactly ten commits on top of accepted `e52dcc4`.
No register reducer, alias reduction, value masking, stack inference, boundary
inference or fact construction moved in this relay.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/syntax_spec_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/asm_syntax_spec_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/instruction_parser_dispatch_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_parser_dispatch_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/effect_match_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effect_match_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_source_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 18 and 19 (2026-11-13)

ERIDU accepted the syntax-spec and adapter instruction-parser dispatch tranches
green.

Confirmed:

- syntax table, node-type, field, field text/value, token fallback and mnemonic
  normalization contracts remain intact;
- bundled x86-64 mov, push and syscall syntax rules still resolve correctly;
- adapter instruction-parser dispatch preserves missing-config fail-closed
  behavior, default/custom function selection and exact argument forwarding;
- the real ASM parser still produces register/integer operand semantics for
  `mov rax, 42`;
- effect matching, source fallback, stack inference, carried register state,
  pop-depth precedence, syscall boundary inference, instruction events,
  register focus, memory/effective-address evidence, instruction-relative
  addressing, Inspect and adapter contracts remain green.

Accepted baseline: `dee5dfe`.


## Context-engine split tranche 20 — construct context primitives (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/constructs/context_primitives.lua
~~~

This module owns structural context mechanics only:

- zero/one-based cursor coordinate helpers;
- global and unavailable context defaults;
- node containment checks;
- node type and source-line/range helpers;
- scope-entry construction from parsed constructs;
- outermost-to-innermost scope-path assembly.

`context_engine.lua` keeps the same public API names as direct delegates.

New regressions:

~~~
tests/context_primitives_smoke.lua
tests/context_engine_primitives_smoke.lua
~~~

## Context-engine split tranche 21 — branch presentation policy (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/constructs/branch_presentation.lua
~~~

This module owns branch presentation only:

- syntax-declared alternative matching;
- legacy `node_match` compatibility;
- syntax-field and named-child alternative discovery;
- alternative-label lookup;
- grouped/non-grouped display formatting;
- cursor-selected branch display labels.

Construct parsing, validation, scope semantics and language-specific behavior
remain outside this module. `context_engine.lua` keeps its existing public
branch helper names as delegates.

New regressions:

~~~
tests/branch_presentation_smoke.lua
tests/context_engine_branch_smoke.lua
~~~

## Ten-commit relay boundary after tranches 20 and 21

This relay stops after exactly ten commits on top of accepted `dee5dfe`.
No register reducer, alias/mask logic, stack inference, boundary inference,
memory evaluation or fact construction moved in this relay.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/context_primitives_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/context_engine_primitives_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/branch_presentation_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/context_engine_branch_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/syntax_spec_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_parser_dispatch_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effect_match_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_source_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 20 and 21 (2026-11-13)

ERIDU accepted the construct context-primitives and branch-presentation tranches
green.

Confirmed:

- cursor coordinate conventions, node identity/ranges/containment, scope-entry
  construction, scope ordering and global/unavailable context defaults remain
  intact;
- context_engine preserves the public construct-context delegate surface;
- syntax and legacy branch-alternative matching, field/named-child discovery,
  branch labels, grouped formatting and cursor-selected presentation remain
  intact;
- syntax access, real ASM parser dispatch, effect matching, source fallback,
  stack inference, carried register state, pop-depth precedence, syscall
  boundary inference, register focus, memory/effective-address evidence,
  instruction-relative addressing, Inspect and adapter contracts remain green.

Accepted baseline: `0411c80`.


## Context-engine split tranche 22 — construct spec validation (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/constructs/spec_validation.lua
~~~

This module owns adapter construct-spec lookup and validation only:

- construct-spec table/key validation;
- syntax table and Tree-sitter node-type validation;
- syntax fields/children/tokens/exclusions shape checks;
- canonical construct/scope/member/value contract delegation;
- marker required/optional validation;
- syntax-token lookup including the legacy token fallback;
- exact validation error strings used by callers/tests.

`context_engine.get_construct_spec` and
`context_engine.validate_construct_spec` remain public direct delegates.

New regressions:

~~~
tests/construct_spec_validation_smoke.lua
tests/context_engine_construct_validation_smoke.lua
~~~

## Context-engine split tranche 23 — construct source identity (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/constructs/source_identity.lua
~~~

This module owns construct source identity helpers only:

- first-line source extraction;
- first-line signature strategy;
- local-name then general-name signature-pattern precedence;
- syntax-field name extraction;
- canonical construct assembly through `constructs.contract.new_construct`.

`context_engine` keeps the same public helper names as direct delegates.
`parse_node()` itself remains in `context_engine.lua` and continues to call
those public helper names, so parse orchestration has not moved in this relay.

New regressions:

~~~
tests/construct_source_identity_smoke.lua
tests/context_engine_construct_identity_smoke.lua
~~~

## Ten-commit relay boundary after tranches 22 and 23

This relay stops after exactly ten commits on top of accepted `0411c80`.
Construct parse orchestration, register reduction, alias/mask logic, stack and
boundary inference, memory evaluation and fact construction remain in their
previous owners.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/construct_spec_validation_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/context_engine_construct_validation_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/construct_source_identity_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/context_engine_construct_identity_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/context_primitives_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/branch_presentation_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/syntax_spec_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_instruction_parser_dispatch_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effect_match_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_source_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 22 and 23 (2026-11-13)

ERIDU accepted the construct-spec validation and construct source-identity
tranches green.

Confirmed:

- construct-spec lookup, syntax shape validation, marker/token validation,
  legacy token fallback and canonical contract delegation remain intact;
- construct source identity preserves first-line signatures, local-name
  precedence, syntax-field names and canonical construct assembly;
- the context_engine public validation and source-identity delegates remain
  intact;
- construct primitives, branch presentation, syntax access, ASM parser
  dispatch, effect matching, instruction fallback, stack inference, carried
  register state, pop-depth precedence, boundary inference, register focus,
  memory/effective-address evidence, instruction-relative addressing, Inspect
  and adapter contracts remain green.

Accepted baseline: `8fc4fef`.


## Context-engine split tranche 24 — construct parse orchestration (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/constructs/parser.lua
~~~

This module owns only construct match/parse orchestration over already-extracted
helpers:

- node-type matching against `adapter.construct_specs`;
- construct-spec lookup;
- source range lookup;
- signature/name resolution;
- branch display-label selection;
- canonical construct assembly.

Construct validation, source identity, branch presentation, context primitives
and contract semantics remain in their existing modules. The public
`context_engine.match_node` and `context_engine.parse_node` names remain
direct delegates.

New regressions:

~~~
tests/construct_parser_smoke.lua
tests/context_engine_construct_parser_smoke.lua
~~~

## Context-engine split tranche 25 — register-state read policy (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_state_read.lua
~~~

This module is read-only and owns:

- static-register lookup;
- register-fact map lookup;
- architecture alias lookup;
- canonical-to-alias value projection;
- canonical state-key resolution;
- register-value width lookup;
- resolved-fact classification.

It does not mutate register state, construct facts, apply effects, update alias
families or perform writes. `make_register_fact()` and
`apply_register_effect()` remain in `context_engine.lua`; their existing
local helper names now delegate to this read-policy module.

New regressions:

~~~
tests/register_state_read_smoke.lua
tests/asm_register_state_read_smoke.lua
~~~

The parser-backed ASM test proves a real `mov rax, 42` state projects through
the `eax` alias with canonical key `rax`, width 32 for `eax` and width 64
for `rax`.

## Ten-commit relay boundary after tranches 24 and 25

This relay stops after exactly ten commits on top of accepted `8fc4fef`.
The central register write reducer, partial-mask application, stack/boundary
inference, memory evaluation and fact construction have not moved.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/construct_parser_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/context_engine_construct_parser_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_state_read_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_read_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/construct_spec_validation_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/construct_source_identity_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/context_primitives_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/branch_presentation_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_instruction_parser_dispatch_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effect_match_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_source_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 24 and 25 (2026-11-13)

ERIDU accepted the construct-parser and register-state read-policy tranches
green.

Confirmed:

- construct node matching, source identity/range assembly, canonical payload
  assembly and invalid/missing parse behavior remain intact;
- context_engine preserves public construct parser delegates;
- register static/fact lookup, alias resolution, canonical state keys,
  canonical-to-alias projection, widths, resolved classification and direct
  fact precedence remain intact;
- real x86-64 `mov rax, 42` projects through `eax` as value 42 with
  canonical key `rax`, width 32 for `eax` and width 64 for `rax`;
- construct validation/identity, source fallback, stack inference, carried
  register state, pop-depth precedence, boundary inference, register focus,
  memory/effective-address evidence, instruction-relative addressing, Inspect
  and adapter contracts remain green.

Accepted baseline: `7f7dc39`.


## Context-engine split tranche 26 — register value policy (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_value_policy.lua
~~~

This module owns pure register-value transformation policy only:

- target-width modular wrapping;
- width-policy metadata;
- exact numeric normalization;
- safe-number conversion;
- source integer interpretation through declarative integer-operand policy;
- source integer metadata shaping.

It does not mutate register state, apply alias writes, construct register facts
or dispatch effects. `context_engine.lua` keeps delta arithmetic itself and
now delegates the width/immediate policy helpers.

New regressions:

~~~
tests/register_value_policy_smoke.lua
tests/asm_register_value_policy_smoke.lua
~~~

The parser-backed ASM test proves:

- `mov al, 0xFF; inc al` wraps at 8 bits;
- `add rax, 0xFFFFFFFF` still sign-interprets the immediate as signed imm32
  and wraps the final target-width result.

## Context-engine split tranche 27 — register effect processing orchestration (2026-11-13)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_processing.lua
~~~

This module owns only the ordered processing loop over already-collected
register-effect instruction nodes:

- temporary register/family/latest-fact state containers;
- one low-level inference state shared across instructions;
- representative-rule parse dispatch;
- mnemonic bucket selection;
- instruction-state preparation callback sequencing;
- effect application callback sequencing;
- final fact-list callback dispatch.

Register semantics remain in injected callbacks. In particular,
`make_register_fact()`, `apply_register_effect()`,
`register_value_mask.apply_alias_write()`, value resolution and alias-family
mutation remain outside this module.

New regressions:

~~~
tests/register_effect_processing_smoke.lua
tests/asm_register_effect_processing_smoke.lua
~~~

The parser-backed ASM test proves:

~~~
mov rax, 41
inc rax
~~~

still reduces to one latest canonical RAX fact with value 42 and effect
`inc_register`.

## Ten-commit relay boundary after tranches 26 and 27

This relay stops after exactly ten commits on top of accepted `7f7dc39`.
The central register write reducer, alias-mask write semantics, memory
evaluation, stack/boundary inference and fact construction have not moved.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/register_value_policy_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_value_policy_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_processing_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_state_read_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_read_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/construct_parser_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/construct_spec_validation_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/construct_source_identity_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/x86_width_wrap_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 26 and 27 (2026-11-14)

ERIDU accepted the register-value policy and register-effect processing
orchestration tranches green.

Confirmed:

- target-width modular wrapping, unsupported/missing-width fail-closed paths,
  signed immediate interpretation, exact normalization and metadata shaping
  remain intact;
- real x86-64 `AL` arithmetic still wraps at 8 bits and
  `add rax, 0xFFFFFFFF` still sign-interprets signed imm32 before target-width
  wrapping;
- register-effect processing preserves carried state, callback ordering,
  fail-closed dependency handling and one latest canonical fact;
- real `mov rax, 41; inc rax` still reduces to one RAX fact with value 42;
- register reads, construct parsing, x86 alias writes, stack inference,
  boundary inference, register focus, memory/effective-address evidence,
  instruction-relative addressing, Inspect and adapter contracts remain green.

Accepted baseline: `c375c6f`.


## Context-engine split tranche 28 — register-effect value resolution (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_value.lua
~~~

This module owns read-only register-effect value resolution:

- literal effect values;
- stack-top values;
- explicit source-register values;
- source-register operand values;
- fixed and operand-derived arithmetic deltas;
- delta sign application;
- integer operand interpretation through register-value policy;
- immediate/register value operands;
- unresolved register-name fallbacks.

It performs exact arithmetic and reads existing state but does not construct
facts, mutate register state, invalidate aliases or apply alias masks.
`make_register_fact()` remains in `context_engine.lua` and now calls this
module through the existing local resolver name.

New regressions:

~~~
tests/register_effect_value_smoke.lua
tests/asm_register_effect_value_smoke.lua
~~~

The parser-backed ASM test proves:

~~~
mov rax, 40
mov rbx, rax
add rbx, 2
~~~

still resolves the register copy to 40 and the later arithmetic state to 42.

## Context-engine split tranche 29 — stack-effect operand matching (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/stack_effect_match.lua
~~~

This module owns stack-effect operand matching only:

- optional operand value matching;
- operand-kind matching;
- effect operand-list matching;
- the deliberate ASM compatibility rule where a symbol-like operand naming a
  known architecture register may satisfy a register operand spec.

That compatibility remains stack-specific and is not folded into the generic
effect matcher. Stack inference, stack fact construction and effect application
remain in their previous owners.

New regressions:

~~~
tests/stack_effect_match_smoke.lua
tests/asm_stack_effect_match_smoke.lua
~~~

The parser-backed ASM test proves `push rax` still selects
`push_register` and preserves the carried value from `mov rax, 42`.

## Ten-commit relay boundary after tranches 28 and 29

This relay stops after exactly ten commits on top of accepted `c375c6f`.
The central register fact builder/write reducer, alias-mask write semantics,
stack fact construction/application, memory evaluation and boundary inference
have not moved.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/register_effect_value_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_value_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/stack_effect_match_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effect_match_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_value_policy_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_value_policy_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_processing_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_state_read_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_read_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/x86_width_wrap_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 28 and 29 (2026-11-14)

ERIDU accepted the register-effect value-resolution and stack-effect matching
tranches green.

Confirmed:

- literal, stack-top, register, register-operand, fixed-delta,
  operand-derived-delta and immediate value paths preserve their contracts;
- real `mov rax, 40; mov rbx, rax; add rbx, 2` still resolves RBX to 40
  and then 42;
- stack matching preserves register-shaped symbol compatibility, unknown-symbol
  rejection, value matching and operand-list contracts;
- real `mov rax, 42; push rax` still selects `push_register` and carries
  value 42;
- register value policy/processing/reads, x86 alias writes, stack inference,
  boundary inference, register focus, memory/effective-address evidence,
  instruction-relative addressing, Inspect and adapter contracts remain green.

Accepted baseline: `8220215`.


## Context-engine split tranche 30 — register fact construction (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_fact_builder.lua
~~~

This module owns construction of one already-matched register fact:

- effect target resolution;
- register-effect value resolution;
- target-width value policy;
- alias-family certainty composition through register-value masks;
- static register kind/role lookup;
- semantic metadata assembly;
- source integer/source-role metadata merge;
- target-operand source range precedence;
- implicit-register source fallback.

It may read prior family state for alias composition, but it does not publish
or mutate register state maps.

`context_engine.lua` now delegates `make_register_fact` to this builder and
no longer directly owns register-effect value resolution or alias-mask
composition for fact construction.

New regressions:

~~~
tests/register_fact_builder_smoke.lua
tests/asm_register_fact_builder_smoke.lua
~~~

The parser-backed ASM test proves `mov eax, 0xFFFFFFFF` still produces an
`eax` fact whose reduced canonical RAX value is
`0x00000000FFFFFFFF`, with raw write value `4294967295`, canonical name
`rax`, operand target origin and the same effect identity.

## Context-engine split tranche 31 — register state publication (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_state_write.lua
~~~

This module owns publication of an already-built register fact:

- latest canonical state publication;
- family state publication;
- sibling alias invalidation;
- raw source-alias write publication;
- reduced canonical family publication;
- unresolved raw/canonical publication semantics.

It does not match effects, resolve values or construct facts.
`apply_register_effect()` remains in `context_engine.lua` as the semantic
gatekeeper and now reduces to match -> build fact -> publish fact.

New regressions:

~~~
tests/register_state_write_smoke.lua
tests/asm_register_state_write_smoke.lua
~~~

The parser-backed ASM test proves:

~~~
mov rax, 0xFFFFFFFFFFFFFFFF
mov eax, 1
mov rbx, rax
~~~

publishes EAX as zero-extended canonical RAX and the later RAX source read
observes value 1 rather than stale pre-EAX state.

## Ten-commit relay boundary after tranches 30 and 31

This relay stops after exactly ten commits on top of accepted `8220215`.
Register effect matching remains in `apply_register_effect()`; stack fact
construction/application, memory evaluation and boundary inference remain in
their previous owners.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/register_fact_builder_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_fact_builder_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_state_write_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_value_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_value_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_value_policy_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_value_policy_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_state_read_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_read_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/stack_effect_match_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effect_match_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/x86_width_wrap_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_immediate_interpretation_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.


## Accepted context-engine split tranches 30 and 31 (2026-11-14)

ERIDU accepted register fact construction and register state publication after
one narrow test-only correction.

Confirmed:

- register fact construction preserves target identity/role, EAX canonical
  zero-extension, semantic metadata, target source-range precedence and
  implicit-register targets;
- register state publication preserves latest/family state, sibling alias
  invalidation, raw write publication, reduced canonical publication,
  unresolved publication and direct canonical publication;
- real `mov eax, 0xFFFFFFFF` still produces canonical RAX
  `0x00000000FFFFFFFF`;
- real `mov rax, 0xFFFFFFFFFFFFFFFF; mov eax, 1; mov rbx, rax` publishes
  canonical RAX `0x0000000000000001` and the later RBX copy reads that exact
  newly-published value;
- the temporary RED was a new-test representation assumption only: the test
  expected decimal `"1"` instead of the exact canonical value string. The
  correction changed only the test, not production code;
- x86 alias writes and register effect value resolution remain green.

Accepted baseline: `1cf57a6`.


## Context-engine split tranche 32 — instruction-event fact application (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/instruction_event_fact.lua
~~~

This module owns instruction-event fact assembly and match-gated append
semantics only:

- event kind/category/name/role assembly;
- source-line/source-column range assembly;
- adapter/architecture/variant/mnemonic metadata;
- parsed operand and operand-spec metadata;
- control-flow/read/write metadata through `control_infer`;
- appending a fact only after an injected matcher accepts the event.

Syntax-derived mnemonic lookup and event matching remain in their existing
owners and are injected by `context_engine`.

`context_engine.lua` no longer directly requires `control_infer`.

New regressions:

~~~
tests/instruction_event_fact_smoke.lua
tests/asm_instruction_event_fact_smoke.lua
~~~

The parser-backed ASM test proves `call target` preserves call event identity,
source location, configured adapter metadata and parsed target operand metadata.

A pre-gate test-only correction aligned the new test with the configured ASM
architecture label `x86-64`; production code was unchanged.

## Context-engine split tranche 33 — boundary-effect application wrapper (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/boundary_effect_apply.lua
~~~

This module owns only:

- injected mnemonic matching for a boundary effect;
- delegation to `boundary_infer.make_effect_fact`;
- appending a produced boundary fact.

Pre-boundary register collection remains in `context_engine.lua`.
Known syscall resolution, reads, writes, not-preserved state and phase
semantics remain owned by `boundary_infer`.

`context_engine.lua` no longer directly requires `boundary_infer`.

New pure regression:

~~~
tests/boundary_effect_apply_smoke.lua
~~~

Parser-backed integration remains pinned by the established
`tests/asm_boundary_effects_smoke.lua`, which proves real syscall resolution
from pre-boundary register state and read/write phase metadata.

## Ten-commit relay boundary after tranches 32 and 33

This relay stops after exactly ten commits on top of accepted `1cf57a6`.
The register match gate, memory evaluation, stack fact/application and
pre-boundary register collection remain in `context_engine.lua`.

### ERIDU acceptance gate

~~~
git status --short
git pull --ff-only
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/instruction_event_fact_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_fact_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/boundary_effect_apply_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_state_write_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_fact_builder_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

Do not take the next ownership slice until this gate is accepted green.

## Accepted context-engine split tranches 32 and 33 (2026-11-14)

ERIDU accepted the instruction-event fact application and boundary-effect
application wrapper tranches green.

Confirmed:

- instruction-event facts preserve event identity, source ranges, configured
  adapter metadata, parsed operand metadata, control metadata and match-gated
  append behavior;
- real ASM `call target` event facts preserve call identity and operand
  semantics;
- boundary application preserves mnemonic matching, fact identity, phase
  metadata and match-gated append behavior;
- real ASM syscall inference still resolves from pre-instruction register
  state and preserves before-instruction read / after-instruction write phase
  metadata;
- register publication/fact construction, x86 alias writes, stack inference,
  memory/effective-address evidence, instruction-relative addressing, Inspect
  and adapter contracts remain green.

Accepted baseline: `e1ff4cc`.

## Context-engine split tranche 34 — stack-effect application wrapper (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/stack_effect_apply.lua
~~~

This module owns only the final stack-effect application gate:

- injected syntax-derived mnemonic matching;
- stack-specific operand matching, including the established register-shaped
  symbol compatibility rule;
- generic condition matching;
- delegation to `stack_infer.make_effect_fact`;
- appending an accepted stack fact.

Stack state preparation, push/pop value carry, depth tracking and stack-read
semantics remain owned by `stack_infer`. Register reduction remains separate.

`context_engine.lua` no longer directly requires `stack_effect_match` and
keeps only a tiny adapter/syntax wrapper around the new application module.

New regressions:

~~~
tests/stack_effect_apply_smoke.lua
tests/asm_stack_effect_apply_smoke.lua
~~~

The parser-backed ASM test proves a real `push 7` still produces one resolved
`stack_push` fact with the declared `push_immediate` effect identity.

## Context-engine split tranche 35 — pre-boundary register context (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/boundary_register_context.lua
~~~

This module owns construction of the register snapshot used by boundary reads:

- choose the boundary instruction's source-start position;
- normalize the pre-instruction limit;
- invoke injected register-effect collection at that limit;
- publish the resulting facts into the boundary `registers` section.

It does not reduce registers, match boundary effects, resolve known syscalls, or
infer boundary reads/writes/not-preserved state.

New regressions:

~~~
tests/boundary_register_context_smoke.lua
tests/asm_boundary_register_context_smoke.lua
~~~

The parser-backed proof uses:

~~~
mov rax, 1
syscall
mov rax, 60
~~~

with the cursor after all three lines. The syscall must still read pre-boundary
RAX value `1`; the later value `60` must not leak backward into the boundary
snapshot.

## Static audit at pending head

`context_engine.lua`: 1586 lines.

Expected ownership markers:

- exact `stack_effect_apply` require: 1
- direct `stack_effect_match` require: 0
- exact `boundary_register_context` require: 1
- local `collect_registers_before_instruction` definition: 1
- local `apply_register_effect` definition: 1
- local `evaluate_memory_address_before_instruction` definition: 1

The register match/write reducer and memory-address coordinator remain in
`context_engine.lua`; they were intentionally not moved in this relay.

## Relay boundary after tranches 34 and 35

The planned architecture relay contains ten commits on top of accepted
`e1ff4cc`. Before ERIDU acceptance, connector-side static audit found a
literal `\\n` separator defect in the two newly inserted `require` lines.
A narrow production correction repairs those separators and removes the
now-dead direct `stack_effect_match` require; this documentation correction
records the repaired static audit. No semantic reducer logic changed in either
correction.

### ERIDU acceptance gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -14 --oneline

nvim --headless -u NONE -c "luafile tests/stack_effect_apply_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effect_apply_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/boundary_register_context_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_register_context_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/stack_read_depth_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/boundary_effect_apply_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_state_write_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_fact_builder_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, accept the relay head and audit the remaining register
match gate and memory-address coordination before choosing tranche 36.

## Accepted context-engine split tranches 34 and 35 (2026-11-14)

ERIDU accepted the stack-effect application wrapper and pre-boundary register
context tranches green.

Confirmed:

- stack application preserves mnemonic/operand matching, fact construction,
  match-gated append behavior and fail-closed dependency handling;
- real ASM `push 7` still produces the resolved `push_immediate` stack fact;
- pre-boundary register context preserves source-start position limiting and
  publishes a separate register section without mutating the source context;
- with `mov rax, 1; syscall; mov rax, 60`, the syscall still reads pre-boundary
  RAX value `1`; the later write does not leak backward;
- stack push/pop carry and depth transitions, syscall phase semantics,
  register publication/fact construction, x86 alias writes, instruction-event
  collection, memory/effective-address evidence, instruction-relative
  addressing, Inspect and adapter contracts remain green.

Accepted baseline: `5dcd3a4`.

## Context-engine split tranche 36 — register-effect application wrapper (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_apply.lua
~~~

This module owns only the final register-effect application gate:

- injected syntax-derived mnemonic matching;
- generic operand and condition matching;
- delegation to `register_fact_builder.build`;
- delegation to `register_state_write.publish`.

It does not resolve register values, compose alias masks, construct publication
policy, or own the ordered register-processing loop.

`context_engine.lua` no longer directly requires `register_fact_builder` or
`register_state_write`; it keeps only a tiny syntax-policy wrapper around the
new module.

New regressions:

~~~
tests/register_effect_apply_smoke.lua
tests/asm_register_effect_apply_smoke.lua
~~~

The parser-backed ASM proof keeps `mov rax, 41; inc rax` reduced to one
canonical resolved RAX fact with value `42` and effect `inc_register`.

## Context-engine split tranche 37 — source-time memory-address evaluator (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/memory_address_evaluator.lua
~~~

This module owns coordination of one normalized source-memory address:

- validate source-time evaluation context;
- choose instruction-relative evaluation when required;
- otherwise replay register effects only up to the memory instruction;
- index canonical/source register facts for read projection;
- preserve partial/unknown register certainty;
- delegate arithmetic to `effective_address.evaluate`.

It does not parse memory operands, resolve source symbols, provide machine
addresses, match memory-access policy, read process memory, or claim runtime
execution.

`context_engine.lua` now injects only `M.collect_register_effects` into this
module. Direct `effective_address` and `relative_address` dependencies moved
out of the context engine.

New regressions:

~~~
tests/memory_address_evaluator_smoke.lua
tests/asm_memory_address_evaluator_smoke.lua
~~~

The parser-backed proof uses:

~~~
bits 64
mov rax, 0x1000
mov rbx, [rax + 8]
mov rax, 0x2000
~~~

The line-3 source memory operand must evaluate to decimal `4104` from
pre-instruction RAX value `4096`; the later RAX write must not leak backward.
The resulting source fact must remain `execution_status = not_observed`.

## Static audit at pending head

`context_engine.lua`: 1433 lines.

Expected ownership markers:

- exact `register_effect_apply` require: 1
- direct `register_fact_builder` require: 0
- direct `register_state_write` require: 0
- exact `memory_address_evaluator` require: 1
- direct `effective_address` require: 0
- direct `relative_address` require: 0
- local `apply_register_effect` definition: 1
- local `evaluate_memory_address_before_instruction` definition: 1

The context engine still owns adapter syntax/index setup, source collection
wiring, and the cross-section orchestration that belongs at that boundary.

## Ten-commit relay boundary after tranches 36 and 37

This relay stops after exactly ten commits on top of accepted `5dcd3a4`.

### ERIDU acceptance gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -12 --oneline

nvim --headless -u NONE -c "luafile tests/register_effect_apply_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_apply_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_state_write_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_fact_builder_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, accept the relay head and re-audit `context_engine.lua`
for the next ownership boundary rather than continuing extraction by size.

## Accepted context-engine split tranches 36 and 37 (2026-11-14)

ERIDU accepted the register-effect application wrapper and source-time
memory-address evaluator tranches green.

Confirmed:

- register application preserves mnemonic/operand matching, fact construction,
  match-gated publication and fail-closed dependency behavior;
- real `mov rax, 41; inc rax` still publishes one canonical resolved RAX fact
  with value `42`;
- memory evaluation preserves the exact pre-instruction replay limit,
  register arithmetic, partial-register fail-closed behavior and dependency
  fail-closed behavior;
- with `mov rax, 0x1000; mov rbx, [rax + 8]; mov rax, 0x2000`, the source
  memory address still resolves to `4104` from the earlier RAX value and the
  later write does not leak backward;
- register processing/publication, x86 alias state, memory structure,
  effective-address evidence, instruction-relative addressing, Inspect, stack,
  boundary, instruction-event and adapter contracts remain green.

Accepted baseline: `90f0bd5`.

## Context-engine split tranche 38 — shared low-level rule syntax policy (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/rule_syntax.lua
~~~

This module owns the common read-only syntax policy shared by register,
boundary, stack and instruction-event rule indexes:

- Tree-sitter-first node-type lookup with legacy `node_type` fallback;
- Tree-sitter-first `kind` mnemonic lookup with legacy/fallback mnemonic;
- common mnemonic normalization;
- index callback packaging.

The four indexes remain separate owners of their own caches/buckets and semantic
collection behavior.

`context_engine.lua` no longer directly requires `syntax_spec` for these
low-level rules and no longer carries four duplicate mnemonic/index-policy
implementations.

New regressions:

~~~
tests/rule_syntax_smoke.lua
tests/asm_rule_syntax_smoke.lua
~~~

The ASM proof checks real x86-64 register, stack, boundary and instruction-event
rules: `mov`, `push`, `syscall`, and `call`.

## Context-engine split tranche 39 — shared register-effect selection (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_selection.lua
~~~

This module owns generic selection of register-effect candidates from an
already-built register-effect index:

- node-type bucket lookup;
- normalized mnemonic bucket lookup;
- generic operand matching;
- generic condition matching;
- representative-rule parser dispatch for node-based selection.

Adapter parsing and mnemonic policy remain injected. Register-effect indexing,
fact construction, publication and replay remain in their existing owners.

Both register-source Inspect discovery and memory-source collection now use the
same selection policy. `context_engine.lua` no longer directly requires
`effect_match`.

New regressions:

~~~
tests/register_effect_selection_smoke.lua
tests/asm_register_effect_selection_smoke.lua
~~~

The parser-backed proof parses real `mov rax, 42` and requires exactly the
`mov_register_immediate` rule to survive selection.

## Static audit at pending head

`context_engine.lua`: 1275 lines.

Expected ownership markers:

- exact `rule_syntax` require: 1
- direct `syntax_spec` require: 0
- exact `register_effect_selection` require: 1
- direct `effect_match` require: 0
- local register index definition: 1
- local boundary index definition: 1
- local instruction-event index definition: 1
- local stack index definition: 1
- local register-effect matching wrapper: 1

The source-discovery collection wiring remains in `context_engine.lua`
intentionally; this relay moves shared policy only.

## Relay boundary after tranches 38 and 39

The planned architecture relay contains ten commits on top of accepted
`90f0bd5`. Before ERIDU acceptance, connector-side static audit found four
duplicated replacement-boundary markers in `context_engine.lua`:
`build_source_written_role`, the boundary-inference comment,
`instruction_event_matches`, and `apply_stack_effect`.

A narrow production correction in `84b0835` repairs only those duplicated
markers. The new rule-syntax and effect-selection modules were unchanged, and
no semantic inference or reducer behavior changed.

### ERIDU acceptance gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -14 --oneline

nvim --headless -u NONE -c "luafile tests/rule_syntax_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/asm_rule_syntax_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_selection_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_selection_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_effect_apply_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_processing_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, accept the relay and re-audit the remaining source
collection wiring before choosing the next ownership slice.

## Accepted context-engine split tranches 38 and 39 (2026-11-14)

ERIDU accepted the shared low-level rule-syntax policy and shared
register-effect selection tranches green.

Confirmed:

- Tree-sitter-first and legacy rule node/mnemonic lookup preserve their
  contracts and fail closed on invalid input;
- real x86-64 register, stack, boundary and instruction-event rules still
  resolve `mov`, `push`, `syscall`, and `call`;
- register-effect candidate filtering preserves representative parsing plus
  operand/condition matching;
- real `mov rax, 42` still selects exactly `mov_register_immediate`;
- register application/processing, source-time memory evaluation, memory
  structure/effective-address evidence, instruction-relative addressing,
  Inspect, stack, boundary, instruction-event and adapter contracts remain
  green.

Accepted baseline: `7a2ad03`.

## Context-engine split tranche 40 — memory-source discovery coordinator (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/memory_source_discovery.lua
~~~

This module owns the architecture-neutral setup that feeds
`memory_source_collection`:

- instruction-node type selection;
- source-member snapshot collection;
- optional register-effect index lookup;
- register-effect role selection;
- source-memory access intent resolution;
- source-node traversal;
- the bridge to source-time effective-address evaluation.

It does not construct source-memory facts, perform register replay, resolve
effective-address arithmetic, provide machine addresses, or claim execution.

The public context-engine APIs remain unchanged:

- `discover_memory_source_operands`
- `collect_memory_source_operands`

New regressions:

~~~
tests/memory_source_discovery_smoke.lua
tests/asm_memory_source_discovery_smoke.lua
~~~

The parser-backed proof requires exact-line discovery of `[rax + 8]` from
`mov rbx, [rax + 8]`, preserving access `read`, effective address `4104`,
and `execution_status = not_observed`. Role propagation is pinned separately
by the pure coordinator test with an injected register-effect rule.

## Context-engine split tranche 41 — register-source discovery coordinator (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_source_discovery.lua
~~~

This module owns the architecture-neutral setup that feeds
`register_source_collection` for Inspect:

- register-effect index lookup;
- source-member snapshot collection;
- indexed instruction-node traversal;
- representative-rule parse and effect selection;
- the bridge to source-time effective-address evaluation.

Occurrence construction and memory-evidence attachment remain in the existing
register-source collection/occurrence modules.

The public context-engine API remains unchanged:

- `discover_register_source_occurrences`

New regressions:

~~~
tests/register_source_discovery_smoke.lua
tests/asm_register_source_discovery_smoke.lua
~~~

The parser-backed proof requires the line containing
`mov rbx, [rax + 8]` to preserve mnemonic, destination-register focus,
base-register component, and effective-address evidence `4104`. Memory-operand
Inspect-row construction is pinned separately by the pure coordinator test
when a matching register-effect rule exists.

## Context-engine cleanup produced by ownership moves

The coordinator delegation also removes context-engine dependencies/helpers that
became provably dead:

- direct `memory_access` dependency;
- direct `memory_source_evidence` dependency;
- direct `memory_source_collection` dependency;
- direct `register_source_collection` dependency;
- direct `register_effect_selection` dependency;
- direct `register_source_metadata` dependency;
- direct `register_source_occurrence` dependency;
- direct `operand_metadata` dependency;
- direct `scope_members` dependency;
- unused register read/width compatibility aliases;
- unused source-role presentation helpers.

No public API is removed.

## Static audit at pending head

`context_engine.lua`: 1059 lines.

Expected ownership markers:

- exact `memory_source_discovery` require: 1
- exact `register_source_discovery` require: 1
- direct `memory_source_collection` require: 0
- direct `register_source_collection` require: 0
- direct `memory_access` require: 0
- direct `scope_members` require: 0
- local memory discovery wrapper: 1
- exported register discovery entry point: 1

The context engine still owns the source-time register replay bridge because it
is shared with boundary and other cross-section inference.

## Relay boundary after tranches 40 and 41

The planned architecture relay contains ten commits on top of accepted
`7a2ad03`. Before ERIDU acceptance, static audit found four duplicated
replacement-boundary markers in `context_engine.lua`. The same audit also
found two over-assertions in the newly added parser-backed tests: the current
x86 register-effect tables do not declare a `mov register,[memory]` register
effect, so source-memory role/Inspect-row presence must not be invented by the
new migration tests.

Correction `f2735f7` repairs the four duplicated engine markers and narrows
only those two new parser-backed expectations. The pure coordinator tests still
exercise role and memory-operand wiring with injected effect rules. No
established test or production semantic contract was weakened.

### ERIDU acceptance gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -14 --oneline

nvim --headless -u NONE -c "luafile tests/memory_source_discovery_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_source_discovery_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_source_discovery_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_source_discovery_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/memory_source_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/register_source_collection_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_structure_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_effective_address_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_relative_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_effect_apply_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, accept the relay and re-audit the remaining context
orchestration rather than extracting by size.

## Accepted context-engine split tranches 40 and 41 (2026-11-14)

ERIDU accepted the memory-source and register-source discovery coordinators
green.

Confirmed:

- memory discovery dependency dispatch, injected role/access policy, source-time
  certainty and fail-closed behavior remain intact;
- real `mov rbx, [rax + 8]` exact-line memory discovery preserves access
  `read`, effective address `4104`, and source-only execution status;
- register discovery preserves occurrence construction, memory evidence and
  fail-closed behavior;
- real source inspection preserves mnemonic/register focus plus base-register
  effective-address evidence `4104`;
- the existing memory/register source collection contracts remain green;
- source-time memory replay isolation, normalized memory structure,
  effective-address evaluation, instruction-relative addressing, Inspect,
  register application, stack, boundary, instruction-event and adapter
  contracts all remain green.

Accepted baseline: `916a2bc`.

## Context-engine split tranche 42 — boundary-effect pipeline (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/boundary_effect_pipeline.lua
~~~

This coordinator owns the architecture-neutral boundary pipeline:

- boundary-rule index construction;
- indexed source traversal;
- adapter instruction parse dispatch;
- pre-boundary register-context construction;
- boundary matcher/fact application;
- final fact collection.

Register reduction remains injected from the context engine, so the pipeline
does not create a dependency cycle or own register semantics.

New regressions:

~~~
tests/boundary_effect_pipeline_smoke.lua
tests/asm_boundary_effect_pipeline_smoke.lua
~~~

The parser-backed proof requires `mov rax, 60; mov rdi, 7; syscall` to resolve
the Linux `exit` boundary from pre-instruction state, including status value
`7`.

## Context-engine split tranche 43 — instruction-event pipeline (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/instruction_event_pipeline.lua
~~~

This coordinator owns the architecture-neutral instruction-event pipeline:

- instruction-event index construction;
- indexed source traversal;
- adapter instruction parse dispatch;
- event mnemonic matching;
- event fact application;
- stable event collection.

It does not own adapter parsing or control-flow semantics.

New regressions:

~~~
tests/instruction_event_pipeline_smoke.lua
tests/asm_instruction_event_pipeline_smoke.lua
~~~

The parser-backed proof requires real `call target; ret` source to preserve
call/ret ordering and parsed call-target metadata.

## Context-engine cleanup produced by tranches 42 and 43

The context engine no longer directly depends on:

- `boundary_effect_index`
- `boundary_effect_collection`
- `boundary_effect_apply`
- `boundary_register_context`
- `instruction_event_index`
- `instruction_event_collection`
- `instruction_event_fact`

The public APIs remain unchanged:

- `collect_boundary_effects`
- `collect_instruction_events`

Stack orchestration remains in the context engine intentionally; its carried
register-family/latest-fact state makes it a materially different pipeline.

## Static audit at pending head

`context_engine.lua`: 847 lines.

Expected markers:

- exact `boundary_effect_pipeline` require: 1
- exact `instruction_event_pipeline` require: 1
- direct `boundary_effect_collection` require: 0
- direct `boundary_effect_apply` require: 0
- direct `instruction_event_collection` require: 0
- direct `instruction_event_fact` require: 0
- exported boundary entry point: 1
- exported event entry point: 1

## Relay boundary after tranches 42 and 43

The planned architecture relay contains ten commits on top of accepted
`916a2bc`.

During pre-gate static audit, a latent register-read defect from the prior
accepted cleanup was found: `prepare_register_instruction_inference_state`
still called `get_register_fact_for_read`, but tranche 40 had accidentally
removed its local alias to `register_state_read.get_fact_for_read`. The prior
ERIDU gate did not exercise the register-to-register read path, so the issue
survived that acceptance.

Correction `8230096` restores only that local alias. No register-read,
alias-width, publication, boundary, event, stack, or memory semantic policy was
changed. The gate below therefore includes the parser-backed register-state
copy and x86 scalar alias regressions.

With the alias restored, the pending context engine is 847 lines. The pending
branch is thirteen commits ahead of accepted `916a2bc`: ten architectural
relay commits plus the alias correction and two documentation records.

### ERIDU acceptance gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -14 --oneline

nvim --headless -u NONE -c "luafile tests/boundary_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effect_pipeline_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/instruction_event_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_pipeline_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/boundary_effect_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/boundary_effect_apply_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_collection_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/instruction_event_fact_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_index_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_effect_apply_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, accept the relay and audit stack/register orchestration
as the next likely ownership boundary.

## Accepted context-engine split tranches 42 and 43 (2026-11-14)

ERIDU accepted the boundary-effect and instruction-event pipeline coordinators
green, including the pre-gate register-read alias restoration.

Confirmed:

- boundary parser dispatch, pre-register replay, known-effect resolution and
  read/write phase semantics remain intact;
- real `mov rax, 60; mov rdi, 7; syscall` still resolves Linux `exit` from
  pre-instruction state;
- instruction-event parser dispatch, event identity, metadata and fail-closed
  behavior remain intact;
- real `call target; ret` still preserves ordered event facts and call operand
  metadata;
- existing boundary collection/apply and instruction-event collection/fact
  contracts remain green;
- the restored register-read alias is proven by `mov eax, 1; mov rbx, rax`,
  and the full x86 scalar alias-write suite remains green;
- stack, source-time memory replay, Inspect and adapter contracts remain green.

Accepted baseline: `bd1710e`.

## Context-engine split tranche 44 — register-effect pipeline (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/register_effect_pipeline.lua
~~~

This coordinator now owns the complete architecture-neutral register reduction
pipeline:

- register-effect index construction;
- source visibility and ordering;
- instruction-state preparation;
- alias-aware register reads during preparation;
- effect matching/application;
- canonical family/latest-state publication;
- final latest-fact reduction.

It exposes reusable `get_index`, `prepare_instruction_state` and
`apply_effect` helpers because the stack pipeline consumes intervening
register effects without owning register semantics.

Adapter instruction parsing remains injected.

New regressions:

~~~
tests/register_effect_pipeline_smoke.lua
tests/asm_register_effect_pipeline_smoke.lua
~~~

The parser-backed proof repeats the canonical EAX-to-RAX state followed by
`mov rbx, rax`, requiring RBX to receive exact
`0x0000000000000001`.

## Context-engine split tranche 45 — stack-effect pipeline (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

New module:

~~~
lua/tracker_hud/low_level/stack_effect_pipeline.lua
~~~

This coordinator owns the mixed stack/register traversal required for stack
inference:

- stack-effect index construction;
- register-effect index reuse through `register_effect_pipeline`;
- ordered/deduplicated union traversal;
- stack inference state;
- carried register-family/latest-fact state for intervening register effects;
- stack operand value resolution;
- stack fact application.

The stack operand path intentionally preserves its prior direct current-register
map behavior; it does not silently switch to the register pipeline's alias-aware
instruction-state resolver.

New regressions:

~~~
tests/stack_effect_pipeline_smoke.lua
tests/asm_stack_effect_pipeline_smoke.lua
~~~

The parser-backed proof requires `mov rax, 42; push rax` to keep producing a
resolved stack-push fact with value `42`.

## Context-engine cleanup produced by tranches 44 and 45

The context engine no longer directly owns:

- register-effect collection/processing/application;
- register-state read policy;
- register value parsing/policy;
- register operand-value inference;
- stack inference state preparation;
- stack index/collection/application;
- generic low-level inference state for these paths.

Public APIs remain unchanged:

- `collect_register_effects`
- `collect_stack_effects`

The context engine retains only the shared adapter instruction-source bridge and
cross-section composition of the already-owned pipelines/discovery modules.

## Static audit at pending head

`context_engine.lua`: 502 lines.

Expected markers:

- exact `register_effect_pipeline` require: 1
- exact `stack_effect_pipeline` require: 1
- direct `register_effect_processing` require: 0
- direct `register_effect_apply` require: 0
- direct `register_state_read` require: 0
- direct `stack_effect_collection` require: 0
- direct `stack_effect_apply` require: 0
- exported register entry point: 1
- exported stack entry point: 1

## Relay boundary after tranches 44 and 45

The planned architecture relay contains exactly ten commits on top of accepted
`bd1710e`.

During pre-gate static audit, the later stack delegation was found to have
crossed two replacement boundaries in `context_engine.lua`: it swallowed the
thin public `collect_register_effects` wrapper and duplicated the final module
return as `return Mreturn M`. Neither defect changed the new pipeline modules;
both would have prevented the context engine from loading correctly.

Correction `78bb310` restores the public register wrapper, repairs the final
return, and removes context-level rule-syntax/node-collection aliases that had
become dead after the pipeline moves. The corrected context engine is 502
lines, with register and stack public entry points each present exactly once.

### ERIDU acceptance gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -13 --oneline

nvim --headless -u NONE -c "luafile tests/register_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_pipeline_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/stack_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effect_pipeline_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_processing_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_state_write_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/stack_effect_collection_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_register_carry_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_boundary_effects_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, accept the relay and re-audit the now-thin context
engine for whether further extraction is justified at all.

## Accepted context-engine split tranches 44 and 45 (2026-11-14)

ERIDU accepted the register-effect and stack-effect pipeline coordinators green.

Confirmed:

- pure register pipeline indexing, immediate publication, carried register copy
  and fail-closed behavior remain intact;
- parser-backed canonical EAX-to-RAX state still feeds a later RBX copy with
  exact value `0x0000000000000001`;
- existing register processing, canonical state publication and full x86 scalar
  alias-write regressions remain green;
- pure stack mixed-index traversal, carried register value, source provenance
  and fail-closed behavior remain intact;
- parser-backed `mov rax, 42; push rax` still carries resolved value `42`;
- existing stack collection, push/pop behavior and register-carry regression
  remain green;
- boundary, source-time memory replay, Inspect and adapter contracts remain
  green.

Accepted baseline: `3182968`.

## Context-engine split campaign complete — stable facade boundary (2026-11-14)

**Status: stabilization relay pushed on main, pending ERIDU acceptance.**

After accepting tranches 44 and 45, the remaining context engine was audited by
ownership rather than size. No further reusable semantic subsystem remains.

The remaining responsibilities are intentionally top-level:

1. **Public compatibility facade**
   - construct/context helper exports;
   - branch-presentation exports;
   - line-summary policy forwarding;
   - the existing low-level public collection/discovery entry points.

2. **Shared adapter instruction-source bridge**
   - adapter parser dispatch;
   - fallback source extraction through `instruction_source`;
   - Tree-sitter node text callback wiring.

3. **Cross-section source-time composition**
   - register replay injected into source-time memory-address evaluation;
   - memory/register discovery supplied with the shared register index, parser
     bridge and address evaluator.

4. **Thin pipeline entry points**
   - register;
   - boundary;
   - instruction-event;
   - stack.

Moving any of these responsibilities again would either duplicate parser/source
bridge plumbing, hide cross-section dependencies inside a lower-level module,
or break the long-standing `context_engine` public compatibility surface.

Therefore the context-engine extraction campaign stops here.

Current `context_engine.lua`: 502 lines.

Current public callable contract: 37 entries.

### Stabilization regression

New regression:

~~~
tests/context_engine_facade_smoke.lua
~~~

It pins:

- all 37 established public callable names;
- representative line-summary forwarding;
- fail-closed behavior for all seven low-level collection/discovery entry
  points;
- construct parser/validation forwarding.

This test is intentionally a facade contract rather than an implementation
snapshot. Internal module ownership may continue evolving later without changing
the public compatibility surface.

### Small cleanup

The duplicated source-time bridge comment introduced by an earlier replacement
was reduced to one copy. No runtime behavior changed.

### ERIDU stabilization gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -5 --oneline

nvim --headless -u NONE -c "luafile tests/context_engine_facade_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_register_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_pipeline_smoke.lua" -c "qa!"

nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If this gate is GREEN, mark the context-engine split campaign complete and move
development back to foundational architecture features rather than further
facade decomposition.

## Accepted context-engine facade stabilization (2026-11-14)

ERIDU accepted the stable context-engine facade contract green.

Confirmed:

- all 37 public context-engine callables are present;
- line-summary forwarding remains intact;
- all seven low-level collection/discovery entry points fail closed;
- construct parser/validation forwarding remains intact;
- register, stack, boundary and instruction-event parser-backed pipelines remain
  green;
- source-time memory replay and Inspect certainty remain green;
- Lua/Python/C/C++ and ASM adapter contracts remain green.

Accepted baseline: `aea0fb1`.

The context-engine split campaign is complete. Further work returns to the
shared architecture-profile migration roadmap.

## Roadmap re-audit after context-engine stabilization (2026-11-14)

The original migration sequence was re-audited against the current tree rather
than followed by stale tranche number.

### Already landed beyond the original first tranche

The shared x86-64 profile now includes:

- architecture register families/static rows/alias index;
- language-independent platform declarations for Linux, Windows and Darwin;
- calling-convention declarations including SysV AMD64 and Linux syscall
  register convention;
- ABI-owned register-role overlays.

The ASM x86-64 adapter consumes those shared target facts while preserving its
existing public compatibility fields.

Therefore "begin architecture/ABI separation" is no longer the next missing
step.

### Still missing

There is no end-to-end HUD/cursor performance instrumentation or incremental
source-state checkpoint layer.

The existing `analysis_cache.lua` provides cache-window/visibility policy, but
does not record refresh timings, cache hits or replay work.

The existing `tests/architecture_alias_benchmark.lua` measures only alias
lookup and explicitly does not measure HUD redraw, Tree-sitter or instruction
replay.

### Next foundation tranche

Before designing checkpoints or moving additional ISA/effect ownership, measure
the existing refresh path.

New observational module:

~~~
lua/tracker_hud/analysis_profile.lua
~~~

It is opt-in and records existing work only.

Tracked phases:

- context analysis;
- source-state publication;
- HUD render;
- hex-width source refresh;
- total refresh.

Tracked refresh reasons include first refresh, cursor step/move/large jump,
edit and buffer enter.

Runtime command:

~~~
:HudProfile [show|on|off|reset]
~~~

Default configuration remains disabled.

Repeatable ERIDU procedure:

~~~
docs/performance_baseline.md
~~~

## Performance instrumentation tranche — pending ERIDU acceptance (2026-11-14)

**Status: pushed on main, pending ERIDU acceptance.**

This tranche is observational only.

It does **not**:

- add incremental caching;
- alter the 200-line cache-window policy;
- change ON/PAST visibility;
- change parser or adapter selection;
- change target/ABI semantics;
- change register/stack/boundary/event inference.

New files:

- `lua/tracker_hud/analysis_profile.lua`
- `tests/analysis_profile_smoke.lua`
- `tests/analysis_profile_report_smoke.lua`
- `docs/performance_baseline.md`

Changed:

- `lua/tracker_hud/config.lua`: opt-in profile defaults;
- `lua/tracker_hud/init.lua`: existing refresh phases bracketed with timing and
  `:HudProfile` command registered.

### ERIDU code gate

~~~
git status --short && ^
git pull --ff-only && ^
git log -11 --oneline

nvim --headless -u NONE -c "luafile tests/analysis_profile_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/analysis_profile_report_smoke.lua" -c "qa!"

nvim --headless -u NONE -c "luafile tests/context_engine_facade_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_stack_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_boundary_effect_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_instruction_event_pipeline_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_memory_address_evaluator_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_inspect_memory_target_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
~~~

If the code gate is GREEN, run the observational ERIDU scenario in
`docs/performance_baseline.md` and include the `:HudProfile` report before
choosing the checkpoint design.
