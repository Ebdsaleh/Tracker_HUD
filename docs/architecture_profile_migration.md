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
