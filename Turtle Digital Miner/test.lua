m = peripheral.find("modem")

m.open(1200)

while true do
    local event, side, channel, replyChannel, message, distance = os.pullEvent("modem_message")
    m.transmit(replyChannel, channel, "Pong! " .. tonumber(distance))
end    
