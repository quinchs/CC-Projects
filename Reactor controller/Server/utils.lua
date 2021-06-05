local bigfont = require("bigfont")

exports = {}

local currentLiseners = {

}

local customChars = {
    upArrow = "f\152f\137f\144",
    downArrow = "t\155t\159f\132"
              .."f\128f\129f\128",
    bottomBar = "t\143",
    leftBar = "f\149",
    rightBar = "t\149",
}

function getDrawingCharacter(topLeft, topRight, left, right, bottomLeft, bottomRight)
    local data = 128
    if not bottomRight then
          data = data + (topLeft and 1 or 0)
          data = data + (topRight and 2 or 0)
          data = data + (left and 4 or 0)
          data = data + (right and 8 or 0)
          data = data + (bottomLeft and 16 or 0)
    else
          data = data + (topLeft and 0 or 1)
          data = data + (topRight and 0 or 2)
          data = data + (left and 0 or 4)
          data = data + (right and 0 or 8)
          data = data + (bottomLeft and 0 or 16)
    end
    return {char = string.char(data), inverted = bottomRight}
end

exports.drawCustomChar = function(monitor, char, x, y, fColor, bColor) 
    if fColor then monitor.setTextColor(fColor) else monitor.setTextColor(colors.white) end
    if bColor then monitor.setBackgroundColor(bColor) else monitor.setBackgroundColor(colors.black) end

    for i = 0, (#char / 6) - 1 do
        local text = char:sub((i*6) +1, (i+1) * 6)
        monitor.setCursorPos(x, y + i)

        for j = 0, 6, 2 do
            local charVal = text:sub(j + 1, 2 * (j+1))
            local inverted = charVal:sub(1,1) == "t"
            local value = charVal:sub(2,2)

            if inverted then 
                monitor.setTextColor(bColor) 
                monitor.setBackgroundColor(fColor)
            else 
                monitor.setTextColor(fColor) 
                monitor.setBackgroundColor(bColor)
            end
            monitor.write(value)
        end
    end
end

exports.drawSpecialCharVertically = function(monitor, char, x, y, height, fColor, bColor)
    local inverted = char:sub(1,1) == "t"
    local value = char:sub(2,2)

    if inverted then 
        monitor.setTextColor(bColor) 
        monitor.setBackgroundColor(fColor)
    else 
        monitor.setTextColor(fColor) 
        monitor.setBackgroundColor(bColor)
    end

    for i = 0, height - 1 do
        monitor.setCursorPos(x, y + i)
        monitor.write(value)
    end
end

exports.drawSpecialCharHorizontally = function(monitor, char, x, y, width, fColor, bColor)
    monitor.setCursorPos(x, y)
    local inverted = char:sub(1,1) == "t"
    local value = char:sub(2,2)

    if inverted then 
        monitor.setTextColor(bColor) 
        monitor.setBackgroundColor(fColor)
    else 
        monitor.setTextColor(fColor) 
        monitor.setBackgroundColor(bColor)
    end

    local text = value
    for i = 1, width do 
        text = text .. value
    end

    monitor.write(text)
end

local function addListener(func, x1, y1, x2, y2)
    table.insert(currentLiseners, {
        x1 = x1,
        x2 = x2,
        y1 = y1,
        y2 = y2,
        func = func,
    })
end

local function getListener(x, y) 
    for _, v in ipairs(currentLiseners) do
        if v.x1 <= x and v.x2 >= x and v.y1 <= y and v.y2 >= y then return v end
    end
end

exports.writeText = function(monitor, size, text, x, y, fColor, bColor)
    if fColor then monitor.setTextColor(fColor) else monitor.setTextColor(colors.white) end
    if bColor then monitor.setBackgroundColor(bColor) else monitor.setBackgroundColor(colors.black) end

    bigfont.writeOn(monitor, size, text, x, y)
end

exports.writeCenterText = function(monitor, size, text, x, y, width, fColor, bColor)
    if fColor then monitor.setTextColor(fColor) else monitor.setTextColor(colors.white) end
    if bColor then monitor.setBackgroundColor(bColor) else monitor.setBackgroundColor(colors.black) end

    local charWidth = size * 3

    -- determine the center width of the `text` value
    local textWidth = #text * charWidth

    -- next, get the center point of our area and minus the text width from it
    local textX = ( width / 2) - (textWidth / 2)

    -- finally, draw our text
    exports.writeText(monitor, size, text, x + textX, y, fColor, bColor)

end

exports.drawHorizontalProgressBar = function(monitor, x, y, width, height, progress, fColor, bColor)
    -- first lets draw the background,
    paintutils.drawFilledBox(x, y, x + width, y + height - 1, bColor)

    -- next we determine the relative width of the percentage
    local rWidth = width * progress

    if progress >= 1 then rWidth = width end

    if progress ~= 0 then 
        -- we can fill that section in with the floor value of rWidth
        paintutils.drawFilledBox(x, y, x + math.floor(rWidth), y + height - 1, fColor)

        -- finnaly lets see if were above k.5 
        if math.floor(rWidth) ~= math.floor(rWidth + 0.5) then
            -- Add a "half pixel"
            exports.drawSpecialCharVertically(monitor, customChars.leftBar, x + math.floor(rWidth) + 1, y, height, fColor, bColor)
        end
    end
end

exports.makeButton = function(monitor, x, y, width, height, text, fColor, bColor, onClick)
    if height < 2 then height = 2 end
    if width < #text + 2 then width = #text + 2 end
    
    -- draw the rect box
    paintutils.drawFilledBox(x, y, x + width, y + height, bColor)
    exports.drawSpecialCharHorizontally(monitor, customChars.bottomBar, x, y - 1, width, bColor, colors.black)

    -- draw the text
    exports.writeCenterText(monitor, 1, text, x, y, width + 1, fColor, bColor)

    -- add the listener
    addListener(
        function(lX, lY, instance)
            print(onClick)
            if onClick then onClick() end
        end,
        x,
        y,
        x + width, 
        y + height
    )

end

exports.writeRightText = function(monitor, x, y, text, fColor, bColor)
    exports.writeNormalText(monitor, text, x - #text, y, fColor, bColor)
end

exports.writeNormalText = function(monitor,text, x, y, fColor, bColor)
    if fColor then monitor.setTextColor(fColor) else monitor.setTextColor(colors.white) end
    if bColor then monitor.setBackgroundColor(bColor) else monitor.setBackgroundColor(colors.black) end

    monitor.setCursorPos(x, y)
    monitor.write(text)
end

exports.makeCircle = function(monitor, centerX, centerY, radius, thickness, fColor, bColor)
    if fColor then monitor.setTextColor(fColor) else monitor.setTextColor(colors.white) end
    if bColor then monitor.setBackgroundColor(bColor) else monitor.setBackgroundColor(colors.black) end
    
    local r = radius or 10
    r = r * 2
    local t = thickness or 1

    for i = 1, 360 do 
        local dChar = ""
        local x, y = centerX + r/2 * math.cos(i), centerY - r/3 * math.sin(i)

        local xD, yD = x%1*10, y%1*10
        
        --if xD < 5
        
        paintutils.drawPixel(x, y, fColor)

        --print(x, y)
    end
end

exports.makeNumberSelector = function(monitor, size, x, y, fColor, bColor, value, onUp, onDown, rightAligned) 
    if not fColor then fColor = colors.white end
    if not bColor then bColor = colors.green end

    local isRightAligned = rightAligned or false

    -- Check if were going to be writing text outside our rect bounds, if so lets sneakily extend it :D
    local calWidth = #value * (size * 3) + 3
    local calHeight = size * 3 

    -- if calWidth > eX - sX then eX = sX + calWidth end

    if isRightAligned then x = x - calWidth end
    
    -- draw the rect
    paintutils.drawFilledBox(x, y, x + calWidth, y + calHeight - 1, bColor)

    -- add a top border with the \143 char inverted, its basically 1/3 of a bottom of a pixel, looks good with bigfont
    exports.drawSpecialCharHorizontally(monitor, customChars.bottomBar, x, y - 1, calWidth, bColor, colors.black)
    
    -- Write the text
    exports.writeText(monitor, size, value, x + 4, y, fColor, bColor)

    -- draw the controls,
    exports.drawCustomChar(monitor, customChars.upArrow, x + 1, y, fColor, bColor)
    exports.drawCustomChar(monitor, customChars.downArrow, x + 1, y + calHeight - 2, fColor, bColor)

    -- Add the listeners
    addListener(
        function(lX, lY, instance)
            if lY == y then 
                if onUp then onUp() end 
            elseif onDown then 
                onDown() 
            end 
        end,
        x + 1,
        y,
        x + 4,
        y + calHeight - 1
    )
end



exports.handleClick = function(monitor, x, y) 
    local l = getListener(x, y)
    print(l)
    if l then l.func(x, y, l) end
end

return exports