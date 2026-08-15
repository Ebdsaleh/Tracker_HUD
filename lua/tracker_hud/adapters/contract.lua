-- lua/tracker_hud/adapters/contract.lua
--
-- Canonical Tracker_HUD Adapter Contract validator.
--
-- Adapter Contract v1 is Tree-sitter-first:
--
--     syntax
--         exact Tree-sitter node / field / child / token relationships
--
--     construct / member / value / scope
--         language-native and Tracker_HUD semantic meaning layered onto syntax
--
-- Instruction-driven semantic datasets are mnemonic-indexed and each rule
-- carries its own exact Tree-sitter syntax declaration.

local core = require("tracker_hud.core")
local construct_contract = require("tracker_hud.constructs.contract")

local M = {}


M.current_version = 1


local function path_error(path, message)
    if core.is_non_empty_string(path) then
        return false, path .. "." .. message
    end

    return false, message
end


local function validate_optional_boolean(value, path)
    if value == nil or type(value) == "boolean" then
        return true, nil
    end

    return path_error(path, "must be a boolean when provided")
end


local function validate_string_list(values, path, opts)
    opts = opts or {}

    if not core.is_table(values) then
        return path_error(path, "must be a table")
    end

    if opts.non_empty and #values == 0 then
        return path_error(path, "must contain at least one entry")
    end

    local seen = {}

    for index, value in ipairs(values) do
        if not core.is_non_empty_string(value) then
            return path_error(
                path .. "[" .. tostring(index) .. "]",
                "must be a non-empty string"
            )
        end

        if opts.unique and seen[value] then
            return path_error(
                path .. "[" .. tostring(index) .. "]",
                "duplicates '" .. value .. "'"
            )
        end

        seen[value] = true
    end

    return true, nil
end


local function validate_field_descriptor(field_spec, path)
    if core.is_non_empty_string(field_spec) then
        return true, nil
    end

    if not core.is_table(field_spec) then
        return path_error(
            path,
            "must be a Tree-sitter field name string or descriptor table"
        )
    end

    if not core.is_non_empty_string(field_spec.field) then
        return path_error(path .. ".field", "must be a non-empty string")
    end

    if field_spec.node_type ~= nil
        and not core.is_non_empty_string(field_spec.node_type)
    then
        return path_error(
            path .. ".node_type",
            "must be a non-empty string when provided"
        )
    end

    if field_spec.node_types ~= nil then
        local ok, err = validate_string_list(
            field_spec.node_types,
            path .. ".node_types",
            { non_empty = true, unique = true }
        )

        if not ok then
            return false, err
        end
    end

    if field_spec.text ~= nil
        and not core.is_non_empty_string(field_spec.text)
    then
        return path_error(
            path .. ".text",
            "must be a non-empty string when provided"
        )
    end

    local ok, err = validate_optional_boolean(
        field_spec.optional,
        path .. ".optional"
    )

    if not ok then
        return false, err
    end

    return validate_optional_boolean(
        field_spec.multiple,
        path .. ".multiple"
    )
end


local function validate_fields(fields, path)
    if fields == nil then
        return true, nil
    end

    if not core.is_table(fields) then
        return path_error(path, "must be a table when provided")
    end

    for semantic_name, field_spec in pairs(fields) do
        if not core.is_non_empty_string(semantic_name) then
            return path_error(path, "keys must be non-empty strings")
        end

        local ok, err = validate_field_descriptor(
            field_spec,
            path .. "." .. semantic_name
        )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_child_descriptor(child_spec, path)
    if not core.is_table(child_spec) then
        return path_error(path, "must be a table")
    end

    local has_node_type = core.is_non_empty_string(child_spec.node_type)
    local has_node_types = core.is_table(child_spec.node_types)

    if not has_node_type and not has_node_types then
        return path_error(
            path,
            "must declare node_type or node_types"
        )
    end

    if child_spec.node_type ~= nil and not has_node_type then
        return path_error(
            path .. ".node_type",
            "must be a non-empty string when provided"
        )
    end

    if has_node_types then
        local ok, err = validate_string_list(
            child_spec.node_types,
            path .. ".node_types",
            { non_empty = true, unique = true }
        )

        if not ok then
            return false, err
        end
    end

    local ok, err = validate_optional_boolean(
        child_spec.optional,
        path .. ".optional"
    )

    if not ok then
        return false, err
    end

    return validate_optional_boolean(
        child_spec.multiple,
        path .. ".multiple"
    )
end


local function validate_children(children, path)
    if children == nil then
        return true, nil
    end

    if not core.is_table(children) then
        return path_error(path, "must be a table when provided")
    end

    for semantic_name, child_spec in pairs(children) do
        if not core.is_non_empty_string(semantic_name) then
            return path_error(path, "keys must be non-empty strings")
        end

        local ok, err = validate_child_descriptor(
            child_spec,
            path .. "." .. semantic_name
        )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_tokens(tokens, path)
    if tokens == nil then
        return true, nil
    end

    if not core.is_table(tokens) then
        return path_error(path, "must be a table when provided")
    end

    for token_name, token_text in pairs(tokens) do
        if not core.is_non_empty_string(token_name) then
            return path_error(path, "keys must be non-empty strings")
        end

        if not core.is_non_empty_string(token_text) then
            return path_error(
                path .. "." .. token_name,
                "must be a non-empty string"
            )
        end
    end

    return true, nil
end


local function validate_exclusions(exclusions, path)
    if exclusions == nil then
        return true, nil
    end

    if not core.is_table(exclusions) then
        return path_error(path, "must be a table when provided")
    end

    if exclusions.ancestor_node_types ~= nil then
        return validate_string_list(
            exclusions.ancestor_node_types,
            path .. ".ancestor_node_types",
            { non_empty = true, unique = true }
        )
    end

    return true, nil
end


function M.validate_syntax(syntax, path)
    path = path or "syntax"

    if not core.is_table(syntax) then
        return path_error(path, "must be a table")
    end

    if not core.is_non_empty_string(syntax.node_type) then
        return path_error(
            path .. ".node_type",
            "must be a non-empty Tree-sitter node type string"
        )
    end

    local ok, err = validate_fields(
        syntax.fields,
        path .. ".fields"
    )

    if not ok then
        return false, err
    end

    ok, err = validate_children(
        syntax.children,
        path .. ".children"
    )

    if not ok then
        return false, err
    end

    ok, err = validate_tokens(
        syntax.tokens,
        path .. ".tokens"
    )

    if not ok then
        return false, err
    end

    return validate_exclusions(
        syntax.exclusions,
        path .. ".exclusions"
    )
end


local function validate_markers(markers, syntax, path)
    if markers == nil then
        return true, nil
    end

    if not core.is_table(markers) then
        return path_error(path, "must be a table when provided")
    end

    local required = markers.required or {}
    local optional = markers.optional or {}

    local ok, err = validate_string_list(
        required,
        path .. ".required",
        { unique = true }
    )

    if not ok then
        return false, err
    end

    ok, err = validate_string_list(
        optional,
        path .. ".optional",
        { unique = true }
    )

    if not ok then
        return false, err
    end

    local tokens = syntax.tokens or {}

    for _, marker_name in ipairs(required) do
        if not core.is_non_empty_string(tokens[marker_name]) then
            return path_error(
                path .. ".required",
                "references missing syntax token '" .. marker_name .. "'"
            )
        end
    end

    for _, marker_name in ipairs(optional) do
        if not core.is_non_empty_string(tokens[marker_name]) then
            return path_error(
                path .. ".optional",
                "references missing syntax token '" .. marker_name .. "'"
            )
        end
    end

    if markers.total_required ~= nil then
        if not core.is_number(markers.total_required) then
            return path_error(
                path .. ".total_required",
                "must be a number when provided"
            )
        end

        if markers.total_required ~= #required then
            return path_error(
                path .. ".total_required",
                "must equal the number of required markers"
            )
        end
    end

    return true, nil
end


local function validate_branch(branch, path)
    if branch == nil then
        return true, nil
    end

    if not core.is_table(branch) then
        return path_error(path, "must be a table when provided")
    end

    local ok, err = validate_optional_boolean(
        branch.grouped,
        path .. ".grouped"
    )

    if not ok then
        return false, err
    end

    if branch.alternatives == nil then
        return true, nil
    end

    if not core.is_table(branch.alternatives) then
        return path_error(
            path .. ".alternatives",
            "must be a table when provided"
        )
    end

    for index, alternative in ipairs(branch.alternatives) do
        local alternative_path = path
            .. ".alternatives["
            .. tostring(index)
            .. "]"

        if not core.is_table(alternative) then
            return path_error(alternative_path, "must be a table")
        end

        ok, err = M.validate_syntax(
            alternative.syntax,
            alternative_path .. ".syntax"
        )

        if not ok then
            return false, err
        end

        if not core.is_non_empty_string(alternative.label) then
            return path_error(
                alternative_path .. ".label",
                "must be a non-empty string"
            )
        end
    end

    return true, nil
end


local function validate_construct_entry(node_type, spec, path)
    if not core.is_table(spec) then
        return path_error(path, "must be a table")
    end

    local ok, err = M.validate_syntax(
        spec.syntax,
        path .. ".syntax"
    )

    if not ok then
        return false, err
    end

    if spec.syntax.node_type ~= node_type then
        return path_error(
            path .. ".syntax.node_type",
            "must match construct_specs key '" .. node_type .. "'"
        )
    end

    ok, err = construct_contract.validate_construct_spec(
        spec.construct
    )

    if not ok then
        return path_error(path, err)
    end

    if not core.is_non_empty_string(spec.construct.language_term) then
        return path_error(
            path .. ".construct.language_term",
            "is required by Adapter Contract v1"
        )
    end

    ok, err = construct_contract.validate_scope_spec(spec.scope)

    if not ok then
        return path_error(path, err)
    end

    ok, err = construct_contract.validate_value_spec(spec.value)

    if not ok then
        return path_error(path, err)
    end

    if core.is_table(spec.value)
        and not core.is_non_empty_string(spec.value.language_term)
    then
        return path_error(
            path .. ".value.language_term",
            "is required when value is declared"
        )
    end

    ok, err = validate_branch(
        spec.branch,
        path .. ".branch"
    )

    if not ok then
        return false, err
    end

    return validate_markers(
        spec.markers,
        spec.syntax,
        path .. ".markers"
    )
end


local function validate_construct_specs(construct_specs)
    if not core.is_table(construct_specs) then
        return false, "adapter.construct_specs must be a table"
    end

    local count = 0

    for node_type, spec in pairs(construct_specs) do
        count = count + 1

        if not core.is_non_empty_string(node_type) then
            return false,
                "adapter.construct_specs keys must be non-empty Tree-sitter node type strings"
        end

        local ok, err = validate_construct_entry(
            node_type,
            spec,
            "adapter.construct_specs[" .. node_type .. "]"
        )

        if not ok then
            return false, err
        end
    end

    if count == 0 then
        return false, "adapter.construct_specs must contain at least one construct"
    end

    return true, nil
end


local function validate_scope_member_entry(group_name, index, entry)
    local path = "adapter.scope_members."
        .. group_name
        .. "["
        .. tostring(index)
        .. "]"

    if not core.is_table(entry) then
        return path_error(path, "must be a table")
    end

    local ok, err = M.validate_syntax(
        entry.syntax,
        path .. ".syntax"
    )

    if not ok then
        return false, err
    end

    ok, err = construct_contract.validate_member_spec(entry.member)

    if not ok then
        return path_error(path, err)
    end

    if not core.is_table(entry.member) then
        return path_error(path .. ".member", "must be a table")
    end

    if not core.is_non_empty_string(entry.member.language_term) then
        return path_error(
            path .. ".member.language_term",
            "is required by Adapter Contract v1"
        )
    end

    ok, err = construct_contract.validate_value_spec(entry.value)

    if not ok then
        return path_error(path, err)
    end

    if core.is_table(entry.value)
        and not core.is_non_empty_string(entry.value.language_term)
    then
        return path_error(
            path .. ".value.language_term",
            "is required when value is declared"
        )
    end

    if entry.mnemonic ~= nil
        and not core.is_non_empty_string(entry.mnemonic)
    then
        return path_error(
            path .. ".mnemonic",
            "must be a non-empty string when provided"
        )
    end

    if entry.operand_index ~= nil
        and (
            not core.is_number(entry.operand_index)
            or entry.operand_index < 1
        )
    then
        return path_error(
            path .. ".operand_index",
            "must be a positive number when provided"
        )
    end

    return true, nil
end


local function validate_scope_members(scope_members)
    if scope_members == nil then
        return true, nil
    end

    if not core.is_table(scope_members) then
        return false, "adapter.scope_members must be a table when provided"
    end

    for group_name, entries in pairs(scope_members) do
        if not core.is_non_empty_string(group_name) then
            return false, "adapter.scope_members keys must be non-empty strings"
        end

        if not core.is_table(entries) then
            return false,
                "adapter.scope_members."
                .. group_name
                .. " must be a table"
        end

        for index, entry in ipairs(entries) do
            local ok, err = validate_scope_member_entry(
                group_name,
                index,
                entry
            )

            if not ok then
                return false, err
            end
        end
    end

    return true, nil
end


local function validate_range_scopes(range_scopes)
    if range_scopes == nil then
        return true, nil
    end

    if not core.is_table(range_scopes) then
        return false, "adapter.range_scopes must be a table when provided"
    end

    for index, spec in ipairs(range_scopes) do
        local path = "adapter.range_scopes[" .. tostring(index) .. "]"

        if not core.is_table(spec) then
            return path_error(path, "must be a table")
        end

        local ok, err = M.validate_syntax(
            spec.syntax,
            path .. ".syntax"
        )

        if not ok then
            return false, err
        end

        if not core.is_non_empty_string(spec.label) then
            return path_error(
                path .. ".label",
                "must be a non-empty string"
            )
        end

        if not core.is_non_empty_string(spec.range_strategy) then
            return path_error(
                path .. ".range_strategy",
                "must be a non-empty string"
            )
        end

        ok, err = construct_contract.validate_scope_spec(spec.scope)

        if not ok then
            return path_error(path, err)
        end
    end

    return true, nil
end


local function get_rule_mnemonic(rule)
    local syntax = core.is_table(rule) and rule.syntax or nil
    local fields = core.is_table(syntax) and syntax.fields or nil
    local kind_field = core.is_table(fields) and fields.kind or nil

    if core.is_table(kind_field)
        and core.is_non_empty_string(kind_field.text)
    then
        return kind_field.text:lower()
    end

    return nil
end


local function validate_operands(operands, path)
    if operands == nil then
        return true, nil
    end

    if not core.is_table(operands) then
        return path_error(path, "must be a table when provided")
    end

    for index, operand in ipairs(operands) do
        if not core.is_table(operand) then
            return path_error(
                path .. "[" .. tostring(index) .. "]",
                "must be a table"
            )
        end

        if operand.index ~= nil
            and (
                not core.is_number(operand.index)
                or operand.index < 1
            )
        then
            return path_error(
                path .. "[" .. tostring(index) .. "].index",
                "must be a positive number when provided"
            )
        end
    end

    return true, nil
end


local function validate_instruction_rule_set(
    rule_set,
    dataset_name,
    opts
)
    opts = opts or {}

    if rule_set == nil then
        return true, nil
    end

    if not core.is_table(rule_set) then
        return false,
            "adapter."
            .. dataset_name
            .. " must be a table when provided"
    end

    for mnemonic, rules in pairs(rule_set) do
        if type(mnemonic) ~= "string" or mnemonic == "" then
            return false,
                "adapter."
                .. dataset_name
                .. " must be mnemonic-indexed; numeric/legacy entries are not allowed by Adapter Contract v1"
        end

        if not core.is_table(rules) or #rules == 0 then
            return false,
                "adapter."
                .. dataset_name
                .. "."
                .. mnemonic
                .. " must contain at least one rule"
        end

        for index, rule in ipairs(rules) do
            local path = "adapter."
                .. dataset_name
                .. "."
                .. mnemonic
                .. "["
                .. tostring(index)
                .. "]"

            if not core.is_table(rule) then
                return path_error(path, "must be a table")
            end

            local ok, err = M.validate_syntax(
                rule.syntax,
                path .. ".syntax"
            )

            if not ok then
                return false, err
            end

            if rule.syntax.node_type ~= "instruction" then
                return path_error(
                    path .. ".syntax.node_type",
                    "must be 'instruction' for an instruction-driven semantic rule"
                )
            end

            local rule_mnemonic = get_rule_mnemonic(rule)

            if rule_mnemonic ~= mnemonic:lower() then
                return path_error(
                    path .. ".syntax.fields.kind.text",
                    "must match mnemonic bucket '" .. mnemonic .. "'"
                )
            end

            ok, err = validate_operands(
                rule.operands,
                path .. ".operands"
            )

            if not ok then
                return false, err
            end

            if opts.require_effect and not core.is_table(rule.effect) then
                return path_error(path .. ".effect", "must be a table")
            end

            if opts.require_event and not core.is_table(rule.event) then
                return path_error(path .. ".event", "must be a table")
            end
        end
    end

    return true, nil
end


local function validate_capabilities(capabilities)
    if capabilities == nil then
        return true, nil
    end

    if not core.is_table(capabilities) then
        return false, "adapter.capabilities must be a table when provided"
    end

    for capability, enabled in pairs(capabilities) do
        if not core.is_non_empty_string(capability) then
            return false, "adapter.capabilities keys must be non-empty strings"
        end

        if type(enabled) ~= "boolean" then
            return false,
                "adapter.capabilities."
                .. capability
                .. " must be a boolean"
        end
    end

    return true, nil
end


local function validate_sections(sections)
    if sections == nil then
        return true, nil
    end

    if not core.is_table(sections) then
        return false, "adapter.sections must be a table when provided"
    end

    for section_key, descriptor in pairs(sections) do
        local path = "adapter.sections." .. tostring(section_key)

        if not core.is_non_empty_string(section_key) then
            return false, "adapter.sections keys must be non-empty strings"
        end

        if not core.is_table(descriptor) then
            return path_error(path, "must be a table")
        end

        if descriptor.id ~= section_key then
            return path_error(
                path .. ".id",
                "must match section key '" .. section_key .. "'"
            )
        end

        if not core.is_non_empty_string(descriptor.label) then
            return path_error(
                path .. ".label",
                "must be a non-empty string"
            )
        end

        local ok, err = validate_optional_boolean(
            descriptor.use_source_index,
            path .. ".use_source_index"
        )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_presentation(presentation)
    if presentation == nil then
        return true, nil
    end

    if not core.is_table(presentation) then
        return false, "adapter.presentation must be a table when provided"
    end

    if presentation.sections == nil then
        return true, nil
    end

    if not core.is_table(presentation.sections) then
        return false,
            "adapter.presentation.sections must be a table when provided"
    end

    if presentation.sections.order == nil then
        return true, nil
    end

    return validate_string_list(
        presentation.sections.order,
        "adapter.presentation.sections.order",
        { unique = true }
    )
end


local function validate_instruction_parser(instruction_parser)
    if instruction_parser == nil then
        return true, nil
    end

    if not core.is_table(instruction_parser) then
        return false,
            "adapter.instruction_parser must be a table when provided"
    end

    if not core.is_non_empty_string(instruction_parser.module) then
        return false,
            "adapter.instruction_parser.module must be a non-empty string"
    end

    if not core.is_non_empty_string(instruction_parser.function_name) then
        return false,
            "adapter.instruction_parser.function_name must be a non-empty string"
    end

    return true, nil
end


local function normalize_filetypes(filetypes)
    if core.is_string(filetypes) then
        return { filetypes }
    end

    if core.is_table(filetypes) then
        return filetypes
    end

    return {}
end


local function validate_filetypes(filetypes)
    local normalized = normalize_filetypes(filetypes)

    if #normalized == 0 then
        return false,
            "adapter.filetypes must contain at least one filetype"
    end

    return validate_string_list(
        normalized,
        "adapter.filetypes",
        { non_empty = true, unique = true }
    )
end


function M.validate_adapter(adapter)
    if not core.is_table(adapter) then
        return false, "adapter must be a table"
    end

    if not core.is_number(adapter.contract_version) then
        return false,
            "adapter.contract_version is required and must be a number"
    end

    if adapter.contract_version ~= M.current_version then
        return false,
            "unsupported adapter.contract_version: "
            .. tostring(adapter.contract_version)
            .. " (expected "
            .. tostring(M.current_version)
            .. ")"
    end

    if not core.is_non_empty_string(adapter.name) then
        return false, "adapter.name must be a non-empty string"
    end

    local ok, err = validate_filetypes(adapter.filetypes)

    if not ok then
        return false, err
    end

    ok, err = validate_construct_specs(adapter.construct_specs)

    if not ok then
        return false, err
    end

    ok, err = validate_scope_members(adapter.scope_members)

    if not ok then
        return false, err
    end

    ok, err = validate_range_scopes(adapter.range_scopes)

    if not ok then
        return false, err
    end

    ok, err = validate_capabilities(adapter.capabilities)

    if not ok then
        return false, err
    end

    ok, err = validate_sections(adapter.sections)

    if not ok then
        return false, err
    end

    ok, err = validate_presentation(adapter.presentation)

    if not ok then
        return false, err
    end

    ok, err = validate_instruction_parser(adapter.instruction_parser)

    if not ok then
        return false, err
    end

    ok, err = validate_instruction_rule_set(
        adapter.register_effects,
        "register_effects",
        { require_effect = true }
    )

    if not ok then
        return false, err
    end

    ok, err = validate_instruction_rule_set(
        adapter.instruction_events,
        "instruction_events",
        {
            require_effect = true,
            require_event = true,
        }
    )

    if not ok then
        return false, err
    end

    ok, err = validate_instruction_rule_set(
        adapter.stack_effects,
        "stack_effects",
        { require_effect = true }
    )

    if not ok then
        return false, err
    end

    return validate_instruction_rule_set(
        adapter.boundary_effects,
        "boundary_effects"
    )
end


return M
