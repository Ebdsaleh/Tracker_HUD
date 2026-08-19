# Tracker_HUD

By [@Ebdsaleh](https://github.com/Ebdsaleh)

**Current release:** `v0.7.7`  
**Current documented snapshot:** `post-v0.7.7` development snapshot

Tracker_HUD is an experimental Neovim plugin that provides a live, cursor-aware code-analysis HUD.

It is built around a **Tree-sitter-first, declarative-adapter architecture**:

```text
Tree-sitter
    -> tells Tracker_HUD what syntax exists

Adapter
    -> tells Tracker_HUD what that syntax means

Tracker_HUD core
    -> turns those facts into scopes, members, state trees, warnings, visual cues, and source-side inspection behavior
```

Tracker_HUD is not intended to be a normal LSP replacement. Its main goal is to act as an **accessibility-first state tracker**: it shows what the program or machine state means at the current cursor position so the user does not need to hold the whole mental model in working memory.

The current implementation is still experimental, but the architecture has become substantially more structured. The built-in Lua adapter is the reference high-level-language adapter. The ASM adapter currently has the deepest low-level support through its x86-64 variant.

> **Current status:** experimental but usable. The supported display path is the docked panel. Lua supports structural scope/member inspection. ASM/x86-64 uses Adapter Contract v1, target directives, categorized mnemonic-indexed datasets, occurrence-aware register inspection, instruction Events, Stack effects, syscall boundary effects, Heap routing, conservative Warnings, and semantic visual-language rendering.

The long-term direction is a systems-programming analysis HUD: complete the low-level ASM model first, then extend the same adapter-driven state-tracking architecture toward C/C++ pointer/allocation/lifetime state and Rust ownership/lifetime information.

---

## Design goals

Tracker_HUD is designed to answer questions like:

```text
Where am I?
What token/operand/scope am I touching?
What role does it play?
What state exists because of code up to this cursor position?
What changed?
What is unresolved?
What warnings need attention?
```

The project deliberately favors:

- cursor-truth over line guessing
- state-truth over generic syntax help
- declarative adapter specs over hardcoded language behavior
- reusable section/model/tree infrastructure
- semantic visual language over random coloring
- low-color and monochrome survivability
- accessibility through stable, repeated terminology

---

## Features

### Core HUD

- Tree-sitter-powered cursor context tracking
- Docked panel display
- Panel positions: `left`, `right`, `top`, and `bottom`
- Launch-time automatic panel sizing
- Runtime panel resizing and repositioning
- Panel focus restoration so Tracker_HUD does not steal source focus
- HUD panel closes with the tracked source window
- Interactive expandable/collapsible HUD trees
- `<CR>` panel-row toggling
- Double-click panel-row toggling
- Stable current-line, current-scope, and depth status information
- Adapter-driven section layout and Inspect Mode order
- Shared presentation/model/tree infrastructure for reusable section families
- Shared semantic detail rendering through the section-tree/lookup-tree path
- Semantic highlight spans resolved at the final HUD render boundary
- Renderer-agnostic visual-language tables for future text/ASCII/graphical modes

### Source-side Inspect workflow

- Active Inspect Mode shown in the HUD statusline
- Configurable Inspect Mode cycling
- Configurable source-side Inspect action
- Symmetric Inspect toggling: if `<leader>t` can expand/reveal a target, the same action can collapse it
- Tree-aware expand-all / collapse-all for supported Inspect modes
- Column-aware Scope Members inspection
- Occurrence-aware Registers inspection
- Registers semantic state updates proactively as the source cursor moves
- Register expansion/collapse state is independent from current occurrence semantics
- Mnemonic inspection represents **operation effects**
- Operand inspection represents the exact **operand occurrence and role**
- Operand separators/gaps preserve the most recently reached semantic occurrence until the next real operand begins
- Lazy source-index caching for occurrence-aware Registers inspection

### Visual language

- Central `visual_language.lua` semantic tables
- Semantic categories for roles, registers, memory, immediates, symbols, warnings, boundaries, rules, resolved/unresolved values, metadata, and origins
- Deterministic semantic precedence support
- Role-value styling distinguishes `role: source` from provenance such as `source: instruction`
- Low-color and monochrome fallback design through tags and compact markers
- Width-aware formatting concepts: full, condensed, marker, and plain modes
- Text equivalents for future arrows, such as `value flow: 60 -> rax`
- Highlight colors defined as data, consumed by `highlights.lua`
- Relevance concepts for focused/current/contextual/historical rendering

### Lua adapter

- Functions and anonymous function definitions
- Lexical and structural scopes
- `if` / `elseif` / `else` branch alternatives
- Local declarations
- Function parameters
- Assignments
- Table fields
- Return values
- Scalar values
- Function/call values
- Structural table values
- Identifier return-value resolution through visible Scope Members where possible
- Tree-sitter-first adapter declarations using exact syntax plus Tracker_HUD semantics

### ASM / x86-64 adapter

- Strict source target directives such as `; arch=x86-64;`
- NASM/GAS/MASM-aware directive comment prefixes
- Label range scopes
- ASM scope members such as labels and globals
- Canonical x86-64 register families and aliases
- General, pointer, flags, and vector register presentation groups
- Categorized mnemonic-indexed register effects
- Categorized mnemonic-indexed instruction Events
- Categorized mnemonic-indexed Stack effects
- Categorized mnemonic-indexed syscall boundary effects
- Heap facts derived from heap-category boundary effects
- Conservative state/syntax warnings
- Occurrence-aware Register Inspect behavior
- Operation-effect inspection directly from mnemonic semantics
- Static state tracking up to the cursor without emulating the CPU
- Source/destination role feedback for operands
- Source value metadata such as `selected source`, `source role`, and `value flow`

---

## Requirements

- Neovim with Lua support
- [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
- A Tree-sitter parser for each language you want Tracker_HUD to inspect
- A Tracker_HUD adapter for full language-aware context

A Tree-sitter parser and a Tracker_HUD adapter serve different purposes:

```text
Tree-sitter parser
    -> syntax structure

Tracker_HUD adapter
    -> language/architecture meaning

Tracker_HUD core
    -> scopes, state, trees, warnings, visual cues, and Inspect behavior
```

If a parser exists but Tracker_HUD has no adapter for that filetype, the panel can still appear, but language-specific structural analysis will not be available.

---

## Installation

### lazy.nvim

```lua
{
    "Ebdsaleh/Tracker_HUD",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("tracker_hud").setup()
    end,
}
```

A panel-oriented configuration:

```lua
{
    "Ebdsaleh/Tracker_HUD",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
    },
    config = function()
        require("tracker_hud").setup({
            panel_position = "left",
            panel_size = "auto",
        })
    end,
}
```

Tracker_HUD currently supports the docked **panel** display. Older README examples that used a winbar are no longer representative of the current configuration.

---

## Important leader-key note

If you use Tracker_HUD's default keymaps, set your leader before Lazy loads plugins.

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
    -- plugins
})
```

If `mapleader` is assigned after plugin setup, mappings such as `<leader>+`, `<leader>t`, or `<leader><leader>` may be registered against a different leader than expected.

---

## Basic setup

Tracker_HUD's current default display is the docked panel:

```lua
require("tracker_hud").setup({
    panel_position = "right",
    panel_size = "auto",
})
```

The panel stays separate from the source buffer and is marked so Tree-sitter/LSP work is not accidentally run against the HUD itself.

---

## Cursor notation used in this README

Examples in this README use vertical bars to show the cursor/selected range:

```asm
mov |rax|, 60
mov rax, |60|
```

The bars are documentation only. They are not part of the source code.

This avoids overloading ASM square brackets, because real ASM brackets mean memory addressing:

```asm
mov rax, [rbx]
mov rax, [rbp + rax*4 - 8]
```

---

## HUD sections

Tracker_HUD has three mandatory core sections:

```text
Scope
Scope Members
Warnings
```

Adapters can add additional sections and define their presentation order.

For Lua, the normal section order is:

```text
Scope
Scope Members
Warnings
```

For ASM/x86-64, the normal section order is:

```text
Scope
Scope Members
Registers
Events
Stack
Heap
Warnings
```

The same resolved section order also drives Inspect Mode cycling, so Inspect Mode stays aligned with the active adapter rather than relying on one hardcoded global list.

### Panel interaction

| Input | Action |
|---|---|
| `<CR>` | Toggle the section/node under the HUD cursor |
| `<Tab>` | Jump to a Scope Members source location when Show All is enabled |
| Double left click | Toggle the section/control/node under the mouse |

The HUD preserves its panel cursor position during interactive updates where possible.

---

## Inspect Mode

Tracker_HUD treats the source cursor as an inspection point. The active Inspect Mode decides which HUD section interprets that source position.

Default mappings:

```text
<leader><leader>   cycle Inspect Mode
<leader>t          inspect/toggle the source target
<leader>.          expand all for the active Inspect Mode where supported
<leader>,          collapse all for the active Inspect Mode where supported
```

### Inspect is a toggle

`<leader>t` is intentionally symmetric:

```text
first Inspect
    -> reveal / expand the current target

same Inspect again
    -> collapse it
```

For occurrence-aware Registers inspection, moving to another source occurrence updates the semantic role without forcing the register row open or closed. Expansion state is a UI choice; occurrence semantics are source state.

### Register Inspect semantics

The x86-64 Registers section distinguishes three useful inspection levels.

#### 1. Mnemonic: inspect the operation's effects

```asm
|mov| rax, 60
```

Tracker_HUD derives the affected state from the existing instruction-effect specs, so this selects `rax` as the destination without needing a special hardcoded `mov` Inspect scenario.

```asm
|xor| rdi, rdi
```

The operation affects the destination `rdi` and `rflags`, so both can be selected.

```asm
|cmp| rax, rbx
```

`cmp` changes flags but not either source register, so `rflags` is the operation target.

#### 2. Operand: inspect the exact occurrence

```asm
xor |rdi|, rdi
```

The first occurrence is presented as the destination.

```asm
xor rdi, |rdi|
```

The second occurrence is presented as the source.

The underlying register fact remains the same architectural state; the occurrence role is a separate Inspect presentation overlay.

#### 3. Immediate/source value: inspect the value source

```asm
mov rax, |60|
```

The immediate `60` is the source operand. The HUD can still reveal the affected register while presenting the selected occurrence as a source:

```text
role: source
source: instruction
selected source: immediate 60
source role: source value
value flow: 60 -> rax
```

When the cursor is on the destination:

```asm
mov |rax|, 60
```

Tracker_HUD can show:

```text
role: destination
source: instruction
value source: immediate 60
value flow: 60 -> rax
```

When the cursor is past the instruction or on a later line, the carried state can become past-tense/state-oriented:

```text
role: written by mov
source: instruction
value source: immediate 60
value flow: 60 -> rax
```

#### 4. Separator/gap: preserve the most recent occurrence

For:

```asm
xor rdi, rdi
```

cursor movement behaves conceptually like:

```text
|xor| rdi, rdi
    -> operation effects

xor |rdi|, rdi
    -> destination RDI

xor rdi|,| rdi
    -> still destination RDI

xor rdi, |rdi|
    -> source RDI
```

The comma is an operand separator/delimiter. It does not create a new semantic state and it does not jump ahead to the next operand before the cursor reaches that operand.

### Proactive Register cursor state

While Inspect Mode is `Registers`, occurrence semantics stay synchronized with cursor movement even when the row is already expanded.

For example, if `rdi` is open while the cursor is on the destination occurrence and the cursor moves to the source occurrence, the open details update from `destination` to `source` without another `<leader>t` press.

This uses a cached source-index line rather than rescanning the entire x86 rule set on each column movement.

---

## Line summary behavior

Tracker_HUD is cursor-state-first.

By default, it should not pre-read an instruction just because the cursor is on leading whitespace before the instruction.

```asm
| | mov rax, 60
```

Default behavior: do not pretend the cursor is already on `mov`, `rax`, or `60`.

Trailing whitespace after an instruction can show post-instruction state because the cursor has moved past the instruction:

```asm
mov rax, 60 | |
```

This behavior is controlled by:

```lua
line_summary = {
    enabled = true,
    show_before_instruction = false,
    show_after_instruction = true,
}
```

---

## Scope Members

The `Scope Members` section displays statically discovered members described by the active language adapter.

For Lua, this currently includes:

- local declarations
- function parameters
- table fields
- assignments
- return values
- scalar values such as strings, numbers, booleans, and nil
- call values
- structural table values

By default, Scope Members is filtered to the active member-owning scope and current cursor position.

The HUD includes a control:

```text
[ ] Show All Scope Members
```

When enabled:

```text
[+] Show All Scope Members
```

all discovered Scope Members in the file are shown, and `<Tab>` on a supported row jumps the source cursor to that member's source location.

Structural values remain attached to their owning member rather than being rendered as unrelated top-level rows.

### Scope Members source inspection

With Inspect Mode set to `Scope Members`, `<leader>t` targets the member at the source cursor position. Targeting is column-aware. When the cursor is not directly inside a member/value range, Tracker_HUD can fall back to the nearest member on the current line.

Expandable members use symmetric toggle behavior: Inspect can both open and close the selected member.

`<leader>.` and `<leader>,` expand/collapse members inside the current owning scope while preserving cursor-based visibility filtering.

---

## Visual language

Tracker_HUD now has a shared visual-language layer:

```text
semantic fact
    -> semantic style key
        -> visual_language.lua category/tag/marker/priority
            -> highlights.lua public highlight group
                -> text HUD spans now
                -> ASCII/graphical renderers later
```

The visual language is data-first and renderer-agnostic. The text HUD, future ASCII HUD, and any future graphical HUD should consume the same semantic vocabulary.

### Main principles

```text
Semantic identity determines meaning/color family.
Relevance determines intensity/emphasis.
Color is enhancement, not meaning.
```

Meaning should survive without color through:

- stable labels
- semantic tags
- compact markers
- indentation
- ordering
- explicit flow text such as `value flow: 60 -> rax`

### Important distinction: role vs source provenance

These are different meanings:

```text
role: source
source: instruction
```

`role: source` means the selected operand is acting as the source operand.

`source: instruction` means the fact came from instruction analysis.

They should not be styled as the same semantic category.

### Semantic categories

Current visual-language categories include:

| Category | Meaning |
|---|---|
| `metadata_key` | field names such as `role`, `source`, `line` |
| `value` | ordinary values without stronger identity |
| `origin` | provenance such as `instruction`, `analysis`, `declaration` |
| `source` | source operand role |
| `destination` | destination operand role |
| `affected` | affected/changed state |
| `register` | architectural register identity |
| `memory` | memory/address entity |
| `immediate` | immediate value |
| `symbol` | symbolic program entity |
| `instruction` | mnemonic / operation identity |
| `warning` | warning headline/severity |
| `warning_subject` | the thing implicated by a warning |
| `warning_rule` | rule/check identifiers |
| `boundary` | syscall/ABI/system boundary concept |
| `resolved` | safe/resolved state |
| `unresolved` | unresolved/failing state |

### Semantic tags

For low-color or explicit accessibility modes, categories can be represented with tags such as:

| Meaning | Full tag | Condensed tag |
|---|---|---|
| Warning | `[WARN]` | `[W]` |
| Warning subject | `[SUBJECT]` | `[SUBJ]` |
| Failure/unresolved | `[FAIL]` | `[X]` |
| Resolved/safe | `[OK]` | `[OK]` |
| Boundary | `[BOUNDARY]` | `[BND]` |
| Rule/check | `[RULE]` | `[RUL]` |
| Source operand | `[SRC]` | `[S]` |
| Destination operand | `[DST]` | `[D]` |
| Register | `[REG]` | `[R]` |
| Memory | `[MEM]` | `[M]` |
| Immediate | `[IMM]` | `[I]` |
| Instruction | `[INSN]` | `[IN]` |
| Metadata key | `[KEY]` | `[K]` |
| Origin | `[ORIGIN]` | `[O]` |

### Compact markers

Compact markers are available for narrow or monochrome output:

| Meaning | Marker |
|---|---|
| Warning | `!` |
| Warning subject | `*` |
| Unresolved/failure | `x` |
| Resolved/safe | `✓` or `ok` |
| Boundary | `@` |
| Rule/check | `?` |
| Source operand | `<` |
| Destination operand | `>` |
| Affected | `~` |
| Register | `R` |
| Memory | `M` |
| Immediate | `#` |
| Symbol | `$` |
| Instruction | `I` |
| Metadata key | `:` |
| Origin | `^` |

### Display capability tiers

Tracker_HUD's visual-language config models display capability tiers:

```text
truecolor
256-color
16-color / ANSI
monochrome
```

Low-color environments can enable tags and markers automatically. This is intended to keep the HUD useful over plain SSH sessions, tmux, OpenBSD/ksh-style terminals, poor ANSI displays, or color-limited setups.

### Width modes

The renderer can choose between:

```text
full
condensed
marker
plain
```

The goal is to preserve meaning without causing excessive wrapping in narrow side panels.

---

## Adapter architecture

Tracker_HUD's current **Adapter Contract v1** is Tree-sitter-first.

The central rule is:

```text
Tree-sitter says what exists syntactically
    ->
adapter says what that syntax means in this language/architecture
    ->
Tracker_HUD says how those semantics behave in the HUD
```

The core should not re-describe grammar facts that Tree-sitter and the adapter already provide.

### Tree-sitter-first construct shape

A construct declaration starts with exact Tree-sitter syntax:

```lua
["function_declaration"] = {
    syntax = {
        node_type = "function_declaration",

        fields = {
            name = "name",
            parameters = "parameters",
            body = "body",
        },

        tokens = {
            start = "function",
            args_open = "(",
            args_close = ")",
            scope_close = "end",
        },
    },

    construct = {
        kind = "function",
        language_term = "function",
        label = "Function",
    },

    scope = {
        kind = "lexical",
        affects_visibility = true,
        owns_members = true,
    },

    value = {
        kind = "function",
        language_term = "function",
        type_label = "function",
    },
}
```

The current syntax contract can describe:

- `syntax.node_type`
- exact Tree-sitter `fields`
- relevant named `children`
- grammar `tokens`
- syntax exclusions such as ancestor node types

Language/Tracker_HUD semantics remain separate from syntax through concepts such as:

```text
construct
scope
member
value
mutability
```

Mutability is orthogonal to construct identity and can describe binding, internal state, and shape independently.

### Instruction-driven semantic datasets

x86-64 instruction data uses the same Tree-sitter-first principle and is indexed directly by mnemonic:

```lua
["xor"] = {
    {
        syntax = {
            node_type = "instruction",

            fields = {
                kind = {
                    field = "kind",
                    node_type = "word",
                    text = "xor",
                },
            },
        },

        operands = {
            -- semantic operand declarations
        },

        effect = {
            -- register/stack/event/boundary semantics
        },
    },
}
```

Adapter Contract v1 validates this representation and rejects the old flat instruction-rule format for current bundled adapters.

This lets Tracker_HUD derive behavior generically. It does not need separate Inspect code for every `mov`, `xor`, `cmp`, `add`, or future instruction scenario.

### Current built-in adapter support

| Filetype | Status |
|---|---|
| `lua` | Supported: scopes, branches, locals, parameters, assignments, returns, values, and structural table members |
| `asm`, `nasm`, `gas`, `s` | Supported through the ASM adapter and x86-64 variant: labels, registers, Events, Stack, syscall boundaries, Heap routing, warnings, and source inspection |
| other filetypes | Panel may appear, but structural adapter support is not yet implemented |

---

## Source directives

Tracker_HUD supports strict source directives for adapter-owned target metadata.

The plugin owns the directive grammar; the adapter owns the directive vocabulary and accepted values.

A directive must begin at the initial column and use this shape:

```text
<comment-prefix><one-space><directive-name><assignment-symbol><value><terminator>
```

For the current ASM adapter, the assignment symbol is `=` and the terminator is `;`.

Valid NASM-style examples:

```asm
; arch=x86-64;
; platform=linux;
; abi=linux_syscall;
; syntax=nasm;
; mode=long64;
```

GAS-style syntax directives can use `#` or `//`:

```asm
# syntax=gas;
# arch=x86-64;
# platform=linux;
```

```asm
// syntax=gas;
// arch=x86-64;
```

Current ASM syntax comment-prefix declarations are:

```text
nasm -> ;
gas  -> #, //
masm -> ;
```

Malformed directive-looking lines produce targeted diagnostics instead of being silently accepted. Tracker_HUD can report issues such as:

- indentation before the directive
- extra spaces after the comment prefix
- whitespace around `=`
- missing terminator
- invalid/unknown target values
- bootstrap comment-prefix conflicts with the resolved syntax

Source directives override setup target defaults. Setup target defaults override adapter/variant defaults.

---

## ASM / x86-64

Add the architecture directive near the top of an ASM file:

```asm
; arch=x86-64;
```

A typical target declaration is:

```asm
; arch=x86-64;
; platform=linux;
; abi=linux_syscall;
; syntax=nasm;
; mode=long64;
```

### Current target metadata

The x86-64 variant currently models target fields including:

```text
architecture
platform
abi
syntax
mode
```

Current platform declarations include Linux support and declared Windows/Darwin variants. The implemented syscall boundary model currently targets Linux `linux_syscall` semantics.

### Register model

The x86-64 adapter describes canonical register families and aliases, for example:

```text
RAX
    RAX  64-bit full write
    EAX  32-bit zero-extend into RAX
    AX   16-bit partial write
    AH    8-bit high partial write
    AL    8-bit low partial write
```

The HUD groups register presentation into categories such as:

```text
General
Pointers
Flags
Vector
```

Register facts are static/effect-based. Unknown or partially known values remain explicit rather than being guessed.

---

## x86-64 register effects

Register effects are fully categorized, Tree-sitter-first, and mnemonic-indexed. The active aggregator does not consume the old flat legacy rule tables.

Current category tree:

```text
register_effects/
    contract.lua
    init.lua
    registry.lua

    integer/
        arithmetic.lua
        multiply_divide.lua
        compare_test.lua
        bitwise.lua
        shifts_rotates.lua
        bit_manipulation.lua
        data_movement.lua
        conditional.lua
        atomic.lua

    string/
        movement.lua
        compare_scan.lua
        io.lua
        repeat_prefix.lua

    control/
        branches.lua
        calls_returns.lua
        loops.lua
        system_calls.lua
        interrupts.lua

    stack/
        push_pop.lua
        frames.lua

    flags/
        direct.lua

    processor/
        io.lua
        identification.lua
        descriptor_segment.lua
        control_state.lua
        protection_state.lua
        timing_random.lua
        profiling.lua
        transactional.lua
        virtualization.lua

    vector/
        movement.lua
        integer_arithmetic.lua
        floating_arithmetic.lua
        logical.lua
        compare.lua
        convert.lua
        shuffle_permute.lua
        broadcast_insert_extract.lua

    mask/
        movement.lua
        arithmetic.lua
        logical.lua
        shifts.lua
        compare.lua

    x87/
        data_movement.lua
        arithmetic.lua
        compare.lua
        control_state.lua

    amx/
        configuration.lua
        movement.lua
        compute.lua

    crypto/
        aes.lua
        sha.lua
        carryless_gfni.lua
        key_locker.lua
        sm3_sm4.lua

    legacy/
        bcd_ascii.lua
        segment.lua
        compatibility.lua
```

Categorization follows instruction meaning rather than whichever register happens to be affected. For example, direct flag-manipulation instructions live under `flags`, while arithmetic instructions that also update `rflags` remain with their arithmetic family.

---

## x86-64 Events

`Events` represents meaningful instruction/runtime/processor actions that should not be modeled as fake register writes simply to make them visible.

The instruction-event dataset is Tree-sitter-first and mnemonic-indexed:

```text
instruction_events/
    memory/
        ordering.lua
        cache_control.lua
        prefetch.lua
        tlb.lua

    processor/
        identification.lua
        serialization.lua
        timing.lua
        entropy.lua
        wait_hint.lua
        descriptor_state.lua
        descriptor_segment.lua
        extended_state.lua
        floating_state.lua
        protection_state.lua
        profiling.lua
        control_state.lua
        segment_state.lua
        io.lua
        timing_random.lua
        transactional.lua
        virtualization.lua

    control/
        branches.lua
        calls_returns.lua
        loops.lua
        interrupts.lua
        exceptions.lua
        system_calls.lua
        transactional.lua

    security/
        sgx.lua
        tdx.lua
        cet.lua
        mpx.lua
        key_locker.lua
        trusted_execution.lua
        platform_security.lua
        user_interrupts.lua
        hardware_crypto.lua

    virtualization/
        vmx.lua
        svm.lua
```

This separation allows operations such as prefetch, profiling, security, virtualization, and processor-state events to appear in the HUD without pretending that they wrote `rip` or another unrelated register.

---

## x86-64 Stack

Stack instruction semantics are also categorized and mnemonic-indexed:

```text
stack_effects/
    data.lua
    allocation.lua
    control.lua
    frames.lua
    init.lua
```

Current modeled examples include:

- `push`
- `pop`
- `sub rsp, immediate`
- `add rsp, immediate`
- `call`
- `ret`
- `leave`

The Stack HUD remains a static semantic model rather than a runtime stack debugger.

---

## Boundaries, Heap, and syscalls

Boundary effects model runtime/system boundaries separately from normal register effects.

The current x86-64 boundary dataset is:

```text
boundary_effects/
    init.lua
    system_calls.lua
```

For Linux `syscall`, Tracker_HUD currently describes:

```text
number register:  rax
return register:  rax
arguments:        rdi, rsi, rdx, r10, r8, r9
```

Known syscall effects currently include:

| Number | Name | Category |
|---:|---|---|
| `0` | `read` | I/O |
| `1` | `write` | I/O |
| `9` | `mmap` | Heap |
| `11` | `munmap` | Heap |
| `12` | `brk` | Heap |
| `60` | `exit` | Process |

Heap-category boundary effects are normalized into the Heap HUD. For example, `mmap` can produce a memory-region fact, while `munmap` can consume pointer/size state.

Boundary metadata also feeds conservative warning checks for missing syscall numbers, unknown syscall effects, and missing required arguments.

---

## Warnings

Warnings are derived from already-collected context facts and Tree-sitter syntax diagnostics. They are intentionally conservative.

Current low-level warnings can report conditions such as:

- a syscall number register with no known value
- an unknown syscall number
- a required syscall argument whose register value is not known
- syntax-level Tree-sitter errors
- other adapter-described state gaps

Warnings are not proof that a program is invalid. Tracker_HUD is a static code-awareness layer, not a full verifier.

---

## Source index

Tracker_HUD includes a generic per-buffer source index:

```text
buffer
    -> section
        -> line
            -> occurrences
            -> presentation targets
```

The source-index core does not know about x86, Registers, Events, Stack, Heap, or any concrete adapter section. Adapter/context-specific discovery supplies semantic occurrences; the generic compiler normalizes and caches them.

Occurrence ranges use 0-based byte columns with an end-exclusive end column.

The source index is currently used for lazy, occurrence-aware Registers inspection. A line remains cached while its source text and active adapter target signature remain current. Moving between operands on an already compiled line therefore does not require rescanning the entire semantic dataset.

---

## Section architecture

Tracker_HUD separates universal section mechanics from reusable category behavior and concrete domain semantics:

```text
generic Section
    -> category template
        -> concrete section
```

Current low-level section implementations follow a consistent model/tree split:

```text
sections/
    templates/
        lookup.lua
        lookup_model.lua
        lookup_tree.lua

    low_level/
        registers.lua
        register_model.lua
        register_tree.lua

        stack.lua
        stack_model.lua
        stack_tree.lua

        heap.lua
        heap_model.lua
        heap_tree.lua
```

Semantic detail rendering is shared through `section_tree.lua` and the lookup-tree template path so Registers, Stack, Heap, and future section families can inherit the same visual-language behavior without duplicating it in each concrete tree file.

Section identity uses stable string IDs. Adapter presentation controls visible order; navigation indexes are not semantic identity.

---

## Configuration

Current default-shaped setup:

```lua
require("tracker_hud").setup({
    display = "panel", -- panel is the supported display

    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

    namespace = {
        prefix = "Hud",
    },

    highlights = {
        enabled = true,
    },

    visual_language = {
        terminal_tier = "auto", -- "auto", "truecolor", "256", "16", "monochrome"

        tags = {
            enabled = "auto", -- true, false, or "auto"
            mode = "auto", -- "auto", "full", "condensed", "marker", "plain"
        },

        markers = {
            enabled = "auto", -- true, false, or "auto"
            ascii_safe = true,
        },

        width = {
            mode = "auto", -- "auto", "full", "condensed", "marker", "plain"
            condensed_columns = 52,
            marker_columns = 40,
        },

        low_color = {
            enforce_collision_fallbacks = true,
            underline_rule_checks = true,
            distinguish_operand_green_from_resolved_green = true,
        },

        flow = {
            enabled = true,
        },
    },

    line_summary = {
        enabled = true,
        show_before_instruction = false,
        show_after_instruction = true,
    },

    panel_position = "right",
    panel_size = "auto",

    panel_auto_width_padding = 2,
    panel_auto_height_padding = 2,

    panel_default_width = 52,
    panel_default_height = 9,

    keymaps = {
        enabled = true,
        increase_size = "<leader>+",
        decrease_size = "<leader>-",
        auto_size = "<leader><CR>",
        cycle_inspect_mode = "<leader><leader>",
        inspect_source = "<leader>t",
        expand_all_members_in_scope = "<leader>.",
        collapse_all_members_in_scope = "<leader>,",
        step = 2,
    },

    adapter_paths = {
        "tracker_hud/adapters",
    },

    targets = {
        architecture = nil,
        platform = nil,
        abi = nil,
        syntax = nil,
        mode = nil,
    },
})
```

### Target precedence

For target metadata such as ASM architecture/platform/syntax:

```text
source directive
    > setup targets
        > adapter/variant defaults
```

---

## Panel positioning

Supported positions:

```lua
panel_position = "left"
panel_position = "right"
panel_position = "top"
panel_position = "bottom"
```

For `left` and `right`, panel size means width in columns.

For `top` and `bottom`, panel size means height in rows.

---

## Panel sizing

### Automatic size

```lua
panel_size = "auto"
```

Auto sizing is calculated when the panel opens. It does not constantly resize itself while the cursor moves.

For left/right panels, automatic size is based on rendered width. For top/bottom panels, it is based on rendered height.

### Fixed size

```lua
panel_size = 52
```

For a bottom/top panel, a smaller value is normally more useful:

```lua
require("tracker_hud").setup({
    panel_position = "bottom",
    panel_size = 9,
})
```

---

## Commands

### `:TrackerHudSize`

Set the current panel size:

```vim
:TrackerHudSize 52
```

Reset to automatic sizing:

```vim
:TrackerHudSize auto
```

### `:TrackerHudPos`

Move the current panel:

```vim
:TrackerHudPos left
:TrackerHudPos right
:TrackerHudPos top
:TrackerHudPos bottom
```

These commands affect the current session; they do not rewrite your Neovim configuration.

---

## Keymaps

Default normal-mode mappings:

| Mapping | Action |
|---|---|
| `<leader>+` | Increase panel size |
| `<leader>-` | Decrease panel size |
| `<leader><CR>` | Recalculate automatic panel size |
| `<leader><leader>` | Cycle the active Inspect Mode |
| `<leader>t` | Inspect/toggle the source target for the active HUD section |
| `<leader>.` | Expand all entries for the active Inspect Mode where supported |
| `<leader>,` | Collapse all entries for the active Inspect Mode where supported |

`<leader>.` / `<leader>,` are scope-aware for Scope Members and tree-aware for Registers, Events, Stack, Heap, and Warnings.

The resize amount is controlled by:

```lua
keymaps = {
    step = 2,
}
```

### Disable default keymaps

```lua
require("tracker_hud").setup({
    keymaps = {
        enabled = false,
    },
})
```

---

## Example full setup

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },

    {
        "Ebdsaleh/Tracker_HUD",
        config = function()
            require("tracker_hud").setup({
                panel_position = "left",
                panel_size = "auto",

                show_line_numbers = true,
                show_branch_context = true,
                separator = " -> ",

                line_summary = {
                    enabled = true,
                    show_before_instruction = false,
                    show_after_instruction = true,
                },

                visual_language = {
                    terminal_tier = "auto",
                    tags = {
                        enabled = "auto",
                        mode = "auto",
                    },
                    markers = {
                        enabled = "auto",
                        ascii_safe = true,
                    },
                },

                targets = {
                    architecture = nil,
                    platform = nil,
                    abi = nil,
                    syntax = nil,
                    mode = nil,
                },

                keymaps = {
                    enabled = true,
                    increase_size = "<leader>+",
                    decrease_size = "<leader>-",
                    auto_size = "<leader><CR>",
                    cycle_inspect_mode = "<leader><leader>",
                    inspect_source = "<leader>t",
                    expand_all_members_in_scope = "<leader>.",
                    collapse_all_members_in_scope = "<leader>,",
                    step = 2,
                },
            })
        end,
    },
})
```

Install the Tree-sitter parsers appropriate for the files you want to inspect.

---

## Current limitations

Tracker_HUD is still experimental and primarily static.

Current limitations include:

- ASM/x86-64 state is effect-based; Tracker_HUD is not a CPU emulator
- Register values may remain unknown or partial when they cannot be safely derived
- Boundary reads and instruction writes still need richer pre-state/post-state handling in some cases
- Stack and Heap modeling is currently incomplete compared with a debugger/runtime trace
- Heap facts currently depend on modeled boundary effects such as selected Linux syscalls
- Warnings are conservative state diagnostics, not formal correctness proofs
- Scope Members does not yet fully model all shadowing, mutation, lifetime, aliasing, or control-flow visibility cases
- Only the bundled Lua and ASM adapters currently provide substantial language-aware behavior
- Windows/Darwin x86-64 target declarations exist, but the deepest current syscall boundary implementation is Linux-oriented
- Full memory ownership, lifetime, pointer alias, and control-flow analysis are future work
- Visual-language rendering is now wired into the text HUD, but ASCII boxes and graphical views are future work
- Color choices are still subject to refinement

---

## Roadmap

Planned/future work includes:

- Continue completing the ASM/x86-64 adapter and low-level state model
- Restore/richly extend arithmetic/logical carrying after the large architecture refactor
- Broader Stack and Heap transition semantics
- Static data / memory-location tracking for ASM labels and memory operands
- More complete warning generation from Register/Stack/Heap facts
- More instruction/event coverage where architectural facts are still missing
- More source-index consumers where occurrence-aware inspection provides a real benefit
- Better visual highlighting/color tuning for section headers, active targets, warnings, and muted details
- Monochrome/tag/marker rendering tests on low-color terminals
- Optional ASCII visualizations such as register boxes and value-flow arrows
- Better Scope Members shadowing/lifetime handling
- Loop-variable discovery and richer high-level member semantics
- C/C++ pointer allocation/free and lifetime tracking
- Rust ownership and lifetime hints
- Diagnostics/LSP enrichment as optional advisory information
- Optional virtual-text warnings
- Additional language adapters

---

## Current source structure

The current `lua/tracker_hud/` source tree in this snapshot is:

```text
lua/tracker_hud/
├── adapters/
│   ├── asm/
│   │   ├── arch/
│   │   │   └── x86_64/
│   │   │       ├── boundary_effects/
│   │   │       │   ├── init.lua
│   │   │       │   └── system_calls.lua
│   │   │       ├── instruction_events/
│   │   │       │   ├── control/
│   │   │       │   │   ├── branches.lua
│   │   │       │   │   ├── calls_returns.lua
│   │   │       │   │   ├── exceptions.lua
│   │   │       │   │   ├── interrupts.lua
│   │   │       │   │   ├── loops.lua
│   │   │       │   │   ├── system_calls.lua
│   │   │       │   │   └── transactional.lua
│   │   │       │   ├── memory/
│   │   │       │   │   ├── cache_control.lua
│   │   │       │   │   ├── ordering.lua
│   │   │       │   │   ├── prefetch.lua
│   │   │       │   │   └── tlb.lua
│   │   │       │   ├── processor/
│   │   │       │   │   ├── control_state.lua
│   │   │       │   │   ├── descriptor_segment.lua
│   │   │       │   │   ├── descriptor_state.lua
│   │   │       │   │   ├── entropy.lua
│   │   │       │   │   ├── extended_state.lua
│   │   │       │   │   ├── floating_state.lua
│   │   │       │   │   ├── identification.lua
│   │   │       │   │   ├── io.lua
│   │   │       │   │   ├── profiling.lua
│   │   │       │   │   ├── protection_state.lua
│   │   │       │   │   ├── segment_state.lua
│   │   │       │   │   ├── serialization.lua
│   │   │       │   │   ├── timing.lua
│   │   │       │   │   ├── timing_random.lua
│   │   │       │   │   ├── transactional.lua
│   │   │       │   │   ├── virtualization.lua
│   │   │       │   │   └── wait_hint.lua
│   │   │       │   ├── security/
│   │   │       │   │   ├── cet.lua
│   │   │       │   │   ├── hardware_crypto.lua
│   │   │       │   │   ├── key_locker.lua
│   │   │       │   │   ├── mpx.lua
│   │   │       │   │   ├── platform_security.lua
│   │   │       │   │   ├── sgx.lua
│   │   │       │   │   ├── tdx.lua
│   │   │       │   │   ├── trusted_execution.lua
│   │   │       │   │   └── user_interrupts.lua
│   │   │       │   ├── virtualization/
│   │   │       │   │   ├── svm.lua
│   │   │       │   │   └── vmx.lua
│   │   │       │   └── init.lua
│   │   │       ├── register_effects/
│   │   │       │   ├── amx/
│   │   │       │   │   ├── compute.lua
│   │   │       │   │   ├── configuration.lua
│   │   │       │   │   └── movement.lua
│   │   │       │   ├── crypto/
│   │   │       │   │   ├── aes.lua
│   │   │       │   │   ├── carryless_gfni.lua
│   │   │       │   │   ├── key_locker.lua
│   │   │       │   │   ├── sha.lua
│   │   │       │   │   └── sm3_sm4.lua
│   │   │       │   ├── flags/
│   │   │       │   │   └── direct.lua
│   │   │       │   ├── integer/
│   │   │       │   │   ├── arithmetic.lua
│   │   │       │   │   ├── atomic.lua
│   │   │       │   │   ├── bit_manipulation.lua
│   │   │       │   │   ├── bitwise.lua
│   │   │       │   │   ├── compare_test.lua
│   │   │       │   │   ├── conditional.lua
│   │   │       │   │   ├── data_movement.lua
│   │   │       │   │   ├── multiply_divide.lua
│   │   │       │   │   └── shifts_rotates.lua
│   │   │       │   ├── legacy/
│   │   │       │   │   ├── bcd_ascii.lua
│   │   │       │   │   ├── compatibility.lua
│   │   │       │   │   └── segment.lua
│   │   │       │   ├── mask/
│   │   │       │   │   ├── arithmetic.lua
│   │   │       │   │   ├── compare.lua
│   │   │       │   │   ├── logical.lua
│   │   │       │   │   ├── movement.lua
│   │   │       │   │   └── shifts.lua
│   │   │       │   ├── stack/
│   │   │       │   │   ├── frames.lua
│   │   │       │   │   └── push_pop.lua
│   │   │       │   ├── string/
│   │   │       │   │   ├── compare_scan.lua
│   │   │       │   │   ├── io.lua
│   │   │       │   │   ├── movement.lua
│   │   │       │   │   └── repeat_prefix.lua
│   │   │       │   ├── vector/
│   │   │       │   │   ├── broadcast_insert_extract.lua
│   │   │       │   │   ├── compare.lua
│   │   │       │   │   ├── convert.lua
│   │   │       │   │   ├── floating_arithmetic.lua
│   │   │       │   │   ├── integer_arithmetic.lua
│   │   │       │   │   ├── logical.lua
│   │   │       │   │   ├── movement.lua
│   │   │       │   │   └── shuffle_permute.lua
│   │   │       │   ├── x87/
│   │   │       │   │   ├── arithmetic.lua
│   │   │       │   │   ├── compare.lua
│   │   │       │   │   ├── control_state.lua
│   │   │       │   │   └── data_movement.lua
│   │   │       │   ├── contract.lua
│   │   │       │   ├── init.lua
│   │   │       │   └── registry.lua
│   │   │       ├── stack_effects/
│   │   │       │   ├── allocation.lua
│   │   │       │   ├── control.lua
│   │   │       │   ├── data.lua
│   │   │       │   ├── frames.lua
│   │   │       │   └── init.lua
│   │   │       ├── adapter.lua
│   │   │       └── init.lua
│   │   ├── adapter.lua
│   │   ├── init.lua
│   │   └── instruction_utils.lua
│   ├── lua/
│   │   ├── adapter.lua
│   │   └── init.lua
│   ├── contract.lua
│   ├── loader.lua
│   ├── registry.lua
│   └── variant_utils.lua
├── constructs/
│   └── contract.lua
├── sections/
│   ├── low_level/
│   │   ├── heap.lua
│   │   ├── heap_model.lua
│   │   ├── heap_tree.lua
│   │   ├── register_model.lua
│   │   ├── register_tree.lua
│   │   ├── registers.lua
│   │   ├── stack.lua
│   │   ├── stack_model.lua
│   │   └── stack_tree.lua
│   └── templates/
│       ├── lookup.lua
│       ├── lookup_model.lua
│       └── lookup_tree.lua
├── source_index/
│   ├── compiler.lua
│   └── init.lua
├── config.lua
├── construct_utils.lua
├── context.lua
├── context_engine.lua
├── core.lua
├── directive_utils.lua
├── event_model.lua
├── event_tree.lua
├── events.lua
├── highlights.lua
├── hud.lua
├── hud_controls.lua
├── hud_inspect.lua
├── hud_nodes.lua
├── hud_relevance.lua
├── hud_sections.lua
├── hud_text.lua
├── init.lua
├── inspect_mode.lua
├── namespace.lua
├── presentation.lua
├── scope_member_model.lua
├── scope_member_tree.lua
├── scope_members.lua
├── section.lua
├── section_layout.lua
├── section_model.lua
├── section_tree.lua
├── state.lua
├── symbol_state.lua
├── target_diagnostics.lua
├── treesitter_errors.lua
├── treesitter_utils.lua
├── visual_language.lua
├── warning_tree.lua
└── warnings.lua
```

The old flat x86-64 `register_effects` and `instruction_events` compatibility modules have been removed. The active tree now contains categorized datasets consumed by current aggregators.

---

## Development notes

### Adapter declarations are spec-only

The long-term adapter rule is:

```text
Adapters describe.
The context engine interprets.
HUD/renderers present.
```

Adapters should stay declarative wherever possible. Language/architecture-specific data should be written as specs, not as executable parser behavior hidden inside adapters.

### Visual-language implementation direction

The visual-language layer should continue moving toward:

```text
facts/data model
    -> semantic style/category
        -> renderer choice
```

This means semantic meaning should not be duplicated separately in Registers, Stack, Heap, Warnings, and future sections. Shared section-tree helpers should own common detail-row behavior where possible.

---

## Version notes

### Post-`v0.7.7` development snapshot

- Added the renderer-agnostic `visual_language.lua` semantic table module
- Added semantic tags, condensed tags, compact markers, display tiers, and width-mode data
- Added deterministic semantic precedence support for future renderers
- Moved highlight defaults into visual-language data consumed by `highlights.lua`
- Added `hud_text.lua` semantic text composition with spans and annotation support
- Added visual-language rendering support for low-color/tag/marker modes
- Added value-flow details such as `value flow: 60 -> rax`
- Added `line_summary` config and cursor-state-first behavior for leading/trailing instruction whitespace
- Normalized operand-role feedback so `mov rax, |60|` reports `role: source`
- Kept `source: instruction` as provenance/origin rather than operand role
- Centralized semantic detail rendering through `section_tree.lua` / `lookup_tree.lua`
- Shared semantic detail helpers across Registers, Stack, and Heap tree implementations
- Added role-value color separation so `role: source` / `role: destination` differ from `source: instruction`
- Restored heap tracking/model files after local file replacement cleanup

### `v0.7.7`

- Made the docked panel the supported display path and aligned configuration/documentation with the panel-only default
- Added strict plugin-wide source directive parsing through `directive_utils.lua`
- Kept directive grammar core-owned while leaving directive names, accepted values, aliases, and meanings adapter-owned
- Added malformed-directive diagnostics for indentation, spacing, assignment formatting, missing terminators, invalid values, and syntax-prefix conflicts
- Added syntax-aware NASM/GAS/MASM directive comment handling
- Added target diagnostics for resolved architecture/platform/ABI/syntax/mode state
- Added Tree-sitter-first **Adapter Contract v1** as the canonical bundled-adapter validation model
- Made `contract_version = 1` mandatory for bundled adapters
- Migrated both Lua and ASM adapters to exact Tree-sitter-first syntax declarations
- Added validation for syntax node types, fields, children, tokens, exclusions, scope members, range scopes, branch alternatives, section descriptors, presentation order, and instruction-rule datasets
- Revalidated the configured ASM adapter after x86-64 variant resolution so variant-provided data must also satisfy Adapter Contract v1
- Converted all x86-64 register-effect data to categorized mnemonic-indexed Tree-sitter-first modules
- Organized register effects into integer, string, control, stack, flags, processor, vector, mask, x87, AMX, crypto, and architectural-legacy instruction families
- Converted all x86-64 instruction-event data to categorized mnemonic-indexed Tree-sitter-first modules
- Added/expanded the `Events` HUD section for memory, processor, control, security, and virtualization events
- Removed fake register-visibility effects where the instruction is more accurately represented as an Event
- Converted x86-64 Stack effects to categorized mnemonic-indexed Tree-sitter-first modules
- Converted syscall boundary effects to a categorized mnemonic-indexed boundary module
- Removed duplicated syscall metadata in favor of the calling-convention/boundary model
- Removed obsolete flat x86-64 register-effect and instruction-event compatibility modules after migration
- Added adapter-driven section descriptors and adapter-controlled section presentation/Inspect order
- Added reusable generic `Section` / `Model` / `Tree` infrastructure
- Added reusable lookup-style section templates used by low-level state sections
- Added generic per-buffer, per-section, per-line source-index infrastructure
- Kept source indexing opt-in through adapter section descriptors rather than making Scope/Scope Members depend on it
- Wired lazy source-index compilation into occurrence-aware Registers inspection
- Added mnemonic-as-operation Inspect semantics so inspecting an instruction mnemonic reveals the register state that operation affects
- Added exact operand-occurrence inspection with destination/source roles
- Made Register occurrence semantics update proactively as the source cursor moves, independently of HUD expansion state
- Preserved the most recently reached operand occurrence while the cursor crosses instruction separators/gaps, so punctuation does not jump ahead semantically
- Made source-side Inspect actions symmetric: if `<leader>t` can expand/reveal a target, the same action can collapse it
- Preserved exact occurrence identity when two source operands refer to the same architectural register
- Kept Scope Members inspection column-aware, tree-aware, and independent from the low-level source-index path
- Preserved Lua Scope Members behavior while the low-level ASM architecture and datasets were reorganized
- Updated the README with the current keymaps, Inspect semantics, Adapter Contract v1, categorized x86-64 data layout, source-index model, and full source tree

### Earlier versions

- `v0.7.6`: moved bundled adapters to directory-backed modules and removed loose adapter compatibility paths
- `v0.7.5`: split the large x86-64 register-effects table and added mnemonic-indexed lookup to reduce ASM HUD lag
- `v0.7.4`: added x86-64 architecture facts, boundary effects, initial Heap HUD section, and syscall heap routing
- `v0.7.3`: added column-aware Scope Members inspect targeting and source-side expand/collapse helpers
- `v0.7.2`: added active Inspect Mode, statusline display, configurable Inspect keymaps, and Scope Members source reveal
- `v0.7.1`: added assignment tracking and structural assignment values for Scope Members
- `v0.7.0`: migrated construct handling to normalized construct/scope/member/value specs
- `v0.6.0`: added interactive HUD sections, Scope Members, controls, and HUD tree expansion
- `v0.5.0`: made the Lua adapter spec-only and moved adapter node matching/parsing into the shared context engine
- `v0.4.x`: introduced/refined the adapter-based context architecture and declarative construct specs
- `v0.3.x`: added runtime panel position/size commands and cleaned public configuration/state handling

---

## Native Windows Perl note

Native Windows Perl LSP support is currently not a Tracker_HUD development target.

Perl may still be usable through Tree-sitter or POSIX-like environments such as WSL, MSYS2, Linux, or OpenBSD, but native Windows Perl LSP behavior has previously been unreliable because of server/runtime/piping compatibility.

---

## Author

Created by [@Ebdsaleh](https://github.com/Ebdsaleh).

---

## License

This project is licensed under the Apache License 2.0.
