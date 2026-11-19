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
        local parameter_spec = nil
        for _, spec in ipairs(adapter.scope_members.symbols or {}) do
            if spec.syntax.node_type == "parameter_declaration" then
                parameter_spec = spec
                break
            end
        end
        assert(parameter_spec
            and parameter_spec.syntax.fields.name == "declarator"
            and parameter_spec.member.kind == "parameter",
            adapter.name .. " must expose declared parameter names")
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

    print(
        "PASS shared Scope Member adapter schema + named builder"
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

    local python_parameter =
        python_adapter.scope_members
            .parameters[1]

    assert(
        python_parameter.syntax.node_type
            == "function_definition"
            and python_parameter.syntax.fields
                .parameters
                == "parameters"
            and python_parameter.syntax.children
                .names.node_type
                == "parameters"
            and python_parameter.member.kind
                == "parameter"
            and python_parameter.member.mutability
                .binding
                == "mutable",
        "Python parameter migration changed Scope Member semantics"
    )

    local python_loop =
        python_adapter.scope_members
            .loops[1]

    assert(
        python_loop.syntax.node_type
            == "for_statement"
            and python_loop.syntax.fields.name
                == "left"
            and python_loop.syntax.fields.iterable
                == "right"
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
            and python_import.syntax.children
                .name.node_types[1]
                == "dotted_name"
            and python_import.syntax.children
                .name.node_types[2]
                == "aliased_import"
            and python_import.syntax.children
                .name.node_types[3]
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

    local python_assignment =
        python_adapter.scope_members
            .symbols[3]

    assert(
        python_assignment.syntax.node_type
            == "assignment"
            and python_assignment.syntax.fields.name
                == "left"
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
