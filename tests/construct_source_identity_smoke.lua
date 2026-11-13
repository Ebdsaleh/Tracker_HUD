-- tests/construct_source_identity_smoke.lua
-- nvim --headless -u NONE -c "luafile tests/construct_source_identity_smoke.lua" -c "qa!"

vim.opt.runtimepath:prepend(vim.fn.getcwd())

local identity =
    require("tracker_hud.constructs.source_identity")

local original_get_node_text =
    vim.treesitter.get_node_text

local name_node = {
    id = "name",
}

local construct_node = {
    id = "construct",

    field = function(_, field_name)
        if field_name == "name" then
            return {
                name_node,
            }
        end

        return {}
    end,
}

vim.treesitter.get_node_text =
    function(node, _bufnr)
        if node == construct_node then
            return "local function alpha(x)\n  return x\nend"
        end

        if node == name_node then
            return "alpha"
        end

        return nil
    end

local first_line =
    identity.get_first_line_text(
        construct_node,
        1
    )

assert(
    first_line
        == "local function alpha(x)",
    "first-line source extraction changed"
)
print("PASS construct source identity: first-line source preserved")

local signature_spec = {
    signature = {
        strategy = "first_line",
        local_name_pattern =
            "^local%s+function%s+([%w_]+)",
        name_pattern =
            "^function%s+([%w_]+)",
    },
}

assert(
    identity.build_signature(
        construct_node,
        1,
        signature_spec
    ) == "local function alpha(x)",
    "first-line signature strategy changed"
)

assert(
    identity.extract_name_from_signature(
        "local function alpha(x)",
        signature_spec
    ) == "alpha",
    "local signature-name precedence changed"
)
print("PASS construct source identity: signature strategy and local-name precedence preserved")

local syntax_name =
    identity.extract_name_from_syntax(
        construct_node,
        1,
        {
            syntax = {
                fields = {
                    name = "name",
                },
            },
        }
    )

assert(
    syntax_name == "alpha",
    "syntax-field name extraction changed"
)
print("PASS construct source identity: syntax-field name extraction preserved")

local construct, construct_error =
    identity.build_construct({
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

        node_type = "function_definition",
        name = "alpha",
        signature = "local function alpha(x)",
        range = {
            start_line = 1,
            end_line = 3,
        },

        metadata = {
            adapter = "lua",
        },
    })

assert(
    construct
        and construct_error == nil
        and construct.node_type
            == "function_definition"
        and construct.name == "alpha"
        and construct.signature
            == "local function alpha(x)"
        and construct.metadata.adapter
            == "lua",
    "canonical construct assembly changed: "
        .. tostring(construct_error)
)
print("PASS construct source identity: canonical construct assembly preserved")

local unsupported_signature =
    identity.build_signature(
        construct_node,
        1,
        {
            signature = {
                strategy = "other",
            },
        }
    )

assert(
    unsupported_signature == nil
        and identity
            .extract_name_from_signature(
                nil,
                signature_spec
            ) == nil
        and identity
            .extract_name_from_syntax(
                nil,
                1,
                {}
            ) == nil,
    "invalid source-identity inputs must fail closed"
)
print("PASS construct source identity: invalid inputs fail closed")

vim.treesitter.get_node_text =
    original_get_node_text

print("PASS Tracker_HUD construct source-identity smoke")
