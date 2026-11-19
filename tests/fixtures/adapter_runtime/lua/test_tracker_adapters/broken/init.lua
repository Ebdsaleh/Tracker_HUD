-- Invalid external adapter fixture used to verify author diagnostics.
return {
    contract_version = 1,
    name = "external_broken",
    filetypes = {
        "external_broken",
    },
    construct_specs = {
        source_file = {
            syntax = {
                node_type = "source_file",
            },
            construct = {
                kind = "not_a_construct_kind",
                language_term = "source file",
                label = "Source File",
            },
        },
    },
}
