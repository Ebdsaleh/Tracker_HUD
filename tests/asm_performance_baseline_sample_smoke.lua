-- tests/asm_performance_baseline_sample_smoke.lua
-- nvim --headless -c "luafile tests/asm_performance_baseline_sample_smoke.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua")
        .use_working_tree()

    local path =
        "samples/asm/x86_64/performance_baseline.asm"

    local source =
        vim.fn.readfile(path)

    assert(
        #source >= 150,
        "performance baseline sample is too short for a >=50-line jump"
    )

    local marker_a = nil
    local marker_b = nil
    local marker_c = nil
    local has_arch = false
    local has_platform = false
    local has_syntax = false

    for line_number, line in ipairs(
        source
    ) do
        if line == "; PROFILE MARKER A" then
            marker_a = line_number
        elseif line == "; PROFILE MARKER B" then
            marker_b = line_number
        elseif line == "; PROFILE MARKER C" then
            marker_c = line_number
        elseif line == "; arch=x86-64;" then
            has_arch = true
        elseif line == "; platform=linux;" then
            has_platform = true
        elseif line == "; syntax=nasm;" then
            has_syntax = true
        end
    end

    assert(
        marker_a
            and marker_b
            and marker_c
            and marker_a < marker_b
            and marker_b < marker_c
            and marker_c - marker_a >= 50,
        "performance markers no longer provide the required large jump"
    )

    assert(
        has_arch
            and has_platform
            and has_syntax,
        "performance sample target directives changed"
    )

    print(
        "PASS ASM performance sample: "
            .. "length, markers and target directives preserved"
    )

    local buffer =
        vim.api.nvim_create_buf(
            false,
            true
        )

    vim.api.nvim_buf_set_lines(
        buffer,
        0,
        -1,
        false,
        source
    )

    vim.bo[buffer].filetype = "asm"

    local ok, parser =
        pcall(
            vim.treesitter.get_parser,
            buffer,
            "asm"
        )

    assert(
        ok and parser,
        "ASM Tree-sitter parser unavailable: "
            .. tostring(parser)
    )

    local trees = parser:parse()

    assert(
        trees and trees[1],
        "ASM performance sample produced no syntax tree"
    )

    local root =
        trees[1]:root()

    local adapter =
        require(
            "tracker_hud.adapters.asm.init"
        )

    local registry =
        require(
            "tracker_hud.adapters.registry"
        )

    assert(
        registry.register(adapter)
    )

    local configured,
        configure_error =
        registry.configure_adapter_for_buffer(
            "asm",
            buffer,
            {}
        )

    assert(
        configured,
        "cannot configure ASM performance sample: "
            .. tostring(
                configure_error
            )
    )

    local engine =
        require(
            "tracker_hud.context_engine"
        )

    local context = {
        cursor = {
            line = #source,
            column = 200,
        },
    }

    local opts = {
        bufnr = buffer,
        root_node = root,
        limit_position = {
            line = #source + 1,
            column = 0,
        },
    }

    local register_facts =
        engine.collect_register_effects(
            context,
            adapter,
            opts
        )

    local stack_facts =
        engine.collect_stack_effects(
            context,
            adapter,
            opts
        )

    local boundary_facts =
        engine.collect_boundary_effects(
            context,
            adapter,
            opts
        )

    local event_facts =
        engine.collect_instruction_events(
            context,
            adapter,
            opts
        )

    assert(
        type(register_facts) == "table"
            and #register_facts > 0,
        "performance sample produced no register facts"
    )

    assert(
        type(stack_facts) == "table"
            and #stack_facts > 0,
        "performance sample produced no stack facts"
    )

    assert(
        type(boundary_facts) == "table"
            and #boundary_facts > 0,
        "performance sample produced no boundary facts"
    )

    assert(
        type(event_facts) == "table"
            and #event_facts > 0,
        "performance sample produced no instruction-event facts"
    )

    print(
        "PASS ASM performance sample: "
            .. "register/stack/boundary/event paths exercised"
    )

    print(
        "PASS Tracker_HUD ASM "
            .. "performance-baseline sample smoke"
    )
end


local ok, err =
    pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM performance-baseline sample smoke: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
