# C adapter validation (structural MVP)

Open from the Tracker_HUD repository root:

```bat
git pull --ff-only
nvim samples/c/c_adapter_validation.c
```

The Neovim Tree-sitter `c` parser must be installed (for compatible nvim-treesitter setups, `:TSInstall c`). Filetype must be `c`; check with `:set filetype?`. Start a **fresh** Neovim process after pulling.

## Source-file target directives (same mechanism as ASM)

The validation files begin with **strict comment directives**. They are
parsed by the existing Tracker_HUD directive scanner, not by the compiler:

```c
// arch=x86-64;
// platform=windows;
// abi=win64;
// syntax=c;
// mode=compiled;
```

Each `//` must begin at **column zero**. The exact directive form is
`// key=value;`, with **one space** after `//`, no spaces around `=`,
and a mandatory final `;`. Directives must appear in the first **20 lines**.

The source file's values override `config.targets`; configuration
otherwise overrides the conservative defaults. An incompatible
`syntax` value is diagnosed and **cannot** switch the Tree-sitter parser.
`arch`, `platform`, `abi`, and `mode` are declared source metadata,
not facts inferred from compiled output. Without explicit target data,
architecture/platform/ABI stay `unknown`. No compiler flags or program
behaviour are changed by these comments.

Quick no-parser acceptance test:

```bat
nvim --headless -u NONE -c "luafile tests/c_cpp_source_directives_smoke.lua"
```

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

## Parser-backed source and discovery test

After the schema smoke test, run with your **usual** Neovim configuration,
so nvim-treesitter can load its installed C and C++ parsers:

```bat
nvim --headless -c "luafile tests/c_cpp_parser_smoke.lua"
```

This test parses real C/C++ fixtures, checks construct kinds, verifies C
parameter binding names (e.g. `amount`, not `int amount`), checks that
struct/class/namespace symbols are emitted, and proves declarations are
hidden before their line and appear **ON** their source line.

The parameter binding collector uses Tree-sitter's `declarator` field; a
pointer declarator may still display `*counter`, because the shared
collector does not yet normalise nested declarator shapes. It must never
invent pointer values or change runtime state.
