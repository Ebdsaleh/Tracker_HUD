-- tests/asm_address_prefix_probe.lua
-- Diagnostic parser-shape probe for NASM A32/A64 instruction prefixes.
-- Intentionally avoids asserting a specific Tree-sitter node shape.
--
-- nvim --headless -c "luafile tests/asm_address_prefix_probe.lua" -c "qa!"

local function run()
    dofile("tests/test_runtime.lua").use_working_tree()

    local source = {
        "bits 64",
        "a32 mov rbx, [eax + 4]",
        "a64 mov rbx, [rax + 4]",
    }

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, source)
    vim.bo[buffer].filetype = "asm"

    local ok, parser = pcall(vim.treesitter.get_parser, buffer, "asm")
    assert(ok and parser, "ASM Tree-sitter parser unavailable: " .. tostring(parser))

    local tree = assert(parser:parse()[1], "ASM parser produced no tree")
    local root = tree:root()

    local function node_text(node)
        local text = vim.treesitter.get_node_text(node, buffer)

        if type(text) == "table" then
            text = table.concat(text, "\n")
        end

        return tostring(text or "")
    end

    local function dump(node, depth, out)
        depth = depth or 0
        out = out or {}

        local start_row, start_col, end_row, end_col = node:range()

        out[#out + 1] = string.rep("  ", depth)
            .. node:type()
            .. "@"
            .. tostring(start_row + 1)
            .. ":"
            .. tostring(start_col)
            .. "-"
            .. tostring(end_row + 1)
            .. ":"
            .. tostring(end_col)
            .. " ["
            .. node_text(node):gsub("\n", "\\n")
            .. "]"

        for child in node:iter_children() do
            dump(child, depth + 1, out)
        end

        return out
    end

    print("BEGIN ASM A32/A64 TREE")
    for _, line in ipairs(dump(root)) do
        print(line)
    end
    print("END ASM A32/A64 TREE")

    local adapter = require("tracker_hud.adapters.asm.init")
    local registry = require("tracker_hud.adapters.registry")
    local registered, register_err = registry.register(adapter)
    assert(registered, "cannot register ASM adapter: " .. tostring(register_err))

    local configured, config_err =
        registry.configure_adapter_for_buffer("asm", buffer, {})
    assert(configured, "cannot configure ASM adapter: " .. tostring(config_err))

    local instruction_utils =
        require("tracker_hud.adapters.asm.instruction_utils")

    local instructions = {}

    local function visit(node)
        if node:type() == "instruction" then
            local parsed = instruction_utils.parse_instruction(
                buffer,
                node,
                nil,
                adapter
            )

            instructions[#instructions + 1] = {
                node = node,
                parsed = parsed,
            }
        end

        for child in node:iter_children() do
            visit(child)
        end
    end

    visit(root)

    print("BEGIN ASM A32/A64 PARSED")

    for index, entry in ipairs(instructions) do
        local parsed = entry.parsed or {}
        local start_row = entry.node:start()

        print("instruction #"
            .. tostring(index)
            .. " line="
            .. tostring(start_row + 1)
            .. " mnemonic="
            .. tostring(parsed.mnemonic)
            .. " operands="
            .. tostring(#(parsed.operands or {})))

        for operand_index, operand in ipairs(parsed.operands or {}) do
            print("  operand #"
                .. tostring(operand_index)
                .. " kind="
                .. tostring(operand.kind)
                .. " text=["
                .. tostring(operand.text)
                .. "]")

            local address = operand.memory
                and operand.memory.normalized
                or nil

            if address then
                print("    address_size_status="
                    .. tostring(address.address_size_status))
                print("    address_size_bits="
                    .. tostring(address.address_size_bits))
                print("    address_size_source="
                    .. tostring(address.address_size_source))
                print("    address_size_reason="
                    .. tostring(address.address_size_reason))
                print("    base="
                    .. tostring(address.base and address.base.name))
                print("    displacement="
                    .. tostring(
                        address.displacement
                        and address.displacement.value
                    ))
            end
        end
    end

    print("END ASM A32/A64 PARSED")

    assert(#instructions > 0,
        "probe expected at least one instruction node")

    print("PASS Tracker_HUD ASM A32/A64 parser-shape probe")
end

local ok, err = pcall(run)

if not ok then
    io.stderr:write(
        "FAIL ASM A32/A64 parser-shape probe: "
            .. tostring(err)
            .. "\n"
    )
    error(err)
end
