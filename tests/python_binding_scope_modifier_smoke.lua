-- tests/python_binding_scope_modifier_smoke.lua
--
-- Parser-backed ownership semantics for Python global/nonlocal statements.
-- These statements are ownership modifiers, not Scope Members themselves.

local function collect_nodes_by_type(
    node,
    wanted,
    out
)
    out = out or {}

    if node:type() == wanted then
        table.insert(out, node)
    end

    for child in node:iter_children() do
        collect_nodes_by_type(
            child,
            wanted,
            out
        )
    end

    return out
end


local function direct_identifier_names(
    node,
    bufnr
)
    local result = {}

    for child in node:iter_children() do
        if child:type() == "identifier" then
            table.insert(
                result,
                vim.treesitter.get_node_text(
                    child,
                    bufnr
                )
            )
        end
    end

    return result
end


local function find_member(
    members,
    name,
    line
)
    for _, member in ipairs(members or {}) do
        if member.name == name
            and member.line == line
        then
            return member
        end
    end

    return nil
end


local function same_scope(
    left,
    right
)
    return left
        and right
        and left.scope_depth
            == right.scope_depth
        and left.scope_start_line
            == right.scope_start_line
        and left.scope_end_line
            == right.scope_end_line
end


local function run()
    vim.opt.runtimepath:prepend(
        vim.fn.getcwd()
    )

    local registry =
        require(
            "tracker_hud.adapters.registry"
        )
    local collector =
        require(
            "tracker_hud.scope_members"
        )
    local adapter =
        require(
            "tracker_hud.adapters.python.init"
        )

    registry.clear()

    local registered, register_err =
        registry.register(adapter)

    assert(
        registered,
        "Python adapter registration failed: "
            .. tostring(register_err)
    )

    local source_path =
        "samples/python/"
        .. "python_binding_scope_modifier_validation.py"

    local lines =
        vim.fn.readfile(
            source_path
        )

    assert(
        type(lines) == "table"
            and #lines > 0,
        "Python ownership-modifier fixture missing"
    )

    local buffer =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        -1,
        false,
        lines
    )

    vim.bo[buffer].filetype =
        "python"

    local parser_ok, parser_or_err =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "python"
        )

    assert(
        parser_ok and parser_or_err,
        "Missing Tree-sitter 'python' parser: "
            .. tostring(parser_or_err)
    )

    local tree =
        parser_or_err:parse()[1]

    assert(
        tree,
        "Python parser yielded no tree"
    )

    local root =
        tree:root()

    assert(
        not root:has_error(),
        "Python ownership-modifier fixture contains parser ERROR nodes"
    )

    local globals =
        collect_nodes_by_type(
            root,
            "global_statement"
        )

    local nonlocals =
        collect_nodes_by_type(
            root,
            "nonlocal_statement"
        )

    assert(
        #globals == 1
            and #nonlocals == 3,
        "Python global/nonlocal parser node counts changed"
    )

    local global_names =
        direct_identifier_names(
            globals[1],
            buffer
        )

    assert(
        #global_names == 2
            and global_names[1]
                == "module_value"
            and global_names[2]
                == "other_global",
        "Python global_statement identifier shape changed"
    )

    for _, node in ipairs(nonlocals) do
        local names =
            direct_identifier_names(
                node,
                buffer
            )

        assert(
            #names == 1,
            "Python nonlocal_statement identifier shape changed"
        )
    end

    local members =
        collector.collect(
            buffer,
            root,
            adapter,
            {
                cursor_line = #lines,
            }
        )

    local module_value_seed =
        find_member(
            members,
            "module_value",
            1
        )

    local other_global_seed =
        find_member(
            members,
            "other_global",
            2
        )

    local closure_seed =
        find_member(
            members,
            "closure_value",
            5
        )

    local chain_seed =
        find_member(
            members,
            "chain_value",
            6
        )

    local class_closure =
        find_member(
            members,
            "closure_value",
            9
        )

    local method_closure =
        find_member(
            members,
            "closure_value",
            13
        )

    local global_module_value =
        find_member(
            members,
            "module_value",
            17
        )

    local global_other =
        find_member(
            members,
            "other_global",
            18
        )

    local middle_chain =
        find_member(
            members,
            "chain_value",
            21
        )

    local inner_chain =
        find_member(
            members,
            "chain_value",
            25
        )

    assert(
        module_value_seed
            and other_global_seed
            and closure_seed
            and chain_seed
            and class_closure
            and method_closure
            and global_module_value
            and global_other
            and middle_chain
            and inner_chain,
        "Python ownership-modifier fixture members missing"
    )

    assert(
        module_value_seed.scope_depth == 1
            and other_global_seed.scope_depth
                == 1,
        "module seed ownership changed"
    )

    assert(
        same_scope(
            global_module_value,
            module_value_seed
        )
            and same_scope(
                global_other,
                other_global_seed
            ),
        "global bindings did not redirect to module lexical ownership"
    )

    assert(
        closure_seed.scope_depth == 2
            and class_closure.scope_depth
                == 3,
        "outer/class lexical baseline changed"
    )

    assert(
        same_scope(
            method_closure,
            closure_seed
        )
            and not same_scope(
                method_closure,
                class_closure
            ),
        "nonlocal incorrectly resolved through class lexical ownership"
    )

    assert(
        same_scope(
            middle_chain,
            chain_seed
        )
            and same_scope(
                inner_chain,
                chain_seed
            ),
        "chained nonlocal ownership did not resolve to outer binding scope"
    )

    local modifier_lines = {
        [12] = true,
        [16] = true,
        [20] = true,
        [24] = true,
    }

    for _, member in ipairs(members) do
        assert(
            not modifier_lines[
                member.line
            ],
            "global/nonlocal statement emitted a Scope Member"
        )
    end

    print(
        "PARSER python ownership modifiers: "
            .. "global_statement(module_value,other_global)"
            .. " nonlocal_statement x3"
    )

    print(
        "COLLECTED python ownership redirects: "
            .. "module_value@17->lex="
            .. tostring(
                global_module_value.scope_depth
            )
            .. ", other_global@18->lex="
            .. tostring(
                global_other.scope_depth
            )
            .. ", closure_value@13->lex="
            .. tostring(
                method_closure.scope_depth
            )
            .. ", chain_value@21->lex="
            .. tostring(
                middle_chain.scope_depth
            )
            .. ", chain_value@25->lex="
            .. tostring(
                inner_chain.scope_depth
            )
    )

    print(
        "PASS Python global/nonlocal lexical ownership semantics"
    )

    vim.api.nvim_buf_delete(
        buffer,
        { force = true }
    )
end


local ok, err =
    pcall(run)

if not ok then
    vim.api.nvim_err_writeln(
        "FAIL Python binding-scope modifier smoke: "
            .. tostring(err)
    )
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
