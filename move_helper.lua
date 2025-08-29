local MoveHelper = {}
local Vec3 = require("vector3")

---@type Vec3
MoveHelper.position = Vec3:zero()
--- 0 = north, 1 = east, 2 = south, 3 = west
---@type number
MoveHelper.direction = 0

---@enum MoveHelper.directions
MoveHelper.directions = {
    north = 0,
    east = 1,
    south = 2,
    west = 3
}

--- For easy iteration
---@type string[]
MoveHelper.directionsArray = { "north", "east", "south", "west" }

---@enum MoveHelper.turns
MoveHelper.turns = {
    none = 0,
    left = 1,
    right = 2,
    around = 3
}

---      0
---3   M   1
---      2

function MoveHelper:turnLeft()
    turtle.turnLeft()
    self.direction = (self.direction - 1) % 4
end

function MoveHelper:turnRight()
    turtle.turnRight()
    self.direction = (self.direction + 1) % 4
end

function MoveHelper:turnAround()
    turtle.turnLeft()
    turtle.turnLeft()
    self.direction = (self.direction + 2) % 4
end

---@param dir MoveHelper.directions
---@return MoveHelper.turns
function MoveHelper:getQuickTurn(dir)
    if dir < 0 or dir > 3 then
        error("Invalid direction: " .. dir, 2)
        return MoveHelper.turns.none
    end

    local diff = (dir - self.direction) % 4
    if diff == 0 then
        return MoveHelper.turns.none
    elseif diff == 1 then
        return MoveHelper.turns.right
    elseif diff == 2 then
        return MoveHelper.turns.around
    elseif diff == 3 then
        return MoveHelper.turns.left
    end
    return MoveHelper.turns.none
end

---@param dir MoveHelper.directions
function MoveHelper:turnTo(dir)
    if dir < 0 or dir > 3 then
        error("Invalid direction: " .. dir, 2)
        return
    end

    local turn = self:getQuickTurn(dir)
    if turn == MoveHelper.turns.left then
        self:turnLeft()
    elseif turn == MoveHelper.turns.right then
        self:turnRight()
    elseif turn == MoveHelper.turns.around then
        self:turnAround()
    end
end

---@return string
function MoveHelper:getDirectionName()
    if MoveHelper.directionsArray[self.direction] then
        return MoveHelper.directionsArray[self.direction]
    end
    return "unknown"
end

---@return boolean
function MoveHelper:forward()
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
        return true
    end
    return false
end

---@return boolean
function MoveHelper:back()
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
        return true
    end
    return false
end

---@return boolean
function MoveHelper:up()
    self:digUp()
    if turtle.up() then
        self.position = self.position:addY(1)
        return true
    end
    return false
end

---@return boolean
function MoveHelper:down()
    self:digDown()
    if turtle.down() then
        self.position = self.position:addY(-1)
        return true
    end
    return false
end

---@param vec3 Vec3 local pos
---@return boolean
function MoveHelper:moveTo(vec3)
    if vec3:isNil() then
        error("Invalid coordinates: " .. vec3, 2)
        return false
    end

    if self.position:equals(vec3) then
        return true
    end

    while self.position.y < vec3.y do
        self:up()
        sleep(0)
    end

    while self.position.y > vec3.y do
        self:down()
        sleep(0)
    end

    while self.position.x ~= vec3.x or self.position.z ~= vec3.z do
        if self.position.x < vec3.x then
            while self.direction ~= self.directions.east do
                self:turnTo(self.directions.east)
                sleep(0)
            end
            self:forward()
        elseif self.position.x > vec3.x then
            while self.direction ~= self.directions.west do
                self:turnTo(self.directions.west)
                sleep(0)
            end
            self:forward()
        elseif self.position.z < vec3.z then
            while self.direction ~= self.directions.north do
                self:turnTo(self.directions.north)
                sleep(0)
            end
            self:forward()
        elseif self.position.z > vec3.z then
            while self.direction ~= self.directions.south do
                self:turnTo(self.directions.south)
                sleep(0)
            end
            self:forward()
        end
        sleep(0)
    end

    return true
end

---@return boolean
function MoveHelper:dig()
    if not turtle.detect() then return false end
    turtle.dig()
    return true
end

---@return boolean
function MoveHelper:digUp()
    if not turtle.detectUp() then return false end
    turtle.digUp()
    return true
end

---@return boolean
function MoveHelper:digDown()
    if not turtle.detectDown() then return false end
    turtle.digDown()
    return true
end

return MoveHelper
