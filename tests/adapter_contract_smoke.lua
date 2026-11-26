-- tests/adapter_contract_smoke.lua
-- Run from the repository root:
--   nvim --headless -u NONE -c "luafile tests/adapter_contract_smoke.lua"
-- This validates adapter shapes/registration. Tree-sitter parser availability and
-- the interactive HUD must still be checked using the sample source files.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local contract = require("tracker_hud.adapters.contract")
    local registry = require("tracker_hud.adapters.registry")
    local scope_member_schema =
        require("tracker_hud.adapters.scope_member_schema")
    local construct_schema =
        require("tracker_hud.adapters.construct_schema")
    local construct_contract =
        require("tracker_hud.constructs.contract")
    local adapters = {
        { filetype = "lua", module = "tracker_hud.adapters.lua.init" },
        { filetype = "python", module = "tracker_hud.adapters.python.init" },
        { filetype = "c", module = "tracker_hud.adapters.c.init" },
        { filetype = "cpp", module = "tracker_hud.adapters.cpp.init" },
    }

    registry.clear()

    for _, item in ipairs(adapters) do
        local adapter = require(item.module)
        local valid, validation_error = contract.validate_adapter(adapter)
        assert(valid, item.filetype .. " contract: " .. tostring(validation_error))

        local registered, registration_error = registry.register(adapter)
        assert(registered, item.filetype .. " registration: " .. tostring(registration_error))
        assert(registry.get_adapter(item.filetype) == adapter,
            item.filetype .. " registry lookup failed")

        print("PASS Adapter Contract v1 + registration: " .. item.filetype)
    end

    local c = registry.get_adapter("c")
    local cpp = registry.get_adapter("cpp")
    assert(c ~= cpp and c.name == "c" and cpp.name == "cpp",
        "C++ adapter must not mutate the C adapter")
    assert(c.construct_specs["class_specifier"] == nil,
        "C adapter must not inherit C++-only grammar rules")
    assert(cpp.construct_specs["class_specifier"] ~= nil,
        "C++ class grammar rule missing")
    assert(cpp.construct_specs["namespace_definition"] ~= nil,
        "C++ namespace grammar rule missing")
    assert(cpp.construct_specs["for_range_loop"] ~= nil,
        "C++ range-for grammar rule missing")
    -- Scope Member group vocabulary is shared by the runtime and contract,
    -- so custom adapters cannot validate a group the collector will ignore.
    for _, adapter in ipairs({ c, cpp }) do
        for group_name in pairs(adapter.scope_members or {}) do
            assert(
                scope_member_schema.is_supported_group(
                    group_name
                ),
                adapter.name
                    .. " has unsupported member group: "
                    .. group_name
            )
        end
        local parameter_count = 0
        local expected_name = {
            field = "declarator",
            recursive = {
                field = "declarator",
                terminal_node_types = { "identifier" },
                container_node_types = { "pointer_declarator", "array_declarator" },
            },
        }
        if adapter.name == "cpp" then
            table.insert(expected_name.recursive.container_node_types, "reference_declarator")
            expected_name.recursive.single_named_child_node_types = { "reference_declarator" }
        end
        for _, spec in ipairs(adapter.scope_members.symbols or {}) do
            if spec.syntax.node_type == "parameter_declaration" then
                parameter_count = parameter_count + 1
                assert(vim.deep_equal(spec.syntax.fields.name, expected_name)
                    and spec.member.kind == "parameter",
                    adapter.name .. " must expose declared terminal parameter names")
            end
        end
        assert(parameter_count == 2, adapter.name .. " must preserve both parameter roles")
    end


    for _, node_type in ipairs({
        "optional_parameter_declaration",
        "variadic_parameter_declaration",
    }) do
        local found = false
        for _, spec in ipairs(cpp.scope_members.symbols or {}) do
            if spec.syntax.node_type == node_type
                and spec.syntax.fields.name == "declarator"
                and spec.member.kind == "parameter"
            then
                found = true
                break
            end
        end
        assert(found, "C++ missing parameter source binding: " .. node_type)
    end

    -- Explicit grammar-name fallbacks must be configured in each adapter.
    -- They are used only if the primary named-field lookup cannot resolve
    -- the declaration; never guess from arbitrary source text.
    local function expect_name_fallback(adapter, group, node_type, fallback)
        local found = false
        for _, spec in ipairs(adapter.scope_members[group] or {}) do
            if spec.syntax.node_type == node_type then
                local child = spec.syntax.children and spec.syntax.children.name
                assert(child and child.node_type == fallback,
                    adapter.name .. " " .. node_type
                        .. " missing AST name fallback " .. fallback)
                found = true
                break
            end
        end
        assert(found, adapter.name .. " missing " .. group .. " " .. node_type)
    end

    for _, adapter in ipairs({ c, cpp }) do
        expect_name_fallback(adapter, "functions",
            "function_definition", "identifier")
        expect_name_fallback(adapter, "symbols",
            "parameter_declaration", "identifier")
        expect_name_fallback(adapter, "symbols",
            "struct_specifier", "type_identifier")
        expect_name_fallback(adapter, "fields",
            "field_declaration", "field_identifier")
    end
    expect_name_fallback(cpp, "symbols",
        "class_specifier", "type_identifier")
    expect_name_fallback(cpp, "symbols",
        "namespace_definition", "namespace_identifier")
    expect_name_fallback(cpp, "symbols",
        "optional_parameter_declaration", "identifier")
    print("PASS C/C++ grammar-specific member fallback contracts")

    local named_probe =
        scope_member_schema.named(
            "function_definition",
            "declarator",
            "function",
            {
                owner_scope =
                    "parent_lexical",
                fallback_node_type =
                    "identifier",
            }
        )

    assert(
        named_probe.syntax.node_type
            == "function_definition"
            and named_probe.syntax.fields.name
                == "declarator"
            and named_probe.syntax.children
                .name.node_type
                == "identifier"
            and named_probe.member.kind
                == "function"
            and named_probe.member.language_term
                == "function"
            and named_probe.member.owner_scope
                == "parent_lexical",
        "shared named Scope Member builder changed declaration shape"
    )

    local invalid_group_probe =
        vim.deepcopy(c)

    invalid_group_probe.scope_members
        .not_a_real_group = {
            vim.deepcopy(
                c.scope_members.symbols[1]
            ),
        }

    local invalid_group_ok,
        invalid_group_error =
        contract.validate_adapter(
            invalid_group_probe
        )

    assert(
        not invalid_group_ok
            and tostring(
                invalid_group_error
            ):find(
                "not a supported Scope Member group",
                1,
                true
            ),
        "contract accepted a Scope Member group the runtime cannot collect"
    )

    assert(
        construct_contract.validate_member_kind(
            "pattern_binding"
        ),
        "shared construct contract must admit structural pattern bindings"
    )

    print(
        "PASS shared Scope Member adapter schema + named builder"
    )

    local recursive_binding_syntax = {
        node_type = "assignment",
        fields = {
            bindings = {
                field = "left",
                recursive = {
                    terminal_node_types = {
                        "identifier",
                        "attribute",
                        "subscript",
                    },
                    container_node_types = {
                        "pattern_list",
                        "tuple_pattern",
                    },
                },
            },
        },
    }

    local recursive_binding_ok,
        recursive_binding_error =
        contract.validate_syntax(
            recursive_binding_syntax,
            "probe.syntax"
        )

    assert(
        recursive_binding_ok,
        "contract rejected recursive binding field: "
            .. tostring(
                recursive_binding_error
            )
    )

    local field_recursive_syntax = vim.deepcopy(recursive_binding_syntax)
    field_recursive_syntax.fields.bindings.recursive.field = "declarator"
    local field_ok, field_err = contract.validate_syntax(field_recursive_syntax, "probe.syntax")
    assert(field_ok, "contract rejected explicit recursive field: " .. tostring(field_err))
    for _, invalid in ipairs({ false, 1, "", {} }) do
        field_recursive_syntax.fields.bindings.recursive.field = invalid
        local valid, err = contract.validate_syntax(field_recursive_syntax, "probe.syntax")
        assert(not valid and tostring(err):find(".recursive.field", 1, true),
            "contract accepted malformed recursive field or lost diagnostic path")
    end

    local single_child_syntax = vim.deepcopy(recursive_binding_syntax)
    local recursive = single_child_syntax.fields.bindings.recursive
    recursive.field = "declarator"
    local container = recursive.container_node_types[1]
    recursive.single_named_child_node_types = { container }
    local single_ok, single_err = contract.validate_syntax(single_child_syntax, "probe.syntax")
    assert(single_ok, "contract rejected single named child traversal: " .. tostring(single_err))
    for _, invalid in ipairs({
        false, "container", {}, { false }, { container, container },
        { "undeclared_container" }, { container, extra = container },
        { [1] = container, [3] = container },
    }) do
        recursive.single_named_child_node_types = invalid
        local valid, err = contract.validate_syntax(single_child_syntax, "probe.syntax")
        assert(not valid and tostring(err):find(".recursive.single_named_child_node_types", 1, true),
            "contract accepted malformed single named child traversal or lost diagnostic path")
    end
    recursive.single_named_child_node_types = { container }
    recursive.field = nil
    local valid, err = contract.validate_syntax(single_child_syntax, "probe.syntax")
    assert(not valid and tostring(err):find(".recursive.single_named_child_node_types", 1, true),
        "contract accepted single named child traversal without explicit field mode")

    local overlapping_binding_syntax =
        vim.deepcopy(
            recursive_binding_syntax
        )

    table.insert(
        overlapping_binding_syntax
            .fields.bindings.recursive
            .container_node_types,
        "identifier"
    )

    local overlapping_binding_ok,
        overlapping_binding_error =
        contract.validate_syntax(
            overlapping_binding_syntax,
            "probe.syntax"
        )

    assert(
        not overlapping_binding_ok
            and tostring(
                overlapping_binding_error
            ):find(
                "must not overlap",
                1,
                true
            ),
        "contract accepted ambiguous recursive binding terminals/containers"
    )

    print(
        "PASS recursive binding field contract"
    )

    local field_path_probe = {
        node_type = "declaration",
        exclusions = {
            ancestor_node_types = { "for_statement" },
            field_paths = {
                { fields = { "declarator", "declarator" },
                  node_types = { "structured_binding_declarator" } },
            },
        },
    }
    local valid_path, path_err = contract.validate_syntax(
        field_path_probe, "probe.syntax")
    assert(valid_path, "valid repeated field path rejected: " .. tostring(path_err))

    for _, invalid in ipairs({
        { fields = {}, node_types = { "identifier" } },
        { fields = { "declarator" }, node_types = {} },
        { fields = { "declarator" }, node_types = { "identifier", "identifier" } },
        { fields = { "declarator", false }, node_types = { "identifier" } },
        { fields = { "declarator", unexpected = "value" }, node_types = { "identifier" } },
    }) do
        local probe = vim.deepcopy(field_path_probe)
        probe.exclusions.field_paths = { invalid }
        local accepted = contract.validate_syntax(probe, "probe.syntax")
        assert(not accepted, "invalid field path exclusion accepted")
    end
    print("PASS declarative field path exclusion contract")

    for _, key in ipairs({ "constraints", "exclusions" }) do
        local probe = {
            node_type = "identifier",
            [key] = { parent_path = { "wrapper", "wrapper", "owner" } },
        }
        local accepted, diagnostic = contract.validate_syntax(probe, "probe.syntax")
        assert(accepted, "valid ordered parent path rejected: " .. tostring(diagnostic))
        for _, invalid in ipairs({
            {}, "wrapper", { "wrapper", false },
            { "wrapper", extra = "owner" }, { "" },
        }) do
            probe[key].parent_path = invalid
            assert(not contract.validate_syntax(probe, "probe.syntax"),
                "invalid " .. key .. " parent path accepted")
        end
    end
    print("PASS declarative ordered parent path contract")

    -- Check the expanded adapter rule, not merely the helper's input.
    -- The named builder historically drops syntax exclusions.
    local ordinary_range_rule = nil
    for _, spec in ipairs(cpp.scope_members.loops or {}) do
        if spec.syntax.node_type == "for_range_loop"
            and spec.member.kind == "loop_variable"
        then
            ordinary_range_rule = spec
            break
        end
    end
    assert(ordinary_range_rule, "ordinary C++ range-for rule missing")
    local syntax = ordinary_range_rule.syntax
    local field_path = syntax.exclusions
        and syntax.exclusions.field_paths
        and syntax.exclusions.field_paths[1]
    assert(field_path
        and #field_path.fields == 1
        and field_path.fields[1] == "declarator"
        and #field_path.node_types == 1
        and field_path.node_types[1] == "structured_binding_declarator",
        "expanded C++ range-for rule lost structured-binding exclusion")
    assert(syntax.fields.name == "declarator"
        and syntax.children.name.node_type == "identifier"
        and ordinary_range_rule.member.visibility.range == "structural_scope",
        "ordinary C++ range-for field/fallback/lifetime changed")
    print("PASS expanded C++ range-for rule retains field exclusion")

    local lifetime_member_probe =
        vim.deepcopy(
            c.scope_members.symbols[1]
        )

    lifetime_member_probe.member.visibility = {
        range =
            "structural_scope",
    }

    local lifetime_member_ok,
        lifetime_member_error =
        construct_contract
            .validate_member_spec(
                lifetime_member_probe.member
            )

    assert(
        lifetime_member_ok,
        "contract rejected structural member visibility range: "
            .. tostring(
                lifetime_member_error
            )
    )

    lifetime_member_probe.member.visibility.range =
        "python_handler_magic"

    local invalid_lifetime_ok,
        invalid_lifetime_error =
        construct_contract
            .validate_member_spec(
                lifetime_member_probe.member
            )

    assert(
        not invalid_lifetime_ok
            and tostring(
                invalid_lifetime_error
            ):find(
                "member.visibility.range is invalid",
                1,
                true
            ),
        "contract accepted language-specific member lifetime magic"
    )

    print(
        "PASS generic Scope Member lifetime contract"
    )

    local owner_exclusion_probe =
        vim.deepcopy(
            c.scope_members.symbols[1]
        )

    owner_exclusion_probe.member.owner_scope =
        "lexical"
    owner_exclusion_probe.member
        .owner_scope_excluded_construct_kinds = {
            "comprehension",
        }

    local owner_exclusion_ok,
        owner_exclusion_error =
        construct_contract
            .validate_member_spec(
                owner_exclusion_probe.member
            )

    assert(
        owner_exclusion_ok,
        "contract rejected generic lexical-owner exclusions: "
            .. tostring(
                owner_exclusion_error
            )
    )

    owner_exclusion_probe.member
        .owner_scope_excluded_construct_kinds = {
            "python_comprehension_magic",
        }

    local invalid_owner_exclusion_ok,
        invalid_owner_exclusion_error =
        construct_contract
            .validate_member_spec(
                owner_exclusion_probe.member
            )

    assert(
        not invalid_owner_exclusion_ok
            and tostring(
                invalid_owner_exclusion_error
            ):find(
                "invalid construct kind",
                1,
                true
            ),
        "contract accepted language-specific lexical-owner exclusion magic"
    )

    print(
        "PASS generic lexical-owner exclusion contract"
    )

    local modifier_probe =
        vim.deepcopy(c)

    modifier_probe.scope_binding_modifiers = {
        {
            syntax = {
                node_type =
                    "binding_redirect",
                children = {
                    names = {
                        node_type =
                            "identifier",
                        multiple = true,
                    },
                },
            },
            target = {
                strategy =
                    "outermost_lexical",
            },
        },
        {
            syntax = {
                node_type =
                    "binding_redirect_nearest",
                children = {
                    names = {
                        node_type =
                            "identifier",
                        multiple = true,
                    },
                },
            },
            target = {
                strategy =
                    "nearest_enclosing_binding",
                eligible_construct_kinds = {
                    "function",
                },
            },
        },
    }

    local modifier_probe_ok,
        modifier_probe_error =
        contract.validate_adapter(
            modifier_probe
        )

    assert(
        modifier_probe_ok,
        "contract rejected generic binding-scope modifiers: "
            .. tostring(
                modifier_probe_error
            )
    )

    local invalid_modifier_probe =
        vim.deepcopy(
            modifier_probe
        )

    invalid_modifier_probe
        .scope_binding_modifiers[1]
        .target.strategy =
            "python_magic"

    local invalid_modifier_ok,
        invalid_modifier_error =
        contract.validate_adapter(
            invalid_modifier_probe
        )

    assert(
        not invalid_modifier_ok
            and tostring(
                invalid_modifier_error
            ):find(
                "outermost_lexical or nearest_enclosing_binding",
                1,
                true
            ),
        "contract accepted language-specific binding ownership magic"
    )

    print(
        "PASS generic binding-scope modifier contract"
    )

    local lua_adapter =
        registry.get_adapter("lua")
    local python_adapter =
        registry.get_adapter("python")

    local function expect_named_member(
        adapter,
        group_name,
        node_type,
        expected
    )
        local found = nil

        for _, spec in ipairs(
            adapter.scope_members[
                group_name
            ] or {}
        ) do
            if spec.syntax.node_type
                == node_type
            then
                found = spec
                break
            end
        end

        assert(
            found ~= nil,
            adapter.name
                .. " missing "
                .. group_name
                .. " member "
                .. node_type
        )

        local fields =
            found.syntax.fields
            or {}

        assert(
            fields.name
                == expected.name_field
            and found.member.kind
                == expected.kind
            and found.member.language_term
                == expected.language_term
            and found.member.owner_scope
                == expected.owner_scope
            and (
                found.member.mutability
                and found.member.mutability
                    .binding
                or nil
            ) == expected.binding_mutability,
            adapter.name
                .. " shared named member shape changed: "
                .. node_type
        )
    end

    expect_named_member(
        lua_adapter,
        "functions",
        "function_declaration",
        {
            name_field = "name",
            kind = "function",
            language_term = "function",
            owner_scope =
                "parent_lexical",
            binding_mutability =
                "mutable",
        }
    )

    expect_named_member(
        lua_adapter,
        "functions",
        "function_definition",
        {
            name_field = nil,
            kind = "function",
            language_term = "function",
            owner_scope =
                "parent_lexical",
            binding_mutability =
                "mutable",
        }
    )

    expect_named_member(
        python_adapter,
        "functions",
        "class_definition",
        {
            name_field = "name",
            kind = "symbol",
            language_term = "class",
            owner_scope =
                "parent_lexical",
            binding_mutability =
                "mutable",
        }
    )

    expect_named_member(
        python_adapter,
        "functions",
        "function_definition",
        {
            name_field = "name",
            kind = "function",
            language_term = "function",
            owner_scope =
                "parent_lexical",
            binding_mutability =
                "mutable",
        }
    )

    print(
        "PASS Lua/Python shared named Scope Member declarations"
    )

    local general_rule_probe =
        scope_member_schema.rule(
            "assignment_statement",
            "assignment",
            {
                fields = {
                    operator = "operator",
                },
                children = {
                    names = {
                        node_type =
                            "variable_list",
                    },
                },
                tokens = {
                    operator = "=",
                },
                exclusions = {
                    ancestor_node_types = {
                        "variable_declaration",
                    },
                },
                constraints = {
                    ancestor_node_types = {
                        "case_clause",
                    },
                    parent_node_types = {
                        "case_pattern",
                    },
                    named_child_count = 1,
                },
                binding_mutability =
                    "mutable",
            }
        )

    assert(
        general_rule_probe.syntax.node_type
            == "assignment_statement"
            and general_rule_probe.syntax.fields.operator
                == "operator"
            and general_rule_probe.syntax.children
                .names.node_type
                == "variable_list"
            and general_rule_probe.syntax.tokens.operator
                == "="
            and general_rule_probe.syntax.exclusions
                .ancestor_node_types[1]
                == "variable_declaration"
            and general_rule_probe.syntax.constraints
                .ancestor_node_types[1]
                == "case_clause"
            and general_rule_probe.syntax.constraints
                .parent_node_types[1]
                == "case_pattern"
            and general_rule_probe.syntax.constraints
                .named_child_count
                == 1
            and general_rule_probe.member.kind
                == "assignment"
            and general_rule_probe.member.language_term
                == "assignment"
            and general_rule_probe.member.owner_scope
                == "lexical"
            and general_rule_probe.member.mutability
                .binding
                == "mutable",
        "shared general Scope Member rule builder changed declaration shape"
    )

    local lua_assignment =
        lua_adapter.scope_members
            .assignments[1]

    assert(
        lua_assignment.syntax.node_type
            == "assignment_statement"
            and lua_assignment.syntax.fields.operator
                == "operator"
            and lua_assignment.syntax.children
                .names.node_type
                == "variable_list"
            and lua_assignment.syntax.children
                .values.node_type
                == "expression_list"
            and lua_assignment.syntax.exclusions
                .ancestor_node_types[1]
                == "variable_declaration"
            and lua_assignment.syntax.exclusions
                .ancestor_node_types[2]
                == "local_declaration"
            and lua_assignment.member.kind
                == "assignment"
            and lua_assignment.member.mutability
                .binding
                == "mutable",
        "Lua general Scope Member declaration migration changed assignment semantics"
    )

    local lua_field =
        lua_adapter.scope_members
            .fields[1]

    assert(
        lua_field.syntax.node_type
            == "field"
            and lua_field.syntax.fields.name
                == "name"
            and lua_field.syntax.fields.value
                == "value"
            and lua_field.syntax.tokens.operator
                == "="
            and lua_field.member.kind
                == "field"
            and lua_field.member.owner_scope
                == "structural"
            and lua_field.member.mutability
                .binding
                == "mutable",
        "Lua general Scope Member declaration migration changed field semantics"
    )

    local valid_constraints_ok,
        valid_constraints_error =
        contract.validate_syntax(
            general_rule_probe.syntax,
            "probe.syntax"
        )

    assert(
        valid_constraints_ok,
        "contract rejected valid syntax constraints: "
            .. tostring(
                valid_constraints_error
            )
    )

    local invalid_constraints =
        vim.deepcopy(
            general_rule_probe.syntax
        )

    invalid_constraints.constraints
        .named_child_count = -1

    local invalid_constraints_ok,
        invalid_constraints_error =
        contract.validate_syntax(
            invalid_constraints,
            "probe.syntax"
        )

    assert(
        not invalid_constraints_ok
            and tostring(
                invalid_constraints_error
            ):find(
                "named_child_count",
                1,
                true
            ),
        "contract accepted invalid syntax named-child constraint"
    )

    print(
        "PASS shared general Scope Member rule builder + Lua migration"
    )

    local value_rule_probe =
        scope_member_schema.rule(
            "import_statement",
            "symbol",
            {
                language_term = "import",
                value = {
                    kind = "reference",
                    language_term = "import",
                    type_label = "import",
                },
            }
        )

    assert(
        value_rule_probe.value
            and value_rule_probe.value.kind
                == "reference"
            and value_rule_probe.value.language_term
                == "import"
            and value_rule_probe.value.type_label
                == "import",
        "shared general Scope Member rule builder changed value semantics"
    )

    local function find_python_parameter_spec(
        node_type,
        member_kind,
        parameters_field
    )
        for _, spec in ipairs(
            python_adapter.scope_members
                .parameters
                or {}
        ) do
            if spec.syntax.node_type
                    == node_type
                and spec.member.kind
                    == member_kind
                and spec.syntax.fields
                    .parameters
                    == parameters_field
            then
                return spec
            end
        end

        return nil
    end

    local python_parameter =
        find_python_parameter_spec(
            "function_definition",
            "parameter",
            "parameters"
        )

    assert(
        python_parameter
            and python_parameter.syntax.children
                .names.node_type
                == "parameters"
            and python_parameter.syntax.children
                .name.node_type
                == "identifier"
            and python_parameter.member.mutability
                .binding
                == "mutable",
        "Python parameter migration changed Scope Member semantics"
    )

    local python_lambda_parameter =
        find_python_parameter_spec(
            "lambda",
            "parameter",
            "parameters"
        )

    assert(
        python_lambda_parameter
            and python_lambda_parameter.syntax.children
                .names.node_type
                == "lambda_parameters"
            and python_lambda_parameter.syntax.children
                .name.node_type
                == "identifier"
            and python_lambda_parameter.member.mutability
                .binding
                == "mutable",
        "Python lambda parameter contract changed"
    )

    for _, expected in ipairs({
        {
            node_type =
                "function_definition",
            parameters_field =
                "type_parameters",
        },
        {
            node_type =
                "class_definition",
            parameters_field =
                "type_parameters",
        },
        {
            node_type =
                "type_alias_statement",
            parameters_field =
                "left",
        },
    }) do
        local type_parameter =
            find_python_parameter_spec(
                expected.node_type,
                "type_parameter",
                expected.parameters_field
            )

        assert(
            type_parameter
                and type_parameter.syntax.children
                    .names.node_type
                    == "type_parameter"
                and type_parameter.syntax.children
                    .name.node_type
                    == "identifier"
                and type_parameter.member
                    .annotation_scope
                    == true,
            "Python PEP 695 annotation member contract changed: "
                .. expected.node_type
        )
    end

    print(
        "PASS Python PEP 695 annotation member contracts"
    )

    local python_loop =
        python_adapter.scope_members
            .loops[1]

    assert(
        python_loop.syntax.node_type
            == "for_statement"
            and python_loop.syntax.fields.name
                .field
                == "left"
            and python_loop.syntax.fields.name
                .node_type
                == "identifier"
            and python_loop.syntax.fields.iterable
                == "right"
            and python_loop.syntax.children
                .names.node_type
                == "pattern_list"
            and python_loop.syntax.children
                .name.node_type
                == "identifier"
            and python_loop.syntax.tokens.iterator
                == "in"
            and python_loop.member.kind
                == "loop_variable"
            and python_loop.member.language_term
                == "loop variable"
            and python_loop.member.mutability
                .binding
                == "conditional",
        "Python loop migration changed Scope Member semantics"
    )

    local python_import =
        python_adapter.scope_members
            .symbols[1]

    assert(
        python_import.syntax.node_type
            == "import_statement"
            and python_import.syntax.fields
                .bindings.field
                == "name"
            and python_import.syntax.fields
                .bindings.multiple
                == true
            and python_import.syntax.fields
                .bindings.node_types[1]
                == "dotted_name"
            and python_import.syntax.fields
                .bindings.node_types[2]
                == "aliased_import"
            and python_import.syntax.fields
                .bindings.node_types[3]
                == "identifier"
            and python_import.syntax.fields.name
                == "alias"
            and python_import.syntax.children
                .name.node_type
                == "identifier"
            and python_import.syntax.tokens.declaration
                == "import"
            and python_import.member.kind
                == "symbol"
            and python_import.member.mutability
                .binding
                == "immutable"
            and python_import.value.kind
                == "reference"
            and python_import.value.type_label
                == "import",
        "Python import migration changed member/value semantics"
    )

    local python_from_import =
        python_adapter.scope_members
            .symbols[2]

    assert(
        python_from_import.syntax.node_type
            == "import_from_statement"
            and python_from_import.syntax.fields
                .bindings.field
                == "name"
            and python_from_import.syntax.fields
                .bindings.multiple
                == true
            and python_from_import.syntax.fields
                .bindings.node_types[1]
                == "dotted_name"
            and python_from_import.syntax.fields
                .bindings.node_types[2]
                == "aliased_import"
            and python_from_import.syntax.fields
                .bindings.node_types[3]
                == "identifier"
            and python_from_import.syntax.fields.name
                == "alias"
            and python_from_import.syntax.children
                .name.node_type
                == "identifier"
            and python_from_import.member.kind
                == "symbol"
            and python_from_import.member.mutability
                .binding
                == "immutable"
            and python_from_import.value.kind
                == "reference"
            and python_from_import.value.type_label
                == "import",
        "Python from-import migration changed binding semantics"
    )

    local python_assignment =
        python_adapter.scope_members
            .symbols[3]

    assert(
        python_assignment.syntax.node_type
            == "assignment"
            and python_assignment.syntax.fields
                .bindings.field
                == "left"
            and python_assignment.syntax.fields
                .bindings.recursive
                .terminal_node_types[1]
                == "identifier"
            and python_assignment.syntax.fields
                .bindings.recursive
                .terminal_node_types[2]
                == "keyword_identifier"
            and python_assignment.syntax.fields
                .bindings.recursive
                .terminal_node_types[3]
                == "attribute"
            and python_assignment.syntax.fields
                .bindings.recursive
                .terminal_node_types[4]
                == "subscript"
            and python_assignment.syntax.fields
                .bindings.recursive
                .container_node_types[1]
                == "pattern_list"
            and python_assignment.syntax.fields
                .bindings.recursive
                .container_node_types[2]
                == "tuple_pattern"
            and python_assignment.syntax.fields
                .bindings.recursive
                .container_node_types[3]
                == "list_pattern"
            and python_assignment.syntax.fields
                .bindings.recursive
                .container_node_types[4]
                == "list_splat_pattern"
            and python_assignment.syntax.fields.value
                == "right"
            and python_assignment.syntax.tokens.operator
                == "="
            and python_assignment.member.kind
                == "assignment"
            and python_assignment.member.mutability
                .binding
                == "mutable",
        "Python assignment migration changed Scope Member semantics"
    )

    local python_with_binding =
        python_adapter.scope_members
            .symbols[5]

    assert(
        python_with_binding.syntax.node_type
            == "as_pattern"
            and python_with_binding.syntax.fields.name
                == "alias"
            and python_with_binding.syntax.exclusions
                .ancestor_node_types[1]
                == "case_clause"
            and python_with_binding.syntax.exclusions
                .ancestor_node_types[2]
                == "except_clause"
            and python_with_binding.member.kind
                == "assignment"
            and python_with_binding.member.language_term
                == "context manager alias"
            and python_with_binding.member.mutability
                .binding
                == "mutable",
        "Python with-alias binding contract changed"
    )

    local python_named_expression =
        python_adapter.scope_members
            .symbols[6]

    assert(
        python_named_expression.syntax.node_type
            == "named_expression"
            and python_named_expression.syntax.fields.name
                == "name"
            and python_named_expression.syntax.fields.value
                == "value"
            and python_named_expression.syntax.tokens.operator
                == ":="
            and python_named_expression.member.kind
                == "assignment"
            and python_named_expression.member.language_term
                == "named expression"
            and python_named_expression.member
                .owner_scope_excluded_construct_kinds[1]
                == "comprehension"
            and python_named_expression.member.mutability
                .binding
                == "mutable",
        "Python named-expression binding contract changed"
    )

    local python_comprehension_loop =
        python_adapter.scope_members
            .loops[2]

    assert(
        python_comprehension_loop.syntax.node_type
            == "for_in_clause"
            and python_comprehension_loop.syntax.fields
                .name.field
                == "left"
            and python_comprehension_loop.syntax.fields
                .name.node_type
                == "identifier"
            and python_comprehension_loop.member.kind
                == "loop_variable"
            and python_comprehension_loop.member.language_term
                == "comprehension variable",
        "Python comprehension loop-binding contract changed"
    )

    for _, node_type in ipairs({
        "list_comprehension",
        "set_comprehension",
        "dictionary_comprehension",
        "generator_expression",
    }) do
        local comprehension =
            python_adapter.construct_specs[
                node_type
            ]

        assert(
            comprehension.construct.kind
                == "comprehension"
                and comprehension.scope.kind
                    == "lexical"
                and comprehension.scope
                    .affects_visibility
                    == true
                and comprehension.scope
                    .owns_members
                    == true,
            "Python comprehension lexical-scope contract changed: "
                .. node_type
        )
    end

    local python_match_dotted_capture =
        python_adapter.scope_members
            .symbols[7]
    local python_match_direct_capture =
        python_adapter.scope_members
            .symbols[8]

    assert(
        python_match_dotted_capture.syntax.node_type
            == "dotted_name"
            and python_match_dotted_capture.syntax.children
                .name.node_type
                == "identifier"
            and python_match_dotted_capture.syntax.constraints
                .ancestor_node_types[1]
                == "case_clause"
            and python_match_dotted_capture.syntax.constraints
                .parent_node_types[1]
                == "case_pattern"
            and python_match_dotted_capture.syntax.constraints
                .parent_node_types[2]
                == "keyword_pattern"
            and python_match_dotted_capture.syntax.constraints
                .named_child_count
                == 1
            and python_match_dotted_capture.member.kind
                == "pattern_binding"
            and python_match_dotted_capture.member.language_term
                == "match capture"
            and python_match_dotted_capture.member.mutability
                .binding
                == "conditional",
        "Python dotted match-capture contract changed"
    )

    assert(
        python_match_direct_capture.syntax.node_type
            == "identifier"
            and python_match_direct_capture.syntax.children
                .name.node_type
                == "identifier"
            and python_match_direct_capture.syntax.constraints
                .ancestor_node_types[1]
                == "case_clause"
            and python_match_direct_capture.syntax.constraints
                .parent_node_types[1]
                == "splat_pattern"
            and python_match_direct_capture.syntax.constraints
                .parent_node_types[2]
                == "as_pattern"
            and python_match_direct_capture.syntax.constraints
                .named_child_count
                == 0
            and python_match_direct_capture.member.kind
                == "pattern_binding"
            and python_match_direct_capture.member.language_term
                == "match capture"
            and python_match_direct_capture.member.mutability
                .binding
                == "conditional",
        "Python direct match-capture contract changed"
    )

    local python_type_alias =
        python_adapter.scope_members
            .symbols[9]

    assert(
        python_type_alias.syntax.node_type
            == "type_alias_statement"
            and python_type_alias.syntax.children
                .name.node_type
                == "identifier"
            and python_type_alias.member.kind
                == "symbol"
            and python_type_alias.member.language_term
                == "type alias"
            and python_type_alias.member.mutability
                .binding
                == "mutable",
        "Python type-alias binding contract changed"
    )

    local python_exception_alias =
        python_adapter.scope_members
            .symbols[10]

    assert(
        python_exception_alias.syntax.node_type
            == "as_pattern"
            and python_exception_alias.syntax.fields.name
                == "alias"
            and python_exception_alias.syntax.constraints
                .ancestor_node_types[1]
                == "except_clause"
            and python_exception_alias.member.kind
                == "assignment"
            and python_exception_alias.member.language_term
                == "exception alias"
            and python_exception_alias.member.mutability
                .binding
                == "conditional"
            and python_exception_alias.member.visibility.range
                == "structural_scope",
        "Python exception-alias binding contract changed"
    )

    local python_return =
        python_adapter.scope_members
            .returns[1]

    assert(
        python_return.syntax.node_type
            == "return_statement"
            and python_return.syntax.tokens.start
                == "return"
            and python_return.member.kind
                == "return_value"
            and python_return.member.language_term
                == "return value",
        "Python return migration changed Scope Member semantics"
    )

    print(
        "PASS Python general Scope Member rules + value semantics"
    )

    local construct_probe =
        construct_schema.rule(
            "number",
            "literal",
            {
                language_term = "number",
                label = "Number",
                construct_mutability = {
                    state = "immutable",
                    shape = "fixed",
                },
                value = {
                    kind = "scalar",
                    language_term = "number",
                    type_label = "number",
                },
            }
        )

    assert(
        construct_probe.syntax.node_type
            == "number"
            and construct_probe.construct.kind
                == "literal"
            and construct_probe.construct.language_term
                == "number"
            and construct_probe.construct.label
                == "Number"
            and construct_probe.construct.mutability.state
                == "immutable"
            and construct_probe.construct.mutability.shape
                == "fixed"
            and construct_probe.value.kind
                == "scalar"
            and construct_probe.value.type_label
                == "number",
        "shared construct rule builder changed simple construct semantics"
    )

    local lua_number =
        lua_adapter.construct_specs[
            "number"
        ]

    assert(
        lua_number.syntax.node_type
            == "number"
            and lua_number.construct.kind
                == "literal"
            and lua_number.construct.mutability.state
                == "immutable"
            and lua_number.value.kind
                == "scalar"
            and lua_number.value.mutability.state
                == "immutable",
        "Lua simple construct migration changed literal semantics"
    )

    local python_import_construct =
        python_adapter.construct_specs[
            "import_statement"
        ]

    assert(
        python_import_construct.syntax.node_type
            == "import_statement"
            and python_import_construct.syntax.tokens.start
                == "import"
            and python_import_construct.construct.kind
                == "declaration"
            and python_import_construct.construct.language_term
                == "import"
            and python_import_construct.value.kind
                == "reference"
            and python_import_construct.value.type_label
                == "import",
        "Python simple construct migration changed import semantics"
    )

    local python_call_construct =
        python_adapter.construct_specs[
            "call"
        ]

    assert(
        python_call_construct.syntax.fields.function_name
            == "function"
            and python_call_construct.syntax.fields.arguments
                == "arguments"
            and python_call_construct.construct.kind
                == "call"
            and python_call_construct.value.kind
                == "call"
            and python_call_construct.value.type_label
                == "call",
        "Python simple construct migration changed call semantics"
    )

    local python_type_alias_construct =
        python_adapter.construct_specs[
            "type_alias_statement"
        ]

    assert(
        python_type_alias_construct.syntax.node_type
            == "type_alias_statement"
            and python_type_alias_construct.syntax.fields.left
                == "left"
            and python_type_alias_construct.syntax.fields.right
                == "right"
            and python_type_alias_construct.syntax.tokens.start
                == "type"
            and python_type_alias_construct.syntax.tokens.operator
                == "="
            and python_type_alias_construct.construct.kind
                == "declaration"
            and python_type_alias_construct.construct.language_term
                == "type alias",
        "Python type-alias construct contract changed"
    )

    local python_named_expression_construct =
        python_adapter.construct_specs[
            "named_expression"
        ]

    assert(
        python_named_expression_construct.syntax.node_type
            == "named_expression"
            and python_named_expression_construct.syntax.fields.name
                == "name"
            and python_named_expression_construct.syntax.fields.value
                == "value"
            and python_named_expression_construct.syntax.tokens.operator
                == ":="
            and python_named_expression_construct.construct.kind
                == "assignment"
            and python_named_expression_construct.construct.language_term
                == "named expression",
        "Python named-expression construct contract changed"
    )

    print(
        "PASS shared construct rule builder + Lua/Python simple constructs"
    )

    local rich_construct_probe =
        construct_schema.rule(
            "function_definition",
            "function",
            {
                fields = {
                    name = "name",
                },
                tokens = {
                    start = "def",
                    body_open = ":",
                },
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
                signature = {
                    strategy = "first_line",
                    name_pattern =
                        "^%s*def%s+([%w_]+)",
                },
                markers = {
                    required = {
                        "start",
                        "body_open",
                    },
                    total_required = 2,
                },
                branch = {
                    grouped = false,
                },
            }
        )

    assert(
        rich_construct_probe.scope.kind
            == "lexical"
            and rich_construct_probe.scope
                .affects_visibility
                == true
            and rich_construct_probe.scope
                .owns_members
                == true
            and rich_construct_probe.signature
                .strategy
                == "first_line"
            and rich_construct_probe.markers
                .required[1]
                == "start"
            and rich_construct_probe.markers
                .total_required
                == 2
            and rich_construct_probe.branch
                .grouped
                == false,
        "shared construct rule builder changed rich contract passthrough"
    )

    local lua_function_construct =
        lua_adapter.construct_specs[
            "function_declaration"
        ]

    assert(
        lua_function_construct.scope.kind
            == "lexical"
            and lua_function_construct.signature
                .strategy
                == "first_line"
            and lua_function_construct.signature
                .local_name_pattern
                ~= nil
            and lua_function_construct.markers
                .required[4]
                == "scope_close"
            and lua_function_construct.markers
                .optional[1]
                == "local_prefix"
            and lua_function_construct.value.kind
                == "function"
            and lua_function_construct.construct
                .mutability.state
                == "immutable",
        "Lua scoped construct migration changed function semantics"
    )

    local lua_branch_construct =
        lua_adapter.construct_specs[
            "if_statement"
        ]

    assert(
        lua_branch_construct.branch.grouped
            == true
            and lua_branch_construct.branch
                .alternatives[1].syntax.node_type
                == "elseif_statement"
            and lua_branch_construct.branch
                .alternatives[2].syntax.node_type
                == "else_statement"
            and lua_branch_construct.scope.kind
                == "lexical",
        "Lua scoped construct migration changed branch semantics"
    )

    local python_function_construct =
        python_adapter.construct_specs[
            "function_definition"
        ]

    assert(
        python_function_construct.scope.kind
            == "lexical"
            and python_function_construct.scope
                .owns_members
                == true
            and python_function_construct.signature
                .name_pattern
                == "^%s*def%s+([%w_]+)"
            and python_function_construct.markers
                .total_required
                == 4,
        "Python scoped construct migration changed function semantics"
    )

    local python_lambda_construct =
        python_adapter.construct_specs[
            "lambda"
        ]

    assert(
        python_lambda_construct.syntax.node_type
            == "lambda"
            and python_lambda_construct.syntax.fields
                .parameters
                == "parameters"
            and python_lambda_construct.syntax.fields.body
                == "body"
            and python_lambda_construct.syntax.tokens.start
                == "lambda"
            and python_lambda_construct.syntax.tokens.body_open
                == ":"
            and python_lambda_construct.construct.kind
                == "function"
            and python_lambda_construct.construct.language_term
                == "lambda"
            and python_lambda_construct.scope.kind
                == "lexical"
            and python_lambda_construct.scope
                .affects_visibility
                == true
            and python_lambda_construct.scope
                .owns_members
                == true
            and python_lambda_construct.value.kind
                == "function",
        "Python lambda construct contract changed"
    )

    local python_for_construct =
        python_adapter.construct_specs[
            "for_statement"
        ]
    local python_while_construct =
        python_adapter.construct_specs[
            "while_statement"
        ]
    local python_with_construct =
        python_adapter.construct_specs[
            "with_statement"
        ]
    local python_match_construct =
        python_adapter.construct_specs[
            "match_statement"
        ]
    local python_case_construct =
        python_adapter.construct_specs[
            "case_clause"
        ]

    -- The active Python adapter is adapter_targeted, which deliberately
    -- upgrades Python block constructs that do not create namespaces into
    -- member-owning structural scopes after loading adapter_visible. Assert
    -- the registered adapter's real policy here rather than adapter_visible's
    -- pre-wrapper defaults.
    assert(
        python_for_construct.scope.kind
            == "structural"
            and python_for_construct.scope
                .affects_visibility
                == true
            and python_for_construct.scope
                .owns_members
                == true
            and python_for_construct.markers
                .required[2]
                == "iterator"
            and python_while_construct.syntax.fields
                .condition
                == "condition"
            and python_while_construct.scope.kind
                == "structural"
            and python_while_construct.scope
                .affects_visibility
                == true
            and python_while_construct.scope
                .owns_members
                == true
            and python_with_construct.syntax.children
                .clause.node_type
                == "with_clause"
            and python_with_construct.syntax.fields.body
                == "body"
            and python_with_construct.scope.kind
                == "structural"
            and python_with_construct.scope
                .affects_visibility
                == true
            and python_with_construct.scope
                .owns_members
                == true
            and python_match_construct.syntax.fields
                .subject
                == "subject"
            and python_match_construct.syntax.fields.body
                == "body"
            and python_match_construct.scope.kind
                == "structural"
            and python_match_construct.scope
                .affects_visibility
                == true
            and python_match_construct.scope
                .owns_members
                == true
            and python_case_construct.syntax.fields.guard
                == "guard"
            and python_case_construct.syntax.fields.consequence
                == "consequence"
            and python_case_construct.syntax.children.pattern
                .node_type
                == "case_pattern"
            and python_case_construct.syntax.tokens.start
                == "case"
            and python_case_construct.syntax.tokens.branch_open
                == ":"
            and python_case_construct.scope.kind
                == "structural"
            and python_case_construct.scope
                .affects_visibility
                == true
            and python_case_construct.scope
                .owns_members
                == true,
        "Python targeted structural-member scope policy changed"
    )

    print(
        "PASS shared rich construct schema + Lua/Python scoped constructs"
    )

    local define_probe_specs = {}

    local define_probe =
        construct_schema.define(
            define_probe_specs,
            "compound_statement",
            "block",
            {
                language_term =
                    "compound block",
                label = "Block",
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
            }
        )

    assert(
        define_probe_specs.compound_statement
            == define_probe
            and define_probe.syntax.node_type
                == "compound_statement"
            and define_probe.construct.kind
                == "block"
            and define_probe.scope.kind
                == "lexical",
        "shared construct define helper changed incremental authoring semantics"
    )

    local c_function_construct =
        c.construct_specs[
            "function_definition"
        ]

    assert(
        c_function_construct.syntax.fields
            .declarator
            == "declarator"
            and c_function_construct.scope.kind
                == "lexical"
            and c_function_construct.scope
                .affects_visibility
                == true
            and c_function_construct.scope
                .owns_members
                == true
            and c_function_construct.signature
                .strategy
                == "first_line",
        "C shared construct migration changed function semantics"
    )

    local c_if_construct =
        c.construct_specs[
            "if_statement"
        ]

    assert(
        c_if_construct.scope.kind
            == "structural"
            and c_if_construct.scope
                .affects_visibility
                == true
            and c_if_construct.scope
                .owns_members
                == false,
        "C shared construct migration changed structural scope semantics"
    )

    local cpp_namespace_construct =
        cpp.construct_specs[
            "namespace_definition"
        ]

    assert(
        cpp_namespace_construct.syntax.fields
            .name
            == "name"
            and cpp_namespace_construct.scope.kind
                == "lexical"
            and cpp_namespace_construct.scope
                .owns_members
                == true,
        "C++ shared construct migration changed namespace semantics"
    )

    local cpp_range_for_construct =
        cpp.construct_specs[
            "for_range_loop"
        ]

    assert(
        cpp_range_for_construct.syntax.fields
            .declarator
            == "declarator"
            and cpp_range_for_construct.scope.kind
                == "structural"
            and cpp_range_for_construct.scope
                .affects_visibility
                == true
            and cpp_range_for_construct.scope
                .owns_members
                == false,
        "C++ shared construct migration changed range-for semantics"
    )

    print(
        "PASS shared construct define helper + C/C++ migration"
    )

    -- Permanent panels are presentation sections, not claims about a
    -- program's compiled architecture, live stack, or allocated objects.
    -- Both adapters must keep the ASM section order, including empty panels.
    local section_layout = require("tracker_hud.section_layout")
    local inspect_mode = require("tracker_hud.inspect_mode")
    local expected_order = {
        "scope", "scope_members", "registers", "events",
        "stack", "heap", "warnings",
    }
    -- The ASM master adapter applies base_presentation during variant
    -- configuration. Mirror that normal configured state in this headless
    -- section test without requiring a user buffer or mutating the master.
    local asm = vim.deepcopy(require("tracker_hud.adapters.asm.adapter"))
    asm.presentation = vim.deepcopy(asm.base_presentation)
    for _, adapter in ipairs({ c, cpp, asm }) do
        local layout = section_layout.resolve(adapter)
        local order = layout.order
        assert(#order == #expected_order,
            adapter.name .. " section count mismatch")
        for index, id in ipairs(expected_order) do
            assert(order[index] == id,
                adapter.name .. " section order differs at " .. index)
            assert(layout.by_id[id] and layout.by_id[id].id == id,
                adapter.name .. " missing permanent section " .. id)
        end

        assert(inspect_mode.set_modes(layout.order),
            adapter.name .. " Inspect Mode section cycle failed")
        local seen = {}
        for _ = 1, #expected_order do
            local mode = inspect_mode.get_mode()
            assert(not seen[mode], adapter.name .. " repeat in Inspect cycle")
            seen[mode] = true
            inspect_mode.cycle_mode()
        end
        for _, id in ipairs(expected_order) do
            assert(seen[id], adapter.name .. " Inspect Mode cannot reach " .. id)
        end
        print("PASS " .. adapter.name .. " persistent section order / Inspect cycle")
    end
    assert(not c.capabilities.registers and not c.capabilities.heap,
        "persistent C panels must not claim registers or heap inference")
    assert(not cpp.capabilities.registers and not cpp.capabilities.heap,
        "persistent C++ panels must not claim registers or heap inference")

    print("PASS C/C++ adapter isolation")

    local parser_identity_probe =
        vim.deepcopy(c)

    parser_identity_probe.instruction_parser = {
        module = "tracker_hud.tests.parser_probe",
        function_name = "parse_instruction",
        cache_identity = "node",
    }

    local parser_identity_valid,
        parser_identity_error =
        contract.validate_adapter(
            parser_identity_probe
        )

    assert(
        parser_identity_valid,
        "node-stable instruction parser contract rejected: "
            .. tostring(
                parser_identity_error
            )
    )

    parser_identity_probe
        .instruction_parser
        .cache_identity =
        "unsafe"

    local invalid_identity,
        invalid_identity_error =
        contract.validate_adapter(
            parser_identity_probe
        )

    assert(
        not invalid_identity
            and tostring(
                invalid_identity_error
            ):find(
                "cache_identity",
                1,
                true
            ),
        "invalid instruction parser cache identity was accepted"
    )

    print(
        "PASS instruction parser cache-identity contract"
    )
end

local ok, err = pcall(run)
if not ok then
    vim.api.nvim_err_writeln("FAIL Tracker_HUD adapter smoke: " .. tostring(err))
    vim.cmd("cquit 1")
else
    print("PASS Tracker_HUD adapter contract smoke")
    vim.cmd("qa!")
end
