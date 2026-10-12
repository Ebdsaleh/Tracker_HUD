-- lua/tracker_hud/adapters/python/adapter_visible.lua
--
-- Python adapter visibility-first MVP.
--
-- This adapter is intentionally small and follows the same working principles as
-- the Lua adapter: declare Tree-sitter constructs, lexical scopes, and scope
-- members using only contract-supported Tracker_HUD vocabulary.
--
-- It also declares class/function range scopes so Python still produces a useful
-- Scope panel even when vim.treesitter.get_node() does not return a precise
-- cursor node for this grammar/environment.

local M = {}

M.contract_version = 1
M.name = "python"

M.filetypes = {
    "python",
    "python3",
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

M.range_scopes = {
    {
        syntax = {
            node_type = "function_definition",
            fields = {
                name = "name",
            },
        },
        label = "Function",
        kind = "function",
        range_strategy = "until_next_peer",
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    },
    {
        syntax = {
            node_type = "class_definition",
            fields = {
                name = "name",
            },
        },
        label = "Class",
        kind = "class",
        range_strategy = "until_next_peer",
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    },
}

M.construct_specs = {
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
    },

    ["class_definition"] = {
        syntax = {
            node_type = "class_definition",
            fields = {
                name = "name",
                body = "body",
            },
            tokens = {
                start = "class",
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
            kind = "object",
            language_term = "class",
            type_label = "class",
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
            total_required = 2,
        },
    },

    ["function_definition"] = {
        syntax = {
            node_type = "function_definition",
            fields = {
                name = "name",
                parameters = "parameters",
                body = "body",
            },
            tokens = {
                start = "def",
                args_open = "(",
                args_close = ")",
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
            total_required = 4,
        },
    },

    ["import_statement"] = {
        syntax = {
            node_type = "import_statement",
            tokens = {
                start = "import",
            },
        },
        construct = {
            kind = "declaration",
            language_term = "import",
            label = "Import",
        },
        value = {
            kind = "reference",
            language_term = "import",
            type_label = "import",
        },
    },

    ["import_from_statement"] = {
        syntax = {
            node_type = "import_from_statement",
            tokens = {
                start = "from",
                import_token = "import",
            },
        },
        construct = {
            kind = "declaration",
            language_term = "from import",
            label = "From Import",
        },
        value = {
            kind = "reference",
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

    ["if_statement"] = {
        syntax = {
            node_type = "if_statement",
            fields = {
                condition = "condition",
                consequence = "consequence",
                alternative = "alternative",
            },
            tokens = {
                start = "if",
                branch_open = ":",
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
        markers = {
            required = {
                "start",
                "branch_open",
            },
            total_required = 2,
        },
    },

    ["for_statement"] = {
        syntax = {
            node_type = "for_statement",
            fields = {
                left = "left",
                right = "right",
                body = "body",
            },
            tokens = {
                start = "for",
                iterator = "in",
                body_open = ":",
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
            total_required = 3,
        },
    },

    ["try_statement"] = {
        syntax = {
            node_type = "try_statement",
            fields = {
                body = "body",
            },
            tokens = {
                start = "try",
                body_open = ":",
            },
        },
        construct = {
            kind = "block",
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
            total_required = 2,
        },
    },

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
            kind = "call",
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

    ["identifier"] = {
        syntax = {
            node_type = "identifier",
        },
        construct = {
            kind = "symbol",
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
        },
    },
}

M.scope_members = {
    functions = {
        {
            syntax = {
                node_type = "class_definition",
                fields = {
                    name = "name",
                },
            },
            member = {
                kind = "symbol",
                language_term = "class",
                owner_scope = "parent_lexical",
                mutability = {
                    binding = "mutable",
                },
            },
        },
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

    loops = {
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

    symbols = {
        {
            syntax = {
                node_type = "import_statement",
                children = {
                    name = {
                        node_types = {
                            "dotted_name",
                            "aliased_import",
                            "identifier",
                        },
                    },
                },
                tokens = {
                    declaration = "import",
                },
            },
            member = {
                kind = "symbol",
                language_term = "import",
                owner_scope = "lexical",
                mutability = {
                    binding = "immutable",
                },
            },
            value = {
                kind = "reference",
                language_term = "import",
                type_label = "import",
            },
        },
        {
            syntax = {
                node_type = "import_from_statement",
                children = {
                    name = {
                        node_types = {
                            "dotted_name",
                            "aliased_import",
                            "identifier",
                        },
                    },
                },
                tokens = {
                    declaration = "from",
                    import_token = "import",
                },
            },
            member = {
                kind = "symbol",
                language_term = "from import",
                owner_scope = "lexical",
                mutability = {
                    binding = "immutable",
                },
            },
            value = {
                kind = "reference",
                language_term = "from import",
                type_label = "import",
            },
        },
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
}

return M
