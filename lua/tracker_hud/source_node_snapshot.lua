-- lua/tracker_hud/source_node_snapshot.lua
--
-- Refresh-local Tree-sitter node snapshot shared by stateless source consumers.
-- Tree-sitter node objects must never escape into persistent cross-refresh caches.

local M = {}


local function profile_counter(snapshot, suffix, delta)
    local opts =
        type(snapshot) == "table"
        and snapshot.profile_opts
        or nil

    if type(opts) ~= "table"
        or type(opts.profile_counter) ~= "function"
    then
        return
    end

    local prefix =
        opts.profile_prefix
        or "context.source_nodes"

    opts.profile_counter(
        prefix .. "." .. suffix,
        delta
    )
end


local function node_is_missing(node)
    if not node then
        return false
    end

    local ok, missing =
        pcall(function()
            return node:missing()
        end)

    return ok and missing == true
end


local function walk(node, snapshot)
    if not node then
        return
    end

    snapshot.node_count =
        snapshot.node_count + 1

    local node_type =
        node:type()

    snapshot.nodes[
        #snapshot.nodes + 1
    ] = node

    local by_type =
        snapshot.by_type[node_type]

    if type(by_type) ~= "table" then
        by_type = {}
        snapshot.by_type[node_type] =
            by_type
    end

    by_type[
        #by_type + 1
    ] = node

    local missing =
        node_is_missing(node)

    if node_type == "ERROR"
        or missing
    then
        snapshot.syntax_candidates[
            #snapshot.syntax_candidates + 1
        ] = {
            node = node,
            node_type = node_type,
            missing = missing,
        }
    end

    for child in node:iter_children() do
        walk(child, snapshot)
    end
end


local function ensure_built(snapshot)
    if type(snapshot) ~= "table"
        or not snapshot.root_node
    then
        return nil
    end

    if snapshot.built == true then
        return snapshot
    end

    snapshot.built = true

    profile_counter(
        snapshot,
        "walks",
        1
    )

    walk(
        snapshot.root_node,
        snapshot
    )

    profile_counter(
        snapshot,
        "nodes_visited",
        snapshot.node_count
    )

    return snapshot
end


function M.new(root_node, profile_opts)
    if not root_node then
        return nil
    end

    return {
        root_node = root_node,
        profile_opts =
            type(profile_opts) == "table"
            and profile_opts
            or {},
        built = false,
        node_count = 0,
        nodes = {},
        by_type = {},
        syntax_candidates = {},
    }
end


function M.nodes_by_type(snapshot, node_type)
    if type(node_type) ~= "string"
        or node_type == ""
    then
        return {}
    end

    snapshot =
        ensure_built(snapshot)

    if not snapshot then
        return nil
    end

    return snapshot.by_type[node_type]
        or {}
end


function M.syntax_candidates(snapshot)
    snapshot =
        ensure_built(snapshot)

    if not snapshot then
        return nil
    end

    return snapshot.syntax_candidates
end


return M
