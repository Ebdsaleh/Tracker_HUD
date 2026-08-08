# Tracker_HUD

By [@Ebdsaleh](https://github.com/Ebdsaleh)

Tracker HUD is an experimental Neovim plugin that displays a live code-awareness HUD based on the cursor position. It uses Tree-sitter plus adapter-provided language facts to track the current function, nested scope depth, branch context, scope members, and low-level ASM state, giving a breadcrumb-style view of where the cursor is inside the code.

The long-term goal is to extend this into a systems-programming analysis HUD capable of tracking stack and heap state in assembly, unfreed pointers in C/C++, and ownership/lifetime status in Rust.

> Current status: early proof-of-concept, but usable. Tracker HUD currently focuses on cursor-aware structural tracking, interactive panel display, panel positioning/resizing, scope breadcrumbs, adapter-driven Lua scope member discovery, return-value inspection, structural value ownership, source-side inspect controls, ASM/x86-64 register, stack, heap, and warning tracking, generic boundary-effect collection, split x86-64 register-effect modules, and mnemonic-indexed register-effect lookup for faster ASM HUD updates.

---

## Features

- Tree-sitter-powered cursor context tracking
- Function/block scope breadcrumb display
- Nested scope depth tracking
- Basic branch awareness for `if` / `elseif` / `else`
- Winbar display mode
- Docked panel display mode
- Panel positions:
  - `left`
  - `right`
  - `top`
  - `bottom`
- Launch-time automatic panel sizing
- Runtime panel resizing command
- Runtime panel position command
- Configurable resize keymaps
- Panel focus restoration so the HUD does not steal editing focus
- HUD panel closes with the source file
- Adapter-based language context architecture
- Lua construct adapter with spec-driven branch alternatives
- Clear missing-adapter messages for unsupported filetypes
- Interactive HUD sections
- Expand/collapse HUD sections with `<CR>`
- Double-click HUD section/control interaction with the mouse
- Stable HUD status block for current line, scope lines, and scope depth
- Scope Members section for adapter-driven local declaration discovery
- Scope Members filtering by active scope and cursor position
- Show All Scope Members HUD control
- `<Tab>` source jump from HUD rows when Show All Scope Members is enabled
- Contract v2 adapter model using `construct`, `scope`, `member`, and `value` specs
- Adapter-driven value type labels for Lua scalar, structural, callable, and call values
- Lua return statement tracking
- Return values displayed as scope members
- Structural values such as Lua tables attach under their owning member
- Shared HUD control registry
- Active Inspect Mode displayed in the HUD panel statusline
- Configurable Inspect Mode cycling keymap
- Configurable source-side inspect/reveal keymap
- Source-side Scope Members inspect reveal
- Scope Members inspect reveal expands the relevant HUD breadcrumb path
- Scope Members inspect reveal keeps focus in the source file
- Scope Members inspect reveal positions the HUD cursor on the revealed row
- Shared Tree-sitter utility helpers
- Shared adapter construct/value utility helpers
- Dedicated Scope Member model helpers for member record creation and labeling
- Column-aware Scope Members inspect targeting
- Scope Members inspect fallback to nearest member on the current line
- Source-side Scope Members inspect toggle for individual expandable members
- Expand all Scope Members in the current owning scope
- Collapse all Scope Members in the current owning scope
- Scope Members expansion state persists as cursor-filtered members become visible
- Identifier return values can resolve to visible scope members where possible
- Scope Members filtering uses the nearest member-owning scope instead of the nearest syntax construct
- ASM adapter architecture with x86-64 variant support
- x86-64 architecture directive detection using `; arch=x86-64;`
- ASM label range scopes for label-local context
- x86-64 register section with canonical register families and aliases
- x86-64 register write effects for common instructions such as `mov`, `xor`, `add`, `sub`, `inc`, and `dec`
- Broad x86-64 instruction-effect coverage split into focused register-effect modules
- Mnemonic-indexed register-effect lookup for faster ASM register tracking
- x86-64 stack section with stack concepts and stack effects such as `push`, `pop`, `call`, `ret`, `leave`, `sub rsp`, and `add rsp`
- Generic boundary-effect collection for adapter-described runtime/system boundaries
- x86-64 syscall convention spec with syscall-number, return, and argument registers
- Heap HUD section between Stack and Warnings
- Heap model/tree/rendering pipeline using `heap.lua`, `heap_model.lua`, and `heap_tree.lua`
- Heap entries routed from heap-category boundary effects such as `mmap`, `munmap`, and `brk`
- Heap included in Inspect Mode cycling
- Heap supports source-side inspect, expand-all, collapse-all, and panel-row expansion
- Warnings section with tree-backed warning entries from adapter rules and Tree-sitter syntax diagnostics

---

## Requirements

- Neovim with Lua support
- `nvim-treesitter`
- Tree-sitter parsers for the languages you want to inspect

Tracker HUD requires both a Tree-sitter parser and a Tracker HUD adapter for full structural context. If a parser exists but no adapter is available for the filetype, the HUD will still appear and report that no adapter is available.

---

## Language adapters

Tracker HUD now uses a modular adapter architecture.

The HUD shell can appear for many filetypes, but structural context is only available when Tracker HUD has an adapter for that filetype.

Current adapter support:

| Filetype | Status |
|---|---|
| `lua` | Supported: scopes, branches, fields, locals, return values, scalar values, calls, assignments, and structural table values |
| `asm`, `nasm`, `gas`, `s` | Supported through the ASM adapter with x86-64 variant facts: labels, scope members, registers, register aliases, broad register effects, mnemonic-indexed effect lookup, stack effects, syscall boundary effects, heap boundary routing, and warning rules |
| other filetypes | HUD appears, but structural adapter support is not yet implemented |

Adapters are lightweight language construct specifications. The shared context engine handles common Tree-sitter helpers, construct validation, node matching, node parsing, scope construction, branch display formatting, value metadata routing, and context output.

Tracker HUD uses a Contract v2 adapter model. Adapters describe language syntax using four normalized concepts:

```text
construct
scope
member
value
```

This keeps the engine language-neutral. For example, Lua tables, JavaScript objects, Python dictionaries, Rust structs, C structs, and custom DSL object blocks can all be described as structural values/scopes by their adapters without requiring engine changes.


### ASM / x86-64 adapter

Tracker HUD includes an ASM adapter with an x86-64 architecture variant.

Add this directive near the top of an ASM file to select the x86-64 variant:

```asm
; arch=x86-64;
```

The x86-64 variant currently describes:

- label range scopes
- labels and `global` declarations as scope members
- canonical registers such as `rax`, `rbx`, `rcx`, `rsp`, and `rbp`
- register alias families such as `rax` / `eax` / `ax` / `ah` / `al`
- broad static register effects for x86-64 instructions
- split register-effect modules grouped by instruction category
- mnemonic-indexed register-effect lookup in the context engine
- stack effects for push/pop/call/return/frame operations
- syscall convention data
- generic boundary effects for syscall-style runtime/system boundaries
- heap-category syscall effects such as `mmap`, `munmap`, and `brk`
- warning rules for unresolved or missing low-level state

This is still static and syntax/effect based. It is not an emulator and does not calculate full runtime values. The x86-64 register-effect rules describe conservative instruction effects; the context engine indexes those rules by mnemonic so the HUD does not need to scan every rule for every instruction.

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

A fuller example:

```lua
{
    "Ebdsaleh/Tracker_HUD",
    config = function()
        require("tracker_hud").setup({
            display = "panel",
            panel_position = "left",
            panel_size = "auto",
        })
    end,
}
```

---

## Important leader-key note

If you use Tracker HUD's default keymaps, set your leader key **before** Lazy loads plugins.

Good:

```lua
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
    -- plugins here
})
```

Avoid setting `mapleader` after `lazy.setup()`, because plugin mappings such as `<leader>+`, `<leader>-`, and `<leader><CR>` may be created using Neovim's default leader instead of the key you expect.

---

## Basic setup

### Winbar mode

```lua
require("tracker_hud").setup({
    display = "winbar",
})
```

Example output:

```text
[+] HUD: Scope: [29] function foo() -> [52] While -> ([61] If : Else [64])
```

### Panel mode

```lua
require("tracker_hud").setup({
    display = "panel",
    panel_position = "left",
    panel_size = "auto",
})
```

Panel mode opens a docked HUD window and keeps focus in the source file.

---

## Interactive HUD panel

In panel mode, Tracker HUD displays multiple HUD sections.

Current sections include:

```text
Scope
Scope Members
Registers
Stack
Heap
Warnings
```

Sections can be expanded or collapsed from inside the HUD panel.

| Input | Action |
|---|---|
| `<CR>` | Toggle the HUD section, control, or node under the cursor |
| `<Tab>` | Jump to the selected HUD row's source location when Show All Scope Members is enabled |
| Double left click | Toggle the HUD section or control under the mouse cursor |

The HUD panel preserves panel cursor position during interactive updates.

### Scope Members

The `Scope Members` section displays statically discovered members from the current language adapter.

For Lua, Tracker HUD currently detects:

- local declarations
- function parameters
- table fields
- return values
- scalar values such as strings, numbers, booleans, and nil
- call values
- structural table values

By default, Scope Members shows members relevant to the active scope and current cursor position.

The HUD also provides a control:

```text
[ ] Show All Scope Members
```

When enabled:

```text
[+] Show All Scope Members
```

the Scope Members section displays all discovered scope members from the current file. In this mode, pressing `<Tab>` on a scope/member row jumps the source cursor to that row's source location.

Structural values are attached under the member that owns them. For example, a returned Lua table is shown under the `return_value` member instead of floating as a separate first-class scope member.

Scope Members also supports source-side inspection commands.

When `Inspect Mode` is set to `Scope Members`, pressing the source inspect keymap reveals the member at the source cursor position. If the matched member is expandable, the command toggles that member open or closed.

Inspect targeting is column-aware. If the cursor is not directly on a symbol or value, Tracker HUD falls back to the nearest Scope Members node on the current line.

Tracker HUD can also expand or collapse all Scope Members inside the current owning scope. This updates the HUD node expansion state without disabling cursor-based visibility filtering. Members that appear later in the scope remain hidden until the source cursor reaches them, but when they become visible they use the stored expanded/collapsed state.


### Registers, Stack, and Heap

For supported low-level adapters, Tracker HUD can display register, stack, and heap-oriented facts.

For ASM/x86-64, the `Registers` section currently tracks architecture registers, register alias families, and static instruction effects up to the cursor position. Register effects are declared by the x86-64 adapter and indexed by mnemonic in the shared context engine before being normalized for display. The `Stack` section tracks architecture stack concepts and common stack effects such as pushes, pops, calls, returns, and frame restoration.

The `Heap` section is now a real tree-backed HUD section. It is populated from generic boundary effects whose resolved category is `heap`. In the x86-64 adapter, this includes syscall boundary effects such as `mmap`, `munmap`, and `brk`.

Example Heap output:

```text
Heap [-]
[-] (memory region) mmap #9 -> rax
    kind: memory_region
    category: heap
    effect key: 9
    result register: rax
    source line: 9
```

The Heap section supports panel-row expansion, source-side inspect mode, expand-all, and collapse-all using the same tree navigation model as Registers and Stack.


### Warnings

The `Warnings` section displays tree-backed warning entries collected from adapter-described warning rules and Tree-sitter syntax diagnostics. For ASM/x86-64, warnings are conservative: they report unresolved, missing, or syntax-level state that Tracker HUD can describe from static facts, but they do not prove full runtime correctness.

---

## Configuration

Default configuration:

```lua
require("tracker_hud").setup({
    display = "winbar", -- "winbar" or "panel"

    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

    -- "left", "right", "top", or "bottom"
    panel_position = "right",

    -- Number = fixed size.
    -- "auto" = calculate once when panel opens.
    panel_size = "auto",

    -- Auto-size padding.
    -- Left/right uses width padding.
    -- Top/bottom uses height padding.
    panel_auto_width_padding = 2,
    panel_auto_height_padding = 2,

    -- Fallbacks if auto-size cannot calculate.
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
})
```

---

## Display modes

### `display = "winbar"`

Uses Neovim's winbar to show a compact one-line HUD.

```lua
require("tracker_hud").setup({
    display = "winbar",
})
```

### `display = "panel"`

Uses a docked panel window.

```lua
require("tracker_hud").setup({
    display = "panel",
    panel_position = "left",
    panel_size = "auto",
})
```

The panel is a scratch buffer and should not be treated as a source file by Tree-sitter or LSP.

---

## Panel positioning

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

Auto sizing is calculated once when the panel opens.

It does **not** constantly grow and shrink while you move the cursor.

For left/right panels, auto size is based on the longest rendered HUD line.

For top/bottom panels, auto size is based on the number of rendered HUD lines.

### Fixed size

```lua
panel_size = 52
```

For left/right panels, this means 52 columns.

For top/bottom panels, this means 52 rows.

Usually, top/bottom panels should use a smaller value:

```lua
require("tracker_hud").setup({
    display = "panel",
    panel_position = "bottom",
    panel_size = 9,
})
```

---

## Commands

### `:TrackerHudSize`

Resize the HUD panel while Neovim is running.

```vim
:TrackerHudSize 52
```

For left/right panels, this changes the panel width.

For top/bottom panels, this changes the panel height.

You can also reset the panel to auto-calculated size:

```vim
:TrackerHudSize auto
```

### `:TrackerHudPos`

Move the HUD panel while Neovim is running.

```vim
:TrackerHudPos left
:TrackerHudPos right
:TrackerHudPos top
:TrackerHudPos bottom
```

This changes the current session only. It does not rewrite your Neovim configuration.

---

## Keymaps

Tracker HUD registers normal-mode panel resize keymaps by default.

| Mapping | Action |
|---|---|
| `<leader>+` | Increase HUD panel size |
| `<leader>-` | Decrease HUD panel size |
| `<leader><CR>` | Auto-size HUD panel |
| `<leader><leader>` | Cycle active Inspect Mode |
| `<leader>t` | Inspect/reveal/toggle current source cursor in the active HUD section |
| `<leader>.` | Expand all entries for the active Inspect Mode where supported |
| `<leader>,` | Collapse all entries for the active Inspect Mode where supported |

Inspect Mode currently cycles through:

```text
Scope -> Scope Members -> Registers -> Stack -> Heap -> Warnings
```

`<leader>.` and `<leader>,` are tree-aware for Scope Members, Registers, Stack, and Heap. Warnings is tree-backed and can be inspected as a HUD section; warning entries are still static/diagnostic facts rather than full program-analysis results.

The size change amount is controlled by:

```lua
keymaps = {
    step = 2,
}
```

For left/right panels, `step = 2` means 2 columns.

For top/bottom panels, `step = 2` means 2 rows.

### Custom keymaps

```lua
require("tracker_hud").setup({
    keymaps = {
        enabled = true,
        increase_size = "<leader>+",
        decrease_size = "<leader>-",
        auto_size = "<leader><CR>",
        cycle_inspect_mode = "<leader><leader>",
        inspect_source = "<leader>t",
        expand_all_members_in_scope = "<leader>.",
        collapse_all_members_in_scope = "<leader>,",
        step = 4,
    },
})
```

### Disable keymaps

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
        "Ebdsaleh/Tracker_HUD",
        config = function()
            require("tracker_hud").setup({
                display = "panel",
                panel_position = "left",
                panel_size = "auto",

                show_line_numbers = true,
                show_branch_context = true,
                separator = " -> ",

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

    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.config").setup({
                ensure_installed = {
                    "lua",
                    "rust",
                    "c",
                    "cpp",
                    "python",
                    "vim",
                    "vimdoc",
                    "query",
                },
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
            })
        end,
    },
})
```

---

## Current limitations

Tracker HUD is still early.

Current functionality is focused on structural awareness:

- current function/scope
- nested scope depth
- basic `if` / `elseif` / `else` branch context for Lua
- HUD panel behavior
- runtime panel position/size controls
- resizing and focus handling
- Scope member tracking is static and syntax-based only
- Scope Members tracks adapter-described values, not runtime values
- Local initializer tracking is currently syntax-based and depends on adapter support
- Scope Members does not yet fully model shadowing, lifetime, mutation, or control-flow visibility
- Registers, Stack, Heap, and Warnings are static/effect-based sections, not full runtime analysis
- ASM register-effect coverage is broad but conservative; unknown or partial state may still appear when the HUD cannot safely resolve a value

It does **not yet** perform full memory, ownership, lifetime, stack, heap, alias, or control-flow analysis.

---

## Roadmap

Planned future work:

- Better panel formatting
- Structured Scope Member entries instead of display strings
- Loop variable discovery
- Better shadowing and lifetime handling for Scope Members
- More complete adapter capability declarations
- Additional Contract v2 adapter documentation
- HUD highlights/colors for section headers, controls, warnings, and muted text
- Rust ownership and lifetime hints
- More complete ASM stack pointer / heap tracking
- Heap-state transitions for allocate/free/unmap/invalidated memory
- More complete warning generation from Heap/Register/Stack facts
- C/C++ pointer allocation/free tracking
- Diagnostics integration
- Optional virtual text warnings
- Additional language adapters and analyzer modules

Current core structure:

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
    inspect_mode.lua
    scope_members.lua
    scope_member_model.lua
    scope_member_tree.lua
    symbol_state.lua
    registers.lua
    register_model.lua
    register_tree.lua
    stack.lua
    stack_model.lua
    stack_tree.lua
    heap.lua
    heap_model.lua
    heap_tree.lua
    hud.lua
    hud_sections.lua
    hud_controls.lua
    hud_nodes.lua
    hud_inspect.lua
    constructs/
        contract.lua
    adapters/
        loader.lua
        registry.lua
        lua_adapter.lua
        asm_adapter.lua
        asm_arch/
            x86_64.lua
            x86_64/
                register_effects/
                    init.lua
                    data_movement.lua
                    arithmetic.lua
                    bitwise.lua
                    control_flow.lua
                    stack_frame.lua
                    system_flags.lua
                    system.lua
                    simd.lua
                    crypto.lua
                    misc.lua
```
---

## Native Windows Perl note

Native Windows Perl LSP support is currently not a target for Tracker HUD development.

Perl support may still be possible through Tree-sitter or through POSIX-like environments such as WSL, MSYS2, Linux, or OpenBSD, but native Windows Perl LSP behavior has proven unstable due to server/runtime/piping compatibility issues.

---

## Version notes

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

