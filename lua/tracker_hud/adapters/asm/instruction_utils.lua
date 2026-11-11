-- lua/tracker_hud/adapters/asm/instruction_utils.lua
--
-- ASM instruction parsing helpers.
--
-- Tree-sitter owns syntax discovery.
-- The active adapter tells this module which Tree-sitter fields/children are
-- relevant and how those nodes should be interpreted as ASM operands.
--
-- This module does not emulate instructions.

local treesitter_utils = require("tracker_hud.treesitter_utils")
local memory_address = require("tracker_hud.low_level.memory_address")
local address_size = require("tracker_hud.low_level.address_size")

local M = {}


local function normalize_text(text)
    if type(text) ~= "string" then
        return nil
    end

    text = text:gsub("^%s+", ""):gsub("%s+$", "")

    if text == "" then
        return nil
    end

    return text
end


local function node_text(bufnr, node)
    if not node then
        return nil
    end

    return normalize_text(
        treesitter_utils.get_node_text(
            node,
            bufnr
        )
    )
end


local function get_construct_spec(adapter, node_type)
    if type(adapter) ~= "table"
        or type(adapter.construct_specs) ~= "table"
        or type(node_type) ~= "string"
        or node_type == ""
    then
        return nil
    end

    local spec = adapter.construct_specs[node_type]

    if type(spec) ~= "table" then
        return nil
    end

    return spec
end


local function get_syntax(spec)
    if type(spec) ~= "table"
        or type(spec.syntax) ~= "table"
    then
        return {}
    end

    return spec.syntax
end


local function get_syntax_field(spec, key)
    local syntax = get_syntax(spec)
    local fields = syntax.fields

    if type(fields) ~= "table" then
        return nil
    end

    local field_name = fields[key]

    if type(field_name) == "string"
        and field_name ~= ""
    then
        return field_name
    end

    if type(field_name) == "table"
        and type(field_name.field) == "string"
        and field_name.field ~= ""
    then
        return field_name.field
    end

    return nil
end


local function get_syntax_child_spec(spec, key)
    local syntax = get_syntax(spec)
    local children = syntax.children

    if type(children) ~= "table" then
        return nil
    end

    local child_spec = children[key]

    if type(child_spec) ~= "table" then
        return nil
    end

    return child_spec
end


local function list_contains(values, wanted)
    if type(values) ~= "table"
        or type(wanted) ~= "string"
    then
        return false
    end

    for _, value in ipairs(values) do
        if value == wanted then
            return true
        end
    end

    return false
end


local function node_matches_child_spec(node, child_spec)
    if not node or type(child_spec) ~= "table" then
        return false
    end

    local node_type = node:type()

    if type(child_spec.node_type) == "string"
        and child_spec.node_type == node_type
    then
        return true
    end

    return list_contains(
        child_spec.node_types,
        node_type
    )
end


local function node_has_descendant_type(node, wanted_type)
    if not node
        or type(wanted_type) ~= "string"
        or wanted_type == ""
    then
        return false
    end

    for child in node:iter_children() do
        if child:type() == wanted_type then
            return true
        end

        if node_has_descendant_type(
            child,
            wanted_type
        ) then
            return true
        end
    end

    return false
end


local function get_operand_kind_from_adapter(node, adapter)
    if not node then
        return nil
    end

    local spec = get_construct_spec(
        adapter,
        node:type()
    )

    if type(spec) ~= "table"
        or type(spec.operand) ~= "table"
    then
        return nil
    end

    local operand_spec = spec.operand
    local overrides = operand_spec.descendant_overrides

    if type(overrides) == "table" then
        for descendant_node_type, kind in pairs(overrides) do
            if type(descendant_node_type) == "string"
                and descendant_node_type ~= ""
                and type(kind) == "string"
                and kind ~= ""
                and node_has_descendant_type(
                    node,
                    descendant_node_type
                )
            then
                return kind
            end
        end
    end

    if type(operand_spec.kind) == "string"
        and operand_spec.kind ~= ""
    then
        return operand_spec.kind
    end

    return nil
end


local function get_operand_spec_from_adapter(node, adapter)
    if not node then
        return nil
    end

    local spec = get_construct_spec(
        adapter,
        node:type()
    )

    if type(spec) ~= "table"
        or type(spec.operand) ~= "table"
    then
        return nil
    end

    return spec.operand
end


local function get_memory_operand_spec(node, adapter)
    local operand_spec = get_operand_spec_from_adapter(
        node,
        adapter
    )

    if type(operand_spec) ~= "table"
        or type(operand_spec.memory) ~= "table"
    then
        return nil
    end

    return operand_spec.memory
end


local function build_register_alias_index(adapter)
    local index = {}

    if type(adapter) ~= "table" then
        return index
    end

    local families = adapter.register_families

    if type(families) == "table" then
        for _, family in pairs(families) do
            if type(family) == "table" then
                if type(family.canonical) == "string" then
                    index[family.canonical:lower()] = true
                end

                if type(family.aliases) == "table" then
                    for alias_name, alias_spec in pairs(family.aliases) do
                        if type(alias_name) == "string" then
                            index[alias_name:lower()] = true
                        end

                        if type(alias_spec) == "table"
                            and type(alias_spec.name) == "string"
                        then
                            index[alias_spec.name:lower()] = true
                        end
                    end
                end
            end
        end
    end

    local static_registers = adapter.registers
        and adapter.registers.static
        or nil

    if type(static_registers) == "table" then
        for _, register in ipairs(static_registers) do
            if type(register) == "table"
                and type(register.name) == "string"
            then
                index[register.name:lower()] = true
            end
        end
    end

    return index
end


local function get_register_bits(adapter, register_name)
    if type(adapter) ~= "table"
        or type(register_name) ~= "string"
    then
        return nil
    end

    local normalized = register_name:lower()
    local alias_index = adapter.register_alias_index

    if type(alias_index) == "table" then
        local entry = alias_index[normalized]

        if type(entry) == "table"
            and type(entry.alias) == "table"
            and type(entry.alias.bits) == "number"
        then
            return entry.alias.bits
        end
    end

    local static_registers = adapter.registers
        and adapter.registers.static
        or nil

    if type(static_registers) == "table" then
        for _, register in ipairs(static_registers) do
            if type(register) == "table"
                and type(register.name) == "string"
                and register.name:lower() == normalized
                and type(register.bits) == "number"
            then
                return register.bits
            end
        end
    end

    return nil
end


local function find_first_bracket_pair(text, memory_spec)
    if type(text) ~= "string" then
        return nil
    end

    local brackets = type(memory_spec) == "table"
        and type(memory_spec.brackets) == "table"
        and memory_spec.brackets
        or {}

    local open_token = type(brackets.open) == "string"
        and brackets.open
        or "["

    local close_token = type(brackets.close) == "string"
        and brackets.close
        or "]"

    local open_start, open_end = text:find(open_token, 1, true)

    if not open_start then
        return nil
    end

    local close_start, close_end = text:find(close_token, open_end + 1, true)

    if not close_start then
        return nil
    end

    return open_start,
        open_end,
        close_start,
        close_end
end


local function trim_with_offsets(text, start_column)
    if type(text) ~= "string" then
        return nil, start_column
    end

    local leading = text:match("^%s*") or ""
    local trailing = text:match("%s*$") or ""
    local trimmed = text:sub(
        #leading + 1,
        #text - #trailing
    )

    return trimmed, start_column + #leading
end


local function parse_memory_prefix(text, memory_spec)
    local open_start = find_first_bracket_pair(text, memory_spec)

    if not open_start or open_start <= 1 then
        return nil
    end

    local prefix_text = text:sub(1, open_start - 1)
    local words = {}

    for word in prefix_text:gmatch("[%a_][%w_]*") do
        table.insert(words, word:lower())
    end

    local size_prefixes = type(memory_spec) == "table"
        and memory_spec.size_prefixes
        or nil

    if type(size_prefixes) ~= "table" then
        return nil
    end

    for _, word in ipairs(words) do
        local size_spec = size_prefixes[word]

        if type(size_spec) == "table" then
            return {
                prefix = word,
                bits = size_spec.bits,
                label = size_spec.label or word,
            }
        end
    end

    return nil
end


local function parse_memory_prefix_from_source_context(
    bufnr,
    source_line,
    source_start_column,
    memory_spec
)
    if not bufnr
        or type(source_line) ~= "number"
        or type(source_start_column) ~= "number"
        or type(memory_spec) ~= "table"
        or type(memory_spec.size_prefixes) ~= "table"
    then
        return nil
    end

    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        source_line - 1,
        source_line,
        false
    )

    local line = lines and lines[1]
    if type(line) ~= "string" then
        return nil
    end

    -- source_start_column is zero-based. Keep only text before the ptr node,
    -- then restrict lookup to the current comma-separated operand segment.
    local before = line:sub(1, source_start_column)
    local segment = before:match("([^,]+)$") or before
    local prefix = segment:match("([%a_][%w_]*)%s*$")

    if not prefix then
        return nil
    end

    prefix = prefix:lower()

    local size_spec = memory_spec.size_prefixes[prefix]
    if type(size_spec) ~= "table" then
        return nil
    end

    return {
        prefix = prefix,
        bits = size_spec.bits,
        label = size_spec.label or prefix,
    }
end


local function parse_address_size_prefix_from_source_context(
    bufnr,
    source_line,
    source_start_column,
    memory_spec
)
    local policy = type(memory_spec) == "table"
        and memory_spec.address_size_policy
        or nil
    local prefixes = type(policy) == "table"
        and policy.prefixes
        or nil

    if not bufnr
        or type(source_line) ~= "number"
        or type(source_start_column) ~= "number"
        or type(prefixes) ~= "table"
    then
        return nil
    end

    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        source_line - 1,
        source_line,
        false
    )

    local line = lines and lines[1]
    if type(line) ~= "string" then
        return nil
    end

    local before = line:sub(1, source_start_column)
    local found

    for word in before:gmatch("[%a_][%w_]*") do
        local normalized = word:lower()
        local bits = prefixes[normalized]

        if type(bits) == "number" then
            if found and found.bits ~= bits then
                return {
                    error = "conflicting explicit address-size prefixes",
                    prefixes = {
                        found.prefix,
                        normalized,
                    },
                }
            end

            found = {
                prefix = normalized,
                bits = bits,
            }
        end
    end

    return found
end


local function token_kind(token, register_index)
    if type(token) ~= "string" or token == "" then
        return nil
    end

    local lowered = token:lower()

    if register_index[lowered] then
        return "register"
    end

    if token:match("^[+-]?0[xX][0-9a-fA-F]+$")
        or token:match("^[+-]?0[bB][01]+$")
        or token:match("^[+-]?%d+$")
    then
        return "integer"
    end

    return "symbol"
end


local function role_label(role, memory_spec)
    local role_spec = nil

    if type(role) == "string"
        and type(memory_spec) == "table"
        and type(memory_spec.component_roles) == "table"
    then
        role_spec = memory_spec.component_roles[role]
    end

    if type(role_spec) == "table"
        and type(role_spec.label) == "string"
    then
        return role_spec.label
    end

    return tostring(role or "component"):gsub("_", " ")
end


local function register_role_override(token, fallback_role, memory_spec)
    if type(token) ~= "string" then
        return fallback_role
    end

    local overrides = type(memory_spec) == "table"
        and memory_spec.register_role_overrides
        or nil

    if type(overrides) ~= "table" then
        return fallback_role
    end

    return overrides[token:lower()] or fallback_role
end


local function add_memory_component(components, opts)
    if type(components) ~= "table"
        or type(opts) ~= "table"
        or type(opts.text) ~= "string"
        or opts.text == ""
    then
        return
    end

    table.insert(components, {
        text = opts.text,
        kind = opts.kind,
        role = opts.role,
        structural_role = opts.structural_role or opts.role,
        role_label = opts.role_label,
        source_line = opts.source_line,
        source_column = opts.source_column,
        source_start_line = opts.source_start_line,
        source_start_column = opts.source_start_column,
        source_end_line = opts.source_end_line,
        source_end_column = opts.source_end_column,
    })
end


local function add_token_component(
    components,
    token,
    role,
    address_start_column,
    address_source_line,
    memory_spec,
    register_index,
    token_offset
)
    local clean_token, clean_offset = trim_with_offsets(
        token,
        token_offset or 0
    )

    if type(clean_token) ~= "string" or clean_token == "" then
        return
    end

    local kind = token_kind(clean_token, register_index)
    local final_role = role

    if kind == "register" then
        final_role = register_role_override(
            clean_token,
            role,
            memory_spec
        )
    end

    add_memory_component(components, {
        text = clean_token,
        kind = kind,
        role = final_role,
        structural_role = role,
        role_label = role_label(final_role, memory_spec),
        source_line = address_source_line,
        source_column = address_start_column + clean_offset,
        source_start_line = address_source_line,
        source_start_column = address_start_column + clean_offset,
        source_end_line = address_source_line,
        source_end_column = address_start_column + clean_offset + #clean_token,
    })
end


local function split_address_terms(address_text)
    local terms = {}
    local term_start = 1
    local sign = 1
    local i = 1

    while i <= #address_text do
        local ch = address_text:sub(i, i)

        if ch == "+" or ch == "-" then
            local text = address_text:sub(term_start, i - 1)
            table.insert(terms, {
                text = text,
                sign = sign,
                offset = term_start - 1,
            })

            sign = ch == "-" and -1 or 1
            term_start = i + 1
        end

        i = i + 1
    end

    table.insert(terms, {
        text = address_text:sub(term_start),
        sign = sign,
        offset = term_start - 1,
    })

    return terms
end


local function classify_plain_term_role(kind, sign, saw_base_register)
    if kind == "register" then
        return saw_base_register
            and "index_register"
            or "base_register"
    end

    if kind == "integer" then
        return "displacement"
    end

    if sign == -1 then
        return "displacement"
    end

    return "symbol"
end


local function parse_memory_components(
    address_text,
    address_start_column,
    address_source_line,
    memory_spec,
    register_index
)
    local components = {}
    local saw_base_register = false

    for _, term in ipairs(split_address_terms(address_text)) do
        local term_text, term_offset = trim_with_offsets(
            term.text,
            term.offset
        )

        if type(term_text) == "string" and term_text ~= "" then
            local star_start, star_end = term_text:find("*", 1, true)

            if star_start then
                local left = term_text:sub(1, star_start - 1)
                local right = term_text:sub(star_end + 1)

                add_token_component(
                    components,
                    left,
                    "index_register",
                    address_start_column,
                    address_source_line,
                    memory_spec,
                    register_index,
                    term_offset
                )

                add_token_component(
                    components,
                    right,
                    "scale",
                    address_start_column,
                    address_source_line,
                    memory_spec,
                    register_index,
                    term_offset + star_end
                )
            else
                local clean = term_text
                local kind = token_kind(clean, register_index)
                local role = classify_plain_term_role(
                    kind,
                    term.sign,
                    saw_base_register
                )

                if kind == "register" then
                    saw_base_register = true
                end

                local component_offset = term_offset

                if term.sign == -1
                    and kind == "integer"
                    and not clean:match("^-")
                then
                    clean = "-" .. clean
                    component_offset = math.max(0, component_offset - 1)
                end

                add_token_component(
                    components,
                    clean,
                    role,
                    address_start_column,
                    address_source_line,
                    memory_spec,
                    register_index,
                    component_offset
                )
            end
        end
    end

    return components
end


local function parse_address_mode(
    address_text,
    address_start_column,
    memory_spec
)
    if type(address_text) ~= "string" then
        return nil, nil, address_text, address_start_column
    end

    local modes = type(memory_spec) == "table"
        and memory_spec.address_modes
        or nil

    if type(modes) ~= "table" then
        return nil, nil, address_text, address_start_column
    end

    local token, rest = address_text:match("^([%a_][%w_]*)%s+(.+)$")
    if not token then
        return nil, nil, address_text, address_start_column
    end

    local spec = modes[token:lower()]
    if type(spec) ~= "table" then
        return nil, nil, address_text, address_start_column
    end

    local rest_start = address_text:find(rest, #token + 1, true)
        or (#token + 2)

    return token:lower(),
        spec.kind or token:lower(),
        rest,
        address_start_column + rest_start - 1
end


local function analyze_memory_operand(
    bufnr,
    node,
    adapter,
    operand_text,
    source_start_line,
    source_start_column
)
    local memory_spec = get_memory_operand_spec(
        node,
        adapter
    )

    if type(memory_spec) ~= "table"
        or type(operand_text) ~= "string"
    then
        return nil
    end

    local open_start,
        open_end,
        close_start,
        close_end = find_first_bracket_pair(
            operand_text,
            memory_spec
        )

    if not open_start or not close_start then
        return nil
    end

    local address_text = operand_text:sub(
        open_end + 1,
        close_start - 1
    )

    local trimmed_address,
        trimmed_address_column = trim_with_offsets(
            address_text,
            source_start_column + open_end
        )

    local address_mode_token,
        address_mode,
        component_text,
        component_start_column = parse_address_mode(
            trimmed_address or "",
            trimmed_address_column,
            memory_spec
        )

    local register_index = build_register_alias_index(adapter)
    local components = parse_memory_components(
        component_text or "",
        component_start_column,
        source_start_line,
        memory_spec,
        register_index
    )

    local size = parse_memory_prefix(
        operand_text,
        memory_spec
    )

    if not size then
        size = parse_memory_prefix_from_source_context(
            bufnr,
            source_start_line,
            source_start_column,
            memory_spec
        )
    end

    local address_size_prefix =
        parse_address_size_prefix_from_source_context(
            bufnr,
            source_start_line,
            source_start_column,
            memory_spec
        )

    local resolved_address_size = address_size.resolve(
        memory_spec.address_size_policy,
        components,
        function(register_name)
            return get_register_bits(
                adapter,
                register_name
            )
        end,
        {
            explicit_bits = address_size_prefix
                and address_size_prefix.bits
                or nil,
            explicit_prefix = address_size_prefix
                and address_size_prefix.prefix
                or nil,
            explicit_error = address_size_prefix
                and address_size_prefix.error
                or nil,
            explicit_prefixes = address_size_prefix
                and address_size_prefix.prefixes
                or nil,
        }
    )

    local memory = {
        kind = memory_spec.kind or "memory",
        container_kind = memory_spec.container_kind or "memory",
        address_kind = memory_spec.address_kind or "address_expression",
        address_text = trimmed_address,
        address_start_column = trimmed_address_column,
        address_end_column = trimmed_address_column
            + #(trimmed_address or ""),
        source_line = source_start_line,
        address_mode = address_mode or "default",
        address_mode_token = address_mode_token,
        address_size = resolved_address_size,
        size = size,
        components = components,
    }

    memory.normalized = memory_address.normalize(memory)

    return memory
end


local function classify_operand(bufnr, node, adapter)
    local text = node_text(bufnr, node)

    if not text then
        return nil
    end

    local node_type = node:type()
    local kind = get_operand_kind_from_adapter(
        node,
        adapter
    )

    -- Compatibility for older ASM adapters that do not yet declare operand
    -- semantics inside construct_specs.
    if not kind then
        if node_type == "int" then
            kind = "integer"
        elseif node_type == "reg"
            or node_has_descendant_type(node, "reg")
        then
            kind = "register"
        elseif node_type == "ident"
            or node_type == "word"
        then
            kind = "symbol"
        else
            kind = "unknown"
        end
    end

    local start_row, start_column, end_row, end_column =
        node:range()

    local operand = {
        text = text,
        kind = kind,
        node_type = node_type,

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }

    if kind == "memory" then
        operand.memory = analyze_memory_operand(
            bufnr,
            node,
            adapter,
            text,
            operand.source_start_line,
            operand.source_start_column
        )
    end

    return operand
end


local function append_operand(
    operands,
    seen,
    bufnr,
    node,
    adapter
)
    local operand = classify_operand(
        bufnr,
        node,
        adapter
    )

    if not operand then
        return
    end

    local start_row, start_column = node:start()

    local key = table.concat({
        operand.text,
        operand.kind,
        operand.node_type,
        tostring(start_row),
        tostring(start_column),
    }, "|")

    if seen[key] then
        return
    end

    seen[key] = true

    table.insert(operands, operand)
end


local function get_mnemonic_node(
    instruction_node,
    instruction_spec
)
    local kind_field =
        get_syntax_field(
            instruction_spec,
            "kind"
        )

    if kind_field then
        local field_node =
            treesitter_utils.get_child_by_field_name(
                instruction_node,
                kind_field
            )

        if field_node then
            return field_node
        end
    end

    local kind_child =
        get_syntax_child_spec(
            instruction_spec,
            "kind"
        )

    if type(kind_child) == "table" then
        for child in instruction_node:iter_children() do
            if node_matches_child_spec(
                child,
                kind_child
            ) then
                return child
            end
        end
    end

    -- Compatibility for older ASM adapters.
    for child in instruction_node:iter_children() do
        if child:type() == "word" then
            return child
        end
    end

    return nil
end


local function collect_declared_operands(
    instruction_node,
    instruction_spec,
    bufnr,
    adapter
)
    local operands = {}
    local seen = {}

    local operand_child =
        get_syntax_child_spec(
            instruction_spec,
            "operands"
        )

    if type(operand_child) ~= "table" then
        return nil
    end

    for child in instruction_node:iter_children() do
        if node_matches_child_spec(
            child,
            operand_child
        ) then
            append_operand(
                operands,
                seen,
                bufnr,
                child,
                adapter
            )
        end
    end

    return operands
end


local function collect_legacy_operands(
    instruction_node,
    bufnr,
    adapter,
    mnemonic_node
)
    local operands = {}
    local seen = {}
    local mnemonic_seen = false

    for child in instruction_node:iter_children() do
        local child_type = child:type()

        if child_type == "word"
            and not mnemonic_seen
        then
            mnemonic_seen = true
        elseif child_type == "reg"
            or child_type == "ident"
            or child_type == "int"
            or child_type == "word"
        then
            append_operand(
                operands,
                seen,
                bufnr,
                child,
                adapter
            )
        end
    end

    return operands
end


function M.parse_instruction(
    bufnr,
    instruction_node,
    _effect_spec,
    adapter
)
    if not instruction_node then
        return nil
    end

    local instruction_spec = get_construct_spec(
        adapter,
        instruction_node:type()
    )

    local syntax = get_syntax(instruction_spec)
    local expected_node_type = syntax.node_type
        or "instruction"

    if instruction_node:type() ~= expected_node_type then
        return nil
    end

    local mnemonic_node = get_mnemonic_node(
        instruction_node,
        instruction_spec
    )

    local mnemonic = node_text(
        bufnr,
        mnemonic_node
    )

    if not mnemonic then
        return nil
    end

    local mnemonic_range = nil

    if mnemonic_node then
        local start_row,
            start_column,
            end_row,
            end_column = mnemonic_node:range()

        mnemonic_range = {
            source_line = start_row + 1,
            source_column = start_column,

            source_start_line = start_row + 1,
            source_start_column = start_column,

            source_end_line = end_row + 1,
            source_end_column = end_column,
        }
    end

    local operands = collect_declared_operands(
        instruction_node,
        instruction_spec,
        bufnr,
        adapter
    )

    if operands == nil then
        operands = collect_legacy_operands(
            instruction_node,
            bufnr,
            adapter,
            mnemonic_node
        )
    end

    local start_row,
        start_column,
        end_row,
        end_column = instruction_node:range()

    return {
        mnemonic = mnemonic:lower(),
        mnemonic_range = mnemonic_range,

        operands = operands,

        source_line = start_row + 1,
        source_column = start_column,

        source_start_line = start_row + 1,
        source_start_column = start_column,
        source_end_line = end_row + 1,
        source_end_column = end_column,
    }
end


return M

