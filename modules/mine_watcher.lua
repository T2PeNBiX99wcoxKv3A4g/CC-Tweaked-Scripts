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
mineWatcher.minerGPSList = {}

local messageCheck = {
    "currentStatus",
    "currentPosition"
}

function mineWatcher:handleMessage()
    local id, message = rednet.receive(self.protocol)
    if not id then return end
    if type(message) ~= "table" or not utils.tableKeyCheck(message, messageCheck) then return end
    local gpsMsg = message --[[@as mineGPS.message]]
    ---@type mineGPS.data
    local data = {
        currentStatus = gpsMsg.currentStatus,
        currentPosition = vec3.fromTable(gpsMsg.currentPosition) or vec3.zero()
    }

    self.minerGPSList[id] = data
end

---@type string[]
mineWatcher.statusName = {
    "idle",
    "mining",
    "tempBacking",
    "backingFinished",
    "backingUnfinished",
    "finished",
    "unfinished"
}

function mineWatcher:refreshWatcher()
    term.clear()
    term.setCursorPos(1, 1)
    print("Miner GPS List: ")

    for id, data in pairs(self.minerGPSList) do
        print(string.format("ID %d: pos - %s, status - %s", id, data.currentPosition,
            self.statusName[data.currentStatus + 1] or "unknown"))
    end
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

    term.clear()
    term.setCursorPos(1, 1)
    print("Trying get miner gps infos...")

    while true do
        self:handleMessage()
        self:refreshWatcher()
    end
end

return mineWatcher
