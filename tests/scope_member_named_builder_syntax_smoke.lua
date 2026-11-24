-- Checkpoint 241: named() is a convenience authoring API, not a
-- second, lossy syntax contract. Its name/fallback shorthand must retain
-- explicitly supplied constraints and exclusions, just as rule() does.
-- This gate is deliberately parser-independent. Runtime C-family role
-- selection needs its own guardrails before enabling previously lost data.

local function run()
    vim.opt.runtimepath:prepend(vim.fn.getcwd())
    local schema = require("tracker_hud.adapters.scope_member_schema")
    local contract = require("tracker_hud.adapters.contract")

    local cases = {
        { label = "legacy name only", options = {} },
        { label = "ancestor constraint", options = {
            constraints = { ancestor_node_types = { "outer" } },
        } },
        { label = "ancestor exclusion", options = {
            exclusions = { ancestor_node_types = { "outer" } },
        } },
        { label = "ordered parent path", options = {
            constraints = { parent_path = { "wrapper", "owner" } },
            exclusions = { parent_path = { "wrapper", "other" } },
        } },
        { label = "field path and combined constraints", options = {
            constraints = {
                parent_node_types = { "owner" },
                named_child_count = 2,
            },
            exclusions = {
                ancestor_node_types = { "excluded" },
                field_paths = {
                    { fields = { "name", "name" }, node_types = { "list" } },
                },
            },
        } },
    }
    local failures = {}
    for _, case in ipairs(cases) do
        local options = vim.deepcopy(case.options)
        options.fallback_node_type = "identifier"
        options.language_term = "named binding"
        options.owner_scope = "lexical"
        options.visibility_range = "structural_scope"
        local before = vim.deepcopy(options)

        local named = schema.named("binding", "name", "variable", options)
        local explicit_options = vim.deepcopy(options)
        explicit_options.fields = { name = "name" }
        explicit_options.children = { name = { node_type = "identifier" } }
        local explicit = schema.rule("binding", "variable", explicit_options)

        assert(vim.deep_equal(options, before), case.label .. ": input mutated")
        local valid, err = contract.validate_syntax(explicit.syntax, "explicit.syntax")
        assert(valid, case.label .. ": explicit rule invalid: " .. tostring(err))
        valid, err = contract.validate_syntax(named.syntax, "named.syntax")
        assert(valid, case.label .. ": named rule invalid: " .. tostring(err))
        if not vim.deep_equal(named, explicit) then
            failures[#failures + 1] = case.label
                .. ": constraints=" .. tostring(named.syntax.constraints ~= nil)
                .. ", exclusions=" .. tostring(named.syntax.exclusions ~= nil)
        end
    end

    -- Omitted name/fallback must remain omitted. No synthetic field.
    local unnamed = schema.named("binding", nil, "variable", {
        owner_scope = "lexical",
    })
    assert(unnamed.syntax.fields == nil and unnamed.syntax.children == nil,
        "named builder fabricated a missing name descriptor")

    assert(#failures == 0, "named/rule expansion differs: "
        .. table.concat(failures, "; "))
    print("PASS named builder preserves explicit constraints and exclusions")
    print("PASS named/rule expansion parity and legacy shorthand")
    print("PASS Tracker_HUD named Scope Member builder syntax smoke")
end

local ok, err = pcall(run)
if not ok then
    local diagnostic = "FAIL named Scope Member builder syntax smoke: " .. tostring(err)
    io.stderr:write(diagnostic .. "\n")
    io.stderr:flush()
    vim.api.nvim_err_writeln(diagnostic)
    vim.cmd("cquit 1")
else
    vim.cmd("qa!")
end
