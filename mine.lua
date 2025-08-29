local Mine = {}
local Vec3 = require("vector3")
local MoveHelper = require("move_helper")
local RefuelHelper = require("refuel_helper")

---@enum Mine.status
Mine.status = {
    idle = 0,
    mining = 1,
    tempBacking = 2,
    backingFinished = 3,
    backingUnfinished = 4,
    finished = 5,
    unfinished = 6
}

---@type Vec3
Mine.initPos = Vec3(0, 0, 0)
---@type MoveHelper.directions
Mine.initDirection = MoveHelper.directions.north
---@type Vec3[]
Mine.Steps = {}
---@type number
Mine.currentStep = 1
---@type Mine.status
Mine.currentStatus = Mine.status.idle

---@param size number
---@param y number
---@return Vec3[]
function Mine:mine2DAreaPath(size, y)
    local points = {}
    local sizeEnd = size - 1

    for x = 0, -sizeEnd, -1 do
        for z = 0, sizeEnd do
            table.insert(points, Vec3(x, y, z))
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
---@return Vec3[]
function Mine:mine3DAreaPath(size, height)
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
function Mine:move()
    local step = self.currentStep
    local movePos = self.Steps[step]
    term.setCursorPos(1, 2)
    term.clearLine()
    term.write(string.format("Step %d/%d: Moving to {x: %d, y: %d, z: %d}", step, #self.Steps, movePos.x, movePos.y,
        movePos.z))
    MoveHelper:moveTo(movePos)
    self.currentStep = self.currentStep + 1
end

---@return nil
function Mine:backToStart()
    MoveHelper:moveTo(self.initPos)
    MoveHelper:turnTo(self.initDirection)
end

---@return nil
function Mine:dropItemToChest()
    MoveHelper:turnTo(MoveHelper.directions.south)

    for i = 1, 16 do
        local item = turtle.getItemDetail(i)
        if item and not RefuelHelper.coalList[item.name] then
            turtle.select(i)
            turtle.drop(item.count)
        end
    end

    turtle.select(1)
end

function Mine:checkInventory()
    local itemSpace = 0

    for i = 1, 16 do
        itemSpace = itemSpace + turtle.getItemSpace(i)
    end

    if itemSpace > 64 then return end
    term.setCursorPos(1, 3)
    term.clearLine()
    term.write(string.format(
        "Inventory space low: %d space left, Temporarily returning to start position to drop items...", itemSpace))
    self.currentStatus = self.status.tempBacking
end

function Mine:tick()
    if RefuelHelper.currentStatus == RefuelHelper.status.outOfFuel then
        self.currentStatus = self.status.backingUnfinished
        term.setCursorPos(1, 3)
        term.clearLine()
        term.write("Out of fuel! Returning to start position...")
    end

    if self.currentStatus == self.status.mining then
        if self.currentStep > #self.Steps then
            self.currentStatus = self.status.backingFinished
            term.setCursorPos(1, 3)
            term.clearLine()
            term.write("Mining complete! Returning to start position...")
            return
        end
        self:move()
        self:checkInventory()
    elseif self.currentStatus == self.status.tempBacking then
        self:backToStart()
        self:dropItemToChest()
        term.setCursorPos(1, 3)
        term.clearLine()
        term.write("Items dropped to chest. Resuming mining...")
        self.currentStatus = self.status.mining
    elseif self.currentStatus == self.status.backingFinished then
        self:backToStart()
        self.currentStatus = self.status.finished
        term.setCursorPos(1, 3)
        term.clearLine()
        term.write("Returned to start position. Mining operation finished.")
    elseif self.currentStatus == self.status.backingUnfinished then
        self:backToStart()
        self.currentStatus = self.status.unfinished
        term.setCursorPos(1, 3)
        term.clearLine()
        term.write("Returned to start position. Mining operation unfinished due to lack of fuel.")
    end
end

function Mine:init()
    self.initPos = MoveHelper.position
    self.initDirection = MoveHelper.direction

    term.clear()
    print("Enter the size of the cube to mine (default 5): ")
    write("> ")
    local size = tonumber(read()) or 5

    term.clear()
    print("Enter the height of the cube to mine (default 11): ")
    write("> ")
    local height = tonumber(read()) or 11

    self.Steps = self:mine3DAreaPath(size, height)

    term.clear()
    term.setCursorPos(1, 1)
    term.write(string.format("Starting mining a cube of size %d and height %d", size, height))

    self.currentStatus = self.status.mining

    while true do
        if self.currentStatus == self.status.finished then break end
        self:tick()
        sleep(0)
    end
end

Mine:init()
