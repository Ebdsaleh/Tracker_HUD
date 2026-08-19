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
        terminal_tier = "auto", -- "auto", "truecolor", "256", "16", "monochrome"

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
