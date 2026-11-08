# C adapter validation (structural MVP)

Open from the Tracker_HUD repository root:

```bat
git pull --ff-only
nvim samples/c/c_adapter_validation.c
```

The Neovim Tree-sitter `c` parser must be installed (for compatible nvim-treesitter setups, `:TSInstall c`). Filetype must be `c`; check with `:set filetype?`. Start a **fresh** Neovim process after pulling.

## Verify in the HUD

- On the `typedef struct Counter` declaration, **Scope** should recognize a `Struct`, not an ASM instruction.
- Within `int value;`, the struct's lexical scope and a field/declaration construct should be available.
- On `advance(...)`, look for **Function**, function parameter declarations, and the owning scope.
- In `if (amount > 0)`, look for **If**, a lexical `Block` when in braces, and local Scope Members.
- On `counter->value = ...`, look for an **Assignment** construct.
- On `return` and `advance(&counter, 3)`, look for **Return** and **Call**.
- No register, heap, or pointer-value tracking is claimed for this first C pass.

No future execution state should be invented. Structural Tree-sitter nodes may contain a complete source range for navigation, but that is **not** evidence of future code having executed.

## Schema/registration smoke check

```bat
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
```

This check covers Adapter Contract v1, registration, and C/C++ separation. It does not replace manual parser/HUD checks.
