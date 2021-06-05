Exports = {}

local utils = nil
local monitor = nil
local screenWidth = 0
local screenHeight = 0
local callbacks = {
    -- callback for toggle button
    -- function(id, value)
}

Exports.init = function(m, cb, u)
    monitor = m
    monitor.setTextScale(0.5)
    monitor.setBackgroundColor(colors.black)
    screenWidth, screenHeight = monitor.getSize()
    callbacks = cb
    utils = u
end

Exports.render = function(data) 
    local oldTerm = term.redirect(monitor)

    monitor.setBackgroundColor(colors.black)
    term.clear()
    
    drawOutline()
    

    -- battery status
    utils.writeCenterText(monitor, 1, "Induction Matrix", 1, 5, screenWidth / 3, colors.white, colors.black)

    utils.drawVerticalProgressBar(monitor, 5, 12, 20, screenHeight - 13, data.matrix.energyPercent, colors.green, colors.lightGray)

    utils.writeNormalText(monitor, utils.formatEnergy(data.matrix.energy) .. "J / " .. utils.formatEnergy(data.matrix.maxEnergy) .. "J", 5, 11, colors.white, colors.black)

    utils.drawVerticalProgressBar(monitor, 28, 12, 3, screenHeight - 13, data.matrix.energyIn / data.matrix.energyTransferCap, colors.green, colors.lightGray)
    utils.drawVerticalProgressBar(monitor, 33, 12, 3, screenHeight - 13, data.matrix.energyIn / data.matrix.energyTransferCap, colors.green, colors.lightGray)

    utils.writeNormalText(monitor, "Max transfer: " .. utils.formatEnergy(data.matrix.energyTransferCap), 28,11, colors.white, colors.black)
    utils.writeNormalText(monitor, "In: " .. utils.formatEnergy(data.matrix.energyIn), 39,13, colors.white, colors.black)
    utils.writeNormalText(monitor, "Out: " .. utils.formatEnergy(data.matrix.energyOut), 39,14, colors.white, colors.black)

    -- draw tanks

    local tankArea = (screenWidth / 3) * 2 - 2
    local tankXStart = (screenWidth / 3)

    local tankWidth = tankArea / table.getn(data.tanks) - 2

    for i, v in pairs(data.tanks) do
        local color = colors.green

        if v.name == "minecraft:water" then
            color = colors.blue
        elseif v.name == "mekanism:sodium" then
            color = colors.white
        end

        local fullName = utils.getCoolantName(v.name)

        utils.writeNormalCenterText(monitor, fullName .. ": " .. utils.formatEnergy(v.amount) .. "B / " .. utils.formatEnergy(v.capacity) .. "B",  math.ceil(tankXStart + (2 * i) + (tankWidth * (i - 1))),  math.ceil((screenHeight / 3) * 2 + 1), math.ceil(tankWidth - 2))

        utils.drawVerticalProgressBar(monitor, 
            math.ceil(tankXStart + (2 * i) + (tankWidth * (i - 1))), -- X
            math.ceil((screenHeight / 3) * 2 + 2),  -- Y
            math.ceil(tankWidth - 2),               -- width
            math.ceil((screenHeight / 3) - 4),  -- height
            v.filledPercent, 
            color, colors.lightGray
        )
    end

    -- boiler
    utils.writeCenterText(monitor, 1, "Boiler", math.ceil(tankXStart), 5, 47, colors.white, colors.black)

    utils.drawVerticalProgressBar(monitor, 
        math.ceil(tankXStart) + 2,
        12,
        4,
        math.ceil((screenHeight / 3)) + 3,
        data.boiler.waterPercent,
        colors.blue,
        colors.lightGray
    )

    utils.drawVerticalProgressBar(monitor, 
        math.ceil(tankXStart) + 8,
        12,
        4,
        math.ceil((screenHeight / 3)) + 3,
        data.boiler.heatedCoolantPercent,
        colors.orange,
        colors.lightGray
    )

    utils.drawVerticalProgressBar(monitor, 
        math.ceil(tankXStart) + 36,
        12,
        4,
        math.ceil((screenHeight / 3)) + 3,
        data.boiler.steamPercent,
        colors.white,
        colors.lightGray
    )

    utils.drawVerticalProgressBar(monitor, 
        math.ceil(tankXStart) + 42,
        12,
        4,
        math.ceil((screenHeight / 3)) + 3,
        data.boiler.cooledCoolantPercent,
        colors.gray,
        colors.lightGray
    )

    utils.writeNormalCenterText(monitor, "Water", math.ceil(tankXStart) + 14, 13, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, utils.formatEnergy(data.boiler.waterAmount) .. "B / " .. utils.formatEnergy(data.boiler.waterCapacity) .. "B",  math.ceil(tankXStart) + 14, 14, 20)

    utils.writeNormalCenterText(monitor, "Heated coolant", math.ceil(tankXStart) + 14, 16, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, utils.formatEnergy(data.boiler.heatedCoolant) .. "B / " .. utils.formatEnergy(data.boiler.heatedCoolantCapacity) .. "B",  math.ceil(tankXStart) + 14, 17, 20)

    utils.writeNormalCenterText(monitor, "Steam", math.ceil(tankXStart) + 14, 19, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, utils.formatEnergy(data.boiler.steamAmount) .. "B / " .. utils.formatEnergy(data.boiler.steamCapacity) .. "B",  math.ceil(tankXStart) + 14, 20, 20)

    utils.writeNormalCenterText(monitor, "Coolant", math.ceil(tankXStart) + 14, 22, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, utils.formatEnergy(data.boiler.cooledCoolant) .. "B / " .. utils.formatEnergy(data.boiler.cooledCoolantCapacity) .. "B",  math.ceil(tankXStart) + 14, 23, 20)

    utils.writeNormalCenterText(monitor, "Tempature", math.ceil(tankXStart) + 14, 25, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, data.boiler.tempature .. "K",  math.ceil(tankXStart) + 14, 26, 20)

    utils.writeNormalCenterText(monitor, "Boil rate", math.ceil(tankXStart) + 14, 28, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, utils.formatEnergy(data.boiler.boilRate) .. "B/t",  math.ceil(tankXStart) + 14, 29, 20)

    utils.writeNormalCenterText(monitor, "Boil capacity", math.ceil(tankXStart) + 14, 31, 20, colors.white, colors.black)
    utils.writeNormalCenterText(monitor, utils.formatEnergy(data.boiler.boilCapacity) .. "B/t",  math.ceil(tankXStart) + 14, 32, 20)
    
    -- turbine

    

    monitor.setBackgroundColor(colors.black)
    term.redirect(oldTerm)
end

function drawOutline()
    -- outline
    utils.drawBorder(monitor, 2, 2, screenWidth - 3, screenHeight - 2, colors.black, colors.lightGray)
    
    for i = 3, screenHeight - 1 do
        utils.drawSubpixelChar(monitor, utils.getDrawingCharacter(
        true, false,
        true, false,
        true, false
        ), screenWidth / 3, i, colors.lightGray, colors.black)
    end

    utils.drawSubpixelChar(monitor, utils.getDrawingCharacter(
        true, false,
        true, true,
        false, false
    ), screenWidth / 3, screenHeight, colors.lightGray, colors.black)

    utils.drawSubpixelChar(monitor, utils.getDrawingCharacter(
        false, false,
        true, true,
        true, false
    ), screenWidth / 3, 2, colors.lightGray, colors.black)

    utils.drawSubpixelChar(monitor, utils.getDrawingCharacter(
        false, false,
        true, true,
        false, false
    ), screenWidth / 3 + 1, (screenHeight / 3) * 2, colors.lightGray, colors.black, (screenWidth / 3) * 2 - 1)

    utils.drawSubpixelChar(monitor, utils.getDrawingCharacter(
        true, false,
        true, true,
        true, false
    ), screenWidth / 3, (screenHeight / 3) * 2, colors.lightGray, colors.black)

    utils.drawSubpixelChar(monitor, utils.getDrawingCharacter(
        false, true,
        true, true,
        false, true
    ), screenWidth / 3 + (screenWidth / 3) * 2 - 1, (screenHeight / 3) * 2, colors.lightGray, colors.black)
end

return Exports