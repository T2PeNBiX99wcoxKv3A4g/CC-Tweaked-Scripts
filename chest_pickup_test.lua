local pickUp = {}

function pickUp:init()
    local test = peripheral.find("inventory")
    if not test then return end

    local items = test.list()

    turtle.turnLeft()
    turtle.turnLeft()

    for slot, item in pairs(items) do
        print(("%d x %s in slot %d"):format(item.count, item.name, slot))
        turtle.suck()
    end

    turtle.turnLeft()
    turtle.turnLeft()
end

pickUp:init()
