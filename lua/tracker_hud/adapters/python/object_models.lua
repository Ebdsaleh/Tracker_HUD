-- lua/tracker_hud/adapters/python/object_models.lua
--
-- Static Python object/model facts derived from the current source file.
--
-- This is intentionally conservative. It does not execute Python and it does
-- not claim runtime truth. It only models simple facts visible in the file up
-- to the current cursor line:
--
--   class fields assigned as self.field = ...
--   object construction: name = ClassName(...)
--   simple mutator calls: name.method(...)

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


local function parse_parameter_names(parameter_text)
    local params = {}

    for _, param in ipairs(split_args(parameter_text or "")) do
        local name = trim(param:gsub("=.*$", ""))
        name = name:gsub("^%*+", "")
        name = name:gsub(":.*$", "")
        name = trim(name)

        if name ~= "" then
            table.insert(params, name)
        end
    end

    return params
end


local function count_keys(tbl)
    local count = 0

    for _ in pairs(tbl or {}) do
        count = count + 1
    end

    return count
end


local function sorted_keys(tbl)
    local keys = {}

    for key in pairs(tbl or {}) do
        table.insert(keys, key)
    end

    table.sort(keys)

    return keys
end


local function ensure_class(classes, name, line_number, indent)
    local class = classes[name]

    if not class then
        class = {
            name = name,
            start_line = line_number,
            indent = indent,
            fields = {},
            methods = {},
        }
        classes[name] = class
    end

    return class
end


local function ensure_method(class, name, params, line_number, indent)
    local method = class.methods[name]

    if not method then
        method = {
            name = name,
            params = params or {},
            start_line = line_number,
            indent = indent,
            effects = {},
        }
        class.methods[name] = method
    end

    return method
end


local function add_field_effect(class, method, field_name, expr, line_number)
    local field = class.fields[field_name]

    if not field then
        field = {
            name = field_name,
            first_line = line_number,
            initial_expr = nil,
            writers = {},
        }
        class.fields[field_name] = field
    end

    if method.name == "__init__" and field.initial_expr == nil then
        field.initial_expr = expr
    end

    field.writers[method.name] = true

    table.insert(method.effects, {
        field = field_name,
        expr = expr,
        line = line_number,
    })
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
                parse_parameter_names(method_params),
                line_number,
                indent
            )
        elseif current_method and not is_blank_or_comment(line) and indent <= current_method.indent then
            current_method = nil
        end

        if current_class and current_method then
            local field_name, expr = stripped:match("^self%.([%w_]+)%s*=%s*(.+)$")

            if field_name and expr then
                add_field_effect(current_class, current_method, field_name, trim(expr), line_number)
            end
        end
    end

    return classes
end


local function bind_arguments(params, args)
    local bound = {}
    local arg_index = 1

    for _, param in ipairs(params or {}) do
        if param ~= "self" then
            bound[param] = args[arg_index]
            arg_index = arg_index + 1
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


local function apply_method_effects(object, class, method, args, source_line)
    if not object or not class or not method then
        return
    end

    local bound = bind_arguments(method.params, args)

    for _, effect in ipairs(method.effects or {}) do
        local value = resolve_expr(effect.expr, bound)

        object.state[effect.field] = value
        object.last_line = source_line or object.last_line

        table.insert(object.changes, {
            line = source_line,
            method = method.name,
            field = effect.field,
            value = value,
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
                end
            end
        end
    end

    return objects
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


local function class_event(class)
    local operands = {}
    local operand_specs = {}

    for _, field_name in ipairs(sorted_keys(class.fields)) do
        local field = class.fields[field_name]
        local writers = sorted_keys(field.writers)
        local label = field_name

        if field.initial_expr then
            label = label .. " initial " .. field.initial_expr
        end

        if #writers > 0 then
            label = label .. " changed by " .. table.concat(writers, ", ")
        end

        add_operand(operands, operand_specs, "field", label)
    end

    return {
        id = "event:python:data_model:class:" .. class.name,
        kind = "python_data_model",
        category = "data model",
        name = class.name,
        role = "class model exposes " .. tostring(count_keys(class.fields)) .. " field(s)",
        source = "python_object_models",
        source_line = class.start_line,
        source_column = 0,
        metadata = {
            operands = operands,
            operand_specs = operand_specs,
        },
    }
end


local function object_event(object)
    local operands = {}
    local operand_specs = {}

    add_operand(operands, operand_specs, "class", object.class_name)
    add_operand(operands, operand_specs, "created", object.construction)

    for _, field_name in ipairs(sorted_keys(object.state)) do
        add_operand(
            operands,
            operand_specs,
            "state",
            field_name .. " = " .. tostring(object.state[field_name])
        )
    end

    for _, change in ipairs(object.changes or {}) do
        add_operand(
            operands,
            operand_specs,
            "change",
            tostring(change.method)
                .. " -> "
                .. tostring(change.field)
                .. " = "
                .. tostring(change.value)
                .. " at line "
                .. tostring(change.line or "?")
        )
    end

    return {
        id = "event:python:object:" .. object.name,
        kind = "python_object_state",
        category = "object",
        name = object.name,
        role = object.class_name .. " state known from file",
        source = "python_object_models",
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
        table.insert(events, class_event(classes[class_name]))
    end

    for _, object_name in ipairs(sorted_keys(objects)) do
        table.insert(events, object_event(objects[object_name]))
    end

    return events
end


return M
