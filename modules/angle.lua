local expect = require("cc.expect")
local expect, range = expect.expect, expect.range

local class = require("modules.class")

---@class angle
local angle = class("angle")

---@class angleTable
---@field direction angle.directions

---      0
---3   M   1
---      2

---@enum angle.directions
angle.directions = {
    north = 0,
    east = 1,
    south = 2,
    west = 3
}

--- For easy iteration
---@private
---@type string[]
angle.directionsArray = { "north", "east", "south", "west" }

---@enum angle.turns
angle.turns = {
    none = 0,
    left = 1,
    right = 2,
    around = 3
}

---@type angle.directions
angle.direction = nil

---@return angle
function angle:copy()
    return angle(self.direction) --[[@as angle]]
end

---@param other angle
---@return boolean
function angle:equals(other)
    return self.direction == other.direction
end

---@return angle
function angle:turnLeft()
    return angle((self.direction - 1) % 4)
end

---@return angle
function angle:turnRight()
    return angle((self.direction + 1) % 4)
end

local quickTurn = {
    angle.turns.none,
    angle.turns.right,
    angle.turns.around,
    angle.turns.left
}

---@param to angle
---@return angle.turns
function angle:getQuickTurn(to)
    local diff = self:getRotationDirection(to)
    if quickTurn[diff + 1] then
        return quickTurn[diff + 1]
    end
    return self.turns.none
end

---@return string
function angle:getDirectionName()
    if angle.directionsArray[self.direction + 1] then
        return angle.directionsArray[self.direction + 1]
    end
    return "unknown"
end

---@param to angle
---@return angle.directions
function angle:getRotationDirection(to)
    return (to.direction - self.direction) % 4
end

---@return boolean
function angle:isZero()
    return self.direction == 0
end

---@return boolean
function angle:isNil()
    return self.direction == nil
end

---@return boolean
function angle:isNilOrZero()
    return self:isNil() or self:isZero()
end

---@param angleTable angleTable
---@return angle|nil
function angle.fromTable(angleTable)
    if not angleTable.direction then return nil end
    return angle(angleTable.direction)
end

---@param obj angle | any
---@return boolean
function angle.isAngle(obj)
    return obj and obj.__type and obj.__type == "angle" and not obj:isNil()
end

angle.__type = "angle"

---@private
function angle:__newindex(key, value)
    if (key == "direction") and type(value) == "number" then
        rawset(self, key, value)
        return
    end
    error("Trying to add invalid value to angle", 2)
end

---@private
---@param dir angle.directions
function angle:init(dir)
    range(dir, 0, 3)
    self.direction = dir
end

---@return angle
function angle.north()
    return angle(angle.directions.north)
end

---@return angle
function angle.east()
    return angle(angle.directions.east)
end

---@return angle
function angle.south()
    return angle(angle.directions.south)
end

---@return angle
function angle.west()
    return angle(angle.directions.west)
end

---@private
angle.__eq = angle.equals

---@private
---@return string
function angle:__tostring()
    return string.format("angle(%s)", self:getDirectionName())
end

---@private
function angle:__concat(other)
    return tostring(self) .. tostring(other)
end

return angle
