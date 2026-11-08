-- Parser-backed C/C++ source memory observations.
-- Run in normal Neovim with c and cpp Tree-sitter parsers installed:
--   nvim --headless -c "luafile tests/c_cpp_memory_observation_smoke.lua"
--
-- Source observations are NOT evidence of allocation success, ownership,
-- heap leaks, or correctness of path-sensitive release semantics.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())

    local observations = require("tracker_hud.adapters.c.memory_facts")
    local heap_section = require("tracker_hud.sections.low_level.heap")
    local heap_tree = require("tracker_hud.sections.low_level.heap_tree")
    local events = require("tracker_hud.events")

    local fixtures = {
        {
            language = "c",
            path = "samples/c/c_memory_observation_validation.c",
            expected = { "malloc", "calloc", "realloc", "free", "free" },
            kinds = {
                "heap_allocation_site", "heap_allocation_site",
                "heap_resize_site", "heap_release_site", "heap_release_site",
            },
            first = "    void *block = malloc(count);",
        },
        {
            language = "cpp",
            path = "samples/cpp/cpp_memory_observation_validation.cpp",
            expected = { "new", "delete", "new", "delete" },
            kinds = {
                "heap_allocation_site", "heap_release_site",
                "heap_allocation_site", "heap_release_site",
            },
            first = "    int *single = new int(9);",
        },
    }

    local failures = {}
    for _, fixture in ipairs(fixtures) do
        local ok, err = pcall(function()
            local lines = vim.fn.readfile(fixture.path)
            assert(#lines > 0, "fixture missing: " .. fixture.path)

            local bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
            vim.bo[bufnr].filetype = fixture.language

            local parser_ok, parser = pcall(vim.treesitter.get_parser,
                bufnr, fixture.language)
            assert(parser_ok and parser,
                "Tree-sitter parser not installed for " .. fixture.language)
            local tree = parser:parse()[1]
            assert(tree, "parser yielded no tree")
            local root = tree:root()
            assert(not root:has_error(), "fixture parse contains ERROR nodes")

            local first_line
            for line, source in ipairs(lines) do
                if source == fixture.first then
                    first_line = line
                    break
                end
            end
            assert(first_line, "first memory operation not found")

            local before = observations.collect(bufnr, root,
                fixture.language, first_line - 1)
            local on = observations.collect(bufnr, root,
                fixture.language, first_line)
            local all = observations.collect(bufnr, root,
                fixture.language, #lines)

            assert(#before == 0,
                "future memory fact leaked before its source line")
            assert(#on == 1 and on[1].name == fixture.expected[1],
                "memory operation not discovered ON its source line")
            assert(#all == #fixture.expected,
                "expected " .. #fixture.expected .. " observations, got "
                .. #all .. " for " .. fixture.language)

            for i, fact in ipairs(all) do
                assert(fact.name == fixture.expected[i],
                    fixture.language .. " operation " .. i .. " named "
                    .. tostring(fact.name) .. ", expected " .. fixture.expected[i])
                assert(fact.kind == fixture.kinds[i],
                    fixture.language .. " operation " .. i .. " wrong kind")
                assert(fact.source_line <= #lines,
                    "fact source line outside fixture")
                assert(fact.metadata.allocation_success == "unknown"
                    and fact.metadata.ownership == "unknown"
                    and fact.metadata.leak_status == "not analyzed",
                    "source event must not invent allocation/ownership/leaks")
            end

            -- Feeding the same facts through the existing HUD sections must
            -- preserve one source event and one heap entry per operation.
            local context = {
                source_memory_facts = all,
                boundary_effects = {},
                instruction_events = {},
                targets = { syntax = fixture.language },
                cursor = { line = #lines },
            }
            local adapter = require(
                "tracker_hud.adapters." .. fixture.language .. ".adapter")
            local collected_events = events.collect(context)
            local collected_heap = heap_section.collect(context, adapter)
            assert(#collected_events == #all,
                fixture.language .. " Events lost or duplicated memory facts")
            assert(#collected_heap == #all,
                fixture.language .. " Heap lost or duplicated memory facts")

            local tree_output = heap_tree.build_tree(collected_heap)
            assert(type(tree_output) == "table"
                and type(tree_output.children) == "table"
                and #tree_output.children == #all,
                "heap display cannot render source memory observations")

            -- Neither a stray source string/comment nor a return to the top
            -- can make future operations appear in any HUD section.
            local initial = observations.collect(bufnr, root,
                fixture.language, 1)
            assert(#initial == 0, "operation visible before discovery")
            print("PASS " .. fixture.language
                .. " observed memory sites " .. #all
                .. " + cursor discovery + Heap/Events rendering")

            pcall(vim.api.nvim_buf_delete, bufnr, { force = true })
        end)
        if not ok then
            table.insert(failures, fixture.language .. ": " .. tostring(err))
            print("FAIL " .. fixture.language .. ": " .. tostring(err))
        end
    end

    assert(#failures == 0,
        "C/C++ memory observation regressions:\n  "
        .. table.concat(failures, "\n  "))
    print("PASS C/C++ source memory observations")
end

local ok, err = pcall(run)
if ok then
    vim.cmd("qa!")
else
    vim.api.nvim_err_writeln("FAIL C/C++ memory smoke: " .. tostring(err))
    vim.cmd("cquit 1")
end
