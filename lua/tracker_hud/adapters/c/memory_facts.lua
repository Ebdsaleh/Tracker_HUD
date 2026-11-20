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

local declarator_wrappers = {
    pointer_declarator = true,
    array_declarator = true,
    parenthesized_declarator = true,
    reference_declarator = true,
}

local function direct_identifier_text(bufnr, node)
    if not node or node:type() ~= "identifier" then
        return nil
    end

    return ts_utils.get_node_text(node, bufnr)
end

local function declarator_identifier_text(bufnr, node)
    if not node then
        return nil
    end

    local direct = direct_identifier_text(bufnr, node)
    if direct then
        return direct
    end

    if not declarator_wrappers[node:type()] then
        return nil
    end

    local nested = ts_utils.get_child_by_field_name(node, "declarator")
    if nested then
        return declarator_identifier_text(bufnr, nested)
    end

    -- Parser versions can differ in whether a declarator wrapper exposes its
    -- nested binding as a named field. Stay conservative and recurse only
    -- through known declarator wrapper shapes.
    for child in node:iter_children() do
        if child:named() then
            local binding = declarator_identifier_text(bufnr, child)
            if binding then
                return binding
            end
        end
    end

    return nil
end

local function initializer_binding(bufnr, node)
    local current = node and node:parent() or nil

    while current do
        local node_type = current:type()

        if node_type == "init_declarator" then
            local declarator =
                ts_utils.get_child_by_field_name(current, "declarator")
            return declarator_identifier_text(bufnr, declarator)
        end

        -- Do not walk out of the declaration/expression that owns the memory
        -- operation. Direct assignment-owned producers are handled separately;
        -- broader pointer propagation remains outside this source-fact layer.
        if node_type == "declaration"
            or node_type == "expression_statement"
            or node_type == "return_statement"
        then
            return nil
        end

        current = current:parent()
    end

    return nil
end

local function assignment_binding(bufnr, node)
    local assignment = node and node:parent() or nil
    if not assignment or assignment:type() ~= "assignment_expression" then
        return nil
    end

    local right = ts_utils.get_child_by_field_name(assignment, "right")
    if not right then
        return nil
    end

    local node_range = ts_utils.get_node_range_fields(node)
    local right_range = ts_utils.get_node_range_fields(right)
    if node:type() ~= right:type()
        or node_range.start_line ~= right_range.start_line
        or node_range.start_column ~= right_range.start_column
        or node_range.end_line ~= right_range.end_line
        or node_range.end_column ~= right_range.end_column
    then
        return nil
    end

    local left = ts_utils.get_child_by_field_name(assignment, "left")
    return direct_identifier_text(bufnr, left)
end

local function direct_call_first_argument(bufnr, node)
    local arguments = ts_utils.get_child_by_field_name(node, "arguments")
    if not arguments then
        return nil
    end

    for child in arguments:iter_children() do
        if child:named() then
            return direct_identifier_text(bufnr, child)
        end
    end

    return nil
end

local function delete_target(bufnr, node)
    local argument = ts_utils.get_child_by_field_name(node, "argument")
    if argument then
        return direct_identifier_text(bufnr, argument)
    end

    -- Keep compatibility with parser versions where delete's operand is a
    -- direct named child rather than an exposed "argument" field.
    for child in node:iter_children() do
        if child:named() then
            return direct_identifier_text(bufnr, child)
        end
    end

    return nil
end

local pointer_callable_scope_types = {
    function_definition = true,
    lambda_expression = true,
}

local function pointer_scope_id(node)
    local current = node

    while current do
        if pointer_callable_scope_types[current:type()] then
            local range = ts_utils.get_node_range_fields(current)
            return table.concat({
                "callable",
                tostring(current:type()),
                tostring(range.start_line or 0),
                tostring(range.start_column or 0),
                tostring(range.end_line or 0),
                tostring(range.end_column or 0),
            }, ":")
        end

        current = current:parent()
    end

    return "translation_unit"
end

local function make_fact(
    bufnr,
    node,
    name,
    kind,
    role,
    source,
    pointer_binding,
    pointer_target
)
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
            pointer_binding = pointer_binding,
            pointer_target = pointer_target,
            pointer_scope_id = pointer_scope_id(node),
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

        local pointer_binding
        local pointer_target

        if name == "malloc" or name == "calloc" or name == "realloc" then
            pointer_binding =
                initializer_binding(bufnr, node)
                or assignment_binding(bufnr, node)
        end

        if name == "realloc" or name == "free" then
            pointer_target = direct_call_first_argument(bufnr, node)
        end

        return make_fact(
            bufnr,
            node,
            name,
            signature.kind,
            signature.role,
            language .. "_source_memory",
            pointer_binding,
            pointer_target
        )
    end

    if language == "cpp" then
        if node_type == "new_expression" then
            return make_fact(
                bufnr,
                node,
                "new",
                "heap_allocation_site",
                "C++ new expression; construction, success and ownership not inferred",
                "cpp_source_memory",
                initializer_binding(bufnr, node)
                    or assignment_binding(bufnr, node),
                nil
            )
        end
        if node_type == "delete_expression" then
            return make_fact(
                bufnr,
                node,
                "delete",
                "heap_release_site",
                "C++ delete expression; pointer ownership and destructor effects not inferred",
                "cpp_source_memory",
                nil,
                delete_target(bufnr, node)
            )
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

    -- Record only direct source-order identity lineage. This intentionally
    -- does not model aliases, path execution, allocation success, liveness,
    -- ownership, release success or leaks.
    local direct_producers = {}

    for _, fact in ipairs(facts) do
        local metadata = fact.metadata or {}
        local pointer_scope = metadata.pointer_scope_id
            or "translation_unit"
        local scoped_producers = direct_producers[pointer_scope]

        if not scoped_producers then
            scoped_producers = {}
            direct_producers[pointer_scope] = scoped_producers
        end

        local pointer_target = metadata.pointer_target

        -- Resolve before publishing the current binding so same-name realloc
        -- forms can point backward rather than at the current fact itself.
        if pointer_target then
            local predecessor = scoped_producers[pointer_target]
            if predecessor then
                metadata.pointer_predecessor_id = predecessor.id
                metadata.pointer_predecessor_relation =
                    "direct_source_identity"
            end
        end

        local pointer_binding = metadata.pointer_binding
        if pointer_binding then
            scoped_producers[pointer_binding] = fact
        end
    end

    return facts
end

return M
