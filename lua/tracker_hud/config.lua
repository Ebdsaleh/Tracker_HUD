-- lua/tracker_hud/config.lua

local M = {}

M.defaults = {
    display = "panel", -- "panel" only now.

    show_line_numbers = true,
    show_branch_context = true,
    separator = " -> ",

    -- Public identifier namespace.
    -- User commands are derived from this prefix (for example: HudSize).
    -- Future public identifiers such as highlight groups can use the same
    -- resolver without hard-coding the plugin name throughout the codebase.
    namespace = {
        prefix = "Hud",
    },

    -- Semantic HUD highlighting. Public highlight group names are generated
    -- from namespace.prefix (for example: HudDestination).
    highlights = {
        enabled = true,
    },

    -- Renderer-agnostic visual language controls.
    --
    -- These options are intentionally data/config first. The current text HUD
    -- still uses semantic highlight spans, while future low-color, tagged,
    -- compact, ASCII, or graphical renderers can consume the same visual
    -- language tables from tracker_hud.visual_language.
    visual_language = {
        -- Public runtime visual mode. This is also controlled by:
        --   :<namespace-prefix>VisualMode auto|rich|tagged|markers|plain
        --
        -- auto    = choose semantic annotations from terminal/panel conditions
        -- rich    = color-first HUD, no semantic tags or markers
        -- tagged  = explicit semantic tags such as [SRC], [DST], [FAIL]
        -- markers = compact markers such as <, >, x, ?, @
        -- plain   = stable text only; disables semantic color rendering
        mode = "auto",

        terminal_tier = "auto", -- "auto", "truecolor", "256", "16", "monochrome"

        colors = {
            enabled = "auto", -- true, false, or "auto"; plain mode disables semantic color
        },

        plain = {
            -- Plain mode does not depend on semantic colors. It should remain
            -- readable in monochrome or unreliable terminal-color environments.
            --
            -- Current plain-mode rules:
            --   all HUD text is forced to bright white;
            --   only the active root-section title is underlined;
            --   only explicitly active/affected rows receive a neutral
            --   background shadow.
            --
            -- Important: this must not shadow every row inside an active root
            -- section. The shadow follows the same active path represented by
            -- the `*` marker and by exact focused descendants.
            emphasize_active_path = false,
            shadow_active_path = true,
            underline_active_section_title = true,
            dim_inactive = false,
        },

        tags = {
            enabled = "auto", -- true, false, or "auto" for low-color terminals
            mode = "auto", -- "auto", "full", "condensed", "marker", "plain"
        },

        markers = {
            enabled = "auto", -- true, false, or "auto" for low-color terminals
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

        -- Hex-width color guides for hexadecimal literals.
        --
        -- When enabled, hexadecimal digits are colored from right to left by
        -- hardware-width bands so the low byte remains visually anchored:
        --   8-bit  low byte          -> blue
        --   16-bit high byte         -> green
        --   32-bit high word         -> orange
        --   64-bit upper double-word -> magenta
        --
        -- Example:
        --   0x7FFF00000000000F
        --   0xMMMMMMMMOOOOGGBB
        --
        -- `hud` colors hex values rendered inside the Tracker HUD panel.
        -- `source` colors hex values directly in normal source buffers,
        -- regardless of language, so ASM, Lua, C, Rust, etc. all get the
        -- same low-level reading aid.
        hex_width = {
            enabled = true,

            -- Default: show 8/16/32/64-bit bands only. Digits above 64-bit
            -- keep their original source/HUD text color so a too-wide literal
            -- does not masquerade as a 64-bit value. Set to 128 to opt into
            -- an extra 128-bit upper band.
            max_bits = 64,

            hud = {
                enabled = true,
            },
            source = {
                enabled = true,
                max_lines = 5000,
            },
        },
    },

    -- Source-position line summaries.
    --
    -- The HUD is cursor-state-first: exact syntax tokens/operands own the
    -- primary meaning. This option controls what happens when the cursor is
    -- on whitespace or punctuation outside an exact semantic occurrence.
    --
    -- Default behavior:
    --   leading whitespace before an instruction does not pre-read it;
    --   trailing whitespace after an instruction may show post-instruction
    --   state, because the cursor has moved past that instruction.
    line_summary = {
        enabled = true,
        show_before_instruction = false,
        show_after_instruction = true,
    },

    -- "left", "right", "top", or "bottom"
    panel_position = "right",

    -- Number = fixed size
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
        step= 2,
    },

    -- Adapter discovery paths.
    -- Each entry is a Lua module path prefix.
    -- Example:
    --   "tracker_hud/adapters"
    -- maps to:
    --   lua/tracker_hud/adapters/*/init.lua

        adapter_paths = {
        "tracker_hud/adapters",
    },

    -- Target defaults used by adapters when source files do not declare
    -- their own target directives.
    --
    -- These are adapter-facing hints. Individual adapters decide which
    -- target fields they support.
    --
    -- Source directives override these defaults when present.

    targets = {
        architecture = nil,
        platform = nil,
        abi = nil,
        syntax = nil,
        mode = nil,
    },
}


function M.resolve(opts)
    return vim.tbl_deep_extend("force", M.defaults, opts or {})
end


return M


