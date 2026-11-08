# Tracker_HUD C / C++ structural adapter baseline

Repository: `Ebdsaleh/Tracker_HUD` — `main` branch. This is an experimental feature tranche, **not** a new released version.

## Safety boundary

- New language-local adapters: `lua/tracker_hud/adapters/c/` and `lua/tracker_hud/adapters/cpp/`.
- Shared C grammar mappings; C++ adapter deep-copies and extends the C adapter.
- Loader discovers only each language's `init.lua`.
- No modifications to `context.lua`, `context_engine.lua`, ASM data, Python model collectors, HUD renderer, or user configuration.
- No new Git branches (only existing main/dev/test policy).
- C and C++ initially expose **Scope** / **Scope Members** / **Warnings** (not fabricated Registers/Heap/Object states).
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
3. Add conservative cursor-discovered C declaration/initializer and C++ class/member state facts only after the structural baseline is green.
4. Introduce a shared, bounded source-window cache without monkey-patching Neovim API functions or changing existing ASM semantics.
5. Add automated Tree-sitter-backed fixture assertions once a suitable Neovim test environment is available.

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
