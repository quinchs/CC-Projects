exports = {}

exports.setItemOutput = function(per)
    parallel.waitForAll(
        function() per.setMode(6, 0, 4) end,
        function() per.setMode(6, 1, 4) end,
        function() per.setMode(6, 2, 4) end,
        function() per.setMode(6, 3, 4) end,
        function() per.setMode(6, 4, 4) end,
        function() per.setMode(6, 5, 4) end
    )
end

exports.setPowerOutput = function(per)
    parallel.waitForAll(
        function() per.setMode(0, 0, 4) end,
        function() per.setMode(0, 1, 4) end,
        function() per.setMode(0, 2, 4) end,
        function() per.setMode(0, 3, 4) end,
        function() per.setMode(0, 4, 4) end,
        function() per.setMode(0, 5, 4) end
    )
end

exports.compareFilters = function(cmp, per)
    -- get the filters
    local filters = per.getFilters()

    if cmp == nil and #filters == 0 then return true end

    if #cmp ~= #filters then return false end

    for i, v in pairs(filters) do
        local fV = cmp[i]

        if 
            fV.type ~= v.type or
            fV.requireReplace ~= v.requireReplace or
            fV.replaceItem ~= v.replaceItem or
            fV.materialItem ~= v.materialItem or
            fV.modId ~= v.modId or
            fV.tag ~= v.tag 
        then return false end
    end

    return true
end

exports.setFilters = function(per, filters)
    for i, v in pairs(filters) do
        per.addFilter(v)
    end
end

exports.clearFilters = function(per)
    local f = per.getFilters()

    for i, v in pairs(f) do
        per.removeFilter(v)
    end
end

return exports