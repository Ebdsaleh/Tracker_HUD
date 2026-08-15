# Tracker_HUD

By [@Ebdsaleh](https://github.com/Ebdsaleh)

Tracker HUD is an experimental Neovim plugin that provides a live, cursor-aware code-analysis HUD. It is built around Tree-sitter and declarative language adapters: Tree-sitter identifies the exact syntax under the cursor, adapters describe what that syntax means, and Tracker HUD turns those facts into scopes, members, register state, instruction events, stack/heap information, warnings, and source-side inspection behavior.

The current implementation is still a proof-of-concept, but the architecture is now substantially more structured than the early versions. The built-in Lua adapter is the reference high-level-language adapter, while the ASM adapter currently has the deepest low-level support through its x86-64 variant.

> **Current status:** experimental but usable. The supported display is the docked panel. Lua supports structural scope/member inspection. ASM/x86-64 now uses a Tree-sitter-first Adapter Contract v1, categorized mnemonic-indexed semantic datasets, occurrence-aware Register inspection, instruction Events, Stack effects, syscall boundary effects, Heap routing, and conservative Warnings.

The long-term direction is a systems-programming analysis HUD: complete the low-level ASM model, then extend the same adapter-driven architecture toward C/C++ pointer and lifetime state and Rust ownership/lifetime information.

---

## Features

### Core HUD

- Tree-sitter-powered cursor context tracking
- Docked panel display
- Panel positions: `left`, `right`, `top`, and `bottom`
- Launch-time automatic panel sizing
- Runtime panel resizing and repositioning
- Panel focus restoration so Tracker HUD does not steal source focus
- HUD panel closes with the tracked source window
- Interactive expandable/collapsible HUD trees
- `<CR>` panel-row toggling
- Double-click panel-row toggling
- Stable current-line, current-scope, and depth status information
- Adapter-driven section layout and Inspect Mode order
- Shared presentation/model/tree infrastructure for reusable section families

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
- Tree-sitter-first adapter declarations using exact syntax plus Tracker HUD semantics

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

---

## Requirements

- Neovim with Lua support
- [`nvim-treesitter`](https://github.com/nvim-treesitter/nvim-treesitter)
- A Tree-sitter parser for each language you want Tracker HUD to inspect
- A Tracker HUD adapter for full language-aware context

A Tree-sitter parser and a Tracker HUD adapter serve different purposes:

```text
Tree-sitter
    -> tells Tracker HUD what syntax exists

Adapter
    -> tells Tracker HUD what that syntax means

Tracker HUD core
    -> turns those facts into scopes, state, trees, warnings, and Inspect behavior
```

If a parser exists but Tracker HUD has no adapter for that filetype, the panel can still appear, but language-specific structural analysis will not be available.

---

## Installation

### lazy.nvim

```lua
{
    "Ebdsaleh/Tracker_HUD",
    config = function()
        require("tracker_hud").setup()
    end,
}
```

A panel-oriented configuration:

```lua
{
    "Ebdsaleh/Tracker_HUD",
    config = function()
        require("tracker_hud").setup({
            panel_position = "left",
            panel_size = "auto",
        })
    end,
}
```

Tracker HUD currently supports the docked **panel** display. Older README examples that used a winbar are no longer representative of the current configuration.

---

## Important leader-key note

If you use Tracker HUD's default keymaps, set your leader before Lazy loads plugins.

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

Tracker HUD's current default display is the docked panel:

```lua
require("tracker_hud").setup({
    panel_position = "right",
    panel_size = "auto",
})
```

The panel stays separate from the source buffer and is marked so Tree-sitter/LSP work is not accidentally run against the HUD itself.

---

## HUD sections

Tracker HUD has three mandatory core sections:

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

Tracker HUD treats the source cursor as an inspection point. The active Inspect Mode decides which HUD section interprets that source position.

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
[mov] rax, 60
```

Tracker HUD derives the affected state from the existing instruction-effect specs, so this selects `rax` as the destination without needing a special `mov` Inspect scenario.

```asm
[xor] rdi, rdi
```

The operation affects the destination `rdi` and `rflags`, so both can be selected.

```asm
[cmp] rax, rbx
```

`cmp` changes flags but not either source register, so `rflags` is the operation target.

#### 2. Operand: inspect the exact occurrence

```asm
xor [rdi], rdi
```

The first occurrence is presented as the destination.

```asm
xor rdi, [rdi]
```

The second occurrence is presented as the source.

The underlying register fact remains the same architectural state; the occurrence role is a separate Inspect presentation overlay.

#### 3. Separator/gap: preserve the most recent occurrence

For:

```asm
xor rdi, rdi
```

cursor movement behaves conceptually like:

```text
[xor] rdi, rdi
    -> operation effects

xor [rdi], rdi
    -> destination RDI

xor rdi[,] rdi
    -> still destination RDI

xor rdi, [rdi]
    -> source RDI
```

The comma is an operand separator/delimiter. It does not create a new semantic state and it does not jump ahead to the next operand before the cursor reaches that operand.

### Proactive Register cursor state

While Inspect Mode is `Registers`, occurrence semantics stay synchronized with cursor movement even when the row is already expanded.

For example, if `rdi` is open while the cursor is on the destination occurrence and the cursor moves to the source occurrence, the open details update from `destination` to `source` without another `<leader>t` press.

This uses a cached source-index line rather than rescanning the entire x86 rule set on each column movement.

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

With Inspect Mode set to `Scope Members`, `<leader>t` targets the member at the source cursor position. Targeting is column-aware. When the cursor is not directly inside a member/value range, Tracker HUD can fall back to the nearest member on the current line.

Expandable members use symmetric toggle behavior: Inspect can both open and close the selected member.

`<leader>.` and `<leader>,` expand/collapse members inside the current owning scope while preserving cursor-based visibility filtering.

---

## Adapter architecture

Tracker HUD's current **Adapter Contract v1** is Tree-sitter-first.

The central rule is:

```text
Tree-sitter says what exists syntactically
        ->
adapter says what that syntax means in this language/architecture
        ->
Tracker HUD says how those semantics behave in the HUD
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

Language/Tracker HUD semantics remain separate from syntax through concepts such as:

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

This lets Tracker HUD derive behavior generically. It does not need separate Inspect code for every `mov`, `xor`, `cmp`, `add`, or future instruction scenario.

### Built-in adapter layout

```text
lua/tracker_hud/adapters/
    contract.lua
    loader.lua
    registry.lua
    variant_utils.lua

    lua/
        init.lua
        adapter.lua

    asm/
        init.lua
        adapter.lua
        instruction_utils.lua
        arch/
            x86_64/
                init.lua
                adapter.lua
                ...
```

`adapters/<name>/init.lua` is the adapter entry point. The adapter registry validates Contract v1 when an adapter is registered and validates the resolved active adapter again after architecture/variant configuration.

### Current built-in adapter support

| Filetype | Status |
|---|---|
| `lua` | Supported: scopes, branches, locals, parameters, assignments, returns, values, and structural table members |
| `asm`, `nasm`, `gas`, `s` | Supported through the ASM adapter and x86-64 variant: labels, registers, Events, Stack, syscall boundaries, Heap routing, warnings, and source inspection |
| other filetypes | Panel may appear, but structural adapter support is not yet implemented |

---

## Source directives

Tracker HUD supports strict source directives for adapter-owned target metadata.

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

Malformed directive-looking lines produce targeted diagnostics instead of being silently accepted. Tracker HUD can report issues such as:

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

Current platform declarations include Linux support and declared Windows/Darwin variants; the implemented syscall boundary model currently targets Linux `linux_syscall` semantics.

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
        extended_state.lua
        floating_state.lua
        protection_state.lua
        profiling.lua
        control_state.lua
        segment_state.lua

    control/
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
    system_calls.lua
```

For Linux `syscall`, Tracker HUD currently describes:

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

Warnings are not proof that a program is invalid. Tracker HUD is a static code-awareness layer, not a full verifier.

---

## Source index

Tracker HUD includes a generic per-buffer source index:

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

Tracker HUD separates universal section mechanics from reusable category behavior and concrete domain semantics:

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

Section identity uses stable string IDs. Adapter presentation controls visible order; navigation indexes are not semantic identity.

---

## Configuration

Current defaults:

```lua
require("tracker_hud").setup({
    display = "panel", -- panel is the supported display

    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

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
            require("nvim-treesitter.config").setup({
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

Tracker HUD is still experimental and primarily static.

Current limitations include:

- ASM/x86-64 state is effect-based; Tracker HUD is not a CPU emulator
- Register values may remain unknown or partial when they cannot be safely derived
- Stack and Heap modeling is currently incomplete compared with a debugger/runtime trace
- Heap facts currently depend on modeled boundary effects such as selected Linux syscalls
- Warnings are conservative state diagnostics, not formal correctness proofs
- Scope Members does not yet fully model all shadowing, mutation, lifetime, aliasing, or control-flow visibility cases
- Only the bundled Lua and ASM adapters currently provide substantial language-aware behavior
- Windows/Darwin x86-64 target declarations exist, but the deepest current syscall boundary implementation is Linux-oriented
- Full memory ownership, lifetime, pointer alias, and control-flow analysis are future work

---

## Roadmap

Planned/future work includes:

- Continue completing the ASM/x86-64 adapter and low-level state model
- Broader Stack and Heap transition semantics
- More complete warning generation from Register/Stack/Heap facts
- More instruction/event coverage where architectural facts are still missing
- Further source-index consumers where occurrence-aware inspection provides a real benefit
- Better visual highlighting/colors for section headers, active targets, warnings, and muted details
- Better Scope Members shadowing/lifetime handling
- Loop-variable discovery and richer high-level member semantics
- C/C++ pointer allocation/free and lifetime tracking
- Rust ownership and lifetime hints
- Diagnostics integration
- Optional virtual-text warnings
- Additional language adapters

---

## Current source structure

A condensed view of the current architecture:

```text
lua/tracker_hud/
    init.lua
    config.lua
    core.lua
    state.lua

    context.lua
    context_engine.lua
    treesitter_utils.lua
    construct_utils.lua
    directive_utils.lua
    target_diagnostics.lua
    treesitter_errors.lua

    inspect_mode.lua
    presentation.lua

    section.lua
    section_layout.lua
    section_model.lua
    section_tree.lua

    events.lua
    event_model.lua
    event_tree.lua

    warnings.lua
    warning_tree.lua

    scope_members.lua
    scope_member_model.lua
    scope_member_tree.lua
    symbol_state.lua

    hud.lua
    hud_sections.lua
    hud_controls.lua
    hud_nodes.lua
    hud_inspect.lua

    constructs/
        contract.lua

    source_index/
        init.lua
        compiler.lua

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

    adapters/
        contract.lua
        loader.lua
        registry.lua
        variant_utils.lua

        lua/
            init.lua
            adapter.lua

        asm/
            init.lua
            adapter.lua
            instruction_utils.lua

            arch/
                x86_64/
                    init.lua
                    adapter.lua

                    register_effects/
                        init.lua
                        integer/
                        string/
                        control/
                        stack/
                        flags/
                        processor/
                        vector/
                        mask/
                        x87/
                        amx/
                        crypto/
                        legacy/

                    instruction_events/
                        init.lua
                        memory/
                        processor/
                        control/
                        security/
                        virtualization/

                    stack_effects/
                        init.lua
                        data.lua
                        allocation.lua
                        control.lua
                        frames.lua

                    boundary_effects/
                        init.lua
                        system_calls.lua
```

Some old compatibility modules remain as empty `return {}` files after the migration. They are no longer consumed by the active categorized aggregators.

---

## Native Windows Perl note

Native Windows Perl LSP support is currently not a Tracker HUD development target.

Perl may still be usable through Tree-sitter or POSIX-like environments such as WSL, MSYS2, Linux, or OpenBSD, but native Windows Perl LSP behavior has previously been unreliable because of server/runtime/piping compatibility.

---

## Version notes

### Next version

- Made the docked panel the supported display path and aligned the README/configuration with the current panel-only default
- Added strict plugin-wide source directive parsing through `directive_utils.lua`
- Kept directive grammar core-owned while leaving directive names, accepted values, and meanings adapter-owned
- Added malformed-directive diagnostics for indentation, spacing, assignment formatting, missing terminators, invalid values, and syntax-prefix conflicts
- Added syntax-aware NASM/GAS/MASM directive comment handling
- Added Adapter Contract v1 as the canonical Tree-sitter-first adapter validator
- Made `contract_version = 1` mandatory for current bundled adapters
- Migrated both Lua and ASM adapters to the Tree-sitter-first syntax contract
- Added exact syntax validation for node types, fields, children, tokens, exclusions, scope members, range scopes, and branch alternatives
- Converted x86-64 register effects to categorized mnemonic-indexed Tree-sitter-first modules
- Split register effects into integer, string, control, stack, flags, processor, vector, mask, x87, AMX, crypto, and legacy families
- Converted x86-64 instruction events to categorized mnemonic-indexed Tree-sitter-first modules
- Added/expanded the `Events` HUD section for processor, memory, control, security, and virtualization events
- Removed fake register-visibility effects where an instruction is more accurately represented as an Event
- Converted x86-64 Stack effects to categorized mnemonic-indexed Tree-sitter-first modules
- Converted x86-64 syscall boundary effects to a categorized mnemonic-indexed module
- Removed duplicated syscall metadata in favor of one boundary/calling-convention model
- Added adapter-driven section descriptors and presentation order
- Added reusable generic Section / Model / Tree infrastructure and lookup-style section templates
- Added generic per-buffer, per-section, per-line source-index infrastructure
- Wired lazy source-index compilation into occurrence-aware Registers inspection
- Added mnemonic-as-operation Inspect semantics so inspecting a command reveals its affected register state
- Added exact operand-occurrence inspection with destination/source roles
- Made Register occurrence semantics update proactively as the cursor moves, independently of expansion state
- Preserved the previous semantic occurrence while the cursor crosses operand separators/gaps
- Made source-side Inspect actions symmetric so the same `<leader>t` action can expand and collapse targets
- Kept Scope Members inspection column-aware and tree-aware
- Preserved Lua Scope Members behavior while the low-level ASM architecture was reorganized


### `v0.7.6`

- Converted built-in adapters from loose `*_adapter.lua` files to directory-backed modules
- Moved the Lua adapter to `adapters/lua/init.lua` and `adapters/lua/adapter.lua`
- Moved the ASM adapter to `adapters/asm/init.lua` and `adapters/asm/adapter.lua`
- Moved ASM instruction parsing helpers under `adapters/asm/instruction_utils.lua`
- Moved the x86-64 ASM architecture variant under `adapters/asm/arch/x86_64/`
- Kept x86-64 register-effect modules split by instruction category under the nested architecture variant module
- Updated adapter discovery so built-in adapters are loaded from `adapters/<name>/init.lua`
- Removed old loose adapter compatibility paths after Lua and ASM adapter behavior was restored
- Preserved existing Lua Scope Members behavior and ASM/x86-64 Scope Members, Registers, Stack, Heap, and Warnings behavior

### `v0.7.5`

- Split the large x86-64 `register_effects` table into focused register-effect modules
- Kept `asm_arch/x86_64.lua` as the public x86-64 variant entry point
- Added `asm_arch/x86_64/register_effects/init.lua` to merge register-effect module files
- Preserved the existing flat `adapter.register_effects` contract for compatibility with the current context engine
- Added mnemonic-indexed register-effect lookup in `context_engine.lua`
- Reduced ASM HUD lag by dispatching only rules for the current instruction mnemonic instead of scanning every register-effect rule for every instruction
- Preserved existing ASM behavior, including unresolved/partial register-state reporting where values cannot be safely resolved

### `v0.7.4`

- Added ASM/x86-64 architecture facts for register aliases, register effects, stack effects, syscall convention data, and boundary effects
- Added generic `boundary_effects` collection in the shared context engine
- Added `context.boundary_effects` as an internal adapter-driven effect stream
- Added the Heap HUD section between Stack and Warnings
- Added Heap to Inspect Mode cycling
- Added Heap and Warnings shell handling for source-side inspect commands
- Added `heap.lua`, `heap_model.lua`, and `heap_tree.lua` to keep Heap structurally aligned with Registers and Stack
- Routed heap-category boundary effects into `context.heap`
- Rendered Heap as a tree-backed HUD section with expandable entries and source targets
- Wired Heap into source-side inspect tree navigation, expand-all, and collapse-all behavior
- Added initial x86-64 syscall heap routing for `mmap`, `munmap`, and `brk`
- Preserved the visible HUD section order: Scope, Scope Members, Registers, Stack, Heap, Warnings

### `v0.7.3`

- Added column-aware Scope Members inspect targeting
- Added nearest-node fallback for source inspect when the cursor is on whitespace on a line with Scope Members
- Changed Scope Members source inspect from reveal-only to reveal/toggle behavior
- Added source-side expand-all command for Scope Members in the current owning scope
- Added source-side collapse-all command for Scope Members in the current owning scope
- Added configurable keymaps for expanding and collapsing all Scope Members in the current owning scope
- Added HUD node tree expansion helpers for generic expand/collapse behavior
- Added current owning member scope tracking to context output
- Improved Scope Members filtering to use the nearest member-owning scope instead of the nearest syntax construct
- Added identifier return-value resolution through Scope Members symbol enrichment
- Preserved cursor-based visibility while allowing expanded state to apply as later members become visible

### `v0.7.2`

* Added active Inspect Mode state for HUD-driven source inspection
* Added HUD statusline display for the active Inspect Mode
* Added configurable Inspect Mode cycling keymap
* Added configurable source-side inspect/reveal keymap
* Added Scope Members source-side inspect reveal
* Scope Members inspect reveal now opens the Scope Members section when needed
* Scope Members inspect reveal expands the relevant node breadcrumb path
* Scope Members inspect reveal preserves source-file focus
* Scope Members inspect reveal positions the HUD cursor on the revealed row
* Added `inspect_mode.lua` for active inspect mode state
* Extracted shared Tree-sitter node helpers into `treesitter_utils.lua`
* Extracted adapter-backed construct/value helpers into `construct_utils.lua`
* Extracted Scope Member record construction and labeling into `scope_member_model.lua`
* Reduced `scope_members.lua` responsibilities by separating generic utilities, construct helpers, and member model logic

### `v0.7.1`

- Added assignment tracking for Scope Members
- Added adapter-driven assignment name/value pairing
- Added assignment values as inspectable HUD members
- Supported structural assignment values with nested field ownership

### `v0.7.0`

- Migrated construct handling to Contract v2
- Replaced ambiguous `creates_scope`-style adapter semantics with normalized `construct`, `scope`, `member`, and `value` specs
- Added adapter capabilities metadata
- Updated the Lua adapter to use quoted Tree-sitter node-type keys
- Added adapter-driven Lua value metadata for strings, numbers, booleans, nil, calls, callable values, and table values
- Moved type/value display toward adapter-provided metadata instead of core inference
- Added return statement recognition
- Added return values as Scope Members
- Added initializer value capture for local declarations
- Added structural value ranges for collected members
- Added compact structural value display such as `table [start - end]`
- Attached structural scopes to the member that owns the structural value
- Added HUD `<Tab>` source jump for rows when Show All Scope Members is enabled
- Added source-line metadata to HUD tree targets
- Improved Scope Members tree semantics so structural table scopes can nest under returns or owning values

### `v0.6.0`

- Added interactive HUD sections
- Added expand/collapse support for HUD sections
- Added `<CR>` section/control toggling inside the HUD panel
- Added double-click mouse toggling for HUD panel rows
- Added stable HUD status layout for current line, current scope lines, and scope depth
- Added `hud_sections.lua` for HUD section state and construction
- Added `hud_controls.lua` for HUD control state and control title rendering
- Added `core.lua` for shared validation helpers
- Added `scope_members.lua` for static adapter-driven scope member discovery
- Added Lua adapter `scope_members` declaration specifications
- Added Scope Members HUD section
- Added scope member filtering by active scope range and cursor position
- Added Show All Scope Members HUD control
- Added numeric line sorting for scope member display

### `v0.5.0`

- Made the Lua adapter spec-only
- Moved adapter node matching into the shared context engine
- Moved adapter node parsing into the shared context engine
- Updated the adapter registry to route parsing through the context engine
- Removed parser behavior requirements from language adapters
- Continued moving toward declarative language construct specifications

### `v0.4.2`

- Made branch alternative labels spec-driven
- Made branch alternative discovery spec-driven
- Made branch display grouping controlled by adapter specs
- Continued moving Lua adapter behavior toward declarative construct specs

### `v0.4.1`

- Added/refined shared `context_engine.lua`
- Moved generic context helpers out of the Lua adapter
- Added construct spec validation
- Expanded Lua construct specs toward a declarative format

### `v0.4.0`

- Added adapter-based context architecture
- Added Lua Tree-sitter adapter
- Migrated context parsing away from hardcoded `target_nodes`
- Added clearer missing-adapter behavior for unsupported filetypes

### `v0.3.1`

- Internal cleanup and follow-up fixes after `v0.3.0`

### `v0.3.0`

- Added runtime HUD panel position command
- Refactored config/state handling
- Cleaned public configuration surface
- Updated README for panel position and runtime controls

---

## Author

Created by [@Ebdsaleh](https://github.com/Ebdsaleh).

---

## License

This project is licensed under the Apache License 2.0.

