# Tracker_HUD Visual Language Specification v0.4

## Status

This document is the current finalized visual-language baseline for the post-`v0.7.7` development snapshot.

It is finalized enough to live in `/docs/` and guide implementation, README wording, and future renderer work. It should still be treated as a living specification: exact color choices can change, and future ASCII/graphical renderers may add presentation forms, but the semantic rules in this document should remain stable unless the project intentionally changes them.

---

## Purpose

Tracker_HUD is an accessibility-first state tracker for Neovim.

The visual language exists so the HUD can explain code state consistently across:

- the current text panel
- low-color terminals
- monochrome or unreliable terminal environments
- future ASCII/state diagrams
- possible future graphical views

The goal is not decoration. The goal is to make program state easier to read, easier to learn, and easier to keep in working memory.

---

## Core philosophy

Tracker_HUD should prioritize:

1. **Cursor-truth** - show what is true about the token, operand, symbol, scope, or state at the current cursor position.
2. **State-truth** - show what machine/program state exists because of code up to the cursor.
3. **Semantic consistency** - the same concept should look and feel like the same concept everywhere.
4. **Accessibility** - visual cues should be simple, stable, low-clutter, and usable under fatigue or stress.
5. **Terminal survivability** - meaning must survive truecolor, 256-color, 16-color, monochrome, SSH, tmux, OpenBSD/PuTTY-style setups, and broken color environments.
6. **Renderer independence** - semantic facts must stay separate from specific text, ASCII, or graphical renderers.

---

## Foundational rule

Tracker_HUD visuals are governed by two layers:

```text
semantic identity
    -> what something means

relevance state
    -> how important/focused/current it is right now
```

Semantic identity determines the category, color family, tag, and marker.

Relevance state determines intensity, focus treatment, emphasis, and active-path presentation.

Relevance must not erase semantic identity.

---

## Core section and Inspect Mode presentation

Tracker_HUD has three mandatory language-neutral core sections (Scope,
Scope Members, Warnings). Adapters explicitly opt into additional permanent
inspection surfaces. ASM, C, and C++ expose Registers, Events, Stack, and
Heap even when no facts have been discovered at the cursor.

The default palette uses existing Neovim highlight links for the original
titles, with independent restrained accents for the low-level headings.
It is a shared HUD mapping by section ID, **not an ASM-only rule**.

| Section | Default title style / palette source | Purpose |
|---|---|---|
| `Scope` | `Function` | Scope title and mode name |
| `Scope Members` | `String` | Members title and mode name |
| `Registers` | Garnet red `#D68187` | Registers title and mode name |
| `Events` | `Keyword` | Events title and mode name, sharing the `Target:` label accent |
| `Stack` | Warm gold `#D7B45D` | Stack title and mode name |
| `Heap` | Muted copper `#CE906A` | Heap title and mode name |
| `Warnings` | `DiagnosticWarn` | Warnings title and mode name |

The original four styles are colorscheme links, not hardcoded RGB values.
The three low-level heading accents are **default colour definitions**,
selected as distinct section identities. They do not change the colours
or meanings of register, stack, or heap *facts*. Garnet is deliberately
lighter than literal dark blood-red to stay legible on the selected
charcoal heading/statusline surface (minimum 4.5:1 contrast).
The **default** for both the `Target:` label and `Events` section title is
the shared `Keyword` highlight link. In the current ERIDU colour scheme,
`Keyword` is the preferred purple accent. The `Events` event *facts* keep
their existing, independent `Special` semantic colour; only the section
heading and its selected Inspect Mode name change.

These values are the initial **Tracker_HUD defaults**, not a locked user theme.
A later user-defined theme feature should override the named, namespaced
styles (`EventsSectionTitle`, `TargetLabel`, etc.) without changing
language-adapter logic or hardcoding one palette into source facts.
The full end-user theme configuration system is not implemented yet.

The namespaced styles include `<prefix>ScopeSectionTitle`,
`<prefix>ScopeMembersSectionTitle`, `<prefix>RegistersSectionTitle`,
`<prefix>EventsSectionTitle`, `<prefix>StackSectionTitle`,
`<prefix>HeapSectionTitle`, and `<prefix>WarningSectionTitle`. Their
names make future user-theme overrides possible without editing adapters.
Other, unregistered adapter-specific sections retain generic styling.

In the panel statusline the literal **`Inspect:` prefix stays at a
neutral, readable foreground** (the editor's `Normal` text colour against
charcoal). Only the selected section's name uses its matching theme-linked
foreground. Do not tint the prefix.

The **entire Tracker_HUD panel statusline**, including the empty area after
`Inspect: <mode>`, now uses the **same charcoal background** as the active
section's highlight bar: `#2D3138` (cterm `236`). This applies to both
active and inactive HUD-window statuslines; other editor windows keep their
original `StatusLine`/`StatusLineNC` colours. Dedicated namespaced statusline
segments preserve the section-specific foreground accents (including
Registers, Stack and Heap) while avoiding the lighter statusline background.
No global `StatusLine`, `StatusLineNC`, `IncSearch`, or semantic highlight
group is overwritten.

The current Inspect Mode also produces a **visible focus cue in the HUD**:
the selected root-section title is **bold and underlined** and receives
a root-heading-only charcoal background (`#2D3138`, 256-colour fallback
`236`). This is a deliberate exception to theme-linked hues: it is a
background contrast surface, *not* a semantic foreground colour. Previously
the selected line inherited the theme's `IncSearch` background, which
could be too bright for green title text. The dedicated
`<prefix>InspectHeader` group sets no foreground and doesn't modify
other `active` rows or source-relevant tree entries.

The heading focus follows Inspect Mode even when the cursor has no matching
source fact in the selected section. **Every unselected root heading keeps
its section colour**, softened only slightly for headings with explicit
RGB defaults (12% blend toward the muted accent). Theme-linked headings
keep their colourscheme hue without source-relevance dimming. The selected
title retains its full accent plus bold/underline and the charcoal
background. This is deliberately independent of historical/contextual
source relevance: those relevance states still affect the facts inside
a section, not the stable section identity. The source-context `*`
markers remain independent.
Do **not** underline every descendant or shadow every row of a section.

The source-location `*` marker is **not** an Inspect Mode selection marker.
For example, the Scope Members tree seeds the current owning lexical scope
even before a specific member is encountered. Its containing source range can
remain relevant at the cursor, so Scope Members may still show `*` while
`Inspect: Warnings` is selected. This is intentional source context,
**not** a reason to keep Scope Members' heading highlighted. Header
background and title underline follow Inspect Mode exclusively.

These visual effects do not claim that a warning exists or program state
has changed. The `String` group is used only to give Scope Members a
distinct theme-linked heading hue; it does **not** classify members as strings.
A different user colorscheme may render groups differently.

Plain mode remains strictly colorless. The active root title is underlined
as before; all other HUD text and the entire statusline label are neutral.
The **statusline still has the same neutral charcoal background**; its title,
marker, `Inspect:` prefix, and mode name use neutral foregrounds. Only
individually targeted active-path rows may get a neutral shadow.
The `InspectHeader` charcoal root-row surface is **not** applied in plain
mode. No background highlight is added across an entire Scope/Scope Members
tree.

This behavior separates the visual-language layers:

- **Semantic identity**: section name and its theme-linked or explicit default accent, even while another section is selected.
- **Inspect focus**: bold/underline and root-heading highlight on the selected section only.
- **Source relevance**: separate source-cursor facts and their `*` markers, which can remain on another section.

Validate with a fresh Neovim session:

```bat
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua"
nvim samples/python/python_adapter_validation.py
```

Cycle Inspect Mode (default `<leader><leader>`) and compare the
selected root title with the statusline. Try `:HudVisualMode rich` and
`:HudVisualMode plain`. Check `Scope`, `Scope Members`, `Registers`,
`Events`, `Stack`, `Heap`, and `Warnings` in the ASM, C, and C++
fixtures. Adapter-specific section visibility still follows each adapter's
presentation order.

---

## Color is enhancement, not meaning

Tracker_HUD must never depend on color alone.

Color is a useful enhancement layer, but meaning must also be available through:

- stable text labels
- semantic tags
- compact markers
- indentation
- ordering
- typography where supported
- active-path markers such as `*`
- neutral background emphasis in plain mode
- explicit relationships such as `value flow: 60 -> rax`

This is required for:

- monochrome terminals
- low-color terminals
- remote shells
- OpenBSD/PuTTY/ksh-style minimal environments
- screen-reader-adjacent output modes
- users with color vision differences
- users who need explicit terminology rather than subtle color distinctions

---

## Hex-width color guides

Tracker_HUD may color hexadecimal literal digits by hardware-width bands. This
feature is a positional reading aid for low-level work, not a replacement for
semantic labels.

The bands are applied from the right edge of a `0x...` literal:

| Band | Bits | Color family | Example marker |
|---|---:|---|---|
| Low byte | 0-7 | Blue | `BB` |
| 16-bit extension byte | 8-15 | Green | `GG` |
| 32-bit high word | 16-31 | Orange | `OOOO` |
| 64-bit upper double-word | 32-63 | Magenta | `MMMMMMMM` |

Example:

```text
0x7FFF00000000000F
0xMMMMMMMMOOOOGGBB
```

This lets the eye identify magnitude without counting nibbles. The blue byte is
the fixed low-end anchor, so values used as 8-bit data, 16-bit addresses,
32-bit values, or 64-bit values remain visually separable even when the text is
mostly leading zeroes. In plain visual mode the HUD remains colorless, so these
bands are intentionally disabled along with other semantic colors.

---

## Runtime visual modes

Tracker_HUD currently supports these public visual modes:

| Mode | Purpose |
|---|---|
| `auto` | Choose annotation behavior from terminal capability and panel width |
| `rich` | Color-first HUD with no semantic tags or markers |
| `tagged` | Explicit semantic tags such as `[SRC]`, `[DST]`, `[REG]`, and `[FAIL]` |
| `markers` | Compact semantic markers such as `<`, `>`, `R`, `x`, `?`, and `@` |
| `plain` | Colorless/plain-text mode with neutral active-path emphasis |

The command name uses the configured namespace prefix.

Default command examples:

```vim
:HudVisualMode auto
:HudVisualMode rich
:HudVisualMode tagged
:HudVisualMode markers
:HudVisualMode plain
```

With:

```lua
namespace = {
    prefix = "MyHud",
}
```

the command becomes:

```vim
:MyHudVisualMode plain
```

---

## Runtime presentation presets (separate from visual modes)

The **meaning/detail** preset is independent of `:HudVisualMode` and of
`Inspect` section selection. It is a reversible reading lens, **not**
another language adapter and not a new inference pass.

```vim
:HudPresentation
:HudPresentation standard
:HudPresentation learning
:HudPresentation cycle
```

- `standard` — unchanged full technical text HUD (default).
- `learning` — early accessibility-first text preview. Adds one short
  explanation for a currently discovered register-state fact when
  available, explicitly labelling source inference rather than execution.
  Retains **all existing sections**, expansion selections, colour rules
  and source position. Other sections still show their technical detail.
- `cycle` — toggles between the implemented presets using existing
  in-memory HUD state; it does not reparse merely to change presentation.

These are implemented **text presentations only**. Future graphics,
animation, byte/bit cells and reduced-motion/accessibility alternatives
are design objectives, not selectable renderers yet. Never report them
as active modes before they exist.

The command respects the namespace prefix: with `namespace.prefix =
"MyHud"`, use `:MyHudPresentation cycle`.

An optional user-chosen keymap avoids overriding existing mappings:

```lua
require("tracker_hud").setup({
    keymaps = { cycle_presentation_mode = "<leader>hp" },
})
```

`:HudVisualMode rich` still controls semantic colour/tags, and the
normal Inspect cycle still selects Scope, Registers, Events and so on;
neither is changed by switching presentation presets.

### Presentation contract for future graphical modes

Every renderer consumes normalized, cursor-visible facts (same state
and certainty). Different formats may show:
- 64-bit registers in faithful **8-byte / 64-bit** diagrams, including
  byte order, register aliases and known/unknown bit lanes;
- arrows connecting source operands to destination state, with a text
  equivalent;
- simplified explanations for younger learners and explicit advanced
  detail on demand.

Never imply an unknown memory load is a confirmed number, use colour
alone as the information carrier, or remove the user's ability to
switch back without navigation.

---

## Plain mode

Plain mode is the dedicated colorless/unreliable-terminal mode.

Current plain-mode rules:

```text
all HUD text              -> bright white
semantic colors           -> disabled
tags                      -> disabled by visual mode
markers                   -> disabled by visual mode
inactive dimming          -> disabled
active root-section title -> underlined
active/affected rows      -> neutral background shadow
```

Plain mode intentionally does **not** dim inactive text. If text is bright white everywhere, then the neutral background shadow becomes the important contrast cue.

Plain mode also intentionally does **not** underline every active descendant. That was too visually loud. Only the active root-section title should be underlined.

### Plain shadow targeting

Plain-mode background shadow must be targeted.

Correct behavior:

```text
Registers [-] *          <- active root title: underline
  [-] General            <- category/container: no shadow just because it contains a child
  *[-] rax [full]        <- affected row: shadow
    - role: destination  <- active row details may shadow when this row is the focused active path
```

Incorrect behavior:

```text
Registers [-] *
  [-] General            <- should not be shadowed merely because Registers is active
  [-] Pointers           <- should not be shadowed merely because Registers is active
  [-] Flags              <- should not be shadowed merely because Registers is active
  [-] Vector             <- should not be shadowed merely because Registers is active
```

The shadow follows explicit active/affected row state, similar to the `*` active-path marker. It should not leak to category/container rows.

Current low-level shadow targeting applies to:

```text
Registers
Events
Stack
Heap
Warnings
```

`Scope` and `Scope Members` are intentionally quieter for now. They can be considered later, but shadowing them too aggressively can become noisy.

---

## Display capability tiers

The visual-language model describes four display capability tiers:

| Tier | Meaning |
|---|---|
| `truecolor` | Full semantic color families |
| `color_256` | Reduced but still meaning-separated colors |
| `ansi_16` | Broad colors plus tags, markers, and typography |
| `monochrome` | Meaning preserved without color |

Terminal detection is best-effort. Users can force visual behavior through configuration and `:HudVisualMode`.

---

## Width modes

The visual-language model also includes width modes:

| Mode | Purpose |
|---|---|
| `full` | Full labels and semantic tags |
| `condensed` | Short tags for narrow side panels |
| `marker` | Compact marker-heavy output |
| `plain` | Stable labels without extra semantic tags |

Width modes and visual modes are related but not identical. A visual mode is the public behavior request. A width mode is a rendering/layout decision.

---

## Semantic categories

The current semantic categories are:

| Category | Label | Meaning |
|---|---|---|
| `metadata_key` | Metadata Key | field names and descriptive labels |
| `value` | Ordinary Value | ordinary values without stronger semantic identity |
| `origin` | Source / Origin Information | where a fact came from |
| `source` | Source Operand | operand supplying a value |
| `destination` | Destination Operand | operand receiving a value |
| `affected` | Affected Operand / State | operand or state changed as an effect |
| `register` | Register Entity | machine register identity |
| `memory` | Memory / Address Entity | memory location, address, stack slot, heap target, or memory operand |
| `immediate` | Immediate Value | literal value encoded in an instruction |
| `symbol` | Symbol | named program entity such as label, function, variable, or constant |
| `instruction` | Instruction / Mnemonic | operation being performed |
| `warning` | Warning | active warning or warning headline |
| `warning_subject` | Warning Subject | thing implicated in a warning |
| `warning_rule` | Rule / Check Identifier | analysis rule or check identity |
| `boundary` | Boundary / System Entity | system, ABI, syscall, or boundary concept |
| `resolved` | Resolved / Safe State | safe, true, completed, or validated state |
| `unresolved` | Unresolved / Failure State | unsafe, failed, false, unresolved, or unknown state |

---

## Semantic precedence

When a piece of text could have multiple semantic identities, the renderer uses deterministic precedence.

Current implementation order:

```text
unresolved
resolved
warning_subject
warning
destination
source
affected
boundary
warning_rule
memory
register
immediate
symbol
instruction
value
metadata_key
origin
```

This makes dangerous/unresolved state outrank ordinary identity, while still letting labels and origin metadata remain readable.

---

## Semantic tags

Tags are explicit text labels for semantic identity.

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
| Affected state | `[AFFECTED]` | `[A]` |
| Register | `[REG]` | `[R]` |
| Memory | `[MEM]` | `[M]` |
| Immediate | `[IMM]` | `[I]` |
| Symbol | `[SYM]` | `[$]` |
| Instruction | `[INSN]` | `[IN]` |
| Metadata key | `[KEY]` | `[K]` |
| Origin | `[ORIGIN]` | `[O]` |
| Historical | `[PAST]` | `[P]` |
| Focused | `[FOCUS]` | `[F]` |
| Current | `[CURRENT]` | `[C]` |
| Contextual | `[CTX]` | `[CXT]` |

Example tagged output:

```text
[KEY] role: [DST] destination
[KEY] source: [ORIGIN] instruction
[REG] rax : 64-bit 00 [full]
[WARN] syscall number register rax has no known value
[KEY] register: [SUBJECT] rax
[KEY] rule_check: [RULE] missing_read_value
[KEY] resolved: [FAIL] false
```


---

## Compact markers

Markers are compact text symbols for semantic identity.

| Meaning | Marker |
|---|---|
| Warning | `!` |
| Warning subject | `*` |
| Unresolved/failure | `x` |
| Resolved/safe | `✓` or ASCII `ok` |
| Boundary | `@` |
| Rule/check | `?` |
| Source operand | `<` |
| Destination operand | `>` |
| Affected state | `~` |
| Register | `R` |
| Memory | `M` |
| Immediate | `#` |
| Symbol | `$` |
| Instruction | `I` |
| Metadata key | `:` |
| Origin | `^` |
| Historical | `.` |
| Focused | `|` |
| Current | `+` |
| Contextual | `-` |

Example marker output:

```text
! syscall number register rax has no known value
  : register: * rax
  : boundary_name: @ syscall
  : rule_check: ? missing_read_value
  : resolved: x false
```

---

## Role vs provenance

These two fields are intentionally different:

```text
role: source
source: instruction
```

`role: source` says the selected operand is a source operand.

`source: instruction` says the fact came from instruction analysis.

They must not share the same semantic meaning or visual category.

Related field grammar:

| Key | Intended meaning |
|---|---|
| `role` | current operand/state role, such as `source`, `destination`, `affected`, `written by mov`, or `clobbered by Linux syscall` |
| `source` | provenance/origin of a fact, such as `instruction` or `analysis` |
| `value source` | where the current value came from |
| `selected source` | the source occurrence currently touched by the cursor |
| `source role` | the source occurrence's operand contribution |
| `writes to` | destination of a value/effect |
| `flows into` | target reached by the value |
| `value flow` | explicit textual flow, such as `60 -> rax` |
| `resolved` | boolean/safety state |
| `rule_check` | warning/check identity |
| `boundary_name` | system/ABI boundary identity |

---

## Cursor notation in documentation

Documentation examples use vertical bars to indicate cursor position or selected range:

```asm
mov |rax|, 60
mov rax, |60|
```

The bars are not source code.

Square brackets in ASM examples remain real ASM memory syntax:

```asm
mov rax, [rbp + |rax|*4 - 8]
```

In that example:

```text
focused token: rax
focused token kind: register
containing operand: [rbp + rax*4 - 8]
containing operand kind: memory
operand role: source
address role: index register
```

---

## Directional flow text

Text HUD output should use explicit flow fields rather than relying on arrows or graphical layout alone.

Examples:

```text
value flow: 60 -> rax
flows into: rax
writes to: rax
value flow: rdi -> rflags
```

Future ASCII/graphical renderers may draw arrows, but the text HUD must keep the textual relationship.

---

## Current implementation modules

Current visual-language behavior is spread across these core modules:

```text
lua/tracker_hud/visual_language.lua
    -> semantic categories, tags, markers, precedence, modes, terminal/width resolution, plain-mode rules

lua/tracker_hud/highlights.lua
    -> public highlight groups and Neovim highlight setup

lua/tracker_hud/hud_text.lua
    -> rendered text plus byte-column semantic spans and annotation prefixes

lua/tracker_hud/hud_sections.lua
    -> section rendering, active-path row targeting, and plain-mode shadow row style assignment

lua/tracker_hud/section_tree.lua
lua/tracker_hud/sections/templates/lookup_tree.lua
    -> shared detail-row key/value semantic handling

lua/tracker_hud/warning_tree.lua
    -> warning-specific semantic rows

lua/tracker_hud/sections/low_level/register_tree.lua
lua/tracker_hud/sections/low_level/stack_tree.lua
lua/tracker_hud/sections/low_level/heap_tree.lua
    -> low-level section tree output using shared detail semantics
```

The important architectural rule is:

```text
facts/data model
    -> semantic style/category
        -> renderer choice
```

Concrete sections should not each invent their own meaning/color/tag system.

---

## Current configuration shape

```lua
visual_language = {
    mode = "auto", -- auto | rich | tagged | markers | plain

    terminal_tier = "auto", -- auto | truecolor | 256 | 16 | monochrome

    colors = {
        enabled = "auto", -- true | false | auto
    },

    plain = {
        emphasize_active_path = false,
        shadow_active_path = true,
        underline_active_section_title = true,
        dim_inactive = false,
    },

    tags = {
        enabled = "auto", -- true | false | auto
        mode = "auto", -- auto | full | condensed | marker | plain
    },

    markers = {
        enabled = "auto", -- true | false | auto
        ascii_safe = true,
    },

    width = {
        mode = "auto", -- auto | full | condensed | marker | plain
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
}
```

---

## Finalized v0.4 behavior

The following behavior is considered locked in for this snapshot:

- semantic identity and relevance are separate concepts
- color is enhancement, not meaning
- `rich`, `tagged`, `markers`, and `plain` are public visual modes
- `:<prefix>VisualMode` is the runtime command family
- `role: source` / `role: destination` are operand-role values
- `source: instruction` is provenance/origin
- tags and markers are semantic annotations, not random decorations
- plain mode uses no semantic colors, no tags, no markers, no inactive dimming
- plain mode uses bright text plus active root-section underline and targeted neutral shadows
- plain-mode shadows must target concrete active/affected rows, not whole container/category subtrees
- value flow must remain explicit in text output

---

## Future work

Future visual-language work may include:

- richer color palette tuning for `rich`, `tagged`, and `markers`
- explicit OpenBSD/PuTTY/tmux/SSH rendering test notes
- optional ASCII register boxes
- optional ASCII stack/heap region diagrams
- graphical HUD experiments
- user-tunable color palettes
- screen-reader-adjacent plain output profiles
- more precise active-path behavior for Scope and Scope Members if it can be done without noise


### Hex width overflow policy

Hex-width coloring is anchored from the right edge of a `0x...` literal:

```text
0x7FFF00000000000F
0xMMMMMMMMOOOOGGBB
```

By default, Tracker HUD colors only the low 64-bit bands:

- `BB`: low 8-bit byte, blue
- `GG`: bits 8-15, green
- `OOOO`: bits 16-31, orange
- `MMMMMMMM`: bits 32-63, magenta

Digits above the configured width keep their original source/HUD text color,
so oversized values read as:

```text
0x[normal overflow][MMMMMMMM][OOOO][GG][BB]
```

This avoids falsely labeling overflow digits as part of the 64-bit range. Users
can opt into a 128-bit upper band with:

```lua
visual_language = {
  hex_width = {
    max_bits = 128,
  },
}
```

Values wider than the configured maximum still keep their original text color.
