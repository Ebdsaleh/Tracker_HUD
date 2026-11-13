-- tests/syntax_spec_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/syntax_spec_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local syntax_spec =
    require("tracker_hud.syntax_spec")

local spec = {
    syntax = {
        node_type = "instruction",
        fields = {
            name = "name",
            kind = {
                field = "kind",
                text = "MOV",
            },
            value_kind = {
                field = "kind",
                value = "lea",
            },
        },
        tokens = {
            required = "token-a",
        },
    },
}

assert(
    syntax_spec.get(spec)
        == spec.syntax
        and syntax_spec.get_node_type(spec)
            == "instruction",
    "syntax table or node-type access changed"
)
print("PASS syntax spec: syntax table and node type preserved")

assert(
    syntax_spec.get_field(
        spec,
        "name"
    ) == "name"
        and syntax_spec.get_field(
            spec,
            "kind"
        ) == "kind",
    "syntax field access changed"
)
print("PASS syntax spec: string and table field access preserved")

assert(
    syntax_spec.get_field_text(
        spec,
        "kind"
    ) == "MOV"
        and syntax_spec.get_field_text(
            spec,
            "value_kind"
        ) == "lea",
    "syntax field text/value precedence changed"
)
print("PASS syntax spec: field text and value access preserved")

assert(
    syntax_spec.get_tokens(spec)
        == spec.syntax.tokens,
    "syntax token access changed"
)

local legacy_tokens = {
    old = "legacy",
}

assert(
    syntax_spec.get_tokens({
        tokens = legacy_tokens,
    }) == legacy_tokens,
    "legacy token fallback changed"
)
print("PASS syntax spec: syntax and legacy tokens preserved")

assert(
    syntax_spec.normalize_mnemonic(
        "MOV"
    ) == "mov"
        and syntax_spec
            .normalize_mnemonic("")
            == nil
        and syntax_spec
            .normalize_mnemonic(nil)
            == nil,
    "mnemonic normalization changed"
)
print("PASS syntax spec: mnemonic normalization preserved")

assert(
    next(syntax_spec.get(nil)) == nil
        and syntax_spec
            .get_node_type({})
            == nil
        and syntax_spec
            .get_field({}, "name")
            == nil
        and syntax_spec
            .get_field_text({}, "kind")
            == nil
        and syntax_spec
            .get_tokens({})
            == nil,
    "invalid syntax inputs must fail closed"
)
print("PASS syntax spec: invalid inputs fail closed")

print("PASS Tracker_HUD syntax-spec smoke")
