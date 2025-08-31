local pickUp = {}

function pickUp:init()
    turtle.turnLeft()
    turtle.turnLeft()

    local test = peripheral.find("inventory")
    if not test then return end

    for slot, item in pairs(test.list()) do
        print(("%d x %s in slot %d"):format(item.count, item.name, slot))
        turtle.suck()
    end

    turtle.turnLeft()
    turtle.turnLeft()
end

pickUp:init()
