-- tests/treesitter_warning_cache_smoke.lua
-- Source-derived Tree-sitter warning discovery must be reusable across
-- cursor-only refreshes while selection/classification stays fresh.

vim.opt.runtimepath:prepend(vim.fn.getcwd())

package.loaded[
    "tracker_hud.treesitter_errors"
] = nil

local provider =
    require(
        "tracker_hud.treesitter_errors"
    )


local function fake_node(
    node_type,
    start_row,
    end_row,
    children,
    missing
)
    local node = {}

    function node:type()
        return node_type
    end

    function node:missing()
        return missing == true
    end

    function node:range()
        return start_row,
            0,
            end_row,
            3
    end

    function node:iter_children()
        local values =
            children or {}

        local index = 0

        return function()
            index = index + 1
            return values[index]
        end
    end

    return node
end


local error_node =
    fake_node(
        "ERROR",
        1,
        1,
        {}
    )

local root =
    fake_node(
        "program",
        0,
        2,
        {
            error_node,
        }
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
    {
        "ok",
        "bad",
        "tail",
    }
)

local counters = {}

local function add_counter(
    name,
    delta
)
    counters[name] =
        (counters[name] or 0)
        + (delta or 1)
end


local function collect(
    opts
)
    opts = opts or {}
    opts.filetype = "probe"
    opts.profile_counter =
        add_counter

    return provider.collect(
        buffer,
        root,
        opts
    )
end


local before =
    collect({
        cursor_line = 1,
    })

assert(
    #before == 0,
    "syntax warning appeared before cursor"
)

assert(
    counters[
        "context.warnings.syntax.cross_refresh_reuse_miss"
    ] == 1
        and counters[
            "context.warnings.syntax.scans"
        ] == 1
        and counters[
            "context.warnings.syntax.nodes_visited"
        ] == 2
        and counters[
            "context.warnings.syntax.candidates"
        ] == 1,
    "initial syntax-warning discovery measurement changed"
)

local current =
    collect({
        cursor_line = 2,
    })

assert(
    #current == 1
        and current[1]
            .metadata
            .location
            == "current",
    "reused syntax discovery did not classify current cursor freshly"
)

assert(
    counters[
        "context.warnings.syntax.cross_refresh_reuse_possible"
    ] == 1
        and counters[
            "context.warnings.syntax.cross_refresh_reuse_applied"
        ] == 1
        and counters[
            "context.warnings.syntax.scans"
        ] == 1,
    "unchanged source did not reuse syntax-warning discovery"
)

local suppressed =
    collect({
        cursor_line = 2,
        comments = {
            line = {
                {
                    prefix = "bad",
                },
            },
        },
    })

assert(
    #suppressed == 0
        and counters[
            "context.warnings.syntax.cross_refresh_reuse_applied"
        ] == 2
        and counters[
            "context.warnings.syntax.scans"
        ] == 1,
    "comment filtering was cached instead of selected freshly"
)

local descriptors =
    provider.discover(
        root,
        {}
    )

assert(
    #descriptors == 1
        and descriptors[1].node_type
            == "ERROR"
        and descriptors[1].range
            .source_line
            == 2
        and descriptors[1].node
            == nil,
    "syntax-warning discovery retained parser node identity"
)

vim.api.nvim_buf_set_lines(
    buffer,
    0,
    1,
    false,
    {
        "changed",
    }
)

local after_edit =
    collect({
        cursor_line = 2,
    })

assert(
    #after_edit == 1
        and counters[
            "context.warnings.syntax.cross_refresh_reuse_miss"
        ] == 2
        and counters[
            "context.warnings.syntax.scans"
        ] == 2,
    "buffer edit did not invalidate syntax-warning discovery"
)

local other_buffer =
    vim.api.nvim_create_buf(
        false,
        true
    )

vim.api.nvim_buf_set_lines(
    other_buffer,
    0,
    -1,
    false,
    {
        "ok",
        "bad",
        "tail",
    }
)

local other =
    provider.collect(
        other_buffer,
        root,
        {
            filetype = "probe",
            cursor_line = 2,
            profile_counter =
                add_counter,
        }
    )

assert(
    #other == 1
        and counters[
            "context.warnings.syntax.cross_refresh_reuse_miss"
        ] == 3
        and counters[
            "context.warnings.syntax.scans"
        ] == 3,
    "syntax-warning discovery crossed buffer identity"
)

vim.api.nvim_buf_delete(
    buffer,
    {
        force = true,
    }
)

vim.api.nvim_buf_delete(
    other_buffer,
    {
        force = true,
    }
)

print(
    "PASS Tree-sitter warning cache: "
        .. "unchanged source reuses immutable discovery"
)

print(
    "PASS Tree-sitter warning cache: "
        .. "cursor/comment selection remains fresh"
)

print(
    "PASS Tree-sitter warning cache: "
        .. "edits and buffer identity invalidate safely"
)

print(
    "PASS Tracker_HUD Tree-sitter warning cache smoke"
)
