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
--
-- Python note: class/function/module introduce member scopes. Control-flow
-- blocks such as if/for/try are visible constructs, but they do not create a
-- new local/member scope in Python.

local scope_member_schema =
    require("tracker_hud.adapters.scope_member_schema")
local construct_schema =
    require("tracker_hud.adapters.construct_schema")

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

    ["import_statement"] =
        construct_schema.rule(
            "import_statement",
            "declaration",
            {
                language_term = "import",
                label = "Import",
                tokens = {
                    start = "import",
                },
                value = {
                    kind = "reference",
                    language_term = "import",
                    type_label = "import",
                },
            }
        ),

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
            kind = "structural",
            affects_visibility = false,
            owns_members = false,
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
            kind = "structural",
            affects_visibility = false,
            owns_members = false,
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
            kind = "structural",
            affects_visibility = false,
            owns_members = false,
        },
        markers = {
            required = {
                "start",
                "body_open",
            },
            total_required = 2,
        },
    },

    ["assignment"] =
        construct_schema.rule(
            "assignment",
            "assignment",
            {
                language_term =
                    "assignment",
                label = "Assignment",
                fields = {
                    left = "left",
                    right = "right",
                },
                tokens = {
                    operator = "=",
                },
            }
        ),


    ["augmented_assignment"] =
        construct_schema.rule(
            "augmented_assignment",
            "assignment",
            {
                language_term =
                    "augmented assignment",
                label =
                    "Augmented Assignment",
                fields = {
                    left = "left",
                    operator = "operator",
                    right = "right",
                },
            }
        ),


    ["return_statement"] =
        construct_schema.rule(
            "return_statement",
            "return",
            {
                language_term = "return",
                label = "Return",
                tokens = {
                    start = "return",
                },
            }
        ),


    ["raise_statement"] =
        construct_schema.rule(
            "raise_statement",
            "call",
            {
                language_term = "raise",
                label = "Raise",
                tokens = {
                    start = "raise",
                },
            }
        ),


    ["call"] =
        construct_schema.rule(
            "call",
            "call",
            {
                language_term =
                    "function call",
                label = "Call",
                fields = {
                    function_name =
                        "function",
                    arguments =
                        "arguments",
                },
                value = {
                    kind = "call",
                    language_term =
                        "function call",
                    type_label = "call",
                },
            }
        ),


    ["identifier"] =
        construct_schema.rule(
            "identifier",
            "symbol",
            {
                language_term =
                    "identifier",
                label = "Identifier",
                value = {
                    kind = "reference",
                    language_term =
                        "identifier",
                    type_label =
                        "identifier",
                },
            }
        ),


    ["string"] =
        construct_schema.rule(
            "string",
            "literal",
            {
                language_term = "string",
                label = "String",
                construct_mutability = {
                    state = "immutable",
                    shape = "fixed",
                },
                value = {
                    kind = "scalar",
                    language_term = "string",
                    type_label = "string",
                },
            }
        ),


    ["integer"] =
        construct_schema.rule(
            "integer",
            "literal",
            {
                language_term = "integer",
                label = "Integer",
                construct_mutability = {
                    state = "immutable",
                    shape = "fixed",
                },
                value = {
                    kind = "scalar",
                    language_term = "integer",
                    type_label = "integer",
                },
            }
        ),

}

M.scope_members = {
    functions = {
        scope_member_schema.named(
            "class_definition",
            "name",
            "symbol",
            {
                language_term = "class",
                owner_scope =
                    "parent_lexical",
                binding_mutability =
                    "mutable",
            }
        ),
        scope_member_schema.named(
            "function_definition",
            "name",
            "function",
            {
                owner_scope =
                    "parent_lexical",
                binding_mutability =
                    "mutable",
            }
        ),
    },

    parameters = {
        scope_member_schema.rule(
            "function_definition",
            "parameter",
            {
                fields = {
                    parameters =
                        "parameters",
                },
                children = {
                    names = {
                        node_type =
                            "parameters",
                    },
                },
                binding_mutability =
                    "mutable",
            }
        ),
    },

    loops = {
        scope_member_schema.rule(
            "for_statement",
            "loop_variable",
            {
                language_term =
                    "loop variable",
                fields = {
                    name = "left",
                    iterable = "right",
                },
                tokens = {
                    iterator = "in",
                },
                binding_mutability =
                    "conditional",
            }
        ),
    },

    symbols = {
        scope_member_schema.rule(
            "import_statement",
            "symbol",
            {
                language_term = "import",
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
                binding_mutability =
                    "immutable",
                value = {
                    kind = "reference",
                    language_term = "import",
                    type_label = "import",
                },
            }
        ),
        scope_member_schema.rule(
            "import_from_statement",
            "symbol",
            {
                language_term =
                    "from import",
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
                binding_mutability =
                    "immutable",
                value = {
                    kind = "reference",
                    language_term =
                        "from import",
                    type_label = "import",
                },
            }
        ),
        scope_member_schema.rule(
            "assignment",
            "assignment",
            {
                fields = {
                    name = "left",
                    value = "right",
                },
                tokens = {
                    operator = "=",
                },
                binding_mutability =
                    "mutable",
            }
        ),
        scope_member_schema.rule(
            "augmented_assignment",
            "assignment",
            {
                language_term =
                    "augmented assignment",
                fields = {
                    name = "left",
                    operator = "operator",
                    value = "right",
                },
                binding_mutability =
                    "mutable",
            }
        ),
    },

    returns = {
        scope_member_schema.rule(
            "return_statement",
            "return_value",
            {
                language_term =
                    "return value",
                tokens = {
                    start = "return",
                },
            }
        ),
    },
}

return M
