-- lua/tracker_hud/low_level/instruction_parser_dispatch.lua
--
-- Adapter-declared instruction parser dispatch.
--
-- This module owns only loading and invoking an adapter's configured
-- instruction parser. Parsing semantics remain in the adapter parser module.

local M = {}


function M.parse(
    adapter,
    bufnr,
    node,
    effect_spec
)
    if type(adapter) ~= "table"
        or type(adapter.instruction_parser)
            ~= "table"
    then
        return nil
    end

    local parser_spec =
        adapter.instruction_parser

    local module_name =
        parser_spec.module

    local function_name =
        parser_spec.function_name
        or "parse_instruction"

    if type(module_name) ~= "string"
        or module_name == ""
    then
        return nil
    end

    local ok, parser_module =
        pcall(
            require,
            module_name
        )

    if not ok
        or type(parser_module) ~= "table"
    then
        return nil
    end

    local parser_fn =
        parser_module[function_name]

    if type(parser_fn) ~= "function" then
        return nil
    end

    return parser_fn(
        bufnr,
        node,
        effect_spec,
        adapter
    )
end


return M
