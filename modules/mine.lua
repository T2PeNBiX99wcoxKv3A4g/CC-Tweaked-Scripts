local class = require("modules.class")
local vec3 = require("modules.vector3")
local moveHelper = require("modules.move_helper")
local fileHelper = require("modules.file_helper")
local refuelHelper = require("modules.refuel_helper")
local logHelper = require("modules.log_helper")

---@class mine
local mine = class("mine")

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
---@type fileHelper
mine.saveHelper = fileHelper(fileHelper.type.save, "mine_save.json")
---@type refuelHelper
mine.refuelHelper = refuelHelper()
---@type moveHelper
mine.moveHelper = moveHelper(mine)

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

function mine:move()
    local step = self.currentStep
    local movePos = self.steps[step]
    logHelper.progress(string.format("Step %d/%d: {x: %d, y: %d, z: %d}", step, #self.steps, movePos.x, movePos.y,
        movePos.z))
    self.moveHelper:moveTo(movePos)
    self.currentStep = self.currentStep + 1
    self:save()
end

function mine:backToStartPos()
    self.moveHelper:moveTo(self.initPos)
end

function mine:turnToStartDirection()
    self.moveHelper:turnTo(self.initDirection)
end

function mine:dropItemToChest()
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

function mine:checkInventory()
    local hasSpace = false

    for i = 1, 16 do
        if turtle.getItemCount(i) < 1 then
            hasSpace = true
            break
        end
    end

    if hasSpace then return end
    logHelper.warning("Inventory space low, Temporarily returning to start position to drop items...")
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
        self:backToStartPos()
        self:dropItemToChest()
        self.currentStatus = self.status.mining
        logHelper.massage("Items dropped to chest. Resuming mining...")
    end,
    [mine.status.backingFinished] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self:turnToStartDirection()
        self.currentStatus = self.status.finished
        self:deleteSave()
        logHelper.massage("Returned to start position. Mining operation finished.")
    end,
    [mine.status.backingUnfinished] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self:turnToStartDirection()
        self.currentStatus = self.status.unfinished
        self:deleteSave()
        logHelper.error("Returned to start position. Mining operation unfinished due to lack of fuel.")
    end
}

function mine:tick()
    if self.refuelHelper.currentStatus == refuelHelper.status.outOfFuel then
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
        initPos = self.initPos:copy(),
        initDirection = self.initDirection,
        position = self.moveHelper.position:copy(),
        direction = self.moveHelper.direction,
        steps = self.steps,
        currentStep = self.currentStep,
        currentStatus = self.currentStatus
    }
    return self.saveHelper:save(data)
end

---@return boolean
function mine:load()
    local data = self.saveHelper:load()
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
    self.initPos = vec3:fromTable(data.initPos) or vec3:zero()
    self.initDirection = data.initDirection
    self.moveHelper.position = vec3:fromTable(data.position) or vec3:zero()
    self.moveHelper.direction = data.direction

    local newSteps = {}

    for index, value in ipairs(data.steps) do
        newSteps[index] = vec3:fromTable(value)
    end

    self.steps = newSteps
    self.currentStep = data.currentStep
    self.currentStatus = data.currentStatus

    return true
end

---@return boolean
function mine:deleteSave()
    return self.saveHelper:delete()
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
    hook.add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook.add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming mining operation...")
    else
        self.initPos = self.moveHelper.position:copy()
        self.initDirection = self.moveHelper.direction

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
        self:save()

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
