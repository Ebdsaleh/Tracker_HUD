-- lua/tracker_hud/adapters/python/object_model_collections.lua
--
-- Static Python collection/object-container facts.
--
-- This is intentionally conservative and line-based. It does not execute
-- Python. It only reports simple collection state visible in the current file
-- up to the cursor position.

local M = {}


local function trim(value)
    if type(value) ~= "string" then
        return ""
    end

    return (value:gsub("^%s+", ""):gsub("%s+$", ""))
end


local function leading_indent(line)
    local spaces = line:match("^(%s*)") or ""
    return #spaces
end


local function is_blank_or_comment(line)
    local stripped = trim(line)
    return stripped == "" or stripped:sub(1, 1) == "#"
end


local function split_args(text)
    local result = {}
    local current = {}
    local quote = nil
    local escape = false
    local depth = 0

    text = text or ""

    for index = 1, #text do
        local ch = text:sub(index, index)

        if escape then
            table.insert(current, ch)
            escape = false
        elseif quote then
            table.insert(current, ch)

            if ch == "\\" then
                escape = true
            elseif ch == quote then
                quote = nil
            end
        else
            if ch == "'" or ch == '"' then
                quote = ch
                table.insert(current, ch)
            elseif ch == "(" or ch == "[" or ch == "{" then
                depth = depth + 1
                table.insert(current, ch)
            elseif ch == ")" or ch == "]" or ch == "}" then
                if depth > 0 then
                    depth = depth - 1
                end
                table.insert(current, ch)
            elseif ch == "," and depth == 0 then
                table.insert(result, trim(table.concat(current)))
                current = {}
            else
                table.insert(current, ch)
            end
        end
    end

    local last = trim(table.concat(current))

    if last ~= "" then
        table.insert(result, last)
    end

    return result
end


local function sorted_keys(tbl)
    local keys = {}

    for key in pairs(tbl or {}) do
        table.insert(keys, key)
    end

    table.sort(keys)

    return keys
end


local function parse_parameter_entries(parameter_text)
    local params = {}

    for _, param in ipairs(split_args(parameter_text or "")) do
        local name_part = param
        local equals_at = param:find("=", 1, true)

        if equals_at then
            name_part = param:sub(1, equals_at - 1)
        end

        local name = trim(name_part)
        name = name:gsub("^%*+", "")
        name = name:gsub(":.*$", "")
        name = trim(name)

        if name ~= "" then
            table.insert(params, name)
        end
    end

    return params
end


local function parse_call_arguments(args)
    local parsed = {
        positional = {},
        keyword = {},
    }

    for _, arg in ipairs(args or {}) do
        local key, value = arg:match("^([%w_]+)%s*=%s*(.+)$")

        if key and value then
            parsed.keyword[key] = trim(value)
        else
            table.insert(parsed.positional, arg)
        end
    end

    return parsed
end


local function bind_arguments(params, args)
    local bound = {}
    local parsed = parse_call_arguments(args)
    local arg_index = 1

    for _, param_name in ipairs(params or {}) do
        if param_name ~= "self" then
            if parsed.keyword[param_name] ~= nil then
                bound[param_name] = parsed.keyword[param_name]
            elseif parsed.positional[arg_index] ~= nil then
                bound[param_name] = parsed.positional[arg_index]
                arg_index = arg_index + 1
            end
        end
    end

    return bound
end


local function resolve_expr(expr, bound)
    expr = trim(expr)

    if bound and bound[expr] ~= nil and bound[expr] ~= "" then
        return bound[expr]
    end

    return expr
end


local function add_operand(operands, operand_specs, role, text)
    if type(text) ~= "string" or text == "" then
        return
    end

    local index = #operands + 1

    table.insert(operands, { text = text })
    table.insert(operand_specs, {
        index = index,
        role = role,
    })
end


local function ensure_class(classes, name, line_number, indent)
    local class = classes[name]

    if not class then
        class = {
            name = name,
            start_line = line_number,
            indent = indent,
            collections = {},
            methods = {},
        }
        classes[name] = class
    end

    return class
end


local function ensure_collection(class, field_name, kind, line_number)
    local collection = class.collections[field_name]

    if not collection then
        collection = {
            name = field_name,
            kind = kind or "collection",
            init_line = line_number,
            effects = {},
        }
        class.collections[field_name] = collection
    elseif kind and collection.kind == "collection" then
        collection.kind = kind
    end

    return collection
end


local function ensure_method(class, method_name, params, line_number, indent)
    local method = class.methods[method_name]

    if not method then
        method = {
            name = method_name,
            params = params or {},
            start_line = line_number,
            indent = indent,
            effects = {},
        }
        class.methods[method_name] = method
    end

    return method
end


local function collection_kind_from_expr(expr)
    expr = trim(expr)

    if expr == "[]" or expr:match("^list%s*%(") then
        return "list"
    end

    if expr == "{}" or expr:match("^dict%s*%(") then
        return "dict"
    end

    if expr:match("^set%s*%(") then
        return "set"
    end

    return nil
end


local function add_method_effect(class, method, effect)
    if not class or not method or type(effect) ~= "table" then
        return
    end

    if effect.field then
        local kind = effect.kind

        if kind == "append" or kind == "extend" then
            kind = "list"
        elseif kind == "setitem" then
            kind = "dict"
        end

        ensure_collection(class, effect.field, kind, effect.line)
    end

    table.insert(method.effects, effect)
end


local function scan_classes(lines)
    local classes = {}
    local current_class = nil
    local current_method = nil

    for line_number, line in ipairs(lines or {}) do
        local indent = leading_indent(line)
        local stripped = trim(line)
        local class_name = stripped:match("^class%s+([%w_]+)")
        local method_name, method_params = stripped:match("^def%s+([%w_]+)%s*%((.-)%)%s*:")

        if class_name then
            current_class = ensure_class(classes, class_name, line_number, indent)
            current_method = nil
        elseif current_class and not is_blank_or_comment(line) and indent <= current_class.indent then
            current_class = nil
            current_method = nil
        end

        if current_class and method_name and indent > current_class.indent then
            current_method = ensure_method(
                current_class,
                method_name,
                parse_parameter_entries(method_params),
                line_number,
                indent
            )
        elseif current_method and not is_blank_or_comment(line) and indent <= current_method.indent then
            current_method = nil
        end

        if current_class and current_method then
            local init_field, init_expr = stripped:match("^self%.([%w_]+)%s*=%s*(.+)$")
            local init_kind = init_expr and collection_kind_from_expr(init_expr) or nil

            if init_field and init_kind then
                ensure_collection(current_class, init_field, init_kind, line_number)
                add_method_effect(current_class, current_method, {
                    kind = "initialize",
                    field = init_field,
                    value = trim(init_expr),
                    line = line_number,
                })
            end

            local append_field, append_value = stripped:match("^self%.([%w_]+)%.append%s*%((.*)%)%s*$")

            if append_field then
                add_method_effect(current_class, current_method, {
                    kind = "append",
                    field = append_field,
                    value = trim(append_value),
                    line = line_number,
                })
            end

            local extend_field, extend_value = stripped:match("^self%.([%w_]+)%.extend%s*%((.*)%)%s*$")

            if extend_field then
                add_method_effect(current_class, current_method, {
                    kind = "extend",
                    field = extend_field,
                    value = trim(extend_value),
                    line = line_number,
                })
            end

            local setitem_field, setitem_key, setitem_value = stripped:match("^self%.([%w_]+)%s*%[(.+)%]%s*=%s*(.+)$")

            if setitem_field then
                add_method_effect(current_class, current_method, {
                    kind = "setitem",
                    field = setitem_field,
                    key = trim(setitem_key),
                    value = trim(setitem_value),
                    line = line_number,
                })
            end
        end
    end

    return classes
end


local function add_object_change(object, change)
    if type(object) ~= "table" or type(change) ~= "table" then
        return
    end

    table.insert(object.changes, change)
    object.last_line = change.line or object.last_line

    local field_state = object.state[change.field]

    if not field_state then
        field_state = {
            field = change.field,
            kind = change.collection_kind or "collection",
            appends = {},
            extends = {},
            items = {},
        }
        object.state[change.field] = field_state
    end

    if change.kind == "initialize" then
        field_state.initial = change.value
        field_state.kind = change.collection_kind or field_state.kind
    elseif change.kind == "append" then
        table.insert(field_state.appends, change.value)
    elseif change.kind == "extend" then
        table.insert(field_state.extends, change.value)
    elseif change.kind == "setitem" then
        field_state.items[change.key or "?"] = change.value
    end
end


local function apply_method_effects(object, class, method, args, source_line)
    if not object or not class or not method then
        return
    end

    local bound = bind_arguments(method.params, args)

    for _, effect in ipairs(method.effects or {}) do
        local collection = class.collections[effect.field] or {}
        add_object_change(object, {
            line = source_line,
            method = method.name,
            kind = effect.kind,
            field = effect.field,
            collection_kind = collection.kind,
            key = effect.key and resolve_expr(effect.key, bound) or nil,
            value = resolve_expr(effect.value or "", bound),
        })
    end
end


local function scan_objects(lines, classes, cursor_line)
    local objects = {}
    local max_line = cursor_line or #(lines or {})

    for line_number = 1, math.min(max_line, #(lines or {})) do
        local stripped = trim(lines[line_number] or "")

        if stripped ~= "" and stripped:sub(1, 1) ~= "#" then
            local object_name, class_name, arg_text = stripped:match("^([%w_]+)%s*=%s*([%w_]+)%s*%((.*)%)%s*$")

            if object_name and class_name and classes[class_name] then
                local class = classes[class_name]
                local object = {
                    name = object_name,
                    class_name = class_name,
                    construction = class_name .. "(" .. trim(arg_text or "") .. ")",
                    start_line = line_number,
                    last_line = line_number,
                    state = {},
                    changes = {},
                }

                objects[object_name] = object
                apply_method_effects(
                    object,
                    class,
                    class.methods.__init__,
                    split_args(arg_text or ""),
                    line_number
                )
            else
                local call_object, method_name, call_args = stripped:match("^([%w_]+)%.([%w_]+)%s*%((.*)%)%s*$")
                local object = call_object and objects[call_object] or nil
                local class = object and classes[object.class_name] or nil
                local method = class and class.methods[method_name] or nil

                if object and class and method then
                    apply_method_effects(
                        object,
                        class,
                        method,
                        split_args(call_args or ""),
                        line_number
                    )
                else
                    local direct_object, field_name, append_value = stripped:match("^([%w_]+)%.([%w_]+)%.append%s*%((.*)%)%s*$")
                    local direct_target = direct_object and objects[direct_object] or nil

                    if direct_target then
                        add_object_change(direct_target, {
                            line = line_number,
                            method = "<direct>",
                            kind = "append",
                            field = field_name,
                            collection_kind = "list",
                            value = trim(append_value),
                        })
                    else
                        local write_object, write_field, write_key, write_value = stripped:match("^([%w_]+)%.([%w_]+)%s*%[(.+)%]%s*=%s*(.+)$")
                        local write_target = write_object and objects[write_object] or nil

                        if write_target then
                            add_object_change(write_target, {
                                line = line_number,
                                method = "<direct>",
                                kind = "setitem",
                                field = write_field,
                                collection_kind = "dict",
                                key = trim(write_key),
                                value = trim(write_value),
                            })
                        end
                    end
                end
            end
        end
    end

    return objects
end


local function collection_effect_label(effect)
    if effect.kind == "initialize" then
        return tostring(effect.field) .. " initialized as " .. tostring(effect.value)
    end

    if effect.kind == "append" then
        return tostring(effect.field) .. ".append(" .. tostring(effect.value) .. ")"
    end

    if effect.kind == "extend" then
        return tostring(effect.field) .. ".extend(" .. tostring(effect.value) .. ")"
    end

    if effect.kind == "setitem" then
        return tostring(effect.field)
            .. "["
            .. tostring(effect.key)
            .. "] = "
            .. tostring(effect.value)
    end

    return nil
end


local function class_collection_event(class)
    if type(class) ~= "table" or next(class.collections or {}) == nil then
        return nil
    end

    local operands = {}
    local operand_specs = {}

    for _, field_name in ipairs(sorted_keys(class.collections)) do
        local collection = class.collections[field_name]
        add_operand(
            operands,
            operand_specs,
            "collection field",
            tostring(field_name) .. " : " .. tostring(collection.kind)
        )
    end

    for _, method_name in ipairs(sorted_keys(class.methods)) do
        local method = class.methods[method_name]

        for _, effect in ipairs(method.effects or {}) do
            local label = collection_effect_label(effect)

            if label then
                add_operand(
                    operands,
                    operand_specs,
                    "collection effect",
                    tostring(method_name) .. " -> " .. label
                )
            end
        end
    end

    return {
        id = "event:python:data_model_collection:class:" .. class.name,
        kind = "python_collection_model",
        category = "data model",
        name = class.name,
        role = "collection fields visible from file",
        source = "python_object_model_collections",
        source_line = class.start_line,
        source_column = 0,
        metadata = {
            operands = operands,
            operand_specs = operand_specs,
        },
    }
end


local function object_collection_event(object, cursor_line)
    if type(object) ~= "table" or next(object.state or {}) == nil then
        return nil
    end

    local operands = {}
    local operand_specs = {}

    add_operand(operands, operand_specs, "class", object.class_name)
    add_operand(operands, operand_specs, "created", object.construction)
    add_operand(
        operands,
        operand_specs,
        "known through",
        "cursor line " .. tostring(cursor_line or object.last_line)
    )

    for _, field_name in ipairs(sorted_keys(object.state)) do
        local field_state = object.state[field_name]
        add_operand(
            operands,
            operand_specs,
            "collection state",
            tostring(field_name) .. " : " .. tostring(field_state.kind)
        )

        if field_state.initial then
            add_operand(
                operands,
                operand_specs,
                "initial state",
                tostring(field_name) .. " = " .. tostring(field_state.initial)
            )
        end

        for _, value in ipairs(field_state.appends or {}) do
            add_operand(
                operands,
                operand_specs,
                "appended",
                tostring(field_name) .. " += " .. tostring(value)
            )
        end

        for _, value in ipairs(field_state.extends or {}) do
            add_operand(
                operands,
                operand_specs,
                "extended",
                tostring(field_name) .. " extend " .. tostring(value)
            )
        end

        for _, key in ipairs(sorted_keys(field_state.items or {})) do
            add_operand(
                operands,
                operand_specs,
                "item state",
                tostring(field_name)
                    .. "["
                    .. tostring(key)
                    .. "] = "
                    .. tostring(field_state.items[key])
            )
        end
    end

    for _, change in ipairs(object.changes or {}) do
        local label = collection_effect_label(change)

        if label then
            add_operand(
                operands,
                operand_specs,
                "collection write",
                tostring(change.method)
                    .. " -> "
                    .. label
                    .. " at line "
                    .. tostring(change.line or "?")
            )
        end
    end

    return {
        id = "event:python:collection_object:" .. object.name,
        kind = "python_collection_object_state",
        category = "object",
        name = object.name,
        role = object.class_name .. " collection state known from file up to cursor",
        source = "python_object_model_collections",
        source_line = object.start_line,
        source_column = 0,
        source_end_line = object.last_line,
        source_end_column = 0,
        metadata = {
            operands = operands,
            operand_specs = operand_specs,
        },
    }
end


function M.collect_events(context)
    local events = {}

    if type(context) ~= "table"
        or type(context.targets) ~= "table"
        or context.targets.syntax ~= "python"
    then
        return events
    end

    local ok_buf, bufnr = pcall(vim.api.nvim_get_current_buf)

    if not ok_buf or not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
        return events
    end

    if vim.bo[bufnr].filetype ~= "python" then
        return events
    end

    local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local cursor_line = context.cursor and tonumber(context.cursor.line) or #lines
    local classes = scan_classes(lines)
    local objects = scan_objects(lines, classes, cursor_line)

    for _, class_name in ipairs(sorted_keys(classes)) do
        local event = class_collection_event(classes[class_name])

        if event then
            table.insert(events, event)
        end
    end

    for _, object_name in ipairs(sorted_keys(objects)) do
        local event = object_collection_event(objects[object_name], cursor_line)

        if event then
            table.insert(events, event)
        end
    end

    return events
end


return M
