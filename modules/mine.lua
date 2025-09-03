local class = require("modules.class")
local vec3 = require("modules.vector3")
local moveHelper = require("modules.move_helper")
local fileHelper = require("modules.file_helper")
local refuelHelper = require("modules.refuel_helper")
local logHelper = require("modules.log_helper")
local mineGPS = require("modules.mine_gps")
local utils = require("modules.utils")

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

---@enum mine.modes
mine.modes = {
    down = 0,
    forward = 1,
    up = 2
}

---@type number
mine.length = 5
---@type number
mine.width = 5
---@type number
mine.height = 11
---@type vec3
mine.initPos = vec3(0, 0, 0)
---@type vec3|nil
mine.initGPSPos = nil
---@type moveHelper.directions
mine.initDirection = moveHelper.directions.north
---@type vec3[]
mine.steps = {}
---@type number
mine.currentStep = 1
---@type mine.status
mine.currentStatus = mine.status.idle
---@type mine.modes
mine.currentMode = mine.modes.down
---@type boolean
mine.gpsAvailable = false
---@type ccTweaked.peripherals.Modem
mine.modem = nil
---@type fileHelper
mine.saveHelper = fileHelper(fileHelper.type.save, "mine_save.json")
---@type fileHelper
mine.gpsHelper = fileHelper(fileHelper.type.save, "mine_gps_list.json")
---@type refuelHelper
mine.refuelHelper = refuelHelper()
---@type moveHelper
mine.moveHelper = moveHelper(mine)

function mine:move()
    local step = self.currentStep
    local movePos = self.steps[step]
    local printPos = movePos:copy()

    if settings.get(mineGPS.settingName, false) and self.initGPSPos then
        printPos = self.initGPSPos + printPos
    end

    logHelper.progress(string.format("Step %d/%d: {x: %d, y: %d, z: %d}", step - 1, #self.steps, printPos.x, printPos.y,
        printPos.z))
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
        length = self.length,
        width = self.width,
        height = self.height,
        initPos = self.initPos:copy(),
        initDirection = self.initDirection,
        position = self.moveHelper.position:copy(),
        direction = self.moveHelper.direction,
        steps = self.steps,
        currentStep = self.currentStep,
        currentStatus = self.currentStatus,
        currentMode = self.currentMode
    }
    return self.saveHelper:save(data)
end

local dataCheck = {
    "length",
    "width",
    "height",
    "initPos",
    "initDirection",
    "position",
    "direction",
    "steps",
    "currentStep",
    "currentStatus",
    "currentMode"
}

---@return boolean
function mine:load()
    local data = self.saveHelper:load()
    if not data then
        self:deleteSave()
        return false
    end
    if not utils.tableKeyCheck(data, dataCheck) then
        self:deleteSave()
        return false
    end

    self.length = data.length
    self.width = data.width
    self.height = data.height
    self.initPos = vec3.fromTable(data.initPos) or vec3.zero()
    self.initDirection = data.initDirection
    self.moveHelper.position = vec3.fromTable(data.position) or vec3.zero()
    self.moveHelper.direction = data.direction

    local newSteps = {}

    for index, value in ipairs(data.steps) do
        newSteps[index] = vec3.fromTable(value)
    end

    self.steps = newSteps
    self.currentStep = data.currentStep
    self.currentStatus = data.currentStatus
    self.currentMode = data.currentMode

    return true
end

---@return boolean
function mine:deleteSave()
    return self.saveHelper:delete()
end

function mine:broadcastGPSData()
    if not settings.get(mineGPS.settingName, false) then return end
    local gpsX, gpsY, gpsZ = gps.locate(2, false)
    if not gpsX then return end
    ---@type mineGPS.data
    local data = {
        currentStatus = self.currentStatus,
        currentPosition = vec3(gpsX, gpsY, gpsZ),
        currentFuelLevel = turtle.getFuelLevel(),
        currentStep = self.currentStep - 1,
        maxStep = #self.steps
    }
    rednet.broadcast(data, mineGPS.protocol)
end

---@param newDirection moveHelper.directions
function mine:onDirectionChanged(newDirection)
    self:save()
    self:broadcastGPSData()
end

---@param newPosition vec3
function mine:onPositionChanged(newPosition)
    self:save()
    self:broadcastGPSData()
end

mine.modesSteps = {
    [mine.modes.down] = function(length, width, height)
        return utils.mine3DDownAreaPath(length, width, height)
    end,
    [mine.modes.forward] = function(length, width, height)
        return utils.mine3DForwardAreaPath(length, width, height)
    end,
    [mine.modes.up] = function(length, width, height)
        return utils.mine3DUpAreaPath(length, width, height)
    end
}

function mine:init()
    hook.add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook.add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    self:broadcastGPSData()

    if settings.get(mineGPS.settingName, false) then
        local gpsX, gpsY, gpsZ = gps.locate(2, false)

        if gpsX then
            self.initGPSPos = vec3(gpsX, gpsY, gpsZ) --[[@as vec3]]
        end
    end

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming mining operation...")
    else
        self.initPos = self.moveHelper.position:copy()
        self.initDirection = self.moveHelper.direction

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the length of the cube to mine (default 5): ")
        write("> ")
        local length = tonumber(read()) or 5

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the width of the cube to mine (default 5): ")
        write("> ")
        local width = tonumber(read()) or 5

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the height of the cube to mine (default 11): ")
        write("> ")
        local height = tonumber(read()) or 11

        term.clear()
        term.setCursorPos(1, 1)
        print("Enter the mine mode, 0 = down, 1 = forward, 2 = up (default 0): ")
        write("> ")
        local mode = tonumber(read()) or 0

        term.clear()
        term.setCursorPos(1, 1)

        self.steps = assert(self.modesSteps[mode], "Can't find any available steps can be use")(length, width, height)
        self.currentStatus = self.status.mining
        self.currentMode = mode
        self.length = length
        self.width = width
        self.height = height
        self:save()

        logHelper.massage("Starting new mining operation...")
    end

    logHelper.title(string.format("Mining a cube of %d * %d * %d", self.length, self.width, self.height))

    while true do
        if self.currentStatus == self.status.finished or self.currentStatus == self.status.unfinished then break end
        self:tick()
        sleep(0)
    end
end

return mine
