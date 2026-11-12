-- lua/tracker_hud/low_level/machine_address.lua
--
-- Certainty-aware machine-address provider aggregation.
--
-- Source locations, labels, and syntax may be used as provider query keys,
-- but this module never derives a machine address from them. A provider must
-- return an explicit exact address value with provenance.

local integer_value = require("tracker_hud.low_level.integer_value")

local M = {}

local valid_query_kinds = {
    instruction = true,
    next_instruction = true,
    symbol = true,
}

local function unknown(reason, details)
    return {
        status = "unknown",
        value = nil,
        bits = nil,
        reason = reason,
        details = details or {},
    }
end

local function valid_bits(bits)
    return type(bits) == "number"
        and bits > 0
        and bits == math.floor(bits)
end

local function normalize_query(query)
    if type(query) ~= "table" then
        return nil, "machine-address query must be a table"
    end

    if type(query.kind) ~= "string"
        or not valid_query_kinds[query.kind]
    then
        return nil, "unsupported machine-address query kind"
    end

    if query.kind == "symbol"
        and (type(query.name) ~= "string" or query.name == "")
    then
        return nil, "symbol query requires a name"
    end

    return vim.deepcopy(query), nil
end

local function provider_identity(provider, index)
    local id = type(provider) == "table"
        and provider.id
        or nil

    if type(id) ~= "string" or id == "" then
        id = "provider#" .. tostring(index)
    end

    local kind = type(provider) == "table"
        and provider.kind
        or nil

    if type(kind) ~= "string" or kind == "" then
        kind = "machine_address"
    end

    return id, kind
end

local function normalize_known_result(
    provider,
    provider_index,
    result,
    opts
)
    local provider_id, provider_kind =
        provider_identity(
            provider,
            provider_index
        )

    local value = integer_value.normalize(
        result.value
    )

    if not value or value:sub(1, 1) == "-" then
        return nil, {
            provider_id = provider_id,
            provider_kind = provider_kind,
            status = "unknown",
            reason = "provider returned invalid machine address",
        }
    end

    local result_bits = result.bits
    local target_bits = opts.bits

    if result_bits ~= nil
        and not valid_bits(result_bits)
    then
        return nil, {
            provider_id = provider_id,
            provider_kind = provider_kind,
            status = "unknown",
            reason = "provider returned invalid address width",
        }
    end

    if target_bits ~= nil
        and not valid_bits(target_bits)
    then
        return nil, {
            provider_id = provider_id,
            provider_kind = provider_kind,
            status = "unknown",
            reason = "requested address width is invalid",
        }
    end

    local check_bits = target_bits or result_bits

    if check_bits
        and not integer_value.fits_unsigned(
            value,
            check_bits
        )
    then
        return nil, {
            provider_id = provider_id,
            provider_kind = provider_kind,
            status = "unknown",
            reason = "machine address does not fit address width",
            value = value,
            bits = check_bits,
        }
    end

    local provenance = type(result.provenance) == "table"
        and vim.deepcopy(result.provenance)
        or {}

    provenance.provider_id = provider_id
    provenance.provider_kind = provider_kind

    return {
        status = "known",
        value = value,
        bits = target_bits or result_bits,
        provenance = provenance,
    }, nil
end

local function normalize_provider_result(
    provider,
    provider_index,
    result,
    opts
)
    local provider_id, provider_kind =
        provider_identity(
            provider,
            provider_index
        )

    if result == nil then
        return nil, {
            provider_id = provider_id,
            provider_kind = provider_kind,
            status = "unknown",
            reason = "provider made no address claim",
        }
    end

    if type(result) ~= "table" then
        return nil, {
            provider_id = provider_id,
            provider_kind = provider_kind,
            status = "unknown",
            reason = "provider returned invalid result",
        }
    end

    if result.status == "known"
        or (result.status == nil and result.value ~= nil)
    then
        return normalize_known_result(
            provider,
            provider_index,
            result,
            opts
        )
    end

    return nil, {
        provider_id = provider_id,
        provider_kind = provider_kind,
        status = "unknown",
        reason = result.reason
            or "provider did not prove a machine address",
        details = type(result.details) == "table"
            and vim.deepcopy(result.details)
            or nil,
    }
end

function M.resolve(providers, query, opts)
    opts = opts or {}

    local normalized_query, query_error =
        normalize_query(query)

    if not normalized_query then
        return unknown(
            query_error,
            {
                query = type(query) == "table"
                    and vim.deepcopy(query)
                    or query,
            }
        )
    end

    if opts.bits ~= nil
        and not valid_bits(opts.bits)
    then
        return unknown(
            "requested address width is invalid",
            {
                bits = opts.bits,
                query = normalized_query,
            }
        )
    end

    local known = {}
    local evidence = {}
    local provider_ids = {}

    for index, provider in ipairs(providers or {}) do
        local provider_id =
            provider_identity(
                provider,
                index
            )

        if provider_ids[provider_id] then
            return unknown(
                "duplicate machine-address provider id",
                {
                    provider_id = provider_id,
                    query = normalized_query,
                }
            )
        end

        provider_ids[provider_id] = true

        if type(provider) ~= "table"
            or type(provider.resolve) ~= "function"
        then
            evidence[#evidence + 1] = {
                provider_id = provider_id,
                status = "unknown",
                reason = "provider resolver unavailable",
            }
        else
            local ok, result = pcall(
                provider.resolve,
                vim.deepcopy(normalized_query)
            )

            if not ok then
                local _, provider_kind =
                    provider_identity(
                        provider,
                        index
                    )

                evidence[#evidence + 1] = {
                    provider_id = provider_id,
                    provider_kind = provider_kind,
                    status = "unknown",
                    reason = "provider resolver failed",
                    error = tostring(result),
                }
            else
                local normalized, rejected =
                    normalize_provider_result(
                        provider,
                        index,
                        result,
                        opts
                    )

                if normalized then
                    known[#known + 1] = normalized
                    evidence[#evidence + 1] = {
                        provider_id =
                            normalized.provenance.provider_id,
                        provider_kind =
                            normalized.provenance.provider_kind,
                        status = "known",
                        value = normalized.value,
                        bits = normalized.bits,
                        provenance =
                            vim.deepcopy(
                                normalized.provenance
                            ),
                    }
                elseif rejected then
                    evidence[#evidence + 1] = rejected
                end
            end
        end
    end

    if #known == 0 then
        return unknown(
            "machine address unavailable",
            {
                query = normalized_query,
                evidence = evidence,
            }
        )
    end

    local expected_value = known[1].value

    for _, candidate in ipairs(known) do
        if candidate.value ~= expected_value then
            local candidates = {}

            for _, item in ipairs(known) do
                candidates[#candidates + 1] = {
                    value = item.value,
                    bits = item.bits,
                    provenance =
                        vim.deepcopy(
                            item.provenance
                        ),
                }
            end

            return unknown(
                "machine address conflict",
                {
                    query = normalized_query,
                    candidates = candidates,
                    evidence = evidence,
                }
            )
        end
    end

    local provenance = {}

    for _, candidate in ipairs(known) do
        provenance[#provenance + 1] =
            vim.deepcopy(
                candidate.provenance
            )
    end

    return {
        status = "known",
        value = expected_value,
        bits = opts.bits or known[1].bits,
        reason = nil,
        query = normalized_query,
        provenance = provenance,
        evidence = evidence,
    }
end

return M
