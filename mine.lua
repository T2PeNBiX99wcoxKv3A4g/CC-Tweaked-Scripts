local Mine = {}
local Vec3 = require("vector3")
local MoveHelper = require("move_helper")

---@type Vec3
Mine.initPos = Vec3(0, 0, 0)
---@type MoveHelper.directions
Mine.initDirection = MoveHelper.directions.north
---@type Vec3[]
Mine.Steps = {}
---@type number
Mine.currentStep = 1
---@type number
Mine.done = 0

---@param size number
---@param y number
---@return Vec3[]
function Mine:mine2DAreaPath(size, y)
    local points = {}
    local sizeEnd = size - 1

    for x = 0, -sizeEnd, -1 do
        for z = 0, sizeEnd do
            table.insert(points, Vec3(x, y, z))
        end
    end

    table.sort(points, function(a, b)
        if a.x == b.x then
            return a.z < b.z
        end
        return a.x > b.x
    end)

    return points
end

---@param size number
---@param height number
---@return Vec3[]
function Mine:mine3DAreaPath(size, height)
    local points = {}
    local newHeight = height + 1

    for y = -1, -newHeight, -1 do
        local layerPoints = self:mine2DAreaPath(y, size)
        for _, v in ipairs(layerPoints) do
            table.insert(points, v)
        end
    end

    return points
end

function Mine:tick()
    if self.done > 0 and self.done < 1 then
        print("Mining test complete!")
        self.done = 2
        return
    end

    for k, v in ipairs(self.Steps) do
        print(string.format("Step %d/%d: Moving to {x: %d, y: %d, z: %d}", k, #self.Steps, v.x, v.y, v.z))
        MoveHelper:moveTo(v)
    end

    MoveHelper:moveTo(self.initPos)
    MoveHelper:turnTo(self.initDirection)
    self.done = 1
end

function Mine:init()
    self.initPos = MoveHelper.position
    self.initDirection = MoveHelper.direction

    term.clear()
    print("Enter the size of the cube to mine (default 5): ")
    write("> ")
    local size = tonumber(read()) or 5

    term.clear()
    print("Enter the height of the cube to mine (default 11): ")
    write("> ")
    local height = tonumber(read()) or 11

    self.Steps = self:mine2DAreaPath(size, -1)

    term.clear()
    print(string.format("Starting mining a cube of size %d and height %d", size, height))

    while true do
        self:tick()
        sleep(0)
    end
end

Mine:init()
