---@class vec3
local vec3 = {}

---Will never be use and replace with instance table
---@type number
vec3.x = nil
---@type number
vec3.y = nil
---@type number
vec3.z = nil

---@return vec3
function vec3:copy()
    return vec3(self.x, self.y, self.z)
end

---@param other vec3
---@return boolean
function vec3:equals(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

---@param other vec3
---@return vec3
function vec3:add(other)
    return vec3(self.x + other.x, self.y + other.y, self.z + other.z)
end

---@param other vec3
function vec3:addInPlace(other)
    self.x = self.x + other.x
    self.y = self.y + other.y
    self.z = self.z + other.z
end

---@param x number
---@return vec3
function vec3:addX(x)
    return vec3(self.x + x, self.y, self.z)
end

---@param y number
---@return vec3
function vec3:addY(y)
    return vec3(self.x, self.y + y, self.z)
end

---@param z number
---@return vec3
function vec3:addZ(z)
    return vec3(self.x, self.y, self.z + z)
end

---@param x number
function vec3:addXInPlace(x)
    self.x = self.x + x
end

---@param y number
function vec3:addYInPlace(y)
    self.y = self.y + y
end

---@param z number
function vec3:addZInPlace(z)
    self.z = self.z + z
end

---@return vec3
function vec3:zero()
    return vec3(0, 0, 0)
end

---@return vec3
function vec3:invert()
    return vec3(1 / self.x, 1 / self.y, 1 / self.z)
end

---@return vec3
function vec3:abs()
    return vec3(math.abs(self.x), math.abs(self.y), math.abs(self.z))
end

---@return vec3
function vec3:ceil()
    return vec3(math.ceil(self.x), math.ceil(self.y), math.ceil(self.z))
end

---@return vec3
function vec3:round()
    return vec3(math.floor(self.x + 0.5), math.floor(self.y + 0.5), math.floor(self.z + 0.5))
end

---@return vec3
function vec3:floor()
    return vec3(math.floor(self.x), math.floor(self.y), math.floor(self.z))
end

---@return vec3
function vec3:negate()
    return vec3(-self.x, -self.y, -self.z)
end

---@param other vec3
---@return number
function vec3:dot(other)
    return self.x * other.x + self.y * other.y + self.z * other.z
end

---@param other vec3
---@return vec3
function vec3:cross(other)
    return vec3(
        self.y * other.z - self.z * other.y,
        self.z * other.x - self.x * other.z,
        self.x * other.y - self.y * other.x
    )
end

---@param scalar number
---@return vec3
function vec3:scale(scalar)
    return vec3(self.x * scalar, self.y * scalar, self.z * scalar)
end

---@param other vec3
---@return vec3
function vec3:subtract(other)
    return vec3(self.x - other.x, self.y - other.y, self.z - other.z)
end

---@param other vec3
function vec3:subtractInPlace(other)
    self.x = self.x - other.x
    self.y = self.y - other.y
    self.z = self.z - other.z
end

---@param x number
---@return vec3
function vec3:subtractX(x)
    return vec3(self.x - x, self.y, self.z)
end

---@param y number
---@return vec3
function vec3:subtractY(y)
    return vec3(self.x, self.y - y, self.z)
end

---@param z number
---@return vec3
function vec3:subtractZ(z)
    return vec3(self.x, self.y, self.z - z)
end

---@param x number
function vec3:subtractXInPlace(x)
    self.x = self.x - x
end

---@param y number
function vec3:subtractYInPlace(y)
    self.y = self.y - y
end

---@param z number
function vec3:subtractZInPlace(z)
    self.z = self.z - z
end

-- Aliases
vec3.sub = vec3.subtract
vec3.subInPlace = vec3.subtractInPlace
vec3.subX = vec3.subtractX
vec3.subY = vec3.subtractY
vec3.subZ = vec3.subtractZ
vec3.subXInPlace = vec3.subtractXInPlace
vec3.subYInPlace = vec3.subtractYInPlace
vec3.subZInPlace = vec3.subtractZInPlace

---@return vec3
function vec3:normalize()
    local len = self:length()
    if len == 0 then return vec3:zero() end
    return vec3(self.x / len, self.y / len, self.z / len)
end

---@return number
function vec3:length()
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
end

---@param other vec3
---@return number
function vec3:distanceTo(other)
    local dx = self.x - other.x
    local dy = self.y - other.y
    local dz = self.z - other.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

---@param other vec3
---@return number
function vec3:manhattanDistanceTo(other)
    return math.abs(self.x - other.x) + math.abs(self.y - other.y) + math.abs(self.z - other.z)
end

---@return boolean
function vec3:isZero()
    return self.x == 0 and self.y == 0 and self.z == 0
end

---@return boolean
function vec3:isNil()
    return self.x == nil and self.y == nil and self.z == nil
end

---@return boolean
function vec3:isNilOrZero()
    return self:isNil() or self:isZero()
end

---@param vecTable table
---@return vec3|nil
function vec3:formTable(vecTable)
    if not vecTable.x or not vecTable.y or not vecTable.z then return nil end
    return vec3(vecTable.x, vecTable.y, vecTable.z)
end

local metaTable = {}

---@param x number
---@param y number
---@param z number
---@return vec3
function metaTable:__call(x, y, z)
    local obj = { x = x or 0, y = y or 0, z = z or 0 }
    local objMetaTable = { __index = vec3 }

    function objMetaTable:__newindex(key, value)
        if (key == "x" or key == "y" or key == "z") and type(value) == "number" then
            rawset(self, key, value)
            return
        end
        error("Trying to add invalid value to Vec3", 2)
    end

    setmetatable(obj, objMetaTable)
    return obj
end

---@return string
function metaTable:__tostring()
    return string.format("Vec3(%s, %s, %s)", self.x, self.y, self.z)
end

---@param other vec3
---@return vec3
function metaTable:__add(other)
    return vec3(self.x + other.x, self.y + other.y, self.z + other.z)
end

---@param other vec3
---@return vec3
function metaTable:__sub(other)
    return vec3(self.x - other.x, self.y - other.y, self.z - other.z)
end

---@param other vec3
---@return vec3
function metaTable:__mul(other)
    return vec3(self.x * other.x, self.y * other.y, self.z * other.z)
end

---@param other vec3
---@return vec3
function metaTable:__div(other)
    return vec3(self.x / other.x, self.y / other.y, self.z / other.z)
end

---@return vec3
function metaTable:__unm()
    return vec3(-self.x, -self.y, -self.z)
end

---@param other vec3
---@return boolean
function metaTable:__eq(other)
    return self.x == other.x and self.y == other.y and self.z == other.z
end

---@param other vec3
---@return boolean
function metaTable:__lt(other)
    return self.x < other.x and self.y < other.y and self.z < other.z
end

---@param other vec3
---@return boolean
function metaTable:__le(other)
    return self.x <= other.x and self.y <= other.y and self.z <= other.z
end

function metaTable:__newindex(key, value)
    error("Attempt to modify read-only table", 2)
end

function metaTable:__concat(other)
    return tostring(self) .. tostring(other)
end

setmetatable(vec3, metaTable)

return vec3
