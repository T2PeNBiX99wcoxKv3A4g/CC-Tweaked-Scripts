local expect = require("cc.expect").expect

local class = require("modules.class")
local logHelper = require("modules.log_helper")

---@class refuelHelper
local refuelHelper = class("refuelHelper")

---@enum refuelHelper.status
refuelHelper.status = {
    idle = 0,
    refueling = 1,
    outOfFuel = 2
}

---@type table<string, boolean>
refuelHelper.fuelList = {
    ["minecraft:coal"] = true,
    ["minecraft:coal_block"] = true,
    ["minecraft:charcoal"] = true,
    ["minecraft:charcoal_block"] = true,
    ["minecraft:lava_bucket"] = true,
    ["aether:ambrosium_shard"] = true,
    ["aether:ambrosium_block"] = true
}

---Will never be use and replace with instance table
---@type refuelHelper.status
refuelHelper.currentStatus = nil
---@type number
refuelHelper.lowFuelLevel = nil
---@type number
refuelHelper.maxRefuelLevel = nil

---@param itemName string
---@return boolean
function refuelHelper:isFuelItem(itemName)
    if refuelHelper.fuelList[itemName] then
        return true
    end
    return false
end

---@return nil
function refuelHelper:tryRefuel()
    local fuelLevel = turtle.getFuelLevel()
    logHelper.fuelLevel(fuelLevel)
    if fuelLevel == "unlimited" or (fuelLevel > self.lowFuelLevel and self.currentStatus == self.status.idle) then return end

    if self.currentStatus == self.status.idle then
        self.currentStatus = self.status.refueling
    end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)

        if item and self:isFuelItem(item.name) then
            turtle.select(slot)
            while turtle.getItemCount(slot) > 0 do
                local fuelLevel = turtle.getFuelLevel()
                turtle.refuel(1)
                logHelper.fuelMassage(string.format("Refueled with %s. Current fuel level: %s", item.name, fuelLevel))

                if fuelLevel > self.maxRefuelLevel then
                    self.currentStatus = self.status.idle
                    return
                end
                sleep(0)
            end
        end
    end

    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel > self.lowFuelLevel then
        self.currentStatus = self.status.idle
        return
    end

    logHelper.fuelError("Out of fuel! Please add coal to the turtle.")
    self.currentStatus = self.status.outOfFuel
end

---@param lowFuelLevel number
---@param maxRefuelLevel number
function refuelHelper:init(lowFuelLevel, maxRefuelLevel)
    expect(1, lowFuelLevel, "number")
    expect(2, maxRefuelLevel, "number")

    self.currentStatus = refuelHelper.status.idle
    self.lowFuelLevel = lowFuelLevel or 100
    self.maxRefuelLevel = maxRefuelLevel or 1000
end

return refuelHelper
