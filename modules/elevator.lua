local class = require("modules.class")
local vec3 = require("modules.vector3")
local moveHelper = require("modules.move_helper")
local refuelHelper = require("modules.refuel_helper")

---@class elevator
local elevator = class("elevator")

---@type vec3
elevator.initPos = vec3(0, 0, 0)
---@type moveHelper.directions
elevator.initDirection = moveHelper.directions.north
---@type refuelHelper
elevator.refuelHelper = refuelHelper()
---@type moveHelper
elevator.moveHelper = moveHelper(elevator)

function elevator:heightLevelControl()
    term.clear()
    term.setCursorPos(1, 1)
    print("Enter height increase (-1 will descent height): ")
    write("> ")

    local highLevel = tonumber(read()) or 1

    term.clear()
    term.setCursorPos(1, 1)
    print("Height level increase " .. highLevel)

    self.moveHelper:moveTo(self.moveHelper.position:addY(highLevel))
end

function elevator:init()
    self.initPos = self.moveHelper.position:copy()
    self.initDirection = self.moveHelper.direction

    while true do
        self:heightLevelControl()
        sleep(0)
    end
end

return elevator
