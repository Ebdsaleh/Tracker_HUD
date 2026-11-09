# Tracker_HUD — Normalized Semantic Facts and Runtime Presentations (v1)

**Status:** incremental implementation on `main`; ERIDU acceptance pending.  
**Date:** 2026-11-09  
**Design objective:** same cursor-time truth, multiple instantly switchable
presentations for expert use and inclusive programming education.

## Public controls

```vim
:HudPresentation           " show current preset
:HudPresentation standard  " default; unchanged technical text HUD
:HudPresentation learning  " short source-based explanation + existing sections
:HudPresentation cycle     " toggle presets using cached context
```

`:HudPresentation` is namespace-aware, like `:HudVisualMode`.
Set `namespace.prefix = "Tutor"` to use `:TutorPresentation`.
An optional keymap can be set in the user's setup:

```lua
require("tracker_hud").setup({
    keymaps = {
        cycle_presentation_mode = "<leader>hp",
    },
})
```

There is **no new default keybinding** to collide with the user's
existing Neovim profile. These controls are separate from
`:HudVisualMode` (colour, tags, markers, plain) and the existing
`Inspect:` section selection (Scope, Scope Members, Registers, etc.).

Switching should re-render the **already collected** source context,
not force an AST/semantic replay. The source cursor, currently selected
Inspect section and expanded sections must be retained. The mode is
an in-memory setting for the configured Tracker_HUD instance; persistence
across restarts/user profiles is not implemented.

## Data contract (pure Lua, v1)

Implementation: `lua/tracker_hud/facts/contract.lua`

```lua
{
    version = 1,
    id = "register:rax@12",  -- stable identity within source snapshot
    kind = "register",       -- memory, stack, heap, event, warning
    subject = {
        kind = "register",
        name = "rax",
        architecture = "x86-64",
    },
    source = {
        line = 12,           -- 1-based
        start_column = 4,    -- 0-based
    },
    effect = {
        operation = "write",
        role = "destination",
    },
    value = {
        status = "known",    -- unknown | partial | conditional
        data = 60,
    },
    provenance = {
        kind = "inferred",
        rule = "mov-immediate",
    },
    known_through = { line = 12, column = 4 },
    metadata = {},
}
```

The constructor `facts.new(spec)` returns a detached fact or
`nil, error`. It does not parse source or draw the UI.
`facts.visible_at(fact, {line, column})` enforces **ON/Past** the
source discovery location. The caller remains responsible for
providing correct cursor-scoped source facts; a cache never authorizes
showing future source discoveries.

### Certainty rules

- `known`: a resolved value, including **0**, **false**, and an
  explicitly represented known `nil` (`is_nil=true`).
- `unknown`: value is unresolved/not shown to be known from source.
- `partial`: available expression/symbolic representation but
  insufficient proof of a concrete numeric value.
- `conditional`: an effect/value depends on a path or condition.
- Never promote a symbolic address, an unexecuted memory load,
  or a physical CPU runtime value into “known” merely because the
  source contains an expression.

The first opt-in adapter
`lua/tracker_hud/presenters/learning.lua` converts a bounded,
source-visible register record into a normalized fact and uses it
to generate **one** short, text-only teaching explanation. It avoids
static hardware register rows masquerading as instruction effects
and omits future-source facts. The full original HUD is still beneath
this explanation, and `standard` returns to the unchanged output.

The first preview does **not** yet provide all register aliases as
byte cells, beginner guidance for every language, graphical drawing,
animation, visual theme customization, a compiler, or a full debugger.
Those are future presentation layers, not part of this acceptance.

## Architecture ownership and extension

```text
   Parser/adapter ----> cursor-scoped source facts
                              |
   Architecture/ABI ---> semantic inference engine
                              |
                    Normalized fact snapshot
                              |
                   selectable presentation
                     /                \\
           existing text HUD       learning text
                                     / future
                           8-byte diagram, images,
                           animations, explanations
```

The architecture describes registers, aliases, widths, flag behaviour.
ABI profiles supply calling-convention information. Source language
adapters describe syntactic constructs. The inference engine describes
effects and certainty. Renderers describe **how to explain the facts**;
they cannot change their truth.

For educational 64-bit RAX diagrams, do not draw arbitrary boxes:
a correct byte representation of numeric `60` is
`00 00 00 00 00 00 00 3C` in most-significant-byte-first display,
and an 8-bit `AL` alias refers to the low byte. Endianness and
display order must be clearly labelled.

## Acceptance / next steps

From ERIDU at the repository root:

```bat
git status --short
git pull --ff-only
nvim --headless -u NONE -c "luafile tests/normalized_fact_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/presentation_modes_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua" -c "qa!"
nvim --headless -u NONE -c "luafile tests/section_inspect_colors_smoke.lua" -c "qa!"
nvim --headless -c "luafile tests/asm_register_focus_regression.lua" -c "qa!"
```

Manual:

```bat
nvim samples/asm/x86_64/memory_operand_validation.asm
```

While open, try `:HudPresentation learning`, `:HudPresentation
standard`, and `:HudPresentation cycle`. Check that source
position/Inspect selection/expanded rows are preserved and that
static register listings never pretend they came from an executed
instruction. Try `:HudVisualMode plain` with each preset to prove
the two mode axes remain independent.

**Known outstanding separate gate:** the ASM memory-token cursor-focus
regression still requires ERIDU validation on the updated `main`.
The presence of ordinary working `test.asm` semantics does not by
itself verify the memory-operand fixture. Do not alter ASM inference
to make this new presenter work.

**Future small migration tranches:** extend typed facts to
memory, stack, heap, events and warnings; add source/provenance detail
and byte-accurate visual projections; measure render-vs-analysis
cost separately; add accessible layouts without deleting existing
expert detail.


## Second presentation tranche — ASCII register byte diagram (2026-11-09)

The new optional `diagram` preset adds a terminal-safe **eight-byte**
high-significance-to-low-significance register diagram. It is a text
projection of the same normalized source facts. It is **not** a picture,
GIF, CPU debugger, or measured runtime state.

```vim
:HudPresentation standard
:HudPresentation learning
:HudPresentation diagram
:HudPresentation cycle
```

`cycle` now moves `standard -> learning -> diagram -> standard`.
`standard` remains the unchanged default; the entire technical HUD
and its user-controlled Inspect selection/expanded nodes remain
available in every mode. Switching reuses an already-collected context.

For an x86-64 source-inferred 64-bit register value of 60:

```text
Byte diagram (source inference, not live CPU state):
  RAX  (64 bits = 8 bytes)
  MSB                                 LSB
  [00][00][00][00][00][00][00][3C]
  Bits: 0x000000000000003C
  Source-inferred value, not execution proof.
  Left to right: high to low significance, NOT memory order.
```

The **width** must come from an architecture-profile register family
(e.g. `register.metadata.family.bits = 64`), not a guessed register
name. Unknown, partial, unresolved or conditional results show
`[??]` for each byte. If the architecture width is unavailable or
not 64 bits, the presenter says so instead of fabricating a bank.
This initial diagram does not yet show 8-/16-/32-bit registers or
per-alias overlays.

The precise converter `presenters/byte_diagram.lua` accepts
64-bit decimal and hexadecimal **string** integers, and safe exact
Lua numeric integers. Arithmetic on decimal strings is byte-by-byte
and preserves unsigned values through
`18446744073709551615` (`0xFFFFFFFFFFFFFFFF`) as well as negative
64-bit signed values down to `-9223372036854775808`. Numeric inputs
outside Lua's safe-integer precision, fractional/symbolic data, and
out-of-range values are not silently rounded, wrapped or rendered as
verified bytes.

MSB/LSB describes the significance of the register value, **not
the byte order of a memory load or store**. Do not equate the diagram
with memory layout or claim x86-64 memory has been inspected.

`tests/byte_diagram_smoke.lua` covers width, conversion, signed
boundary, known/unknown/partial state and ON/PAST source gating.
ERIDU acceptance remains pending at the moment of this update.

