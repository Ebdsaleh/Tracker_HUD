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
