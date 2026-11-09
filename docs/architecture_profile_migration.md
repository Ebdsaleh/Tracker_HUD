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
