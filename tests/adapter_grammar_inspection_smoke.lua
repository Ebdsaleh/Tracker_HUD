-- tests/adapter_grammar_inspection_smoke.lua
--
-- Keeps the documented adapter grammar-discovery workflow executable against
-- Neovim's bundled Lua parser. This tests author tooling assumptions, not
-- Tracker_HUD runtime semantics.

local function find_first(
    node,
    wanted_type
)
    if not node then
        return nil
    end

    if node:type() == wanted_type then
        return node
    end

    for child in node:iter_children() do
        local found =
            find_first(
                child,
                wanted_type
            )

        if found then
            return found
        end
    end

    return nil
end


local function run()
    local source =
        table.concat(
            {
                "local function greet(name)",
                "    return name",
                "end",
            },
            "\n"
        )

    local parser =
        vim.treesitter
            .get_string_parser(
                source,
                "lua"
            )

    local trees =
        parser:parse()

    assert(
        type(trees) == "table"
            and trees[1] ~= nil,
        "documented grammar inspection workflow could not parse Lua source"
    )

    local root =
        trees[1]:root()

    local sexpr =
        root:sexpr()

    assert(
        type(sexpr) == "string"
            and sexpr:find(
                "function_declaration",
                1,
                true
            ),
        "TSNode:sexpr() no longer exposes Lua function_declaration"
    )

    local function_node =
        find_first(
            root,
            "function_declaration"
        )

    assert(
        function_node ~= nil,
        "grammar workflow could not locate function_declaration"
    )

    local fields = {}
    local anonymous_tokens = {}

    for child, field_name in
        function_node:iter_children()
    do
        local entry = {
            node_type =
                child:type(),
            named =
                child:named(),
            text =
                vim.treesitter
                    .get_node_text(
                        child,
                        source
                    ),
        }

        if field_name ~= nil then
            fields[field_name] =
                entry
        elseif not child:named() then
            anonymous_tokens[
                entry.text
            ] = true
        end
    end

    assert(
        fields.name
            and fields.name.node_type
                == "identifier"
            and fields.name.text
                == "greet"
            and fields.parameters
            and fields.parameters.node_type
                == "parameters",
        "TSNode:iter_children() no longer exposes expected Lua field names"
    )

    print(
        "PASS adapter grammar workflow exposes node types + field names"
    )

    assert(
        anonymous_tokens["function"]
            == true
            and anonymous_tokens["end"]
                == true,
        "grammar workflow no longer exposes anonymous marker tokens"
    )

    local language_info =
        vim.treesitter.language.inspect(
            "lua"
        )

    assert(
        type(language_info) == "table",
        "vim.treesitter.language.inspect('lua') did not return parser metadata"
    )

    print(
        "PASS adapter grammar workflow exposes anonymous tokens + parser metadata"
    )
end


run()
