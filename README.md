# Tracker_HUD

By [@Ebdsaleh](https://github.com/Ebdsaleh)

Tracker HUD is an experimental Neovim plugin that displays a live code-awareness HUD based on the cursor position. It uses Tree-sitter to track the current function, nested scope depth, and branch context, giving a breadcrumb-style view of where the cursor is inside the code.

The long-term goal is to extend this into a systems-programming analysis HUD capable of tracking stack and heap state in assembly, unfreed pointers in C/C++, and ownership/lifetime status in Rust.

> Current status: early proof-of-concept, but usable. Tracker HUD currently focuses on cursor-aware structural tracking, panel display, panel positioning/resizing, scope breadcrumbs, and a modular adapter-based context architecture.

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

Adapters are intended to become lightweight language construct specifications. The shared context engine handles common Tree-sitter helpers, construct validation, scope construction, branch display formatting, and context output.

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

It does **not yet** perform full memory, ownership, lifetime, stack, or heap analysis.

---

## Roadmap

Planned future work:

- Better panel formatting
- Expandable/collapsible HUD sections
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
    state.lua
    context.lua
    context_engine.lua
    hud.lua
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


