---@class bridgeBuilder
local bridgeBuilder = {}

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

---@type vec3
bridgeBuilder.initPos = vec3(0, 0, 0)
---@type moveHelper.directions
bridgeBuilder.initDirection = moveHelper.directions.north
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

---@return nil
function bridgeBuilder:move()
    self.moveHelper:forward()

    local position = self.moveHelper.position
    logHelper.progress(string.format("Position: {x: %d, y: %d, z: %d}", position.x, position.y, position.z))

    self.progressPosition = position:copy()
    self:save()
end

---@return nil
function bridgeBuilder:backToStartPos()
    self.moveHelper:moveTo(self.initPos)
end

---@return nil
function bridgeBuilder:turnToStartDirection()
    self.moveHelper:turnTo(self.initDirection)
end

---@return nil
function bridgeBuilder:backToProgressPosition()
    self.moveHelper:moveTo(self.progressPosition)
end

---@return nil
function bridgeBuilder:dropItemToChest()
    self.moveHelper:turnTo(moveHelper.directions.south)

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

    local inventoryName = peripheral.getName(inventory)
    local blockCount = 0

    for slot, item in pairs(inventory.list()) do
        if self:checkInventoryHaveSpace() then
            return blockCount > 0
        end
        if not self.refuelHelper:isFuelItem(item.name) then
            inventory.pullItems(inventoryName, slot)
            blockCount = blockCount + 1
        end
    end
    return blockCount > 0
end

---@return boolean
function bridgeBuilder:checkInventoryHaveSpace()
    local hasSpace = false

    for i = 1, 16 do
        if turtle.getItemCount(i) < 1 then
            hasSpace = true
            break
        end
    end

    return hasSpace
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

---@return nil
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
        if turtle.detect() then
            self:placeBlock()
            self.currentStatus = self.status.backingFinished
            logHelper.massage("Mining complete! Returning to start position...")
            return
        end

        self:move()
        self:placeBlock()
    end,
    [bridgeBuilder.status.tempBacking] = function(self)
        self:backToStartPos()
        local ret = self:searchBlockInsideChest()
        if ret then
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

---@return boolean
function bridgeBuilder:save()
    local data = {
        initPos = self.initPos:copy(),
        initDirection = self.initDirection,
        progressPosition = self.progressPosition and self.progressPosition:copy() or nil,
        position = self.moveHelper.position:copy(),
        direction = self.moveHelper.direction,
        currentStatus = self.currentStatus
    }
    return self.saveHelper:save(data)
end

---@return boolean
function bridgeBuilder:load()
    local data = self.saveHelper:load()
    if not data then
        self:deleteSave()
        return false
    end
    if not data.initPos or not data.initDirection or not data.position or not data.direction or not data.currentStatus then
        self:deleteSave()
        return false
    end

    self.initPos = vec3:fromTable(data.initPos) or vec3:zero()
    self.initDirection = data.initDirection
    self.progressPosition = data.progressPosition and vec3:fromTable(data.progressPosition) or nil
    self.moveHelper.position = vec3:fromTable(data.position) or vec3:zero()
    self.moveHelper.direction = data.direction
    self.currentStatus = data.currentStatus

    return true
end

---@return boolean
function bridgeBuilder:deleteSave()
    return self.saveHelper:delete()
end

---@param newDirection moveHelper.directions
function bridgeBuilder:onDirectionChanged(newDirection)
    self:save()
end

---@param newPosition vec3
function bridgeBuilder:onPositionChanged(newPosition)
    self:save()
end

function bridgeBuilder:init()
    hook:add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook:add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming building operation...")
    else
        self.initPos = self.moveHelper.position:copy()
        self.initDirection = self.moveHelper.direction

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
