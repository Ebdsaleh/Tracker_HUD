-- lua/tracker_hud/context.lua

local M = {}

local adapter_registry = require("tracker_hud.adapters.registry")
local context_engine = require("tracker_hud.context_engine")
local scope_members = require("tracker_hud.scope_members")
local registers = require("tracker_hud.registers")
local stack = require("tracker_hud.stack")
local heap = require("tracker_hud.heap")
local warnings = require("tracker_hud.warnings")
local ts_utils = require("tracker_hud.treesitter_utils")


local function try_parse_construct_with_adapter(bufnr, node)
    if not node then
        return nil
    end

    local filetype = vim.bo[bufnr].filetype

    if not filetype or filetype == "" then
        return nil
    end

    if not adapter_registry.has_adapter(filetype) then
        return nil
    end

    local construct, _err = adapter_registry.parse_node(filetype, node, bufnr)
    return construct
end


local function find_nearest_member_scope(scopes)
    for _, scope_entry in ipairs(scopes or {}) do
        local scope = scope_entry.scope

        if type(scope) == "table"
            and (
                scope.affects_visibility == true
                or scope.owns_members == true
            )
        then
            return scope_entry
        end
    end

    return nil
end


local function build_member_scope_context(scope_entry)
    if type(scope_entry) ~= "table" then
        return nil
    end

    return {
        label = scope_entry.label,
        raw_label = scope_entry.raw_label,
        node_type = scope_entry.node_type,
        kind = scope_entry.kind,
        start_line = scope_entry.start_line,
        end_line = scope_entry.end_line,
    }
end


local function get_first_descendant_text_by_type(node, bufnr, node_type)
    if not node or type(node_type) ~= "string" or node_type == "" then
        return nil
    end

    local found = ts_utils.find_first_descendant_by_type(node, node_type)

    if not found then
        return nil
    end

    return ts_utils.get_node_text(found, bufnr)
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


local function make_range_scope_entry(bufnr, node, range_scope_spec, start_line, end_line)
    if not node or type(range_scope_spec) ~= "table" then
        return nil
    end

    local name = get_first_descendant_text_by_type(
        node,
        bufnr,
        range_scope_spec.name_node_type
    )

    local label = range_scope_spec.label or "Scope"
    local raw_label = label

    if type(name) == "string" and name ~= "" then
        raw_label = label .. " " .. name
    end

    local display_label = "[" .. tostring(start_line) .. "] " .. raw_label

    return {
        label = display_label,
        raw_label = raw_label,
        node_type = node:type(),
        kind = range_scope_spec.kind or "range_scope",
        scope = range_scope_spec.scope,
        value = range_scope_spec.value,
        start_line = start_line,
        end_line = end_line,
        construct = {
            node_type = node:type(),
            name = name,
            range = {
                start_line = start_line,
                end_line = end_line,
            },
            metadata = {
                display_label = display_label,
                range_strategy = range_scope_spec.range_strategy,
            },
        },
    }
end


local function scope_entry_exists(scopes, candidate)
    if type(candidate) ~= "table" then
        return false
    end

    for _, scope_entry in ipairs(scopes or {}) do
        if type(scope_entry) == "table"
            and scope_entry.node_type == candidate.node_type
            and scope_entry.start_line == candidate.start_line
            and scope_entry.end_line == candidate.end_line
        then
            return true
        end
    end

    return false
end


local function collect_range_scope_entries(bufnr, root_node, adapter, cursor_line)
    local entries = {}

    if not root_node or type(adapter) ~= "table" or type(adapter.range_scopes) ~= "table" then
        return entries
    end

    if type(cursor_line) ~= "number" then
        return entries
    end

    local file_end_line = vim.api.nvim_buf_line_count(bufnr)

    for _, range_scope_spec in ipairs(adapter.range_scopes) do
        if type(range_scope_spec) == "table"
            and range_scope_spec.range_strategy == "until_next_peer"
            and type(range_scope_spec.node_type) == "string"
        then
            local nodes = collect_nodes_by_type(root_node, range_scope_spec.node_type)

            for index, node in ipairs(nodes) do
                local start_line = node:start() + 1
                local end_line = file_end_line

                local next_node = nodes[index + 1]

                if next_node then
                    end_line = next_node:start()
                end

                if cursor_line >= start_line and cursor_line <= end_line then
                    local entry = make_range_scope_entry(
                        bufnr,
                        node,
                        range_scope_spec,
                        start_line,
                        end_line
                    )

                    if entry then
                        table.insert(entries, entry)
                    end
                end
            end
        end
    end

    return entries
end


local function append_missing_range_scopes(scopes, range_scopes)
    for _, range_scope in ipairs(range_scopes or {}) do
        if not scope_entry_exists(scopes, range_scope) then
            -- scopes are stored innermost -> outermost.
            -- A label range is usually outside the current instruction node.
            table.insert(scopes, range_scope)
        end
    end
end


local function attach_context_sections(context, bufnr, root_node, adapter, scope_member_opts)
    context.scope_members = scope_members.collect(
        bufnr,
        root_node,
        adapter,
        scope_member_opts
    )

    context.all_scope_members = scope_members.collect(bufnr, root_node, adapter)

    context.registers = registers.collect(context, adapter, {
        bufnr = bufnr,
        root_node = root_node,
    })

    context.stack = stack.collect(context, adapter, {
        bufnr = bufnr,
        root_node = root_node,
    })

    context.boundary_effects = context_engine.collect_boundary_effects(
        context,
        adapter,
        {
            bufnr = bufnr,
            root_node = root_node,
        }
    )

    -- Heap is intentionally a shell for now.
    -- Later, boundary effects such as mmap/brk/munmap/malloc/free/new/delete
    -- can populate this section.
    context.heap = heap.collect(context, adapter, {
        bufnr = bufnr,
        root_node = root_node,
    })

    -- warnings are derived after boundary/heap facts exist.
    context.warnings = warnings.collect(context, adapter, {
        bufnr = bufnr,
        root_node = root_node
    })

    return context
end

function M.get_cursor_context(bufnr, config)
    config = config or {}

    local filetype = vim.bo[bufnr].filetype
    local ok, parser = pcall(vim.treesitter.get_parser, bufnr)

    if not ok or not parser then
        return context_engine.make_unavailable_context(
            "No Tree-sitter parser available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    if not adapter_registry.has_adapter(filetype) then
        return context_engine.make_unavailable_context(
            "No Tracker HUD adapter available for filetype: " .. tostring(filetype),
            filetype
        )
    end

    local tree = parser:parse()[1]
    local root_node = nil

    if tree then
        root_node = tree:root()
    end

    local configured, configure_err = adapter_registry.configure_adapter_for_buffer(
        filetype,
        bufnr,
        config
    )

    if not configured then
        return context_engine.make_unavailable_context(
            "Tracker HUD adapter configuration failed for filetype: "
                .. tostring(filetype)
                .. " - "
                .. tostring(configure_err),
            filetype
        )
    end

    local adapter = adapter_registry.get_adapter(filetype)
    local cursor = context_engine.get_cursor_location()
    local node = vim.treesitter.get_node()

    if not node then
        local context = context_engine.make_global_context()
        local range_scopes = collect_range_scope_entries(
            bufnr,
            root_node,
            adapter,
            cursor.line
        )

        append_missing_range_scopes(context.scopes, range_scopes)

        if #context.scopes > 0 then
            context = context_engine.build_context_from_scopes(context.scopes, config)
        end

        local nearest_member_scope = find_nearest_member_scope(context.scopes)
        local scope_member_opts = {
            cursor_line = context.cursor and context.cursor.line,
        }

        if nearest_member_scope then
            scope_member_opts.start_line = nearest_member_scope.start_line
            scope_member_opts.end_line = nearest_member_scope.end_line
            context.member_scope = build_member_scope_context(nearest_member_scope)
        else
            scope_member_opts.scope_depth = 0
            context.member_scope = nil
        end

        return attach_context_sections(
            context,
            bufnr,
            root_node,
            adapter,
            scope_member_opts
        )
    end

    local scopes = {}

    while node do
        local construct = try_parse_construct_with_adapter(bufnr, node)

        if construct then
            local scope_entry = context_engine.build_scope_entry_from_construct(construct)

            if scope_entry then
                table.insert(scopes, scope_entry)
            end
        end

        node = node:parent()
    end

    local range_scopes = collect_range_scope_entries(
        bufnr,
        root_node,
        adapter,
        cursor.line
    )

    append_missing_range_scopes(scopes, range_scopes)

    local context = context_engine.build_context_from_scopes(scopes, config)

    local scope_member_opts = {
        cursor_line = context.cursor and context.cursor.line,
    }

    local nearest_member_scope = find_nearest_member_scope(context.scopes)

    if nearest_member_scope then
        scope_member_opts.start_line = nearest_member_scope.start_line
        scope_member_opts.end_line = nearest_member_scope.end_line
        context.member_scope = build_member_scope_context(nearest_member_scope)
    else
        scope_member_opts.scope_depth = 0
        context.member_scope = nil
    end

    return attach_context_sections(
        context,
        bufnr,
        root_node,
        adapter,
        scope_member_opts
    )
end

return M
