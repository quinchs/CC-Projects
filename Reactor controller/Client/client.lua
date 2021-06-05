
local channel = 1235

local reactorName = "fissionReactorLogicAdapter"
local boilerName = "boilerValve"
local turbineName = "turbineValve"
local inductionName = "inductionPort"

-- Find Wireless Modems
local wirelessModems = table.pack(peripheral.find("modem", function(_, modem)
    return modem.isWireless()
end))

local modem = wirelessModems[1]

local connectedMachines = {
    reactors = {},
    boilers = {},
    turbines = {},
    inductions = {}
}

local opCodes = {
    toggleReactor = 1,
    updateBurnrate = 2,
    newData = 3,
}

function loadPeripherals()
    for i, v in pairs(peripheral.getNames()) do
        if string.find(v, reactorName .. "_%d") then 
            -- reactor
            table.insert(connectedMachines.reactors, peripheral.wrap(v))
            print("Reactor at", i, v)

        elseif string.find(v, boilerName .. "_%d") then
            -- boiler
            table.insert(connectedMachines.boilers, peripheral.wrap(v))
            print("Boiler at", i, v)

        elseif string.find(v, turbineName .. "_%d") then 
            -- turbine
            table.insert(connectedMachines.turbines, peripheral.wrap(v))
            print("Turbine at", i, v)

        elseif string.find(v, inductionName .. "_%d") then
            -- induction 
            table.insert(connectedMachines.inductions, peripheral.wrap(v))
            print("Induction at", i, v)
            
        end
    end
end


function readReactor(i, v)
    local r = {
        id = i,
    }

    parallel.waitForAll(
        function () r.active = v.getStatus() end,
        function () r.coolantPercent = v.getCoolantFilledPercentage() end,
        function () r.coolantCapacity = v.getCoolantCapacity() end,
        function () r.heatedCoolantPercent = v.getHeatedCoolantFilledPercentage() end,
        function () r.heatedCoolantCapacity = v.getHeatedCoolantCapacity() end,
        function () r.fuelAmount = v.getFuel().amount end,
        function () r.fuelPercent = v.getFuelFilledPercentage() end,
        function () r.fuelCapacity = v.getFuelCapacity() end,
        function () r.wasteAmount = v.getWaste().amount end,
        function () r.wastePercent = v.getWasteFilledPercentage() end,
        function () r.wasteCapacity = v.getWasteCapacity() end,
        function () r.burnRate = v.getBurnRate() end,
        function () r.actualBurnRate = v.getActualBurnRate() end,
        function () r.maxBurnRate = v.getMaxBurnRate() end,
        function () r.damagePercent = v.getDamagePercent() end,
        function () r.heatingRate = v.getHeatingRate() end,
        function () r.tempature = v.getTemperature() end,
        function () r.coolant = v.getCoolant() end,
        function () r.heatedCoolant = v.getHeatedCoolant() end
    )

    local parsedCoolantName = getCoolantName(r.coolant.name)
    r.coolant = {
        name = parsedCoolantName,
        amount = r.coolant.amount
    }
    r.heatedCoolant = {
        name = getHeatedCoolantName(parsedCoolantName),
        amount = r.heatedCoolant.amount
    }
    return r
end


function getValues()
    returnData = {}
    --local t = os.clock()
    if #connectedMachines.reactors > 0 then 
        returnData.reactors = {}

        for i, v in pairs(connectedMachines.reactors) do
            local t = os.clock()
            local s, data = pcall(readReactor, i, v)
            local r = os.clock() - t
            print("Took", r, "s for read")

            if not s then 
                connectedMachines.reactors[i] = nil 
                print("Reactor " .. tostring(i) .. " Disconnected:", data)
            else returnData.reactors[i] = data end
        end
    end

    -- local r = os.clock() - t
    -- print("Took", r, "s for read")

    return returnData
end

function getHeatedCoolantName(coolant)
    if coolant == "Water" then return "Steam" 
    elseif coolant == "Sodium" then return "Superheated Sodium"
    else return "Unknown" end
end

function getCoolantName(fullName)
    local term = Split(fullName, ":")
    return term[2]:gsub("^%l", string.upper)
end

function Split(s, delimiter)
    result = {};
    for match in (s..delimiter):gmatch("(.-)"..delimiter) do
        table.insert(result, match);
    end
    return result;
end

function handleMessage(data)
    if data.op == opCodes.toggleReactor then
        local reactor = connectedMachines.reactors[data.p.id]
        
        if reactor then 
            local x, y = nil, nil
            if not reactor.getStatus() and data.p.value then  x, y = pcall(reactor.activate)
            else x, y = pcall(reactor.scram) end
            print(x, y)
        end

    elseif data.op == opCodes.updateBurnrate then 
        local reactor = connectedMachines.reactors[data.p.id]

        local x, y = pcall(reactor.setBurnRate, data.p.value)
        print(x, y)
    end
end


function transmitData()
    while true do 
        local s, data = pcall(getValues)
        if s then 
            modem.transmit(1230, channel, {
                op = 3,
                p = data
            })
            os.sleep(0.1)
        else 

        end
    end
end

function listenForEvents()
    while true do 
        local event = {os.pullEvent()}

        local eventName = event[1]
    
        if eventName == "modem_message" then
            local msg = event[5]
            handleMessage(msg)
        end
    end
end


modem.open(channel)

print("Loading peripherals")
loadPeripherals()

function test() return "aaa" end

x, y = parallel.waitForAll(test)

print(x, y)

parallel.waitForAll(listenForEvents, transmitData)
