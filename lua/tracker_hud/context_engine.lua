-- lua/tracker_hud/context_engine.lua
--
-- Shared context engine helpers.
--
-- This module should contain language-neutral behavior only.
-- Language-specific rules belong in adapters.

local core = require("tracker_hud.core")
local ts_utils = require("tracker_hud.treesitter_utils")
local low_level_inference = require("tracker_hud.low_level.inference")
local register_infer = require("tracker_hud.low_level.register_infer")
local stack_infer = require("tracker_hud.low_level.stack_infer")
local boundary_infer = require("tracker_hud.low_level.boundary_infer")

local M = {}

local register_effect_index_cache = setmetatable({}, { __mode = "k" })
local instruction_event_index_cache = setmetatable({}, { __mode = "k" })
local boundary_effect_index_cache = setmetatable({}, { __mode = "k" })
local stack_effect_index_cache = setmetatable({}, { __mode = "k" })


local function get_syntax(spec)
    if not core.is_table(spec)
        or not core.is_table(spec.syntax)
    then
        return {}
    end

    return spec.syntax
end


local function get_syntax_node_type(spec)
    local syntax = get_syntax(spec)

    if core.is_non_empty_string(
        syntax.node_type
    ) then
        return syntax.node_type
    end

    return nil
end


local function get_syntax_field(spec, key)
    local syntax = get_syntax(spec)
    local fields = syntax.fields or {}
    local field_name = fields[key]

    if core.is_non_empty_string(
        field_name
    ) then
        return field_name
    end

    if core.is_table(field_name)
        and core.is_non_empty_string(
            field_name.field
        )
    then
        return field_name.field
    end

    return nil
end



local function get_syntax_field_text(spec, key)
    local syntax = get_syntax(spec)
    local fields = syntax.fields or {}
    local field_spec = fields[key]

    if not core.is_table(field_spec) then
        return nil
    end

    if core.is_non_empty_string(field_spec.text) then
        return field_spec.text
    end

    if core.is_non_empty_string(field_spec.value) then
        return field_spec.value
    end

    return nil
end


local function get_syntax_tokens(spec)
    local syntax = get_syntax(spec)

    if core.is_table(syntax.tokens) then
        return syntax.tokens
    end

    --
    -- Temporary compatibility while bundled adapters are migrated.
    --
    if core.is_table(spec)
        and core.is_table(spec.tokens)
    then
        return spec.tokens
    end

    return nil
end



local function normalize_mnemonic(mnemonic)
    if not core.is_non_empty_string(mnemonic) then
        return nil
    end

    return mnemonic:lower()
end


local function get_register_effect_node_type(effect_spec)
    if not core.is_table(effect_spec) then
        return nil
    end

    return get_syntax_node_type(effect_spec)
        or effect_spec.node_type
end


local function get_register_effect_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(effect_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(effect_spec, "kind")
        or effect_spec.mnemonic
        or fallback_mnemonic
    )
end


local function add_register_effect_to_index(
    index,
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(index)
        or not core.is_table(effect_spec)
    then
        return
    end

    local node_type =
        get_register_effect_node_type(
            effect_spec
        )

    local mnemonic =
        get_register_effect_mnemonic(
            effect_spec,
            fallback_mnemonic
        )

    if not core.is_non_empty_string(node_type)
        or not mnemonic
    then
        return
    end

    index.node_types[node_type] = true
    index.by_node_type[node_type] =
        index.by_node_type[node_type] or {}

    local node_bucket =
        index.by_node_type[node_type]

    node_bucket[mnemonic] =
        node_bucket[mnemonic] or {}

    table.insert(
        node_bucket[mnemonic],
        effect_spec
    )

    node_bucket.__first =
        node_bucket.__first or effect_spec
end


local function build_register_effect_index(register_effects)
    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(register_effects) then
        return index
    end

    -- Current/legacy format:
    --
    -- {
    --     {
    --         node_type = "instruction",
    --         mnemonic = "mov",
    --         ...
    --     },
    -- }
    for _, effect_spec in ipairs(register_effects) do
        add_register_effect_to_index(index, effect_spec)
    end

    -- Tree-sitter-first mnemonic-indexed format:
    --
    -- {
    --     mov = {
    --         {
    --             syntax = {
    --                 node_type = "instruction",
    --                 fields = {
    --                     kind = {
    --                         field = "kind",
    --                         node_type = "word",
    --                         text = "mov",
    --                     },
    --                 },
    --             },
    --             ...
    --         },
    --     },
    -- }
    for mnemonic, rules in pairs(register_effects) do
        if type(mnemonic) == "string" and core.is_table(rules) then
            for _, effect_spec in ipairs(rules) do
                add_register_effect_to_index(index, effect_spec, mnemonic)
            end
        end
    end

    return index
end


local function get_register_effect_index(adapter)
    if not core.is_table(adapter) then
        return build_register_effect_index(nil)
    end

    local register_effects = adapter.register_effects

    if not core.is_table(register_effects) then
        return build_register_effect_index(nil)
    end

    local cached = register_effect_index_cache[register_effects]

    if cached then
        return cached
    end

    local index = build_register_effect_index(register_effects)

    register_effect_index_cache[register_effects] = index

    return index
end


local function parse_instruction_with_adapter(adapter, bufnr, node, effect_spec)
    if type(adapter) ~= "table" or type(adapter.instruction_parser) ~= "table" then
        return nil
    end

    local parser_spec = adapter.instruction_parser
    local module_name = parser_spec.module
    local function_name = parser_spec.function_name or "parse_instruction"

    if type(module_name) ~= "string" or module_name == "" then
        return nil
    end

    local ok, parser_module = pcall(require, module_name)

    if not ok or type(parser_module) ~= "table" then
        return nil
    end

    local parser_fn = parser_module[function_name]

    if type(parser_fn) ~= "function" then
        return nil
    end

    return parser_fn(bufnr, node, effect_spec, adapter)
end

function M.make_global_context()
    return {
        label = "Global Scope",
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        scope_members = {},
        targets = {},
        cursor = M.get_cursor_location(),
    }
end


function M.make_unavailable_context(message, filetype)
    return {
        label = message,
        node_type = nil,
        start_line = nil,
        end_line = nil,
        depth = 0,
        path = {},
        scopes = {},
        scope_members = {},
        cursor = M.get_cursor_location(),
        unavailable = true,
        filetype = filetype,
    }
end


function M.get_first_line_text(node, bufnr)
    local ok, node_text = pcall(vim.treesitter.get_node_text, node, bufnr)

    if not ok or not node_text then
        return nil
    end

    return node_text:match("([^\n]+)")
end


function M.build_signature(node, bufnr, spec)
    if not core.is_table(spec) or not core.is_table(spec.signature) then
        return nil
    end

    if spec.signature.strategy ~= "first_line" then
        return nil
    end

    return M.get_first_line_text(node, bufnr)

end


function M.extract_name_from_signature(signature, spec)
    if type(signature) ~= "string" then
        return nil
    end
    
    if not core.is_table(spec) or not core.is_table(spec.signature) then
        return nil
    end

    local signature_spec = spec.signature

    if type(signature_spec.local_name_pattern) == "string" then
        local name = signature:match(signature_spec.local_name_pattern)

        if name then
            return name
        end
    end

    if type(signature_spec.name_pattern) == "string" then
        return signature:match(signature_spec.name_pattern)
    end

    return nil
end


function M.extract_name_from_syntax(
    node,
    bufnr,
    spec
)
    if not node or not core.is_table(spec) then
        return nil
    end

    local name_field =
        get_syntax_field(
            spec,
            "name"
        )

    if not name_field then
        return nil
    end

    local name_node =
        require("tracker_hud.treesitter_utils")
            .get_child_by_field_name(
                node,
                name_field
            )

    if not name_node then
        return nil
    end

    return require("tracker_hud.treesitter_utils")
        .get_node_text(
            name_node,
            bufnr
        )
end


function M.build_construct(opts)
    opts = opts or {}

    local contract = require("tracker_hud.constructs.contract")

    return contract.new_construct({
        construct = opts.construct,
        scope = opts.scope,
        member = opts.member,
        value = opts.value,

        node_type = opts.node_type,
        name = opts.name,
        signature = opts.signature,
        range = opts.range,
        metadata = opts.metadata or {},
    })
end


function M.get_cursor_position()
    local cursor = vim.api.nvim_win_get_cursor(0)

    return {
        row = cursor[1] - 1,
        col = cursor[2],
    }
end


function M.get_cursor_location()
    local cursor = vim.api.nvim_win_get_cursor(0)

    return {
        line = cursor[1],
        column = cursor[2] + 1, 
    }
end


function M.resolve_line_summary_options(config)
    local line_summary = core.is_table(config)
        and config.line_summary
        or nil

    if not core.is_table(line_summary) then
        line_summary = {}
    end

    local enabled = line_summary.enabled ~= false

    return {
        enabled = enabled,
        show_before_instruction = enabled
            and line_summary.show_before_instruction == true,
        show_after_instruction = enabled
            and line_summary.show_after_instruction ~= false,
    }
end


function M.classify_instruction_cursor_position(
    instruction_start_column,
    instruction_end_column,
    source_column
)
    local start_column = tonumber(instruction_start_column)
    local end_column = tonumber(instruction_end_column)
    local column = tonumber(source_column)

    if not start_column or not end_column or not column then
        return nil
    end

    if column < start_column then
        return "before_instruction"
    end

    if column >= end_column then
        return "after_instruction"
    end

    return "inside_instruction"
end


function M.line_summary_allows_position(config, position)
    if position == "inside_instruction" then
        return true
    end

    local options = M.resolve_line_summary_options(config)

    if options.enabled ~= true then
        return false
    end

    if position == "before_instruction" then
        return options.show_before_instruction == true
    end

    if position == "after_instruction" then
        return options.show_after_instruction == true
    end

    return false
end


local function get_occurrence_instruction_range(occurrence)
    if not core.is_table(occurrence) then
        return nil
    end

    local metadata = core.is_table(occurrence.metadata)
        and occurrence.metadata
        or {}

    local start_column = tonumber(
        metadata.instruction_start_column
        or occurrence.start_column
    )

    local end_column = tonumber(
        metadata.instruction_end_column
        or occurrence.end_column
    )

    if not start_column or not end_column then
        return nil
    end

    return start_column, end_column
end


function M.get_compiled_line_instruction_range(compiled_line)
    if not core.is_table(compiled_line)
        or not core.is_table(compiled_line.occurrences)
    then
        return nil, nil
    end

    local first_start = nil
    local last_end = nil

    for _, occurrence in ipairs(compiled_line.occurrences) do
        local start_column, end_column = get_occurrence_instruction_range(
            occurrence
        )

        if start_column and end_column then
            if not first_start or start_column < first_start then
                first_start = start_column
            end

            if not last_end or end_column > last_end then
                last_end = end_column
            end
        end
    end

    return first_start, last_end
end


function M.classify_compiled_line_cursor_position(
    compiled_line,
    source_column
)
    local start_column, end_column =
        M.get_compiled_line_instruction_range(compiled_line)

    return M.classify_instruction_cursor_position(
        start_column,
        end_column,
        source_column
    )
end


function M.line_summary_allows_compiled_line_position(
    config,
    compiled_line,
    source_column
)
    return M.line_summary_allows_position(
        config,
        M.classify_compiled_line_cursor_position(
            compiled_line,
            source_column
        )
    )
end



function M.format_branch_display_label(start_line, base_label, alternative_label, alternative_line, grouped)
    if grouped then
        return "([" .. start_line .. "] "
            .. base_label
            .. " : "
            .. alternative_label
            .. " ["
            .. alternative_line
            .. "])"
    end
    
    return "[" .. start_line .. "] "
        .. base_label
        .. " : "
        .. alternative_label
        .. " ["
        .. alternative_line
        .. "]"
end



function M.node_matches_branch_alternative(node, spec)
    if not node or not core.is_table(spec) then
        return false
    end

    local branch_spec = spec.branch or {}
    local alternatives = branch_spec.alternatives or {}
    local node_type = node:type()

    for _, alternative_spec in ipairs(alternatives) do
        if core.is_table(alternative_spec) then
            local alternative_node_type =
                get_syntax_node_type(
                    alternative_spec
                )

            if core.is_non_empty_string(
                alternative_node_type
            ) and node_type == alternative_node_type
            then
                return true
            end

            --
            -- Temporary compatibility for pre-syntax adapters.
            --
            if type(alternative_spec.node_match)
                == "string"
                and node_type:match(
                    alternative_spec.node_match
                )
            then
                return true
            end
        end
    end

    return false
end


function M.get_node_alternatives(node, spec)
    local alternatives = {}

    if not node then
        return alternatives
    end

    local alternative_field =
        get_syntax_field(
            spec,
            "alternative"
        )
        or "alternative"

    local ok, field_nodes = pcall(function()
        return node:field(
            alternative_field
        )
    end)

    if ok and field_nodes then
        for _, alternative in ipairs(field_nodes) do
            table.insert(alternatives, alternative)
        end
    end

    for i = 0, node:named_child_count() - 1 do
        local child = node:named_child(i)

        if M.node_matches_branch_alternative(child, spec) then
            table.insert(alternatives, child)
        end
    end

    return alternatives
end


function M.get_branch_alternative_label(alternative_node, spec)
    if not alternative_node or not core.is_table(spec) then
        return nil
    end

    local branch_spec = spec.branch or {}
    local alternatives = branch_spec.alternatives or {}
    local alternative_type = alternative_node:type()

    for _, alternative_spec in ipairs(alternatives) do
        if core.is_table(alternative_spec)
            and type(alternative_spec.label) == "string"
        then
            local alternative_node_type =
                get_syntax_node_type(
                    alternative_spec
                )

            if core.is_non_empty_string(
                alternative_node_type
            ) and alternative_type
                == alternative_node_type
            then
                return alternative_spec.label
            end

            --
            -- Temporary compatibility for pre-syntax adapters.
            --
            if type(alternative_spec.node_match)
                == "string"
                and alternative_type:match(
                    alternative_spec.node_match
                )
            then
                return alternative_spec.label
            end
        end
    end

    return nil
end


function M.build_branch_display_label(node, spec)
    local start_line = M.get_first_node_line(node)
    local construct_spec = spec.construct or {}
    local base_label = construct_spec.label or "Branch"

    if not start_line then
        return base_label
    end

    local cursor = M.get_cursor_position()
    local alternatives = M.get_node_alternatives(node, spec)
    local branch_spec = spec.branch or {}
    local grouped = branch_spec.grouped == true

    for _, alternative in ipairs(alternatives) do
        if M.position_in_node(cursor.row, cursor.col, alternative) then
            local alternative_line = M.get_first_node_line(alternative) or start_line
            local label = M.get_branch_alternative_label(alternative, spec) or "Alternative"

            return M.format_branch_display_label(
                start_line,
                base_label,
                label,
                alternative_line,
                grouped
            )
        end
    end

    return "[" .. start_line .. "] " .. base_label
end


function M.position_in_node(row, col, node)
    if not node then
        return false
    end

    local start_row, start_col, end_row, end_col = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return false
    end

    if row < start_row or row > end_row then
        return false
    end

    if row == start_row and core.is_number(start_col) and col < start_col then
        return false
    end

    if row == end_row and core.is_number(end_col) and col > end_col then
        return false
    end

    return true
end


function M.get_node_type(node)
    if not node then
        return nil
    end

    return node:type()
end



function M.get_first_node_line(node)
    if not node then
        return nil
    end

    local start_row = node:range()


    if not core.is_number(start_row) then
        return nil
    end

    return start_row + 1
end


function M.build_scope_entry_from_construct(construct)
    if not core.is_table(construct) or not core.is_table(construct.range) then
        return nil
    end

    local construct_spec = construct.construct or {}
    local line_number = construct.range.start_line
    local label = construct.signature or construct_spec.label
    local display_label = nil

    if construct.metadata then
        display_label = construct.metadata.display_label
    end

    display_label = display_label or "[" .. line_number .. "] " .. tostring(label or "<unknown>")

    return {
        label = display_label,
        raw_label = label,
        node_type = construct.node_type,
        kind = construct_spec.kind,
        scope = construct.scope,
        value = construct.value,
        start_line = construct.range.start_line,
        end_line = construct.range.end_line,
        construct = construct,
    }
end


function M.build_context_from_scopes(scopes, config)
    local context = M.make_global_context()

    if not core.is_table(scopes) or #scopes == 0 then
        return context
    end

    local path = {}

    -- Scopes are collected innermost -> outermost.
    -- Reverse them so HUD reads outermost -> innermost.
    for i = #scopes, 1, -1 do
        table.insert(path, scopes[i].label)
    end
    
    local innermost = scopes[1]
    local separator = (config and config.separator) or " -> "


    context.label = "Scope: " .. table.concat(path, separator)
    context.node_type = innermost.node_type
    context.start_line = innermost.start_line
    context.end_line = innermost.end_line
    context.depth = #scopes
    context.path = path
    context.scopes = scopes
    context.scope_members = {}

    return context
end


function M.get_node_range(node)
    if not node then
        return nil
    end
    
    local start_row, _, end_row, _ = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return nil
    end
    
    return {
        start_line = start_row + 1,
        end_line = end_row + 1,
    }
end


function M.match_node(adapter, node)
    if not core.is_table(adapter) or not core.is_table(adapter.construct_specs) then
        return false
    end

    local node_type = M.get_node_type(node)

    if not node_type then
        return false
    end

    return adapter.construct_specs[node_type] ~= nil
end



function M.parse_node(adapter, node, bufnr)
    if not core.is_table(adapter) then
        return nil, "adapter must be a table"
    end

    if not core.is_table(adapter.construct_specs) then
        return nil, "adapter.construct_specs must be a table"
    end

    local node_type = M.get_node_type(node)

    local spec, spec_err = M.get_construct_spec(
        adapter.construct_specs,
        node_type
    )

    if not spec then
        return nil, spec_err
    end

    local range = M.get_node_range(node)

    if not range then
        return nil, "could not get node range"
    end

    local construct_spec = spec.construct or {}

    local signature = nil
    local name = nil

    if core.is_table(spec.signature) then
        signature = M.build_signature(
            node,
            bufnr,
            spec
        )
    end

    --
    -- Tree-sitter fields are authoritative for syntax identity.
    -- Text-pattern parsing is only a fallback when the grammar does not
    -- expose the requested field on this construct.
    --
    name = M.extract_name_from_syntax(
        node,
        bufnr,
        spec
    )

    if not name and signature then
        name = M.extract_name_from_signature(
            signature,
            spec
        )
    end

    local label = construct_spec.label
        or "<unknown>"

    local display_label = nil

    if core.is_table(spec.branch) then
        display_label = M.build_branch_display_label(
            node,
            spec
        )

        label = display_label
    end

    local resolved_construct =
        vim.deepcopy(construct_spec)

    resolved_construct.label = label

    return M.build_construct({
        construct = resolved_construct,

        scope = spec.scope,
        member = spec.member,
        value = spec.value,

        node_type = node_type,
        name = name,
        signature = signature,
        range = range,

        metadata = {
            adapter = adapter.name,
            display_label = display_label,
        },
    })
end


function M.get_construct_spec(construct_specs, node_type)
    if not core.is_table(construct_specs) then
        return nil, "construct_specs must be table"
    end

    if type(node_type) ~= "string" or node_type == "" then
        return nil, "node_type must be a non-empty string"
    end

    local spec = construct_specs[node_type]

    if not spec then
        return nil, nil
    end

    local ok, err =
        M.validate_construct_spec(
            spec,
            node_type
        )

    if not ok then
        return nil, err
    end

    return spec, nil

end


function M.validate_construct_spec(
    spec,
    expected_node_type
)
    if not core.is_table(spec) then
        return false, "construct spec must be a table"
    end

    local syntax = get_syntax(spec)

    if spec.syntax ~= nil
        and not core.is_table(spec.syntax)
    then
        return false,
            "construct spec syntax must be a table when provided"
    end

    if core.is_table(spec.syntax) then
        if not core.is_non_empty_string(
            syntax.node_type
        ) then
            return false,
                "construct spec syntax.node_type must be a non-empty Tree-sitter node type"
        end

        if core.is_non_empty_string(
            expected_node_type
        ) and syntax.node_type
            ~= expected_node_type
        then
            return false,
                "construct spec syntax.node_type '"
                .. tostring(syntax.node_type)
                .. "' does not match construct_specs key '"
                .. tostring(expected_node_type)
                .. "'"
        end

        if syntax.fields ~= nil
            and not core.is_table(
                syntax.fields
            )
        then
            return false,
                "construct spec syntax.fields must be a table when provided"
        end

        if syntax.children ~= nil
            and not core.is_table(
                syntax.children
            )
        then
            return false,
                "construct spec syntax.children must be a table when provided"
        end

        if syntax.tokens ~= nil
            and not core.is_table(
                syntax.tokens
            )
        then
            return false,
                "construct spec syntax.tokens must be a table when provided"
        end

        if syntax.exclusions ~= nil
            and not core.is_table(
                syntax.exclusions
            )
        then
            return false,
                "construct spec syntax.exclusions must be a table when provided"
        end
    end

    local contract = require("tracker_hud.constructs.contract")

    local ok, err = contract.validate_construct_spec(spec.construct)

    if not ok then
        return false, err
    end

    ok, err = contract.validate_scope_spec(spec.scope)

    if not ok then
        return false, err
    end

    ok, err = contract.validate_member_spec(spec.member)

    if not ok then
        return false, err
    end

    ok, err = contract.validate_value_spec(spec.value)

    if not ok then
        return false, err
    end

    if spec.markers ~= nil then
        if not core.is_table(spec.markers) then
            return false, "construct spec markers must be a table when provided"
        end

        local required = spec.markers.required or {}
        local optional = spec.markers.optional or {}

        if not core.is_table(required) then
            return false, "construct spec markers.required must be a table"
        end

        if not core.is_table(optional) then
            return false, "construct spec markers.optional must be a table"
        end

        local tokens =
            get_syntax_tokens(spec)

        if tokens == nil then
            return false,
                "construct spec markers require syntax.tokens"
        end

        for _, marker_name in ipairs(required) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "required marker names must be non-empty strings"
            end

            if tokens[marker_name] == nil then
                return false,
                    "required marker '"
                    .. marker_name
                    .. "' is missing from syntax.tokens"
            end
        end

        for _, marker_name in ipairs(optional) do
            if type(marker_name) ~= "string" or marker_name == "" then
                return false, "optional marker names must be non-empty strings"
            end

            if tokens[marker_name] == nil then
                return false,
                    "optional marker '"
                    .. marker_name
                    .. "' is missing from syntax.tokens"
            end
        end

        if spec.markers.total_required ~= nil
            and spec.markers.total_required ~= #required
        then
            return false, "markers.total_required does not match number of required markers"
        end
    end

    return true, nil
end


local function normalize_text(text)
    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("^%s+", ""):gsub("%s+$", "")

    if text == "" then
        return nil
    end

    return text
end


local function node_text(node, bufnr)
    if not node then
        return nil
    end

    return normalize_text(ts_utils.get_node_text(node, bufnr))
end


local function node_has_descendant_type(node, wanted_type)
    if not node or type(wanted_type) ~= "string" then
        return false
    end

    for child in node:iter_children() do
        if child:type() == wanted_type then
            return true
        end

        if node_has_descendant_type(child, wanted_type) then
            return true
        end
    end

    return false
end


local function node_has_ancestor_type_until(node, wanted_type, stop_type)
    if not node or type(wanted_type) ~= "string" then
        return false
    end

    local parent = node:parent()

    while parent do
        if parent:type() == wanted_type then
            return true
        end

        if stop_type and parent:type() == stop_type then
            break
        end

        parent = parent:parent()
    end

    return false
end


local function infer_operand_kind(node, effect_spec)
    if not node then
        return "unknown"
    end

    local node_type = node:type()
    local instruction_node_type = effect_spec.node_type or "instruction"

    if node_type == "int" then
        return "integer"
    end

    if node_type == "reg"
        or node_has_ancestor_type_until(node, "reg", instruction_node_type)
        or node_has_descendant_type(node, "reg")
    then
        return "register"
    end

    if node_type == "ident" or node_type == "word" then
        return "symbol"
    end

    return "unknown"
end


local function build_operand(node, bufnr, effect_spec)
    local text = node_text(node, bufnr)

    if not text then
        return nil
    end

    local start_row, start_column, end_row, end_column = node:range()

    return {
        text = text,
        kind = infer_operand_kind(node, effect_spec),
        node_type = node:type(),

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }
end


local function collect_instruction_operands(adapter, node, bufnr, effect_spec)
    local adapter_instruction = parse_instruction_with_adapter(
        adapter,
        bufnr,
        node,
        effect_spec
    )

    if adapter_instruction then
        return adapter_instruction
    end

    local operands = {}
    local mnemonic = nil
    local mnemonic_seen = false

    for child in node:iter_children() do
        local child_type = child:type()

        if child_type == "word" and not mnemonic_seen then
            mnemonic = node_text(child, bufnr)
            mnemonic_seen = true
        elseif child_type == "reg"
            or child_type == "ident"
            or child_type == "int"
            or child_type == "word"
        then
            local operand = build_operand(child, bufnr, effect_spec)

            if operand then
                table.insert(operands, operand)
            end
        end
    end

    return {
        mnemonic = mnemonic and mnemonic:lower() or nil,
        operands = operands,
        source_line = node:start() + 1,
    }
end


local function collect_nodes_by_type(node, node_type, result)
    result = result or {}

    if not node or type(node_type) ~= "string" or node_type == "" then
        return result
    end

    if node:type() == node_type then
        table.insert(result, node)
    end

    for child in node:iter_children() do
        collect_nodes_by_type(child, node_type, result)
    end

    return result
end


local function normalize_operand_value(value)
    if type(value) ~= "string" then
        return nil
    end

    value = value:lower()
    value = value:gsub("^%s+", "")
    value = value:gsub("%s+$", "")
    value = value:gsub("^%%", "")

    return value
end

local function collect_operand_values(operand)
    local values = {}

    if type(operand) ~= "table" then
        return values
    end

    local candidate_fields = {
        "value",
        "text",
        "name",
        "raw",
        "display",
        "source",
        "register",
    }

    for _, field in ipairs(candidate_fields) do
        local normalized = normalize_operand_value(operand[field])

        if normalized ~= nil and normalized ~= "" then
            values[normalized] = true
        end
    end

    return values
end

local function operand_value_matches(operand, expected_value)
    if expected_value == nil then
        return true
    end

    local operand_values = collect_operand_values(operand)

    if type(expected_value) == "string" then
        local normalized_expected = normalize_operand_value(expected_value)

        if normalized_expected == nil then
            return true
        end

        return operand_values[normalized_expected] == true
    end

    if type(expected_value) == "table" then
        for _, candidate in ipairs(expected_value) do
            local normalized_candidate = normalize_operand_value(candidate)

            if normalized_candidate ~= nil and operand_values[normalized_candidate] == true then
                return true
            end
        end

        return false
    end

    return true
end


local function operand_matches_spec(operand, operand_spec)
    if type(operand) ~= "table" or type(operand_spec) ~= "table" then
        return false
    end

    if not operand_value_matches(operand, operand_spec.value) then
        return false
    end

    if not operand_value_matches(operand, operand_spec.values) then
        return false
    end

    if type(operand_spec.kind) == "string"
        and operand.kind ~= operand_spec.kind
    then
        return false
    end

    return true
end


local function operands_match_effect(instruction, effect_spec)
    if type(instruction) ~= "table" or type(effect_spec) ~= "table" then
        return false
    end

    for _, operand_spec in ipairs(effect_spec.operands or {}) do
        local index = tonumber(operand_spec.index)

        if not index then
            return false
        end

        local operand = instruction.operands and instruction.operands[index]

        if not operand_matches_spec(operand, operand_spec) then
            return false
        end
    end

    return true
end


local function condition_matches(instruction, condition_spec)
    if type(condition_spec) ~= "table" then
        return true
    end

    local operands_equal = condition_spec.operands_equal

    if type(operands_equal) == "table" then
        local left_index = tonumber(operands_equal[1])
        local right_index = tonumber(operands_equal[2])

        if not left_index or not right_index then
            return false
        end

        local left = instruction.operands and instruction.operands[left_index]
        local right = instruction.operands and instruction.operands[right_index]

        if not left or not right then
            return false
        end

        if tostring(left.text or ""):lower() ~= tostring(right.text or ""):lower() then
            return false
        end
    end

    return true
end


local function get_static_register_spec(adapter, name)
    if not core.is_table(adapter) or type(name) ~= "string" then
        return nil
    end

    local normalized = name:lower()

    for _, register_spec in ipairs((adapter.registers and adapter.registers.static) or {}) do
        if type(register_spec) == "table"
            and type(register_spec.name) == "string"
            and register_spec.name:lower() == normalized
        then
            return register_spec
        end
    end

    return nil
end


local function get_register_fact_from_map(facts_by_register, register_name)
    if not core.is_table(facts_by_register)
        or not core.is_non_empty_string(register_name)
    then
        return nil
    end

    return facts_by_register[register_name:lower()]
end



local function parse_numeric_value(value)
    if value == nil then
        return nil
    end

    if type(value) == "number" then
        return value
    end

    if type(value) ~= "string" then
        return nil
    end

    local normalized = value:gsub("^%s+", ""):gsub("%s+$", "")

    if normalized == "" then
        return nil
    end

    local sign = 1

    if normalized:sub(1, 1) == "-" then
        sign = -1
        normalized = normalized:sub(2)
    elseif normalized:sub(1, 1) == "+" then
        normalized = normalized:sub(2)
    end

    local hex = normalized:match("^0[xX]([%da-fA-F]+)$")

    if hex then
        return sign * tonumber(hex, 16)
    end

    local binary = normalized:match("^0[bB]([01]+)$")

    if binary then
        return sign * tonumber(binary, 2)
    end

    local decimal = tonumber(normalized)

    if decimal then
        return sign * decimal
    end

    return nil
end


local function register_fact_is_resolved(fact)
    return core.is_table(fact)
        and fact.value ~= nil
        and fact.resolved ~= false
end


local function get_effect_operand_spec(effect_spec, operand_index)
    if not core.is_table(effect_spec)
        or not core.is_table(effect_spec.operands)
        or not operand_index
    then
        return nil
    end

    for _, operand_spec in ipairs(effect_spec.operands) do
        if tonumber(operand_spec.index) == tonumber(operand_index) then
            return operand_spec
        end
    end

    return nil
end


local function format_operand_role_label(role)
    if not core.is_non_empty_string(role) then
        return nil
    end

    return role:gsub("_", " ")
end


local function get_operand_kind_label(kind)
    if not core.is_non_empty_string(kind) then
        return nil
    end

    if kind == "integer" then
        return "immediate"
    end

    return kind:gsub("_", " ")
end


local function get_source_operand_index(effect)
    if not core.is_table(effect) then
        return nil
    end

    return tonumber(effect.value_operand)
        or tonumber(effect.value_from_register_operand)
        or tonumber(effect.value_delta_operand)
        or tonumber(effect.size_operand)
end


local function build_value_source_label(operand)
    if not core.is_table(operand)
        or not core.is_non_empty_string(operand.text)
    then
        return nil
    end

    local kind_label = get_operand_kind_label(operand.kind)

    if core.is_non_empty_string(kind_label) then
        return kind_label .. " " .. operand.text
    end

    return operand.text
end


local function build_source_operand_metadata(effect_spec, instruction, effect, instruction_state)
    if not core.is_table(instruction)
        or not core.is_table(effect)
    then
        return {}
    end

    local metadata = {}

    if effect.value_from_stack_top == true
        or effect.value_from_stack == "top"
    then
        local stack_value = core.is_table(instruction_state)
            and instruction_state.stack_pop
            or nil

        local source_text = "stack"

        if core.is_table(stack_value) then
            source_text = stack_value.source_text
                or stack_value.source_name
                or stack_value.source
                or source_text
        end

        metadata.source_operand_kind = "stack"
        metadata.source_kind = "stack"
        metadata.source_operand_role = "stack_top"
        metadata.source_role = "stack top"
        metadata.source_operand = source_text
        metadata.source_operand_text = source_text
        metadata.value_source = "stack " .. tostring(source_text)
        metadata.value_source_kind = "stack"
        metadata.value_source_text = source_text

        if core.is_table(stack_value) then
            metadata.stack_value_source_kind = stack_value.source_kind
            metadata.stack_value_source_name = stack_value.source_name
            metadata.stack_value_source_text = stack_value.source_text
            metadata.stack_value_resolved = stack_value.resolved ~= false
        end

        return metadata
    end

    local source_index = get_source_operand_index(effect)
    local source_operand = source_index
        and instruction.operands
        and instruction.operands[source_index]
        or nil

    if core.is_table(source_operand)
        and core.is_non_empty_string(source_operand.text)
    then
        local operand_spec = get_effect_operand_spec(
            effect_spec,
            source_index
        ) or {}

        local kind_label = get_operand_kind_label(source_operand.kind)
        local role_label = format_operand_role_label(operand_spec.role)
        local value_source = build_value_source_label(source_operand)

        metadata.source_operand_index = source_index
        metadata.source_operand = source_operand.text
        metadata.source_operand_text = source_operand.text
        metadata.source_operand_kind = source_operand.kind
        metadata.source_kind = kind_label
        metadata.source_operand_role = operand_spec.role
        metadata.source_role = role_label
        metadata.value_source = value_source
        metadata.value_source_kind = kind_label
        metadata.value_source_text = source_operand.text

        metadata.source_operand_line = source_operand.source_line
        metadata.source_operand_column = source_operand.source_column
        metadata.source_operand_start_line = source_operand.source_start_line
        metadata.source_operand_start_column = source_operand.source_start_column
        metadata.source_operand_end_line = source_operand.source_end_line
        metadata.source_operand_end_column = source_operand.source_end_column

        return metadata
    end

    if effect.value_from_stack_top == true
        or effect.value_from_stack == "top"
    then
        local stack_value = core.is_table(instruction_state)
            and instruction_state.stack_pop
            or nil

        if core.is_table(stack_value) then
            return stack_value.value, stack_value.resolved ~= false
        end

        return nil, false
    end

    if core.is_non_empty_string(effect.value_from_register) then
        metadata.source_operand_kind = "register"
        metadata.source_kind = "register"
        metadata.source_operand_role = "source_register"
        metadata.source_role = "source register"
        metadata.source_operand = effect.value_from_register
        metadata.source_operand_text = effect.value_from_register
        metadata.value_source = "register " .. effect.value_from_register
        metadata.value_source_kind = "register"
        metadata.value_source_text = effect.value_from_register
    end

    return metadata
end


local function merge_source_metadata(target, source)
    if not core.is_table(target) or not core.is_table(source) then
        return target
    end

    for key, value in pairs(source) do
        if value ~= nil then
            target[key] = value
        end
    end

    return target
end


local function prepare_register_instruction_inference_state(
    low_level_state,
    facts_by_register,
    instruction,
    effect_specs
)
    return stack_infer.prepare_instruction_state(
        low_level_state,
        instruction,
        effect_specs,
        {
            resolve_operand_value = function(operand)
                return register_infer.resolve_operand_value(
                    facts_by_register,
                    instruction,
                    operand,
                    {
                        parse_numeric_value = parse_numeric_value,
                    }
                )
            end,
        }
    )
end


local function resolve_register_effect_value(facts_by_register, instruction, effect, instruction_state)
    local value = effect.value
    local resolved = value ~= nil


    if core.is_non_empty_string(effect.value_from_register) then
        local source_fact = get_register_fact_from_map(
            facts_by_register,
            effect.value_from_register
        )

        if register_fact_is_resolved(source_fact) then
            return source_fact.value, true
        end

        return effect.value_from_register, false
    end

    if tonumber(effect.value_from_register_operand) then
        local source_operand = instruction.operands[tonumber(effect.value_from_register_operand)]

        if source_operand and core.is_non_empty_string(source_operand.text) then
            local source_fact = get_register_fact_from_map(
                facts_by_register,
                source_operand.text
            )

            if register_fact_is_resolved(source_fact) then
                return source_fact.value, true
            end

            return source_operand.text, false
        end
    end

    if tonumber(effect.value_delta_operand) or effect.value_delta ~= nil then
        local target_operand = nil
        local target_register = effect.target_register

        if tonumber(effect.target_operand) then
            target_operand = instruction.operands[tonumber(effect.target_operand)]

            if target_operand then
                target_register = target_operand.text
            end
        end

        local target_fact = target_register
            and get_register_fact_from_map(facts_by_register, target_register)

        if not register_fact_is_resolved(target_fact) then
            return nil, false
        end

        local current_number = parse_numeric_value(target_fact.value)

        if not current_number then
            return nil, false
        end

        local delta = effect.value_delta

        if delta == nil and tonumber(effect.value_delta_operand) then
            local delta_operand = instruction.operands[tonumber(effect.value_delta_operand)]

            if delta_operand then
                delta = delta_operand.text
            end
        end

        local delta_number = parse_numeric_value(delta)

        if not delta_number then
            return nil, false
        end

        local sign = tonumber(effect.value_delta_sign) or 1

        return tostring(current_number + (delta_number * sign)), true
    end

    if value == nil and tonumber(effect.value_operand) then
        local value_operand = instruction.operands[tonumber(effect.value_operand)]
            if value_operand then
                value = value_operand.text

                if value_operand.kind == "register" then
                    local source_fact = get_register_fact_from_map(
                        facts_by_register,
                        value_operand.text
                    )

                    resolved = register_fact_is_resolved(source_fact)

                    if resolved then
                        value = source_fact.value
                    end
                elseif value_operand.kind == "integer" then
                    local numeric_value = parse_numeric_value(value_operand.text)

                    if numeric_value ~= nil then
                        value = tostring(numeric_value)
                        resolved = true
                    else
                        resolved = false
                    end
                else
                    resolved = value ~= nil
                end
            end

        end

    return value, resolved
end


local function make_register_fact(facts_by_register, adapter, instruction, effect_spec, instruction_state)

    if not core.is_table(facts_by_register)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
        or not core.is_table(effect_spec.effect)
    then
        return nil
    end

    local effect = effect_spec.effect
    local target_index = tonumber(effect.target_operand)
    local target_operand = nil
    local target_register = effect.target_register

    if target_index then
        target_operand = instruction.operands and instruction.operands[target_index]

        if not core.is_table(target_operand)
            or not core.is_non_empty_string(target_operand.text)
            then
                return nil
            end

        target_register = target_operand.text
    end

    if not core.is_non_empty_string(target_register) then
        return nil
    end

    local value, resolved = resolve_register_effect_value(
        facts_by_register,
        instruction,
        effect,
        instruction_state
    )

    local static_spec = get_static_register_spec(adapter, target_register) or {}
    local metadata = {
        adapter = adapter.name,
        architecture = adapter.architecture,
        variant = adapter.active_variant_name,
        mnemonic = instruction.mnemonic,
        effect = effect.name,

        -- Semantic origin of the effect target. This is deliberately
        -- presentation-neutral: consumers can distinguish an explicitly
        -- named operand write from an architectural/implicit register
        -- effect without reverse-engineering the instruction text.
        effect_target_origin = target_index
            and "operand"
            or "implicit_register",
    }

    merge_source_metadata(
        metadata,
        build_source_operand_metadata(
            effect_spec,
            instruction,
            effect,
            instruction_state
        )
    )

    return {
        name = target_register:lower(),
        kind = static_spec.kind or "unknown",
        value = value,
        resolved = resolved ~= false,
        role = effect.role or static_spec.role,
        source = "instruction",

        source_line = target_operand
            and target_operand.source_line
            or instruction.source_line,

        source_column = target_operand
            and target_operand.source_column
            or instruction.source_column
            or 0,

        source_start_line = target_operand
            and target_operand.source_start_line
            or instruction.source_start_line
            or instruction.source_line,

        source_start_column = target_operand
            and target_operand.source_start_column
            or instruction.source_start_column
            or instruction.source_column
            or 0,

        source_end_line = target_operand
            and target_operand.source_end_line
            or instruction.source_end_line
            or instruction.source_line,

        source_end_column = target_operand
            and target_operand.source_end_column
            or instruction.source_end_column
            or instruction.source_column
            or 0,

        metadata = metadata,
    }

end


local function apply_register_effect(facts_by_register, adapter, instruction, effect_spec, instruction_state)
    if not core.is_table(facts_by_register)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    local expected_mnemonic =
        get_register_effect_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return
    end

    if not operands_match_effect(instruction, effect_spec) then
        return
    end

    if not condition_matches(instruction, effect_spec.condition) then
        return
    end

    local fact = make_register_fact(
        facts_by_register,
        adapter,
        instruction,
        effect_spec,
        instruction_state
    )

    if fact then
        facts_by_register[fact.name] = fact
    end
end


function M.collect_register_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(adapter.register_effects)
    then
        return {}
    end

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local limit_position = low_level_inference.normalize_position(
        opts.limit_position
            or opts.stop_before
            or opts.before_position
    )

    local effect_index = get_register_effect_index(adapter)

    local nodes = {}
    local seen_nodes = {}

    for node_type, _ in pairs(effect_index.node_types) do
        for _, node in ipairs(collect_nodes_by_type(root_node, node_type)) do
            local start_row, start_column, end_row, end_column = node:range()
            local node_line = start_row + 1

            local should_collect = false

            if limit_position then
                should_collect = low_level_inference.position_is_before(
                    {
                        line = node_line,
                        column = start_column,
                    },
                    limit_position
                )
            elseif not cursor_line or node_line < cursor_line then
                should_collect = true
            elseif node_line == cursor_line then
                local cursor_column = context
                    and context.cursor
                    and context.cursor.column

                if core.is_number(cursor_column) then
                    cursor_column = math.max(
                        0,
                        cursor_column - 1
                    )
                end

                local cursor_position =
                    M.classify_instruction_cursor_position(
                        start_column,
                        end_column,
                        cursor_column
                    )

                should_collect =
                    M.line_summary_allows_position(
                        opts.config,
                        cursor_position
                    )
            end

            if should_collect then
                local key = table.concat({
                    node:type(),
                    tostring(start_row),
                    tostring(start_column),
                    tostring(end_row),
                    tostring(end_column),
                }, ":")

                if not seen_nodes[key] then
                    seen_nodes[key] = true

                    table.insert(nodes, {
                        node = node,
                        line = node_line,
                        column = start_column,
                    })
                end
            end
        end
    end

    table.sort(nodes, function(left, right)
        if left.line == right.line then
            return left.column < right.column
        end

        return left.line < right.line
    end)

    local facts_by_register = {}
    local low_level_state = low_level_inference.new_state()

    for _, entry in ipairs(nodes) do
        local node_type = entry.node:type()
        local node_bucket = effect_index.by_node_type[node_type]

        if node_bucket then
            local representative_effect_spec = node_bucket.__first

            local instruction = collect_instruction_operands(
                adapter,
                entry.node,
                bufnr,
                representative_effect_spec
            )

            local mnemonic = instruction
                and normalize_mnemonic(instruction.mnemonic)

            local effect_specs = mnemonic and node_bucket[mnemonic] or nil

            local instruction_state = prepare_register_instruction_inference_state(
                low_level_state,
                facts_by_register,
                instruction,
                effect_specs
            )

            for _, effect_spec in ipairs(effect_specs or {}) do
                apply_register_effect(
                    facts_by_register,
                    adapter,
                    instruction,
                    effect_spec,
                    instruction_state
                )
            end
        end
    end

    return register_infer.to_fact_list(facts_by_register)
end



--
-- Discover source occurrences for explicit Registers inspection.
--
-- Register state remains line-based, while Inspect selection is occurrence-based.
-- This function does not mutate register state and does not render HUD nodes.
-- It describes which presentation register rows are addressed by the exact
-- Tree-sitter mnemonic/operand occurrences on one source line.
--

local function resolve_register_occurrence_name(adapter, register_name)
    if not core.is_non_empty_string(register_name) then
        return nil
    end

    local normalized = register_name:lower()

    for canonical, family in pairs(
        core.is_table(adapter) and adapter.register_families or {}
    ) do
        if core.is_table(family)
            and core.is_table(family.aliases)
            and core.is_table(family.aliases[normalized])
        then
            return tostring(family.canonical or canonical):lower()
        end
    end

    return normalized
end


local function register_occurrence_target_id(adapter, register_name)
    local canonical = resolve_register_occurrence_name(
        adapter,
        register_name
    )

    if not canonical then
        return nil
    end

    return "register:" .. canonical
end


local function normalize_register_occurrence_role(role)
    if not core.is_non_empty_string(role) then
        return nil
    end

    local normalized = role:lower()

    if normalized:match("^destination") then
        return "destination"
    end

    if normalized:match("^source") then
        return "source"
    end

    return role
end


local function add_unique_string(result, seen, value)
    if not core.is_non_empty_string(value)
        or seen[value]
    then
        return
    end

    seen[value] = true
    table.insert(result, value)
end


local function get_register_operand_occurrence_role(
    effect_specs,
    operand_index
)
    for _, effect_spec in ipairs(effect_specs or {}) do
        for _, operand_spec in ipairs(effect_spec.operands or {}) do
            if tonumber(operand_spec.index) == operand_index then
                local role = normalize_register_occurrence_role(
                    operand_spec.role
                )

                if role then
                    return role
                end
            end
        end
    end

    return nil
end


local function get_matching_register_effect_specs(
    effect_index,
    adapter,
    instruction_node,
    bufnr
)
    if not instruction_node then
        return nil, {}
    end

    local node_bucket = effect_index.by_node_type[
        instruction_node:type()
    ]

    if not node_bucket then
        return nil, {}
    end

    local instruction = collect_instruction_operands(
        adapter,
        instruction_node,
        bufnr,
        node_bucket.__first
    )

    if not core.is_table(instruction) then
        return nil, {}
    end

    local mnemonic = normalize_mnemonic(
        instruction.mnemonic
    )

    local candidates = mnemonic
        and node_bucket[mnemonic]
        or nil

    local matching = {}

    for _, effect_spec in ipairs(candidates or {}) do
        if operands_match_effect(instruction, effect_spec)
            and condition_matches(
                instruction,
                effect_spec.condition
            )
        then
            table.insert(matching, effect_spec)
        end
    end

    return instruction, matching
end


local function get_register_effect_target_operand_role(
    effect_spec,
    operand_index
)
    if not core.is_table(effect_spec) then
        return nil
    end

    for _, operand_spec in ipairs(effect_spec.operands or {}) do
        if tonumber(operand_spec.index) == operand_index then
            return normalize_register_occurrence_role(
                operand_spec.role
            )
        end
    end

    return nil
end


local function build_register_mnemonic_occurrence(
    adapter,
    instruction,
    effect_specs
)
    if not core.is_table(instruction)
        or not core.is_table(instruction.mnemonic_range)
    then
        return nil
    end

    local target_ids = {}
    local seen_target_ids = {}
    local target_roles = {}

    -- The mnemonic represents the operation itself. Inspecting it therefore
    -- addresses every register STATE TARGET affected by the matching semantic
    -- effects: explicit destination operands plus implicit architectural
    -- targets such as RFLAGS. Source-only operands remain operand occurrences
    -- and are not promoted to operation targets.
    for _, effect_spec in ipairs(effect_specs or {}) do
        local effect = effect_spec.effect

        if core.is_table(effect) then
            if core.is_non_empty_string(effect.target_register) then
                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    register_occurrence_target_id(
                        adapter,
                        effect.target_register
                    )
                )
            end

            local target_operand = tonumber(
                effect.target_operand
            )

            local operand = target_operand
                and instruction.operands
                and instruction.operands[target_operand]
                or nil

            if core.is_table(operand)
                and operand.kind == "register"
            then
                local target_id =
                    register_occurrence_target_id(
                        adapter,
                        operand.text
                    )

                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    target_id
                )

                local role =
                    get_register_effect_target_operand_role(
                        effect_spec,
                        target_operand
                    )

                if target_id and role then
                    target_roles[target_id] = role
                end
            end
        end
    end

    local range = instruction.mnemonic_range

    return {
        kind = "mnemonic",
        text = instruction.mnemonic,
        start_column = range.source_start_column,
        end_column = range.source_end_column,
        targets = {
            state = target_ids,
        },
        metadata = {
            mnemonic = instruction.mnemonic,
            inspection_kind = "operation",
            target_roles = target_roles,
            instruction_start_column =
                instruction.source_start_column,
            instruction_end_column =
                instruction.source_end_column,
        },
    }
end


local function operand_role_is_source(role)
    if not core.is_non_empty_string(role) then
        return false
    end

    return role:lower():match("^source") ~= nil
end


local function operand_role_is_destination(role)
    if not core.is_non_empty_string(role) then
        return false
    end

    return role:lower():match("^destination") ~= nil
end


local function add_effect_target_register_ids(
    target_ids,
    seen_target_ids,
    adapter,
    instruction,
    effect_spec
)
    if not core.is_table(target_ids)
        or not core.is_table(seen_target_ids)
        or not core.is_table(effect_spec)
        or not core.is_table(effect_spec.effect)
    then
        return
    end

    local effect = effect_spec.effect

    if core.is_non_empty_string(effect.target_register) then
        add_unique_string(
            target_ids,
            seen_target_ids,
            register_occurrence_target_id(
                adapter,
                effect.target_register
            )
        )
    end

    local target_operand_index = tonumber(effect.target_operand)
    local target_operand = target_operand_index
        and instruction
        and instruction.operands
        and instruction.operands[target_operand_index]
        or nil

    if core.is_table(target_operand)
        and target_operand.kind == "register"
    then
        add_unique_string(
            target_ids,
            seen_target_ids,
            register_occurrence_target_id(
                adapter,
                target_operand.text
            )
        )
    end
end


local function get_effect_target_register_ids(
    adapter,
    instruction,
    effect_spec
)
    local target_ids = {}
    local seen_target_ids = {}

    add_effect_target_register_ids(
        target_ids,
        seen_target_ids,
        adapter,
        instruction,
        effect_spec
    )

    return target_ids
end


local function build_source_written_role(instruction, operand)
    local kind_label = get_operand_kind_label(
        core.is_table(operand) and operand.kind or nil
    ) or "source"

    local mnemonic = instruction and instruction.mnemonic or nil

    if kind_label == "memory" then
        return "loaded from memory"
            .. (mnemonic and " by " .. mnemonic or "")
    end

    return "written from "
        .. kind_label
        .. (mnemonic and " by " .. mnemonic or "")
end


local function build_operand_occurrence_metadata(
    adapter,
    instruction,
    operand,
    operand_index,
    operand_role,
    target_roles
)
    local metadata = {
        instruction_start_column = instruction
            and instruction.source_start_column
            or nil,
        instruction_end_column = instruction
            and instruction.source_end_column
            or nil,
        target_roles = target_roles,
    }

    if core.is_table(operand) then
        metadata.operand_kind = operand.kind
        metadata.operand_kind_label = get_operand_kind_label(operand.kind)
        metadata.operand_role = operand_role
        metadata.operand_role_label = format_operand_role_label(operand_role)
        metadata.operand_index = operand_index
    end

    if core.is_table(operand)
        and core.is_non_empty_string(operand.text)
    then
        metadata.source_operand_index = operand_index
        metadata.source_operand = operand.text
        metadata.source_operand_text = operand.text
        metadata.source_operand_kind = operand.kind
        metadata.source_kind = get_operand_kind_label(operand.kind)
        metadata.source_operand_role = operand_role
        metadata.source_role = format_operand_role_label(operand_role)
        metadata.value_source = build_value_source_label(operand)
        metadata.value_source_kind = get_operand_kind_label(operand.kind)
        metadata.value_source_text = operand.text
    end

    if core.is_table(operand)
        and operand.kind == "register"
    then
        metadata.register_name = resolve_register_occurrence_name(
            adapter,
            operand.text
        )
        metadata.written_name = operand.text
    end

    return metadata
end


local function build_register_operand_occurrence(
    adapter,
    instruction,
    operand,
    operand_index,
    effect_specs
)
    if not core.is_table(operand)
        or not core.is_non_empty_string(operand.text)
    then
        return nil
    end

    local target_ids = {}
    local seen_target_ids = {}
    local target_roles = {}
    local own_register_id = nil
    local occurrence_role = nil
    local operand_role = nil

    if operand.kind == "register" then
        own_register_id = register_occurrence_target_id(
            adapter,
            operand.text
        )

        add_unique_string(
            target_ids,
            seen_target_ids,
            own_register_id
        )
    end

    for _, effect_spec in ipairs(effect_specs or {}) do
        local operand_spec = get_effect_operand_spec(
            effect_spec,
            operand_index
        )

        local raw_role = core.is_table(operand_spec)
            and operand_spec.role
            or nil

        local normalized_role = normalize_register_occurrence_role(
            raw_role
        )

        if normalized_role then
            operand_role = operand_role or raw_role or normalized_role
            occurrence_role = occurrence_role or normalized_role
        end

        if own_register_id and normalized_role then
            target_roles[own_register_id] = normalized_role
        end

        if operand_role_is_source(raw_role or normalized_role) then
            for _, target_id in ipairs(
                get_effect_target_register_ids(
                    adapter,
                    instruction,
                    effect_spec
                )
            ) do
                add_unique_string(
                    target_ids,
                    seen_target_ids,
                    target_id
                )

                -- Exact operand inspection should teach syntactic roles, not
                -- post-instruction state. When the cursor is on operand 2 in
                -- `mov rax, 60`, the selected thing is a source operand even
                -- though the revealed register state target is RAX. The
                -- carried/post-line state still comes from the register fact's
                -- own role, such as "written by mov".
                target_roles[target_id] = "source"
            end
        elseif operand_role_is_destination(raw_role or normalized_role) then
            for _, target_id in ipairs(
                get_effect_target_register_ids(
                    adapter,
                    instruction,
                    effect_spec
                )
            ) do
                if target_id == own_register_id then
                    target_roles[target_id] = "destination"
                end
            end
        end
    end

    if #target_ids == 0 then
        return nil
    end

    return {
        kind = "operand",
        text = operand.text,
        start_column = operand.source_start_column,
        end_column = operand.source_end_column,
        operand_index = operand_index,
        role = occurrence_role,
        targets = {
            state = target_ids,
        },
        metadata = build_operand_occurrence_metadata(
            adapter,
            instruction,
            operand,
            operand_index,
            operand_role,
            target_roles
        ),
    }
end


function M.discover_register_source_occurrences(
    bufnr,
    root_node,
    adapter,
    line_number
)
    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(adapter.register_effects)
        or not core.is_number(line_number)
    then
        return {}
    end

    local effect_index = get_register_effect_index(adapter)
    local occurrences = {}
    local seen_nodes = {}

    for node_type, _ in pairs(effect_index.node_types) do
        for _, node in ipairs(
            collect_nodes_by_type(root_node, node_type)
        ) do
            local start_row,
                start_column,
                end_row,
                end_column = node:range()

            if start_row + 1 == line_number then
                local node_key = table.concat({
                    node:type(),
                    tostring(start_row),
                    tostring(start_column),
                    tostring(end_row),
                    tostring(end_column),
                }, ":")

                if not seen_nodes[node_key] then
                    seen_nodes[node_key] = true

                    local instruction, matching_specs =
                        get_matching_register_effect_specs(
                            effect_index,
                            adapter,
                            node,
                            bufnr
                        )

                    if instruction and #matching_specs > 0 then
                        local mnemonic_occurrence =
                            build_register_mnemonic_occurrence(
                                adapter,
                                instruction,
                                matching_specs
                            )

                        if mnemonic_occurrence then
                            table.insert(
                                occurrences,
                                mnemonic_occurrence
                            )
                        end

                        for operand_index, operand in ipairs(
                            instruction.operands or {}
                        ) do
                            local operand_occurrence =
                                build_register_operand_occurrence(
                                    adapter,
                                    instruction,
                                    operand,
                                    operand_index,
                                    matching_specs
                                )

                            if operand_occurrence then
                                table.insert(
                                    occurrences,
                                    operand_occurrence
                                )
                            end
                        end
                    end
                end
            end
        end
    end

    return occurrences
end


local function get_boundary_effect_node_type(effect_spec)
    if not core.is_table(effect_spec) then
        return nil
    end

    return get_syntax_node_type(effect_spec)
        or effect_spec.node_type
end


local function get_boundary_effect_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(effect_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(effect_spec, "kind")
        or effect_spec.mnemonic
        or fallback_mnemonic
    )
end


local function add_boundary_effect_to_index(
    index,
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(index)
        or not core.is_table(effect_spec)
    then
        return
    end

    local node_type =
        get_boundary_effect_node_type(
            effect_spec
        )

    local mnemonic =
        get_boundary_effect_mnemonic(
            effect_spec,
            fallback_mnemonic
        )

    if not core.is_non_empty_string(node_type)
        or not mnemonic
    then
        return
    end

    index.node_types[node_type] = true
    index.by_node_type[node_type] =
        index.by_node_type[node_type] or {}

    local node_bucket =
        index.by_node_type[node_type]

    node_bucket[mnemonic] =
        node_bucket[mnemonic] or {}

    table.insert(
        node_bucket[mnemonic],
        effect_spec
    )

    node_bucket.__first =
        node_bucket.__first or effect_spec
end


local function build_boundary_effect_index(boundary_effects)
    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(boundary_effects) then
        return index
    end

    -- Temporary compatibility with old flat adapter data.
    for _, effect_spec in ipairs(boundary_effects) do
        add_boundary_effect_to_index(
            index,
            effect_spec
        )
    end

    -- Tree-sitter-first mnemonic-indexed adapter data.
    for mnemonic, effect_specs in pairs(
        boundary_effects
    ) do
        if type(mnemonic) == "string"
            and core.is_table(effect_specs)
        then
            for _, effect_spec in ipairs(
                effect_specs
            ) do
                add_boundary_effect_to_index(
                    index,
                    effect_spec,
                    mnemonic
                )
            end
        end
    end

    return index
end


local function get_boundary_effect_index(adapter)
    if not core.is_table(adapter) then
        return build_boundary_effect_index(nil)
    end

    local boundary_effects =
        adapter.boundary_effects

    if not core.is_table(boundary_effects) then
        return build_boundary_effect_index(nil)
    end

    local cached =
        boundary_effect_index_cache[
            boundary_effects
        ]

    if cached then
        return cached
    end

    local index =
        build_boundary_effect_index(
            boundary_effects
        )

    boundary_effect_index_cache[
        boundary_effects
    ] = index

    return index
end


-- Boundary read/write/not-preserved inference lives in
-- tracker_hud.low_level.boundary_infer. Context engine keeps only syntax/node
-- selection and adapter matching concerns here.


local function boundary_instruction_matches(instruction, effect_spec)
    if not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return false
    end

    local expected_mnemonic =
        get_boundary_effect_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return false
    end

    return true
end


local function make_boundary_effect_fact(
    context,
    adapter,
    instruction,
    effect_spec,
    phase_contexts
)
    return boundary_infer.make_effect_fact(
        context,
        adapter,
        instruction,
        effect_spec,
        phase_contexts
    )
end


local function collect_registers_before_instruction(
    context,
    adapter,
    opts,
    instruction
)
    if not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(opts)
        or not core.is_table(instruction)
    then
        return context
    end

    local limit_position = low_level_inference.normalize_position({
        line = instruction.source_start_line
            or instruction.source_line,
        column = instruction.source_start_column
            or instruction.source_column
            or 0,
    })

    if not limit_position then
        return context
    end

    local registers_before = M.collect_register_effects(
        context,
        adapter,
        {
            bufnr = opts.bufnr,
            root_node = opts.root_node,
            limit_position = limit_position,
        }
    )

    return low_level_inference.with_section_facts(
        context,
        "registers",
        registers_before
    )
end


local function apply_boundary_effect(
    facts,
    context,
    adapter,
    instruction,
    effect_spec,
    phase_contexts
)
    if not core.is_table(facts)
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    if not boundary_instruction_matches(instruction, effect_spec) then
        return
    end

    local fact = make_boundary_effect_fact(
        context,
        adapter,
        instruction,
        effect_spec,
        phase_contexts
    )

    if fact then
        table.insert(facts, fact)
    end
end


function M.collect_boundary_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(
            adapter.boundary_effects
        )
    then
        return {}
    end

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local effect_index =
        get_boundary_effect_index(adapter)

    local nodes = {}
    local seen_nodes = {}

    for node_type, _ in pairs(
        effect_index.node_types
    ) do
        for _, node in ipairs(
            collect_nodes_by_type(
                root_node,
                node_type
            )
        ) do
            local start_row,
                start_column,
                end_row,
                end_column = node:range()

            local node_line = start_row + 1

            if not cursor_line
                or node_line <= cursor_line
            then
                local key = table.concat({
                    node:type(),
                    tostring(start_row),
                    tostring(start_column),
                    tostring(end_row),
                    tostring(end_column),
                }, ":")

                if not seen_nodes[key] then
                    seen_nodes[key] = true

                    table.insert(nodes, {
                        node = node,
                        line = node_line,
                        column = start_column,
                    })
                end
            end
        end
    end

    table.sort(nodes, function(left, right)
        if left.line == right.line then
            return left.column < right.column
        end

        return left.line < right.line
    end)

    local facts = {}
    local low_level_state = low_level_inference.new_state()

    for _, entry in ipairs(nodes) do
        local node_type = entry.node:type()
        local node_bucket =
            effect_index.by_node_type[
                node_type
            ]

        if node_bucket then
            local representative_effect_spec =
                node_bucket.__first

            local instruction =
                collect_instruction_operands(
                    adapter,
                    entry.node,
                    bufnr,
                    representative_effect_spec
                )

            local mnemonic = instruction
                and normalize_mnemonic(
                    instruction.mnemonic
                )

            local effect_specs = mnemonic
                and node_bucket[mnemonic]
                or nil

            local read_context = collect_registers_before_instruction(
                context,
                adapter,
                opts,
                instruction
            )

            for _, effect_spec in ipairs(
                effect_specs or {}
            ) do
                apply_boundary_effect(
                    facts,
                    context,
                    adapter,
                    instruction,
                    effect_spec,
                    {
                        read_context = read_context,
                        write_context = context,
                    }
                )
            end
        end
    end

    return facts
end


local function get_instruction_event_node_type(event_spec)
    if not core.is_table(event_spec) then
        return nil
    end

    return get_syntax_node_type(event_spec)
        or event_spec.node_type
end


local function get_instruction_event_mnemonic(
    event_spec,
    fallback_mnemonic
)
    if not core.is_table(event_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(event_spec, "kind")
        or event_spec.mnemonic
        or fallback_mnemonic
    )
end


local function add_instruction_event_to_index(
    index,
    event_spec,
    fallback_mnemonic
)
    if not core.is_table(index)
        or not core.is_table(event_spec)
    then
        return
    end

    local node_type =
        get_instruction_event_node_type(
            event_spec
        )

    local mnemonic =
        get_instruction_event_mnemonic(
            event_spec,
            fallback_mnemonic
        )

    if not core.is_non_empty_string(node_type)
        or not mnemonic
    then
        return
    end

    index.node_types[node_type] = true
    index.by_node_type[node_type] =
        index.by_node_type[node_type] or {}

    local node_bucket =
        index.by_node_type[node_type]

    node_bucket[mnemonic] =
        node_bucket[mnemonic] or {}

    table.insert(
        node_bucket[mnemonic],
        event_spec
    )

    node_bucket.__first =
        node_bucket.__first or event_spec
end


local function build_instruction_event_index(
    instruction_events
)
    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(instruction_events) then
        return index
    end

    -- Remaining legacy flat event specs.
    for _, event_spec in ipairs(
        instruction_events
    ) do
        add_instruction_event_to_index(
            index,
            event_spec
        )
    end

    -- Tree-sitter-first mnemonic-indexed event specs.
    for mnemonic, rules in pairs(
        instruction_events
    ) do
        if type(mnemonic) == "string"
            and core.is_table(rules)
        then
            for _, event_spec in ipairs(rules) do
                add_instruction_event_to_index(
                    index,
                    event_spec,
                    mnemonic
                )
            end
        end
    end

    return index
end


local function get_instruction_event_index(adapter)
    if not core.is_table(adapter) then
        return build_instruction_event_index(nil)
    end

    local instruction_events =
        adapter.instruction_events

    if not core.is_table(instruction_events) then
        return build_instruction_event_index(nil)
    end

    local cached =
        instruction_event_index_cache[
            instruction_events
        ]

    if cached then
        return cached
    end

    local index =
        build_instruction_event_index(
            instruction_events
        )

    instruction_event_index_cache[
        instruction_events
    ] = index

    return index
end


local function instruction_event_matches(
    instruction,
    event_spec
)
    if not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return false
    end

    local expected_mnemonic =
        get_instruction_event_mnemonic(
            event_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return false
    end

    return true
end


local function make_instruction_event_fact(adapter, instruction, event_spec)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return nil
    end

    return {
        kind = event_spec.kind or "instruction_event",
        category = event_spec.category or "instruction",
        name = event_spec.name
            or get_instruction_event_mnemonic(event_spec)
            or "instruction_event",
        role = event_spec.role,

        source = "instruction",
        source_line = instruction.source_line,
        source_column = instruction.source_column or 0,

        source_start_line = instruction.source_line,
        source_start_column = instruction.source_column or 0,
        source_end_line = instruction.source_line,
        source_end_column = instruction.source_end_column or instruction.source_column or 0,

        metadata = {
            adapter = adapter.name,
            architecture = adapter.architecture,
            variant = adapter.active_variant_name,
            mnemonic = instruction.mnemonic,
            event = event_spec.name
                or get_instruction_event_mnemonic(event_spec),
        },
    }
end


local function apply_instruction_event(facts, adapter, instruction, event_spec)
    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(event_spec)
    then
        return
    end

    if not instruction_event_matches(instruction, event_spec) then
        return
    end

    local fact = make_instruction_event_fact(adapter, instruction, event_spec)

    if fact then
        table.insert(facts, fact)
    end
end


function M.collect_instruction_events(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(context)
        or not core.is_table(adapter)
        or not core.is_table(adapter.instruction_events)
    then
        return {}
    end

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local event_index =
        get_instruction_event_index(adapter)

    local nodes = {}
    local seen_nodes = {}

    -- Discover each relevant Tree-sitter node once per node type.
    for node_type, _ in pairs(
        event_index.node_types
    ) do
        for _, node in ipairs(
            collect_nodes_by_type(
                root_node,
                node_type
            )
        ) do
            local start_row,
                start_column,
                end_row,
                end_column = node:range()

            local node_line = start_row + 1

            if not cursor_line
                or node_line <= cursor_line
            then
                local key = table.concat({
                    node:type(),
                    tostring(start_row),
                    tostring(start_column),
                    tostring(end_row),
                    tostring(end_column),
                }, ":")

                if not seen_nodes[key] then
                    seen_nodes[key] = true

                    table.insert(nodes, {
                        node = node,
                        line = node_line,
                        column = start_column,
                    })
                end
            end
        end
    end

    table.sort(nodes, function(left, right)
        if left.line == right.line then
            return left.column < right.column
        end

        return left.line < right.line
    end)

    local facts = {}

    for _, entry in ipairs(nodes) do
        local node_type = entry.node:type()
        local node_bucket =
            event_index.by_node_type[node_type]

        if node_bucket then
            local representative_event_spec =
                node_bucket.__first

            local instruction =
                collect_instruction_operands(
                    adapter,
                    entry.node,
                    bufnr,
                    representative_event_spec
                )

            local mnemonic = instruction
                and normalize_mnemonic(
                    instruction.mnemonic
                )

            local event_specs = mnemonic
                and node_bucket[mnemonic]
                or nil

            for _, event_spec in ipairs(
                event_specs or {}
            ) do
                apply_instruction_event(
                    facts,
                    adapter,
                    instruction,
                    event_spec
                )
            end
        end
    end

    table.sort(facts, function(left, right)
        local left_line = left.source_line
        local right_line = right.source_line

        if left_line and right_line then
            if left_line == right_line then
                return tostring(left.name or "")
                    < tostring(right.name or "")
            end

            return left_line < right_line
        end

        if left_line then
            return true
        end

        if right_line then
            return false
        end

        return tostring(left.name or "")
            < tostring(right.name or "")
    end)

    return facts
end



local function get_stack_effect_node_type(effect_spec)
    if not core.is_table(effect_spec) then
        return nil
    end

    return get_syntax_node_type(effect_spec)
        or effect_spec.node_type
end


local function get_stack_effect_mnemonic(
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(effect_spec) then
        return normalize_mnemonic(fallback_mnemonic)
    end

    return normalize_mnemonic(
        get_syntax_field_text(effect_spec, "kind")
        or effect_spec.mnemonic
        or fallback_mnemonic
    )
end


local function add_stack_effect_to_index(
    index,
    effect_spec,
    fallback_mnemonic
)
    if not core.is_table(index)
        or not core.is_table(effect_spec)
    then
        return
    end

    local node_type =
        get_stack_effect_node_type(
            effect_spec
        )

    local mnemonic =
        get_stack_effect_mnemonic(
            effect_spec,
            fallback_mnemonic
        )

    if not core.is_non_empty_string(node_type)
        or not mnemonic
    then
        return
    end

    index.node_types[node_type] = true
    index.by_node_type[node_type] =
        index.by_node_type[node_type] or {}

    local node_bucket =
        index.by_node_type[node_type]

    node_bucket[mnemonic] =
        node_bucket[mnemonic] or {}

    table.insert(
        node_bucket[mnemonic],
        effect_spec
    )

    node_bucket.__first =
        node_bucket.__first or effect_spec
end


local function build_stack_effect_index(stack_effects)
    local index = {
        node_types = {},
        by_node_type = {},
    }

    if not core.is_table(stack_effects) then
        return index
    end

    -- Temporary compatibility with old flat adapter data.
    for _, effect_spec in ipairs(stack_effects) do
        add_stack_effect_to_index(
            index,
            effect_spec
        )
    end

    -- Tree-sitter-first mnemonic-indexed adapter data.
    for mnemonic, effect_specs in pairs(
        stack_effects
    ) do
        if type(mnemonic) == "string"
            and core.is_table(effect_specs)
        then
            for _, effect_spec in ipairs(
                effect_specs
            ) do
                add_stack_effect_to_index(
                    index,
                    effect_spec,
                    mnemonic
                )
            end
        end
    end

    return index
end


local function get_stack_effect_index(adapter)
    if not core.is_table(adapter) then
        return build_stack_effect_index(nil)
    end

    local stack_effects =
        adapter.stack_effects

    if not core.is_table(stack_effects) then
        return build_stack_effect_index(nil)
    end

    local cached =
        stack_effect_index_cache[
            stack_effects
        ]

    if cached then
        return cached
    end

    local index =
        build_stack_effect_index(
            stack_effects
        )

    stack_effect_index_cache[
        stack_effects
    ] = index

    return index
end


local function stack_operand_value_matches(operand, operand_spec)
    if type(operand_spec.value) ~= "string" then
        return true
    end

    if not core.is_table(operand) or not core.is_non_empty_string(operand.text) then
        return false
    end

    return operand.text:lower() == operand_spec.value:lower()
end

local function stack_operand_matches_spec(adapter, operand, operand_spec)
    if not core.is_table(operand) or not core.is_table(operand_spec) then
        return false
    end

    if type(operand_spec.kind) == "string"
        and operand.kind ~= operand_spec.kind
    then
        -- ASM registers can sometimes appear as symbol-like words depending
        -- on the exact instruction shape. Treat known architecture registers
        -- as registers for stack-effect matching.
        if operand_spec.kind == "register"
            and core.is_non_empty_string(operand.text)
            and get_static_register_spec(adapter, operand.text)
        then
            return true
        end

        return false
    end

    return true
end


local function stack_operands_match_effect(adapter, instruction, effect_spec)
    if not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return false
    end

    for _, operand_spec in ipairs(effect_spec.operands or {}) do
        local index = tonumber(operand_spec.index)

        if not index then
            return false
        end

        local operand = instruction.operands and instruction.operands[index]

        if not stack_operand_matches_spec(adapter, operand, operand_spec) then
            return false
        end

        if not stack_operand_value_matches(operand, operand_spec) then
            return false
        end
    end

    return true
end


local function make_stack_fact(adapter, instruction, effect_spec, instruction_state)
    return stack_infer.make_effect_fact(
        adapter,
        instruction,
        effect_spec,
        instruction_state
    )
end


local function apply_stack_effect(facts, adapter, instruction, effect_spec, instruction_state)
    if not core.is_table(facts)
        or not core.is_table(adapter)
        or not core.is_table(instruction)
        or not core.is_table(effect_spec)
    then
        return
    end

    local expected_mnemonic =
        get_stack_effect_mnemonic(
            effect_spec
        )

    if expected_mnemonic
        and normalize_mnemonic(
            instruction.mnemonic
        ) ~= expected_mnemonic
    then
        return
    end

    if not stack_operands_match_effect(adapter, instruction, effect_spec) then
        return
    end

    if not condition_matches(instruction, effect_spec.condition) then
        return
    end

    local fact = make_stack_fact(adapter, instruction, effect_spec, instruction_state)

    if fact then
        table.insert(facts, fact)
    end
end


function M.collect_stack_effects(context, adapter, opts)
    opts = opts or {}

    local bufnr = opts.bufnr
    local root_node = opts.root_node

    if not bufnr
        or not root_node
        or not core.is_table(adapter)
        or not core.is_table(adapter.stack_effects)
    then
        return {}
    end

    local cursor_line = context
        and context.cursor
        and context.cursor.line

    local stack_effect_index = get_stack_effect_index(adapter)
    local register_effect_index = get_register_effect_index(adapter)

    local nodes = {}
    local seen_nodes = {}

    local function add_nodes_from_index(effect_index)
        if not core.is_table(effect_index)
            or not core.is_table(effect_index.node_types)
        then
            return
        end

        for node_type, _ in pairs(effect_index.node_types) do
            for _, node in ipairs(
                collect_nodes_by_type(root_node, node_type)
            ) do
                local start_row,
                    start_column,
                    end_row,
                    end_column = node:range()

                local node_line = start_row + 1

                if not cursor_line
                    or node_line <= cursor_line
                then
                    local key = table.concat({
                        node:type(),
                        tostring(start_row),
                        tostring(start_column),
                        tostring(end_row),
                        tostring(end_column),
                    }, ":")

                    if not seen_nodes[key] then
                        seen_nodes[key] = true

                        table.insert(nodes, {
                            node = node,
                            line = node_line,
                            column = start_column,
                        })
                    end
                end
            end
        end
    end

    -- Stack display needs stack facts, but stack values may come from earlier
    -- register facts. Walk stack-effect and register-effect instructions in a
    -- single ordered pass so push/pop facts can reuse the same lightweight
    -- carried register state without rescanning the buffer for every stack row.
    add_nodes_from_index(stack_effect_index)
    add_nodes_from_index(register_effect_index)

    table.sort(nodes, function(left, right)
        if left.line == right.line then
            return left.column < right.column
        end

        return left.line < right.line
    end)

    local facts = {}
    local low_level_state = low_level_inference.new_state()
    local facts_by_register = {}

    for _, entry in ipairs(nodes) do
        local node_type = entry.node:type()

        local stack_bucket = stack_effect_index.by_node_type
            and stack_effect_index.by_node_type[node_type]
            or nil

        local register_bucket = register_effect_index.by_node_type
            and register_effect_index.by_node_type[node_type]
            or nil

        local representative_effect_spec = stack_bucket
            and stack_bucket.__first
            or register_bucket
            and register_bucket.__first
            or nil

        if representative_effect_spec then
            local instruction = collect_instruction_operands(
                adapter,
                entry.node,
                bufnr,
                representative_effect_spec
            )

            local mnemonic = instruction
                and normalize_mnemonic(instruction.mnemonic)

            local stack_effect_specs = mnemonic
                and stack_bucket
                and stack_bucket[mnemonic]
                or nil

            local register_effect_specs = mnemonic
                and register_bucket
                and register_bucket[mnemonic]
                or nil

            local instruction_state = {}

            if core.is_table(stack_effect_specs) then
                instruction_state = stack_infer.prepare_instruction_state(
                    low_level_state,
                    instruction,
                    stack_effect_specs,
                    {
                        resolve_operand_value = function(operand)
                            return register_infer.resolve_operand_value(
                                facts_by_register,
                                instruction,
                                operand,
                                {
                                    parse_numeric_value = parse_numeric_value,
                                }
                            )
                        end,
                    }
                )

                for _, effect_spec in ipairs(stack_effect_specs) do
                    apply_stack_effect(
                        facts,
                        adapter,
                        instruction,
                        effect_spec,
                        instruction_state
                    )
                end
            end

            if core.is_table(register_effect_specs) then
                for _, effect_spec in ipairs(register_effect_specs) do
                    apply_register_effect(
                        facts_by_register,
                        adapter,
                        instruction,
                        effect_spec,
                        instruction_state
                    )
                end
            end
        end
    end

    return facts
end

return M
