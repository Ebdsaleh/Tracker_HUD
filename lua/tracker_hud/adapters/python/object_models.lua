-- lua/tracker_hud/adapters/python/object_models.lua
--
-- Static Python object/model facts derived from the current source file.
--
-- This is intentionally conservative. It does not execute Python and it does
-- not claim runtime truth. It only models simple facts visible in the file up
-- to the current cursor line:
--
--   class fields assigned as self.field = ...
--   annotated model fields: name: Type = default
--   dataclass construction from annotated fields
--   object construction: name = ClassName(...)
--   simple mutator calls: name.method(...)
--   direct instance writes: name.field = ...

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


local function parse_parameter_entries(parameter_text)
    local params = {}

    for _, param in ipairs(split_args(parameter_text or "")) do
        local default = nil
        local name_part = param
        local equals_at = param:find("=", 1, true)

        if equals_at then
            name_part = param:sub(1, equals_at - 1)
            default = trim(param:sub(equals_at + 1))
        end

        local name = trim(name_part)
        name = name:gsub("^%*+", "")
        name = name:gsub(":.*$", "")
        name = trim(name)

        if name ~= "" then
            table.insert(params, {
                name = name,
                default = default,
            })
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
            field_order = {},
            methods = {},
            dataclass = false,
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
            synthesized = false,
        }
        class.methods[name] = method
    end

    return method
end


local function ensure_field(class, field_name, line_number)
    local field = class.fields[field_name]

    if not field then
        field = {
            name = field_name,
            first_line = line_number,
            initial_expr = nil,
            annotation = nil,
            declared_default = nil,
            writers = {},
        }
        class.fields[field_name] = field
        table.insert(class.field_order, field_name)
    end

    return field
end


local function add_field_effect(class, method, field_name, expr, line_number)
    local field = ensure_field(class, field_name, line_number)

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


local function add_declared_field(class, field_name, annotation, default, line_number)
    local field = ensure_field(class, field_name, line_number)

    if type(annotation) == "string" and annotation ~= "" then
        field.annotation = trim(annotation)
    end

    if type(default) == "string" and default ~= "" then
        field.declared_default = trim(default)

        if field.initial_expr == nil then
            field.initial_expr = field.declared_default
        end
    end

    if class.dataclass then
        field.writers.__init__ = true
    end
end


local function stripped_is_dataclass_decorator(stripped)
    return stripped == "@dataclass"
        or stripped:match("^@dataclass%s*%(") ~= nil
        or stripped == "@dataclasses.dataclass"
        or stripped:match("^@dataclasses%.dataclass%s*%(") ~= nil
end


local function maybe_parse_annotated_field(stripped)
    local field_name, annotation, default =
        stripped:match("^([%w_]+)%s*:%s*(.-)%s*=%s*(.+)$")

    if field_name and annotation and default then
        return field_name, trim(annotation), trim(default)
    end

    field_name, annotation = stripped:match("^([%w_]+)%s*:%s*(.+)$")

    if field_name and annotation then
        return field_name, trim(annotation), nil
    end

    return nil, nil, nil
end


local function synthesize_dataclass_init(class)
    if not class.dataclass or class.methods.__init__ then
        return
    end

    local params = {
        { name = "self" },
    }

    local method = {
        name = "__init__",
        params = params,
        start_line = class.start_line,
        indent = class.indent + 4,
        effects = {},
        synthesized = true,
    }

    for _, field_name in ipairs(class.field_order or {}) do
        local field = class.fields[field_name]

        if field then
            table.insert(params, {
                name = field.name,
                default = field.declared_default,
            })

            table.insert(method.effects, {
                field = field.name,
                expr = field.name,
                line = field.first_line,
            })

            field.writers.__init__ = true
        end
    end

    class.methods.__init__ = method
end


local function synthesize_dataclass_methods(classes)
    for _, class_name in ipairs(sorted_keys(classes)) do
        synthesize_dataclass_init(classes[class_name])
    end
end


local function scan_classes(lines)
    local classes = {}
    local current_class = nil
    local current_method = nil
    local pending_dataclass = false

    for line_number, line in ipairs(lines or {}) do
        local indent = leading_indent(line)
        local stripped = trim(line)
        local class_name = stripped:match("^class%s+([%w_]+)")
        local method_name, method_params = stripped:match("^def%s+([%w_]+)%s*%((.-)%)%s*:")

        if stripped:sub(1, 1) == "@" then
            if stripped_is_dataclass_decorator(stripped) then
                pending_dataclass = true
            end
        elseif class_name then
            current_class = ensure_class(classes, class_name, line_number, indent)
            current_class.dataclass = pending_dataclass == true
            pending_dataclass = false
            current_method = nil
        elseif current_class and not is_blank_or_comment(line) and indent <= current_class.indent then
            current_class = nil
            current_method = nil
            pending_dataclass = false
        elseif not is_blank_or_comment(line) then
            pending_dataclass = false
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
            local field_name, expr = stripped:match("^self%.([%w_]+)%s*=%s*(.+)$")

            if field_name and expr then
                add_field_effect(current_class, current_method, field_name, trim(expr), line_number)
            end
        elseif current_class and not current_method and indent > current_class.indent then
            local field_name, annotation, default = maybe_parse_annotated_field(stripped)

            if field_name then
                add_declared_field(current_class, field_name, annotation, default, line_number)
            end
        end
    end

    synthesize_dataclass_methods(classes)

    return classes
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

    for _, param in ipairs(params or {}) do
        local param_name = type(param) == "table" and param.name or tostring(param)
        local default = type(param) == "table" and param.default or nil

        if param_name ~= "self" then
            if parsed.keyword[param_name] ~= nil then
                bound[param_name] = parsed.keyword[param_name]
            elseif parsed.positional[arg_index] ~= nil then
                bound[param_name] = parsed.positional[arg_index]
                arg_index = arg_index + 1
            elseif default ~= nil and default ~= "" then
                bound[param_name] = default
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


local function add_object_change(object, opts)
    if type(object) ~= "table" or type(opts) ~= "table" then
        return
    end

    object.state[opts.field] = opts.value
    object.last_line = opts.line or object.last_line

    table.insert(object.changes, {
        line = opts.line,
        method = opts.method,
        field = opts.field,
        value = opts.value,
        kind = opts.kind,
    })
end


local function apply_method_effects(object, class, method, args, source_line)
    if not object or not class or not method then
        return
    end

    local bound = bind_arguments(method.params, args)
    local change_kind = "method write"

    if method.name == "__init__" then
        change_kind = "constructor write"
    end

    for _, effect in ipairs(method.effects or {}) do
        add_object_change(object, {
            line = source_line,
            method = method.name,
            field = effect.field,
            value = resolve_expr(effect.expr, bound),
            kind = change_kind,
        })
    end
end


local function apply_direct_field_write(object, field_name, expr, line_number)
    if not object or not field_name or not expr then
        return
    end

    add_object_change(object, {
        line = line_number,
        method = "<direct>",
        field = field_name,
        value = trim(expr),
        kind = "direct write",
    })
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
                    local write_object, field_name, expr = stripped:match("^([%w_]+)%.([%w_]+)%s*=%s*(.+)$")
                    local write_target = write_object and objects[write_object] or nil

                    if write_target then
                        apply_direct_field_write(
                            write_target,
                            field_name,
                            expr,
                            line_number
                        )
                    end
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


local function field_label(field)
    local label = field.name

    if field.annotation then
        label = label .. " : " .. field.annotation
    end

    if field.initial_expr then
        label = label .. " initial " .. field.initial_expr
    end

    local writers = sorted_keys(field.writers)

    if #writers > 0 then
        label = label .. " changed by " .. table.concat(writers, ", ")
    end

    return label
end


local function method_effect_label(method)
    local parts = {}

    for _, effect in ipairs(method.effects or {}) do
        table.insert(parts, tostring(effect.field) .. " = " .. tostring(effect.expr))
    end

    if #parts == 0 then
        return nil
    end

    if method.name == "__init__" and method.synthesized then
        return "dataclass __init__ initializes " .. table.concat(parts, ", ")
    end

    if method.name == "__init__" then
        return "__init__ initializes " .. table.concat(parts, ", ")
    end

    return method.name .. " mutates " .. table.concat(parts, ", ")
end


local function class_event(class)
    local operands = {}
    local operand_specs = {}

    if class.dataclass then
        add_operand(operands, operand_specs, "model kind", "dataclass")
    end

    for _, field_name in ipairs(sorted_keys(class.fields)) do
        add_operand(
            operands,
            operand_specs,
            "field",
            field_label(class.fields[field_name])
        )
    end

    for _, method_name in ipairs(sorted_keys(class.methods)) do
        local label = method_effect_label(class.methods[method_name])

        if label then
            add_operand(operands, operand_specs, "method effect", label)
        end
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


local function object_event(object, cursor_line)
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
        add_operand(
            operands,
            operand_specs,
            "current state",
            field_name .. " = " .. tostring(object.state[field_name])
        )
    end

    for _, change in ipairs(object.changes or {}) do
        add_operand(
            operands,
            operand_specs,
            change.kind or "change",
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
        role = object.class_name .. " state known from file up to cursor",
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
        table.insert(events, object_event(objects[object_name], cursor_line))
    end

    return events
end


return M
