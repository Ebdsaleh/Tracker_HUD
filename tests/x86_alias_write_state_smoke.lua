-- tests/x86_alias_write_state_smoke.lua
-- Parser-backed x86-64 scalar alias write-state regression.
-- Run with ERIDU's configured Neovim (ASM Tree-sitter parser required):
-- nvim --headless -c "luafile tests/x86_alias_write_state_smoke.lua" -c "qa!"

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local source = {
        "bits 64",
        "mov ah, 0x3C",
        -- Keep a compact seed here because this smoke is about alias
        -- composition. Wide parser-backed integers have their own regression.
        "mov rax, 0x12345678",
        "mov ah, 0xAA",
        "mov al, 0xBB",
        "mov ax, 0xCCDD",
        "mov eax, 0x12345678",
        "mov ah, bl",
        "mov eax, ebx",
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
        return assert(found, "missing reduced RAX-family state after line "
            .. tostring(line_number))
    end

    local ah_from_unknown = state_after(2)
    assert(ah_from_unknown.resolved == false
        and ah_from_unknown.value == nil,
        "AH write into unknown RAX must remain partially known")
    assert(ah_from_unknown.name == "ah",
        "source alias spelling must remain attached to reduced state")
    assert(ah_from_unknown.metadata.partial_value.known_mask
            == "0x000000000000FF00"
        and ah_from_unknown.metadata.partial_value.known_value
            == "0x0000000000003C00",
        "AH immediate must prove exactly bits 15..8")
    print("PASS x86 alias state: AH into unknown RAX proves only bits 15..8")

    local full = state_after(3)
    assert(full.resolved ~= false
        and tostring(full.value) == tostring(0x12345678),
        "full RAX write must establish exact seed value")

    local ah = state_after(4)
    assert(ah.resolved ~= false
        and ah.value == "0x000000001234AA78",
        "AH write must preserve all other known RAX bytes")
    print("PASS x86 alias state: AH preserves prior known family bits")

    local al = state_after(5)
    assert(al.resolved ~= false
        and al.value == "0x000000001234AABB",
        "AL write must replace only bits 7..0")

    local ax = state_after(6)
    assert(ax.resolved ~= false
        and ax.value == "0x000000001234CCDD",
        "AX write must replace only bits 15..0")
    print("PASS x86 alias state: AL/AX compose into canonical RAX")

    local eax = state_after(7)
    assert(eax.resolved ~= false
        and eax.value == "0x0000000012345678",
        "EAX write must clear upper 32 bits and establish full RAX")
    print("PASS x86 alias state: EAX write zero-extends into full RAX")

    local unknown_ah = state_after(8)
    assert(unknown_ah.resolved == false and unknown_ah.value == nil,
        "unknown AH source must invalidate the overwritten byte")
    assert(unknown_ah.metadata.partial_value.known_mask
            == "0xFFFFFFFFFFFF00FF"
        and unknown_ah.metadata.partial_value.known_value
            == "0x0000000012340078",
        "unknown AH write must preserve proven bits outside bits 15..8")
    print("PASS x86 alias state: unknown AH invalidates only its byte")

    local unknown_eax = state_after(9)
    assert(unknown_eax.resolved == false and unknown_eax.value == nil,
        "unknown EAX source cannot establish low 32-bit value")
    assert(unknown_eax.metadata.partial_value.known_mask
            == "0xFFFFFFFF00000000"
        and unknown_eax.metadata.partial_value.known_value
            == "0x0000000000000000",
        "unknown EAX write must still prove architectural upper-zero bits")
    print("PASS x86 alias state: unknown EAX still proves upper 32 zero")

    print("PASS Tracker_HUD x86 scalar alias write-state smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL x86 alias write-state smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
