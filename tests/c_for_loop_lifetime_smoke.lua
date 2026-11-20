-- tests/c_for_loop_lifetime_smoke.lua
--
-- Real-parser C for-declaration lifetime baseline.
--
-- A variable declared by a C for initializer is visible through that
-- for-statement and must not leak into the remainder of the enclosing block.

local function find_member(members, name, kind)
    for _, member in ipairs(members or {}) do
        if member.name == name and member.kind == kind then
            return member
        end
    end
    return nil
end

local function has_member(members, name, kind)
    return find_member(members, name, kind) ~= nil
end

local function find_line(lines, needle)
    for index, line in ipairs(lines or {}) do
        if line:find(needle, 1, true) then
            return index
        end
    end
    return nil
end

local function collect_nodes_by_type(node, wanted, out)
    out = out or {}
    if node:type() == wanted then
        table.insert(out, node)
    end
    for child in node:iter_children() do
        collect_nodes_by_type(child, wanted, out)
    end
    return out
end

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local registry = require("tracker_hud.adapters.registry")
    local collector = require("tracker_hud.scope_members")
    local ts_utils = require("tracker_hud.treesitter_utils")
    local adapter = require("tracker_hud.adapters.c.init")

    registry.clear()
    local registered, register_err = registry.register(adapter)
    assert(registered, "C adapter registration failed: " .. tostring(register_err))

    local path = "samples/c/c_for_loop_lifetime_validation.c"
    local lines = vim.fn.readfile(path)
    assert(type(lines) == "table" and #lines > 0,
        "C for-loop lifetime fixture missing")

    local loop_line = find_line(lines, "for (int i = 0;")
    local body_line = find_line(lines, "total += i;")
    local after_line = find_line(lines, "int after = total;")
    assert(loop_line and body_line and after_line,
        "C for-loop validation lines missing")

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, lines)
    vim.bo[buffer].filetype = "c"

    local parser_ok, parser_or_err =
        pcall(vim.treesitter.get_parser, buffer, "c")
    assert(parser_ok and parser_or_err,
        "Missing Tree-sitter 'c' parser: " .. tostring(parser_or_err))

    local tree = parser_or_err:parse()[1]
    assert(tree, "C parser yielded no tree")
    local root = tree:root()
    assert(not root:has_error(),
        "C for-loop fixture contains parser ERROR nodes")

    local loops = collect_nodes_by_type(root, "for_statement")
    assert(#loops == 1,
        "C fixture expected one for_statement, got " .. tostring(#loops))

    local loop_range = ts_utils.get_node_range_fields(loops[1])
    print(
        "PARSER c for statement: "
            .. tostring(loop_range.start_line)
            .. "-"
            .. tostring(loop_range.end_line)
    )

    local discovery = collector.discover(buffer, root, adapter)
    local all = collector.select(discovery, {})

    local variable = find_member(all, "i", "variable")
    if not variable then
        local observed = {}
        for _, member in ipairs(all or {}) do
            if member.name == "i" then
                table.insert(observed,
                    tostring(member.kind) .. "@" .. tostring(member.line))
            end
        end
        error(
            "C for initializer variable 'i' missing; same-name members="
                .. (#observed > 0 and table.concat(observed, ",") or "none")
        )
    end

    print(
        "OBSERVED c for binding: "
            .. tostring(variable.name)
            .. "@" .. tostring(variable.line)
            .. "(lex=" .. tostring(variable.scope_depth or "?")
            .. ",owner=" .. tostring(variable.scope_start_line or "?")
            .. "-" .. tostring(variable.scope_end_line or "?")
            .. ",visible=" .. tostring(variable.visibility_start_line or "none")
            .. "-" .. tostring(variable.visibility_end_line or "none")
            .. ")"
    )

    assert(
        variable.visibility_start_line == loop_range.start_line
            and variable.visibility_end_line == loop_range.end_line,
        "C for initializer variable must use the for-statement structural range as its visibility lifetime"
    )

    local inside = collector.select(discovery, {
        cursor_line = body_line,
        start_line = variable.scope_start_line,
        end_line = variable.scope_end_line,
    })

    local after = collector.select(discovery, {
        cursor_line = after_line,
        start_line = variable.scope_start_line,
        end_line = variable.scope_end_line,
    })

    assert(has_member(inside, "i", "variable"),
        "C for initializer variable must be visible inside the loop body")
    assert(not has_member(after, "i", "variable"),
        "C for initializer variable leaked past the for-statement lifetime")

    print("PASS C parser-backed for-declaration lifetime semantics")
    vim.api.nvim_buf_delete(buffer, { force = true })
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln(
        "FAIL C for-declaration lifetime smoke: " .. tostring(err))
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
