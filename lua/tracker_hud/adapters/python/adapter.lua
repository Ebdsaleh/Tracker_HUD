-- lua/tracker_hud/adapters/python/adapter.lua
--
-- Python Tree-sitter adapter.
--
-- Python is the fast-win high-level-language adapter after the much harder ASM
-- work. This first tranche deliberately focuses on reliable source structure:
-- modules, imports, classes, functions, control-flow statements, assignments,
-- calls, returns, and raises.
--
-- Adapters describe language facts. They are not linters or LSPs.

local M = {}

M.contract_version = 1

M.name = "python"

M.filetypes = {
    "python",
}

M.presentation = {
    sections = {
        order = {
            "scope",
            "scope_members",
            "warnings",
        },
    },
}

M.capabilities = {
    lexical_scopes = true,
    structural_scopes = true,
    members = true,
    values = true,
    source_jump = true,
}

M.construct_specs = {

    --------------------------------------------------------------------------
    -- Module / top level
    --------------------------------------------------------------------------

    ["module"] = {
        syntax = {
            node_type = "module",
        },

        construct = {
            kind = "module",
            language_term = "module",
            label = "Module",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "module",
            language_term = "module",
            type_label = "module",
        },
    },

    --------------------------------------------------------------------------
    -- Definitions
    --------------------------------------------------------------------------

    ["class_definition"] = {
        syntax = {
            node_type = "class_definition",

            fields = {
                name = "name",
                superclasses = "superclasses",
                body = "body",
            },

            tokens = {
                start = "class",
                base_open = "(",
                base_close = ")",
                body_open = ":",
            },
        },

        construct = {
            kind = "class",
            language_term = "class",
            label = "Class",

            mutability = {
                state = "mutable",
                shape = "extensible",
            },
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "class",
            language_term = "class",
            type_label = "class",

            mutability = {
                state = "mutable",
                shape = "extensible",
            },
        },

        signature = {
            strategy = "first_line",
            name_pattern = "^%s*class%s+([%w_]+)",
        },

        markers = {
            required = {
                "start",
                "body_open",
            },

            optional = {
                "base_open",
                "base_close",
            },

            total_required = 2,
        },
    },

    ["function_definition"] = {
        syntax = {
            node_type = "function_definition",

            fields = {
                name = "name",
                parameters = "parameters",
                return_type = "return_type",
                body = "body",
            },

            tokens = {
                start = "def",
                args_open = "(",
                args_close = ")",
                return_arrow = "->",
                body_open = ":",
            },
        },

        construct = {
            kind = "function",
            language_term = "function",
            label = "Function",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        value = {
            kind = "function",
            language_term = "function",
            type_label = "function",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        signature = {
            strategy = "first_line",
            name_pattern = "^%s*def%s+([%w_]+)",
        },

        markers = {
            required = {
                "start",
                "args_open",
                "args_close",
                "body_open",
            },

            optional = {
                "return_arrow",
            },

            total_required = 4,
        },
    },

    ["decorated_definition"] = {
        syntax = {
            node_type = "decorated_definition",

            children = {
                decorators = {
                    node_type = "decorator",
                    multiple = true,
                    optional = true,
                },

                definition = {
                    node_types = {
                        "class_definition",
                        "function_definition",
                    },
                },
            },
        },

        construct = {
            kind = "decorated_definition",
            language_term = "decorated definition",
            label = "Decorated Definition",
        },

        scope = {
            kind = "structural",
            affects_visibility = false,
            owns_members = false,
        },
    },

    ["decorator"] = {
        syntax = {
            node_type = "decorator",

            tokens = {
                start = "@",
            },
        },

        construct = {
            kind = "decorator",
            language_term = "decorator",
            label = "Decorator",
        },

        value = {
            kind = "decorator",
            language_term = "decorator",
            type_label = "decorator",
        },
    },

    --------------------------------------------------------------------------
    -- Imports
    --------------------------------------------------------------------------

    ["import_statement"] = {
        syntax = {
            node_type = "import_statement",

            tokens = {
                start = "import",
            },
        },

        construct = {
            kind = "import",
            language_term = "import",
            label = "Import",
        },

        value = {
            kind = "import",
            language_term = "import",
            type_label = "import",
        },
    },

    ["import_from_statement"] = {
        syntax = {
            node_type = "import_from_statement",

            fields = {
                module_name = "module_name",
                name = "name",
            },

            tokens = {
                start = "from",
                import_token = "import",
            },
        },

        construct = {
            kind = "import",
            language_term = "from import",
            label = "From Import",
        },

        value = {
            kind = "import",
            language_term = "from import",
            type_label = "import",
        },

        markers = {
            required = {
                "start",
                "import_token",
            },

            total_required = 2,
        },
    },

    --------------------------------------------------------------------------
    -- Branches
    --------------------------------------------------------------------------

    ["if_statement"] = {
        syntax = {
            node_type = "if_statement",

            fields = {
                condition = "condition",
                consequence = "consequence",
                alternative = "alternative",
            },

            children = {
                alternatives = {
                    node_types = {
                        "elif_clause",
                        "else_clause",
                    },
                    multiple = true,
                    optional = true,
                },
            },

            tokens = {
                start = "if",
                branch_open = ":",
                alternative_if = "elif",
                alternative = "else",
            },
        },

        construct = {
            kind = "branch",
            language_term = "if",
            label = "If",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        branch = {
            grouped = true,

            alternatives = {
                {
                    syntax = {
                        node_type = "elif_clause",
                    },
                    label = "Elif",
                },

                {
                    syntax = {
                        node_type = "else_clause",
                    },
                    label = "Else",
                },
            },
        },

        markers = {
            required = {
                "start",
                "branch_open",
            },

            optional = {
                "alternative_if",
                "alternative",
            },

            total_required = 2,
        },
    },

    --------------------------------------------------------------------------
    -- Loops / compound statements
    --------------------------------------------------------------------------

    ["for_statement"] = {
        syntax = {
            node_type = "for_statement",

            fields = {
                left = "left",
                right = "right",
                body = "body",
                alternative = "alternative",
            },

            tokens = {
                start = "for",
                iterator = "in",
                body_open = ":",
                alternative = "else",
            },
        },

        construct = {
            kind = "loop",
            language_term = "for",
            label = "For",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        markers = {
            required = {
                "start",
                "iterator",
                "body_open",
            },

            optional = {
                "alternative",
            },

            total_required = 3,
        },
    },

    ["while_statement"] = {
        syntax = {
            node_type = "while_statement",

            fields = {
                condition = "condition",
                body = "body",
                alternative = "alternative",
            },

            tokens = {
                start = "while",
                body_open = ":",
                alternative = "else",
            },
        },

        construct = {
            kind = "loop",
            language_term = "while",
            label = "While",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        markers = {
            required = {
                "start",
                "body_open",
            },

            optional = {
                "alternative",
            },

            total_required = 2,
        },
    },

    ["try_statement"] = {
        syntax = {
            node_type = "try_statement",

            fields = {
                body = "body",
            },

            children = {
                handlers = {
                    node_type = "except_clause",
                    multiple = true,
                    optional = true,
                },

                finalizer = {
                    node_type = "finally_clause",
                    optional = true,
                },

                alternative = {
                    node_type = "else_clause",
                    optional = true,
                },
            },

            tokens = {
                start = "try",
                body_open = ":",
                except_token = "except",
                finally_token = "finally",
                else_token = "else",
            },
        },

        construct = {
            kind = "exception_flow",
            language_term = "try",
            label = "Try",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        markers = {
            required = {
                "start",
                "body_open",
            },

            optional = {
                "except_token",
                "finally_token",
                "else_token",
            },

            total_required = 2,
        },
    },

    ["with_statement"] = {
        syntax = {
            node_type = "with_statement",

            fields = {
                body = "body",
            },

            tokens = {
                start = "with",
                body_open = ":",
            },
        },

        construct = {
            kind = "context_manager",
            language_term = "with",
            label = "With",
        },

        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },

        markers = {
            required = {
                "start",
                "body_open",
            },

            total_required = 2,
        },
    },

    --------------------------------------------------------------------------
    -- Statements / operations
    --------------------------------------------------------------------------

    ["assignment"] = {
        syntax = {
            node_type = "assignment",

            fields = {
                left = "left",
                right = "right",
            },

            tokens = {
                operator = "=",
            },
        },

        construct = {
            kind = "assignment",
            language_term = "assignment",
            label = "Assignment",
        },
    },

    ["augmented_assignment"] = {
        syntax = {
            node_type = "augmented_assignment",

            fields = {
                left = "left",
                operator = "operator",
                right = "right",
            },
        },

        construct = {
            kind = "assignment",
            language_term = "augmented assignment",
            label = "Augmented Assignment",
        },
    },

    ["return_statement"] = {
        syntax = {
            node_type = "return_statement",

            tokens = {
                start = "return",
            },
        },

        construct = {
            kind = "return",
            language_term = "return",
            label = "Return",
        },
    },

    ["raise_statement"] = {
        syntax = {
            node_type = "raise_statement",

            tokens = {
                start = "raise",
            },
        },

        construct = {
            kind = "raise",
            language_term = "raise",
            label = "Raise",
        },
    },

    ["call"] = {
        syntax = {
            node_type = "call",

            fields = {
                function_name = "function",
                arguments = "arguments",
            },
        },

        construct = {
            kind = "call",
            language_term = "function call",
            label = "Call",
        },

        value = {
            kind = "call",
            language_term = "function call",
            type_label = "call",
        },
    },

    --------------------------------------------------------------------------
    -- Common values
    --------------------------------------------------------------------------

    ["identifier"] = {
        syntax = {
            node_type = "identifier",
        },

        construct = {
            kind = "identifier",
            language_term = "identifier",
            label = "Identifier",
        },

        value = {
            kind = "reference",
            language_term = "identifier",
            type_label = "identifier",
        },
    },

    ["string"] = {
        syntax = {
            node_type = "string",
        },

        construct = {
            kind = "literal",
            language_term = "string",
            label = "String",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "string",
            type_label = "string",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },

    ["integer"] = {
        syntax = {
            node_type = "integer",
        },

        construct = {
            kind = "literal",
            language_term = "integer",
            label = "Integer",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "integer",
            type_label = "integer",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },

    ["float"] = {
        syntax = {
            node_type = "float",
        },

        construct = {
            kind = "literal",
            language_term = "float",
            label = "Float",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "float",
            type_label = "float",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },

    ["true"] = {
        syntax = {
            node_type = "true",

            tokens = {
                literal = "True",
            },
        },

        construct = {
            kind = "literal",
            language_term = "boolean",
            label = "Boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "boolean",
            type_label = "boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },

    ["false"] = {
        syntax = {
            node_type = "false",

            tokens = {
                literal = "False",
            },
        },

        construct = {
            kind = "literal",
            language_term = "boolean",
            label = "Boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "boolean",
            type_label = "boolean",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },

    ["none"] = {
        syntax = {
            node_type = "none",

            tokens = {
                literal = "None",
            },
        },

        construct = {
            kind = "literal",
            language_term = "none",
            label = "None",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },

        value = {
            kind = "scalar",
            language_term = "none",
            type_label = "none",

            mutability = {
                state = "immutable",
                shape = "fixed",
            },
        },
    },
}

M.scope_members = {

    --------------------------------------------------------------------------
    -- Imports
    --------------------------------------------------------------------------

    imports = {
        {
            syntax = {
                node_type = "import_statement",

                tokens = {
                    declaration = "import",
                },
            },

            member = {
                kind = "import",
                language_term = "import",
                owner_scope = "lexical",

                mutability = {
                    binding = "immutable",
                },
            },
        },

        {
            syntax = {
                node_type = "import_from_statement",

                tokens = {
                    declaration = "from",
                    import_token = "import",
                },
            },

            member = {
                kind = "import",
                language_term = "from import",
                owner_scope = "lexical",

                mutability = {
                    binding = "immutable",
                },
            },
        },
    },

    --------------------------------------------------------------------------
    -- Definitions
    --------------------------------------------------------------------------

    classes = {
        {
            syntax = {
                node_type = "class_definition",

                fields = {
                    name = "name",
                },
            },

            member = {
                kind = "class",
                language_term = "class",
                owner_scope = "parent_lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },

    functions = {
        {
            syntax = {
                node_type = "function_definition",

                fields = {
                    name = "name",
                },
            },

            member = {
                kind = "function",
                language_term = "function",
                owner_scope = "parent_lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },

    --------------------------------------------------------------------------
    -- Parameters and local names
    --------------------------------------------------------------------------

    parameters = {
        {
            syntax = {
                node_type = "function_definition",

                fields = {
                    parameters = "parameters",
                },

                children = {
                    names = {
                        node_type = "parameters",
                    },
                },
            },

            member = {
                kind = "parameter",
                language_term = "parameter",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },

    assignments = {
        {
            syntax = {
                node_type = "assignment",

                fields = {
                    name = "left",
                    value = "right",
                },

                tokens = {
                    operator = "=",
                },
            },

            member = {
                kind = "assignment",
                language_term = "assignment",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },

        {
            syntax = {
                node_type = "augmented_assignment",

                fields = {
                    name = "left",
                    operator = "operator",
                    value = "right",
                },
            },

            member = {
                kind = "assignment",
                language_term = "augmented assignment",
                owner_scope = "lexical",

                mutability = {
                    binding = "mutable",
                },
            },
        },
    },

    returns = {
        {
            syntax = {
                node_type = "return_statement",

                tokens = {
                    start = "return",
                },
            },

            member = {
                kind = "return_value",
                language_term = "return value",
                owner_scope = "lexical",
            },
        },
    },

    raises = {
        {
            syntax = {
                node_type = "raise_statement",

                tokens = {
                    start = "raise",
                },
            },

            member = {
                kind = "raise",
                language_term = "raise",
                owner_scope = "lexical",
            },
        },
    },

    loop_variables = {
        {
            syntax = {
                node_type = "for_statement",

                fields = {
                    name = "left",
                    iterable = "right",
                },

                tokens = {
                    iterator = "in",
                },
            },

            member = {
                kind = "loop_variable",
                language_term = "loop variable",
                owner_scope = "lexical",

                mutability = {
                    binding = "conditional",
                },
            },
        },
    },
}

return M
