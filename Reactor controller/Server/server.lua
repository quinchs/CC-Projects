local utils = require "gplus"
local reactorScreen = require "reactorScreen"
local electricScreen = require "electricScreen"

local hostPort, clientPort = 1230, 1235
local reactorMonitor, electricMonitor = peripheral.wrap("left"), peripheral.wrap("right")

if not reactorMonitor then error("No reactorMonitor found") end

local modem = peripheral.find("modem")
if not modem then error("No modem found") end

electricMonitor.clear()
reactorMonitor.clear()

local data = {
}

local opCodes = {
    toggleReactor = 1,
    updateBurnrate = 2,
    newData = 3,
}

function sendToClient(opCode, payload)
    modem.transmit(clientPort, hostPort, {
        op = opCode,
        p = payload
    })
end

function toggleReactor(id, value)
    term.write("Callback toggleReactor: ".. tostring(id) .. " " .. tostring(value))
    sendToClient(opCodes.toggleReactor, {
        id = id,
        value = not data.reactors[id].active
    })
end

function changeBurnRate(id, value)
    term.write("Callback changeBurnRate: ".. tostring(id) .. " " .. tostring(value))

    local currRate = data.reactors[id].burnRate

    print(currRate)
    
    if value then 
        if currRate < data.reactors[id].maxBurnRate then 
            currRate = currRate + 0.1
        end
    else 
        if currRate == 0.1 then 
            currRate = 0
        else currRate = currRate - 0.1 end
    end

    sendToClient(opCodes.updateBurnrate, {
        id = id,
        value = currRate
    })
end

function mainRender()
    while true do 
        reactorScreen.render(data)
        electricScreen.render({
            matrix = {
                energy = 124949000042,
                maxEnergy = 12800000900000,
                energyPercent = 1,
                energyIn = 19414143,
                energyOut = 1941414,
                energyTransferCap = 19414143
            },
            tanks = {
                {
                    name = "mekanism:sodium",
                    amount = 123415,
                    filledPercent = 1,
                    capacity = 1234151,
                },
                {
                    name = "minecraft:water",
                    amount = 123415,
                    filledPercent = 1,
                    capacity = 1234151,
                }
            },
            boiler = {
                waterAmount = 1294781924,
                waterPercent = 1,
                waterCapacity = 141412314,

                cooledCoolant = 1,
                cooledCoolantPercent = 1,
                cooledCoolantCapacity = 1414,

                heatedCoolant = 13,
                heatedCoolantCapacity = 14141231434,
                heatedCoolantPercent = 1,

                steamAmount = 10,
                steamPercent = 1,
                steamCapacity = 1000,
  
                tempature = 100,
                boilRate = 100,
                boilCapacity = 141414,


            }
        })
        os.sleep(1)
    end
end

function checkNewData(newData)
    if newData then
        if newData.reactors then
            for i, v in pairs(newData.reactors) do
                if v.active then 
                    if v.damagePercent > 0 then
                        -- disable
                        toggleReactor(v.id, false)
                    elseif v.coolantPercent < 0.1 then 
                        toggleReactor(v.id, false)
                    elseif v.tempature > 1200 then 
                        toggleReactor(v.id, false)
                    elseif v.wastePercent > 0.05 then 
                        toggleReactor(v.id, false)
                    elseif v.heatedCoolantPercent > 0.1 then 
                        toggleReactor(v.id, false)
                    end
                end
                
            end
        end
    end

    
end

function listeners()
    while true do 
        local args = {os.pullEvent()}
    
        local eventName = args[1]
    
        if eventName == "monitor_touch" then
            print("touch")
            utils.handleClick(reactorMonitor, args[3], args[4])
        elseif eventName == "modem_message" then 
            local eventData = args[5]

            if eventData.op == opCodes.newData then
                data = eventData.p
            end

            checkNewData(eventData.p)
        end
    end
end

-- Open the modem
modem.open(hostPort)

-- init 
local callbacks = {}

callbacks.toggleReactor = toggleReactor
callbacks.changeBurnRate = changeBurnRate

reactorScreen.init(reactorMonitor, callbacks, utils)
electricScreen.init(electricMonitor, nil, utils)

parallel.waitForAny(mainRender, listeners)
