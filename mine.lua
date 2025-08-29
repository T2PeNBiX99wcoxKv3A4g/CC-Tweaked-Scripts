local Mine = {}
local Vec3 = require("vector3")

---@type Vec3
Mine.position = Vec3:zero()
---@type number
Mine.direction = 0 -- 0 = north, 1 = east, 2 = south, 3 = west

---@enum directions
Mine.directions = {
    north = 0,
    east = 1,
    south = 2,
    west = 3
}

---      0
---3   M   1
---      2

---@type table<string, boolean>
Mine.coalList = {
    ["minecraft:coal"] = true,
    ["minecraft:coal_block"] = true,
    ["aether:ambrosium_shard"] = true
}

---@type Vec3
Mine.initPos = Vec3(0, 0, 0)

---@return boolean
function Mine:refuel()
    local fuelLevel = turtle.getFuelLevel()
    if fuelLevel == "unlimited" or fuelLevel > 100 then return false end

    for slot = 1, 16 do
        local item = turtle.getItemDetail(slot)

        if item and self[item.name] then
            turtle.select(slot)
            turtle.refuel(1)
            print("Refueled with coal. Current fuel level: " .. turtle.getFuelLevel())
            return true
        end
    end

    print("Out of fuel! Please add coal to the turtle.")
    while true do
        sleep(10)
        self:refuel()
    end
end

function Mine:turnLeft()
    turtle.turnLeft()
    self.direction = (self.direction - 1) % 4
end

function Mine:turnRight()
    turtle.turnRight()
    self.direction = (self.direction + 1) % 4
end

---@return boolean
function Mine:forward()
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
function Mine:back()
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
function Mine:up()
    self:digUp()
    if turtle.up() then
        self.position = self.position:addY(1)
        return true
    end
    return false
end

---@return boolean
function Mine:down()
    self:digDown()
    if turtle.down() then
        self.position = self.position:addY(-1)
        return true
    end
    return false
end

---@param vec3 Vec3 local pos
---@return boolean
function Mine:moveTo(vec3)
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
function Mine:dig()
    if not turtle.detect() then return false end
    turtle.dig()
    return true
end

---@return boolean
function Mine:digUp()
    if not turtle.detectUp() then return false end
    turtle.digUp()
    return true
end

---@return boolean
function Mine:digDown()
    if not turtle.detectDown() then return false end
    turtle.digDown()
    return true
end

local testStep = 0

function Mine:tick()
    self:refuel()

    if testStep > 1 then
        return
    elseif testStep > 0 then
        if self:moveTo(self.initPos) then
            testStep = testStep + 1
        end
        return
    elseif self:moveTo(Vec3(-20, 0, 20)) then
        testStep = testStep + 1
    end
end

function Mine:init()
    print("Starting mining turtle...")
    while true do
        self:tick()
        sleep(0)
    end
end

Mine:init()
