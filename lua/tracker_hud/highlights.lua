-- lua/tracker_hud/highlights.lua
--
-- Semantic HUD highlight groups.
--
-- Internal rendering code uses stable semantic style keys. Public Neovim
-- highlight-group names are resolved through tracker_hud.namespace so the
-- final project name is not hard-coded into presentation logic.
--
-- This module intentionally defines presentation TARGETS, not fixed colors.
-- Defaults link to standard Neovim groups. Users/colorschemes can override any
-- generated group, including font-style attributes such as bold, italic,
-- underline, undercurl, strikethrough, and reverse.

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
    warning_rule = "WarningRule",
    resolved = "Resolved",
    unresolved = "Unresolved",

    -- Relevance state. These are presentation modifiers stacked on top of
    -- semantic groups; they are not semantic identities themselves.
    focused = "Focused",
    current = "Current",
    contextual = "Contextual",
    historical = "Historical",

    -- Fallbacks.
    muted = "Muted",
    empty = "Empty",
}

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
    line_number = "LineNr",
    scope = "Function",
    scope_range = "Comment",
    member = "Identifier",
    category = "Type",
    kind = "Type",
    name = "Identifier",
    type = "Type",
    value = "Constant",
    role = "Keyword",
    origin = "String",

    status_label = "Comment",
    status_value = "Identifier",
    target_label = "Keyword",
    target_key = "Comment",
    target_value = "Identifier",
    diagnostic = "DiagnosticWarn",
    metadata = "Comment",
    metadata_key = "Identifier",
    metadata_value = "String",

    register = "Identifier",
    register_alias = "Identifier",
    stack = "Identifier",
    heap = "Identifier",
    event = "Special",
    boundary = "DiagnosticWarn",

    destination = "DiagnosticOk",
    source = "DiagnosticInfo",

    -- Implicit architectural effects deliberately share the warning color
    -- family by default without sharing warning semantics. This makes hidden
    -- register side-effects such as syscall clobbers visually obvious.
    implicit = "DiagnosticWarn",

    warning = "DiagnosticWarn",
    warning_severity = "DiagnosticWarn",
    warning_category = "Special",
    warning_message = "DiagnosticWarn",
    warning_detail_key = "Identifier",
    warning_detail_value = "String",
    warning_rule = "Keyword",
    resolved = "DiagnosticOk",
    unresolved = "DiagnosticWarn",

    muted = "Comment",
    empty = "Comment",
}

local DEFAULT_RELEVANCE_DEFINITIONS = {
    -- Exact semantic occurrence: strongest state while preserving the
    -- underlying semantic foreground color.
    focused = {
        bold = true,
    },

    -- Current line + matching Inspect Mode, but not an exact symbol.
    current = {
        bold = true,
    },

    -- Current line, but another Inspect Mode owns the user's attention.
    -- Italic preserves semantic color while clearly lowering emphasis.
    contextual = {
        italic = true,
    },

    -- Retained state from an earlier source position. The semantic meaning is
    -- still present in the model, but presentation deliberately becomes
    -- past-tense/muted.
    historical = {
        link = "Comment",
    },
}


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


function M.group_name(config, style)
    local suffix = STYLE_SUFFIXES[style]

    if not suffix then
        return nil
    end

    return namespace.name(config, suffix)
end


function M.setup(config)
    if not highlights_enabled(config) then
        return false
    end

    for style, link in pairs(DEFAULT_LINKS) do
        local group = M.group_name(config, style)

        if group then
            vim.api.nvim_set_hl(0, group, {
                link = link,
                default = true,
            })
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
    -- comes first and the relevance modifier comes last, so focused/current
    -- typography can augment semantic color while historical can deliberately
    -- mute it.
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




