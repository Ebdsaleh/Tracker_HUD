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


M.visual_modes = {
    auto = {
        label = "auto",
        description = "Choose visual annotations from terminal and panel conditions.",
    },

    rich = {
        label = "rich",
        description = "Color-first HUD with no semantic tags or markers.",
        force_colors = true,
        force_tags = false,
        force_markers = false,
    },

    tagged = {
        label = "tagged",
        description = "Explicit semantic tags such as [SRC], [DST], and [FAIL].",
        force_colors = true,
        force_tags = true,
        force_markers = false,
    },

    markers = {
        label = "markers",
        description = "Compact semantic markers such as <, >, x, ?, and @.",
        force_colors = true,
        force_tags = false,
        force_markers = true,
    },

    plain = {
        label = "plain",
        description = "Stable text with neutral active-path emphasis; no semantic color assumptions or annotation prefixes.",
        force_colors = false,
        force_tags = false,
        force_markers = false,
    },
}

M.visual_mode_order = {
    "auto",
    "rich",
    "tagged",
    "markers",
    "plain",
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
    "resolved",
    "warning_subject",
    "warning",
    "destination",
    "source",
    "affected",
    "boundary",
    "warning_rule",
    "memory",
    "register",
    "immediate",
    "symbol",
    "instruction",
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

    warning = {
        label = "Warning",
        meaning = "active warning or warning headline",
        color_family = "amber",
        tag = "warning",
        marker = "warning",
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
    section_title = "SectionTitle",
    warning_section_title = "WarningSectionTitle",
    plain_text = "PlainText",
    plain_section_title = "PlainSectionTitle",
    plain_active_section_title = "PlainActiveSectionTitle",
    plain_active_marker = "PlainActiveMarker",
    plain_active_shadow = "PlainActiveShadow",
    plain_current_shadow = "PlainCurrentShadow",
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
    section_title = "Function",
    warning_section_title = "DiagnosticWarn",
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
    -- Operand-role values (for example: role: source / role: destination).
    -- This is intentionally greener than Origin so provenance lines such as
    -- source: instruction do not look identical to operand-role values.
    destination = { fg = "#83D197" },
    source = { fg = "#83D197" },
    affected = { fg = "#83D197" },

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

    -- Plain-mode neutral text/emphasis. These groups deliberately avoid
    -- semantic color families: they describe colorless/plain visibility only.
    -- PlainText gives every HUD line a bright white foreground so plain mode
    -- does not depend on dimming, semantic colors, or colorscheme defaults.
    -- The active root-section title remains the only underlined element.
    plain_text = { fg = "#FFFFFF" },
    plain_section_title = { fg = "#FFFFFF", bold = true },
    plain_active_section_title = { fg = "#FFFFFF", bold = true, underline = true },
    plain_active_marker = { fg = "#FFFFFF", bold = true },
    plain_active_shadow = { fg = "#FFFFFF", bg = "#2A2A2A", bold = true, blend = 12 },
    plain_current_shadow = { fg = "#FFFFFF", bg = "#242424", blend = 18 },
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


-- Rendering styles and semantic categories are related, but not identical.
-- These aliases let renderers ask for tags/markers/priority with concrete HUD
-- style keys such as `warning_rule_check` or `register_alias` while still
-- preserving one stable semantic vocabulary.
M.semantic_aliases = {
    warning_severity = "warning",
    warning_category = "boundary",
    warning_message = "warning",
    warning_detail_key = "metadata_key",
    warning_detail_value = "value",
    warning_rule_source = "warning_rule",
    warning_rule_check = "warning_rule",

    metadata = "metadata_key",
    metadata_value = "value",
    role = "value",
    kind = "value",
    category = "value",
    type = "value",
    line_number = "value",

    register_alias = "register",
    stack = "memory",
    heap = "memory",

    -- Implicit architectural side effects are not warnings, but in text/ASCII
    -- mode they need a visible semantic cue. Treat them as affected state for
    -- low-color annotation purposes.
    implicit = "affected",
}


local function normalize_detail_key(key)
    if type(key) ~= "string" then
        key = tostring(key or "")
    end

    return key:lower():gsub("_", " ")
end

local function normalize_detail_value(value)
    if type(value) ~= "string" then
        value = tostring(value or "")
    end

    return value:lower()
end

local function value_starts_with(value, prefix)
    return normalize_detail_value(value):match("^" .. prefix) ~= nil
end

local function value_looks_unresolved(value)
    local normalized = normalize_detail_value(value)

    return normalized == "false"
        or normalized == "unresolved"
        or normalized == "unknown"
        or normalized == "nil"
        or normalized == "null"
        or normalized:find("missing", 1, true) ~= nil
        or normalized:find("failed", 1, true) ~= nil
end

local function value_looks_resolved(value)
    local normalized = normalize_detail_value(value)

    return normalized == "true"
        or normalized == "resolved"
        or normalized == "ok"
        or normalized == "safe"
        or normalized == "valid"
end

local function source_value_style(value)
    local normalized = normalize_detail_value(value)

    if normalized:find("memory", 1, true)
        or normalized:find("[", 1, true)
    then
        return "memory"
    end

    if normalized:find("register", 1, true) then
        return "register"
    end

    if normalized:find("immediate", 1, true) then
        return "immediate"
    end

    if normalized:find("symbol", 1, true) then
        return "symbol"
    end

    return "source"
end

function M.detail_styles_for_key(key, value, semantic_override)
    local normalized_key = normalize_detail_key(key)
    local key_style = "metadata_key"
    local value_style = "metadata_value"

    if normalized_key == "kind" then
        key_style = "kind"
        value_style = "kind"
    elseif normalized_key == "category" then
        key_style = "category"
        value_style = "category"
    elseif normalized_key == "type" then
        key_style = "type"
        value_style = "type"
    elseif normalized_key == "value" then
        value_style = "value"
    elseif normalized_key == "role" then
        value_style = semantic_override or "role"

        if value_starts_with(value, "destination") then
            value_style = "destination"
        elseif value_starts_with(value, "source") then
            value_style = "source"
        elseif value_starts_with(value, "affected") then
            value_style = "affected"
        elseif value_starts_with(value, "written")
            or value_starts_with(value, "updated")
            or value_starts_with(value, "clobbered")
            or value_starts_with(value, "zeroed")
            or value_starts_with(value, "loaded")
            or value_starts_with(value, "receives")
        then
            value_style = semantic_override or "affected"
        end
    elseif normalized_key == "source" then
        -- `source:` is provenance/origin metadata, not the same semantic as
        -- `role: source`. Keep the key in the normal metadata-key family and
        -- only color the value as origin information.
        key_style = "metadata_key"
        value_style = "origin"
    elseif normalized_key == "value source"
        or normalized_key == "selected source"
        or normalized_key == "source kind"
        or normalized_key == "source role"
    then
        key_style = "origin"
        value_style = source_value_style(value)
    elseif normalized_key == "source operand" then
        key_style = "origin"
        value_style = source_value_style(value)
    elseif normalized_key == "writes to"
        or normalized_key == "flows into"
        or normalized_key == "value flow"
    then
        key_style = "origin"
        value_style = "source"
    elseif normalized_key == "operand kind"
        or normalized_key == "focused token kind"
    then
        key_style = "kind"
        value_style = "kind"
    elseif normalized_key == "focused token" then
        value_style = semantic_override or "metadata_value"
    elseif normalized_key == "address role"
        or normalized_key == "containing operand"
    then
        key_style = "memory"
        value_style = "memory"
    elseif normalized_key == "written alias" then
        key_style = "register_alias"
        value_style = "register_alias"
    elseif normalized_key == "resolved" then
        if value_looks_unresolved(value) then
            value_style = "unresolved"
        elseif value_looks_resolved(value) then
            value_style = "resolved"
        else
            value_style = "metadata_value"
        end
    elseif normalized_key:find("boundary", 1, true) then
        value_style = "boundary"
    elseif normalized_key:find("rule", 1, true) then
        value_style = "warning_rule"
    elseif normalized_key:find("register", 1, true) then
        value_style = "register"
    elseif normalized_key:find("pointer", 1, true)
        or normalized_key:find("address", 1, true)
        or normalized_key:find("memory", 1, true)
    then
        value_style = "memory"
    elseif normalized_key == "line"
        or normalized_key == "source line"
    then
        value_style = "line_number"
    elseif normalized_key == "offset"
        or normalized_key == "size"
        or normalized_key == "effect key"
    then
        value_style = "value"
    end

    return key_style, value_style
end


M.terminal_tier_aliases = {
    ["truecolor"] = "truecolor",
    ["24bit"] = "truecolor",
    ["24-bit"] = "truecolor",
    ["256"] = "color_256",
    ["256-color"] = "color_256",
    ["color_256"] = "color_256",
    ["16"] = "ansi_16",
    ["16-color"] = "ansi_16",
    ["ansi"] = "ansi_16",
    ["ansi_16"] = "ansi_16",
    ["mono"] = "monochrome",
    ["monochrome"] = "monochrome",
}


local function table_get(root, key)
    if type(root) ~= "table" or type(key) ~= "string" then
        return nil
    end

    return root[key]
end


function M.semantic_style_for(style)
    if type(style) ~= "string" or style == "" then
        return nil
    end

    if M.semantic_categories[style] then
        return style
    end

    return M.semantic_aliases[style]
end


function M.priority_for(style)
    local semantic_style = M.semantic_style_for(style)
    return semantic_style and M.semantic_priority[semantic_style] or nil
end


function M.category_for(style)
    local semantic_style = M.semantic_style_for(style)
    return semantic_style and M.semantic_categories[semantic_style] or nil
end


function M.tag_for(style, mode)
    local semantic_style = M.semantic_style_for(style) or style
    local entry = table_get(M.tags, semantic_style)

    if type(entry) ~= "table" then
        return nil
    end

    if mode == "condensed" then
        return entry.condensed or entry.full
    end

    return entry.full or entry.condensed
end


function M.marker_for(style, ascii_safe)
    local semantic_style = M.semantic_style_for(style) or style
    local entry = table_get(M.markers, semantic_style)

    if type(entry) ~= "table" then
        return nil
    end

    if ascii_safe == true then
        return entry.ascii or entry.preferred
    end

    return entry.preferred or entry.ascii
end


local function get_visual_config(config)
    if type(config) ~= "table" then
        return {}
    end

    if type(config.visual_language) == "table" then
        return config.visual_language
    end

    return {}
end


local function normalize_visual_mode_name(mode)
    if type(mode) ~= "string" or mode == "" then
        return nil
    end

    local normalized = mode:lower():gsub("%s+", "")

    if M.visual_modes[normalized] then
        return normalized
    end

    return nil
end


function M.visual_mode_names()
    local result = {}

    for _, mode in ipairs(M.visual_mode_order) do
        table.insert(result, mode)
    end

    return result
end


function M.resolve_visual_mode(config)
    local visual_config = get_visual_config(config)
    local mode = normalize_visual_mode_name(visual_config.mode)

    return mode or "auto"
end


function M.set_visual_mode(config, mode)
    local normalized = normalize_visual_mode_name(mode)

    if not normalized then
        return nil, "invalid visual mode"
    end

    if type(config) ~= "table" then
        return nil, "missing config"
    end

    if type(config.visual_language) ~= "table" then
        config.visual_language = {}
    end

    config.visual_language.mode = normalized

    return normalized
end


local function get_plain_config(config)
    local visual_config = get_visual_config(config)

    if type(visual_config.plain) == "table" then
        return visual_config.plain
    end

    return {}
end


function M.plain_emphasis_enabled(config)
    if M.resolve_visual_mode(config) ~= "plain" then
        return false
    end

    local plain = get_plain_config(config)

    return plain.underline_active_section_title ~= false
        or plain.emphasize_active_path == true
        or plain.shadow_active_path == true
end


function M.plain_style_for(config, style, relevance, usage)
    if not M.plain_emphasis_enabled(config) then
        return nil
    end

    local plain = get_plain_config(config)
    local underline_active_section_title =
        plain.underline_active_section_title ~= false

    usage = usage or "span"

    -- Plain mode should not dim or shadow whole lines by default. Those cues
    -- can be reintroduced later, but the current safe baseline is simple:
    -- only the active root-section title gets underlined.
    if usage == "line" then
        if plain.shadow_active_path == true then
            if style == "active" or relevance == "focused" then
                return "plain_active_shadow"
            end

            if relevance == "current" then
                return "plain_current_shadow"
            end
        end

        return nil
    end

    if style == "section_title"
        or style == "warning_section_title"
    then
        if not underline_active_section_title then
            return nil
        end

        if relevance == "focused"
            or relevance == "current"
        then
            return "plain_active_section_title"
        end

        return nil
    end

    if style == "active"
        and plain.emphasize_active_path == true
    then
        return "plain_active_marker"
    end

    -- In plain mode, semantic spans inside a section intentionally do not
    -- receive per-token color or underline. Text labels carry meaning; the
    -- active root-section title carries the first neutral focus cue.
    return nil
end


function M.colors_enabled(config)
    local visual_config = get_visual_config(config)
    local mode = M.resolve_visual_mode(config)

    if mode == "plain" then
        return false
    end

    local colors_config = type(visual_config.colors) == "table"
        and visual_config.colors
        or {}

    if colors_config.enabled == false then
        return false
    end

    if colors_config.enabled == true then
        return true
    end

    local visual_mode = M.visual_modes[mode]

    if type(visual_mode) == "table"
        and type(visual_mode.force_colors) == "boolean"
    then
        return visual_mode.force_colors
    end

    local tier_name = M.resolve_terminal_tier(config)
    local tier = M.display_tiers[tier_name] or M.display_tiers.truecolor

    return tier.use_colors == true
end


local function get_vim_option(name)
    if type(vim) ~= "table" or type(vim.o) ~= "table" then
        return nil
    end

    local ok, value = pcall(function()
        return vim.o[name]
    end)

    if ok then
        return value
    end

    return nil
end


local function detect_color_count()
    local value = get_vim_option("t_Co")
    local numeric = tonumber(value)

    if numeric then
        return numeric
    end

    if type(vim) == "table" and type(vim.env) == "table" then
        if tostring(vim.env.TERM or ""):find("256color", 1, true) then
            return 256
        end

        if tostring(vim.env.TERM or ""):find("color", 1, true) then
            return 16
        end
    end

    return nil
end


local function normalize_tier_name(name)
    if type(name) ~= "string" or name == "" then
        return nil
    end

    return M.terminal_tier_aliases[name:lower()]
end


function M.detect_terminal_tier()
    if get_vim_option("termguicolors") == true then
        return "truecolor"
    end

    local colors = detect_color_count()

    if colors and colors >= 256 then
        return "color_256"
    end

    if colors and colors >= 16 then
        return "ansi_16"
    end

    if colors and colors > 0 then
        return "monochrome"
    end

    -- In non-Neovim/test environments, default to the least intrusive rich
    -- tier so semantic annotations stay opt-in unless a low-color terminal is
    -- actually detected.
    return "truecolor"
end


function M.resolve_terminal_tier(config)
    local visual_config = get_visual_config(config)
    local requested = visual_config.terminal_tier

    if requested == "auto" or requested == nil then
        return M.detect_terminal_tier()
    end

    return normalize_tier_name(requested) or "truecolor"
end


local function normalize_width_mode(mode)
    if type(mode) ~= "string" or mode == "" then
        return nil
    end

    if M.width_modes[mode] then
        return mode
    end

    return nil
end


function M.resolve_width_mode(config, panel_width)
    local visual_config = get_visual_config(config)
    local width_config = type(visual_config.width) == "table"
        and visual_config.width
        or {}

    local requested = normalize_width_mode(width_config.mode)

    if requested and requested ~= "auto" then
        return requested
    end

    local width = tonumber(panel_width)

    if width then
        local marker_columns = tonumber(width_config.marker_columns) or 40
        local condensed_columns = tonumber(width_config.condensed_columns) or 52

        if width <= marker_columns then
            return "marker"
        end

        if width <= condensed_columns then
            return "condensed"
        end
    end

    return "full"
end


local function auto_enabled(setting, default_auto_value)
    if setting == true then
        return true
    end

    if setting == false then
        return false
    end

    if setting == "auto" or setting == nil then
        return default_auto_value == true
    end

    return false
end


function M.resolve_annotation_mode(config, panel_width)
    local visual_config = get_visual_config(config)
    local visual_mode_name = M.resolve_visual_mode(config)
    local visual_mode = M.visual_modes[visual_mode_name] or M.visual_modes.auto
    local tier_name = M.resolve_terminal_tier(config)
    local tier = M.display_tiers[tier_name] or M.display_tiers.truecolor
    local width_mode_name = M.resolve_width_mode(config, panel_width)
    local width_mode = M.width_modes[width_mode_name] or M.width_modes.full
    local tags_config = type(visual_config.tags) == "table"
        and visual_config.tags
        or {}
    local markers_config = type(visual_config.markers) == "table"
        and visual_config.markers
        or {}

    local tag_mode = tags_config.mode

    if tag_mode == nil or tag_mode == "auto" then
        tag_mode = width_mode.prefer_tags
    end

    if tag_mode == "marker" or tag_mode == "plain" then
        tag_mode = false
    end

    local tier_prefers_tags = tier.use_tags == true
    local tier_prefers_markers = tier.use_markers == true

    local use_tags = auto_enabled(
        tags_config.enabled,
        tier_prefers_tags
    )

    local use_markers = auto_enabled(
        markers_config.enabled,
        tier_prefers_markers
    )

    if width_mode_name == "marker" then
        use_tags = false

        if markers_config.enabled ~= false then
            use_markers = true
        end
    elseif width_mode_name == "plain" then
        use_tags = false
        use_markers = false
    end

    if type(visual_mode.force_tags) == "boolean" then
        use_tags = visual_mode.force_tags
    end

    if type(visual_mode.force_markers) == "boolean" then
        use_markers = visual_mode.force_markers
    end

    if visual_mode_name == "tagged"
        and (tag_mode == nil or tag_mode == "auto" or tag_mode == false)
    then
        tag_mode = width_mode.prefer_tags

        if tag_mode == false then
            tag_mode = "full"
        end
    end

    if not tag_mode then
        use_tags = false
    end

    return {
        visual_mode = visual_mode_name,
        terminal_tier = tier_name,
        width_mode = width_mode_name,
        use_colors = M.colors_enabled(config),
        use_tags = use_tags,
        use_markers = use_markers,
        tag_mode = tag_mode or "full",
        ascii_safe = markers_config.ascii_safe ~= false,
    }
end


function M.annotations_enabled(config, panel_width)
    local mode = M.resolve_annotation_mode(config, panel_width)

    return mode.use_tags == true or mode.use_markers == true
end


function M.annotation_for(style, config, panel_width)
    local semantic_style = M.semantic_style_for(style)

    if not semantic_style then
        return nil
    end

    local mode = M.resolve_annotation_mode(config, panel_width)

    if mode.use_tags ~= true and mode.use_markers ~= true then
        return nil
    end

    local parts = {}
    local marker = nil
    local tag = nil

    if mode.use_markers == true then
        marker = M.marker_for(semantic_style, mode.ascii_safe)

        if marker and marker ~= "" then
            table.insert(parts, marker)
        end
    end

    if mode.use_tags == true then
        tag = M.tag_for(semantic_style, mode.tag_mode)

        if tag and tag ~= "" then
            table.insert(parts, tag)
        end
    end

    if #parts == 0 then
        return nil
    end

    return {
        semantic_style = semantic_style,
        marker = marker,
        tag = tag,
        text = table.concat(parts, " "),
        mode = mode,
    }
end


function M.highlight_priority_for(style, base_priority)
    local base = tonumber(base_priority) or 200
    local priority = M.priority_for(style)

    if not priority then
        return base
    end

    return base + (100 - priority)
end


return M
