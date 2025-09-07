local expect = require("cc.expect")
local expect, range = expect.expect, expect.range

local class = require("modules.class")
local vec3 = require("modules.vector3")
local angle = require("modules.angle")

---@class moveHelper
local moveHelper = class("moveHelper")

---@type vec3
moveHelper.position = nil
---@type angle
moveHelper.angle = nil
---@type mine|destroyer
moveHelper.mainClass = nil

---@return boolean
function moveHelper:turnLeft()
    if turtle.turnLeft() then
        self.angle = self.angle:turnLeft()
        hook.call("moveHelper.onDirectionChanged", self.angle:copy())
        return true
    end
    return false
end

---@return boolean
function moveHelper:turnRight()
    if turtle.turnRight() then
        self.angle = self.angle:turnRight()
        hook.call("moveHelper.onDirectionChanged", self.angle:copy())
        return true
    end
    return false
end

---@return boolean
function moveHelper:turnAround()
    return self:turnLeft() and self:turnLeft()
end

---@param to angle
---@return boolean
function moveHelper:turnTo(to)
    ---@diagnostic disable-next-line: param-type-mismatch
    expect(1, to, "table")
    assert(angle.isAngle(to), "Invalid angle: " .. to)

    local turn = self.angle:getQuickTurn(to)
    if turn == angle.turns.left then
        return self:turnLeft()
    elseif turn == angle.turns.right then
        return self:turnRight()
    elseif turn == angle.turns.around then
        return self:turnAround()
    end
    return true
end

---@return boolean
function moveHelper:forward()
    self.mainClass.refuelHelper:tryRefuel()
    self:dig()
    if turtle.forward() then
        if self.angle == angle.north() then
            self.position = self.position:addZ(1)
        elseif self.angle == angle.east() then
            self.position = self.position:addX(1)
        elseif self.angle == angle.south() then
            self.position = self.position:addZ(-1)
        elseif self.angle == angle.west() then
            self.position = self.position:addX(-1)
        end
        hook.call("moveHelper.onPositionChanged", self.position:copy())
        return true
    end
    return false
end

---@return boolean
function moveHelper:back()
    self.mainClass.refuelHelper:tryRefuel()
    if turtle.back() then
        if self.angle == angle.north() then
            self.position = self.position:addZ(-1)
        elseif self.angle == angle.east() then
            self.position = self.position:addX(-1)
        elseif self.angle == angle.south() then
            self.position = self.position:addZ(1)
        elseif self.angle == angle.west() then
            self.position = self.position:addX(1)
        end
        hook.call("moveHelper.onPositionChanged", self.position:copy())
        return true
    end
    return false
end

---@return boolean
function moveHelper:up()
    self.mainClass.refuelHelper:tryRefuel()
    self:digUp()
    if turtle.up() then
        self.position = self.position:addY(1)
        hook.call("moveHelper.onPositionChanged", self.position:copy())
        return true
    end
    return false
end

---@return boolean
function moveHelper:down()
    self.mainClass.refuelHelper:tryRefuel()
    self:digDown()
    if turtle.down() then
        self.position = self.position:addY(-1)
        hook.call("moveHelper.onPositionChanged", self.position:copy())
        return true
    end
    return false
end

---@param vector vec3 local pos
---@return boolean
function moveHelper:moveTo(vector)
    ---@diagnostic disable-next-line: param-type-mismatch
    expect(1, vector, "table")
    assert(vec3.isVec3(vector), "Invalid vector3: " .. vector)

    if self.position == vector then
        return true
    end

    while self.position.y < vector.y do
        if not self:up() then break end
        sleep(0)
    end

    while self.position.y > vector.y do
        if not self:down() then break end
        sleep(0)
    end

    while self.position.x ~= vector.x or self.position.z ~= vector.z do
        if self.position.x < vector.x then
            while self.angle ~= angle.east() do
                if not self:turnTo(angle.east()) then break end
                sleep(0)
            end
        elseif self.position.x > vector.x then
            while self.angle ~= angle.west() do
                if not self:turnTo(angle.west()) then break end
                sleep(0)
            end
        elseif self.position.z < vector.z then
            while self.angle ~= angle.north() do
                if not self:turnTo(angle.north()) then break end
                sleep(0)
            end
        elseif self.position.z > vector.z then
            while self.angle ~= angle.south() do
                if not self:turnTo(angle.south()) then break end
                sleep(0)
            end
        end

        if not self:forward() then break end
        sleep(0)
    end

    return true
end

---@return boolean
function moveHelper:dig()
    if not turtle.detect() then return false end
    turtle.dig()
    return true
end

---@return boolean
function moveHelper:digUp()
    if not turtle.detectUp() then return false end
    turtle.digUp()
    return true
end

---@return boolean
function moveHelper:digDown()
    if not turtle.detectDown() then return false end
    turtle.digDown()
    return true
end

---@param mainClass mine|destroyer
function moveHelper:init(mainClass)
    ---@diagnostic disable-next-line: param-type-mismatch
    expect(1, mainClass, "table")

    self.position = vec3.zero() --[[@as vec3]]
    self.angle = angle.north() --[[@as angle]]
    self.mainClass = mainClass
end

return moveHelper
