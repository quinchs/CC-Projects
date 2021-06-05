Exports = {}

local utils = nil
local monitor = nil
local boxWidth = 0
local boxHeight = 0
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
    boxWidth, boxHeight = screenWidth/ 4,  screenHeight - 14
    callbacks = cb

    print(callbacks.toggleReactor)
    utils = u
end

Exports.render = function(data) 
    local oldTerm = term.redirect(monitor)

    term.clear()
    paintutils.drawBox(2, screenHeight - 12, screenWidth - 1, screenHeight - 1, colors.gray)

    for i = 0, 3 do 
        local boxXStart, boxYStart, boxXEnd, boxYEnd = 2 + (boxWidth * i), 2, boxWidth * (i + 1) - 1, boxHeight
        paintutils.drawBox(boxXStart, boxYStart, boxXEnd, boxYEnd , colors.gray)
    
        local reactorData = nil

        if data and data.reactors then reactorData = data.reactors[i+1] end
    
        utils.writeText(monitor, 1, "Reactor " .. tostring(i+1), boxXStart + 6, boxYStart + 2)
    
        if reactorData then

             -- draw the controls
            local buttonText = ""
            local buttonColor = colors.red
            if reactorData then 
                if reactorData.active then
                    buttonText = "SCRAM"
                    buttonColor = colors.red
                else 
                    buttonText = "Activate"
                    buttonColor = colors.green
                end
            else 
                buttonText = "INOP" 
            end
    
            utils.makeButton(monitor, boxXStart + 2, screenHeight - 10, boxWidth - 7, 2, buttonText, colors.white, buttonColor, function() 
                print(callbacks["toggleReactor"])
                if callbacks.toggleReactor then
                    print(not reactorData.active, reactorData.active)
                    callbacks.toggleReactor(reactorData.id, not reactorData.active)
                end
            end)
        
            local burnrateVal = "0"
            if reactorData then burnrateVal = tostring(reactorData.burnRate) end
            utils.writeText(monitor, 1, "Burn:", boxXStart + 2, screenHeight - 6)
            utils.makeNumberSelector(monitor, 1, boxXStart + 16, screenHeight - 6, colors.white, colors.black, burnrateVal, function() 
                if callbacks.changeBurnRate then callbacks.changeBurnRate(reactorData.id, true) end
            end , function() 
                if callbacks.changeBurnRate then callbacks.changeBurnRate(reactorData.id, false) end
            end)

            -- Status
            local status = ""
            local statusColor = nil
            if reactorData.active then status = "Active" statusColor = colors.green else status = "Disabled" statusColor = colors.red end
            utils.writeCenterText(monitor, 1, status, boxXStart, boxYStart + 6, boxWidth, statusColor)
    
            -- coolant

            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 11, boxWidth - 7, 1, reactorData.coolantPercent, colors.lightBlue, colors.lightGray)
            utils.writeNormalText(monitor, "Coolant (" .. reactorData.coolant.name .. ")", boxXStart + 2, boxYStart + 10)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 10, tostring(reactorData.coolant.amount) .. "/" .. tostring(reactorData.coolantCapacity))
    
            -- Heated coolant
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 14, boxWidth - 7, 1, reactorData.heatedCoolantPercent, colors.yellow, colors.lightGray)
            utils.writeNormalText(monitor, "Heated coolant", boxXStart + 2, boxYStart + 13)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 13, tostring(reactorData.heatedCoolant.amount) .. "/" .. tostring(reactorData.heatedCoolantCapacity))
    
            -- Fuel
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 17, boxWidth - 7, 1, reactorData.fuelPercent, colors.brown, colors.lightGray)
            utils.writeNormalText(monitor, "Fuel", boxXStart + 2, boxYStart + 16)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 16, tostring(reactorData.fuelAmount) .. " / " .. tostring(reactorData.fuelCapacity))
    
            -- Waste
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 20, boxWidth - 7, 1, reactorData.wastePercent, colors.orange, colors.lightGray)
            utils.writeNormalText(monitor, "Waste", boxXStart + 2, boxYStart + 19)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 19, tostring(reactorData.wasteAmount) .. " / " .. tostring(reactorData.wasteCapacity))
    
            -- Burn rate
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 23, boxWidth - 7, 1, reactorData.actualBurnRate / reactorData.maxBurnRate, colors.red, colors.lightGray)
            utils.writeNormalText(monitor, "Burn rate", boxXStart + 2, boxYStart + 22)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 22, tostring(reactorData.actualBurnRate) .. " / " .. tostring(reactorData.maxBurnRate))
    
            -- tempature
            local greenBarPer = reactorData.tempature / 600
            local yellowBarPer = reactorData.tempature / 1000
            local orangeBarPer = reactorData.tempature / 1200
            local redBarPer = reactorData.tempature / 1300
    
            if greenBarPer > 1 then greenBarPer = 1 end
            if yellowBarPer > 1 then yellowBarPer = 1 end
            if orangeBarPer > 1 then orangeBarPer = 1 end
            if redBarPer > 1 then redBarPer = 1 end
    
            if reactorData.tempature < 600 then yellowBarPer = 0 end
            if reactorData.tempature < 1000 then orangeBarPer = 0 end
            if reactorData.tempature < 1200 then redBarPer = 0 end
    
            local greenWidth  = ((boxWidth - 7) / 2) - 2 
            local yellowWidth = ((boxWidth - 7) / 3) 
            local orangeWidth = ((boxWidth - 7) / 6) 
            local redWidth    = 2  
    
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 26, greenWidth, 1, greenBarPer, colors.green, colors.lightGray)
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2 + greenWidth, boxYStart + 26, yellowWidth, 1, yellowBarPer, colors.yellow, colors.lightGray)
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2 + greenWidth + yellowWidth, boxYStart + 26, orangeWidth, 1, orangeBarPer, colors.orange, colors.lightGray)
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2 + greenWidth + yellowWidth + orangeWidth, boxYStart + 26, redWidth, 1, redBarPer, colors.red, colors.lightGray)
    
            utils.writeNormalText(monitor, "Tempature", boxXStart + 2, boxYStart + 25)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 25, tostring(math.floor(reactorData.tempature)) .. "k / 1200k")
    
            -- Damage
            utils.drawHorizontalProgressBar(monitor, boxXStart + 2, boxYStart + 29, boxWidth - 7, 1, reactorData.damagePercent / 100, colors.red, colors.lightGray)
            utils.writeNormalText(monitor, "Damage", boxXStart + 2, boxYStart + 28)
            utils.writeRightText(monitor, boxXEnd - 1, boxYStart + 28, tostring(reactorData.damagePercent) .. " / 100")
    
        else 
            utils.writeCenterText(monitor, 1, "INOP", boxXStart, boxYStart + 6, boxWidth, colors.red)
        end
    end

    -- restore the terminal
    term.redirect(oldTerm)
end

return Exports