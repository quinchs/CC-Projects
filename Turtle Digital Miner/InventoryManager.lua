exports = {}

local inventory = {}

local isDisposed = false

function getInventoryContents()
    local r = {}

    for i = 1, 16 do 
        r[i] = turtle.getItemDetail(i)
    end

    return r
end

function listener()
    while not isDisposed do
        os.pullEvent("turtle_inventory")
        
        inventory = getInventoryContents()
    end
end

exports.bind = function()
    if not turtle then error("No turtle found") end
    isDisposed = false
    listener()
end

exports.dispose = function() isDisposed = true end

exports.getInventory = function() return inventory end

exports.findItemSlot = function(search)
    for i, v in pairs(inventory) do
        if v then 
            if string.find(v.name, search) then return i end
        end
    end
    
    return nil
end

exports.findExpectedSlot = function(num, fallbackFilter)
    local d = turtle.getItemDetail(num)
    if not d or not string.find(d.name, fallbackFilter) then 
        num = exports.findItemSlot(fallbackFilter)

        if not num then error("No " .. fallbackFilter .. " in inventory") end
    end

    return num
end

exports.itemAtSlot = function(num, filter)
    local d = turtle.getItemDetail(num)
    if not d then return false end

    if string.find(d.name, filter) then
        return true 
    else return false end
end

return exports