local Mine = {}
local Vec3 = require("vector3")
local MoveHelper = require("move_helper")

---@type Vec3
Mine.initPos = Vec3(0, 0, 0)

---@param radius number
---@return Vec3[]
function Mine:generateSphere(radius)
    local points = {}
    local rSquared = radius * radius

    for x = -radius, radius do
        for y = -radius, radius do
            for z = -radius, radius do
                if x * x + y * y + z * z <= rSquared then
                    table.insert(points, Vec3(x, y, z))
                end
            end
        end
    end

    table.sort(points, function(a, b)
        return (a.x * a.x + a.y * a.y + a.z * a.z) < (b.x * b.x + b.y * b.y + b.z * b.z)
    end)

    return points
end

---@param size number
---@return Vec3[]
function Mine:generateCube(size)
    local points = {}
    local halfSize = math.floor(size / 2)

    for x = -halfSize, halfSize do
        for y = -halfSize, halfSize do
            for z = -halfSize, halfSize do
                table.insert(points, Vec3(x, y, z))
            end
        end
    end

    table.sort(points, function(a, b)
        return math.abs(a.x) + math.abs(a.y) + math.abs(a.z) < math.abs(b.x) + math.abs(b.y) + math.abs(b.z)
    end)

    return points
end

---@param radius number
---@param height number
---@return Vec3[]
function Mine:generateCylinder(radius, height)
    local points = {}
    local rSquared = radius * radius
    local halfHeight = math.floor(height / 2)

    for x = -radius, radius do
        for z = -radius, radius do
            if x * x + z * z <= rSquared then
                for y = -halfHeight, halfHeight do
                    table.insert(points, Vec3(x, y, z))
                end
            end
        end
    end

    table.sort(points, function(a, b)
        return (a.x * a.x + a.z * a.z) < (b.x * b.x + b.z * b.z)
    end)

    return points
end

---@param size number
---@param height number
---@return Vec3[]
function Mine:generateHighCube(size, height)
    local points = {}
    local halfSize = math.floor(size / 2)
    local halfHeight = math.floor(height / 2)

    for x = -halfSize - 2, 0 do
        for y = -halfHeight * 2, 0 do
            for z = 0, halfSize * 2 do
                table.insert(points, Vec3(x, y, z))
            end
        end
    end

    -- table.sort(points, function(a, b)
    --     return math.abs(a.x) + math.abs(a.y) + math.abs(a.z) < math.abs(b.x) + math.abs(b.y) + math.abs(b.z)
    -- end)

    return points
end

local initDirection = MoveHelper.directions.north
local done = 0
local testTable = Mine:generateHighCube(5, 11)

function Mine:tick()
    if done > 0 and done < 1 then
        print("Mining test complete!")
        done = 2
        return
    end

    for k, v in ipairs(testTable) do
        MoveHelper:moveTo(v)
    end

    MoveHelper:moveTo(self.initPos)
    MoveHelper:turnTo(initDirection)
    done = 1
end

function Mine:init()
    print("Starting mining turtle...")
    initDirection = MoveHelper.direction
    while true do
        self:tick()
        sleep(0)
    end
end

Mine:init()
