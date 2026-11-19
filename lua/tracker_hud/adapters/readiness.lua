-- lua/tracker_hud/adapters/readiness.lua
--
-- On-demand adapter authoring/readiness diagnostic.
--
-- This module is intentionally outside the cursor refresh hot path. It checks
-- the current buffer's filetype -> Tree-sitter parser -> syntax root -> adapter
-- registration -> Adapter Contract chain when explicitly requested.

local core =
    require("tracker_hud.core")
local registry =
    require(
        "tracker_hud.adapters.registry"
    )

local M = {}


local function current_or_explicit_buffer(
    bufnr
)
    if bufnr == nil
        or bufnr == 0
    then
        return vim.api
            .nvim_get_current_buf()
    end

    return bufnr
end


local function parser_status(
    bufnr,
    language
)
    local ok,
        parser_or_err,
        parser_err =
        pcall(
            vim.treesitter.get_parser,
            bufnr,
            language
        )

    if not ok then
        return false,
            nil,
            tostring(parser_or_err)
    end

    if not parser_or_err then
        return false,
            nil,
            tostring(
                parser_err
                or "parser unavailable"
            )
    end

    return true,
        parser_or_err,
        nil
end


local function root_status(
    parser
)
    local ok,
        trees_or_err =
        pcall(function()
            return parser:parse()
        end)

    if not ok then
        return false,
            nil,
            tostring(trees_or_err)
    end

    local tree =
        type(trees_or_err) == "table"
        and trees_or_err[1]
        or nil

    if not tree then
        return false,
            nil,
            "parser produced no root tree"
    end

    local root =
        tree:root()

    if not root then
        return false,
            nil,
            "parser produced no root node"
    end

    return true,
        root:type(),
        nil
end


function M.inspect(bufnr)
    bufnr =
        current_or_explicit_buffer(
            bufnr
        )

    local result = {
        bufnr = bufnr,
        ready = false,
        filetype_known = false,
        language_resolved = false,
        parser_available = false,
        root_available = false,
        adapter_registered = false,
        adapter_valid = false,
    }

    if not vim.api
        .nvim_buf_is_valid(bufnr)
    then
        result.buffer_error =
            "buffer is invalid"
        return result
    end

    local filetype =
        vim.bo[bufnr].filetype

    result.filetype =
        filetype
    result.filetype_known =
        core.is_non_empty_string(
            filetype
        )

    if not result.filetype_known then
        result.filetype_error =
            "buffer has no filetype"
        return result
    end

    local language =
        vim.treesitter.language
            .get_lang(filetype)

    result.language =
        language
    result.language_resolved =
        core.is_non_empty_string(
            language
        )

    if result.language_resolved then
        local parser_ok,
            parser,
            parser_err =
            parser_status(
                bufnr,
                language
            )

        result.parser_available =
            parser_ok
        result.parser_error =
            parser_err

        if parser_ok then
            local root_ok,
                root_type,
                root_err =
                root_status(
                    parser
                )

            result.root_available =
                root_ok
            result.root_type =
                root_type
            result.root_error =
                root_err
        end
    else
        result.language_error =
            "Tree-sitter language could not be resolved"
    end

    local adapter =
        registry.get_adapter(
            filetype
        )

    result.adapter_registered =
        adapter ~= nil
    result.adapter_name =
        adapter
        and adapter.name
        or nil

    if adapter then
        local valid,
            validation_err =
            registry.validate_adapter(
                adapter
            )

        result.adapter_valid =
            valid == true
        result.adapter_error =
            validation_err
    end

    result.ready =
        result.filetype_known
        and result.language_resolved
        and result.parser_available
        and result.root_available
        and result.adapter_registered
        and result.adapter_valid

    return result
end


local function status_word(
    ok
)
    return ok
        and "[OK]"
        or "[MISSING]"
end


function M.lines(result)
    result =
        type(result) == "table"
        and result
        or {}

    local lines = {
        "Tracker_HUD adapter readiness",
        status_word(
            result.filetype_known
        )
            .. " filetype: "
            .. tostring(
                result.filetype
                or "<none>"
            ),
        status_word(
            result.language_resolved
        )
            .. " Tree-sitter language: "
            .. tostring(
                result.language
                or "<unresolved>"
            ),
        status_word(
            result.parser_available
        )
            .. " parser: "
            .. (
                result.parser_available
                and "available"
                or tostring(
                    result.parser_error
                    or "unavailable"
                )
            ),
        status_word(
            result.root_available
        )
            .. " root: "
            .. tostring(
                result.root_type
                or result.root_error
                or "<unavailable>"
            ),
        status_word(
            result.adapter_registered
        )
            .. " adapter: "
            .. tostring(
                result.adapter_name
                or "<not registered>"
            ),
        status_word(
            result.adapter_valid
        )
            .. " contract: "
            .. (
                result.adapter_valid
                and "valid"
                or tostring(
                    result.adapter_error
                    or "not validated"
                )
            ),
        result.ready
            and "[READY] adapter pipeline is ready"
            or "[NOT READY] fix the first missing/invalid item above",
    }

    return lines
end


function M.message(result)
    return table.concat(
        M.lines(result),
        "\n"
    )
end


return M
