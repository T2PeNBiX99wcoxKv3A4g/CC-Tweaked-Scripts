local class = require("modules.class")
local vec3 = require("modules.vector3")
local angle = require("modules.angle")
local moveHelper = require("modules.move_helper")
local fileHelper = require("modules.file_helper")
local refuelHelper = require("modules.refuel_helper")
local logHelper = require("modules.log_helper")
local utils = require("modules.utils")

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

---@enum destroyer.modes
destroyer.modes = {
    forward = 0,
    down = 1,
    up = 2
}

---@type number
destroyer.length = 10
---@type number
destroyer.height = 2
---@type number
destroyer.width = 2
---@type string
destroyer.attackSide = "right"
---@type vec3
destroyer.initPos = vec3(0, 0, 0)
---@type angle
destroyer.initAngle = angle.north()
---@type vec3[]
destroyer.steps = {}
---@type number
destroyer.currentStep = 1
---@type destroyer.status
destroyer.currentStatus = destroyer.status.idle
---@type mine.modes
destroyer.currentMode = destroyer.modes.forward
---@type fileHelper
destroyer.saveHelper = fileHelper(fileHelper.type.save, "destroyer_save.json")
---@type fileHelper
destroyer.dataHelper = fileHelper(fileHelper.type.data, "destroyer_config.json")
---@type refuelHelper
destroyer.refuelHelper = refuelHelper(100, 3000)
---@type moveHelper
destroyer.moveHelper = moveHelper(destroyer)

function destroyer:move()
    local step = self.currentStep
    local movePos = self.steps[step]
    logHelper.progress(string.format("Step %d/%d: {x: %d, y: %d, z: %d}", step, #self.steps, movePos.x, movePos.y,
        movePos.z))
    self.moveHelper:moveTo(movePos)
    self.currentStep = self.currentStep + 1
    self:save()
end

function destroyer:backToStartPos()
    self.moveHelper:moveTo(self.initPos)
end

function destroyer:turnToStartDirection()
    self.moveHelper:turnTo(self.initAngle)
end

function destroyer:dropItemToChest()
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

---@class destroyer.save
---@field length number
---@field width number
---@field height number
---@field initPos vec3Table
---@field initAngle angleTable
---@field position vec3Table
---@field angle angleTable
---@field steps vec3Table[]
---@field currentStep number
---@field currentStatus destroyer.status
---@field currentMode destroyer.modes

---@return boolean
function destroyer:save()
    ---@type destroyer.save
    local data = {
        length = self.length,
        width = self.width,
        height = self.height,
        initPos = self.initPos:copy() --[[@as vec3Table]],
        initAngle = self.initAngle:copy() --[[@as angleTable]],
        position = self.moveHelper.position:copy() --[[@as vec3Table]],
        angle = self.moveHelper.angle:copy() --[[@as angleTable]],
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
    "initAngle",
    "position",
    "angle",
    "steps",
    "currentStep",
    "currentStatus",
    "currentMode"
}

---@return boolean
function destroyer:load()
    local data = self.saveHelper:load()
    if not data then
        self:deleteSave()
        return false
    end
    if not utils.tableKeyCheck(data, dataCheck) then
        self:deleteSave()
        return false
    end

    local validData = data --[[@as destroyer.save]]

    self.length = validData.length
    self.width = validData.width
    self.height = validData.height
    self.initPos = vec3.fromTable(validData.initPos) or vec3.zero()
    self.initAngle = angle.fromTable(validData.initAngle) or angle.north()
    self.moveHelper.position = vec3.fromTable(validData.position) or vec3.zero()
    self.moveHelper.angle = angle.fromTable(validData.angle) or angle.north()

    ---@type vec3[]
    local newSteps = {}

    for index, value in ipairs(validData.steps) do
        newSteps[index] = vec3.fromTable(value)
    end

    self.steps = newSteps
    self.currentStep = validData.currentStep
    self.currentStatus = validData.currentStatus
    self.currentMode = validData.currentMode

    return true
end

---@return boolean
function destroyer:deleteSave()
    return self.saveHelper:delete()
end

---@param newAngle angle
function destroyer:onDirectionChanged(newAngle)
    turtle.attack(self.attackSide)
    self:save()
end

---@param newPosition vec3
function destroyer:onPositionChanged(newPosition)
    turtle.attack(self.attackSide)
    self:save()
end

destroyer.modesSteps = {
    [destroyer.modes.forward] = function(length, width, height)
        return utils.mine3DForwardAreaPath(length, width, height)
    end,
    [destroyer.modes.down] = function(length, width, height)
        return utils.mine3DDownAreaPath(width, height, length)
    end,
    [destroyer.modes.up] = function(length, width, height)
        return utils.mine3DUpAreaPath(width, height, length)
    end
}

---@class destroyer.config
---@field length number
---@field height number
---@field width number
---@field attackSide string

local configCheck = {
    "length",
    "height",
    "width",
    "attackSide"
}

function destroyer:init()
    hook.add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook.add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming mining operation...")

        local config = self.dataHelper:load()

        if config and utils.tableKeyCheck(config, configCheck) then
            local validConfig = config --[[@as destroyer.config]]
            self.attackSide = validConfig.attackSide
        end
    else
        self.initPos = self.moveHelper.position:copy()
        self.initAngle = self.moveHelper.angle:copy()

        local config = self.dataHelper:load()

        if config and utils.tableKeyCheck(config, configCheck) then
            local validConfig = config --[[@as destroyer.config]]
            self.length = validConfig.length
            self.height = validConfig.height
            self.width = validConfig.width
            self.attackSide = validConfig.attackSide
        else
            ---@type destroyer.config
            local configTable = {
                length = self.length,
                height = self.height,
                width = self.width,
                attackSide = self.attackSide
            }

            self.dataHelper:delete()
            self.dataHelper:save(configTable)
        end

        term.clear()
        term.setCursorPos(1, 1)
        print(("Enter the mine mode, 0 = forward, 1 = down, 2 = up (default %d): "):format(self.currentMode))
        write("> ")
        local mode = tonumber(read()) or self.currentMode

        term.clear()
        term.setCursorPos(1, 1)

        self.steps = assert(self.modesSteps[mode], "Can't find any available steps can be use")(self.length, self.width,
            self.height)
        self.currentStatus = self.status.mining
        self.currentMode = mode
        self:save()

        logHelper.massage("Starting new mining operation...")
    end

    logHelper.title(string.format("Mining a cube of %d * %d * %d", self.length, self.height, self.width))

    while true do
        if self.currentStatus == self.status.finished or self.currentStatus == self.status.unfinished then break end
        self:tick()
        sleep(0)
    end
end

return destroyer
