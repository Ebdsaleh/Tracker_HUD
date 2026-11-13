-- tests/construct_spec_validation_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/construct_spec_validation_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local validation =
    require("tracker_hud.constructs.spec_validation")

local valid_spec = {
    syntax = {
        node_type = "function_definition",
        fields = {
            name = "name",
        },
        children = {},
        tokens = {
            open = "(",
            close = ")",
        },
        exclusions = {},
    },

    construct = {
        kind = "function",
        language_term = "function",
        label = "Function",
    },

    scope = {
        kind = "lexical",
        affects_visibility = true,
        owns_members = true,
    },

    member = {
        kind = "function",
        owner_scope = "parent_lexical",
    },

    value = {
        kind = "function",
    },

    markers = {
        required = {
            "open",
        },
        optional = {
            "close",
        },
        total_required = 1,
    },
}

local ok, err =
    validation.validate(
        valid_spec,
        "function_definition"
    )

assert(
    ok == true and err == nil,
    "valid construct spec rejected: "
        .. tostring(err)
)
print("PASS construct spec validation: valid syntax and contract preserved")

local specs = {
    function_definition =
        valid_spec,
}

local resolved, resolve_error =
    validation.get(
        specs,
        "function_definition"
    )

assert(
    resolved == valid_spec
        and resolve_error == nil,
    "construct spec lookup changed"
)
print("PASS construct spec validation: keyed lookup preserved")

local missing, missing_error =
    validation.get(
        specs,
        "class_definition"
    )

assert(
    missing == nil
        and missing_error == nil,
    "missing construct spec behavior changed"
)
print("PASS construct spec validation: missing keys remain non-errors")

local invalid_syntax = vim.deepcopy(
    valid_spec
)
invalid_syntax.syntax = "bad"

local syntax_ok, syntax_error =
    validation.validate(
        invalid_syntax,
        "function_definition"
    )

assert(
    syntax_ok == false
        and syntax_error
            == "construct spec syntax must be a table when provided",
    "invalid syntax-table error changed: "
        .. tostring(syntax_error)
)
print("PASS construct spec validation: malformed syntax fails closed")

local mismatched = vim.deepcopy(
    valid_spec
)
mismatched.syntax.node_type =
    "class_definition"

local mismatch_ok, mismatch_error =
    validation.validate(
        mismatched,
        "function_definition"
    )

assert(
    mismatch_ok == false
        and mismatch_error
            == "construct spec syntax.node_type 'class_definition' does not match construct_specs key 'function_definition'",
    "node-type mismatch error changed: "
        .. tostring(mismatch_error)
)
print("PASS construct spec validation: keyed node-type identity preserved")

local missing_marker = vim.deepcopy(
    valid_spec
)
missing_marker.markers.required = {
    "missing",
}
missing_marker.markers.total_required = 1

local marker_ok, marker_error =
    validation.validate(
        missing_marker,
        "function_definition"
    )

assert(
    marker_ok == false
        and marker_error
            == "required marker 'missing' is missing from syntax.tokens",
    "required marker validation changed: "
        .. tostring(marker_error)
)
print("PASS construct spec validation: marker/token contract preserved")

local legacy_tokens_spec = vim.deepcopy(
    valid_spec
)
legacy_tokens_spec.syntax.tokens = nil
legacy_tokens_spec.tokens = {
    open = "(",
    close = ")",
}

local legacy_ok, legacy_error =
    validation.validate(
        legacy_tokens_spec,
        "function_definition"
    )

assert(
    legacy_ok == true
        and legacy_error == nil,
    "legacy token fallback changed: "
        .. tostring(legacy_error)
)
print("PASS construct spec validation: legacy token fallback preserved")

local bad_construct = vim.deepcopy(
    valid_spec
)
bad_construct.construct.kind =
    "not-a-kind"

local contract_ok, contract_error =
    validation.validate(
        bad_construct,
        "function_definition"
    )

assert(
    contract_ok == false
        and contract_error
            == "construct.kind is invalid or missing",
    "construct contract delegation changed: "
        .. tostring(contract_error)
)
print("PASS construct spec validation: construct contract delegation preserved")

local bad_lookup, bad_lookup_error =
    validation.get(
        nil,
        "function_definition"
    )

assert(
    bad_lookup == nil
        and bad_lookup_error
            == "construct_specs must be table",
    "invalid lookup table error changed"
)

local bad_node, bad_node_error =
    validation.get(
        specs,
        ""
    )

assert(
    bad_node == nil
        and bad_node_error
            == "node_type must be a non-empty string",
    "invalid node-type lookup error changed"
)
print("PASS construct spec validation: invalid lookup inputs fail closed")

print("PASS Tracker_HUD construct-spec validation smoke")
