---@class refuelHelper
local refuelHelper = {}

---@enum refuelHelper.status
refuelHelper.status = {
    idle = 0,
    refueling = 1,
    outOfFuel = 2
}

---@type refuelHelper.status
refuelHelper.currentStatus = refuelHelper.status.idle

---@type table<string, boolean>
refuelHelper.coalList = {
    ["minecraft:coal"] = true,
    ["minecraft:coal_block"] = true,
    ["minecraft:charcoal"] = true,
    ["minecraft:charcoal_block"] = true,
    ["aether:ambrosium_shard"] = true,
    ["aether:ambrosium_block"] = true
}

---@return nil
function refuelHelper:tryRefuel()
    local fuelLevel = turtle.getFuelLevel()
    logHelper.fuelLevel(fuelLevel)
    if fuelLevel == "unlimited" or (fuelLevel > 100 and self.currentStatus == self.status.idle) then return end

    if self.currentStatus == self.status.idle then
        self.currentStatus = refuelHelper.status.refueling
    end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)

        if item and self.coalList[item.name] then
            turtle.select(slot)
            while turtle.getItemCount(slot) > 0 do
                local fuelLevel = turtle.getFuelLevel()
                turtle.refuel(1)
                logHelper.fuelMassage(string.format("Refueled with %s. Current fuel level: %s", item.name, fuelLevel))

                if fuelLevel > 1000 then
                    self.currentStatus = refuelHelper.status.idle
                    return
                end
                sleep(0)
            end
        end
    end

    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel > 100 then
        self.currentStatus = refuelHelper.status.idle
        return
    end

    logHelper.fuelError("Out of fuel! Please add coal to the turtle.")
    self.currentStatus = refuelHelper.status.outOfFuel
    while true do
        sleep(10)
        self:tryRefuel()
    end
end

return refuelHelper
