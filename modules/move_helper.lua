local expect = require("cc.expect")
local expect, range = expect.expect, expect.range

local class = require("modules.class")
local vec3 = require("modules.vector3")

---@class moveHelper
local moveHelper = class("moveHelper")

---@enum moveHelper.directions
moveHelper.directions = {
    north = 0,
    east = 1,
    south = 2,
    west = 3
}

--- For easy iteration
---@type string[]
---@private
moveHelper.directionsArray = { "north", "east", "south", "west" }

---@enum moveHelper.turns
moveHelper.turns = {
    none = 0,
    left = 1,
    right = 2,
    around = 3
}

---      0
---3   M   1
---      2

---Will never be use and replace with instance table
---@type vec3
moveHelper.position = nil
--- 0 = north, 1 = east, 2 = south, 3 = west
---@type number
moveHelper.direction = nil
---@type mine|destroyer
moveHelper.mainClass = nil

---@return boolean
function moveHelper:turnLeft()
    if turtle.turnLeft() then
        self.direction = (self.direction - 1) % 4
        hook.call("moveHelper.onDirectionChanged", self.direction)
        return true
    end
    return false
end

---@return boolean
function moveHelper:turnRight()
    if turtle.turnRight() then
        self.direction = (self.direction + 1) % 4
        hook.call("moveHelper.onDirectionChanged", self.direction)
        return true
    end
    return false
end

---@return boolean
function moveHelper:turnAround()
    return self:turnLeft() and self:turnLeft()
end

---@param dir moveHelper.directions
---@return moveHelper.turns
function moveHelper:getQuickTurn(dir)
    range(dir, 0, 3)

    local diff = (dir - self.direction) % 4
    if diff == 0 then
        return moveHelper.turns.none
    elseif diff == 1 then
        return moveHelper.turns.right
    elseif diff == 2 then
        return moveHelper.turns.around
    elseif diff == 3 then
        return moveHelper.turns.left
    end
    return moveHelper.turns.none
end

---@param dir moveHelper.directions
---@return boolean
function moveHelper:turnTo(dir)
    range(dir, 0, 3)

    local turn = self:getQuickTurn(dir)
    if turn == moveHelper.turns.left then
        return self:turnLeft()
    elseif turn == moveHelper.turns.right then
        return self:turnRight()
    elseif turn == moveHelper.turns.around then
        return self:turnAround()
    end
    return true
end

---@return string
function moveHelper:getDirectionName()
    if moveHelper.directionsArray[self.direction + 1] then
        return moveHelper.directionsArray[self.direction + 1]
    end
    return "unknown"
end

---@return boolean
function moveHelper:forward()
    self.mainClass.refuelHelper:tryRefuel()
    self:dig()
    if turtle.forward() then
        if self.direction == self.directions.north then
            self.position = self.position:addZ(1)
        elseif self.direction == self.directions.east then
            self.position = self.position:addX(1)
        elseif self.direction == self.directions.south then
            self.position = self.position:addZ(-1)
        elseif self.direction == self.directions.west then
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
        if self.direction == self.directions.north then
            self.position = self.position:addZ(-1)
        elseif self.direction == self.directions.east then
            self.position = self.position:addX(-1)
        elseif self.direction == self.directions.south then
            self.position = self.position:addZ(1)
        elseif self.direction == self.directions.west then
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
            while self.direction ~= self.directions.east do
                if not self:turnTo(self.directions.east) then break end
                sleep(0)
            end
        elseif self.position.x > vector.x then
            while self.direction ~= self.directions.west do
                if not self:turnTo(self.directions.west) then break end
                sleep(0)
            end
        elseif self.position.z < vector.z then
            while self.direction ~= self.directions.north do
                if not self:turnTo(self.directions.north) then break end
                sleep(0)
            end
        elseif self.position.z > vector.z then
            while self.direction ~= self.directions.south do
                if not self:turnTo(self.directions.south) then break end
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

    self.position = vec3:zero()
    self.direction = moveHelper.directions.north
    self.mainClass = mainClass
end

return moveHelper
