local class = require("modules.class")
local vec3 = require("modules.vector3")
local utils = require("modules.utils")

---@class mineGPS
local mineGPS = class("mineGPS")

---@enum mineGPS.modes
mineGPS.modes = {
    noModem = 0,
    host = 1,
    client = 2
}

---@type mine.modes
mineGPS.currentMode = mineGPS.modes.noModem
---@type boolean
mineGPS.gpsAvailable = false
---@type ccTweaked.peripherals.Modem
mineGPS.modem = nil
---@type string
mineGPS.protocol = "mineGPS"

---@class mineGPS.data
---@field currentStatus mine.status
---@field currentPosition vec3

---@type boolean
MineGPSIsAvailable = false
---@type table<number, mineGPS.data>
MineGPSOtherPos = {}

function mineGPS:gpsSetup()
    self.gpsAvailable = gps.locate(2, false) and true or false
    if not self.gpsAvailable then return end

    ---@type ccTweaked.peripherals.Modem|nil
    local modem = peripheral.find("modem") --[[@as ccTweaked.peripherals.Modem|nil]]
    if not modem then return end

    rednet.open(peripheral.getName(modem))

    self.modem = modem
end

local messageCheck = {
    "currentStatus",
    "currentPosition",
    "currentDirection"
}

function mineGPS:handleMessage()
    local id, message = rednet.receive(self.protocol)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as mineGPS.data]]
    ---@type mineGPS.data
    local data = {
        currentStatus = gpsMsg.currentStatus,
        currentPosition = gpsMsg.currentPosition:copy()
    }

    MineGPSOtherPos[id] = data
end

function mineGPS:init()
    self:gpsSetup()

    if not self.gpsAvailable then
        printError("GPS is not Available!")
        return
    end

    MineGPSIsAvailable = true

    while true do
        self:handleMessage()
        sleep(0)
    end
end

return mineGPS
