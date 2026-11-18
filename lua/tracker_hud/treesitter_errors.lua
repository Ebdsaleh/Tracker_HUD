-- lua/tracker_hud/treesitter_errors.lua
--
-- Generic Tree-sitter syntax warning provider.

local core = require("tracker_hud.core")

local M = {}


local function profile_counter(
    opts,
    suffix,
    delta
)
    if type(opts) ~= "table"
        or type(opts.profile_counter)
            ~= "function"
    then
        return
    end

    local prefix =
        opts.profile_prefix
        or "context.warnings"

    opts.profile_counter(
        prefix
            .. ".syntax."
            .. suffix,
        delta
    )
end


local function node_is_missing(node)
    if not node then
        return false
    end

    local ok, missing = pcall(function()
        return node:missing()
    end)

    return ok and missing == true
end


local function node_range(node)
    if not node then
        return nil
    end

    local start_row, start_column, end_row, end_column = node:range()

    if not core.is_number(start_row) or not core.is_number(end_row) then
        return nil
    end

    return {
        source_line = start_row + 1,
        source_column = start_column or 0,

        source_start_line = start_row + 1,
        source_start_column = start_column or 0,
        source_end_line = end_row + 1,
        source_end_column = end_column or 0,
    }
end


local function line_is_comment(bufnr, line_number, comment_spec)
    if not bufnr
        or not line_number
        or not core.is_table(comment_spec)
        or not core.is_table(comment_spec.line)
    then
        return false
    end

    local lines = vim.api.nvim_buf_get_lines(
        bufnr,
        line_number - 1,
        line_number,
        false
    )

    local line = lines[1]

    if not core.is_non_empty_string(line) then
        return false
    end

    local trimmed = line:match("^%s*(.-)%s*$") or ""

    for _, line_comment in ipairs(comment_spec.line) do
        if core.is_table(line_comment)
            and core.is_non_empty_string(line_comment.prefix)
            and trimmed:sub(1, #line_comment.prefix) == line_comment.prefix
        then
            return true
        end
    end

    return false
end


local function warning_is_inside_comment(bufnr, range, opts)
    if not range then
        return false
    end

    return line_is_comment(
        bufnr,
        range.source_line,
        opts and opts.comments
    )
end


local function classify_warning_location(range, opts)
    opts = opts or {}

    if not range then
        return "unknown"
    end

    local cursor_line = opts.cursor_line
    local scope_start_line = opts.scope_start_line
    local scope_end_line = opts.scope_end_line

    local start_line = range.source_start_line or range.source_line
    local end_line = range.source_end_line or range.source_line

    if not start_line or not end_line then
        return "unknown"
    end

    if cursor_line and cursor_line >= start_line and cursor_line <= end_line then
        return "current"
    end

    if scope_start_line
        and scope_end_line
        and start_line >= scope_start_line
        and start_line <= scope_end_line
    then
        return "scope"
    end

    if cursor_line and start_line < cursor_line then
        return "earlier"
    end

    return "file"
end


local persistent_discovery_cache = nil
local syntax_warning_module_token = tostring({})
local syntax_warning_buffer_token_serial = 0
local issued_syntax_warning_buffer_tokens = {}


local function get_buffer_revision(
    bufnr
)
    if not vim
        or not vim.api
        or type(
            vim.api.nvim_buf_get_changedtick
        ) ~= "function"
        or type(
            vim.api.nvim_buf_get_var
        ) ~= "function"
        or type(
            vim.api.nvim_buf_set_var
        ) ~= "function"
    then
        return nil
    end

    local ok_tick, changedtick =
        pcall(
            vim.api.nvim_buf_get_changedtick,
            bufnr
        )

    if not ok_tick then
        return nil
    end

    local variable_name =
        "tracker_hud_syntax_warning_cache_token"

    local ok_token, token =
        pcall(
            vim.api.nvim_buf_get_var,
            bufnr,
            variable_name
        )

    local expected_prefix =
        syntax_warning_module_token
        .. ":"

    if not ok_token
        or type(token) ~= "string"
        or token:sub(
            1,
            #expected_prefix
        ) ~= expected_prefix
        or issued_syntax_warning_buffer_tokens[
            token
        ] ~= true
    then
        syntax_warning_buffer_token_serial =
            syntax_warning_buffer_token_serial
            + 1

        token =
            expected_prefix
            .. tostring(
                syntax_warning_buffer_token_serial
            )

        issued_syntax_warning_buffer_tokens[
            token
        ] = true

        local ok_set =
            pcall(
                vim.api.nvim_buf_set_var,
                bufnr,
                variable_name,
                token
            )

        if not ok_set then
            return nil
        end
    end

    return {
        token = token,
        changedtick = changedtick,
    }
end


local function persistent_discovery_matches(
    bufnr,
    filetype,
    revision
)
    local cached =
        persistent_discovery_cache

    return type(cached) == "table"
        and type(revision) == "table"
        and cached.bufnr == bufnr
        and cached.buffer_token
            == revision.token
        and cached.changedtick
            == revision.changedtick
        and cached.filetype
            == filetype
        and type(cached.candidates)
            == "table"
end


local function remember_persistent_discovery(
    bufnr,
    filetype,
    revision,
    candidates
)
    if type(revision) ~= "table"
        or type(candidates) ~= "table"
    then
        persistent_discovery_cache =
            nil
        return
    end

    persistent_discovery_cache = {
        bufnr = bufnr,
        buffer_token = revision.token,
        changedtick = revision.changedtick,
        filetype = filetype,
        candidates = candidates,
    }
end


local function candidate_from_node(
    node,
    node_type,
    is_missing
)
    return {
        node_type =
            node_type
            or "<unknown>",
        missing =
            is_missing == true,
        range =
            node_range(node),
    }
end


local function make_syntax_warning(
    candidate,
    opts
)
    opts = opts or {}

    local node_type =
        candidate
        and candidate.node_type
        or "<unknown>"

    local range =
        candidate
        and candidate.range
        or {}

    local is_missing =
        candidate
        and candidate.missing
            == true

    local message =
        "Tree-sitter parse error"

    if is_missing then
        message =
            "Tree-sitter missing node: "
            .. tostring(node_type)
    end

    local location =
        classify_warning_location(
            range,
            opts
        )

    return {
        message = message,
        kind = "warning",
        severity = "syntax",
        category = "parser",
        source = "treesitter",

        source_line = range.source_line,
        source_column = range.source_column,

        source_start_line =
            range.source_start_line,
        source_start_column =
            range.source_start_column,
        source_end_line =
            range.source_end_line,
        source_end_column =
            range.source_end_column,

        metadata = {
            provider = "treesitter",
            node_type = node_type,
            missing = is_missing,
            filetype = opts.filetype,
            location = location,
        },
    }
end


local function discover_from_node(
    node,
    candidates,
    opts
)
    if not node then
        return
    end

    opts = opts or {}

    profile_counter(
        opts,
        "nodes_visited",
        1
    )

    local node_type =
        node:type()

    local is_error =
        node_type == "ERROR"

    local is_missing =
        node_is_missing(node)

    if is_error or is_missing then
        profile_counter(
            opts,
            "candidates",
            1
        )

        table.insert(
            candidates,
            candidate_from_node(
                node,
                node_type,
                is_missing
            )
        )
    end

    for child in node:iter_children() do
        discover_from_node(
            child,
            candidates,
            opts
        )
    end
end


function M.discover(
    root_node,
    opts
)
    opts = opts or {}

    local candidates = {}

    if not root_node then
        return candidates
    end

    profile_counter(
        opts,
        "scans",
        1
    )

    discover_from_node(
        root_node,
        candidates,
        opts
    )

    return candidates
end


function M.select(
    bufnr,
    candidates,
    opts
)
    opts = opts or {}

    local warnings = {}

    for _, candidate in ipairs(
        candidates or {}
    ) do
        local range =
            candidate.range

        if not warning_is_inside_comment(
            bufnr,
            range,
            opts
        )
            and (
                not opts.cursor_line
                or not range
                or range.source_line
                    <= opts.cursor_line
            )
        then
            table.insert(
                warnings,
                make_syntax_warning(
                    candidate,
                    opts
                )
            )
        end
    end

    return warnings
end


function M.collect(
    bufnr,
    root_node,
    opts
)
    opts = opts or {}

    if not bufnr
        or not root_node
    then
        return {}
    end

    local revision =
        get_buffer_revision(
            bufnr
        )

    local candidates = nil

    if persistent_discovery_matches(
        bufnr,
        opts.filetype,
        revision
    )
    then
        profile_counter(
            opts,
            "cross_refresh_reuse_possible",
            1
        )

        profile_counter(
            opts,
            "cross_refresh_reuse_applied",
            1
        )

        candidates =
            persistent_discovery_cache
                .candidates
    else
        profile_counter(
            opts,
            "cross_refresh_reuse_miss",
            1
        )

        candidates =
            M.discover(
                root_node,
                opts
            )

        remember_persistent_discovery(
            bufnr,
            opts.filetype,
            revision,
            candidates
        )
    end

    return M.select(
        bufnr,
        candidates,
        opts
    )
end


return M
