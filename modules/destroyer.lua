local class = require("modules.class")
local vec3 = require("modules.vector3")
local moveHelper = require("modules.move_helper")
local fileHelper = require("modules.file_helper")
local refuelHelper = require("modules.refuel_helper")
local logHelper = require("modules.log_helper")

---@class destroyer
local destroyer = class("destroyer")

---@enum destroyer.status
destroyer.status = {
    idle = 0,
    mining = 1,
    tempBacking = 2,
    backingFinished = 3,
    backingUnfinished = 4,
    finished = 5,
    unfinished = 6
}

---@type number
destroyer.size = 10
---@type number
destroyer.height = 2
---@type number
destroyer.width = 2
---@type string
destroyer.attackSide = "right"
---@type vec3
destroyer.initPos = vec3(0, 0, 0)
---@type moveHelper.directions
destroyer.initDirection = moveHelper.directions.north
---@type vec3[]
destroyer.steps = {}
---@type number
destroyer.currentStep = 1
---@type destroyer.status
destroyer.currentStatus = destroyer.status.idle
---@type fileHelper
destroyer.saveHelper = fileHelper(fileHelper.type.save, "destroyer_save.json")
---@type fileHelper
destroyer.dataHelper = fileHelper(fileHelper.type.data, "destroyer_config.json")
---@type refuelHelper
destroyer.refuelHelper = refuelHelper(100, 3000)
---@type moveHelper
destroyer.moveHelper = moveHelper(destroyer)

---@param size number
---@param height number
---@param x number
---@return vec3[]
function destroyer:mine2DAreaPath(size, height, x)
    local points = {}
    local sizeEnd = size - 1
    local heightEnd = height - 1

    for y = 0, heightEnd do
        for z = 0, sizeEnd do
            table.insert(points, vec3(x, y, z))
        end
    end

    table.sort(points, function(a, b)
        if a.y == b.y then
            return a.z < b.z
        end
        return a.y < b.y
    end)

    return points
end

---@param size number
---@param height number
---@param width number
---@return vec3[]
function destroyer:mine3DAreaPath(size, height, width)
    local points = {}
    local widthEnd = width - 1

    for x = 0, -widthEnd, -1 do
        local layerPoints = self:mine2DAreaPath(size, height, x)
        for _, v in ipairs(layerPoints) do
            table.insert(points, v)
        end
    end

    return points
end

---@return nil
function destroyer:move()
    local step = self.currentStep
    local movePos = self.steps[step]
    logHelper.progress(string.format("Step %d/%d: {x: %d, y: %d, z: %d}", step, #self.steps, movePos.x, movePos.y,
        movePos.z))
    self.moveHelper:moveTo(movePos)
    self.currentStep = self.currentStep + 1
    self:save()
end

---@return nil
function destroyer:backToStartPos()
    self.moveHelper:moveTo(self.initPos)
end

---@return nil
function destroyer:turnToStartDirection()
    self.moveHelper:turnTo(self.initDirection)
end

---@return nil
function destroyer:dropItemToChest()
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

---@type table<destroyer.status, fun(self: destroyer)>
destroyer.statusTick = {
    [destroyer.status.mining] = function(self)
        if self.currentStep > #self.steps then
            self.currentStatus = self.status.backingFinished
            logHelper.massage("Mining complete! Returning to start position...")
            return
        end
        self:move()
    end,
    [destroyer.status.tempBacking] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self.currentStatus = self.status.mining
        logHelper.massage("Items dropped to chest. Resuming mining...")
    end,
    [destroyer.status.backingFinished] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self:turnToStartDirection()
        self.currentStatus = self.status.finished
        self:deleteSave()
        logHelper.massage("Returned to start position. Mining operation finished.")
    end,
    [destroyer.status.backingUnfinished] = function(self)
        self:backToStartPos()
        self:dropItemToChest()
        self:turnToStartDirection()
        self.currentStatus = self.status.unfinished
        self:deleteSave()
        logHelper.error("Returned to start position. Mining operation unfinished due to lack of fuel.")
    end
}

function destroyer:tick()
    if self.refuelHelper.currentStatus == refuelHelper.status.outOfFuel then
        self.currentStatus = self.status.backingUnfinished
        logHelper.error("Out of fuel! Returning to start position...")
    end

    if self.statusTick[self.currentStatus] then
        self.statusTick[self.currentStatus](self)
    end
end

---@return boolean
function destroyer:save()
    local data = {
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
function destroyer:load()
    local data = self.saveHelper:load()
    if not data then
        self:deleteSave()
        return false
    end
    if not data.initPos or not data.initDirection or not data.position or not data.direction or not data.steps or not data.currentStep or not data.currentStatus then
        self:deleteSave()
        return false
    end

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
function destroyer:deleteSave()
    return self.saveHelper:delete()
end

---@param newDirection moveHelper.directions
function destroyer:onDirectionChanged(newDirection)
    turtle.attack(self.attackSide)
    self:save()
end

---@param newPosition vec3
function destroyer:onPositionChanged(newPosition)
    turtle.attack(self.attackSide)
    self:save()
end

function destroyer:init()
    hook.add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook.add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming mining operation...")
    else
        self.initPos = self.moveHelper.position:copy()
        self.initDirection = self.moveHelper.direction

        local config = self.dataHelper:load()

        if config and config.size and config.height and config.width then
            self.size = config.size
            self.height = config.height
            self.width = config.width
            self.attackSide = config.attackSide
        else
            local configTable = {
                size = self.size,
                height = self.height,
                width = self.width,
                attackSide = self.attackSide
            }

            self.dataHelper:delete()
            self.dataHelper:save(configTable)
        end

        term.clear()
        term.setCursorPos(1, 1)

        self.steps = self:mine3DAreaPath(self.size, self.height, self.width)
        self.currentStatus = self.status.mining
        self:save()

        logHelper.massage("Starting new mining operation...")
    end

    logHelper.title(string.format("Mining a cube of %d * %d * %d", self.size, self.height, self.width))

    while true do
        if self.currentStatus == self.status.finished or self.currentStatus == self.status.unfinished then break end
        self:tick()
        sleep(0)
    end
end

return destroyer
