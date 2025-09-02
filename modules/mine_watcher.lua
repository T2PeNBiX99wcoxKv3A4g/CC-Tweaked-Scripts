local class = require("modules.class")
local vec3 = require("modules.vector3")
local utils = require("modules.utils")

---@class mineWatcher
local mineWatcher = class("mineWatcher")

---@type ccTweaked.peripherals.Modem
mineWatcher.modem = nil
---@type string
mineWatcher.protocol = "mineGPS"
---@type table<number, mineGPS.data>
mineWatcher.AllPos = {}

local messageCheck = {
    "currentStatus",
    "currentPosition",
    "currentDirection"
}

function mineWatcher:handleMessage()
    local id, message = rednet.receive(self.protocol)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as mineGPS.data]]
    ---@type mineGPS.data
    local data = {
        currentStatus = gpsMsg.currentStatus,
        currentPosition = gpsMsg.currentPosition:copy()
    }

    self.AllPos[id] = data
end

function mineWatcher:refreshWatcher()
    if table.isEmpty(self.AllPos) then return end
    term.clear()
    term.setCursorPos(1, 1)
    print(self.AllPos)
end

function mineWatcher:redNetSetup()
    ---@type ccTweaked.peripherals.Modem|nil
    local modem = peripheral.find("modem") --[[@as ccTweaked.peripherals.Modem|nil]]
    if not modem then return end

    rednet.open(peripheral.getName(modem))

    self.modem = modem
end

function mineWatcher:init()
    self:redNetSetup()

    while true do
        term.clear()
        term.setCursorPos(1, 1)
        print("Trying get all miner infos...")
        self:handleMessage()
        self:refreshWatcher()
    end
end

return mineWatcher
