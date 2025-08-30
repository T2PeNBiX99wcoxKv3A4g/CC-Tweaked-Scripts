---@class mine
local mine = {}

---@diagnostic disable: lowercase-global
moveHelper = moveHelper or require("move_helper")
refuelHelper = refuelHelper or require("refuel_helper")
hook = hook or require("hook")
---@diagnostic enable: lowercase-global

local vec3 = require("vector3")
local logHelper = require("log_helper")
local saveHelper = require("save_helper")

---@enum mine.status
mine.status = {
    idle = 0,
    mining = 1,
    tempBacking = 2,
    backingFinished = 3,
    backingUnfinished = 4,
    finished = 5,
    unfinished = 6
}

---@type number
mine.size = 5
---@type number
mine.height = 11
---@type vec3
mine.initPos = vec3(0, 0, 0)
---@type moveHelper.directions
mine.initDirection = moveHelper.directions.north
---@type vec3[]
mine.steps = {}
---@type number
mine.currentStep = 1
---@type mine.status
mine.currentStatus = mine.status.idle
---@type string
mine.saveFileName = "mine_save.txt"

---@param size number
---@param y number
---@return vec3[]
function mine:mine2DAreaPath(size, y)
    local points = {}
    local sizeEnd = size - 1

    for x = 0, -sizeEnd, -1 do
        for z = 0, sizeEnd do
            table.insert(points, vec3(x, y, z))
        end
    end

    table.sort(points, function(a, b)
        if a.x == b.x then
            return a.z < b.z
        end
        return a.x > b.x
    end)

    return points
end

---@param size number
---@param height number
---@return vec3[]
function mine:mine3DAreaPath(size, height)
    local points = {}

    for y = -1, -height, -1 do
        local layerPoints = self:mine2DAreaPath(size, y)
        for _, v in ipairs(layerPoints) do
            table.insert(points, v)
        end
    end

    return points
end

---@return nil
function mine:move()
    local step = self.currentStep
    local movePos = self.steps[step]
    logHelper.progress(string.format("Step %d/%d: {x: %d, y: %d, z: %d}", step, #self.steps, movePos.x, movePos.y,
        movePos.z))
    moveHelper:moveTo(movePos)
    self.currentStep = self.currentStep + 1
    self:save()
end

---@return nil
function mine:backToStart()
    moveHelper:moveTo(self.initPos)
    moveHelper:turnTo(self.initDirection)
end

---@return nil
function mine:dropItemToChest()
    moveHelper:turnTo(moveHelper.directions.south)

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and not refuelHelper.coalList[item.name] then
            turtle.select(i)
            turtle.drop(item.count)
        end
    end

    turtle.select(1)
end

---@return nil
function mine:checkInventory()
    local itemSpace = 0

    for i = 1, 16 do
        itemSpace = itemSpace + turtle.getItemSpace(i)
    end

    if itemSpace > 128 then return end
    logHelper.warning(string.format(
        "Inventory space low: %d space left, Temporarily returning to start position to drop items...", itemSpace))
    self.currentStatus = self.status.tempBacking
end

---@type table<mine.status, fun(self: mine)>
mine.statusTick = {
    [mine.status.mining] = function(self)
        if self.currentStep > #self.steps then
            self.currentStatus = self.status.backingFinished
            logHelper.massage("Mining complete! Returning to start position...")
            return
        end
        self:move()
        self:checkInventory()
    end,
    [mine.status.tempBacking] = function(self)
        self:backToStart()
        self:dropItemToChest()
        self.currentStatus = self.status.mining
        logHelper.massage("Items dropped to chest. Resuming mining...")
    end,
    [mine.status.backingFinished] = function(self)
        self:backToStart()
        self:dropItemToChest()
        self:backToStart()
        self.currentStatus = self.status.finished
        self:deleteSave()
        logHelper.massage("Returned to start position. Mining operation finished.")
    end,
    [mine.status.backingUnfinished] = function(self)
        self:backToStart()
        self:dropItemToChest()
        self:backToStart()
        self.currentStatus = self.status.unfinished
        self:deleteSave()
        logHelper.error("Returned to start position. Mining operation unfinished due to lack of fuel.")
    end
}

function mine:tick()
    if refuelHelper.currentStatus == refuelHelper.status.outOfFuel then
        self.currentStatus = self.status.backingUnfinished
        logHelper.error("Out of fuel! Returning to start position...")
    end

    if self.statusTick[self.currentStatus] then
        self.statusTick[self.currentStatus](self)
    end
end

---@return boolean
function mine:save()
    local data = {
        size = self.size,
        height = self.height,
        initPos = self.initPos,
        initDirection = self.initDirection,
        position = moveHelper.position,
        direction = moveHelper.direction,
        steps = self.steps,
        currentStep = self.currentStep,
        currentStatus = self.currentStatus
    }
    return saveHelper.save(self.saveFileName, data)
end

---@return boolean
function mine:load()
    local data = saveHelper.load(self.saveFileName)
    if not data then
        self:deleteSave()
        return false
    end
    if not data.size or not data.height or not data.initPos or not data.initDirection or not data.position or not data.direction or not data.steps or not data.currentStep or not data.currentStatus then
        self:deleteSave()
        return false
    end

    self.size = data.size
    self.height = data.height
    self.initPos = data.initPos
    self.initDirection = data.initDirection
    self.steps = data.steps
    self.currentStep = data.currentStep
    self.currentStatus = data.currentStatus

    return true
end

---@return boolean
function mine:deleteSave()
    return saveHelper.delete(self.saveFileName)
end

---@param newDirection moveHelper.directions
function mine:onDirectionChanged(newDirection)
    self:save()
end

---@param newPosition vec3
function mine:onPositionChanged(newPosition)
    self:save()
end

function mine:init()
    hook:add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook:add("moveHelper.onPositionChanged", self, self.onPositionChanged)
    self.initPos = moveHelper.position
    self.initDirection = moveHelper.direction

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming mining operation...")
    else
        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the size of the cube to mine (default 5): ")
        write("> ")
        local size = tonumber(read()) or 5

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the height of the cube to mine (default 11): ")
        write("> ")
        local height = tonumber(read()) or 11

        term.clear()
        term.setCursorPos(1, 1)

        self.steps = self:mine3DAreaPath(size, height)
        self.currentStatus = self.status.mining
        self.size = size
        self.height = height

        logHelper.massage("Starting new mining operation...")
    end

    logHelper.title(string.format("Mining a cube of %d * %d * %d", self.size, self.size, self.height))

    while true do
        if self.currentStatus == self.status.finished or self.currentStatus == self.status.unfinished then break end
        self:tick()
        sleep(0)
    end
end

return mine
