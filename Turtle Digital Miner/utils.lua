local json = require "json"

exports = {}

exports.setState = function(activity, step)
    saveOptions("state.json", {activity = activity, step = step})
end

exports.loadState = function()
    return json.decodeFromFile("state.json")
end

exports.loadOptions = function(path)
    return json.decodeFromFile(path)
end

exports.saveOptions = function(path, filters)
    local content = json.encode(filters)

    local handle = io.open(path, "w")
    handle.write(content)
    handle.close()
end

return exports