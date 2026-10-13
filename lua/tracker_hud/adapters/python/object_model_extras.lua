-- lua/tracker_hud/adapters/python/object_model_extras.lua
--
-- Extra static Python model facts that are intentionally kept separate from
-- the primary object_models collector until the patterns are physically
-- validated in Neovim.
--
-- This module is conservative and line-based. It only reports facts visible in
-- the current file up to the cursor position.

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
        if parsed.keyword[param_name] ~= nil then
            bound[param_name] = parsed.keyword[param_name]
        elseif parsed.positional[arg_index] ~= nil then
            bound[param_name] = parsed.positional[arg_index]
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


local function resolve_args(args, bound)
    local result = {}

    for _, arg in ipairs(args or {}) do
        local key, value = arg:match("^([%w_]+)%s*=%s*(.+)$")

        if key and value then
            table.insert(result, key .. "=" .. resolve_expr(value, bound))
        else
            table.insert(result, resolve_expr(arg, bound))
        end
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


local function scan_classes(lines)
    local classes = {}
    local current_class = nil

    for line_number, line in ipairs(lines or {}) do
        local indent = leading_indent(line)
        local stripped = trim(line)
        local class_name = stripped:match("^class%s+([%w_]+)")

        if class_name then
            current_class = {
                name = class_name,
                start_line = line_number,
                indent = indent,
                attributes = {},
            }
            classes[class_name] = current_class
        elseif current_class and not is_blank_or_comment(line) and indent <= current_class.indent then
            current_class = nil
        elseif current_class and indent > current_class.indent then
            local attr_name, attr_expr = stripped:match("^([%w_]+)%s*=%s*(.+)$")

            if attr_name and attr_expr then
                table.insert(current_class.attributes, {
                    name = attr_name,
                    expr = trim(attr_expr),
                    line = line_number,
                })
            end
        end
    end

    return classes
end


local function scan_factories(lines, classes)
    local factories = {}
    local current_function = nil

    for line_number, line in ipairs(lines or {}) do
        local indent = leading_indent(line)
        local stripped = trim(line)
        local function_name, params = stripped:match("^def%s+([%w_]+)%s*%((.-)%)%s*:")

        if function_name and indent == 0 then
            current_function = {
                name = function_name,
                params = parse_parameter_entries(params),
                start_line = line_number,
                indent = indent,
            }
        elseif current_function and not is_blank_or_comment(line) and indent <= current_function.indent then
            current_function = nil
        end

        if current_function then
            local class_name, arg_text = stripped:match("^return%s+([%w_]+)%s*%((.*)%)%s*$")

            if class_name and classes[class_name] then
                factories[current_function.name] = {
                    name = current_function.name,
                    params = current_function.params,
                    class_name = class_name,
                    args = split_args(arg_text or ""),
                    start_line = current_function.start_line,
                    return_line = line_number,
                }
            end
        end
    end

    return factories
end


local function scan_factory_objects(lines, factories, cursor_line)
    local objects = {}
    local max_line = cursor_line or #(lines or {})

    for line_number = 1, math.min(max_line, #(lines or {})) do
        local stripped = trim(lines[line_number] or "")
        local object_name, factory_name, arg_text =
            stripped:match("^([%w_]+)%s*=%s*([%w_]+)%s*%((.*)%)%s*$")
        local factory = factory_name and factories[factory_name] or nil

        if object_name and factory then
            local bound = bind_arguments(factory.params, split_args(arg_text or ""))
            local constructor_args = resolve_args(factory.args, bound)

            table.insert(objects, {
                name = object_name,
                factory_name = factory.name,
                factory_call = factory.name .. "(" .. trim(arg_text or "") .. ")",
                class_name = factory.class_name,
                construction = factory.class_name .. "(" .. table.concat(constructor_args, ", ") .. ")",
                source_line = line_number,
                factory_line = factory.start_line,
                return_line = factory.return_line,
            })
        end
    end

    return objects
end


local function class_attribute_event(class)
    if type(class) ~= "table" or #(class.attributes or {}) == 0 then
        return nil
    end

    local operands = {}
    local operand_specs = {}

    for _, attr in ipairs(class.attributes or {}) do
        add_operand(
            operands,
            operand_specs,
            "class attribute",
            tostring(attr.name) .. " = " .. tostring(attr.expr)
        )
    end

    return {
        id = "event:python:data_model_extra:class_attrs:" .. class.name,
        kind = "python_data_model_extra",
        category = "data model",
        name = class.name,
        role = "class attributes visible from file",
        source = "python_object_model_extras",
        source_line = class.start_line,
        source_column = 0,
        metadata = {
            operands = operands,
            operand_specs = operand_specs,
        },
    }
end


local function factory_event(factory)
    local operands = {}
    local operand_specs = {}

    add_operand(operands, operand_specs, "returns", factory.class_name)
    add_operand(
        operands,
        operand_specs,
        "constructor",
        factory.class_name .. "(" .. table.concat(factory.args or {}, ", ") .. ")"
    )

    for _, param in ipairs(factory.params or {}) do
        add_operand(operands, operand_specs, "parameter", param)
    end

    return {
        id = "event:python:factory:" .. factory.name,
        kind = "python_factory_model",
        category = "factory",
        name = factory.name,
        role = "factory returns " .. tostring(factory.class_name),
        source = "python_object_model_extras",
        source_line = factory.start_line,
        source_column = 0,
        source_end_line = factory.return_line,
        source_end_column = 0,
        metadata = {
            operands = operands,
            operand_specs = operand_specs,
        },
    }
end


local function factory_object_event(object, cursor_line)
    local operands = {}
    local operand_specs = {}

    add_operand(operands, operand_specs, "factory", object.factory_name)
    add_operand(operands, operand_specs, "factory call", object.factory_call)
    add_operand(operands, operand_specs, "class", object.class_name)
    add_operand(operands, operand_specs, "created", object.construction)
    add_operand(
        operands,
        operand_specs,
        "known through",
        "cursor line " .. tostring(cursor_line or object.source_line)
    )

    return {
        id = "event:python:factory_object:" .. object.name,
        kind = "python_factory_object_state",
        category = "object",
        name = object.name,
        role = object.class_name .. " object created through factory",
        source = "python_object_model_extras",
        source_line = object.source_line,
        source_column = 0,
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
    local factories = scan_factories(lines, classes)
    local factory_objects = scan_factory_objects(lines, factories, cursor_line)

    for _, class_name in ipairs(sorted_keys(classes)) do
        local event = class_attribute_event(classes[class_name])

        if event then
            table.insert(events, event)
        end
    end

    for _, factory_name in ipairs(sorted_keys(factories)) do
        table.insert(events, factory_event(factories[factory_name]))
    end

    for _, object in ipairs(factory_objects) do
        table.insert(events, factory_object_event(object, cursor_line))
    end

    return events
end


return M
