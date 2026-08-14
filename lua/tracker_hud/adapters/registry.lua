-- lua/tracker_hud/adapters/registry.lua
--
-- Internal adapter registry.
--
-- Users should not edit this file.
--
-- The registry stores language adapters by filetype and exposes lookup/parse
-- helpers for the context engine.
--
-- Tracker_HUD Adapter Contract v1
--
-- Every v1 adapter declares:
--
--     contract_version = 1
--     name = "..."
--     filetypes = { ... }
--
-- Tree-sitter-facing construct identity is expressed by:
--
--     construct_specs[tree_sitter_node_type]
--
-- Each construct specification then maps that exact Tree-sitter identity onto:
--
--     construct.kind
--         Tracker_HUD semantic identity.
--
--     construct.language_term
--         Active-language terminology.
--
--     construct.label
--         Human-facing display label.
--
-- Optional construct semantics include:
--
--     construct.mutability
--     scope
--     value
--     tokens
--     signature
--     branch
--     markers
--
-- Scope-member declarations use the same semantic vocabulary through:
--
--     member.kind
--     member.language_term
--     member.owner_scope
--     member.mutability
--
-- During the v1 migration, adapters without contract_version remain loadable.
-- Once all bundled adapters conform to v1, contract_version will become
-- mandatory.

local core = require("tracker_hud.core")
local contract = require("tracker_hud.constructs.contract")
local context_engine = require("tracker_hud.context_engine")

local M = {}


M.current_contract_version = 1


local adapters_by_filetype = {}


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
    local normalized =
        normalize_filetypes(filetypes)

    if #normalized == 0 then
        return false,
            "adapter.filetypes must contain at least one filetype"
    end

    for _, filetype in ipairs(normalized) do
        if not core.is_non_empty_string(filetype) then
            return false,
                "adapter.filetypes must only contain non-empty strings"
        end
    end

    return true, nil
end


local function validate_contract_version(adapter)
    if adapter.contract_version == nil then
        --
        -- Temporary migration compatibility.
        --
        -- Bundled legacy adapters may continue loading until they are
        -- explicitly migrated to Adapter Contract v1.
        --
        return true, nil
    end

    if not core.is_number(
        adapter.contract_version
    ) then
        return false,
            "adapter.contract_version must be a number"
    end

    if adapter.contract_version
        ~= M.current_contract_version
    then
        return false,
            "unsupported adapter.contract_version: "
            .. tostring(adapter.contract_version)
            .. " (expected "
            .. tostring(M.current_contract_version)
            .. ")"
    end

    return true, nil
end


local function validate_v1_construct_spec(
    node_type,
    spec
)
    if not core.is_non_empty_string(node_type) then
        return false,
            "adapter.construct_specs keys must be non-empty Tree-sitter node type strings"
    end

    if not core.is_table(spec) then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "] must be a table"
    end

    if not core.is_table(spec.construct) then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "].construct must be a table"
    end

    local ok, err =
        contract.validate_construct_spec(
            spec.construct
        )

    if not ok then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "]."
            .. tostring(err)
    end

    --
    -- Adapter Contract v1 requires every declared construct to expose
    -- active-language vocabulary explicitly.
    --
    if not core.is_non_empty_string(
        spec.construct.language_term
    ) then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "].construct.language_term is required by Adapter Contract v1"
    end

    ok, err =
        contract.validate_scope_spec(
            spec.scope
        )

    if not ok then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "]."
            .. tostring(err)
    end

    ok, err =
        contract.validate_value_spec(
            spec.value
        )

    if not ok then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "]."
            .. tostring(err)
    end

    if core.is_table(spec.value)
        and not core.is_non_empty_string(
            spec.value.language_term
        )
    then
        return false,
            "adapter.construct_specs["
            .. tostring(node_type)
            .. "].value.language_term is required when value is declared by Adapter Contract v1"
    end

    return true, nil
end


local function validate_v1_construct_specs(
    construct_specs
)
    if not core.is_table(construct_specs) then
        return false,
            "adapter.construct_specs must be a table"
    end

    for node_type, spec in pairs(
        construct_specs
    ) do
        local ok, err =
            validate_v1_construct_spec(
                node_type,
                spec
            )

        if not ok then
            return false, err
        end
    end

    return true, nil
end


local function validate_v1_scope_member_entry(
    group_name,
    index,
    entry
)
    if not core.is_table(entry) then
        return false,
            "adapter.scope_members."
            .. tostring(group_name)
            .. "["
            .. tostring(index)
            .. "] must be a table"
    end

    if not core.is_non_empty_string(
        entry.node_type
    ) then
        return false,
            "adapter.scope_members."
            .. tostring(group_name)
            .. "["
            .. tostring(index)
            .. "].node_type must be a non-empty Tree-sitter node type string"
    end

    if not core.is_table(entry.member) then
        return false,
            "adapter.scope_members."
            .. tostring(group_name)
            .. "["
            .. tostring(index)
            .. "].member must be a table"
    end

    local ok, err =
        contract.validate_member_spec(
            entry.member
        )

    if not ok then
        return false,
            "adapter.scope_members."
            .. tostring(group_name)
            .. "["
            .. tostring(index)
            .. "]."
            .. tostring(err)
    end

    if not core.is_non_empty_string(
        entry.member.language_term
    ) then
        return false,
            "adapter.scope_members."
            .. tostring(group_name)
            .. "["
            .. tostring(index)
            .. "].member.language_term is required by Adapter Contract v1"
    end

    return true, nil
end


local function validate_v1_scope_members(
    scope_members
)
    if scope_members == nil then
        return true, nil
    end

    if not core.is_table(scope_members) then
        return false,
            "adapter.scope_members must be a table when provided"
    end

    for group_name, entries in pairs(
        scope_members
    ) do
        if not core.is_non_empty_string(
            group_name
        ) then
            return false,
                "adapter.scope_members keys must be non-empty strings"
        end

        if not core.is_table(entries) then
            return false,
                "adapter.scope_members."
                .. tostring(group_name)
                .. " must be a table"
        end

        for index, entry in ipairs(entries) do
            local ok, err =
                validate_v1_scope_member_entry(
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


local function validate_v1_capabilities(
    capabilities
)
    if capabilities == nil then
        return true, nil
    end

    if not core.is_table(capabilities) then
        return false,
            "adapter.capabilities must be a table when provided"
    end

    for capability, enabled in pairs(
        capabilities
    ) do
        if not core.is_non_empty_string(
            capability
        ) then
            return false,
                "adapter.capabilities keys must be non-empty strings"
        end

        if type(enabled) ~= "boolean" then
            return false,
                "adapter.capabilities."
                .. tostring(capability)
                .. " must be a boolean"
        end
    end

    return true, nil
end


local function validate_v1_sections(
    sections
)
    if sections == nil then
        return true, nil
    end

    if not core.is_table(sections) then
        return false,
            "adapter.sections must be a table when provided"
    end

    for section_key, descriptor in pairs(
        sections
    ) do
        if not core.is_non_empty_string(
            section_key
        ) then
            return false,
                "adapter.sections keys must be non-empty strings"
        end

        if not core.is_table(descriptor) then
            return false,
                "adapter.sections."
                .. tostring(section_key)
                .. " must be a table"
        end

        if not core.is_non_empty_string(
            descriptor.id
        ) then
            return false,
                "adapter.sections."
                .. tostring(section_key)
                .. ".id must be a non-empty string"
        end

        if descriptor.id ~= section_key then
            return false,
                "adapter.sections."
                .. tostring(section_key)
                .. ".id must match its section key"
        end

        if not core.is_non_empty_string(
            descriptor.label
        ) then
            return false,
                "adapter.sections."
                .. tostring(section_key)
                .. ".label must be a non-empty string"
        end

        if descriptor.use_source_index ~= nil
            and type(
                descriptor.use_source_index
            ) ~= "boolean"
        then
            return false,
                "adapter.sections."
                .. tostring(section_key)
                .. ".use_source_index must be a boolean when provided"
        end
    end

    return true, nil
end


local function validate_v1_presentation(
    presentation
)
    if presentation == nil then
        return true, nil
    end

    if not core.is_table(presentation) then
        return false,
            "adapter.presentation must be a table when provided"
    end

    if presentation.sections == nil then
        return true, nil
    end

    if not core.is_table(
        presentation.sections
    ) then
        return false,
            "adapter.presentation.sections must be a table when provided"
    end

    local order =
        presentation.sections.order

    if order == nil then
        return true, nil
    end

    if not core.is_table(order) then
        return false,
            "adapter.presentation.sections.order must be a table when provided"
    end

    for _, section_id in ipairs(order) do
        if not core.is_non_empty_string(
            section_id
        ) then
            return false,
                "adapter.presentation.sections.order must contain only non-empty section IDs"
        end
    end

    return true, nil
end


local function validate_v1_adapter(
    adapter
)
    local ok, err =
        validate_v1_construct_specs(
            adapter.construct_specs
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_v1_scope_members(
            adapter.scope_members
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_v1_capabilities(
            adapter.capabilities
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_v1_sections(
            adapter.sections
        )

    if not ok then
        return false, err
    end

    ok, err =
        validate_v1_presentation(
            adapter.presentation
        )

    if not ok then
        return false, err
    end

    return true, nil
end


function M.validate_adapter(adapter)
    if not core.is_table(adapter) then
        return false,
            "adapter must be a table"
    end

    local version_ok, version_err =
        validate_contract_version(adapter)

    if not version_ok then
        return false, version_err
    end

    if not core.is_non_empty_string(
        adapter.name
    ) then
        return false,
            "adapter.name must be a non-empty string"
    end

    local filetypes_ok, filetypes_err =
        validate_filetypes(
            adapter.filetypes
        )

    if not filetypes_ok then
        return false, filetypes_err
    end

    if not core.is_table(
        adapter.construct_specs
    ) then
        return false,
            "adapter.construct_specs must be a table"
    end

    if adapter.contract_version
        == M.current_contract_version
    then
        return validate_v1_adapter(
            adapter
        )
    end

    --
    -- Temporary legacy path.
    --
    -- This disappears after the bundled adapters have all migrated to v1.
    --

    return true, nil
end


function M.register(adapter)
    local ok, err =
        M.validate_adapter(adapter)

    if not ok then
        return false, err
    end

    for _, filetype in ipairs(
        normalize_filetypes(
            adapter.filetypes
        )
    ) do
        adapters_by_filetype[filetype] =
            adapter
    end

    return true, nil
end


function M.get_adapter(filetype)
    if not core.is_non_empty_string(
        filetype
    ) then
        return nil
    end

    return adapters_by_filetype[filetype]
end


function M.configure_adapter_for_buffer(
    filetype,
    bufnr,
    config
)
    local adapter =
        M.get_adapter(filetype)

    if not adapter then
        return false,
            "no adapter registered for filetype: "
            .. tostring(filetype)
    end

    if type(
        adapter.configure_adapter_for_buffer
    ) ~= "function"
    then
        return true, nil
    end

    local ok, err =
        pcall(
            adapter.configure_adapter_for_buffer,
            bufnr,
            config
        )

    if not ok then
        return false, tostring(err)
    end

    return true, nil
end


function M.has_adapter(filetype)
    return M.get_adapter(filetype) ~= nil
end


function M.parse_node(
    filetype,
    node,
    bufnr
)
    local adapter =
        M.get_adapter(filetype)

    if not adapter then
        return nil,
            "no adapter registered for filetype: "
            .. tostring(filetype)
    end

    local matched =
        context_engine.match_node(
            adapter,
            node
        )

    if not matched then
        return nil, nil
    end

    local parsed_ok,
        construct,
        parse_err =
        pcall(
            context_engine.parse_node,
            adapter,
            node,
            bufnr
        )

    if not parsed_ok then
        return nil,
            "context_engine.parse_node failed for "
            .. adapter.name
            .. ": "
            .. tostring(construct)
    end

    if not construct then
        return nil, parse_err
    end

    local valid, validation_err =
        contract.validate_construct(
            construct
        )

    if not valid then
        return nil,
            "invalid construct from "
            .. adapter.name
            .. ": "
            .. tostring(validation_err)
    end

    return construct, nil
end


function M.list_filetypes()
    local filetypes = {}

    for filetype, _ in pairs(
        adapters_by_filetype
    ) do
        table.insert(
            filetypes,
            filetype
        )
    end

    table.sort(filetypes)

    return filetypes
end


function M.clear()
    adapters_by_filetype = {}
end


return M
