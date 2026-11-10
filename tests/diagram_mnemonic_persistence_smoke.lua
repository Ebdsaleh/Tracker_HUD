-- tests/diagram_mnemonic_persistence_smoke.lua
-- Parser-backed regression for carried register state while the cursor is on
-- an instruction mnemonic before that instruction's destination effect is
-- visible.
--
-- nvim --headless -c "luafile tests/diagram_mnemonic_persistence_smoke.lua" -c "qa!"

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local source = {
        "bits 64",
        "mov ah, 0x3C",
        "mov rax, 0x12345678",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"
    vim.api.nvim_set_current_buf(buffer)

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))
    local trees = parser:parse()
    assert(trees and trees[1], "ASM parser produced no tree")

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")
    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local context_module = require("tracker_hud.context")
    local learning = require("tracker_hud.presenters.learning")
    local diagram = require("tracker_hud.presenters.byte_diagram")
    local bank = require("tracker_hud.presenters.register_state_bank")

    -- Column zero is the 'm' in the second mov. Its destination effect has not
    -- been reached, but line 2's AH state must remain visible.
    vim.api.nvim_win_set_cursor(0, { 3, 0 })
    local mnemonic_context = context_module.get_cursor_context(buffer, {})

    assert(type(mnemonic_context.registers_before_current_line) == "table",
        "context must retain reduced register state from before the current line")

    assert(learning.select_fact(mnemonic_context) == nil,
        "current mov effect must remain gated while cursor is on mnemonic")

    local carried = learning.select_diagram_fact(mnemonic_context)
    assert(carried
        and carried.subject.name == "rax"
        and carried.value.status == "partial"
        and carried.value.known_mask == "0x000000000000FF00"
        and carried.value.known_value == "0x0000000000003C00",
        "diagram must fall back to prior RAX state on the mov mnemonic")
    assert(carried.metadata and carried.metadata.carried_state == true,
        "fallback diagram fact must be explicitly marked as carried state")
    assert(carried.source and carried.source.line == 2,
        "carried diagram must retain the real source line of its latest proof")

    local diagram_text = table.concat(diagram.lines(carried), "\n")
    assert(diagram_text:find(
            "[??][??][??][??][??][??][3C][??]",
            1,
            true
        )
        and diagram_text:find(
            "Carried state: the current source effect has not been reached yet.",
            1,
            true
        )
        and diagram_text:find(
            "Latest proven change is from line 2.",
            1,
            true
        ),
        "carried diagram must visibly preserve and label prior state")

    local state = learning.state_facts(mnemonic_context)
    local found_rax = false
    for _, fact in ipairs(state) do
        if fact.subject and fact.subject.name == "rax" then
            found_rax = true
            assert(fact.value.status == "partial"
                and fact.value.known_value == "0x0000000000003C00"
                and fact.source.line == 2,
                "persistent bank must use prior RAX state before current effect")
        end
    end
    assert(found_rax,
        "persistent bank must not erase RAX while cursor is on mov mnemonic")

    local bank_text = table.concat(bank.lines(state, 3), "\n")
    assert(bank_text:find(
            "RAX  [??][??][??][??][??][??][3C][??]",
            1,
            true
        ),
        "persistent bank must render carried RAX bytes on mnemonic")
    print("PASS diagram persistence: mov mnemonic carries prior RAX state")

    -- Move onto the destination register. The current instruction is now
    -- visible and must replace the carried state with its own full write.
    vim.api.nvim_win_set_cursor(0, { 3, 4 })
    local destination_context = context_module.get_cursor_context(buffer, {})
    local current = learning.select_diagram_fact(destination_context)

    assert(current
        and not (current.metadata and current.metadata.carried_state)
        and current.source.line == 3
        and current.value.status == "known",
        "destination cursor must switch from carried state to current effect")

    local current_diagram = table.concat(diagram.lines(current), "\n")
    assert(current_diagram:find(
            "[00][00][00][00][12][34][56][78]",
            1,
            true
        )
        and not current_diagram:find("Carried state:", 1, true),
        "destination diagram must show current full RAX write")
    print("PASS diagram persistence: destination replaces carried state with current effect")

    print("PASS Tracker_HUD diagram mnemonic persistence smoke")
end

local ok, err = pcall(run)
if not ok then
    io.stderr:write("FAIL diagram mnemonic persistence smoke: "
        .. tostring(err) .. "\n")
    error(err)
end
