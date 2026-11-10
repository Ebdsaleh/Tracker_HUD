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
git log -12 --oneline
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
git log -12 --oneline

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
