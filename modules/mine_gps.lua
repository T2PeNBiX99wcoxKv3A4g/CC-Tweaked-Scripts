local class = require("modules.class")
local vec3 = require("modules.vector3")
local fileHelper = require("modules.file_helper")
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
---@type string
mineGPS.settingName = "mineGPS.gpsAvailable"
---@type table<number, mineGPS.data>
mineGPS.minerGPSList = {}
---@type fileHelper
mineGPS.gpsHelper = fileHelper(fileHelper.type.save, "mine_gps_list.json")

---@class mineGPS.data
---@field currentStatus mine.status
---@field currentPosition vec3

---@class mineGPS.message
---@field currentStatus mine.status
---@field currentPosition vec3Table

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
    "currentPosition"
}

function mineGPS:handleMessage()
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
mineGPS.statusName = {
    "idle",
    "mining",
    "tempBacking",
    "backingFinished",
    "backingUnfinished",
    "finished",
    "unfinished"
}

function mineGPS:refreshWatcher()
    term.clear()
    term.setCursorPos(1, 1)
    print("Miner GPS List: ")

    for id, data in pairs(self.minerGPSList) do
        print(string.format("ID %d: pos - %s, status - %s", id, data.currentPosition,
            self.statusName[data.currentStatus + 1] or "unknown"))
    end
end

function mineGPS:saveGPSList()
    self.gpsHelper:save(table.copy(self.minerGPSList))
end

function mineGPS:init()
    settings.define(self.settingName, {
        description = "GPS is available or not",
        default = false,
        type = "boolean"
    })

    self.gpsHelper:delete()
    self:gpsSetup()

    term.clear()
    term.setCursorPos(1, 1)
    print("Trying get miner gps infos...")

    if not self.gpsAvailable then
        printError("GPS is not Available!")
        settings.set(self.settingName, false)
        settings.save()
        return
    end

    settings.set(self.settingName, true)
    settings.save()

    while true do
        self:handleMessage()
        self:refreshWatcher()
        self:saveGPSList()
        sleep(0)
    end
end

return mineGPS
