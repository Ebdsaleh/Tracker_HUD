# Tracker_HUD

By [@Ebdsaleh](https://github.com/Ebdsaleh)

Tracker HUD is an experimental Neovim plugin that displays a live code-awareness HUD based on the cursor position. It uses Tree-sitter to track the current function, nested scope depth, and branch context, giving a breadcrumb-style view of where the cursor is inside the code.

The long-term goal is to extend this into a systems-programming analysis HUD capable of tracking stack and heap state in assembly, unfreed pointers in C/C++, and ownership/lifetime status in Rust.

> Current status: early proof-of-concept, but usable. Tracker HUD currently focuses on cursor-aware structural tracking, interactive panel display, panel positioning/resizing, scope breadcrumbs, adapter-driven Lua scope member discovery, return-value inspection, structural value ownership, source-side Scope Members inspect controls, and a Contract v2 spec-driven adapter architecture.

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
| `lua` | Supported: scopes, branches, fields, locals, return values, scalar values, calls, and structural table values |
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
| `<leader>.` | Expand all Scope Members in the current owning scope |
| `<leader>,` | Collapse all Scope Members in the current owning scope |

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
- Registers, Stack, and Warnings are placeholder sections

It does **not yet** perform full memory, ownership, lifetime, stack, or heap analysis.

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
- ASM stack pointer / heap tracking
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
    hud.lua
    hud_sections.lua
    hud_controls.lua
    hud_nodes.lua
    constructs/
        contract.lua
    adapters/
        loader.lua
        registry.lua
        lua_adapter.lua
```
---

## Native Windows Perl note

Native Windows Perl LSP support is currently not a target for Tracker HUD development.

Perl support may still be possible through Tree-sitter or through POSIX-like environments such as WSL, MSYS2, Linux, or OpenBSD, but native Windows Perl LSP behavior has proven unstable due to server/runtime/piping compatibility issues.

---

## Version notes

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
