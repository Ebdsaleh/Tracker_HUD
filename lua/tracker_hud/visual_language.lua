-- lua/tracker_hud/visual_language.lua
--
-- Shared semantic visual-language tables for Tracker_HUD.
--
-- This module is intentionally data-first and renderer-agnostic. The text HUD,
-- future ASCII views, and any future graphical view should all consume the same
-- semantic vocabulary instead of each renderer inventing its own meanings.
--
-- Design rule:
--   semantic identity chooses meaning / color family / tag / marker
--   relevance state chooses intensity / emphasis
--
-- Color is enhancement, not meaning. Tags and compact markers give low-color
-- and monochrome environments a way to preserve the same information.

local M = {}


M.display_tiers = {
    truecolor = {
        order = 1,
        label = "truecolor",
        description = "Full semantic color families.",
        use_colors = true,
        use_tags = false,
        use_markers = false,
        use_typography = true,
    },

    color_256 = {
        order = 2,
        label = "256-color",
        description = "Reduced but still meaning-separated colors.",
        use_colors = true,
        use_tags = false,
        use_markers = false,
        use_typography = true,
    },

    ansi_16 = {
        order = 3,
        label = "16-color / ANSI",
        description = "Broad colors plus tags, markers, and typography.",
        use_colors = true,
        use_tags = true,
        use_markers = true,
        use_typography = true,
    },

    monochrome = {
        order = 4,
        label = "monochrome",
        description = "Meaning preserved without color.",
        use_colors = false,
        use_tags = true,
        use_markers = true,
        use_typography = false,
    },
}


M.width_modes = {
    full = {
        label = "full",
        description = "Full labels and semantic tags.",
        prefer_tags = "full",
        prefer_markers = true,
    },

    condensed = {
        label = "condensed",
        description = "Short tags for narrow side panels.",
        prefer_tags = "condensed",
        prefer_markers = true,
    },

    marker = {
        label = "marker",
        description = "Compact marker-heavy output.",
        prefer_tags = false,
        prefer_markers = true,
    },

    plain = {
        label = "plain",
        description = "Stable labels without extra semantic tags.",
        prefer_tags = false,
        prefer_markers = false,
    },
}


M.tags = {
    warning = {
        full = "[WARN]",
        condensed = "[W]",
    },

    warning_subject = {
        full = "[SUBJECT]",
        condensed = "[SUBJ]",
    },

    unresolved = {
        full = "[FAIL]",
        condensed = "[X]",
    },

    resolved = {
        full = "[OK]",
        condensed = "[OK]",
    },

    boundary = {
        full = "[BOUNDARY]",
        condensed = "[BND]",
    },

    warning_rule = {
        full = "[RULE]",
        condensed = "[RUL]",
    },

    source = {
        full = "[SRC]",
        condensed = "[S]",
    },

    destination = {
        full = "[DST]",
        condensed = "[D]",
    },

    affected = {
        full = "[AFFECTED]",
        condensed = "[A]",
    },

    register = {
        full = "[REG]",
        condensed = "[R]",
    },

    memory = {
        full = "[MEM]",
        condensed = "[M]",
    },

    immediate = {
        full = "[IMM]",
        condensed = "[I]",
    },

    symbol = {
        full = "[SYM]",
        condensed = "[$]",
    },

    instruction = {
        full = "[INSN]",
        condensed = "[IN]",
    },

    metadata_key = {
        full = "[KEY]",
        condensed = "[K]",
    },

    origin = {
        full = "[ORIGIN]",
        condensed = "[O]",
    },

    historical = {
        full = "[PAST]",
        condensed = "[P]",
    },

    focused = {
        full = "[FOCUS]",
        condensed = "[F]",
    },

    current = {
        full = "[CURRENT]",
        condensed = "[C]",
    },

    contextual = {
        full = "[CTX]",
        condensed = "[CXT]",
    },
}


M.markers = {
    warning = {
        preferred = "!",
        ascii = "!",
    },

    warning_subject = {
        preferred = "*",
        ascii = "*",
    },

    unresolved = {
        preferred = "x",
        ascii = "x",
    },

    resolved = {
        preferred = "✓",
        ascii = "ok",
    },

    boundary = {
        preferred = "@",
        ascii = "@",
    },

    warning_rule = {
        preferred = "?",
        ascii = "?",
    },

    source = {
        preferred = "<",
        ascii = "<",
    },

    destination = {
        preferred = ">",
        ascii = ">",
    },

    affected = {
        preferred = "~",
        ascii = "~",
    },

    register = {
        preferred = "R",
        ascii = "R",
    },

    memory = {
        preferred = "M",
        ascii = "M",
    },

    immediate = {
        preferred = "#",
        ascii = "#",
    },

    symbol = {
        preferred = "$",
        ascii = "$",
    },

    instruction = {
        preferred = "I",
        ascii = "I",
    },

    metadata_key = {
        preferred = ":",
        ascii = ":",
    },

    origin = {
        preferred = "^",
        ascii = "^",
    },

    historical = {
        preferred = ".",
        ascii = ".",
    },

    focused = {
        preferred = "|",
        ascii = "|",
    },

    current = {
        preferred = "+",
        ascii = "+",
    },

    contextual = {
        preferred = "-",
        ascii = "-",
    },
}


-- Deterministic semantic precedence. This is used by future renderers when a
-- token has multiple possible semantic meanings, for example a register that
-- is also a focused destination operand and a warning subject.
M.semantic_precedence = {
    "unresolved",
    "warning_subject",
    "destination",
    "source",
    "affected",
    "boundary",
    "warning_rule",
    "memory",
    "register",
    "immediate",
    "symbol",
    "value",
    "metadata_key",
    "origin",
}

M.semantic_priority = {}

for priority, style in ipairs(M.semantic_precedence) do
    M.semantic_priority[style] = priority
end


M.semantic_categories = {
    metadata_key = {
        label = "Metadata Key",
        meaning = "field names and descriptive labels",
        color_family = "cyan",
        tag = "metadata_key",
        marker = "metadata_key",
    },

    value = {
        label = "Ordinary Value",
        meaning = "ordinary values without stronger semantic identity",
        color_family = "neutral value tone",
    },

    origin = {
        label = "Source / Origin Information",
        meaning = "where a fact came from",
        color_family = "teal",
        tag = "origin",
        marker = "origin",
    },

    source = {
        label = "Source Operand",
        meaning = "operand supplying a value",
        color_family = "sage / cyan-green",
        tag = "source",
        marker = "source",
    },

    destination = {
        label = "Destination Operand",
        meaning = "operand receiving a value",
        color_family = "sage / cyan-green",
        tag = "destination",
        marker = "destination",
    },

    affected = {
        label = "Affected Operand / State",
        meaning = "operand or state changed as an effect",
        color_family = "sage / cyan-green",
        tag = "affected",
        marker = "affected",
    },

    register = {
        label = "Register Entity",
        meaning = "machine register identity",
        color_family = "neutral technical tone",
        tag = "register",
        marker = "register",
    },

    warning_subject = {
        label = "Warning Subject",
        meaning = "thing implicated in a warning",
        color_family = "amber / orange",
        tag = "warning_subject",
        marker = "warning_subject",
    },

    boundary = {
        label = "Boundary / System Entity",
        meaning = "system, ABI, syscall, or boundary concept",
        color_family = "purple / magenta",
        tag = "boundary",
        marker = "boundary",
    },

    warning_rule = {
        label = "Rule / Check Identifier",
        meaning = "analysis rule or check identity",
        color_family = "violet / pink-violet",
        tag = "warning_rule",
        marker = "warning_rule",
        low_color_typography = "underline",
    },

    unresolved = {
        label = "Unresolved / Failure State",
        meaning = "unsafe, failed, false, unresolved, or unknown state",
        color_family = "red / hot amber-red",
        tag = "unresolved",
        marker = "unresolved",
    },

    resolved = {
        label = "Resolved / Safe State",
        meaning = "safe, true, completed, or validated state",
        color_family = "success green",
        tag = "resolved",
        marker = "resolved",
    },

    memory = {
        label = "Memory / Address Entity",
        meaning = "memory location, address, stack slot, heap target, or memory operand",
        color_family = "blue-purple / indigo",
        tag = "memory",
        marker = "memory",
    },

    immediate = {
        label = "Immediate Value",
        meaning = "literal value encoded in an instruction",
        color_family = "numeric value tone",
        tag = "immediate",
        marker = "immediate",
    },

    symbol = {
        label = "Symbol",
        meaning = "named program entity such as label, function, variable, or constant",
        color_family = "symbol/name accent",
        tag = "symbol",
        marker = "symbol",
    },

    instruction = {
        label = "Instruction / Mnemonic",
        meaning = "operation being performed",
        color_family = "neutral bright accent",
        tag = "instruction",
        marker = "instruction",
    },
}


M.style_suffixes = {
    -- HUD shell / navigation.
    title = "Title",
    tip = "Tip",
    tip_label = "TipLabel",
    key_hint = "KeyHint",
    section = "Section",
    section_marker = "SectionMarker",
    control = "Control",
    control_marker = "ControlMarker",
    active = "Active",
    tree_marker = "TreeMarker",
    status_title = "StatusTitle",
    status_marker = "StatusMarker",
    inspect_mode = "InspectMode",

    -- Generic structural text.
    punctuation = "Punctuation",
    separator = "Separator",
    operator = "Operator",
    qualifier = "Qualifier",
    line_number = "LineNumber",
    scope = "Scope",
    scope_range = "ScopeRange",
    member = "Member",
    category = "Category",
    kind = "Kind",
    name = "Name",
    type = "Type",
    value = "Value",
    role = "Role",
    origin = "Origin",

    -- Status / target metadata.
    status_label = "StatusLabel",
    status_value = "StatusValue",
    target_label = "TargetLabel",
    target_key = "TargetKey",
    target_value = "TargetValue",
    diagnostic = "Diagnostic",
    metadata = "Metadata",
    metadata_key = "MetadataKey",
    metadata_value = "MetadataValue",

    -- Low-level / event identities.
    register = "Register",
    register_alias = "RegisterAlias",
    stack = "Stack",
    heap = "Heap",
    memory = "Memory",
    immediate = "Immediate",
    symbol = "Symbol",
    instruction = "Instruction",
    event = "Event",
    boundary = "Boundary",

    -- Occurrence/effect semantics.
    destination = "Destination",
    source = "Source",
    affected = "Affected",
    implicit = "Implicit",

    -- Warning structure.
    warning = "Warning",
    warning_severity = "WarningSeverity",
    warning_category = "WarningCategory",
    warning_message = "WarningMessage",
    warning_detail_key = "WarningDetailKey",
    warning_detail_value = "WarningDetailValue",
    warning_subject = "WarningSubject",
    warning_rule = "WarningRule",
    warning_rule_source = "WarningRuleSource",
    warning_rule_check = "WarningRuleCheck",
    resolved = "Resolved",
    unresolved = "Unresolved",

    -- Relevance state. These are presentation modifiers stacked on top of
    -- semantic groups when a relevance-specific semantic group is not known.
    -- They are not semantic identities themselves.
    focused = "Focused",
    current = "Current",
    contextual = "Contextual",
    historical = "Historical",

    -- Fallbacks.
    muted = "Muted",
    empty = "Empty",
}


M.default_links = {
    title = "Title",
    tip = "Comment",
    tip_label = "Special",
    key_hint = "Special",
    section = "Function",
    section_marker = "Special",
    control = "Special",
    control_marker = "Special",
    active = "IncSearch",
    tree_marker = "Delimiter",
    status_title = "StatusLine",
    status_marker = "Special",
    inspect_mode = "ModeMsg",

    punctuation = "Delimiter",
    separator = "Delimiter",
    operator = "Operator",
    qualifier = "Type",
    scope = "Function",
    scope_range = "Comment",
    member = "Identifier",
    category = "Type",
    kind = "Type",
    name = "Identifier",
    type = "Type",
    role = "Keyword",

    status_label = "Comment",
    status_value = "Identifier",
    target_label = "Keyword",
    target_key = "Comment",
    target_value = "Identifier",
    diagnostic = "DiagnosticWarn",
    metadata = "Comment",

    stack = "Identifier",
    heap = "Identifier",
    event = "Special",

    muted = "Comment",
    empty = "Comment",
}


-- These defaults intentionally separate operand-role sage from success green.
M.default_style_definitions = {
    line_number = { fg = "#7AA2F7" },
    value = { fg = "#C0CAF5" },
    metadata_key = { fg = "#7DCFFF" },
    metadata_value = { fg = "#C0CAF5" },
    origin = { fg = "#73DACA" },

    register = { fg = "#7DCFFF" },
    register_alias = { fg = "#89DDFF" },
    destination = { fg = "#B4BE82" },
    source = { fg = "#B4BE82" },
    affected = { fg = "#B4BE82" },

    instruction = { fg = "#C0CAF5" },
    immediate = { fg = "#C0CAF5" },
    memory = { fg = "#7E9CD8" },
    symbol = { fg = "#DCD7BA" },

    -- Implicit architectural effects deliberately share the warning color
    -- family by default without sharing warning semantics. This makes hidden
    -- register side-effects such as syscall clobbers visually obvious.
    implicit = { fg = "#E0AF68" },

    boundary = { fg = "#BB9AF7" },

    warning = { fg = "#E0AF68" },
    warning_severity = { fg = "#E0AF68" },
    warning_category = { fg = "#BB9AF7" },
    warning_message = { fg = "#FFC777" },
    warning_detail_key = { fg = "#7DCFFF" },
    warning_detail_value = { fg = "#C0CAF5" },

    -- Important: this is not the same as HudUnresolved.
    -- A warning subject is the implicated thing, such as rax, buffer, syscall,
    -- or another concrete target named by a warning.
    warning_subject = { fg = "#FF9E64" },

    warning_rule = { fg = "#C678DD", underline = true },
    warning_rule_source = { fg = "#9D7CD8" },
    warning_rule_check = { fg = "#FF75A0", underline = true },

    resolved = { fg = "#9ECE6A" },
    unresolved = { fg = "#F7768E" },
}


M.relevance_definitions = {
    focused = {
        bold = true,
    },

    current = {},

    contextual = {
        italic = true,
    },

    historical = {
        italic = true,
    },
}

M.relevance_color_mixes = {
    focused = 0.00,
    current = 0.00,
    contextual = 0.34,
    historical = 0.58,
}

M.relevance_mute_target = "#565F89"


M.flow_keys = {
    flows_into = "flows into",
    writes_to = "writes to",
    value_flow = "value flow",
}

M.nested_operand_keys = {
    focused_token = "focused token",
    focused_token_kind = "focused token kind",
    address_role = "address role",
    containing_operand = "containing operand",
}

M.address_roles = {
    base_register = "base register",
    index_register = "index register",
    scale = "scale",
    displacement = "displacement",
}


local function table_get(root, key)
    if type(root) ~= "table" or type(key) ~= "string" then
        return nil
    end

    return root[key]
end


function M.tag_for(style, mode)
    local entry = table_get(M.tags, style)

    if type(entry) ~= "table" then
        return nil
    end

    if mode == "condensed" then
        return entry.condensed or entry.full
    end

    return entry.full or entry.condensed
end


function M.marker_for(style, ascii_safe)
    local entry = table_get(M.markers, style)

    if type(entry) ~= "table" then
        return nil
    end

    if ascii_safe == true then
        return entry.ascii or entry.preferred
    end

    return entry.preferred or entry.ascii
end


function M.priority_for(style)
    return M.semantic_priority[style]
end


function M.category_for(style)
    return M.semantic_categories[style]
end


return M
