# Adapter target dimensions and language-version bundles

**Status:** architectural design contract; implementation is intentionally incremental.

This document records the naming and composition rules for adapter-selected
semantic dimensions. The core principle is:

> **The selection mechanism is generic, but its vocabulary is adapter-owned.**

Tracker_HUD must not flatten unrelated concepts into one universal
`variant` field. Each ecosystem should use the terminology that its users
already use, while the shared context engine treats those dimensions as
independent semantic coordinates.

## Dimension meanings

These names are not interchangeable:

```text
language
    Source-language family.
    Examples: cpp, c, asm, lua, python

standard
    A language-standard edition when that ecosystem uses standards as its
    normal versioning vocabulary.
    C++ examples: cpp98, cpp03, cpp11, cpp14, cpp17, cpp20, cpp23

variant
    An adapter-owned machine / ISA / processor-family variant when
    "standard" would be misleading.
    ASM examples: i386, x86_64, m68000, sh4, armv7, aarch64

syntax
    Source notation / assembler dialect / grammar presentation.
    ASM examples: nasm, gas, masm, intel, motorola

platform
    Operating system, console, machine environment, or other deployment
    platform. This must not be confused with the processor/ISA variant.
    Examples: windows, linux, nes, snes, megadrive, saturn, dreamcast

abi
    Calling convention or binary interface where meaningful.
    Examples: win64, sysv, linux_syscall

mode
    Execution / assembler / compilation mode where meaningful.
    Examples: long64, protected32, real16, compiled

dialect
    Optional language/compiler extension layer where the ecosystem needs it.
    This is separate from the ISO language standard.
    Possible future C++ examples: msvc71, gnu, clang
```

The adapter declares which dimensions it understands. A dimension is not
globally mandatory merely because another adapter uses it.

## C++ policy

For C++, use the ecosystem term **standard**.

Planned source intent:

```cpp
// language=cpp;
// standard=cpp17;
```

The built-in C++ adapter remains the `cpp` language-family adapter. The
selected standard supplies the language-version semantic bundle.

The intended default is:

```text
language = cpp
standard = cpp17
```

unless the source/config explicitly selects another supported standard.

The design must support both forward and backward selection. A C++20
selection may add C++20 semantics, while a C++98 selection must suppress
C++11-and-later semantics even if the installed Tree-sitter grammar can parse
them.

Tree-sitter parse capability is therefore **not** language-standard
authorization.

Example:

```text
lambda_expression
    available since cpp11

active standard = cpp98
    -> syntax may parse
    -> C++11 lambda semantics are not activated
    -> a future diagnostic may report that the construct requires C++11+

active standard = cpp17
    -> C++11 lambda semantics are available
```

The same rule applies to the C++20 range-for init-statement that exposed this
design requirement: ordinary range-for is available from C++11, while a
range-for init-statement is a C++20 feature and must not silently enter the
C++17 default bundle.

### C++ standard composition

Do not duplicate complete adapters per standard. Prefer cumulative semantic
bundles / overlays.

Conceptually:

```text
cpp98 = common C++ family semantics + cpp98 availability
cpp03 = cpp98 + cpp03 additions/changes
cpp11 = cpp03 + cpp11 additions/changes
cpp14 = cpp11 + cpp14 additions/changes
cpp17 = cpp14 + cpp17 additions/changes
cpp20 = cpp17 + cpp20 additions/changes
cpp23 = cpp20 + cpp23 additions/changes
```

The exact implementation may use overlays, availability filters, or compiled
bundles, but selecting an older standard must produce a genuinely older
semantic surface rather than an additive "latest C++" adapter.

Semantic declarations should carry availability metadata rather than being
copied into every bundle. Preferred vocabulary:

```lua
availability = {
    language = "cpp",
    since = "cpp11",
    until = nil,
}
```

For bounded or discontinuous availability:

```lua
availability = {
    language = "cpp",
    since = "cpp98",
    until = "cpp17",
}
```

or, when a range cannot express the rule cleanly:

```lua
availability = {
    standards = {
        "cpp98",
        "cpp03",
    },
}
```

Internally a resolved standard may compile a `bundle` of applicable
declarations, but `bundle` is composition machinery rather than the
user-facing ecosystem term.

### C++ standard vs compiler dialect

A language standard and compiler-specific behavior are separate dimensions.

A future legacy toolchain target may need:

```text
language = cpp
standard = cpp98
dialect = msvc71
```

This allows Tracker_HUD to model an old MSVC-era codebase without pretending
compiler extensions or limitations are ISO C++98 semantics.

## ASM policy

For assembly, use **variant**, not `standard`, for the processor/ISA
selection.

Conceptual source intent:

```asm
; language=asm;
; variant=x86_64;
; syntax=nasm;
; platform=linux;
; abi=sysv;
; mode=long64;
```

Another target may be:

```asm
; language=asm;
; variant=m68000;
; platform=megadrive;
; syntax=motorola;
```

The processor/ISA variant and the platform are independent.

Correct:

```text
language = asm
variant = m68000
platform = megadrive
```

Incorrect:

```text
variant = megadrive
```

because Mega Drive is the target platform, not the processor variant.

Likewise Windows/Linux are platforms; they are not x86/x86-64 variants.

The current ASM implementation already has an `architecture` / `arch`
target field and an internal architecture variant mechanism. Future
terminology migration must preserve compatibility deliberately rather than
silently changing existing directives. This document records the desired
semantic distinction; it does not claim the `variant=` directive is already
implemented.

An internal architecture-family relationship may still be useful:

```text
architecture family = x86
variant = i386

architecture family = x86
variant = x86_64

architecture family = m68k
variant = m68000
```

Users should not be forced to provide both when the selected variant already
implies its family.

## Adapter-owned dimension declarations

The shared engine should support a generic declaration of selectable
dimensions while leaving names and accepted values to each adapter.

Conceptually:

```lua
-- C++
dimensions = {
    standard = { default = "cpp17", ... },
    platform = { ... },
    abi = { ... },
    dialect = { ... },
}

-- ASM
dimensions = {
    variant = { ... },
    syntax = { ... },
    platform = { ... },
    abi = { ... },
    mode = { ... },
}
```

Do not force C++ to call `cpp17` a variant when its ecosystem calls it a
standard. Do not force ASM to call `x86_64` a standard when its ecosystem
treats it as an architecture/ISA variant.

Other languages may use other ecosystem-native dimensions. For example a
future Python adapter may prefer `version` and `implementation`.

## Resolution and cache identity

Every dimension that can alter semantics must participate in configured
adapter identity / invalidation.

Changing:

```text
cpp17 -> cpp20
```

must re-resolve semantic availability even though Neovim filetype and the
Tree-sitter parser remain `cpp`.

Changing:

```text
x86_64 -> i386
```

must likewise re-resolve ASM semantics even if the source filetype remains
assembly.

No configured-adapter cache may reuse semantic state across incompatible
dimension selections.

## Diagnostics

A parser recognizing a construct outside the selected semantic bundle is not
proof that the construct belongs to the active target.

Future diagnostics may report:

```text
C++20 construct encountered
active standard: C++17
requires: C++20 or later
```

This is preferable to silently applying later-standard semantics.

## Current implementation boundary

As of this decision, the C/C++ source-target implementation still resolves:

```text
architecture
platform
abi
syntax
mode
```

and the ASM implementation still uses its existing architecture/variant
machinery and `arch` source directive.

The following are **design decisions, not yet implemented API**:

- C++ `language=` / `standard=` source directives;
- C++ standard bundles and availability filtering;
- default `cpp17` standard resolution in the context engine;
- ASM user-facing `variant=` terminology;
- compiler/dialect overlays such as `msvc71`;
- diagnostics for syntax parsed outside the selected standard/variant bundle.

Implement these incrementally with test-first checkpoints. Do not bypass the
existing strict directive scanner or silently reinterpret current target
fields.

## Locked design rules

1. Use ecosystem-native terminology.
2. Keep language family, language standard/version, ISA variant, syntax,
   platform, ABI, mode, and compiler dialect semantically separate.
3. C++ uses `standard`; built-in default is intended to be `cpp17`.
4. C++ standard selection must regress as well as advance.
5. ASM uses `variant` for ISA/processor selection; `platform` stays the
   OS/console/machine environment.
6. Parser capability does not select semantic availability.
7. Prefer availability metadata and composed bundles over duplicated adapters.
8. Semantic dimensions participate in cache identity/invalidation.
9. Adapter-owned vocabulary sits on top of shared generic selection machinery.
10. Preserve compatibility deliberately when migrating existing directive
    names or target fields.
