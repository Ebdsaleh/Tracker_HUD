-- tests/adapter_authoring_starter_smoke.lua
--
-- Keeps the copyable adapter starter and author-facing diagnostics executable.

local function run()
    vim.opt.runtimepath:prepend(
        vim.fn.getcwd()
    )

    local contract =
        require(
            "tracker_hud.adapters.contract"
        )

    local starter =
        dofile(
            vim.fn.getcwd()
                .. "/samples/adapter_starter/minimal_adapter.lua"
        )

    local ok, err =
        contract.validate_adapter(
            starter
        )

    assert(
        ok,
        "adapter starter must satisfy Adapter Contract v1: "
            .. tostring(err)
    )

    assert(
        starter.construct_specs.source_file
            .scope.kind
            == "lexical"
            and starter.construct_specs
                .function_definition
                .construct.kind
                == "function"
            and starter.scope_members
                .functions[1].member.kind
                == "function"
            and starter.scope_members
                .parameters[1].member.kind
                == "parameter",
        "adapter starter lost its construct/member teaching shape"
    )

    print(
        "PASS adapter authoring starter validates through Contract v1"
    )


    local bad_construct =
        vim.deepcopy(starter)

    bad_construct.construct_specs
        .function_definition
        .construct.kind =
            "not_a_construct_kind"

    ok, err =
        contract.validate_adapter(
            bad_construct
        )

    assert(
        not ok
            and err
                == "adapter.construct_specs[function_definition].construct.kind is invalid or missing",
        "construct diagnostic lost exact author-facing path: "
            .. tostring(err)
    )


    local bad_scope =
        vim.deepcopy(starter)

    bad_scope.construct_specs
        .function_definition
        .scope.kind =
            "not_a_scope_kind"

    ok, err =
        contract.validate_adapter(
            bad_scope
        )

    assert(
        not ok
            and err
                == "adapter.construct_specs[function_definition].scope.kind is invalid",
        "scope diagnostic lost exact author-facing path: "
            .. tostring(err)
    )


    local bad_member =
        vim.deepcopy(starter)

    bad_member.scope_members
        .functions[1]
        .member.owner_scope =
            "not_an_owner_scope"

    ok, err =
        contract.validate_adapter(
            bad_member
        )

    assert(
        not ok
            and err
                == "adapter.scope_members.functions[1].member.owner_scope is invalid",
        "member diagnostic lost exact author-facing path: "
            .. tostring(err)
    )

    print(
        "PASS adapter authoring diagnostics identify exact semantic paths"
    )
end


run()
