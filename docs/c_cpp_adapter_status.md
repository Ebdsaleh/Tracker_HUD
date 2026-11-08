# Tracker_HUD C / C++ structural adapter baseline

Repository: `Ebdsaleh/Tracker_HUD` — `main` branch. This is an experimental feature tranche, **not** a new released version.

## Safety boundary

- New language-local adapters: `lua/tracker_hud/adapters/c/` and `lua/tracker_hud/adapters/cpp/`.
- Shared C grammar mappings; C++ adapter deep-copies and extends the C adapter.
- Loader discovers only each language's `init.lua`.
- No modifications to `context.lua`, `context_engine.lua`, ASM data, Python model collectors, HUD renderer, or user configuration.
- The shared `visual_language.lua` now also styles Registers, Stack and Heap headings for **every** adapter exposing those sections, including ASM.
- No new Git branches (only existing main/dev/test policy).
- C and C++ now expose permanent **Scope / Scope Members / Registers / Events / Stack / Heap / Warnings** panels, following the ASM section order.
- Empty Registers/Stack/Heap panels **do not claim** real machine-register values, memory locations, allocations, or tracked ownership. These are ready-to-populate inspection surfaces, not leak detection.
- Architecture, ABI and platform remain **unknown** without source-supported evidence; syntax reports C or C++.
- Neovim's Tree-sitter C and C++ parsers are required.

## Implemented first pass

C: translation unit; function and compound-block scopes; structs, unions, enums, typedefs; declarations, fields, parameters; if/switch/case/else, loops, assignment, calls and return; preprocessor include/definition; identifiers and scalar literals.

C++: all shared C constructs plus namespaces, classes, templates, access specifiers, type aliases/using declarations, lambdas, range-for loops, reference declarators, new/delete expressions, throw, try, and co_return.

Use `samples/c/c_adapter_validation.c` and `samples/cpp/cpp_adapter_validation.cpp` for manual checks. For shape/registration smoke test:

```bat
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
```

The smoke test also covers existing Lua and Python adapter contract/registration. It does not assert Tree-sitter parser availability or interactive rendering.

## Discovery and cache policy

The ASM discovery contract remains the reference: **ON or PAST the source line → visible; before source line → hidden**. Future C/C++ semantic events must use that same rule; no eager future fact should be rendered.

`:HudCacheLimit on` currently configures the *intended initial window* of 200 lines; `:HudCacheLimit off` disables the limit and a positive integer sets a custom limit. The shared helper exists, but the complete persistent file-open cache and adapter-wide lazy expansion are **not implemented yet**. Do not claim C/C++ large-file performance is solved by adding these structural adapters.

## Next validation-driven tasks

1. Physically confirm parser registration and scope/member output on both fixtures.
2. Fix C/C++ structural edge cases in adapter-local code only: nested class owners, declarator names, headers, methods, parameters, source-range visibility.
3. Implement conservative cursor-discovered C declaration/initializer and C++ class/member state facts **after** structural baseline acceptance.
4. Implement memory-allocation/lifetime facts and path-aware leak diagnostics, with evidence and clear unknown states.
5. Introduce a shared, bounded source-window cache without monkey-patching Neovim API functions or changing existing ASM semantics.
6. Run the existing Tree-sitter-backed fixture test on ERIDU before expanding inference.

Do not infer pointer targets, aliasing, heap validity, object construction/destruction effects, or template instantiations without evidence. Accuracy and graceful unknown state are preferred to guesses.

## Second tranche — validated mappings (2026-11-08)

The registration/schema test passed on ERIDU for Lua, Python, C and C++.
This does **not** yet prove C/C++ HUD behavior; physical Neovim validation
is still pending.

Focused adapter-local repairs:

- C and inherited C++ parameter names are now read from
  `parameter_declaration.declarator` using the existing symbol collector
  rather than emitting the whole parameter declaration text.
- C++ also maps `optional_parameter_declaration.declarator` and
  `variadic_parameter_declaration.declarator` to parameter members.
- C `struct_specifier`/`union_specifier`, and C++ `class_specifier`/
  `namespace_definition`, no longer disappear from Scope Members because
  `parent_lexical` symbol rules are skipped by the shared collector.
  The interim mapping is `lexical`, without claiming precise
  parent-scope ownership. Scope itself still represents lexical ancestry.
- Added a C++ default-argument case to the validation fixture.
- Added `tests/c_cpp_parser_smoke.lua` to exercise real Tree-sitter AST
  nodes, construct parsing, member collection, and ON/PAST discovery.

Run from the repository root:

```bat
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
nvim samples/c/c_adapter_validation.c
nvim samples/cpp/cpp_adapter_validation.cpp
```

Use **normal Neovim startup** for parser-backed testing, since
`-u NONE` may omit the parser installation runtimepath. Missing parsers
are reported explicitly, not silently skipped.

The C/C++ parser-backed test was added in GitHub but has not yet been run
on the user's ERIDU Neovim. Report its actual output before claiming
physical parser acceptance. Do not overwrite already-working ASM/Python
behavior just to work around a C++ declarator edge case.


## Third tranche — persistent memory surfaces and low-level colours (2026-11-08)

The HUD now exposes the same seven sections for ASM, C, and C++, regardless
of whether each category has discovered a source fact:

1. Scope
2. Scope Members
3. Registers
4. Events
5. Stack
6. Heap
7. Warnings

C++ inherits the C adapter's section descriptors by deep copy. ASM retains
its own existing section descriptors and source-index configuration.

The shared `visual_language.lua` maps Registers to cyan (`#7DCFFF`),
Stack to teal (`#73DACA`), and Heap to orange (`#FF9E64`).
These are existing semantic palette hues, not new language-specific styling.
The same named heading and statusline styles work in ASM and C/C++; plain
mode remains colourless, with a neutral active-title underline. The
selected-header background and HUD statusline remain charcoal
(`#2D3138`). Events keeps the established `Target:` purple, Scope blue,
Scope Members green, and Warnings amber. This documents **defaults**; user
themes are a future feature, not implemented here.

Added/extended tests:

```bat
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
```

The schema/section tests check the seven-section order across configured
ASM/C/C++ adapters and Inspect Mode cycling. The visual test checks the
three new heading and statusline colours plus plain-mode compatibility.
The real-parser test requires installed Tree-sitter C and C++ parsers.
Physical ERIDU acceptance is pending for this tranche.

### Planned memory-lifetime analysis — accuracy contract

**Visible at cursor, not at file open:** each allocation, release,
assignment or ownership effect is presented only ON or PAST its source line.
The static index may cache later syntax, but must not reveal future state.

**Data model:** track allocation sites separately from variables/pointers,
with size expression if known, allocator family, source location, current
owners/aliases when provable, and one of:
`allocated`, `released`, `escaped`, `unknown`, or `possible leak`.
Do not make a pointer's non-nullness alone evidence of heap ownership.

**C:** recognise `malloc`, `calloc`, `realloc`, `free`,
local automatic storage, explicit pointer assignments and calls with
ownership semantics where known. In particular, `realloc` failure must
not imply the original allocation was freed.

**C++:** distinguish `new`/`delete` and `new[]`/`delete[]`,
constructor/destructor effects where provable, RAII ownership
(`unique_ptr`, container-held allocations), and escapes/returns.
Avoid treating a `std::unique_ptr`-owned object as unfreed just because
no explicit `delete` appears in source.

**Diagnostics:** report an unfreed allocation only after sufficient control
flow has been inspected and at a meaningful **scope/function exit**, not
merely because the cursor reached physical end-of-file. If different
branches permit both release and non-release, label a **possible leak**.
Returned or escaped pointers may transfer ownership; unknown calls are
unknown rather than free or leak. Do not claim physical register values or
stack addresses from C/C++ source alone.

**Required negative controls:** local non-heap pointers, null allocations,
all properly freed paths, ownership returned to callers, RAII, deliberate
ownership transfer, macros/indirect calls with unknown effects, and
source edits that invalidate cached analyses.

Only after these fixtures pass should the Heap or Warnings sections emit
ownership/leak facts. The present tranche deliberately changes section
availability and colours **only**, not semantic memory tracking.

## ERIDU parser-backed test finding (2026-11-08)

User's physical ERIDU results at commit `631e1bb`:

- `tests/adapter_contract_smoke.lua` **PASS**, including C/C++ and configured ASM
  seven-section order / Inspect Mode cycling.
- `tests/section_inspect_colors_smoke.lua` **PASS**, including all seven default
  header/statusline colours and plain mode.
- `tests/c_cpp_parser_smoke.lua` **FAIL** after C real-syntax construct checks
  passed: `c declared member missing from collector: Counter` at its
  `expected_member_names` assertion.

Do not mark the C/C++ member collector as accepted or begin leak inference.
The C fixture uses `typedef struct Counter { int value; } Counter;`.
The installed grammar defines both `struct_specifier.name` and
`type_definition.declarator`, but we do **not yet know** whether this
particular ERIDU parser AST omits the field, yields a different name,
or the generic member walker fails to emit it. Avoid changing grammar
fields speculatively.

The parser-backed test now includes diagnostics listing **actual collected
members and their source lines/depths**, alongside matching raw AST name/
declarator fields. It also executes the C and C++ fixture checks
independently in the same invocation, aggregating failures without
suppressing a non-zero test result.

Next validation step (ERIDU, normal Neovim startup with C/C++ parsers):

```bat
git pull --ff-only
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
```

Read both actual C/C++ collector/AST diagnostics, fix the smallest supported
cause with a regression test, and rerun both parser and contract tests.
The schema/visual smoke tests need not be rerun unless affected source
changes. Preserve the failing `Counter` assertion rather than removing
or weakening it.


## Correction — real Neovim TSNode field API (2026-11-08)

At ERIDU commit `6ce6029`, the diagnostics failed in both languages with:

```text
PASS c parser constructs mapped from real syntax
FAIL c ... attempt to call method 'child_by_field_name' (a nil value)
PASS cpp parser constructs mapped from real syntax
FAIL cpp ... attempt to call method 'child_by_field_name' (a nil value)
```

The diagnostic was incorrectly calling a non-existent Neovim TSNode method.
Audit then found the **same defect** in the shared
`treesitter_utils.get_child_by_field_name` function. Neovim provides
`node:field(name)` returning a **list** of child nodes. The helper now
returns its first child, while retaining a fallback for older mock-node
fixtures implementing `child_by_field_name`. This is a targeted API
compatibility correction, not a change to scope-discovery policy.

The C/C++ parser smoke now:
- Calls the corrected shared field-access helper in raw AST diagnostics;
- Builds expensive failure descriptions only **after** detecting a failed
  assertion, rather than as eagerly evaluated `assert` arguments;
- Always prints `COLLECTED c (...): ...` and `COLLECTED cpp (...): ...`
  with kind/name/line/depth, before the member checks;
- Keeps the exact names and ON/PAST discovery assertions, runs both
  language fixtures, and exits nonzero on any failure.

A separate `tests/treesitter_field_access_smoke.lua` test covers both
Neovim's list-returning field API and old mock compatibility without
requiring installed parsers.

**Current validation status:** the fix is on GitHub `main`, but ERIDU has
not yet run the corrected smoke tests. Do not claim that the parser failure
or other member issues are resolved until those results arrive.

```bat
git pull --ff-only
nvim --headless -u NONE -c "luafile tests/treesitter_field_access_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
```

The contract and visual tests were already green on ERIDU and should be
rerun only if the updated shared field helper causes a regression. Keeping
the upcoming C/C++ allocations/leaks work gated on parser acceptance remains
the correct priority.


## Fourth tranche — grammar-specific member recovery (2026-11-08)

Physical ERIDU testing of `def2680` exposed a deeper collector failure:

```text
PASS c parser constructs mapped from real syntax
COLLECTED c (0): <empty collection>
FAIL c ... declared member missing from collector: Counter
  AST fields: <no matching named AST declarator>
PASS cpp parser constructs mapped from real syntax
COLLECTED cpp (1): assignment:value_@20(depth=6)
FAIL cpp ... declared member missing from collector: tracker_hud_sample
  AST fields: <no matching named AST declarator>
```

This means the syntax constructs were recognised, but source bindings were
not. The previous direct `TSNode:field(name)` correction did **not** close
member discovery on ERIDU and should not be reported as sufficient.

This tranche retains named-field lookup as the preferred path and adds
adapter-authorized **AST node-type fallbacks** when a name is absent. These
are not source-text regular expressions or made-up values:

- **C**: `type_identifier` for struct/union/enum names;
  `identifier` for parameters, declarations, initializers and functions;
  `field_identifier` for struct fields.
- **C++**: `namespace_identifier` for namespace names;
  `type_identifier` for classes and aliases;
  `identifier` for C++ defaulted/variadic parameters and range-for variables.
- **Shared collector**: field declarations and function-name extraction now
  consult `syntax.children.name` if direct AST fields fail. The symbol
  collector already supports this precise fallback. ASM/Python adapters
  without new fallback declarations retain their prior behaviour.
- **Tests**: contract smoke now asserts the exact configured fallback types.
  C/C++ parser smoke retains every required name and ON/PAST assertion.
  If a symbol remains missing, it reports a bounded AST `sexpr` and
  observed child-field names as well as the collected member list.

The `Counter` and `tracker_hud_sample` expectations have **not** been
deleted, disabled or weakened. These changes have been source-reviewed on
GitHub, but require ERIDU's actual Neovim parsers for confirmation.

Next acceptance commands, from repository root:

```bat
git pull --ff-only
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
```

Do not advance to heap allocation/ownership inference unless both pass.
If either parser test fails, use the `AST layout:` evidence to distinguish
grammar shape differences from collector omissions, then fix the
minimal concrete cause. The visual and seven-section tests passed earlier
and were not modified in this tranche.


## Fifth tranche — C/C++ source-observed Heap operations (2026-11-08)

ERIDU **confirmed** all parser-backed C/C++ member assertions green at
`aa292b0`: C discovered 15 members and C++ discovered 28, including
source-line ON/PAST discovery. This closes the prior empty-member failure
but does **not** imply complete C/C++ inference.

Next experimental capability, committed to `main` but still awaiting
ERIDU validation:

- `lua/tracker_hud/adapters/c/memory_facts.lua` inspects actual parsed
  source expression nodes up to (and including) the cursor line.
  It observes direct identifier calls named `malloc`, `calloc`,
  `realloc`, `free`; C++ additionally observes `new_expression` and
  `delete_expression`.
- `context.lua` calculates these facts once for C/C++ only, before
  collecting Events and Heap. ASM, Lua and Python are not opted in.
- The existing **Events** section displays a source memory observation
  for each discovered site. The existing **Heap** section displays
  `allocation site`, `release site`, or `resize site` entries
  together with expression text, source location, and explicitly unknown
  success/ownership/leak status.
- The pass is pruned at the cursor; source comments, string literals,
  indirect/qualified calls, and macro expansions are not treated as
  observed direct heap operations. There is no source-text regex scanner.
- New C/C++ fixtures in `samples/c/*memory_observation_validation.c`
  and `samples/cpp/*memory_observation_validation.cpp` cover the
  initial direct syntax. They are small and safe to inspect in Neovim.
- New parser-backed smoke
  `tests/c_cpp_memory_observation_smoke.lua` checks expected operations,
  cursor-line boundary, absence of future facts, non-invented state, and
  Events/Heap presentation. It should exit nonzero on regression.

### Nonclaims and next step

This tranche does **NOT** track pointer values, resolve which `malloc`
definition a call binds to, identify allocation success, infer actual
releases, detect leaks, or emit warnings. The label is a **source site**,
not an allocation or deallocation proven to have occurred. `realloc`
is marked as a resize site, never as an unconditional free. C++ RAII,
ownership transfers, aliases, escaped allocations and branch-aware exit
analysis are required before trustworthy leak warnings can be enabled.
Do not claim C/C++ allocation-lifetime analysis is complete.

The shared Heap label/detail renderer changed additively, retaining
existing ASM entries. Regression gates on ERIDU:

```bat
git pull --ff-only
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_memory_observation_smoke.lua"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"

nvim samples/c/c_memory_observation_validation.c
nvim samples/cpp/cpp_memory_observation_validation.cpp
```

The new memory observation tests are **not yet verified** on the user's
Neovim runtime. Keep the earlier green parser tests and avoid adding
leak warnings until this tranche is accepted.


## Sixth tranche — C/C++ source-file target directives (2026-11-08)

Added the same strict **source-file target metadata** mechanism used by ASM,
without introducing a separate loose C/C++ parser. C and C++ recognize
the five ASM-compatible directive names on column-zero `//` lines:

```c
// arch=x86-64;
// platform=windows;
// abi=win64;
// syntax=c;
// mode=compiled;
```

For C++, use `// syntax=cpp;`. Each directive must have **one space**
after `//`, no spaces surrounding `=`, a final `;`, and appear within
the **first 20 source lines**. The scanner and malformed-line diagnostics
come directly from `tracker_hud.directive_utils` via
`adapters.variant_utils`, as in ASM.

Implementation:

- `lua/tracker_hud/adapters/c/target_directives.lua` resolves
  `architecture`, `platform`, `abi`, `syntax`, `mode` in
  source > `config.targets` > defaults order. It supports the same common
  `x64`, `amd64`, `x86_64` aliases to `x86-64`.
- `adapters/c/adapter.lua` and `adapters/cpp/adapter.lua` each configure
  their own active targets on each buffer. C++ **must not** inherit C's
  Lua closure capturing the C adapter table.
- `syntax` is tied to the buffer's actual C/C++ parser; a conflicting
  source directive emits a diagnostic and is not permitted to silently
  switch the parser. Unknown architecture/platform/ABI remain unknown
  until declared or configured. Other target strings are metadata,
  not compiler/ABI validation or runtime inference.
- Both structural and memory-observation source samples now declare
  target metadata at the top. Examples use the Windows x86-64 target
  for ERIDU; callers can change values for a cross-compilation target.
- `tests/c_cpp_source_directives_smoke.lua` verifies valid directives,
  source-over-config precedence, defaults, architecture aliases,
  malformed/missing terminator diagnostics, first-20-lines restriction,
  cross-language isolation, and syntax mismatch warnings. No Tree-sitter
  parser needed for that particular smoke test.

**Acceptance pending on ERIDU:** although source edits have been
verified on GitHub, the C/C++ target directive tests (and new Heap
observation tests from tranche five) are **not** yet reported green.
Preserve previous C/C++ member collector results (15 C, 28 C++).

Next run:

```bat
git pull --ff-only
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
nvim --headless -u NONE -c "luafile tests/c_cpp_source_directives_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
nvim --headless -c "luafile tests/c_cpp_memory_observation_smoke.lua"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
```

Inspect `samples/c/c_adapter_validation.c` and
`samples/cpp/cpp_adapter_validation.cpp` to confirm the HUD's
`Target:` line shows the declared metadata. The memory-observation
facts must remain source-only and must not trigger leak warnings.


## Seventh tranche — preserve inactive heading identity (2026-11-08)

ERIDU verified the parser-backed C/C++ member test again at `41d544b`:
C 15 members, C++ 28 members, both ON/PAST cursor checks green. The
screenshots show the selected headings and `Inspect:` segment in the
new garnet/gold/copper palette, but the inactive low-level heading
colours are too muted because source `contextual`/`historical`
relevance also applied to the section title.

Changed **only shared visual presentation**:
- `visual_language.section_heading_relevance`: root-title relevance
  is `inspecting` when selected and `section_idle` otherwise.
- `hud.build_section_header_line`: retain source relevance for
  markers/fact rows, but set the title span to its own heading
  relevance. This prevents source history from washing out section
  colour identity.
- `section_idle` uses 12% blending toward the existing muted target
  for explicit RGB title accents; linked colourscheme titles retain
  their theme hue. No inactive underline, italic, highlight bar or
  marker changes. Selected titles retain full hue, bold underline,
  and charcoal bar; the neutral `Inspect:` prefix and statusline
  remain unchanged.
- Extended `tests/section_inspect_colors_smoke.lua` to check inactive
  contrast-to-base, distinct identities, Inspect isolation, and
  plain-mode behaviour.
- Updated `docs/visual_language.md`. The mapping is shared by ASM,
  C and C++ and will remain theme-customisable.

**Validation:** source pushed to `main`; ERIDU has not yet run these
new highlight tests. Re-run:

```bat
git pull --ff-only
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
```

Visual check: open `samples/cpp/cpp_adapter_validation.cpp` and cycle
`Inspect:` modes. Confirm all seven headings keep their identity hue
when inactive, with only the selected title underlined/charcoal-band
highlighted. Then try ASM to verify shared styling.

**Unverified earlier work:** the parser-independent
`tests/c_cpp_source_directives_smoke.lua` and parser-backed
`tests/c_cpp_memory_observation_smoke.lua` have not yet been reported
green by ERIDU. Do not infer lifetime or leak correctness from the
C/C++ source-observation feature.
