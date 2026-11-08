# C++ adapter validation (structural MVP)

Open from the Tracker_HUD repository root:

```bat
git pull --ff-only
nvim samples/cpp/cpp_adapter_validation.cpp
```

The Neovim Tree-sitter `cpp` parser must be installed (for compatible nvim-treesitter setups, `:TSInstall cpp`). Filetype must be `cpp` (check `:set filetype?`). Reopen Neovim after pulling.

## Verify in the HUD

- On `namespace tracker_hud_sample`, **Scope** should show **Namespace**.
- On `class Counter`, **Scope** should show **Class** and preserve its owning range through method bodies.
- On `void add(int amount)` and `int value() const`, watch **Function**, parameters, and lexical blocks.
- On `template <typename T>` and `[](int n) { ... }`, see **Template** and **Lambda** constructs.
- On `for (int item : items)`, see **Range For**.
- On `using`, aliases, `new`, `delete`, and `try` (in your own sources), the corresponding constructs should be recognized.
- Basic C declarations, structs, calls, returns and assignments should still be recognized from the inherited C grammar subset.

This is source-structure inspection, **not** a compiler, debugger, lifetime analyzer, or C++ object-state predictor. Templates, overloads, constructor effects, ownership, pointer aliasing and runtime values are not inferred yet.

## Schema/registration smoke check

```bat
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
```

The test checks registered shapes but cannot prove actual HUD rendering; please validate in the real Neovim environment.
