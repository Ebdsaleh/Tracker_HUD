-- lua/tracker_hud/highlights.lua
--
-- Semantic HUD highlight groups.
--
-- Internal rendering code uses stable semantic style keys. Public Neovim
-- highlight-group names are resolved through tracker_hud.namespace so the
-- final project name is not hard-coded into presentation logic.
--
-- This module gives semantic information a consistent visual vocabulary:
-- semantic identity chooses the hue/family, while relevance chooses the
-- intensity/emphasis. Users/colorschemes can still override any generated
-- group, including font-style attributes such as bold, italic, underline,
-- undercurl, strikethrough, and reverse.

local namespace = require("tracker_hud.namespace")

local M = {}


local STYLE_SUFFIXES = {
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
    event = "Event",
    boundary = "Boundary",

    -- Occurrence/effect semantics.
    destination = "Destination",
    source = "Source",
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

-- Fallback links for styles that do not need a dedicated default color.
local DEFAULT_LINKS = {
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

-- Default semantic colors. These are deliberately meaning-based rather than
-- section-based:
--
--   cyan       -> keys / register-ish metadata
--   blue       -> line numbers / ordinary numeric anchors
--   teal       -> origin/source information
--   purple     -> boundary/system entities
--   violet     -> rule systems and checks
--   amber      -> warning text / implicated subjects
--   red        -> unresolved/failure state
--   green      -> resolved/success state
--
-- The palette is TokyoNight-friendly but intentionally plain hex so it works
-- with any colorscheme that does not override the generated Hud* groups.
local DEFAULT_STYLE_DEFINITIONS = {
    line_number = { fg = "#7AA2F7" },
    value = { fg = "#C0CAF5" },
    metadata_key = { fg = "#7DCFFF" },
    metadata_value = { fg = "#C0CAF5" },
    origin = { fg = "#73DACA" },

    register = { fg = "#7DCFFF" },
    register_alias = { fg = "#89DDFF" },
    destination = { fg = "#9ECE6A" },
    source = { fg = "#73DACA" },

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

    warning_rule = { fg = "#C678DD" },
    warning_rule_source = { fg = "#9D7CD8" },
    warning_rule_check = { fg = "#FF75A0" },

    resolved = { fg = "#9ECE6A" },
    unresolved = { fg = "#F7768E" },
}

-- Relevance is an intensity/emphasis layer, not a replacement for the
-- semantic hue. Styles with DEFAULT_STYLE_DEFINITIONS get combined groups such
-- as HudWarningSubjectFocused and HudWarningSubjectHistorical so historical
-- values can become dull amber/purple/red instead of collapsing to identical
-- gray.
local DEFAULT_RELEVANCE_DEFINITIONS = {
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

local DEFAULT_RELEVANCE_COLOR_MIXES = {
    focused = 0.00,
    current = 0.00,
    contextual = 0.34,
    historical = 0.58,
}

local RELEVANCE_MUTE_TARGET = "#565F89"


local render_namespace =
    vim.api.nvim_create_namespace(
        "tracker_hud_render_highlights"
    )


local function highlights_enabled(config)
    return not (
        type(config) == "table"
        and type(config.highlights) == "table"
        and config.highlights.enabled == false
    )
end


function M.is_enabled(config)
    return highlights_enabled(config)
end


local function normalize_column(value)
    local number = tonumber(value)

    if not number then
        return nil
    end

    return math.max(0, math.floor(number))
end


local function copy_definition(definition)
    local result = {}

    for key, value in pairs(definition or {}) do
        result[key] = value
    end

    return result
end


local function parse_hex_channel(value)
    local parsed = tonumber(value, 16)

    if type(parsed) ~= "number" then
        return nil
    end

    return parsed
end


local function parse_hex_color(color)
    if type(color) ~= "string" then
        return nil
    end

    local r, g, b = color:match("^#(%x%x)(%x%x)(%x%x)$")

    if not r then
        return nil
    end

    return {
        r = parse_hex_channel(r),
        g = parse_hex_channel(g),
        b = parse_hex_channel(b),
    }
end


local function clamp_channel(value)
    return math.max(0, math.min(255, math.floor(value + 0.5)))
end


local function format_hex_color(rgb)
    if type(rgb) ~= "table"
        or type(rgb.r) ~= "number"
        or type(rgb.g) ~= "number"
        or type(rgb.b) ~= "number"
    then
        return nil
    end

    return string.format(
        "#%02X%02X%02X",
        clamp_channel(rgb.r),
        clamp_channel(rgb.g),
        clamp_channel(rgb.b)
    )
end


local function blend_hex_color(color, target, amount)
    local source_rgb = parse_hex_color(color)
    local target_rgb = parse_hex_color(target)
    local numeric_amount = tonumber(amount) or 0

    if not source_rgb or not target_rgb then
        return color
    end

    numeric_amount = math.max(0, math.min(1, numeric_amount))

    return format_hex_color({
        r = source_rgb.r + ((target_rgb.r - source_rgb.r) * numeric_amount),
        g = source_rgb.g + ((target_rgb.g - source_rgb.g) * numeric_amount),
        b = source_rgb.b + ((target_rgb.b - source_rgb.b) * numeric_amount),
    }) or color
end


function M.group_name(config, style)
    local suffix = STYLE_SUFFIXES[style]

    if not suffix then
        return nil
    end

    return namespace.name(config, suffix)
end


local function composite_group_name(
    config,
    style,
    relevance
)
    local style_suffix = STYLE_SUFFIXES[style]
    local relevance_suffix = STYLE_SUFFIXES[relevance]

    if not style_suffix
        or not relevance_suffix
        or type(DEFAULT_STYLE_DEFINITIONS[style]) ~= "table"
    then
        return nil
    end

    return namespace.name(
        config,
        style_suffix .. relevance_suffix
    )
end


local function relevance_definition(relevance)
    return DEFAULT_RELEVANCE_DEFINITIONS[relevance] or {}
end


local function composite_definition(style, relevance)
    local base = DEFAULT_STYLE_DEFINITIONS[style]

    if type(base) ~= "table" then
        return nil
    end

    local result = copy_definition(base)
    local mix = DEFAULT_RELEVANCE_COLOR_MIXES[relevance]

    if type(result.fg) == "string" and mix ~= nil then
        result.fg = blend_hex_color(
            result.fg,
            RELEVANCE_MUTE_TARGET,
            mix
        )
    end

    for key, value in pairs(relevance_definition(relevance)) do
        result[key] = value
    end

    return result
end


local function set_default_highlight(group, definition)
    if type(group) ~= "string"
        or group == ""
        or type(definition) ~= "table"
    then
        return false
    end

    local resolved = {
        default = true,
    }

    for key, value in pairs(definition) do
        resolved[key] = value
    end

    vim.api.nvim_set_hl(
        0,
        group,
        resolved
    )

    return true
end


function M.setup(config)
    if not highlights_enabled(config) then
        return false
    end

    for style, link in pairs(DEFAULT_LINKS) do
        if DEFAULT_STYLE_DEFINITIONS[style] == nil then
            local group = M.group_name(config, style)

            if group then
                set_default_highlight(group, {
                    link = link,
                })
            end
        end
    end

    for style, definition in pairs(DEFAULT_STYLE_DEFINITIONS) do
        local group = M.group_name(config, style)

        if group then
            set_default_highlight(
                group,
                definition
            )
        end
    end

    for relevance, definition in pairs(
        DEFAULT_RELEVANCE_DEFINITIONS
    ) do
        local group = M.group_name(
            config,
            relevance
        )

        if group then
            set_default_highlight(
                group,
                definition
            )
        end
    end

    for style, _definition in pairs(DEFAULT_STYLE_DEFINITIONS) do
        for relevance, _relevance_definition in pairs(
            DEFAULT_RELEVANCE_DEFINITIONS
        ) do
            local group = composite_group_name(
                config,
                style,
                relevance
            )

            local definition = composite_definition(
                style,
                relevance
            )

            if group and definition then
                set_default_highlight(
                    group,
                    definition
                )
            end
        end
    end

    return true
end


function M.clear_buffer(bufnr)
    if not bufnr
        or not vim.api.nvim_buf_is_valid(bufnr)
    then
        return false
    end

    vim.api.nvim_buf_clear_namespace(
        bufnr,
        render_namespace,
        0,
        -1
    )

    return true
end


local function build_group_stack(
    config,
    style,
    relevance
)
    local composite_group = composite_group_name(
        config,
        style,
        relevance
    )

    if composite_group then
        return composite_group
    end

    local groups = {}

    local semantic_group =
        M.group_name(config, style)

    if semantic_group then
        table.insert(groups, semantic_group)
    end

    local relevance_group =
        M.group_name(config, relevance)

    if relevance_group then
        table.insert(groups, relevance_group)
    end

    if #groups == 0 then
        return nil
    end

    if #groups == 1 then
        return groups[1]
    end

    -- Neovim extmarks support a stack of highlight groups. The semantic group
    -- comes first and the relevance modifier comes last. For known semantic
    -- colors we return a relevance-specific composite group above; this stack
    -- remains the fallback for colorscheme-linked/custom styles.
    return groups
end


local function normalize_style_spec(spec)
    if type(spec) == "string" then
        return spec, nil
    end

    if type(spec) == "table" then
        return spec.style, spec.relevance
    end

    return nil, nil
end


local function apply_line_style(
    bufnr,
    config,
    line_number,
    style_spec
)
    local style, relevance =
        normalize_style_spec(style_spec)

    local group = build_group_stack(
        config,
        style,
        relevance
    )

    local numeric_line = tonumber(line_number)

    if not group or not numeric_line then
        return
    end

    pcall(
        vim.api.nvim_buf_set_extmark,
        bufnr,
        render_namespace,
        numeric_line - 1,
        0,
        {
            end_row = numeric_line - 1,
            end_col = -1,
            strict = false,
            hl_group = group,
            priority = 150,
        }
    )
end

local function apply_span(
    bufnr,
    config,
    line_number,
    span
)
    if type(span) ~= "table" then
        return
    end

    local group = build_group_stack(
        config,
        span.style,
        span.relevance
    )

    local start_col =
        normalize_column(span.start_col)

    local end_col =
        normalize_column(span.end_col)

    local numeric_line =
        tonumber(line_number)

    if not group
        or not numeric_line
        or start_col == nil
        or end_col == nil
        or end_col <= start_col
    then
        return
    end

    local row = numeric_line - 1

    -- Extmarks give semantic spans an explicit priority over a whole-line
    -- fallback style. This is important when, for example, an active row has
    -- a destination-colored register name and separately styled value.
    pcall(
        vim.api.nvim_buf_set_extmark,
        bufnr,
        render_namespace,
        row,
        start_col,
        {
            end_row = row,
            end_col = end_col,
            hl_group = group,
            priority = tonumber(span.priority) or 200,
        }
    )
end


function M.apply_styles(
    bufnr,
    config,
    line_styles,
    line_spans
)
    if not bufnr
        or not vim.api.nvim_buf_is_valid(bufnr)
    then
        return false
    end

    M.clear_buffer(bufnr)

    if not highlights_enabled(config) then
        return true
    end

    -- Whole-line styles remain a useful fallback for unstructured/custom
    -- output. Structured semantic spans are applied afterwards at higher
    -- priority.
    for line_number, style in pairs(
        line_styles or {}
    ) do
        apply_line_style(
            bufnr,
            config,
            line_number,
            style
        )
    end

    for line_number, spans in pairs(
        line_spans or {}
    ) do
        for _, span in ipairs(spans or {}) do
            apply_span(
                bufnr,
                config,
                line_number,
                span
            )
        end
    end

    return true
end


-- Compatibility wrapper for callers that only provide whole-line styles.
function M.apply_line_styles(
    bufnr,
    config,
    line_styles
)
    return M.apply_styles(
        bufnr,
        config,
        line_styles,
        nil
    )
end


function M.styles()
    local result = {}

    for style, _suffix in pairs(
        STYLE_SUFFIXES
    ) do
        table.insert(result, style)
    end

    table.sort(result)
    return result
end


return M

