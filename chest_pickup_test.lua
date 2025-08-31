local pickUp = {}

function pickUp:init()
    local test = peripheral.find("inventory")
    if not test then return end

    for slot, item in pairs(test.list()) do
        print(("%d x %s in slot %d"):format(item.count, item.name, slot))
    end
end

pickUp:init()
