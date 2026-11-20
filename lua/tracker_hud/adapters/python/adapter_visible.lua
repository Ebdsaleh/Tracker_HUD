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

M.scope_binding_modifiers = {
    {
        syntax = {
            node_type =
                "global_statement",
            children = {
                names = {
                    node_type =
                        "identifier",
                    multiple = true,
                },
            },
            tokens = {
                start = "global",
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
                "nonlocal_statement",
            children = {
                names = {
                    node_type =
                        "identifier",
                    multiple = true,
                },
            },
            tokens = {
                start = "nonlocal",
            },
        },
        target = {
            strategy =
                "nearest_enclosing_binding",

            -- Python closure lookup skips ordinary class namespaces.
            -- Lambda constructs use the shared "function" construct kind,
            -- so this also admits lambda lexical owners without teaching
            -- the generic resolver Python node names.
            eligible_construct_kinds = {
                "function",
            },
        },
    },
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
    ["module"] =
        construct_schema.rule(
            "module",
            "module",
            {
                language_term = "module",
                label = "Module",
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
            }
        ),


    ["class_definition"] =
        construct_schema.rule(
            "class_definition",
            "class",
            {
                language_term = "class",
                label = "Class",
                fields = {
                    name = "name",
                    body = "body",
                },
                tokens = {
                    start = "class",
                    body_open = ":",
                },
                construct_mutability = {
                    state = "mutable",
                    shape = "extensible",
                },
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,

                    -- Nested Python functions do not resolve ordinary lexical
                    -- bindings through the class namespace.
                    binding_parent = false,
                },
                value = {
                    kind = "object",
                    language_term = "class",
                    type_label = "class",
                },
                signature = {
                    strategy = "first_line",
                    name_pattern =
                        "^%s*class%s+([%w_]+)",
                },
                markers = {
                    required = {
                        "start",
                        "body_open",
                    },
                    total_required = 2,
                },
            }
        ),


    ["function_definition"] =
        construct_schema.rule(
            "function_definition",
            "function",
            {
                language_term = "function",
                label = "Function",
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
                construct_mutability = {
                    state = "immutable",
                    shape = "fixed",
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
                    name_pattern =
                        "^%s*def%s+([%w_]+)",
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
            }
        ),


    ["lambda"] =
        construct_schema.rule(
            "lambda",
            "function",
            {
                language_term = "lambda",
                label = "Lambda",
                fields = {
                    parameters = "parameters",
                    body = "body",
                },
                tokens = {
                    start = "lambda",
                    body_open = ":",
                },
                construct_mutability = {
                    state = "immutable",
                    shape = "fixed",
                },
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
                value = {
                    kind = "function",
                    language_term = "lambda",
                    type_label = "function",
                },
            }
        ),


    ["global_statement"] =
        construct_schema.rule(
            "global_statement",
            "declaration",
            {
                language_term =
                    "global declaration",
                label = "Global",
                tokens = {
                    start = "global",
                },
            }
        ),


    ["nonlocal_statement"] =
        construct_schema.rule(
            "nonlocal_statement",
            "declaration",
            {
                language_term =
                    "nonlocal declaration",
                label = "Nonlocal",
                tokens = {
                    start = "nonlocal",
                },
            }
        ),


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

    ["import_from_statement"] =
        construct_schema.rule(
            "import_from_statement",
            "declaration",
            {
                language_term =
                    "from import",
                label = "From Import",
                tokens = {
                    start = "from",
                    import_token = "import",
                },
                value = {
                    kind = "reference",
                    language_term =
                        "from import",
                    type_label = "import",
                },
                markers = {
                    required = {
                        "start",
                        "import_token",
                    },
                    total_required = 2,
                },
            }
        ),


    ["if_statement"] =
        construct_schema.rule(
            "if_statement",
            "branch",
            {
                language_term = "if",
                label = "If",
                fields = {
                    condition = "condition",
                    consequence = "consequence",
                    alternative = "alternative",
                },
                tokens = {
                    start = "if",
                    branch_open = ":",
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
            }
        ),


    ["while_statement"] =
        construct_schema.rule(
            "while_statement",
            "loop",
            {
                language_term = "while",
                label = "While",
                fields = {
                    condition = "condition",
                    body = "body",
                    alternative = "alternative",
                },
                tokens = {
                    start = "while",
                    body_open = ":",
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
            }
        ),


    ["for_statement"] =
        construct_schema.rule(
            "for_statement",
            "loop",
            {
                language_term = "for",
                label = "For",
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
            }
        ),


    ["try_statement"] =
        construct_schema.rule(
            "try_statement",
            "block",
            {
                language_term = "try",
                label = "Try",
                fields = {
                    body = "body",
                },
                tokens = {
                    start = "try",
                    body_open = ":",
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
            }
        ),


    ["except_clause"] =
        construct_schema.rule(
            "except_clause",
            "branch",
            {
                language_term =
                    "except",
                label =
                    "Except",
                fields = {
                    value = "value",
                    alias = "alias",
                },
                tokens = {
                    start = "except",
                    alias = "as",
                    branch_open = ":",
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
            }
        ),


    ["with_statement"] =
        construct_schema.rule(
            "with_statement",
            "block",
            {
                language_term = "with",
                label = "With",
                fields = {
                    body = "body",
                },
                children = {
                    clause = {
                        node_type = "with_clause",
                    },
                },
                tokens = {
                    start = "with",
                    body_open = ":",
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
            }
        ),


    ["match_statement"] =
        construct_schema.rule(
            "match_statement",
            "branch",
            {
                language_term = "match",
                label = "Match",
                fields = {
                    subject = "subject",
                    body = "body",
                },
                tokens = {
                    start = "match",
                    branch_open = ":",
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
            }
        ),


    ["case_clause"] =
        construct_schema.rule(
            "case_clause",
            "branch",
            {
                language_term = "case",
                label = "Case",
                fields = {
                    guard = "guard",
                    consequence = "consequence",
                },
                children = {
                    pattern = {
                        node_type = "case_pattern",
                    },
                },
                tokens = {
                    start = "case",
                    branch_open = ":",
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
            }
        ),


    ["type_alias_statement"] =
        construct_schema.rule(
            "type_alias_statement",
            "declaration",
            {
                language_term =
                    "type alias",
                label =
                    "Type Alias",
                fields = {
                    left = "left",
                    right = "right",
                },
                tokens = {
                    start = "type",
                    operator = "=",
                },
            }
        ),


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


    ["named_expression"] =
        construct_schema.rule(
            "named_expression",
            "assignment",
            {
                language_term =
                    "named expression",
                label =
                    "Named Expression",
                fields = {
                    name = "name",
                    value = "value",
                },
                tokens = {
                    operator = ":=",
                },
            }
        ),


    ["list_comprehension"] =
        construct_schema.rule(
            "list_comprehension",
            "comprehension",
            {
                language_term =
                    "list comprehension",
                label =
                    "List Comprehension",
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
            }
        ),


    ["set_comprehension"] =
        construct_schema.rule(
            "set_comprehension",
            "comprehension",
            {
                language_term =
                    "set comprehension",
                label =
                    "Set Comprehension",
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
            }
        ),


    ["dictionary_comprehension"] =
        construct_schema.rule(
            "dictionary_comprehension",
            "comprehension",
            {
                language_term =
                    "dictionary comprehension",
                label =
                    "Dictionary Comprehension",
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
                },
            }
        ),


    ["generator_expression"] =
        construct_schema.rule(
            "generator_expression",
            "comprehension",
            {
                language_term =
                    "generator expression",
                label =
                    "Generator Expression",
                scope = {
                    kind = "lexical",
                    affects_visibility = true,
                    owns_members = true,
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
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                binding_mutability =
                    "mutable",
            }
        ),
        scope_member_schema.rule(
            "function_definition",
            "type_parameter",
            {
                language_term =
                    "type parameter",
                fields = {
                    parameters =
                        "type_parameters",
                },
                children = {
                    names = {
                        node_type =
                            "type_parameter",
                    },
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                annotation_scope = true,
            }
        ),
        scope_member_schema.rule(
            "class_definition",
            "type_parameter",
            {
                language_term =
                    "type parameter",
                fields = {
                    parameters =
                        "type_parameters",
                },
                children = {
                    names = {
                        node_type =
                            "type_parameter",
                    },
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                annotation_scope = true,
            }
        ),
        scope_member_schema.rule(
            "type_alias_statement",
            "type_parameter",
            {
                language_term =
                    "type parameter",
                fields = {
                    parameters =
                        "left",
                },
                children = {
                    names = {
                        node_type =
                            "type_parameter",
                    },
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                annotation_scope = true,
            }
        ),
        scope_member_schema.rule(
            "lambda",
            "parameter",
            {
                fields = {
                    parameters =
                        "parameters",
                },
                children = {
                    names = {
                        node_type =
                            "lambda_parameters",
                    },
                    name = {
                        node_type =
                            "identifier",
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
                    name = {
                        field = "left",
                        node_type =
                            "identifier",
                    },
                    iterable = "right",
                },
                children = {
                    names = {
                        node_type =
                            "pattern_list",
                    },
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                tokens = {
                    iterator = "in",
                },
                binding_mutability =
                    "conditional",
            }
        ),
        scope_member_schema.rule(
            "for_in_clause",
            "loop_variable",
            {
                language_term =
                    "comprehension variable",
                fields = {
                    name = {
                        field = "left",
                        node_type =
                            "identifier",
                    },
                    iterable = "right",
                },
                children = {
                    names = {
                        node_type =
                            "pattern_list",
                    },
                    name = {
                        node_type =
                            "identifier",
                    },
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
                fields = {
                    bindings = {
                        field = "name",
                        node_types = {
                            "dotted_name",
                            "aliased_import",
                            "identifier",
                        },
                        multiple = true,
                    },
                    name = "alias",
                },
                children = {
                    name = {
                        node_type =
                            "identifier",
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
                fields = {
                    bindings = {
                        field = "name",
                        node_types = {
                            "dotted_name",
                            "aliased_import",
                            "identifier",
                        },
                        multiple = true,
                    },
                    name = "alias",
                },
                children = {
                    name = {
                        node_type =
                            "identifier",
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
                    bindings = {
                        field = "left",

                        -- Assignment destructuring is grammar-driven.
                        -- Composite attribute/subscript targets are terminals,
                        -- never containers whose child identifiers become
                        -- fake lexical bindings.
                        recursive = {
                            terminal_node_types = {
                                "identifier",
                                "keyword_identifier",
                                "attribute",
                                "subscript",
                            },
                            container_node_types = {
                                "pattern_list",
                                "tuple_pattern",
                                "list_pattern",
                                "list_splat_pattern",
                            },
                        },
                    },
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
        scope_member_schema.rule(
            "as_pattern",
            "assignment",
            {
                language_term =
                    "context manager alias",
                fields = {
                    name = "alias",
                },
                exclusions = {
                    ancestor_node_types = {
                        "case_clause",
                        "except_clause",
                    },
                },
                binding_mutability =
                    "mutable",
            }
        ),
        scope_member_schema.rule(
            "named_expression",
            "assignment",
            {
                language_term =
                    "named expression",
                fields = {
                    name = "name",
                    value = "value",
                },
                tokens = {
                    operator = ":=",
                },
                owner_scope_excluded_construct_kinds = {
                    "comprehension",
                },
                binding_mutability =
                    "mutable",
            }
        ),
        scope_member_schema.rule(
            "dotted_name",
            "pattern_binding",
            {
                language_term =
                    "match capture",
                children = {
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                constraints = {
                    ancestor_node_types = {
                        "case_clause",
                    },
                    parent_node_types = {
                        "case_pattern",
                        "keyword_pattern",
                    },
                    named_child_count = 1,
                },
                binding_mutability =
                    "conditional",
            }
        ),
        scope_member_schema.rule(
            "identifier",
            "pattern_binding",
            {
                language_term =
                    "match capture",
                children = {
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                constraints = {
                    ancestor_node_types = {
                        "case_clause",
                    },
                    parent_node_types = {
                        "splat_pattern",
                        "as_pattern",
                    },
                    named_child_count = 0,
                },
                binding_mutability =
                    "conditional",
            }
        ),
        scope_member_schema.rule(
            "type_alias_statement",
            "symbol",
            {
                language_term =
                    "type alias",
                children = {
                    name = {
                        node_type =
                            "identifier",
                    },
                },
                binding_mutability =
                    "mutable",
            }
        ),
        scope_member_schema.rule(
            "as_pattern",
            "assignment",
            {
                language_term =
                    "exception alias",
                fields = {
                    name = "alias",
                },
                constraints = {
                    ancestor_node_types = {
                        "except_clause",
                    },
                },
                binding_mutability =
                    "conditional",
                visibility_range =
                    "structural_scope",
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
