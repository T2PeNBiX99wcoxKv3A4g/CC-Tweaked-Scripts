local class               = require("modules.class")
local refuelHelper        = require("modules.refuel_helper")
local logHelper           = require("modules.log_helper")

---@class zephyrKiller
local zephyrKiller        = class("zephyrKiller")

---@type table<string, boolean>
zephyrKiller.arrowList    = {
    ["minecraft:arrow"] = true
}

---@enum zephyrKiller.targetSide
zephyrKiller.targetSide   = {
    none = 0,
    forward = 1,
    up = 2
}

---@type turtleMatic.shooting
zephyrKiller.bow          = nil
---@type turtleMatic.automata
zephyrKiller.automata     = nil
---@type refuelHelper
zephyrKiller.refuelHelper = refuelHelper(600, 10000)

---@return zephyrKiller.targetSide
function zephyrKiller:findTarget()
    local lookForward = self.automata.look("entity")
    if lookForward and lookForward.type == "Zephyr" then return self.targetSide.forward end
    local lookUp = self.automata.look("entity", "up")
    if lookUp and lookUp.type == "Zephyr" then return self.targetSide.up end
    return self.targetSide.none
end

---@return boolean
function zephyrKiller:checkIsArrow()
    local item = turtle.getItemDetail(turtle.getSelectedSlot())
    return item ~= nil and self.arrowList[item.name]
end

---@return boolean
function zephyrKiller:selectArrow()
    if self:checkIsArrow() then return true end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)

        if item and self.arrowList[item.name] then
            turtle.select(slot)
            return true
        end
    end
    return false
end

---@type table<zephyrKiller.targetSide, fun(self: zephyrKiller)>
local shootFunc = {
    [zephyrKiller.targetSide.forward] = function(self)
        self.bow.setAngle(0)
        self.bow.shoot(4)
        logHelper.progress("Shoot forward")
    end,
    [zephyrKiller.targetSide.up] = function(self)
        self.bow.setAngle(90)
        self.bow.shoot(4)
        logHelper.progress("Shoot up")
    end
}

---@param targetSide zephyrKiller.targetSide
function zephyrKiller:shoot(targetSide)
    if not self:selectArrow() then
        logHelper.error("Arrow is not found!")
        return
    end

    if shootFunc[targetSide] then
        shootFunc[targetSide](self)
    end
end

function zephyrKiller:tick()
    self.refuelHelper:tryRefuel()

    local targetSide = self:findTarget()

    if targetSide ~= self.targetSide.none then
        self:shoot(targetSide)
    end
end

function zephyrKiller:init()
    ---@diagnostic disable-next-line: param-type-mismatch
    self.automata = assert(peripheral.find("automata"),
        "Automata is not found! Please install 'Turtlematic' then put automata inside") --[[@as turtleMatic.automata]]

    ---@diagnostic disable-next-line: param-type-mismatch
    self.bow = assert(peripheral.find("bow"),
        "Bow is not found! Please install 'Turtlematic' then put bow inside") --[[@as turtleMatic.shooting]]

    logHelper.title("Zephyr Killer")

    while true do
        self:tick()
        sleep(0)
    end
end

return zephyrKiller
