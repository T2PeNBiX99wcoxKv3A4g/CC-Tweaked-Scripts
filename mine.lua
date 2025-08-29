local Mine = {}
local Vec3 = require("vector3")
local MoveHelper = require("move_helper")

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

local testStep = 0
local initDirection = MoveHelper.directions.north

function Mine:tick()
    self:refuel()

    if testStep > 1 then
        if MoveHelper.direction ~= initDirection then
            MoveHelper:turnTo(initDirection)
            return
        end
        return
    elseif testStep > 0 then
        if MoveHelper:moveTo(self.initPos) then
            testStep = testStep + 1
        end
        return
    elseif MoveHelper:moveTo(Vec3(-20, 0, 20)) then
        testStep = testStep + 1
    end
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
