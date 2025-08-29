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
                self:turnRight()
                sleep(0)
            end
            self:forward()
        elseif self.position.x > vec3.x then
            while self.direction ~= self.directions.west do
                self:turnRight()
                sleep(0)
            end
            self:forward()
        elseif self.position.z < vec3.z then
            while self.direction ~= self.directions.north do
                self:turnRight()
                sleep(0)
            end
            self:forward()
        elseif self.position.z > vec3.z then
            while self.direction ~= self.directions.south do
                self:turnRight()
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
