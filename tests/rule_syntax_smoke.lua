-- tests/rule_syntax_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/rule_syntax_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local rule_syntax =
    require("tracker_hud.low_level.rule_syntax")

local tree_first = {
    syntax = {
        node_type = "instruction",
        fields = {
            kind = {
                field = "kind",
                node_type = "word",
                text = "MOV",
            },
        },
    },
}

assert(
    rule_syntax.get_node_type(
        tree_first
    ) == "instruction"
        and rule_syntax.get_mnemonic(
            tree_first
        ) == "mov",
    "Tree-sitter-first rule syntax changed"
)
print("PASS rule syntax: Tree-sitter node and mnemonic preserved")

local legacy = {
    node_type = "legacy_instruction",
    mnemonic = "PUSH",
}

assert(
    rule_syntax.get_node_type(
        legacy
    ) == "legacy_instruction"
        and rule_syntax.get_mnemonic(
            legacy
        ) == "push",
    "legacy low-level rule syntax fallback changed"
)
print("PASS rule syntax: legacy node and mnemonic fallback preserved")

assert(
    rule_syntax.get_mnemonic(
        {},
        "SYSCALL"
    ) == "syscall"
        and rule_syntax.get_mnemonic(
            nil,
            "RET"
        ) == "ret",
    "fallback mnemonic normalization changed"
)
print("PASS rule syntax: fallback mnemonic normalization preserved")

local opts =
    rule_syntax.index_options()

assert(
    type(opts) == "table"
        and opts.get_node_type
            == rule_syntax.get_node_type
        and opts.get_mnemonic
            == rule_syntax.get_mnemonic,
    "shared index option callbacks changed"
)
print("PASS rule syntax: index callback contract preserved")

assert(
    rule_syntax.get_node_type(nil)
        == nil
        and rule_syntax.get_mnemonic(
            nil,
            nil
        ) == nil,
    "invalid rule syntax inputs must fail closed"
)
print("PASS rule syntax: invalid inputs fail closed")

print("PASS Tracker_HUD low-level rule-syntax smoke")
