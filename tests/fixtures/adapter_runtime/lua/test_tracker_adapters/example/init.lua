-- External adapter discovery fixture.
local construct_schema =
    require("tracker_hud.adapters.construct_schema")

local M = {
    contract_version = 1,
    name = "external_example",
    filetypes = {
        "external_example",
    },
    construct_specs = {},
}

construct_schema.define(
    M.construct_specs,
    "source_file",
    "module",
    {
        language_term = "source file",
        label = "Source File",
        scope = {
            kind = "lexical",
            affects_visibility = true,
            owns_members = true,
        },
    }
)

return M
