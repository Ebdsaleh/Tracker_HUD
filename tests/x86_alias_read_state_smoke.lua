-- tests/x86_alias_read_state_smoke.lua
-- Parser-backed x86-64 canonical-to-alias read projection regression.
-- Requires ERIDU's configured ASM Tree-sitter parser.
-- nvim --headless -c "luafile tests/x86_alias_read_state_smoke.lua" -c "qa!"

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local source = {
        "bits 64",
        "mov rax, 0x1122334455667788",
        "add eax, 1",
        "mov rax, 0x1122334455667788",
        "add ax, 1",
        "mov rax, 0x1122334455667788",
        "add ah, 1",
        "mov rax, 0x1122334455667788",
        "add al, 1",
        "mov rax, 0x1122334455667788",
        "mov ah, bl",
        "add al, 1",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))
    local trees = parser:parse()
    assert(trees and trees[1], "ASM parser produced no tree")
    local root = trees[1]:root()

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")
    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local engine = require("tracker_hud.context_engine")

    local function state_after(line_number)
        local facts = engine.collect_register_effects(
            { cursor = { line = line_number, column = 200 } },
            adapter,
            {
                bufnr = buffer,
                root_node = root,
                limit_position = {
                    line = line_number + 1,
                    column = 0,
                },
            }
        )

        local found
        for _, fact in ipairs(facts or {}) do
            local canonical = fact.metadata and fact.metadata.canonical_name
            if canonical == "rax" or fact.name == "rax" then
                assert(not found,
                    "canonical RAX family must reduce to one latest state fact")
                found = fact
            end
        end

        return assert(found,
            "missing reduced RAX-family state after line "
                .. tostring(line_number))
    end

    local eax = state_after(3)
    assert(eax.name == "eax"
        and eax.resolved ~= false
        and eax.value == "0x0000000055667789"
        and eax.metadata.write_value == "1432778633",
        "EAX arithmetic must read low 32 bits from known canonical RAX")
    print("PASS x86 alias read: EAX projects known canonical low dword")

    for iteration = 1, 32 do
        local repeated = state_after(3)

        assert(repeated.name == "eax"
            and repeated.resolved ~= false
            and repeated.value == "0x0000000055667789"
            and repeated.metadata.write_value == "1432778633",
            "canonical-to-EAX read changed across repeated collection at iteration "
                .. tostring(iteration))
    end
    print("PASS x86 alias read: repeated collection is deterministic")

    local ax = state_after(5)
    assert(ax.name == "ax"
        and ax.resolved ~= false
        and ax.value == "0x1122334455667789"
        and ax.metadata.write_value == "30601",
        "AX arithmetic must read low 16 bits from known canonical RAX")
    print("PASS x86 alias read: AX projects known canonical low word")

    local ah = state_after(7)
    assert(ah.name == "ah"
        and ah.resolved ~= false
        and ah.value == "0x1122334455667888"
        and ah.metadata.write_value == "120",
        "AH arithmetic must read bits 15..8 from known canonical RAX")
    print("PASS x86 alias read: AH projects known canonical high byte")

    local al = state_after(9)
    assert(al.name == "al"
        and al.resolved ~= false
        and al.value == "0x1122334455667789"
        and al.metadata.write_value == "137",
        "AL arithmetic must read low byte from known canonical RAX")
    print("PASS x86 alias read: AL projects known canonical low byte")

    local partial_al = state_after(12)
    assert(partial_al.name == "al"
        and partial_al.resolved == false
        and partial_al.value == nil
        and partial_al.metadata.write_value == "137"
        and partial_al.metadata.partial_value.known_mask
            == "0xFFFFFFFFFFFF00FF"
        and partial_al.metadata.partial_value.known_value
            == "0x1122334455660089",
        "AL arithmetic must read its proven slice from partial canonical RAX state")
    print("PASS x86 alias read: partial canonical certainty feeds proven alias reads")

    print("PASS Tracker_HUD x86 canonical-to-alias read smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL x86 canonical-to-alias read smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
