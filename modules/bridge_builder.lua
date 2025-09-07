local class = require("modules.class")
local vec3 = require("modules.vector3")
local angle = require("modules.angle")
local moveHelper = require("modules.move_helper")
local fileHelper = require("modules.file_helper")
local refuelHelper = require("modules.refuel_helper")
local logHelper = require("modules.log_helper")
local utils = require("modules.utils")

---@class bridgeBuilder
local bridgeBuilder = class("bridgeBuilder")

---@enum bridgeBuilder.status
bridgeBuilder.status = {
    idle = 0,
    building = 1,
    tempBacking = 2,
    backingFinished = 3,
    backingUnfinished = 4,
    finished = 5,
    unfinished = 6
}

---@type table<string, boolean>
bridgeBuilder.skipBlocks = {
    ["minecraft:grass"] = true,
    ["minecraft:fire"] = true
}

---@type vec3
bridgeBuilder.initPos = vec3(0, 0, 0)
---@type angle
bridgeBuilder.initAngle = angle.north()
---@type vec3 | nil
bridgeBuilder.progressPosition = nil
---@type bridgeBuilder.status
bridgeBuilder.currentStatus = bridgeBuilder.status.idle
---@type fileHelper
bridgeBuilder.saveHelper = fileHelper(fileHelper.type.save, "bridge_builder_save.json")
---@type refuelHelper
bridgeBuilder.refuelHelper = refuelHelper()
---@type moveHelper
bridgeBuilder.moveHelper = moveHelper(bridgeBuilder)

function bridgeBuilder:move()
    self.moveHelper:forward()

    local position = self.moveHelper.position
    logHelper.progress(string.format("Position: {x: %d, y: %d, z: %d}", position.x, position.y, position.z))

    self.progressPosition = position:copy()
    self:save()
end

function bridgeBuilder:backToStartPos()
    self.moveHelper:moveTo(self.initPos)
end

function bridgeBuilder:turnToStartDirection()
    self.moveHelper:turnTo(self.initAngle)
end

function bridgeBuilder:backToProgressPosition()
    self.moveHelper:moveTo(self.progressPosition or self.initPos)
end

function bridgeBuilder:dropItemToChest()
    self.moveHelper:turnTo(angle.south())

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and not self.refuelHelper:isFuelItem(item.name) then
            turtle.select(i)
            turtle.drop(item.count)
        end
    end

    turtle.select(1)
end

---@return boolean
function bridgeBuilder:searchBlockInsideChest()
    local inventory = peripheral.find("inventory")
    if not inventory then return false end
    local blockCount = 0

    for slot, item in pairs(inventory.list()) do
        if self:checkInventoryIsFull() then
            return blockCount > 0
        end
        turtle.suck()
        if not self.refuelHelper:isFuelItem(item.name) then
            blockCount = blockCount + 1
        end
    end
    return blockCount > 0
end

---@return boolean
function bridgeBuilder:checkInventoryIsFull()
    local isFull = true

    for i = 1, 16 do
        if turtle.getItemCount(i) < 1 then
            isFull = false
            break
        end
    end

    return isFull
end

---@return boolean
function bridgeBuilder:checkInventory()
    local hasBlock = false

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and not self.refuelHelper:isFuelItem(item.name) then
            if item.count > 0 then
                hasBlock = true
                break
            end
        end
    end

    if hasBlock then return true end
    logHelper.warning("Need more block to build, Temporarily returning to start position to pickup blocks...")
    self.currentStatus = self.status.tempBacking
    return false
end

function bridgeBuilder:placeBlock()
    if turtle.detectDown() then return end

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)

        if item and not self.refuelHelper:isFuelItem(item.name) then
            if item.count > 0 then
                turtle.select(i)
                local success, errorMessage = turtle.placeDown()
                if success then return end
                logHelper.error(errorMessage or "Can't place a block!")
            end
        end
    end

    logHelper.error("All items can't be use as block!")
    self.currentStatus = self.status.backingUnfinished
end

---@type table<bridgeBuilder.status, fun(self: bridgeBuilder)>
bridgeBuilder.statusTick = {
    [bridgeBuilder.status.building] = function(self)
        if not self:checkInventory() then return end
        local hasBlock, blockData = turtle.inspect()

        if turtle.detect() and hasBlock and blockData and not self.skipBlocks[blockData.name] then
            self.currentStatus = self.status.backingFinished
            logHelper.massage("Mining complete! Returning to start position...")
            return
        end

        self:move()
        self:placeBlock()
    end,
    [bridgeBuilder.status.tempBacking] = function(self)
        self:backToStartPos()
        self.moveHelper:turnTo(angle.south())
        if self:searchBlockInsideChest() then
            self:turnToStartDirection()
            self:backToProgressPosition()
            self.currentStatus = self.status.building
            logHelper.massage("Pick blocks from chest. Resuming building...")
        else
            self:dropItemToChest()
            self:turnToStartDirection()
            self.currentStatus = self.status.unfinished
            self:deleteSave()
            logHelper.error("Can't find any block can be use to build!")
        end
    end,
    [bridgeBuilder.status.backingFinished] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self:turnToStartDirection()
        self.currentStatus = self.status.finished
        self:deleteSave()
        logHelper.massage("Returned to start position. building operation finished.")
    end,
    [bridgeBuilder.status.backingUnfinished] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self:turnToStartDirection()
        self.currentStatus = self.status.unfinished
        self:deleteSave()
        logHelper.error(
            "Returned to start position. Mining operation unfinished due to lack of fuel or no block can be use.")
    end
}

function bridgeBuilder:tick()
    if self.refuelHelper.currentStatus == refuelHelper.status.outOfFuel then
        self.currentStatus = self.status.backingUnfinished
        logHelper.error("Out of fuel! Returning to start position...")
    end

    if self.statusTick[self.currentStatus] then
        self.statusTick[self.currentStatus](self)
    end
end

---@class bridgeBuilder.save
---@field initPos vec3Table
---@field initAngle angleTable
---@field progressPosition vec3Table|nil
---@field position vec3Table
---@field angle angleTable
---@field currentStatus bridgeBuilder.status

---@return boolean
function bridgeBuilder:save()
    ---@type bridgeBuilder.save
    local data = {
        initPos = self.initPos:copy() --[[@as vec3Table]],
        initAngle = self.initAngle --[[@as angleTable]],
        progressPosition = self.progressPosition and self.progressPosition:copy() or nil --[[@as vec3Table|nil]],
        position = self.moveHelper.position:copy() --[[@as vec3Table]],
        angle = self.moveHelper.angle:copy() --[[@as angleTable]],
        currentStatus = self.currentStatus
    }
    return self.saveHelper:save(data)
end

local dataCheck = {
    "initPos",
    "initAngle",
    "position",
    "angle",
    "currentStatus"
}

---@return boolean
function bridgeBuilder:load()
    local data = self.saveHelper:load()
    if not data then
        self:deleteSave()
        return false
    end
    if not utils.tableKeyCheck(data, dataCheck) then
        self:deleteSave()
        return false
    end

    local validData = data --[[@as bridgeBuilder.save]]

    self.initPos = vec3.fromTable(validData.initPos) or vec3.zero()
    self.initAngle = angle(validData.initAngle) --[[@as angle]]
    self.progressPosition = validData.progressPosition and vec3.fromTable(validData.progressPosition) or
        nil
    self.moveHelper.position = vec3.fromTable(validData.position) or vec3.zero()
    self.moveHelper.angle = angle.fromTable(validData.angle) or angle.north()
    self.currentStatus = validData.currentStatus

    return true
end

---@return boolean
function bridgeBuilder:deleteSave()
    return self.saveHelper:delete()
end

---@param newAngle angle
function bridgeBuilder:onDirectionChanged(newAngle)
    self:save()
end

---@param newPosition vec3
function bridgeBuilder:onPositionChanged(newPosition)
    self:save()
end

function bridgeBuilder:init()
    hook.add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook.add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming building operation...")
    else
        self.initPos = self.moveHelper.position:copy()
        self.initAngle = self.moveHelper.angle:copy()

        term.clear()
        term.setCursorPos(1, 1)

        self.currentStatus = self.status.building
        self:save()

        logHelper.massage("Starting new building operation...")
    end

    logHelper.title("Bridge Builder is running...")

    while true do
        if self.currentStatus == self.status.finished or self.currentStatus == self.status.unfinished then break end
        self:tick()
        sleep(0)
    end
end

return bridgeBuilder
