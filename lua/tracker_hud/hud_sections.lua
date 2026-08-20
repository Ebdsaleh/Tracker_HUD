-- lua/tracker_hud/hud_sections.lua
--
-- HUD section state and section construction.

local hud_controls = require("tracker_hud.hud_controls")
local scope_member_tree = require("tracker_hud.scope_member_tree")
local register_tree = require("tracker_hud.sections.low_level.register_tree")
local event_tree = require("tracker_hud.event_tree")
local stack_tree = require("tracker_hud.sections.low_level.stack_tree")
local heap_tree = require("tracker_hud.sections.low_level.heap_tree")
local warning_tree = require("tracker_hud.warning_tree")
local hud_nodes = require("tracker_hud.hud_nodes")
local symbol_state = require("tracker_hud.symbol_state")
local adapter_registry = require("tracker_hud.adapters.registry")
local context_engine = require("tracker_hud.context_engine")
local source_index = require("tracker_hud.source_index")
local source_index_compiler = require("tracker_hud.source_index.compiler")
local hud_text = require("tracker_hud.hud_text")
local hud_relevance = require("tracker_hud.hud_relevance")
local visual_language = require("tracker_hud.visual_language")


local M = {}

local section_state = {
    scope = true,
    scope_members = false,
    warnings = false,
}

-- Explicit source Inspect is a toggle action.
--
-- Registers need one small piece of source-action identity because two
-- different source occurrences can address the same register node:
--
--     xor [rdi], rdi    -> RDI destination
--     xor rdi, [rdi]    -> RDI source
--
-- Moving between those occurrences should reveal the newly selected
-- occurrence, while pressing Inspect again on the SAME occurrence should
-- collapse what that action opened.
local last_register_inspect_key = nil


local function validate_section(section_id)
    return type(section_id) == "string"
        and section_id ~= ""
        and section_state[section_id] ~= nil
end


local function get_default_expanded(section_id)
    return section_id == "scope"
end


function M.sync_sections(section_layout)
    if type(section_layout) ~= "table"
        or type(section_layout.by_id) ~= "table"
    then
        return false
    end

    local next_state = {}

    for section_id, _descriptor in pairs(section_layout.by_id) do
        if type(section_id) == "string"
            and section_id ~= ""
        then
            if section_state[section_id] ~= nil then
                next_state[section_id] = section_state[section_id]
            else
                next_state[section_id] = get_default_expanded(section_id)
            end
        end
    end

    section_state = next_state

    return true
end


function M.toggle(section_id)
    if not validate_section(section_id) then
        return false
    end

    section_state[section_id] = not section_state[section_id]
    return true
end


function M.is_expanded(section_id)
    if not validate_section(section_id) then
        return false
    end

    return section_state[section_id] == true
end


function M.set_expanded(section_id, expanded)
    if not validate_section(section_id) then
        return false
    end

    section_state[section_id] = expanded == true
    return true
end


local function get_display_width(text)
    local ok, width = pcall(vim.fn.strdisplaywidth, text or "")

    if ok and type(width) == "number" then
        return width
    end

    return #(text or "")
end


local function fit_width(text, max_width)
    if not max_width or max_width <= 0 then
        return true
    end

    return get_display_width(text) <= max_width
end


local function node_has_children(node)
    return type(node) == "table"
        and type(node.children) == "table"
        and #node.children > 0
end


local function get_node_default_expanded(node)
    if type(node) ~= "table" then
        return false
    end

    if type(node.default_expanded) == "boolean" then
        return node.default_expanded
    end

    return node.kind == "scope"
end



local function node_matches_cursor(node, opts)
    if type(node) ~= "table" or type(opts) ~= "table" then
        return false
    end

    local source_line = tonumber(opts.active_source_line)
    local source_column = tonumber(opts.active_source_column)

    if not source_line or not source_column then
        return false
    end

    local start_line = tonumber(node.source_start_line or node.source_line)
    local end_line = tonumber(node.source_end_line or node.source_line)

    if not start_line or not end_line then
        return false
    end

    if source_line < start_line or source_line > end_line then
        return false
    end

    local start_column = tonumber(node.source_start_column or node.source_column or 0)
    local end_column = tonumber(node.source_end_column or node.source_column or start_column)

    if start_line == end_line then
        return source_column >= start_column
            and source_column <= end_column
    end

    if source_line == start_line then
        return source_column >= start_column
    end

    if source_line == end_line and end_column > 0 then
        return source_column <= end_column
    end

    return true
end


local function get_node_marker(node, opts)
    local active_marker = " "
    local explicit_active_ids = type(opts) == "table"
        and opts.explicit_active_node_ids
        or nil

    if node_has_children(node) then
        if type(explicit_active_ids) == "table" then
            if explicit_active_ids[node.id] == true then
                active_marker = "*"
            end
        elseif node_matches_cursor(node, opts) then
            active_marker = "*"
        end
    end

    if not node_has_children(node) then
        return "  -"
    end

    if hud_nodes.is_expanded(node.id, get_node_default_expanded(node)) then
        return active_marker .. "[-]"
    end

    return active_marker .. "[+]"
end


local function get_node_style(node, opts)
    if type(node) ~= "table" then
        return nil
    end

    local style_by_node_id = type(opts) == "table"
        and opts.style_by_node_id
        or nil

    if type(style_by_node_id) == "table"
        and style_by_node_id[node.id]
    then
        return style_by_node_id[node.id]
    end

    if type(node.style) == "string" and node.style ~= "" then
        return node.style
    end

    if node.kind == "warning" then
        return "warning"
    end

    if node.kind == "detail" or node.kind == "warning_detail" then
        return "metadata"
    end

    return nil
end


local function build_scope_range_label(node)
    if type(node) ~= "table" then
        return nil
    end

    if not node.scope_start_line or not node.scope_end_line then
        return nil
    end

    return "[scope "
        .. tostring(node.scope_start_line)
        .. " - "
        .. tostring(node.scope_end_line)
        .. "]"
end


local function node_base_style(node, opts)
    local explicit = get_node_style(node, opts)

    if explicit then
        return explicit
    end

    if type(node) ~= "table" then
        return nil
    end

    if node.kind == "scope" then
        return "scope"
    end

    if node.kind == "member" then
        return "member"
    end

    if node.kind == "register"
        or node.kind == "register_group"
    then
        return "register"
    end

    if node.kind == "register_alias" then
        return "register_alias"
    end

    if node.kind == "stack" then
        return "stack"
    end

    if node.kind == "heap_entry"
        or node.kind == "heap_root"
    then
        return "heap"
    end

    if type(node.event) == "table" then
        return "event"
    end

    if node.kind == "warning" then
        return "warning"
    end

    if node.kind == "detail"
        or node.kind == "warning_detail"
    then
        return "metadata"
    end

    return "name"
end


local function add_literal_spans(
    line,
    label_offset,
    label,
    literal,
    style,
    priority
)
    if type(line) ~= "table"
        or type(label) ~= "string"
        or type(literal) ~= "string"
        or literal == ""
        or type(style) ~= "string"
    then
        return
    end

    local search_from = 1

    while true do
        local start_index, end_index =
            label:find(
                literal,
                search_from,
                true
            )

        if not start_index then
            break
        end

        hud_text.add_span(
            line,
            label_offset + start_index - 1,
            label_offset + end_index,
            style,
            priority
        )

        search_from = end_index + 1
    end
end


local function add_pattern_capture_span(
    line,
    label_offset,
    label,
    pattern,
    style,
    priority
)
    if type(label) ~= "string" then
        return
    end

    local captured = label:match(pattern)

    if type(captured) ~= "string"
        or captured == ""
    then
        return
    end

    local capture_start, capture_end =
        label:find(captured, 1, true)

    if not capture_start then
        return
    end

    hud_text.add_span(
        line,
        label_offset + capture_start - 1,
        label_offset + capture_end,
        style,
        priority
    )
end


local function style_common_punctuation(
    line,
    label_offset,
    label
)
    for _, literal in ipairs({
        "(",
        ")",
        "[",
        "]",
        "#",
    }) do
        add_literal_spans(
            line,
            label_offset,
            label,
            literal,
            "punctuation",
            245
        )
    end

    for _, literal in ipairs({
        " = ",
        " <- ",
        " -> ",
        " @ ",
        " - ",
    }) do
        add_literal_spans(
            line,
            label_offset,
            label,
            literal,
            "operator",
            245
        )
    end
end


local function detail_styles_for_key(key, semantic_override, value, node)
    if type(node) == "table"
        and (node.detail_key_style or node.detail_value_style)
    then
        return node.detail_key_style or "metadata_key",
            node.detail_value_style or "metadata_value"
    end

    return visual_language.detail_styles_for_key(
        key,
        value,
        semantic_override
    )
end


local function style_detail_label(
    line,
    label_offset,
    label,
    node,
    semantic_override
)
    local key, value_start =
        label:match("^([^:]+):%s*()")

    if type(key) ~= "string"
        or not value_start
    then
        return false
    end

    local key_start = 1
    local key_end = #key
    local value = label:sub(value_start)

    local key_style, value_style = detail_styles_for_key(
        key,
        semantic_override,
        value,
        node
    )

    hud_text.add_span(
        line,
        label_offset + key_start - 1,
        label_offset + key_end,
        key_style,
        230
    )

    local colon_start = label:find(":", 1, true)

    if colon_start then
        hud_text.add_span(
            line,
            label_offset + colon_start - 1,
            label_offset + colon_start,
            "punctuation",
            245
        )
    end

    if value ~= "" then
        hud_text.add_span(
            line,
            label_offset + value_start - 1,
            label_offset + #label,
            value_style,
            semantic_override and 260 or 230
        )
    end

    return true
end


local function warning_detail_value_style(node)
    if type(node) ~= "table" then
        return "warning_detail_value"
    end

    local detail_kind = node.detail_kind

    if detail_kind == "line" then
        return "line_number"
    end

    if detail_kind == "source" then
        return "origin"
    end

    if detail_kind == "register"
        or detail_kind == "pointer"
        or detail_kind == "symbol"
        or detail_kind == "address"
        or detail_kind == "argument_name"
    then
        -- Warning subjects are the implicated things named by a warning.
        -- They should not collapse into generic register/value styling, and
        -- they should not share the hotter failure color used by unresolved.
        return "warning_subject"
    end

    if detail_kind == "boundary" then
        return "boundary"
    end

    if detail_kind == "rule_source" then
        return "warning_rule_source"
    end

    if detail_kind == "rule_check" then
        return "warning_rule_check"
    end

    if detail_kind == "rule" then
        return "warning_rule"
    end

    if detail_kind == "argument_index"
        or detail_kind == "value"
    then
        return "value"
    end

    if detail_kind == "resolution" then
        if node.detail_value == false
            or tostring(node.detail_value):lower() == "false"
        then
            return "unresolved"
        end

        return "resolved"
    end

    return "warning_detail_value"
end


local function style_structured_warning_detail(
    line,
    label_offset,
    label,
    node
)
    if type(node) ~= "table"
        or node.kind ~= "warning_detail"
        or node.detail_key == nil
        or node.detail_value == nil
    then
        return false
    end

    local key = tostring(node.detail_key)
    local value = tostring(node.detail_value)
    local key_start, key_end = label:find(key, 1, true)

    if key_start then
        hud_text.add_span(
            line,
            label_offset + key_start - 1,
            label_offset + key_end,
            "warning_detail_key",
            245
        )
    end

    local colon_start = label:find(":", 1, true)

    if colon_start then
        hud_text.add_span(
            line,
            label_offset + colon_start - 1,
            label_offset + colon_start,
            "punctuation",
            255
        )
    end

    local value_start = nil

    if colon_start then
        value_start = label:find(value, colon_start + 1, true)
    end

    if value_start then
        hud_text.add_span(
            line,
            label_offset + value_start - 1,
            label_offset + value_start - 1 + #value,
            warning_detail_value_style(node),
            260
        )
    end

    return true
end


local function style_known_node_fields(
    line,
    label_offset,
    label,
    node,
    semantic_override
)
    if type(node) ~= "table" then
        return
    end

    if node.kind == "warning_detail"
        and style_structured_warning_detail(
            line,
            label_offset,
            label,
            node
        )
    then
        style_common_punctuation(
            line,
            label_offset,
            label
        )
        return
    end

    if node.kind == "detail"
        or node.kind == "warning_detail"
    then
        if style_detail_label(
            line,
            label_offset,
            label,
            node,
            semantic_override
        ) then
            return
        end
    end

    -- Leading line-number token used by Scope Members.
    add_pattern_capture_span(
        line,
        label_offset,
        label,
        "^%[(%d+)%]",
        "line_number",
        235
    )

    -- Leading classification/category token used by members, registers,
    -- stack, heap, and events.
    add_pattern_capture_span(
        line,
        label_offset,
        label,
        "^%((.-)%)",
        (
            type(node.event) == "table"
            and "category"
            or "kind"
        ),
        235
    )

    if node.kind == "member"
        and type(node.member) == "table"
    then
        add_literal_spans(
            line,
            label_offset,
            label,
            tostring(node.member.name or ""),
            "member",
            240
        )
    elseif node.kind == "register"
        and type(node.register) == "table"
    then
        local register = node.register

        add_literal_spans(
            line,
            label_offset,
            label,
            tostring(register.name or ""),
            semantic_override or "register",
            semantic_override and 260 or 240
        )

        if register.value ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(register.value),
                "value",
                235
            )
        end

        local metadata = register.metadata or {}

        if metadata.alias_written then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(metadata.alias_written),
                "register_alias",
                240
            )
        end

        if type(metadata.alias_spec) == "table"
            and metadata.alias_spec.write_mode
        then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(metadata.alias_spec.write_mode),
                "qualifier",
                240
            )
        end
    elseif node.kind == "register_alias" then
        add_literal_spans(
            line,
            label_offset,
            label,
            tostring(node.alias_name or ""),
            semantic_override or "register_alias",
            semantic_override and 260 or 240
        )

        local alias_spec = node.alias_spec or {}

        if alias_spec.bits ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(alias_spec.bits),
                "value",
                235
            )
        end

        if alias_spec.offset ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(alias_spec.offset),
                "value",
                235
            )
        end

        if alias_spec.write_mode then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(alias_spec.write_mode),
                "qualifier",
                240
            )
        end
    elseif node.kind == "stack"
        and type(node.stack_entry) == "table"
    then
        local entry = node.stack_entry

        add_literal_spans(
            line,
            label_offset,
            label,
            tostring(entry.name or ""),
            "stack",
            240
        )

        if entry.offset ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(entry.offset),
                "value",
                235
            )
        end

        if entry.value ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(entry.value),
                "value",
                235
            )
        end
    elseif node.kind == "heap_entry"
        and type(node.heap_entry) == "table"
    then
        local entry = node.heap_entry

        add_literal_spans(
            line,
            label_offset,
            label,
            tostring(entry.name or ""),
            "heap",
            240
        )

        if entry.effect_key ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(entry.effect_key),
                "value",
                235
            )
        end

        if entry.result_register ~= nil then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(entry.result_register),
                "register",
                240
            )
        end
    elseif type(node.event) == "table" then
        local event = node.event

        add_literal_spans(
            line,
            label_offset,
            label,
            tostring(event.name or ""),
            "event",
            240
        )

        if event.role then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(event.role),
                "role",
                240
            )
        end
    elseif node.kind == "warning"
        and type(node.warning) == "table"
    then
        local warning = node.warning

        if warning.severity then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(warning.severity),
                "warning_severity",
                250
            )
        end

        if warning.category then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(warning.category),
                "warning_category",
                250
            )
        end

        if warning.message then
            add_literal_spans(
                line,
                label_offset,
                label,
                tostring(warning.message),
                "warning_message",
                250
            )
        end
    elseif node.kind == "scope" then
        hud_text.add_span(
            line,
            label_offset,
            label_offset + #label,
            "scope",
            230
        )
    end

    style_common_punctuation(
        line,
        label_offset,
        label
    )
end


local function parse_detail_parts(node, label)
    if type(node) == "table"
        and node.detail_key ~= nil
        and node.detail_value ~= nil
    then
        return tostring(node.detail_key), tostring(node.detail_value)
    end

    if type(label) ~= "string" then
        return nil, nil
    end

    local key, value = label:match("^([^:]+):%s?(.*)$")

    if type(key) ~= "string" then
        return nil, nil
    end

    return key, value or ""
end


local function build_annotated_detail_line(
    node,
    marker,
    label,
    indent,
    opts,
    semantic_override
)
    opts = opts or {}

    if not hud_text.annotations_enabled(
        opts.config,
        opts.panel_width
    ) then
        return nil
    end

    if type(node) ~= "table"
        or (node.kind ~= "detail" and node.kind ~= "warning_detail")
    then
        return nil
    end

    local key, value = parse_detail_parts(node, label)

    if type(key) ~= "string" then
        return nil
    end

    local key_style = "metadata_key"
    local value_style = "metadata_value"

    if node.kind == "warning_detail" then
        key_style = "warning_detail_key"
        value_style = warning_detail_value_style(node)
    else
        key_style, value_style = detail_styles_for_key(
            key,
            semantic_override,
            value,
            node
        )
    end

    local line = hud_text.new()

    hud_text.append(
        line,
        indent or "",
        nil
    )

    hud_text.append(
        line,
        marker or "",
        "tree_marker"
    )

    hud_text.append(line, " ", nil)

    hud_text.append_annotation_prefix(
        line,
        "metadata_key",
        opts.config,
        opts.panel_width
    )

    hud_text.append(
        line,
        key,
        key_style
    )

    hud_text.append(
        line,
        ": ",
        "punctuation"
    )

    hud_text.append_annotation_prefix(
        line,
        value_style,
        opts.config,
        opts.panel_width
    )

    hud_text.append(
        line,
        value,
        value_style
    )

    return line
end


local function build_node_line(
    node,
    marker,
    label,
    indent,
    range_label,
    opts
)
    local line = hud_text.new()
    local semantic_override =
        get_node_style(node, opts)

    local annotated_detail = build_annotated_detail_line(
        node,
        marker,
        label,
        indent,
        opts,
        semantic_override
    )

    if annotated_detail then
        return annotated_detail
    end

    hud_text.append(
        line,
        indent or "",
        nil
    )

    local marker_offset = #line.text

    hud_text.append(
        line,
        marker or "",
        "tree_marker"
    )

    if type(marker) == "string" then
        local active_start =
            marker:find("*", 1, true)

        if active_start then
            hud_text.add_span(
                line,
                marker_offset + active_start - 1,
                marker_offset + active_start,
                "active",
                270
            )
        end
    end

    hud_text.append(line, " ", nil)

    hud_text.append_annotation_prefix(
        line,
        semantic_override or node_base_style(node, opts),
        opts.config,
        opts.panel_width
    )

    local label_offset = #line.text

    hud_text.append(
        line,
        label,
        node_base_style(node, opts)
    )

    style_known_node_fields(
        line,
        label_offset,
        label,
        node,
        semantic_override
    )

    if range_label then
        hud_text.append(
            line,
            "  ",
            nil
        )

        local range_offset = #line.text

        hud_text.append(
            line,
            range_label,
            "scope_range"
        )

        add_pattern_capture_span(
            line,
            range_offset,
            range_label,
            "^%[scope%s+(%d+)",
            "line_number",
            235
        )

        local second_line =
            range_label:match("%-%s+(%d+)%]$")

        if second_line then
            local start_index =
                range_label:find(
                    second_line,
                    1,
                    true
                )

            if start_index then
                hud_text.add_span(
                    line,
                    range_offset + start_index - 1,
                    range_offset + start_index - 1 + #second_line,
                    "line_number",
                    235
                )
            end
        end

        style_common_punctuation(
            line,
            range_offset,
            range_label
        )
    end

    return line
end


local function apply_render_relevance(rendered, relevance)
    hud_text.set_relevance(
        rendered,
        relevance
    )

    return rendered
end


local function append_rendered_line(
    result,
    rendered,
    target
)
    table.insert(
        result.lines,
        hud_text.to_text(rendered)
    )

    result.spans[#result.lines] =
        hud_text.spans(rendered)

    if target then
        result.targets[#result.lines] =
            target
    end
end


local function node_is_explicit_active_path(node, marker, opts)
    if type(node) ~= "table" then
        return false
    end

    opts = opts or {}

    if node.id ~= nil
        and type(opts.focused_node_ids) == "table"
        and opts.focused_node_ids[node.id] == true
    then
        return true
    end

    if node.id ~= nil
        and type(opts.explicit_active_node_ids) == "table"
        and opts.explicit_active_node_ids[node.id] == true
    then
        return true
    end

    -- The visual active path should match the explicit `*` marker. This keeps
    -- plain-mode background shadows restricted to concrete affected rows
    -- instead of every presentation/category row inside an active section.
    return type(marker) == "string"
        and marker:find("*", 1, true) ~= nil
end


local function append_scope_member_tree_lines(
    result,
    nodes,
    depth,
    opts,
    inherited_relevance
)
    depth = depth or 0
    opts = opts or {}

    local indent = string.rep("  ", depth)
    local panel_width = opts.panel_width or 0

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local relevance = hud_relevance.classify_node(
                node,
                opts,
                inherited_relevance
            )

            local label =
                node.label
                or tostring(node.id or "")

            local matches_cursor =
                node_matches_cursor(node, opts)

            if matches_cursor then
                result.active = true
            end

            local marker =
                get_node_marker(node, opts)

            local range_label =
                build_scope_range_label(node)

            local target_style = get_node_style(node, opts)

            if node_is_explicit_active_path(node, marker, opts) then
                target_style = "active_path"
            end

            local target = {
                kind = "node",
                id = node.id,
                source_line = node.source_line,
                source_column = node.source_column,
                style = target_style,
                relevance = relevance,
            }

            if node.kind == "scope"
                and range_label
            then
                local inline =
                    apply_render_relevance(
                        build_node_line(
                            node,
                            marker,
                            label,
                            indent,
                            range_label,
                            opts
                        ),
                        relevance
                    )

                if fit_width(
                    inline.text,
                    panel_width
                ) then
                    append_rendered_line(
                        result,
                        inline,
                        target
                    )
                else
                    append_rendered_line(
                        result,
                        apply_render_relevance(
                            build_node_line(
                                node,
                                marker,
                                label,
                                indent,
                                nil,
                                opts
                            ),
                            relevance
                        ),
                        target
                    )

                    local range_line =
                        hud_text.new()

                    hud_text.append(
                        range_line,
                        indent .. "  ",
                        nil
                    )

                    local range_offset =
                        #range_line.text

                    hud_text.append(
                        range_line,
                        range_label,
                        "scope_range"
                    )

                    style_common_punctuation(
                        range_line,
                        range_offset,
                        range_label
                    )

                    hud_text.set_relevance(
                        range_line,
                        relevance
                    )

                    append_rendered_line(
                        result,
                        range_line,
                        nil
                    )
                end
            else
                append_rendered_line(
                    result,
                    apply_render_relevance(
                        build_node_line(
                            node,
                            marker,
                            label,
                            indent,
                            nil,
                            opts
                        ),
                        relevance
                    ),
                    target
                )
            end

            if node_has_children(node)
                and hud_nodes.is_expanded(
                    node.id,
                    get_node_default_expanded(
                        node
                    )
                )
            then
                append_scope_member_tree_lines(
                    result,
                    node.children,
                    depth + 1,
                    opts,
                    relevance
                )
            end
        elseif type(node) == "string" then
            local line =
                hud_text.plain(
                    indent .. node,
                    "metadata"
                )

            hud_text.set_relevance(
                line,
                inherited_relevance
                    or opts.section_relevance
                    or "historical"
            )

            append_rendered_line(
                result,
                line,
                nil
            )
        end
    end
end


local function build_scope_member_tree_lines(
    nodes,
    opts
)
    local result = {
        lines = {},
        targets = {},
        spans = {},
        active = false,
    }

    append_scope_member_tree_lines(
        result,
        nodes,
        0,
        opts
    )

    return result
end


local function build_hud_tree_lines(nodes, opts)
    local result = {
        lines = {},
        targets = {},
        spans = {},
        active = false,
    }

    append_scope_member_tree_lines(
        result,
        nodes,
        0,
        opts
    )

    return result
end


local function get_node_source_range(node)
    if type(node) ~= "table" then
        return nil
    end

    if node.source_start_line and node.source_end_line then
        return {
            start_line = node.source_start_line,
            start_column = node.source_start_column or 0,
            end_line = node.source_end_line,
            end_column = node.source_end_column or 0,
        }
    end

    if node.scope_start_line and node.scope_end_line then
        return {
            start_line = node.scope_start_line,
            start_column = node.scope_start_column or 0,
            end_line = node.scope_end_line,
            end_column = node.scope_end_column or 0,
        }
    end

    if type(node.member) == "table" then
        if node.member.value_start_line and node.member.value_end_line then
            return {
                start_line = node.member.value_start_line,
                start_column = node.member.value_start_column or 0,
                end_line = node.member.value_end_line,
                end_column = node.member.value_end_column or 0,
            }
        end

        if node.member.source_start_line and node.member.source_end_line then
            return {
                start_line = node.member.source_start_line,
                start_column = node.member.source_start_column or 0,
                end_line = node.member.source_end_line,
                end_column = node.member.source_end_column or 0,
            }
        end

        if node.member.line then
            return {
                start_line = node.member.line,
                start_column = 0,
                end_line = node.member.line,
                end_column = 0,
            }
        end
    end

    if node.source_line then
        return {
            start_line = node.source_line,
            start_column = node.source_column or 0,
            end_line = node.source_line,
            end_column = node.source_column or 0,
        }
    end

    return nil
end


local function position_is_in_range(source_line, source_column, range)
    if not source_line or type(range) ~= "table" then
        return false
    end

    local start_line = range.start_line
    local end_line = range.end_line

    if not start_line or not end_line then
        return false
    end

    source_column = tonumber(source_column) or 0

    local start_column = tonumber(range.start_column) or 0
    local end_column = tonumber(range.end_column) or 0

    if source_line < start_line or source_line > end_line then
        return false
    end

    if start_line == end_line then
        return source_column >= start_column
            and source_column <= end_column
    end

    if source_line == start_line then
        return source_column >= start_column
    end

    if source_line == end_line and end_column > 0 then
        return source_column <= end_column
    end

    return true
end


local function node_contains_position(node, source_line, source_column)
    local range = get_node_source_range(node)

    return position_is_in_range(source_line, source_column, range)
end


local function find_deepest_node_path_for_position(
    nodes,
    source_line,
    source_column,
    current_path,
    best_path
)
    current_path = current_path or {}
    best_path = best_path or nil

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local range = get_node_source_range(node)

            if range
                and position_is_in_range(
                    source_line,
                    source_column,
                    range
                )
            then
                local next_path = {}

                for _, path_node in ipairs(current_path) do
                    table.insert(next_path, path_node)
                end

                table.insert(next_path, node)
                best_path = next_path

                if node_has_children(node) then
                    best_path = find_deepest_node_path_for_position(
                        node.children,
                        source_line,
                        source_column,
                        next_path,
                        best_path
                    )
                end

            elseif not range and node_has_children(node) then
                -- Presentation/group nodes may intentionally have no source
                -- range of their own. Search through them so source-backed
                -- descendants remain inspectable, while preserving the
                -- container in the returned reveal path.
                local next_path = {}

                for _, path_node in ipairs(current_path) do
                    table.insert(next_path, path_node)
                end

                table.insert(next_path, node)

                best_path = find_deepest_node_path_for_position(
                    node.children,
                    source_line,
                    source_column,
                    next_path,
                    best_path
                )
            end
        end
    end

    return best_path
end


local function range_contains_line(range, source_line)
    if type(range) ~= "table" or not source_line then
        return false
    end

    if not range.start_line or not range.end_line then
        return false
    end

    return source_line >= range.start_line
        and source_line <= range.end_line
end


local function get_column_distance_to_range(source_line, source_column, range)
    if type(range) ~= "table" then
        return 999999
    end

    source_column = tonumber(source_column) or 0

    local start_column = tonumber(range.start_column) or 0
    local end_column = tonumber(range.end_column) or start_column

    if range.start_line ~= range.end_line then
        return 0
    end

    if source_column < start_column then
        return start_column - source_column
    end

    if source_column > end_column then
        return source_column - end_column
    end

    return 0
end


local function find_closest_node_path_for_line(
    nodes,
    source_line,
    source_column,
    current_path,
    best
)
    current_path = current_path or {}
    best = best or nil

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local range = get_node_source_range(node)

            if range_contains_line(range, source_line) then
                local next_path = {}

                for _, path_node in ipairs(current_path) do
                    table.insert(next_path, path_node)
                end

                table.insert(next_path, node)

                local distance = get_column_distance_to_range(
                    source_line,
                    source_column,
                    range
                )

                local depth = #next_path

                if not best
                    or distance < best.distance
                    or (
                        distance == best.distance
                        and depth > best.depth
                    )
                then
                    best = {
                        path = next_path,
                        distance = distance,
                        depth = depth,
                    }
                end

                if node_has_children(node) then
                    best = find_closest_node_path_for_line(
                        node.children,
                        source_line,
                        source_column,
                        next_path,
                        best
                    )
                end

            elseif not range and node_has_children(node) then
                -- Range-less presentation/group nodes are transparent to
                -- source matching but remain part of the reveal path.
                local next_path = {}

                for _, path_node in ipairs(current_path) do
                    table.insert(next_path, path_node)
                end

                table.insert(next_path, node)

                best = find_closest_node_path_for_line(
                    node.children,
                    source_line,
                    source_column,
                    next_path,
                    best
                )
            end
        end
    end

    return best
end


local function section_has_cursor_target(nodes, source_line, source_column)
    source_line = tonumber(source_line)
    source_column = tonumber(source_column) or 0

    if not source_line then
        return false
    end

    local node_path = find_deepest_node_path_for_position(
        nodes,
        source_line,
        source_column
    )

    if node_path and #node_path > 0 then
        return true
    end

    local fallback = find_closest_node_path_for_line(
        nodes,
        source_line,
        source_column
    )

    return fallback ~= nil and fallback.path ~= nil
end



local function section_has_exact_cursor_target(
    nodes,
    source_line,
    source_column
)
    source_line = tonumber(source_line)
    source_column = tonumber(source_column) or 0

    if not source_line then
        return false
    end

    local node_path = find_deepest_node_path_for_position(
        nodes,
        source_line,
        source_column
    )

    return node_path ~= nil and #node_path > 0
end


local function classify_section_relevance(
    section_id,
    inspect_mode,
    affected_line,
    exact_symbol
)
    return hud_relevance.classify({
        affected_line = affected_line == true,
        inspect_match = inspect_mode == section_id,
        exact_symbol = exact_symbol == true,
    })
end


local function mark_descendants(
    nodes,
    root_ids,
    result,
    inherited
)
    result = result or {}
    inherited = inherited == true

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local active = inherited
                or (
                    type(root_ids) == "table"
                    and root_ids[node.id] == true
                )

            if active and node.id then
                result[node.id] = true
            end

            if node_has_children(node) then
                mark_descendants(
                    node.children,
                    root_ids,
                    result,
                    active
                )
            end
        end
    end

    return result
end


local function build_scope_member_nodes_for_context(context, use_all_members)
    if type(context) ~= "table" then
        return {}
    end

    local scope_members = context.scope_members or {}

    if use_all_members then
        scope_members = context.all_scope_members or {}
    end

    scope_members = symbol_state.enrich_members(scope_members, context)

    return scope_member_tree.build(scope_members, context)
end


local function get_context_member_scope_range(context)
    if type(context) ~= "table" then
        return nil
    end

    if type(context.member_scope) == "table"
        and context.member_scope.start_line
        and context.member_scope.end_line
    then
        return {
            start_line = context.member_scope.start_line,
            end_line = context.member_scope.end_line,
        }
    end

    return nil
end


local function scope_node_matches_range(node, range)
    return type(node) == "table"
        and type(range) == "table"
        and node.kind == "scope"
        and node.scope_start_line == range.start_line
        and node.scope_end_line == range.end_line
end


local function find_scope_node_by_range(nodes, range)
    for _, node in ipairs(nodes or {}) do
        if scope_node_matches_range(node, range) then
            return node
        end

        local found = find_scope_node_by_range(node.children, range)

        if found then
            return found
        end
    end

    return nil
end
local function find_scope_node_inside_range(nodes, range)
    if type(range) ~= "table" then
        return nil
    end

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" and node.kind == "scope" then
            local start_line = node.scope_start_line

            if start_line
                and range.start_line
                and range.end_line
                and start_line >= range.start_line
                and start_line <= range.end_line
            then
                return node
            end
        end

        local found = find_scope_node_inside_range(node.children, range)

        if found then
            return found
        end
    end

    return nil
end


local function find_scope_node_for_range(nodes, range)
    return find_scope_node_by_range(nodes, range)
        or find_scope_node_inside_range(nodes, range)
end


local function find_deepest_expandable_node_in_path(node_path)
    for index = #(node_path or {}), 1, -1 do
        local node = node_path[index]

        if node_has_children(node) then
            return node, index
        end
    end

    return nil, nil
end


local function reveal_path_and_toggle_best_node(section_id, node_path)
    if not node_path or #node_path == 0 then
        return false, nil
    end

    local section_was_expanded = M.is_expanded(section_id)
    local toggle_node, toggle_index =
        find_deepest_expandable_node_in_path(node_path)

    local target_node = toggle_node or node_path[#node_path]
    local target_node_id = target_node and target_node.id

    -- A source target with no expandable HUD node can still reveal the
    -- section. Make that reveal symmetric too: the same Inspect action can
    -- collapse the section again.
    if not toggle_node then
        M.set_expanded(section_id, not section_was_expanded)
        return true, target_node_id
    end

    -- First press from a collapsed section is always a reveal operation.
    M.set_expanded(section_id, true)

    for index, node in ipairs(node_path) do
        if node_has_children(node) then
            if not section_was_expanded then
                hud_nodes.set_expanded(node.id, true)
            elseif index < toggle_index then
                -- Ancestors stay open so the toggled target remains visible.
                hud_nodes.set_expanded(node.id, true)
            elseif node == toggle_node then
                local currently_expanded = hud_nodes.is_expanded(
                    node.id,
                    get_node_default_expanded(node)
                )

                hud_nodes.set_expanded(node.id, not currently_expanded)
            end
        end
    end

    return true, target_node_id
end

local function toggle_section_fallback(section_id)
    if not validate_section(section_id) then
        return false, nil
    end

    M.set_expanded(section_id, not M.is_expanded(section_id))

    return true, nil
end

local function scope_member_contains_position(
    member,
    source_line,
    source_column
)
    if type(member) ~= "table" then
        return false
    end

    local start_line =
        tonumber(
            member.source_start_line
            or member.line
        )

    local end_line =
        tonumber(
            member.source_end_line
            or member.line
        )

    if not start_line or not end_line then
        return false
    end

    local start_column =
        tonumber(
            member.source_start_column
        ) or 0

    local end_column =
        tonumber(
            member.source_end_column
        ) or start_column

    if source_line < start_line
        or source_line > end_line
    then
        return false
    end

    if start_line == end_line then
        return source_column >= start_column
            and source_column < end_column
    end

    if source_line == start_line then
        return source_column >= start_column
    end

    if source_line == end_line then
        return source_column < end_column
    end

    return true
end


local function get_scope_member_range_span(member)
    if type(member) ~= "table" then
        return math.huge, math.huge
    end

    local start_line =
        tonumber(
            member.source_start_line
            or member.line
        )

    local end_line =
        tonumber(
            member.source_end_line
            or member.line
        )

    if not start_line or not end_line then
        return math.huge, math.huge
    end

    local line_span =
        end_line - start_line

    local column_span = math.huge

    if line_span == 0 then
        local start_column =
            tonumber(
                member.source_start_column
            ) or 0

        local end_column =
            tonumber(
                member.source_end_column
            ) or start_column

        column_span =
            math.max(
                0,
                end_column - start_column
            )
    end

    return line_span, column_span
end


local function find_most_specific_scope_member(
    members,
    source_line,
    source_column
)
    local best_member = nil
    local best_line_span = math.huge
    local best_column_span = math.huge

    for _, member in ipairs(members or {}) do
        if scope_member_contains_position(
            member,
            source_line,
            source_column
        ) then
            local line_span, column_span =
                get_scope_member_range_span(
                    member
                )

            if not best_member
                or line_span < best_line_span
                or (
                    line_span == best_line_span
                    and column_span < best_column_span
                )
            then
                best_member = member
                best_line_span = line_span
                best_column_span = column_span
            end
        end
    end

    return best_member
end


local function find_node_path_by_id(
    nodes,
    wanted_id,
    current_path
)
    if not wanted_id then
        return nil
    end

    current_path = current_path or {}

    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            local next_path = {}

            for _, path_node in ipairs(
                current_path
            ) do
                table.insert(
                    next_path,
                    path_node
                )
            end

            table.insert(
                next_path,
                node
            )

            if node.id == wanted_id then
                return next_path
            end

            if node_has_children(node) then
                local found =
                    find_node_path_by_id(
                        node.children,
                        wanted_id,
                        next_path
                    )

                if found then
                    return found
                end
            end
        end
    end

    return nil
end


local function reveal_and_toggle_scope_member(
    member,
    scope_member_nodes
)
    if type(member) ~= "table"
        or not member.id
    then
        return false, nil
    end

    local node_path =
        find_node_path_by_id(
            scope_member_nodes,
            member.id
        )

    if not node_path
        or #node_path == 0
    then
        return false, nil
    end

    local member_node =
        node_path[#node_path]

    if type(member_node) ~= "table"
        or member_node.kind ~= "member"
    then
        return false, nil
    end

    M.set_expanded(
        "scope_members",
        true
    )

    --
    -- Reveal every parent container first.
    --

    for index = 1, #node_path - 1 do
        local node =
            node_path[index]

        if node_has_children(node) then
            hud_nodes.set_expanded(
                node.id,
                true
            )
        end
    end

    --
    -- Then toggle exactly the member selected from source.
    --

    local currently_expanded =
        hud_nodes.is_expanded(
            member_node.id,
            get_node_default_expanded(
                member_node
            )
        )

    hud_nodes.set_expanded(
        member_node.id,
        not currently_expanded
    )

    return true, member_node.id
end


function M.inspect_scope_members(request)
    if type(request) ~= "table"
        or type(request.context) ~= "table"
    then
        return false
    end

    local source_line =
        tonumber(request.line)

    local source_column =
        tonumber(request.column) or 0

    if not source_line then
        return false
    end

    local context =
        request.context

    local scope_members =
        context.scope_members or {}

    local scope_member_nodes =
        build_scope_member_nodes_for_context(
            context,
            false
        )

    --
    -- FIRST:
    --
    -- Resolve the exact semantic Scope Member directly from the
    -- Scope Members model.
    --
    -- Do not infer member identity from the rendered tree.
    --

    local member =
        find_most_specific_scope_member(
            scope_members,
            source_line,
            source_column
        )

    if member then
        local ok, target_node_id =
            reveal_and_toggle_scope_member(
                member,
                scope_member_nodes
            )

        if ok then
            return true, target_node_id
        end
    end

    --
    -- SECOND:
    --
    -- No concrete Scope Member occupies the cursor position.
    --
    -- Fall back to structural/scope inspection so syntax such as
    -- if / then / end / for can still reveal its owning scope.
    --

    local node_path =
        find_deepest_node_path_for_position(
            scope_member_nodes,
            source_line,
            source_column
        )

    if not node_path
        or #node_path == 0
    then
        local fallback =
            find_closest_node_path_for_line(
                scope_member_nodes,
                source_line,
                source_column
            )

        node_path =
            fallback
            and fallback.path
            or nil
    end

    if not node_path
        or #node_path == 0
    then
        return false
    end

    return reveal_path_and_toggle_best_node(
        "scope_members",
        node_path
    )
end

local function build_register_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    return register_tree.build(context.registers or {}, context)
end


local function build_event_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end
    return event_tree.build(context.events or {}, context)
end


local function build_stack_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    return stack_tree.build(context.stack or {}, context)
end


local function build_heap_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    local heap_root = heap_tree.build_tree(context.heap or {})

    if type(heap_root) ~= "table" then
        return {}
    end

    return heap_root.children or {}
end


local function build_warning_nodes_for_context(context)
    if type(context) ~= "table" then
        return {}
    end

    return warning_tree.build(context.warnings or {}, context)
end


local function inspect_hud_nodes_for_source_position(request, section_id, nodes)
    if type(request) ~= "table" then
        return false
    end

    local source_line = tonumber(request.line)
    local source_column = tonumber(request.column) or 0

    if not source_line then
        return false
    end

    local node_path = find_deepest_node_path_for_position(
        nodes,
        source_line,
        source_column
    )

    if not node_path or #node_path == 0 then
        local fallback = find_closest_node_path_for_line(
            nodes,
            source_line,
            source_column
        )

        node_path = fallback and fallback.path or nil
    end

    return reveal_path_and_toggle_best_node(section_id, node_path)
end


local function get_register_inspect_adapter_signature(adapter)
    if type(adapter) ~= "table" then
        return "<none>"
    end

    local targets = adapter.active_targets or {}

    return table.concat({
        tostring(adapter.name or ""),
        tostring(adapter.active_variant_name or ""),
        tostring(targets.architecture or ""),
        tostring(targets.platform or ""),
        tostring(targets.abi or ""),
        tostring(targets.syntax or ""),
        tostring(targets.mode or ""),
    }, "|")
end


local function get_register_inspect_line(request)
    local bufnr = tonumber(request.bufnr)
    local line_number = tonumber(request.line)

    if not bufnr
        or not line_number
        or not vim.api.nvim_buf_is_valid(bufnr)
    then
        return nil
    end

    local filetype = vim.bo[bufnr].filetype
    local adapter = adapter_registry.get_adapter(filetype)

    if type(adapter) ~= "table"
        or type(adapter.register_effects) ~= "table"
    then
        return nil
    end

    local signature = get_register_inspect_adapter_signature(
        adapter
    )

    local cached = source_index.get_line(
        bufnr,
        "registers",
        line_number
    )

    if type(cached) == "table"
        and cached.adapter_signature == signature
        and source_index.line_is_current(
            bufnr,
            line_number,
            cached
        )
    then
        -- Cursor movement inside an unchanged line should be cheap. Tree-sitter
        -- discovery was already performed when this source-index line was
        -- compiled, so reuse it directly.
        return cached
    end

    if type(cached) == "table"
        and cached.adapter_signature ~= signature
    then
        source_index.invalidate_line(
            bufnr,
            "registers",
            line_number
        )
    end

    local ok, parser = pcall(
        vim.treesitter.get_parser,
        bufnr
    )

    if not ok or not parser then
        return nil
    end

    local tree = parser:parse()[1]
    local root_node = tree and tree:root() or nil

    if not root_node then
        return nil
    end

    local compiled_line = source_index.ensure_line(
        bufnr,
        "registers",
        line_number,
        function()
            local occurrences =
                context_engine.discover_register_source_occurrences(
                    bufnr,
                    root_node,
                    adapter,
                    line_number
                )

            local compiled =
                source_index_compiler.compile_line(
                    occurrences
                )

            compiled.adapter_signature = signature

            return compiled
        end
    )

    return compiled_line
end

local function copy_target_ids(target_ids)
    local result = {}

    for _, target_id in ipairs(target_ids or {}) do
        if type(target_id) == "string"
            and target_id ~= ""
        then
            table.insert(result, target_id)
        end
    end

    return result
end


local function build_register_line_role_overrides(
    _compiled_line,
    _selected_ids
)
    -- Whole-line inspection is a post-statement/state view, not an exact
    -- operand view. Do not reuse operand roles here: if the cursor is on
    -- trailing whitespace after `mov rax, 60`, RAX should present its carried
    -- state role (`written by mov`) instead of the last operand role (`source`).
    -- Returning no overrides lets register_tree fall back to each register
    -- fact's own role.
    return {}
end


local function build_register_occurrence_role_overrides(
    occurrence,
    selected_ids
)
    local roles = {}

    if type(occurrence) ~= "table" then
        return roles
    end

    local target_roles = type(occurrence.metadata) == "table"
        and occurrence.metadata.target_roles
        or nil

    if type(target_roles) == "table" then
        for _, target_id in ipairs(selected_ids or {}) do
            local role = target_roles[target_id]

            if type(role) == "string" and role ~= "" then
                roles[target_id] = role
            end
        end
    end

    -- Operand occurrences carry one role because they address one concrete
    -- source occurrence. Mnemonic/operation occurrences may address several
    -- targets with different roles, so their target-specific map above wins.
    if type(occurrence.role) == "string"
        and occurrence.role ~= ""
    then
        for _, target_id in ipairs(selected_ids or {}) do
            if roles[target_id] == nil then
                roles[target_id] = occurrence.role
            end
        end
    end

    return roles
end


local function collapse_register_detail_nodes(nodes)
    for _, node in ipairs(nodes or {}) do
        if type(node) == "table" then
            if node.kind == "register" and node.id then
                hud_nodes.collapse(node.id)
            end

            collapse_register_detail_nodes(node.children)
        end
    end
end


local function build_register_inspect_key(
    request,
    occurrence,
    target_ids
)
    local parts = {
        tostring(request.bufnr or ""),
        tostring(request.line or ""),
    }

    if type(occurrence) == "table" then
        table.insert(parts, "occurrence")
        table.insert(parts, tostring(occurrence.kind or ""))
        table.insert(parts, tostring(occurrence.start_column or ""))
        table.insert(parts, tostring(occurrence.end_column or ""))
    else
        -- Whole-line inspection is source-position-sensitive. Moving from
        -- leading whitespace to trailing whitespace is a new inspect action,
        -- even though both positions intentionally resolve to the same
        -- post-statement target set.
        table.insert(parts, "line")
        table.insert(parts, tostring(request.column or ""))
    end

    for _, target_id in ipairs(target_ids or {}) do
        table.insert(parts, tostring(target_id))
    end

    return table.concat(parts, "|")
end


local function collect_register_target_paths(
    register_nodes,
    target_ids
)
    local paths = {}
    local target_node_id = nil

    for _, target_id in ipairs(target_ids or {}) do
        local node_path = find_node_path_by_id(
            register_nodes,
            target_id
        )

        if node_path and #node_path > 0 then
            table.insert(paths, node_path)
            target_node_id = target_id
        end
    end

    return paths, target_node_id
end


local function set_register_target_paths_expanded(
    target_paths,
    expanded
)
    for _, node_path in ipairs(target_paths or {}) do
        for index, node in ipairs(node_path) do
            if node_has_children(node) and node.id then
                local is_target = index == #node_path

                if is_target then
                    hud_nodes.set_expanded(
                        node.id,
                        expanded
                    )
                else
                    -- Presentation/group ancestors remain open so a collapsed
                    -- target stays visible and can be toggled back open.
                    hud_nodes.set_expanded(
                        node.id,
                        true
                    )
                end
            end
        end
    end
end


local function register_targets_are_expanded(target_paths)
    local found_expandable_target = false

    for _, node_path in ipairs(target_paths or {}) do
        local target_node = node_path[#node_path]

        if node_has_children(target_node)
            and target_node.id
        then
            found_expandable_target = true

            if not hud_nodes.is_expanded(
                target_node.id,
                get_node_default_expanded(
                    target_node
                )
            )
            then
                return false
            end
        end
    end

    return found_expandable_target
end


local function find_previous_register_occurrence_in_gap(
    compiled_line,
    source_column
)
    if type(compiled_line) ~= "table"
        or type(compiled_line.occurrences) ~= "table"
    then
        return nil
    end

    local previous = nil

    for _, occurrence in ipairs(compiled_line.occurrences) do
        local start_column = tonumber(occurrence.start_column)
        local end_column = tonumber(occurrence.end_column)
        local metadata = type(occurrence.metadata) == "table"
            and occurrence.metadata
            or {}

        local instruction_start = tonumber(
            metadata.instruction_start_column
        )
        local instruction_end = tonumber(
            metadata.instruction_end_column
        )

        if start_column and end_column then
            if source_column < start_column then
                if previous then
                    local previous_metadata =
                        type(previous.metadata) == "table"
                        and previous.metadata
                        or {}

                    local previous_instruction_start = tonumber(
                        previous_metadata.instruction_start_column
                    )
                    local previous_instruction_end = tonumber(
                        previous_metadata.instruction_end_column
                    )

                    if previous_instruction_start
                        and previous_instruction_end
                        and instruction_start
                        and instruction_end
                        and previous_instruction_start
                            == instruction_start
                        and previous_instruction_end
                            == instruction_end
                        and source_column >= previous.end_column
                        and source_column < occurrence.start_column
                    then
                        return previous
                    end
                end

                return nil
            end

            if source_column >= end_column then
                previous = occurrence
            end
        end
    end

    return nil
end


local function resolve_register_cursor_inspection(request)
    if type(request) ~= "table"
        or type(request.context) ~= "table"
    then
        return nil
    end

    local source_column = tonumber(request.column) or 0
    local compiled_line = get_register_inspect_line(
        request
    )

    if type(compiled_line) ~= "table" then
        return nil
    end

    local occurrence = source_index_compiler.find_occurrence(
        compiled_line,
        source_column
    )

    local exact_occurrence = occurrence ~= nil

    if not occurrence then
        -- Punctuation/whitespace BETWEEN semantic occurrences is not a new
        -- semantic state. Keep the most recent occurrence active until the
        -- cursor actually enters the next occurrence. This makes an operand
        -- separator such as the comma in `xor rdi, rdi` inherit the first
        -- RDI's destination semantics instead of jumping ahead to the source.
        occurrence = find_previous_register_occurrence_in_gap(
            compiled_line,
            source_column
        )
    end

    if occurrence then
        local target_ids = copy_target_ids(
            occurrence.targets
                and occurrence.targets.state
                or {}
        )

        -- A concrete token occurrence, or the separator/gap immediately
        -- following it, owns the current cursor semantics. Mnemonics expose
        -- operation effect targets; operands expose their exact occurrence.
        if #target_ids == 0 then
            return nil
        end

        return {
            target_ids = target_ids,
            roles = build_register_occurrence_role_overrides(
                occurrence,
                target_ids
            ),
            occurrence = occurrence,
            exact_occurrence = exact_occurrence,
        }
    end

    -- The cursor is outside the instruction's exact semantic occurrence
    -- span. Whether that should read as a whole-line summary is configurable:
    -- by default, leading whitespace before an instruction does not pre-read
    -- it, while trailing whitespace after an instruction can still show the
    -- post-instruction state.
    if not context_engine.line_summary_allows_compiled_line_position(
        request.config,
        compiled_line,
        source_column
    ) then
        return nil
    end

    local line_targets =
        source_index_compiler.get_line_targets(
            compiled_line
        )

    local target_ids = copy_target_ids(
        line_targets.state or {}
    )

    if #target_ids == 0 then
        return nil
    end

    return {
        target_ids = target_ids,
        roles = build_register_line_role_overrides(
            compiled_line,
            target_ids
        ),
        occurrence = nil,
        exact_occurrence = false,
    }
end


local function apply_register_cursor_inspection(
    context,
    target_ids,
    role_overrides,
    occurrence,
    exact_occurrence
)
    if type(context) ~= "table" then
        return false
    end

    local active_ids = {}

    for _, target_id in ipairs(target_ids or {}) do
        active_ids[target_id] = true
    end

    if next(active_ids) == nil then
        context.register_inspection = nil
        return false
    end

    context.register_inspection = {
        active = true,
        target_ids = active_ids,
        roles = role_overrides or {},
        occurrence = occurrence,
        exact_occurrence = exact_occurrence == true,
    }

    return true
end


function M.update_register_cursor_inspection(request)
    if type(request) ~= "table"
        or type(request.context) ~= "table"
    then
        return false
    end

    request.context.register_inspection = nil

    local resolved = resolve_register_cursor_inspection(
        request
    )

    if not resolved then
        return false
    end

    return apply_register_cursor_inspection(
        request.context,
        resolved.target_ids,
        resolved.roles,
        resolved.occurrence,
        resolved.exact_occurrence
    )
end


local function reveal_register_inspect_targets(
    request,
    target_ids,
    role_overrides,
    occurrence,
    exact_occurrence
)
    local context = request.context

    apply_register_cursor_inspection(
        context,
        target_ids,
        role_overrides,
        occurrence,
        exact_occurrence
    )

    local register_nodes = build_register_nodes_for_context(
        context
    )

    local target_paths, target_node_id =
        collect_register_target_paths(
            register_nodes,
            target_ids
        )

    if #target_paths == 0 then
        context.register_inspection = nil
        return false, nil
    end

    local inspect_key = build_register_inspect_key(
        request,
        occurrence,
        target_ids
    )

    local same_inspect_action =
        inspect_key == last_register_inspect_key

    local section_was_expanded =
        M.is_expanded("registers")

    if same_inspect_action
        and section_was_expanded
        and register_targets_are_expanded(
            target_paths
        )
    then
        -- Same <leader>t action on the same source occurrence: collapse the
        -- exact register targets that action previously revealed.
        set_register_target_paths_expanded(
            target_paths,
            false
        )
    else
        if not same_inspect_action then
            -- A different source occurrence is a new inspection. Hide stale
            -- register details first, then reveal only the new semantic
            -- targets. This is what lets first-RDI (destination) -> second-RDI
            -- (source) stay visibly useful even though both address RDI.
            collapse_register_detail_nodes(
                register_nodes
            )
        end

        M.set_expanded("registers", true)

        set_register_target_paths_expanded(
            target_paths,
            true
        )
    end

    last_register_inspect_key = inspect_key

    return true, target_node_id
end


function M.inspect_registers(request)
    if type(request) ~= "table"
        or type(request.context) ~= "table"
    then
        return false
    end

    request.context.register_inspection = nil

    local resolved = resolve_register_cursor_inspection(
        request
    )

    if not resolved then
        return false
    end

    return reveal_register_inspect_targets(
        request,
        resolved.target_ids,
        resolved.roles,
        resolved.occurrence,
        resolved.exact_occurrence
    )
end

function M.inspect_events(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local event_nodes = build_event_nodes_for_context(request.context)

    if not event_nodes or #event_nodes == 0 then
        return toggle_section_fallback("events")
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "events",
        event_nodes
    )

    if ok then
        return true, target_node_id
    end

    return toggle_section_fallback("events")
end


function M.inspect_stack(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local stack_nodes = build_stack_nodes_for_context(request.context)

    if not stack_nodes or #stack_nodes == 0 then
        return false
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "stack",
        stack_nodes
    )

    if ok then
        return true, target_node_id
    end

    -- Fallback: Stack v1 is mostly static architecture data right now, so it
    -- often has no source-specific node to target yet. Toggle the section itself.
    return toggle_section_fallback("stack")
end


function M.inspect_heap(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local heap_nodes = build_heap_nodes_for_context(request.context)

    if not heap_nodes or #heap_nodes == 0 then
        return toggle_section_fallback("heap")
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "heap",
        heap_nodes
    )

    if ok then
        return true, target_node_id
    end

    return toggle_section_fallback("heap")
end


function M.inspect_warnings(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local warning_nodes = build_warning_nodes_for_context(request.context)

    if not warning_nodes or #warning_nodes == 0 then
        return toggle_section_fallback("warnings")
    end

    local ok, target_node_id = inspect_hud_nodes_for_source_position(
        request,
        "warnings",
        warning_nodes
    )

    if ok then
        return true, target_node_id
    end

    return toggle_section_fallback("warnings")
end


local function get_section_nodes(context, section_id, use_all_members)
    if type(context) ~= "table" then
        return {}
    end

    if section_id == "scope_members" then
        return build_scope_member_nodes_for_context(context, use_all_members == true)
    end

    if section_id == "registers" then
        return build_register_nodes_for_context(context)
    end

    if section_id == "events" then
        return build_event_nodes_for_context(context)
    end

    if section_id == "stack" then
        return build_stack_nodes_for_context(context)
    end

    if section_id == "heap" then
        return build_heap_nodes_for_context(context)
    end

    if section_id == "warnings" then
        return build_warning_nodes_for_context(context)
    end

    return {}
end


function M.expand_section_tree(request, section_id)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local nodes = get_section_nodes(request.context, section_id, true)

    if not nodes or #nodes == 0 then
        return false
    end

    M.set_expanded(section_id, true)

    for _, node in ipairs(nodes) do
        hud_nodes.expand_tree(node)
    end

    return true, nodes[1] and nodes[1].id
end


function M.collapse_section_tree(request, section_id)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local nodes = get_section_nodes(request.context, section_id, true)

    if not nodes or #nodes == 0 then
        return false
    end

    M.set_expanded(section_id, true)

    for _, node in ipairs(nodes) do
        hud_nodes.collapse_tree(node)
    end

    return true, nodes[1] and nodes[1].id
end


function M.expand_scope_members_in_current_scope(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local context = request.context
    local scope_range = get_context_member_scope_range(context)

    if not scope_range then
        return false
    end

    local scope_member_nodes = build_scope_member_nodes_for_context(context, true)
    local target_scope_node = find_scope_node_for_range(scope_member_nodes, scope_range)

    if not target_scope_node then
        return false
    end

    M.set_expanded("scope_members", true)
    hud_nodes.expand_tree(target_scope_node)

    return true, target_scope_node.id
end



function M.collapse_scope_members_in_current_scope(request)
    if type(request) ~= "table" or type(request.context) ~= "table" then
        return false
    end

    local context = request.context
    local scope_range = get_context_member_scope_range(context)

    if not scope_range then
        return false
    end

    local scope_member_nodes = build_scope_member_nodes_for_context(context, true)
    local target_scope_node = find_scope_node_for_range(scope_member_nodes, scope_range)

    if not target_scope_node then
        return false
    end

    M.set_expanded("scope_members", true)
    hud_nodes.collapse_tree(target_scope_node)

    -- Keep the owning scope visible/open so the section does not feel like it vanished.
    hud_nodes.expand(target_scope_node.id)

    return true, target_scope_node.id
end


local function order_sections(sections_by_id, requested_order, scope_members_control)
    local result = {}
    local added = {}

    for _, section_id in ipairs(requested_order or {}) do
        local section = sections_by_id[section_id]

        if section and not added[section_id] then
            -- The Show All Scope Members control belongs to the Scope Members
            -- section workflow, so it moves with Scope Members rather than
            -- occupying a fixed global HUD position.
            if section_id == "scope_members" and scope_members_control then
                table.insert(result, scope_members_control)
            end

            table.insert(result, section)
            added[section_id] = true
        end
    end

    return result
end


function M.build(context, opts)
    if type(context) == "table"
        and type(context.section_layout) == "table"
    then
        M.sync_sections(context.section_layout)
    end

    local show_all_scope_members = hud_controls.is_enabled("show_all_scope_members")
    local scope_members = context.scope_members or {}
    opts = opts or {}
    local active_inspect_mode = opts.inspect_mode
    local active_source_line = context.cursor and context.cursor.line
    local active_source_column = nil
    if context.cursor and context.cursor.column then
        active_source_column = math.max(0, tonumber(context.cursor.column) - 1)
    end

    if show_all_scope_members then
        scope_members = context.all_scope_members or {}
    end

    scope_members = symbol_state.enrich_members(scope_members, context)

    local scope_member_nodes = scope_member_tree.build(scope_members, context)
    local scope_member_affected = section_has_cursor_target(
        scope_member_nodes,
        active_source_line,
        active_source_column
    )
    local scope_member_exact = section_has_exact_cursor_target(
        scope_member_nodes,
        active_source_line,
        active_source_column
    )
    local scope_member_relevance = classify_section_relevance(
        "scope_members",
        active_inspect_mode,
        scope_member_affected,
        scope_member_exact
    )
    local scope_member_render = build_scope_member_tree_lines(scope_member_nodes, {
        panel_width = opts.panel_width,
        config = opts.config,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
        section_id = "scope_members",
        inspect_mode = active_inspect_mode,
        section_relevance = scope_member_relevance,
    })

    local register_nodes = register_tree.build(
        context.registers or {},
        context,
        { config = opts.config }
    )
    local register_inspection = type(context.register_inspection) == "table"
        and context.register_inspection.active == true
        and context.register_inspection
        or nil
    local register_active_ids = register_inspection
        and register_inspection.target_ids
        or nil

    local register_style_by_node_id = {}

    -- Register facts produced by an architectural target_register effect are
    -- implicit/side-effect state even when the user is not actively
    -- inspecting them. Keep that semantic affordance visible in the tree.
    -- Active occurrence inspection below still takes precedence.
    for _, register in ipairs(context.registers or {}) do
        local metadata = type(register) == "table"
            and register.metadata
            or nil

        if type(metadata) == "table"
            and metadata.effect_target_origin == "implicit_register"
            and type(register.id) == "string"
        then
            register_style_by_node_id[register.id] = "implicit"
            register_style_by_node_id[register.id .. ":role"] = "implicit"
        end
    end

    if register_inspection then
        for register_id, active in pairs(register_active_ids or {}) do
            if active == true then
                local role = register_inspection.roles
                    and register_inspection.roles[register_id]
                    or nil
                local style = nil

                if type(role) == "string"
                    and role:lower():match("^destination")
                then
                    style = "destination"
                elseif type(role) == "string"
                    and (
                        role:lower():match("^source")
                        or role:lower():find("from", 1, true)
                    )
                then
                    style = "source"
                elseif register_inspection.exact_occurrence == true then
                    -- An exact operation-level register target without an
                    -- explicit operand role is an implicit architectural
                    -- effect. Whole-line/post-statement inspection intentionally
                    -- falls back to normal register styling instead.
                    style = "implicit"
                end

                if style then
                    register_style_by_node_id[register_id] = style
                    register_style_by_node_id[register_id .. ":role"] = style
                end
            end
        end
    end

    local register_affected = register_inspection ~= nil
        and next(register_active_ids or {}) ~= nil
        or section_has_cursor_target(
            register_nodes,
            active_source_line,
            active_source_column
        )

    local register_exact = register_inspection ~= nil
        and register_inspection.exact_occurrence == true

    local register_relevance = classify_section_relevance(
        "registers",
        active_inspect_mode,
        register_affected,
        register_exact
    )

    local register_focused_ids = {}

    if register_exact then
        register_focused_ids = mark_descendants(
            register_nodes,
            register_active_ids
        )
    end

    local register_render = build_hud_tree_lines(register_nodes, {
        panel_width = opts.panel_width,
        config = opts.config,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
        explicit_active_node_ids = register_active_ids,
        style_by_node_id = register_style_by_node_id,
        section_id = "registers",
        inspect_mode = active_inspect_mode,
        section_relevance = register_relevance,
        focused_node_ids = register_focused_ids,
        focused_node_ids_strict = true,
    })

    local event_nodes = event_tree.build(context.events or {}, context)
    local event_affected = section_has_cursor_target(
        event_nodes,
        active_source_line,
        active_source_column
    )
    local event_exact = section_has_exact_cursor_target(
        event_nodes,
        active_source_line,
        active_source_column
    )
    local event_relevance = classify_section_relevance(
        "events",
        active_inspect_mode,
        event_affected,
        event_exact
    )
    local event_render = build_hud_tree_lines(event_nodes, {
        panel_width = opts.panel_width,
        config = opts.config,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
        section_id = "events",
        inspect_mode = active_inspect_mode,
        section_relevance = event_relevance,
    })


    local stack_nodes = stack_tree.build(context.stack or {}, context)
    local stack_affected = section_has_cursor_target(
        stack_nodes,
        active_source_line,
        active_source_column
    )
    local stack_exact = section_has_exact_cursor_target(
        stack_nodes,
        active_source_line,
        active_source_column
    )
    local stack_relevance = classify_section_relevance(
        "stack",
        active_inspect_mode,
        stack_affected,
        stack_exact
    )
    local stack_render = build_hud_tree_lines(stack_nodes, {
        panel_width = opts.panel_width,
        config = opts.config,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
        section_id = "stack",
        inspect_mode = active_inspect_mode,
        section_relevance = stack_relevance,
    })

    local heap_root = heap_tree.build_tree(context.heap or {})
    local heap_affected = section_has_cursor_target(
        heap_root.children or {},
        active_source_line,
        active_source_column
    )
    local heap_exact = section_has_exact_cursor_target(
        heap_root.children or {},
        active_source_line,
        active_source_column
    )
    local heap_relevance = classify_section_relevance(
        "heap",
        active_inspect_mode,
        heap_affected,
        heap_exact
    )
    local heap_render = build_hud_tree_lines(heap_root.children or {}, {
        panel_width = opts.panel_width,
        config = opts.config,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
        section_id = "heap",
        inspect_mode = active_inspect_mode,
        section_relevance = heap_relevance,
    })

    local warning_nodes = build_warning_nodes_for_context(context)
    local warning_affected = section_has_cursor_target(
        warning_nodes,
        active_source_line,
        active_source_column
    )
    local warning_exact = section_has_exact_cursor_target(
        warning_nodes,
        active_source_line,
        active_source_column
    )
    local warning_relevance = classify_section_relevance(
        "warnings",
        active_inspect_mode,
        warning_affected,
        warning_exact
    )
    local warning_render = build_hud_tree_lines(warning_nodes, {
        panel_width = opts.panel_width,
        config = opts.config,
        active_source_line = active_source_line,
        active_source_column = active_source_column,
        section_id = "warnings",
        inspect_mode = active_inspect_mode,
        section_relevance = warning_relevance,
    })


    local sections_by_id = {
        scope = {
            id = "scope",
            title = "Scope",
            expanded = M.is_expanded("scope"),
            lines = {},
            line_spans = {},
            relevance = (active_inspect_mode == "scope")
                and "current"
                or "contextual",
            empty_text = "<no scope context>",
        },

        scope_members = {
            id = "scope_members",
            title = "Scope Members",
            expanded = M.is_expanded("scope_members"),
            lines = scope_member_render.lines,
            line_spans = scope_member_render.spans,
            active = scope_member_affected,
            relevance = scope_member_relevance,
            line_targets = scope_member_render.targets,
            empty_text = "<no scope members tracked yet>",
        },

        registers = {
            id = "registers",
            title = "Registers",
            expanded = M.is_expanded("registers"),
            active = register_affected,
            relevance = register_relevance,
            lines = register_render.lines,
            line_spans = register_render.spans,
            line_targets = register_render.targets,
            empty_text = "<no registers tracked yet>",
        },

        events = {
            id = "events",
            title = "Events",
            expanded = M.is_expanded("events"),
            active = event_affected,
            relevance = event_relevance,
            lines = event_render.lines,
            line_spans = event_render.spans,
            line_targets = event_render.targets,
            empty_text = "<no events tracked yet>",
        },

        stack = {
            id = "stack",
            title = "Stack",
            expanded = M.is_expanded("stack"),
            active = stack_affected,
            relevance = stack_relevance,
            lines = stack_render.lines,
            line_spans = stack_render.spans,
            line_targets = stack_render.targets,
            empty_text = "<no stack entries tracked yet>",
        },

        heap = {
            id = "heap",
            title = "Heap",
            expanded = M.is_expanded("heap"),
            active = heap_affected,
            relevance = heap_relevance,
            lines = heap_render.lines,
            line_spans = heap_render.spans,
            line_targets = heap_render.targets,
            empty_text = "<no heap entries tracked yet>",
        },

        warnings = {
            id = "warnings",
            title = "Warnings",
            title_style = (#warning_nodes > 0)
                and "warning"
                or "section",
            marker_style = (#warning_nodes > 0)
                and "warning"
                or "section_marker",
            expanded = M.is_expanded("warnings"),
            active = warning_affected,
            relevance = warning_relevance,
            lines = warning_render.lines,
            line_spans = warning_render.spans,
            line_targets = warning_render.targets,
            empty_text = "<no warnings>",
        },
    }

    local scope_members_control = {
        id = "show_all_scope_members",
        kind = "control",
        title = hud_controls.build_title("show_all_scope_members"),
        control_label = "Show All Scope Members",
        control_enabled = hud_controls.is_enabled("show_all_scope_members"),
    }

    local section_order = context.section_layout
        and context.section_layout.order
        or context.section_order
        or {}

    local sections = order_sections(
        sections_by_id,
        section_order,
        scope_members_control
    )

    local scope_section = sections_by_id.scope

    if context.path and #context.path > 0 then
        for index, item in ipairs(context.path) do
            local line = hud_text.new()

            hud_text.append(line, "  ", nil)

            if index > 1 then
                hud_text.append(
                    line,
                    "-> ",
                    "separator"
                )
            end

            hud_text.append(
                line,
                item,
                "scope"
            )

            hud_text.set_relevance(
                line,
                scope_section.relevance
            )

            table.insert(
                scope_section.lines,
                line.text
            )

            scope_section.line_spans[
                #scope_section.lines
            ] = line.spans
        end
    else
        local line = hud_text.new()

        hud_text.append(line, "  ", nil)
        hud_text.append(
            line,
            context.label,
            "scope"
        )

        hud_text.set_relevance(
            line,
            scope_section.relevance
        )

        table.insert(
            scope_section.lines,
            line.text
        )

        scope_section.line_spans[
            #scope_section.lines
        ] = line.spans
    end

    return sections
end

return M


