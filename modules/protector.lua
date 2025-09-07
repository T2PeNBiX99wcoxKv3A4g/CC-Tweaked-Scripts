local expect             = require("cc.expect")
local expect, range      = expect.expect, expect.range

local class              = require("modules.class")
local vec3               = require("modules.vector3")
local angle              = require("modules.angle")
local moveHelper         = require("modules.move_helper")
local fileHelper         = require("modules.file_helper")
local refuelHelper       = require("modules.refuel_helper")
local logHelper          = require("modules.log_helper")
local utils              = require("modules.utils")

---@class protector
local protector          = class("protector")

---@type vec3
protector.lockTargetVec  = nil
---@type string
protector.lockTargetUuid = nil
---@type string
protector.attackSide     = "right"
---@type vec3
protector.initPos        = vec3(0, 0, 0)
---@type angle
protector.initAngle      = angle.north()
---@type turtleMatic.protectiveAutomata
protector.automata       = nil
---@type fileHelper
protector.saveHelper     = fileHelper(fileHelper.type.save, "protector_save.json")
---@type fileHelper
protector.dataHelper     = fileHelper(fileHelper.type.data, "protector_config.json")
---@type refuelHelper
protector.refuelHelper   = refuelHelper(100, 3000)
---@type moveHelper
protector.moveHelper     = moveHelper(protector)

function protector:resetPos()
    self.initPos = vec3.zero()
    self.initAngle = angle.north()
    self.moveHelper.position = vec3.zero()
    self.moveHelper.angle = angle.north()
end

function protector:findTarget()
    local targets = self.automata.scan("entity", 4) --[[@as turtleMatic.scan.output.entity[] ]]
    if #targets < 1 then return end
    local lockTarget = targets[1]
    local relativeVec3 = vec3(lockTarget.z, lockTarget.y, lockTarget.x) --[[@as vec3]]
    self:resetPos()
    self.lockTargetUuid = lockTarget.uuid
    self.lockTargetVec = relativeVec3
    logHelper.massage(("Find a Target! Pos: %s, UUID: %s"):format(self.lockTargetVec, self.lockTargetUuid))
end

function protector:clearTarget()
    self.lockTargetUuid = nil
    self.lockTargetVec = nil
end

---@return boolean
function protector:tryGoUp()
    if turtle.getFuelLevel() < 1 then return false end
    if turtle.detectUp() then return false end

    if not self.moveHelper:forward() then
        self.moveHelper:up()
    end
    return true
end

---@return boolean
function protector:tryGoDown()
    if turtle.getFuelLevel() < 1 then return false end
    if turtle.detectDown() then return false end

    if not self.moveHelper:forward() then
        self.moveHelper:down()
    end
    return true
end

function protector:tryFixUp()
    if turtle.getFuelLevel() < 1 then return end
    while true do
        if turtle.getFuelLevel() < 1 then return end
        if self.moveHelper:up() then
            break
        end
        if not self.moveHelper:forward() then
            break
        end
        sleep(0)
    end
    while true do
        if turtle.getFuelLevel() < 1 then return end
        if self.moveHelper:up() then
            break
        end
        if not self.moveHelper:back() then
            break
        end
        sleep(0)
    end
    while true do
        if turtle.getFuelLevel() < 1 then return end
        if self.moveHelper:up() then
            break
        end
        if not self.moveHelper:turnLeft() and not self.moveHelper:forward() then
            break
        end
        sleep(0)
    end
end

function protector:tryFixDown()
    if turtle.getFuelLevel() < 1 then return end
    while true do
        if turtle.getFuelLevel() < 1 then return end
        if self.moveHelper:down() then
            break
        end
        if not self.moveHelper:forward() then
            break
        end
        sleep(0)
    end
    while true do
        if turtle.getFuelLevel() < 1 then return end
        if self.moveHelper:down() then
            break
        end
        if not self.moveHelper:back() then
            break
        end
        sleep(0)
    end
    while true do
        if turtle.getFuelLevel() < 1 then return end
        if self.moveHelper:down() then
            break
        end
        if not self.moveHelper:turnLeft() and not self.moveHelper:forward() then
            break
        end
        sleep(0)
    end
end

---@return boolean
function protector:followTarget()
    local targets = self.automata.scan("entity", 4) --[[@as turtleMatic.scan.output.entity[] ]]
    if #targets < 1 then return false end
    local ret = false
    for _, value in ipairs(targets) do
        if value.uuid == self.lockTargetUuid then
            local relativeVec3 = vec3(value.z, value.y, value.x) --[[@as vec3]]
            self:resetPos()
            self.lockTargetVec = relativeVec3
            ret = true
        end
    end
    return ret
end

function protector:move()
    if self.moveHelper.position == self.lockTargetVec then return end

    self:followTarget()

    if self.moveHelper.position.y < self.lockTargetVec.y then
        if not self.moveHelper:up() then
            -- self:tryFixUp()
        end
    end

    if self.moveHelper.position.y > self.lockTargetVec.y then
        if not self.moveHelper:down() then
            -- self:tryFixDown()
        end
    end

    if self.moveHelper.position.x ~= self.lockTargetVec.x or self.moveHelper.position.z ~= self.lockTargetVec.z then
        if self.moveHelper.position.x < self.lockTargetVec.x then
            if self.moveHelper.angle ~= angle.east() then
                self.moveHelper:turnTo(angle.east())
            end
        elseif self.moveHelper.position.x > self.lockTargetVec.x then
            if self.moveHelper.angle ~= angle.west() then
                self.moveHelper:turnTo(angle.west())
            end
        elseif self.moveHelper.position.z < self.lockTargetVec.z then
            if self.moveHelper.angle ~= angle.north() then
                self.moveHelper:turnTo(angle.north())
            end
        elseif self.moveHelper.position.z > self.lockTargetVec.z then
            if self.moveHelper.angle ~= angle.south() then
                self.moveHelper:turnTo(angle.south())
            end
        end

        if not self.moveHelper:forward() then
            if not self:tryGoUp() then
                self:tryGoDown()
            end
        end
    end
end

function protector:attack()
    local lookEntity = self.automata.look("entity") --[[@as turtleMatic.look.output.entity|nil]]
    if not lookEntity then return end
    if lookEntity.uuid ~= self.lockTargetUuid then return end
    turtle.attack()
end

function protector:tick()
    logHelper.progress(("Target: Pos: %s, UUID: %s"):format(self.lockTargetVec, self.lockTargetUuid))

    while not self.lockTargetUuid or not self.lockTargetVec do
        self:findTarget()
        sleep(0)
    end

    self:move()
    self:attack()

    if self.moveHelper.position == self.lockTargetVec and not self:followTarget() then
        self:clearTarget()
    end
end

---@class protector.save
---@field lockTargetVec vec3Table|nil
---@field lockTargetUuid string|nil
---@field initPos vec3Table
---@field initAngle angleTable
---@field position vec3Table
---@field angle angleTable

---@return boolean
function protector:save()
    ---@type protector.save
    local data = {
        lockTargetVec = self.lockTargetVec and self.lockTargetVec:copy() or nil --[[@as vec3Table|nil]],
        lockTargetUuid = self.lockTargetUuid,
        initPos = self.initPos:copy() --[[@as vec3Table]],
        initAngle = self.initAngle:copy() --[[@as angleTable]],
        position = self.moveHelper.position:copy() --[[@as vec3Table]],
        angle = self.moveHelper.angle:copy() --[[@as angleTable]]
    }
    return self.saveHelper:save(data)
end

local dataCheck = {
    "lockTargetVec",
    "lockTargetUuid",
    "initPos",
    "initAngle",
    "position",
    "angle"
}

---@return boolean
function protector:load()
    local data = self.saveHelper:load()
    if not data then
        self:deleteSave()
        return false
    end
    if not utils.tableKeyCheck(data, dataCheck) then
        self:deleteSave()
        return false
    end

    local validData = data --[[@as protector.save]]

    self.lockTargetVec = (validData.lockTargetVec and vec3.fromTable(validData.lockTargetVec) or vec3.zero()) or
        vec3:zero()
    self.lockTargetUuid = validData.lockTargetUuid
    self.initPos = vec3.fromTable(validData.initPos) or vec3.zero()
    self.initAngle = angle.fromTable(validData.initAngle) or angle.north()
    self.moveHelper.position = vec3.fromTable(validData.position) or vec3.zero()
    self.moveHelper.angle = angle.fromTable(validData.angle) or angle.north()

    return true
end

---@return boolean
function protector:deleteSave()
    return self.saveHelper:delete()
end

---@param newAngle angle
function protector:onDirectionChanged(newAngle)
    self:save()
end

---@param newPosition vec3
function protector:onPositionChanged(newPosition)
    self:save()
end

---@class protector.config
---@field attackSide string

local configCheck = {
    "attackSide"
}

function protector:init()
    hook.add("moveHelper.onDirectionChanged", self, self.onDirectionChanged)
    hook.add("moveHelper.onPositionChanged", self, self.onPositionChanged)

    ---@diagnostic disable-next-line: param-type-mismatch
    self.automata = assert(peripheral.find("protectiveAutomata"),
        "Protective automata is not found! Please install 'Turtlematic' then put protective automata inside") --[[@as turtleMatic.protectiveAutomata]]

    if self:load() then
        logHelper.massage("Loaded previous state. Resuming mining operation...")

        local config = self.dataHelper:load()

        if config and utils.tableKeyCheck(config, configCheck) then
            local validConfig = config --[[@as protector.config]]
            self.attackSide = validConfig.attackSide
        end
    else
        self.initPos = self.moveHelper.position:copy()
        self.initAngle = self.moveHelper.angle:copy()

        local config = self.dataHelper:load()

        if config and utils.tableKeyCheck(config, configCheck) then
            local validConfig = config --[[@as protector.config]]
            self.attackSide = validConfig.attackSide
        else
            ---@type protector.config
            local configTable = {
                attackSide = self.attackSide
            }

            self.dataHelper:delete()
            self.dataHelper:save(configTable)
        end

        self:save()

        logHelper.massage("Starting new operation...")
    end

    logHelper.title("Protector")

    while true do
        self:tick()
        sleep(0)
    end
end

return protector
