# Tracker_HUD

By [@Ebdsaleh](https://github.com/Ebdsaleh)

Tracker HUD is an experimental Neovim plugin that displays a live code-awareness HUD based on the cursor position. It uses Tree-sitter to track the current function, nested scope depth, and branch context, giving a breadcrumb-style view of where the cursor is inside the code.

The long-term goal is to extend this into a systems-programming analysis HUD capable of tracking stack and heap state in assembly, unfreed pointers in C/C++, and ownership/lifetime status in Rust.

> Current status: early proof-of-concept, but usable. Tracker HUD currently focuses on cursor-aware structural tracking, interactive panel display, panel positioning/resizing, scope breadcrumbs, adapter-driven Lua scope member discovery, and a modular spec-driven adapter architecture.

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
- Shared HUD control registry

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
| `lua` | Supported |
| other filetypes | HUD appears, but structural adapter support is not yet implemented |

Adapters are lightweight language construct specifications. The shared context engine handles common Tree-sitter helpers, construct validation, node matching, node parsing, scope construction, branch display formatting, and context output.

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
| `<CR>` | Toggle the HUD section or control under the cursor |
| Double left click | Toggle the HUD section or control under the mouse cursor |

The HUD panel preserves panel cursor position during interactive updates.

### Scope Members

The `Scope Members` section displays statically discovered local declarations from the current language adapter.

For Lua, Tracker HUD currently detects local declarations using Tree-sitter and the Lua adapter's `scope_members` specification.

By default, Scope Members shows declarations relevant to the active scope and current cursor position.

The HUD also provides a control:

```text
[ ] Show All Scope Members
```

When enabled:

```text
[+] Show All Scope Members
```

the Scope Members section displays all discovered scope members from the current file.

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
- Scope member tracking is static and name-based only
- Scope Members currently tracks declarations, not runtime values
- Scope Members does not yet fully model shadowing, lifetime, mutation, or control-flow visibility
- Registers, Stack, and Warnings are placeholder sections

It does **not yet** perform full memory, ownership, lifetime, stack, or heap analysis.

---

## Roadmap

Planned future work:

- Better panel formatting
- Structured Scope Member entries instead of display strings
- Function parameter discovery
- Loop variable discovery
- Better shadowing and lifetime handling for Scope Members
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
    scope_members.lua
    hud.lua
    hud_sections.lua
    hud_controls.lua
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
