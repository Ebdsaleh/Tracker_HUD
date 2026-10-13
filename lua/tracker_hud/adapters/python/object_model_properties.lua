-- lua/tracker_hud/adapters/python/object_model_properties.lua
--
-- Static Python @property / setter facts for Tracker_HUD.
--
-- This is intentionally conservative and line-based. It does not execute
-- Python. It reports simple property relationships visible in the current
-- source file up to the cursor line.

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


local function ensure_class(classes, class_name, line_number, indent)
    local class = classes[class_name]

    if not class then
        class = {
            name = class_name,
            start_line = line_number,
            indent = indent,
            properties = {},
        }
        classes[class_name] = class
    end

    return class
end


local function ensure_property(class, property_name)
    local property = class.properties[property_name]

    if not property then
        property = {
            name = property_name,
            getter_line = nil,
            setter_line = nil,
            read_field = nil,
            write_field = nil,
            setter_value_name = nil,
        }
        class.properties[property_name] = property
    end

    return property
end


local function scan_property_body(lines, start_index, method_indent)
    local body = {}

    for line_number = start_index + 1, #(lines or {}) do
        local line = lines[line_number] or ""
        local indent = leading_indent(line)
        local stripped = trim(line)

        if not is_blank_or_comment(line) and indent <= method_indent then
            break
        end

        if stripped ~= "" then
            table.insert(body, {
                line = line_number,
                text = stripped,
            })
        end
    end

    return body
end


local function scan_classes(lines)
    local classes = {}
    local current_class = nil
    local pending_property = nil
    local pending_setter = nil

    for line_number, line in ipairs(lines or {}) do
        local indent = leading_indent(line)
        local stripped = trim(line)
        local class_name = stripped:match("^class%s+([%w_]+)")
        local method_name, method_params = stripped:match("^def%s+([%w_]+)%s*%((.-)%)%s*:")

        if class_name then
            current_class = ensure_class(classes, class_name, line_number, indent)
            pending_property = nil
            pending_setter = nil
        elseif current_class and not is_blank_or_comment(line) and indent <= current_class.indent then
            current_class = nil
            pending_property = nil
            pending_setter = nil
        end

        if current_class and stripped == "@property" then
            pending_property = true
            pending_setter = nil
        elseif current_class then
            local setter_name = stripped:match("^@([%w_]+)%.setter%s*$")

            if setter_name then
                pending_property = nil
                pending_setter = setter_name
            elseif stripped:sub(1, 1) == "@" then
                pending_property = nil
                pending_setter = nil
            end
        end

        if current_class and method_name and indent > current_class.indent then
            local body = scan_property_body(lines, line_number, indent)

            if pending_property == true then
                local property = ensure_property(current_class, method_name)
                property.getter_line = line_number

                for _, entry in ipairs(body) do
                    local read_field = entry.text:match("^return%s+self%.([%w_]+)%s*$")

                    if read_field then
                        property.read_field = read_field
                        break
                    end
                end
            elseif pending_setter and pending_setter == method_name then
                local property = ensure_property(current_class, method_name)
                local params = split_args(method_params or "")
                local value_name = params[2]

                if value_name then
                    value_name = trim(value_name:gsub(":.*$", ""))
                end

                property.setter_line = line_number
                property.setter_value_name = value_name

                for _, entry in ipairs(body) do
                    local write_field, write_expr = entry.text:match("^self%.([%w_]+)%s*=%s*(.+)$")

                    if write_field and write_expr then
                        property.write_field = write_field
                        break
                    end
                end
            end

            pending_property = nil
            pending_setter = nil
        end
    end

    return classes
end


local function scan_object_classes(lines, classes, cursor_line)
    local objects = {}
    local max_line = cursor_line or #(lines or {})

    for line_number = 1, math.min(max_line, #(lines or {})) do
        local stripped = trim(lines[line_number] or "")
        local object_name, class_name = stripped:match("^([%w_]+)%s*=%s*([%w_]+)%s*%((.*)%)%s*$")

        if object_name and class_name and classes[class_name] then
            objects[object_name] = {
                name = object_name,
                class_name = class_name,
                line = line_number,
            }
        end
    end

    return objects
end


local function scan_property_writes(lines, classes, objects, cursor_line)
    local writes = {}
    local max_line = cursor_line or #(lines or {})

    for line_number = 1, math.min(max_line, #(lines or {})) do
        local stripped = trim(lines[line_number] or "")
        local object_name, property_name, expr = stripped:match("^([%w_]+)%.([%w_]+)%s*=%s*(.+)$")
        local object = object_name and objects[object_name] or nil
        local class = object and classes[object.class_name] or nil
        local property = class and class.properties[property_name] or nil

        if object and class and property and property.setter_line then
            table.insert(writes, {
                object_name = object.name,
                class_name = class.name,
                property_name = property.name,
                expr = trim(expr),
                line = line_number,
                setter_line = property.setter_line,
                write_field = property.write_field,
            })
        end
    end

    return writes
end


local function class_property_event(class)
    local property_names = sorted_keys(class.properties)

    if #property_names == 0 then
        return nil
    end

    local operands = {}
    local operand_specs = {}

    for _, property_name in ipairs(property_names) do
        local property = class.properties[property_name]
        local bits = { property.name }

        if property.read_field then
            table.insert(bits, "reads self." .. property.read_field)
        end

        if property.write_field then
            table.insert(bits, "sets self." .. property.write_field)
        end

        add_operand(
            operands,
            operand_specs,
            "property",
            table.concat(bits, " | ")
        )

        if property.getter_line then
            add_operand(
                operands,
                operand_specs,
                "getter",
                property.name .. " at line " .. tostring(property.getter_line)
            )
        end

        if property.setter_line then
            add_operand(
                operands,
                operand_specs,
                "setter",
                property.name .. " at line " .. tostring(property.setter_line)
            )
        end
    end

    return {
        id = "event:python:data_model_property:" .. class.name,
        kind = "python_property_model",
        category = "data model",
        name = class.name,
        role = "properties visible from file",
        source = "python_object_model_properties",
        source_line = class.start_line,
        source_column = 0,
        metadata = {
            operands = operands,
            operand_specs = operand_specs,
        },
    }
end


local function property_write_event(write, cursor_line)
    local operands = {}
    local operand_specs = {}

    add_operand(operands, operand_specs, "class", write.class_name)
    add_operand(operands, operand_specs, "property", write.property_name)
    add_operand(operands, operand_specs, "assigned", write.expr)

    if write.write_field then
        add_operand(
            operands,
            operand_specs,
            "setter effect",
            "self." .. write.write_field .. " = " .. write.expr
        )
    end

    add_operand(
        operands,
        operand_specs,
        "known through",
        "cursor line " .. tostring(cursor_line or write.line)
    )

    return {
        id = "event:python:property_write:"
            .. write.object_name
            .. ":"
            .. write.property_name
            .. ":"
            .. tostring(write.line),
        kind = "python_property_write",
        category = "object",
        name = write.object_name .. "." .. write.property_name,
        role = "property assignment resolved through setter",
        source = "python_object_model_properties",
        source_line = write.line,
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
    local objects = scan_object_classes(lines, classes, cursor_line)
    local property_writes = scan_property_writes(lines, classes, objects, cursor_line)

    for _, class_name in ipairs(sorted_keys(classes)) do
        local event = class_property_event(classes[class_name])

        if event then
            table.insert(events, event)
        end
    end

    for _, write in ipairs(property_writes) do
        table.insert(events, property_write_event(write, cursor_line))
    end

    return events
end


return M
