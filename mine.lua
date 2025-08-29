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
---@param height number
---@return Vec3[]
function Mine:generateHighCube(size, height)
    local points = {}
    local halfSize = math.floor(size / 2)
    local halfHeight = math.floor(height / 2)

    for x = -halfSize - 2, 0 do
        for y = -halfHeight * 2 + 1, -1 do
            for z = 0, halfSize * 2 do
                table.insert(points, Vec3(x, y, z))
            end
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

    for _, v in ipairs(self.Steps) do
        MoveHelper:moveTo(v)
    end

    MoveHelper:moveTo(self.initPos)
    MoveHelper:turnTo(self.initDirection)
    self.done = 1
end

function Mine:init()
    print("Starting mining turtle...")

    self.initPos = MoveHelper.position
    self.initDirection = MoveHelper.direction

    local size = tonumber(read("Enter the size of the cube to mine (default 5): ")) or 5
    local height = tonumber(read("Enter the height of the cube to mine (default 11): ")) or 11

    self.Steps = self:generateHighCube(size, height)

    while true do
        self:tick()
        sleep(0)
    end
end

Mine:init()
