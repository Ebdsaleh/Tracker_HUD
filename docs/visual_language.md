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

