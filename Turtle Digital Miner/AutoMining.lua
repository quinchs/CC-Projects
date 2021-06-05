local inv = require "inventoryManager"
local mekUtils = require "MekUtils"
local utils = require "utils"
-- config

-- The channel for the QIO importer to import on.
local depoChannel = "Mining depo"

-- The channel for the turtle to refuel on
local fuelChannel = "Coal" 

-- The channel for the power.
local powerChannel = "Power"

-- The channel of the server to send commands to this turtle
local serverChannel = 1400

-- The channel for this miner
local clientChannel = 1400 + os.getComputerID()

-- the default miner filters file
local optionsFile = "filters.json"

-- Dont change this
local options = {}

-- get the modem
local modem = peripheral.find("modem")
if not modem then error("No modem found") end

local stateCodes = {
    deployQIO = 1,
    refuel = 2,
    deployDigitalMiner = 3,
    deployPower = 4,
    deployAll = 5,
    waitForMiner = 6,
    salvageAll = 7,
}

local running = true

function deployQIO()
    return pcall(function() 
        local slot = inv.findExpectedSlot(2, "qio")
        
        turtle.select(slot)
        turtle.place()

        turtle.down()
        turtle.forward()

        -- the QIO importer should be right in front of us so lets get the peripheral.
        local qio = peripheral.wrap("top")
        if not qio then error("No QIO found in front") end

        if not qio.setFrequency then error("Front peripheral is not a QIO device") end

        local r, e = pcall(qio.setFrequency, depoChannel)

        if not r then error("Failed to set qio channel: " .. e) end

        qio.setImportsWithoutFilter(true)
    end)
end

function refuel()
    return pcall(function()
        -- assume were going to have an open slot in front of us.
        local slot = inv.findExpectedSlot(4, "quant")

        turtle.select(slot)
        turtle.place()

        -- now we have to configure the QE
        local QE = peripheral.wrap("front")

        mekUtils.setItemOutput(QE)
        QE.setEjecting(6, false)
        local r, e = pcall(QE.setFrequency, fuelChannel)
        if not r then error("Failed to set QE channel for fuel: " .. e) end

        turtle.select(16)
        turtle.suck()
        turtle.refuel()

        turtle.dig()

        turtle.transferTo(4)   
    end)
end

function deployDigitalMiner()
    return pcall(function() 
        local slot = inv.findExpectedSlot(1, "digital_miner")

        turtle.select(slot)
        turtle.placeUp()

        local miner = peripheral.wrap("top")
        if not miner then error("Failed to get miner peripheral") end

        if not mekUtils.compareFilters(options.filters, miner) then 
            mekUtils.clearFilters(miner)
            mekUtils.setFilters(miner, options.filters)
        end

        if miner.getSilkTouch() ~= options.silkTouch then 
            miner.setSilkTouch(options.silkTouch)
        end

        if options.radius ~= miner.getRadius() then 
            miner.setRadius(options.radius)
        end

        if options.minY ~= miner.getMinY() then
            miner.setMinY(options.minY)
        end

        if options.maxY ~= miner.getMaxY() then 
            miner.setMaxY(options.maxY)
        end

        miner.start()
    end)
end

function deployPower()
    return pcall(function()
        local slot = inv.findExpectedSlot(3, "quant")
    
        turtle.select(slot)
        turtle.placeUp()
    
        local QE = peripheral.wrap("top")
        mekUtils.setPowerOutput(QE)
    
        QE.setEjecting(0, true)
        local r, e = pcall(QE.setFrequency, powerChannel)
        if not r then error("Failed to set QE channel for power: " .. e) end
    end)
end

function deployAll()
    return pcall(function()

        turtle.back()
        turtle.up()
        turtle.turnRight()
        turtle.forward()
        -- first we place the QIO importer
        local r, e = deployQIO()
        if not r then print(e) end

        -- next go back 2 and down one
        turtle.back()
        turtle.back()
        turtle.down()
        
        -- Deploy the digital miner
        r, e = deployDigitalMiner()
        if not r then print(e) end

        -- next turn left and go over 2
        turtle.turnLeft()
        turtle.forward()
        turtle.forward()

        -- finally deploy the power
        r, e = deployPower()
        if not r then print(e) end

        -- Then we can check if we need a refuel
        if turtle.getFuelLevel() <= 100 then
            r, e = refuel()
            if not r then print(e) end
        end

        -- finally lets go back to below the miner
        turtle.back()
        turtle.back()
    end)
end

function waitForMiner()
    return pcall(function() 
        -- miner should be above us
        local miner = peripheral.wrap("top")

        if not miner then error("No miner found") end

        local toMine = 1000
        repeat
            toMine = miner.getToMine()
            -- Maybe dispatch to a server?
            os.sleep(0.5)
        until toMine == 0
    end)
end

function salvageAll()
    return pcall(function()
        turtle.select(1)
        turtle.digUp()
        turtle.up()
        turtle.turnRight()
        turtle.forward()
        turtle.forward()
        turtle.select(2)
        local x = peripheral.wrap("top")
        x.setImportsWithoutFilter(false)
        turtle.digUp()
        turtle.back()
        turtle.back()
        turtle.turnLeft()
        turtle.forward()
        turtle.select(3)
        turtle.dig()
    end)
end

function startLoop()
    while running do
        local r, e = deployAll()
        if not r then print(e) end

        r, e = waitForMiner()
        if not r then print(e) end

        r, e = salvageAll()
        if not r then print(e) end

        if options.radius * 2 + 100 > turtle.getFuelLevel() then 
            r, e = refuel()
            if not r then print(e) end
        end

        for i = 1, options.radius * 2 do 
            turtle.forward()
        end
    end
end

options = utils.loadOptions(optionsFile)

function main()
    -- load and check the state
    local s, state = pcall(utils.loadState)

    if not s then error(state) end

    if inv.itemAtSlot(1, "digital_miner") and inv.itemAtSlot(2, "qio") and inv.itemAtSlot(3, "quant") and inv.itemAtSlot(4, "quant") then
        -- start
        startLoop()
    else
        -- we have to go around and find the blocks. 
    end
        
end

parallel.waitForAny(inv.bind, main)