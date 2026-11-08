-- lua/tracker_hud/adapters/c/memory_facts.lua
--
-- C and C++ source-observed allocation/release sites. This is NOT pointer
-- analysis, ownership inference or proof of successful allocation/free.
-- Every fact requires an actual Tree-sitter expression node and is visible
-- only when the cursor is ON or PAST its source line.
--
-- Never infer leaks here. That requires alias, escape, path and RAII analysis.

local ts_utils = require("tracker_hud.treesitter_utils")

local M = {}

local direct_calls = {
    malloc = {
        kind = "heap_allocation_site",
        role = "direct call named malloc; allocation success and ownership unknown",
    },
    calloc = {
        kind = "heap_allocation_site",
        role = "direct call named calloc; allocation success and ownership unknown",
    },
    realloc = {
        kind = "heap_resize_site",
        role = "direct call named realloc; old allocation remains valid if resizing fails",
    },
    free = {
        kind = "heap_release_site",
        role = "direct call named free; pointer target and release effect not proven",
    },
}

local function describe_expression(bufnr, node)
    local text = ts_utils.get_node_text(node, bufnr)
    if type(text) ~= "string" then
        return nil
    end
    text = text:gsub("%s+", " ")
    if #text > 160 then
        text = text:sub(1, 157) .. "..."
    end
    return text
end

local function make_fact(bufnr, node, name, kind, role, source)
    local range = ts_utils.get_node_range_fields(node)
    local line = range.start_line
    if not line then
        return nil
    end

    local expression = describe_expression(bufnr, node)
    return {
        id = table.concat({
            "source-memory", tostring(line), tostring(range.start_column or 0),
            tostring(node:type()), tostring(name),
        }, ":"),
        name = name,
        kind = kind,
        category = "heap",
        role = role,
        source = source,
        source_line = line,
        source_column = range.start_column,
        source_start_line = line,
        source_start_column = range.start_column,
        source_end_line = range.end_line,
        source_end_column = range.end_column,
        metadata = {
            observation = "source call/expression only",
            expression = expression,
            allocation_success = "unknown",
            ownership = "unknown",
            live_pointer = "unknown",
            leak_status = "not analyzed",
        },
    }
end

local function inspect_node(bufnr, node, language)
    local node_type = node:type()

    if node_type == "call_expression" then
        local callee = ts_utils.get_child_by_field_name(node, "function")
        -- Only simple direct identifiers. Member, indirect, qualified and
        -- macro-expanded calls cannot be classified confidently at this stage.
        if not callee or callee:type() ~= "identifier" then
            return nil
        end

        local name = ts_utils.get_node_text(callee, bufnr)
        local signature = direct_calls[name]
        if not signature then
            return nil
        end

        return make_fact(bufnr, node, name,
            signature.kind, signature.role, language .. "_source_memory")
    end

    if language == "cpp" then
        if node_type == "new_expression" then
            return make_fact(bufnr, node, "new",
                "heap_allocation_site",
                "C++ new expression; construction, success and ownership not inferred",
                "cpp_source_memory")
        end
        if node_type == "delete_expression" then
            return make_fact(bufnr, node, "delete",
                "heap_release_site",
                "C++ delete expression; pointer ownership and destructor effects not inferred",
                "cpp_source_memory")
        end
    end

    return nil
end

function M.collect(bufnr, root_node, language, cursor_line)
    local facts = {}

    if not root_node or (language ~= "c" and language ~= "cpp") then
        return facts
    end

    local visible_line = tonumber(cursor_line)
    if not visible_line or visible_line < 1 then
        -- Caller has not established where discovery is allowed to stop.
        return facts
    end
    visible_line = math.floor(visible_line)

    local function visit(node)
        local row = node:start()
        -- Tree-sitter rows are zero-based; an expression is discoverable on
        -- its first line, including when it extends across subsequent lines.
        if row + 1 > visible_line then
            return
        end

        local fact = inspect_node(bufnr, node, language)
        if fact then
            table.insert(facts, fact)
        end

        for child in node:iter_children() do
            visit(child)
        end
    end

    visit(root_node)
    table.sort(facts, function(a, b)
        if a.source_line ~= b.source_line then
            return a.source_line < b.source_line
        end
        return (a.source_column or 0) < (b.source_column or 0)
    end)
    return facts
end

return M
