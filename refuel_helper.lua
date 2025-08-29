local RefuelHelper = {}

---@enum RefuelHelper.status
RefuelHelper.status = {
    idle = 0,
    refueling = 1,
    outOfFuel = 2
}

---@type RefuelHelper.status
RefuelHelper.currentStatus = RefuelHelper.status.idle

---@type table<string, boolean>
RefuelHelper.coalList = {
    ["minecraft:coal"] = true,
    ["minecraft:coal_block"] = true,
    ["minecraft:charcoal"] = true,
    ["minecraft:charcoal_block"] = true,
    ["aether:ambrosium_shard"] = true,
    ["aether:ambrosium_block"] = true
}

---@return nil
function RefuelHelper:tryRefuel()
    local fuelLevel = turtle.getFuelLevel()
    print(string.format("Current  fuel level: %s", fuelLevel))
    if fuelLevel == "unlimited" or (fuelLevel > 100 and self.currentStatus == self.status.idle) then return end

    if self.currentStatus == self.status.idle then
        self.currentStatus = RefuelHelper.status.refueling
    end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)

        if item and self.coalList[item.name] then
            turtle.select(slot)
            while turtle.getItemCount(slot) > 0 do
                local fuelLevel = turtle.getFuelLevel()
                turtle.refuel(1)
                print(string.format("Refueled with %s. Current fuel level: %s", item.name, fuelLevel))

                if fuelLevel > 1000 then
                    self.currentStatus = RefuelHelper.status.idle
                    return
                end
                sleep(0)
            end
        end
    end

    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel > 100 then
        self.currentStatus = RefuelHelper.status.idle
        return
    end

    print("Out of fuel! Please add coal to the turtle.")
    self.currentStatus = RefuelHelper.status.outOfFuel
    while true do
        sleep(10)
        self:tryRefuel()
    end
end

return RefuelHelper
